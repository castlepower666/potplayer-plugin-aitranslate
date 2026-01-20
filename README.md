# PotPlayer AI字幕翻译插件

## 📖 简介

这是一套用于PotPlayer的AI字幕实时翻译插件，支持接入主流AI大模型API进行字幕翻译。

**核心特性**：
- 🤖 支持多家AI大模型（OpenAI、DeepSeek、通义千问、Gemini等）
- 📚 上下文感知翻译（保持对话连贯性）
- 🎬 内容类型识别（9种内容类型特定翻译风格）
- 💾 完整翻译缓存（避免重复调用）
- 🔄 自动场景检测（10秒无新字幕自动清空历史）
- ⚙️ 灵活配置（可调整上下文条数0-20）

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

### 方法一：在PotPlayer中配置（推荐）

1. 打开PotPlayer
2. 右键 → 字幕 → 字幕翻译 → 选择"AI大模型翻译"
3. 点击"账户设置"
4. 按以下格式输入配置

**配置格式**：
```
URL|Model|ContextCount|Genre
API Key
```

**参数说明**：
- `URL` - API服务地址（必填）
- `Model` - 模型名称（可选，省略时自动选择）
- `ContextCount` - 上下文条数，0-20（可选，默认5）
- `Genre` - 内容类型（可选，默认general）

**配置示例**：
```
https://api.deepseek.com|deepseek-chat|5|anime
sk-xxxxxxxxxxxxx
```

### 方法二：直接修改插件代码

编辑 `.as` 文件，修改以下变量：

```angelscript
string g_apiKey = "你的API Key";
string g_baseUrl = "https://api.deepseek.com";  // 或其他API地址
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

自动检测、简体中文、繁體中文、English、日本語、한국어、Français、Deutsch、Español、Italiano、Português、Русский、العربية、हिन्दी、ไทย

## 🎬 内容类型（Genre）功能详解

Genre 是一个可选参数，根据内容类型自动调整翻译风格。比如看动漫时用 `anime`，会使用动漫常用术语；看科幻时用 `scifi`，会使用科技专业术语。

### 支持的9种内容类型

#### 1. **anime**（日本动漫）
- **适用**：日本动画、日系漫画改编作品
- **特点**：日系术语（法师、魔法），保持名称一致，恰当翻译日文敬语（-chan、-san、-sama），情感丰富的表达
- **推荐**：`https://api.deepseek.com|deepseek-chat|5|anime`

#### 2. **western-comic**（欧美动画/漫画）⭐ NEW
- **适用**：美国漫画、欧美动画、好莱坞风格内容
- **特点**：西方术语（Superhero、Villain），流行文化风格，直接大气的对话，幽默讽刺
- **推荐**：`https://api.deepseek.com|deepseek-chat|5|western-comic`

#### 3. **scifi**（科幻）
- **适用**：科幻电影、未来题材
- **特点**：科技术语（粒子加速器、量子纠缠），专业表达，技术一致性
- **推荐**：`https://api.deepseek.com|deepseek-chat|8|scifi`（建议用8条上下文）

#### 4. **disney**（迪士尼）
- **适用**：儿童电影、家庭内容
- **特点**：温暖亲切（小姐姐、亲爱的），梦幻氛围，家庭友好
- **推荐**：`https://api.deepseek.com|deepseek-chat|5|disney`

#### 5. **fantasy**（奇幻）
- **适用**：魔幻剧集、冒险故事
- **特点**：史诗感，奇幻术语（魔法、精灵、龙），宏大英勇
- **推荐**：`https://api.deepseek.com|deepseek-chat|5|fantasy`

#### 6. **drama**（剧情）
- **适用**：电视剧、现代故事
- **特点**：自然真实，感情丰富，日常表达，人物关系深度
- **推荐**：`https://api.deepseek.com|deepseek-chat|3|drama`

#### 7. **horror**（恐怖）
- **适用**：恐怖电影、惊悚内容
- **特点**：诡异压抑，紧张气氛，黑暗表达，阴森感
- **推荐**：`https://api.deepseek.com|deepseek-chat|5|horror`

#### 8. **gamedev**（游戏开发教程）
- **适用**：Unity、Unreal Engine 等游戏开发教程
- **特点**：游戏引擎术语精准（Component、Prefab、Blueprint等），编程概念准确，技术术语一致
- **推荐**：`https://api.deepseek.com|deepseek-chat|5|gamedev`
- **示例术语**：Shader（着色器）、Asset（资源）、Rigidbody（刚体）、Collider（碰撞器）、Material（材质）

#### 9. **general**（通用，默认）
- **适用**：不确定的内容
- **特点**：平衡标准翻译，无特殊优化

### 翻译效果对比示例

**原文**：The mage cast a powerful spell to save the day.

| Genre | 翻译结果 | 风格 |
|-------|---------|------|
| anime | 法师施展了强大的魔法来拯救局面。| 日漫术语 |
| western-comic | 魔法师释放了强大的能量来挽救局面。| 欧美漫画风格 |
| scifi | 魔法师释放了强大的能量脉冲来扭转局势。| 科技色彩 |
| disney | 小仙女释放了美妙的魔力来拯救大家。| 温暖梦幻 |
| fantasy | 大法师施放了一个强大的咒语来挽救局面。| 史诗感 |
| drama | 那个法师施展魔法拯救了局面。| 自然真实 |
| horror | 黑暗法师释放了可怕的诅咒魔法...| 诡异压抑 |
| gamedev | （游戏开发教程术语）| 游戏术语 |
| general | 法师施展了强大的法术来挽救局面。| 平衡标准 |

