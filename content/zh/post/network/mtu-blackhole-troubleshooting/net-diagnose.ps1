<#
.SYNOPSIS
    Layered network triage for "pages will not open but ping works".

.DESCRIPTION
    Read-only probe chain, no admin rights and no configuration changes:
    DNS -> TCP:443 -> plain HTTP on 443 -> TLS -> SNI response size -> line throughput.
    Each layer answers one question, so the verdict points at the failing layer
    instead of at a guess. Prints one VERDICT line with suggested next actions.

.PARAMETER Targets
    Host names to probe, comma separated.

.PARAMETER TimeoutSec
    Per-probe timeout in seconds.

.PARAMETER ThroughputUrl
    Large file used as a data-plane baseline. Pass an empty string to skip.

.EXAMPLE
    pwsh -NoProfile -File .\net-diagnose.ps1

.EXAMPLE
    pwsh -NoProfile -File .\net-diagnose.ps1 -Targets www.baidu.com,www.douyu.com

.NOTES
    Exit code: 0 healthy, 1 problem detected, 2 inconclusive.
#>
[CmdletBinding()]
param(
    [string[]]$Targets = @('www.baidu.com', 'www.douyu.com', 'www.5eplay.com', 'www.bilibili.com'),
    [int]$TimeoutSec = 6,
    [string]$ThroughputUrl = 'https://mirrors.ustc.edu.cn/ubuntu/dists/noble/main/binary-amd64/Packages.gz'
)

$ErrorActionPreference = 'Continue'
$TimeoutMs = $TimeoutSec * 1000
$rows = New-Object System.Collections.Generic.List[object]
$notes = New-Object System.Collections.Generic.List[string]

# `-File script.ps1 -Targets a,b` hands over one literal string, so split here as well.
$Targets = @($Targets | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })

function Write-Section {
    param([string]$Title)
    Write-Host ''
    Write-Host "== $Title" -ForegroundColor Cyan
}

# Windows ships curl.exe since 1803; it is the most predictable TLS/timing client here.
$curl = (Get-Command curl.exe -ErrorAction SilentlyContinue).Source
if (-not $curl) {
    Write-Host 'curl.exe not found - TLS probes are unavailable, results will be incomplete.' -ForegroundColor Yellow
}

# Never throws: returns curl exit code, merged output and wall time.
function Invoke-CurlProbe {
    param([string[]]$CurlArgs)
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $out = & $curl @CurlArgs 2>&1
    $code = $LASTEXITCODE
    $sw.Stop()
    [pscustomobject]@{
        Code = $code
        Out  = (($out | Out-String).Trim())
        Sec  = [math]::Round($sw.Elapsed.TotalSeconds, 2)
    }
}

# curl exit codes worth separating:
#   0/22 = an HTTP response arrived          28 = no data before the timeout
#   52   = TCP answered, then nothing       35/56/60 = peer answered, TLS failed
# A TLS error means a small alert packet DID reach us - that is the useful contrast.
function Get-ProbeState {
    param([int]$Code)
    switch ($Code) {
        0 { 'ok' }
        22 { 'ok' }
        28 { 'nodata' }
        35 { 'tlserr' }
        56 { 'tlserr' }
        60 { 'tlserr' }
        52 { 'no-http' }
        default { "exit$Code" }
    }
}

function Test-TcpPort {
    param([string]$Ip, [int]$Port)
    $client = New-Object System.Net.Sockets.TcpClient
    try {
        if ($client.ConnectAsync($Ip, $Port).Wait($TimeoutMs) -and $client.Connected) { return $true }
        return $false
    } catch { return $false } finally { $client.Close() }
}

function Test-PrivateAddress {
    param([string]$Ip)
    if ($Ip -match '^(10\.|127\.|169\.254\.|192\.168\.)') { return $true }
    if ($Ip -match '^172\.(1[6-9]|2[0-9]|3[01])\.') { return $true }
    if ($Ip -match '^100\.(6[4-9]|[7-9][0-9]|1[01][0-9]|12[0-7])\.') { return $true }
    return $false
}

# ---------------------------------------------------------------- environment
Write-Section '环境 / environment'

$route = Get-NetRoute -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue |
    Sort-Object RouteMetric, InterfaceMetric | Select-Object -First 1
$ifIndex = $null
$mtu = $null
$alias = 'unknown'
if ($route) {
    $ifIndex = $route.ifIndex
    $alias = (Get-NetAdapter -InterfaceIndex $ifIndex -ErrorAction SilentlyContinue).Name
    $mtu = (Get-NetIPInterface -InterfaceIndex $ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue).NlMtu
}
Write-Host ("  默认出网接口 : {0} (ifIndex {1}, MTU {2})" -f $alias, $ifIndex, $mtu)

$v6 = @(Get-NetIPAddress -AddressFamily IPv6 -ErrorAction SilentlyContinue |
    Where-Object { $_.IPAddress -notmatch '^fe80' -and $_.PrefixOrigin -ne 'WellKnown' })
