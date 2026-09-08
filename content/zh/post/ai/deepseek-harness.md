安装Node.js

安装dsh，`npx @deepseek-ai/dsh web`

```bash
npm warn deprecated node-domexception@1.0.0: Use your platform's native DOMException instead
```

- `node-domexception` 是一个旧的开源包，它的作用是在较老版本的 Node.js 中模拟 `DOMException` 这个全局错误类型。
- 现在 **Node.js 已经原生支持 `DOMException`**（从 v17 开始），所以这个包不再需要了，官方将其标记为“已弃用”（deprecated）。
- 你之所以看到这个警告，是因为 `@deepseek-ai/dsh` 的某个依赖项仍然引用了这个旧包，但 **它其实不会被执行或加载**，Node.js 会直接使用内置的 `DOMException`，所以不会造成任何功能缺失或错误。