**游戏开发教程例子**：You need to attach a Collider component to enable physics interactions.

| Genre | 翻译结果 |
|-------|---------|
| gamedev | 你需要附加一个 Collider 组件来启用物理交互。|
| general | 你需要附加一个碰撞器组件来启用物理交互。|

### 上下文条数建议

- **0条**：无上下文，最快翻译（可能缺乏连贯性）
- **3-5条**：标准配置，平衡质量和速度（推荐）
- **8-10条**：长对话场景，更好的连贯性（增加API成本）
- **15+条**：超长对话序列（高成本）

### Genre 使用注意事项

- Genre 参数完全可选，不设置时默认为 `general`
- 无效的 Genre 会自动回退到 `general`，不会导致错误
- 添加 Genre 会增加约 5-10% 的 API 成本（因为 Prompt 变长）
- 更改 Genre 无需重启，重新登录新配置即可生效

## ⚠️ 注意事项

1. **网络要求**：需要稳定的网络连接访问API服务
2. **费用**：AI API通常按使用量收费，请注意控制成本
3. **延迟**：由于需要网络请求，翻译会有一定延迟
4. **准确性**：AI翻译质量取决于所选模型，建议使用GPT-4或DeepSeek-chat

## 🔧 常见问题

### Q: 翻译没有反应？
A: 检查API Key是否正确，网络是否通畅

### Q: 翻译速度慢？
A: 
- 减少上下文条数（改为 0-3）
- 尝试使用更快的模型（如gpt-3.5-turbo）
- 尝试使用更近的API节点

### Q: 翻译结果不准确？
A: 
- 尝试更换为更强大的模型（如gpt-4、deepseek-chat）
- 增加上下文条数（改为 5-8）
- 选择更准确的 Genre 类型

### Q: Genre 功能有什么用？
A: Genre 帮助AI理解内容类型，使用更合适的术语和表达方式。例如看动漫时用 `anime`，看科幻时用 `scifi`，看游戏开发教程时用 `gamedev`，翻译质量会更好。

### Q: Genre 拼错了会怎样？
A: 无效的 Genre 会自动回退到 `general`，不会导致错误。

### Q: 如何快速切换 Genre？
A: 重新登录时输入新的 Genre 参数即可，无需重启软件。

### Q: 如何查看调试信息？
A: 在插件中使用 `HostOpenConsole()` 打开调试控制台

## 📊 性能和成本分析

### API 成本影响

**Prompt 长度变化**：
- 基础 Prompt：约 300 字符，50-60 tokens
- + Genre 提示词：额外 200-250 字符，30-40 tokens
- 总计：约 500-550 字符，80-100 tokens

**月度成本估算**（日均 100 条字幕翻译）：
- 仅使用 general：约 150,000 tokens/月
- 使用具体 Genre：约 250,000 tokens/月
- 成本增幅：约 60-70%

### 成本优化建议

- 成本敏感：使用 general 或较少上下文
- 质量优先：选择准确的 Genre + 足量上下文
- 平衡方案：选择 Genre + 中等上下文（5条）

## 📚 技术说明

### 核心架构

**插件特性**：
1. **上下文管理** - 维护最近N条翻译历史，用于AI理解连贯性
2. **完整缓存** - 缓存所有翻译过的字幕，避免重复调用API
3. **场景检测** - 10秒无新字幕自动清空历史（检测场景切换）
4. **Genre提示词** - 根据内容类型动态生成特定翻译指引

### 配置持久化

所有配置会自动保存到PotPlayer本地存储：
- API Key（`AI_Trans_Key`）
- API地址（`AI_Trans_Url`）
- 模型名称（`AI_Trans_Model`）
- 上下文条数（`AI_Trans_History`）
- 内容类型（`AI_Trans_Genre`）

## 🚀 快速开始

### 1分钟快速配置

```bash
# Step 1: 复制插件文件到 PotPlayer
# PotPlayer安装目录\Extension\Subtitle\Translate\SubtitleTranslate - AI.as

# Step 2: 重启 PotPlayer

# Step 3: 在字幕翻译设置中输入
# 配置：https://api.deepseek.com|deepseek-chat|5|anime
# Key：sk-xxxxxxxxxxxxx

# Step 4: 选择字幕，翻译开始！
```

### 选择适合的配置

**快速翻译**：
```
https://api.deepseek.com|deepseek-chat|0
```

**标准配置**：
```
https://api.deepseek.com|deepseek-chat|5
```

**高质量 + 内容特定**：
```
https://api.deepseek.com|deepseek-chat|8|anime
```

**OpenAI 配置**：
```
https://api.openai.com/v1/chat/completions|gpt-3.5-turbo|5|scifi
```

## 📝 开发说明

插件基于AngelScript开发，主要函数：

| 函数 | 说明 |
|------|------|
| `GetTitle()` | 返回插件名称 |
| `GetVersion()` | 返回版本号 |
| `GetDesc()` | 返回插件描述 |
| `ServerLogin()` | 处理登录/配置 |
| `Translate(text)` | 核心翻译函数 |

## 📜 许可证

MIT License - 可自由使用和修改

## 🔗 相关链接

- [PotPlayer官网](https://potplayer.daum.net)
- [AngelScript文档](http://www.angelcode.com/angelscript/)
- [OpenAI API文档](https://platform.openai.com/docs)
- [DeepSeek API文档](https://platform.deepseek.com/api-docs)

---

**最后更新**：2026年1月  
**维护者**：AI 字幕翻译团队  
**状态**：Production Ready ✅