if ($v6.Count -gt 0) { $v6Text = ($v6.IPAddress -join ', ') } else { $v6Text = '无' }
Write-Host ("  全局 IPv6    : {0}" -f $v6Text)

$proxy = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -ErrorAction SilentlyContinue
if ($proxy.ProxyEnable -eq 1) { $proxyText = $proxy.ProxyServer } else { $proxyText = '未启用' }
Write-Host ("  系统代理     : {0} (下面探测一律 --noproxy，绕开它)" -f $proxyText)

$hosts = Get-Content "$env:SystemRoot\System32\drivers\etc\hosts" -ErrorAction SilentlyContinue |
    Where-Object { $_ -notmatch '^\s*#' -and $_.Trim() -ne '' }
$pinned = @()
if ($hosts) {
    foreach ($line in $hosts) {
        foreach ($t in $Targets) { if ($line -match [regex]::Escape($t)) { $pinned += $line.Trim() } }
    }
}
if ($pinned.Count -gt 0) {
    Write-Host ("  hosts 固定了目标: {0}" -f ($pinned -join ' | ')) -ForegroundColor Yellow
    $notes.Add('hosts 文件固定了部分目标域名，判断前先注释掉这些行')
} else {
    Write-Host '  hosts        : 无自定义条目'
}

if ($mtu -and $mtu -lt 1500) {
    $notes.Add("本机 MTU 是非默认值 $mtu（若曾用降 MTU 绕过 MTU 黑洞，属预期）")
}

# ---------------------------------------------------------------- per-target probes
Write-Section '分层探测 / layered probes'

foreach ($t in $Targets) {
    $row = [ordered]@{
        Target = $t
        Dns    = '-'
        Tcp    = '-'
        Plain  = '-'
        Tls    = '-'
        Bogus  = '-'
        Note   = ''
    }

    $ip = $null
    try {
        $addr = [System.Net.Dns]::GetHostAddresses($t) |
            Where-Object { $_.AddressFamily -eq 'InterNetwork' } | Select-Object -First 1
        if ($addr) { $ip = $addr.IPAddressToString }
    } catch { }

    if (-not $ip) {
        $row.Dns = 'fail'
        $row.Note = '解析不到 A 记录'
        $rows.Add([pscustomobject]$row)
        continue
    }
    if (Test-PrivateAddress $ip) {
        $row.Dns = $ip
        $row.Note = '解析到内网/保留地址，疑似 DNS 劫持或污染'
        $rows.Add([pscustomobject]$row)
        continue
    }

    $row.Dns = $ip
    if (-not $curl) {
        $row.Tcp = 'skipped'
        $rows.Add([pscustomobject]$row)
        continue
    }

    if (Test-TcpPort $ip 443) { $row.Tcp = 'open' } else { $row.Tcp = 'closed' }

    # Plain HTTP on 443: does a SMALL response come back at all?
    $plainUrl = 'http://{0}:443/' -f $ip
    $p = Invoke-CurlProbe @('-s', '-k', '-o', 'NUL', '-m', "$TimeoutSec", '--noproxy', '*',
        '-H', "Host: $t", '-w', '%{http_code}', $plainUrl)
    $row.Plain = Get-ProbeState $p.Code

    # TLS with the real SNI: needs the server's multi-KB certificate flight.
    $r = Invoke-CurlProbe @('-s', '-k', '-o', 'NUL', '-m', "$TimeoutSec", '--noproxy', '*',
        '--resolve', "$t`:443:$ip", '-w', '%{http_code}', "https://$t/")
    $row.Tls = Get-ProbeState $r.Code

    # TLS with an unknown SNI: the server answers with a tiny alert packet.
    $b = Invoke-CurlProbe @('-s', '-k', '-o', 'NUL', '-m', "$TimeoutSec", '--noproxy', '*',
        '--resolve', "net-diagnose.invalid:443:$ip", '-w', '%{http_code}', 'https://net-diagnose.invalid/')
    $row.Bogus = Get-ProbeState $b.Code

    if ($row.Tcp -eq 'closed') {
        $row.Note = 'TCP 都连不上'
    } elseif ($row.Tls -eq 'tlserr') {
        $row.Note = 'TLS 层被拒（证书/告警）'
    } elseif ($row.Tls -eq 'nodata') {
        if ($row.Plain -eq 'ok' -or $row.Bogus -eq 'tlserr') {
            $row.Note = '小响应可达、大响应被丢'
        } elseif ($row.Plain -eq 'nodata') {
            $row.Note = '任何响应都收不到'
        } else {
            $row.Note = '只有 TCP 能连，数据层无响应'
        }
    }
    $rows.Add([pscustomobject]$row)
}

$fmt = "{0,-24} {1,-16} {2,-6} {3,-8} {4,-7} {5,-7} {6}"
Write-Host ($fmt -f 'target', 'dns->ip', 'tcp', 'http443', 'tls', 'sni', 'note')
foreach ($r in $rows) { Write-Host ($fmt -f $r.Target, $r.Dns, $r.Tcp, $r.Plain, $r.Tls, $r.Bogus, $r.Note) }

