# PotPlayer AI字幕翻译插件

## 📖 简介

这是一套用于PotPlayer的AI字幕实时翻译插件，支持接入主流AI大模型API进行字幕翻译。

## 📁 插件文件

| 文件 | 说明 |
|------|------|
| `SubtitleTranslate - AI.as` | 通用版本，支持OpenAI、DeepSeek、通义千问等兼容OpenAI格式的API |
| `SubtitleTranslate - DeepSeek.as` | DeepSeek专用版本，针对DeepSeek API优化 |

## 🚀 安装方法

1. 找到PotPlayer安装目录下的扩展文件夹：
   ```
   PotPlayer安装目录\Extension\Subtitle\Translate\
   ```
   
2. 将 `.as` 插件文件复制到该目录

3. 重启PotPlayer

## ⚙️ 配置方法

### 方法一：在PotPlayer中配置

1. 打开PotPlayer
2. 右键 → 字幕 → 字幕翻译 → 选择"AI大模型翻译"或"DeepSeek翻译"
3. 点击"账户设置"
4. 输入你的API Key和相关配置

### 方法二：直接修改插件代码

编辑 `.as` 文件，修改以下变量：

```angelscript
string g_apiKey = "你的API Key";
string g_baseUrl = "https://api.deepseek.com";  // 或其他API地址，如 https://api.openai.com
```

## 🔑 获取API Key

### OpenAI
1. 访问 https://platform.openai.com
2. 注册/登录账户
3. 在 API Keys 页面创建新的Key

### DeepSeek（推荐，性价比高）
1. 访问 https://platform.deepseek.com
2. 注册账户并充值
3. 在控制台获取API Key
4. API地址：`https://api.deepseek.com`

### 通义千问
1. 访问 https://dashscope.aliyun.com
2. 开通服务
3. 获取API Key
4. API地址：`https://dashscope.aliyuncs.com/compatible-mode`

### 其他兼容服务
任何兼容OpenAI API格式的服务都可以使用，只需修改API地址即可。

## 🎬 使用方法

1. 打开视频文件
2. 加载外挂字幕文件（.srt, .ass, .ssa等）
3. 右键 → 字幕 → 字幕翻译
4. 选择你安装的AI翻译插件
5. 选择源语言和目标语言
6. 字幕将自动实时翻译

## 🌍 支持的语言

- 自动检测（仅源语言）
- 简体中文
- 繁體中文
- English
- 日本語
- 한국어
- Français
- Deutsch
- Español
- Italiano
- Português
- Русский
- العربية
- हिन्दी
- ไทย

## ⚠️ 注意事项

1. **网络要求**：需要稳定的网络连接访问API服务
2. **费用**：AI API通常按使用量收费，请注意控制成本
3. **延迟**：由于需要网络请求，翻译会有一定延迟
4. **准确性**：AI翻译质量取决于所选模型，建议使用GPT-4或DeepSeek-chat

## 🔧 常见问题

### Q: 翻译没有反应？
A: 检查API Key是否正确，网络是否通畅

### Q: 翻译速度慢？
A: 可以尝试使用更快的模型（如gpt-3.5-turbo）或更近的API节点

### Q: 翻译结果不准确？
A: 尝试更换为更强大的模型（如gpt-4、deepseek-chat）

### Q: 如何查看调试信息？
A: 在插件中使用 `HostOpenConsole()` 打开调试控制台

## 📝 开发说明

插件基于AngelScript开发，主要函数：

| 函数 | 说明 |
|------|------|
| `GetTitle()` | 返回插件名称 |
| `GetVersion()` | 返回版本号 |
| `GetDesc()` | 返回插件描述 |
| `ServerLogin()` | 处理登录/配置 |
| `GetSrcLanCount()` | 源语言数量 |
| `GetDstLanCount()` | 目标语言数量 |
| `GetSrcLanName(idx)` | 获取源语言名称 |
| `GetDstLanName(idx)` | 获取目标语言名称 |
| `SetSrcLan(idx)` | 设置源语言 |
| `SetDstLan(idx)` | 设置目标语言 |
| `Translate(text)` | **核心翻译函数** |

## 📜 许可证

MIT License - 可自由使用和修改

## 🔗 相关链接

- [PotPlayer官网](https://potplayer.daum.net)
- [AngelScript文档](http://www.angelcode.com/angelscript/)
- [OpenAI API文档](https://platform.openai.com/docs)
- [DeepSeek API文档](https://platform.deepseek.com/api-docs)
