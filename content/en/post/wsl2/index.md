---
title: "WSL2 Installation and Usage Guide"
description: "From install to daily use: a complete WSL2 setup guide covering distro management, resource limits, and troubleshooting."
slug: "wsl2"
date: 2026-08-13T15:41:00+08:00
tags:
  - wsl
  - wsl2
  - linux
  - windows
categories:
  - windows
---

WSL (Windows Subsystem for Linux) is Microsoft's Linux compatibility layer for Windows 10/11. It lets you run Linux commands and applications natively, without a VM or dual boot. WSL2, the second generation, strikes a better balance between performance, compatibility, and resource usage.

This guide is for developers with some programming background. It covers installing WSL2, initial setup, resource limits, and troubleshooting. After reading, you'll have a working Linux development environment on Windows.

## WSL1 or WSL2?

Released with Windows 10 in 2019, WSL2's core improvement is architectural: WSL1 translates Linux syscalls into Windows syscalls with partial compatibility, while WSL2 runs in a lightweight VM with a real Linux kernel and full syscall support.

| Dimension | WSL1 | WSL2 | Traditional VM |
| :-------- | :--- | :--- | :------------- |
| Linux kernel | None (translation layer) | Full kernel | Full kernel |
| Syscalls | Partial | Full | Full |
| Linux dir I/O | Slow | 3-5x faster | Fast |
| Windows dir access | Fast | Slower (cross-filesystem) | Slow |
| Memory usage | Low | Moderate (lightweight VM) | High |
| Startup | Fast | Seconds | Slow |

WSL2 can be up to 20x faster than WSL1 when extracting tar archives, and roughly 2-5x faster for operations like `git clone`. It also supports GPU acceleration and Linux GUI apps.

> Verdict: WSL2 is the better choice in almost every scenario. If you frequently access files on Windows drives, you may keep WSL1 for a specific distro.

## Installation

### Prerequisites

- Windows 10 version 2004 (build 19041) or later, or Windows 11
- CPU with virtualization enabled (Intel VT-x / AMD-V)

> Tip: Press `Win + R`, type `winver`, and press Enter to check your Windows version.

### One-command install (recommended)

Open PowerShell or Windows Terminal as administrator:

```powershell
wsl --install
```

This enables WSL and the Virtual Machine Platform, installs the latest kernel, sets WSL2 as the default, and installs Ubuntu. Restart your computer afterwards.

### Install another distro

```powershell
wsl --list --online        # list available distros
wsl --install -d Debian    # install a specific one
```

| Option | Description |
| :----- | :---------- |
| `--distribution` | Distro name |
| `--no-launch` | Don't launch after install |
| `--web-download` | Download from the web, not the Microsoft Store |
| `--location` | Custom install directory |

### Manual install (alternative)

If `wsl --install` is unavailable:

1. Press `Win + R`, type `appwiz.cpl`, and open "Turn Windows features on or off"
2. Enable "Windows Subsystem for Linux" and "Virtual Machine Platform", then restart
3. Run `wsl --set-default-version 2` in an admin PowerShell
4. Install your distro from the Microsoft Store

## Initial setup

### Username and password

The first launch prompts you to create a Linux username and password. This account is independent of your Windows account and has `sudo` privileges by default.

> Note: the screen shows nothing while typing the password — that's normal security behavior.

Forgot your password? Enter as root from PowerShell and reset it:

```powershell
wsl -u root
# or with a specific distro: wsl -d Ubuntu -u root
```

```bash
passwd <username>
```

### Update packages

```bash
sudo apt update
sudo apt upgrade -y
```

### Switch to a faster mirror (China users)

```bash
bash <(curl -sSL https://linuxmirrors.cn/main.sh)
```

### Install Windows Terminal

Install "Windows Terminal" from the Microsoft Store for multi-tab management of WSL, PowerShell, and CMD. Set Ubuntu as the default profile for the best experience.

## Limiting resources

WSL2 can use up to 80% of your physical memory by default. Limit it via `%UserProfile%\.wslconfig` (that is, `C:\Users\<username>\.wslconfig`):

```ini
[wsl2]
memory=8GB                # max memory
processors=4              # CPU cores
swap=4GB                  # swap size
localhostForwarding=true  # localhost forwarding
```

> Tip: run `wsl --shutdown` to fully stop WSL, wait about 8 seconds, then start again for changes to take effect.

## Common commands

### WSL management (run in PowerShell / CMD)

| Command | Description |
| :------ | :---------- |
| `wsl --status` | Show WSL status and default version |
| `wsl -l -v` | List distros and their versions |
| `wsl` / `wsl -d <distro>` | Launch the default or a specific distro |
| `wsl -t <distro>` | Terminate a distro |
| `wsl --shutdown` | Shut down all WSL instances |
| `wsl --set-default-version 2` | Set WSL2 as default |
| `wsl --set-version <distro> 2` | Convert a distro to WSL2 |
| `wsl --update` | Update the WSL kernel |
| `wsl --unregister <distro>` | Uninstall a distro (removes its filesystem) |
| `wsl --export <distro> <file.tar>` | Export a distro as a tar backup |

### Linux basics (run inside WSL)

| Command | Description |
| :------ | :---------- |
| `uname -a` | Kernel version and architecture |
| `df -h` | Disk space usage |
| `free -h` | Memory usage |
| `pwd` | Current working directory |
| `ls -lah` | List all files (including hidden) |

## Troubleshooting

**Q: "Command not recognized" or install fails?**
Make sure virtualization is enabled in BIOS (Intel VT-x / AMD-V) and that WSL and the Virtual Machine Platform features are turned on.

**Q: `wsl --list --online` cannot fetch the list?**
Usually a network issue (cannot reach `raw.githubusercontent.com`). Change your DNS or configure a proxy.

**Q: WSL2 uses too much memory?**
Limit memory and CPU with `.wslconfig`, as described above.

**Q: Cannot use a proxy in WSL2?**
WSL2 uses NAT networking and is isolated from the host. Enable mirrored networking in `.wslconfig`:

```ini
[wsl2]
networkingMode=mirrored
```

Or set proxy environment variables manually inside WSL.

## Conclusion

WSL2 lets Windows developers use a full Linux environment without a VM or dual boot. Core recommendations:

- Use `wsl --install` for a one-command setup
- Install Windows Terminal for a better experience
- Cap resource usage with `.wslconfig`
- Switch to a faster mirror if you're in China

## References

- [Microsoft Learn - Set up a WSL development environment](https://learn.microsoft.com/en-us/windows/wsl/setup/environment)
- [Microsoft Learn - Compare WSL versions](https://learn.microsoft.com/en-us/windows/wsl/compare-versions)
- [Microsoft Learn - Advanced settings configuration in WSL](https://learn.microsoft.com/en-us/windows/wsl/wsl-config)
- [Ubuntu - Install Ubuntu on WSL 2](https://ubuntu.com/tutorials/install-ubuntu-on-wsl2)
- [Linux Mirrors - one-command mirror switch](https://linuxmirrors.cn/)