# ---------------------------------------------------------------- data plane
$speedKB = $null
if ($ThroughputUrl -and $curl) {
    Write-Section '线路数据面 / data plane'
    $d = Invoke-CurlProbe @('-s', '-o', 'NUL', '-m', '20', '--noproxy', '*',
        '-w', '%{http_code} %{size_download} %{speed_download}', $ThroughputUrl)
    $parts = $d.Out -split '\s+'
    if ($parts.Count -ge 3 -and $parts[0] -match '^\d+$' -and $parts[0] -ne '000') {
        $speedKB = [math]::Round([double]$parts[2] / 1KB, 0)
        Write-Host ("  下载 {0}" -f $ThroughputUrl)
        Write-Host ("  HTTP {0}, {1} KB, {2} KB/s" -f $parts[0], [math]::Round([double]$parts[1] / 1KB, 0), $speedKB)
    } else {
        Write-Host ("  下载 {0} 失败（不影响结论，只少一个对照）" -f $ThroughputUrl) -ForegroundColor Yellow
    }
}

# ---------------------------------------------------------------- verdict
Write-Section '结论 / verdict'

$total = $rows.Count
$ok = @($rows | Where-Object { $_.Tls -eq 'ok' }).Count
$blackhole = @($rows | Where-Object { $_.Note -eq '小响应可达、大响应被丢' })
$deadData = @($rows | Where-Object { $_.Note -eq '任何响应都收不到' -or $_.Note -eq '只有 TCP 能连，数据层无响应' })
$noTcp = @($rows | Where-Object { $_.Note -eq 'TCP 都连不上' })
$tlsErr = @($rows | Where-Object { $_.Note -eq 'TLS 层被拒（证书/告警）' })
$dnsBad = @($rows | Where-Object { $_.Note -like '*DNS*' -or $_.Note -eq '解析不到 A 记录' })

$verdict = 'INCONCLUSIVE'
$exit = 2
$next = @()

if ($ok -eq $total) {
    $verdict = 'HEALTHY'
    $exit = 0
    $next += '所有目标 TLS 握手正常；浏览器仍打不开就先清浏览器连接缓存或换浏览器复测'
} elseif ($blackhole.Count -gt 0) {
    $verdict = 'MTU/MSS BLACKHOLE SUSPECTED'
    $exit = 1
    $next += '小响应能回、服务器一发大包（证书）就断：典型是路径 MTU 偏小 + 上游没做 MSS 钳制 + ICMP 分片报文被丢'
    if ($mtu -and $mtu -ge 1500) {
        $next += "本机验证（需管理员）：netsh interface ipv4 set subinterface `"$alias`" mtu=1280 store=persistent"
        $next += '验证有效即坐实这条路的 MTU 问题；还原把 1280 换回 1500'
    } else {
        $next += "本机 MTU 已是 $mtu，仍有该特征：让上游设备（路由器）对每个 WAN 口开启 MSS 自动钳制"
    }
    $next += '这条通常不是本机能修的，根因在路由器/运营商一侧'
} elseif ($dnsBad.Count -gt 0) {
    $verdict = 'DNS 异常'
    $exit = 1
    $next += '换公共 DNS 后 ipconfig /flushdns 复测：223.5.5.5、119.29.29.29'
} elseif ($noTcp.Count -eq $total) {
    $verdict = 'TCP 层不通（上游 / 路由 / 代理）'
    $exit = 1
    $next += '先确认默认出网接口与网关，再对比直连与走代理两条路径'
} elseif ($tlsErr.Count -gt 0 -and $blackhole.Count -eq 0) {
    $verdict = 'TLS 被干预（证书或告警）'
    $exit = 1
    $next += '排查中间人：系统根证书是否被替换、安全软件是否开启 HTTPS 扫描'
} elseif ($deadData.Count -gt 0) {
    $verdict = '路径或目标侧黑洞（数据层无响应）'
    $exit = 1
    $next += 'TCP 能连却毫无数据返回：优先怀疑上游丢包或目标侧风控，而不是本机配置'
    $next += '换出口（手机流量）对照一次，即可区分本机与上游'
} elseif ($ok -gt 0) {
    $verdict = '部分目标异常'
    $exit = 1
    $next += '异常目标集中在特定 CDN / 网段时，换出口对照以区分本机与上游'
}

if ($speedKB -and $speedKB -gt 500 -and $blackhole.Count -gt 0) {
    $notes.Add("线路本身能跑到 $speedKB KB/s，说明是目标/路径相关的包级丢弃，不是带宽或断网")
}

Write-Host ("  VERDICT: {0}  ({1}/{2} 个目标 TLS 正常)" -f $verdict, $ok, $total) -ForegroundColor White
foreach ($n in $notes) { Write-Host ("  NOTE   : {0}" -f $n) -ForegroundColor DarkGray }
foreach ($n in $next) { Write-Host ("  NEXT   : {0}" -f $n) -ForegroundColor DarkGray }

exit $exit
