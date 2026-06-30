# AI 写作助手 - Word Add-in

在 Word 中用 AI 生成文档，流式输出，支持 OpenAI 兼容 API。**一次安装，开 Word 即用。**

## ✨ 功能

| 功能 | 说明 |
|------|------|
| 💬 **AI 对话** | 多轮聊天，回答可插入文档 |
| ✍️ **全文生成** | 输入主题，AI 生成完整文档 |
| 🔧 **改写润色** | 润色/扩写/缩写/正式/口语化 |
| 🌐 **翻译** | 中英互译 |
| 📋 **模板库** | 周报、方案、邮件、会议纪要等 |
| 📌 **自定义 Prompt** | 保存常用 prompt 快速复用 |

## 🚀 一键安装（永久使用）

以 **管理员身份** 打开 PowerShell，执行：

```powershell
cd C:\Users\肥鱼工作室\source\word-ai-addin
.\install-permanent.ps1
```

一次操作后：
- ✅ 加载项永久注册到 Word 注册表
- ✅ 服务器设为开机自启（后台静默运行，无窗口无弹窗）
- ✅ 立即启动服务器 + 打开 Word
- ✅ **以后每次打开 Word 都能直接看到「AI 写作助手」标签**

## ⚙️ 首次配置 API

在 Word 中点击「AI 写作助手」→ ⚙️ 设置：

| 字段 | 示例 |
|------|------|
| API Key | `sk-xxx...` |
| 接口地址 | `https://api.openai.com` |
| 模型 | `gpt-3.5-turbo` / `deepseek-chat` 等 |

支持所有 OpenAI 兼容 API。

## 🛑 卸载

```powershell
.\uninstall-permanent.ps1
```

## 📁 项目结构

| 文件 | 功能 |
|------|------|
| `install-permanent.ps1` | 🔥 一键永久安装（推荐） |
| `uninstall-permanent.ps1` | 🗑️ 完全卸载 |
| `server.cjs` | Node.js HTTP 服务器 |
| `start-server.vbs` | 开机自启静默启动脚本 |
| `manifest.xml` | Office 加载项清单 |
| `register-addin.ps1` | 注册 Word 加载项 |
| `src/` | React + TypeScript 源码 |
| `dist/` | 构建产物 |

## 🛠 开发

```bash
npm run dev     # Vite 开发服务器
npm run build   # TypeScript 检查 + 构建
npm run start   # 启动生产服务器
```

## 技术栈

- React 18 + TypeScript
- Vite 6
- Office.js
- react-markdown（流式渲染）
- OpenAI 兼容 API（SSE 流式输出）
