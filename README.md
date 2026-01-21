# PotPlayer AI字幕翻译插件

> **版本：v1.0.0** | **状态：Official Release** ✅

## 📖 简介

这是一套用于PotPlayer的AI字幕实时翻译插件，支持接入主流AI大模型API进行字幕翻译。

**核心特性**：
- 🤖 支持多家AI大模型（OpenAI、DeepSeek、通义千问、Gemini等）
- 💬 **口语化翻译**（优先自然日常表达，避免平淡生硬）⭐ ENHANCED
  - 强制使用口语粒子（啦/呀/呢/吧/嘛）
  - 平淡检查机制（NO 平淡/boring translations!）
  - 多语言支持（英文提示词适配全球语言）
- 🎬 **8种内容类型特定翻译**（anime、western-comic、scifi、drama、horror、disney、gamedev、general）
- 📚 **智能上下文判断**（自动判断是否需要上下文，避免误导）
- 🔍 **6步质量检查流程**（包括平淡度、一致性、清晰度）⭐ NEW
- 💾 完整翻译缓存（避免重复调用）
- 🔄 自动场景检测（可配置1-60000ms，默认6秒自动清空历史）
- ⚙️ 灵活配置（可调整上下文条数0-20、场景检测阈值）

## 📁 插件文件

| 文件 | 说明 |
|------|------|
| `SubtitleTranslate - AI.as` | 通用版本，支持OpenAI、DeepSeek、通义千问等兼容OpenAI格式的API |

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
URL|Model|ContextCount|Genre|SceneThreshold
API Key
```

**参数说明**：
- `URL` - API服务地址（**必填**）
- `Model` - 模型名称（可选，省略时自动选择）
- `ContextCount` - 上下文条数，0-20（可选，默认5）
- `Genre` - 内容类型（可选，默认general）
- `SceneThreshold` - 场景切换检测时间，1-60000ms（可选，默认6000ms）⭐ NEW

**必填参数**：只有 `URL` 和 `API Key` 是必需的，其他参数省略时使用智能默认值。

**配置示例**：
```
# 标准配置（动漫，5条上下文，6秒场景检测）
https://api.deepseek.com|deepseek-chat|5|anime|6000
sk-xxxxxxxxxxxxx

# 最小配置（仅API地址和Key）
https://api.deepseek.com
sk-xxxxxxxxxxxxx

# 快速翻译（无上下文，3秒场景检测）
https://api.deepseek.com|deepseek-chat|0||3000
sk-xxxxxxxxxxxxx

# 高质量（10条上下文，科幻题材，8秒场景检测）
https://api.deepseek.com|deepseek-chat|10|scifi|8000
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

## 💡 提示词系统改进 ⭐ LATEST

### 多语言英文提示词

所有提示词已转换为英文，确保在任何语言的翻译中都能获得一致的高质量指导。系统不再依赖中文提示词，而是使用**英文提示词框架**，这样可以：

- ✅ 支持多语言翻译目标（中文、日文、韩文、法文等）
- ✅ 避免提示词本身的语言歧义
- ✅ 通过明确的英文指导确保质量一致性

### 6步质量检查流程

翻译引擎现在包含完整的质量检查机制：

1. **情感真实性检查** - 情感与原文是否一致？
2. **一致性验证** - 角色语音、术语是否一致？
3. **清晰度评估** - 表达是否清晰易懂？
4. **平淡度检查** ⭐ NEW - 是否避免了平淡生硬的表达？
5. **文化适配验证** - 是否符合目标语言文化？
6. **最终质量评分** - 综合评估翻译质量

### 口语化粒子强制应用

系统现在明确要求在中文翻译中使用：
- `啦` - 完成性/确定感（搞定啦、来啦）
- `呢` - 疑问/思考（咋整呢、怎么办呢）
- `吧` - 建议/不确定（走吧、这样吧）
- `嘛` - 强调/理所当然（这不是嘛、谁都知道嘛）
- `呀` - 感叹（真的呀、天哪呀）

这些粒子使翻译更具自然感，避免生硬和平淡。

## 🎬 内容类型（Genre）功能详解

Genre 是一个可选参数，根据内容类型自动调整翻译风格。8种内容类型都已用英文提示词重新设计，确保多语言适配一致性。

### 支持的9种内容类型

#### 1. **anime**（日本动漫）
- **适用**：日本动画、日系漫画改编作品
- **特点**：NATURAL DIALOGUE、CHARACTER DIFFERENTIATION、ACTION SCENES with power words
- **关键原则**：角色对话要自然，不同角色有不同的说话风格
- **推荐**：`https://api.deepseek.com|deepseek-chat|5|anime`

#### 2. **western-comic**（欧美动画/漫画）
- **适用**：美国漫画、欧美动画、好莱坞风格内容
- **特点**：HUMOR LANDS（笑点必须好笑）、CASUAL LANGUAGE（粗俗/俚语可用）、ONE-LINERS（简洁有力）
- **关键原则**：笑点落地，讽刺明显，动感十足
- **推荐**：`https://api.deepseek.com|deepseek-chat|5|western-comic`

#### 3. **scifi**（科幻）
- **适用**：科幻电影、未来题材
- **特点**：CONSISTENT JARGON（术语一致）、FUTURISTIC FEEL（未来感）、SIMPLIFY COMPLEX（简化复杂概念）
- **关键原则**：术语必须一致，解释技术的用途和意义
- **推荐**：`https://api.deepseek.com|deepseek-chat|8|scifi`（建议用8条上下文）

#### 4. **disney**（迪士尼）
- **适用**：儿童电影、家庭内容
- **特点**：WARMTH IS PRIMARY（亲切感）、GENTLE WORD CHOICE（包容感）、LAUGHTER IS KINDNESS（善良的幽默）
- **关键原则**：温暖、积极、充满希望，不是被教育而是被吸引
- **推荐**：`https://api.deepseek.com|deepseek-chat|5|disney`

#### 5. **fantasy**（奇幻）⭐ ENHANCED
- **适用**：魔幻剧集、冒险故事
- **特点**：史诗感，奇幻术语（魔法、精灵、龙），宏大英勇
- **关键原则**：保留世界观一致性，术语翻译统一
- **推荐**：`https://api.deepseek.com|deepseek-chat|5|fantasy`

#### 6. **drama**（剧情）
- **适用**：电视剧、现代故事
- **特点**：DIALOGUE AUTHENTICITY（真实对白）、SUBTEXT IS KEY（潜台词）、COLLOQUIAL EXTREME（极度口语）
- **关键原则**：自然、细腻、有感情，对话要真实可信
- **推荐**：`https://api.deepseek.com|deepseek-chat|3|drama`

#### 7. **horror**（恐怖）
- **适用**：恐怖电影、惊悚内容
- **特点**：ATMOSPHERE OVER PLOT（气氛比情节重要）、SHORT SENTENCES（短句制造紧张）、COLD THREATS（冷酷威胁）
- **关键原则**：压抑、诡异、很有张力，不靠吓而靠造势
- **推荐**：`https://api.deepseek.com|deepseek-chat|5|horror`

#### 8. **gamedev**（游戏开发教程）
- **适用**：Unity、Unreal Engine 等游戏开发教程
- **特点**：TERMINOLOGY PRECISION（术语精准）、PROGRESSION（循序渐进）、HONEST BUT SUPPORTIVE（坦诚但鼓励）
- **关键原则**：清楚、鼓励、实用，像朋友在教你代码
- **推荐**：`https://api.deepseek.com|deepseek-chat|5|gamedev`

#### 9. **general**（通用，默认）
- **适用**：不确定的内容
- **特点**：DIALOGUE FIRST（优先自然对白）、MEANING NOT WORDS（意思而非字对字）、CHARACTER VOICE（保持人物个性）
- **关键原则**：自然、真实、好听，如果听起来好就是对的
- **推荐**：`https://api.deepseek.com|deepseek-chat|5|general`

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

### 场景切换阈值建议 ⭐ NEW

| SceneThreshold | 适用场景 | 特点 |
|---|---|---|
| 1000-2000ms | 快速切换类（动作片、竞技游戏教程） | 反应灵敏，快速清空历史 |
| 3000-6000ms | 一般电影/电视剧（**默认6000**） | 平衡反应和上下文保留 |
| 8000-12000ms | 对话密集剧（悬疑剧、法庭剧） | 保留更长对话上下文 |
| 15000-30000ms | 长剧情片、教学内容 | 维持超长对话一致性 |
| 40000-60000ms | 长纪录片、讲座 | 极长上下文保留 |

**建议配置组合**：
- 快速切换内容：`|deepseek-chat|0||2000` (无上下文，2秒检测)
- 一般看剧：`|deepseek-chat|5||6000` (5条上下文，6秒检测)
- 高质量剧情：`|deepseek-chat|8|drama|10000` (8条上下文，10秒检测)
- 教学视频：`|deepseek-chat|5|gamedev|15000` (5条上下文，15秒检测)

### Genre 使用注意事项

- Genre 参数完全可选，不设置时默认为 `general`
- 无效的 Genre 会自动回退到 `general`，不会导致错误
- 添加 Genre 会增加约 5-10% 的 API 成本（因为 Prompt 变长）
- 更改 Genre 无需重启，重新登录新配置即可生效

## 💬 口语化翻译原则 ⭐ NEW

插件优先使用自然、日常的中文表达，而不是生硬的文言文。

### 核心原则

1. **日常自然** - 优先使用常用词汇，避免晦涩古文
   - ❌ 不：「此人乃一智者也」
   - ✅ 是：「这个人真聪明」

2. **避免文言** - 摒弃之乎者也，用现代口语
   - ❌ 不：「汝何故如斯」
   - ✅ 是：「你怎么这样啊」

3. **保留人物性格** - 翻译要体现角色个性和口吻
   - 原文：\"I ain't got no time for this\" (粗鲁角色)
   - ✅ 是：「老子没空搭理你这破事」(保留粗鲁风格)

4. **允许不完整句子** - 真实对话中存在省略和断句
   - ✅ 接受：「不行...太危险了」（不必完全成句）

5. **语调和表情** - 保持原文的语气和情感
   - 原文：\"Oh come on!\" (轻松玩笑)
   - ✅ 是：「拜托啦」(轻松调侃)

### 场景应用示例

**日常对话**：
```
原文：Hey, what's up?
✅ 翻译：嘿，怎么样？
❌ 反例：喂，汝今日如何？
```

**强调语气**：
```
原文：I literally died laughing!
✅ 翻译：我笑死了！
❌ 反例：我奋笔疾书地死亡而笑也。
```

**俏皮表达**：
```
原文：That's so fetch!
✅ 翻译：超级带劲儿！
❌ 反例：该事物乃卓越不凡。
```

## 🎭 俚语与成语处理 ⭐ NEW

### 俚语识别系统

插件在翻译前进行俚语预检查，包含以下红旗警告：

**动物相关成语**：
- \"go ape\" → 发疯
- \"rat out\" → 背叛
- \"dog days\" → 难熬的日子
- \"bug out\" → 惊吓

**身体部位成语**：
- \"cost an arm and a leg\" → 非常昂贵
- \"break a leg\" → 祝演出顺利
- \"lose your head\" → 失控
- \"get cold feet\" → 临阵退缩

**天气和自然现象**：
- \"raining cats and dogs\" → 下倾盆大雨
- \"under the weather\" → 身体不适
- \"weather the storm\" → 度过难关

**\"like\" 短语**：
- \"like a fish out of water\" → 如鱼离水
- \"like clockwork\" → 准时如钟
- \"like there's no tomorrow\" → 尽情享受

### 翻译原则

1. **保留精神** - 传达原成语的精神含义而非字面意思
2. **适应文化** - 用中文成语或比喻替代，而非生硬直译
3. **维持语调** - 幽默、俏皮或严肃的语气必须保留

### 场景示例

**电影对白**：
```
原文：I'm not gonna spill the beans, so cool your jets.
预检查：识别到\"spill the beans\"（泄露秘密）和\"cool your jets\"（别急）
✅ 翻译：我不会泄露秘密的，别急。
```

**漫画对话**：
```
原文：When life gives you lemons, make lemonade!
预检查：识别到常见生活俚语
✅ 翻译：生活给你酸柠檬，就把它做成柠檬茶！
```

## 🌍 多语言文化适配 ⭐ NEW

系统根据源语言自动调整文化背景，确保翻译符合该文化的表达习惯。

### 英文（English）- 好莱坞与美英文化

**特点**：
- 美式文化、好莱坞电影词汇
- 英式和美式英语表达差异
- 讽刺和黑色幽默常见

**示例**：
```
原文：This is totally mental! (英式)
✅ 翻译：这太疯狂了！
```

**常见习语**：
- \"fancy\" → 喜欢/高级（英式）vs \"cool\" → 酷（美式）
- \"knock someone up\" → 敲门（英式）vs 使怀孕（美式）

### 日文（日本語）- 动漫与敬语文化

**特点**：
- 动漫常用术语（魔法、法师、幻兽）
- 敬语系统（-san, -chan, -sama, -sensei）
- 参考笑料和文化梗（宫崎骏、龙珠等）

**示例**：
```
原文：これはすごい！(日文)
✅ 翻译：这太厉害了！(保留日本动漫的热情感)
原文：田中さん (带敬语)
✅ 翻译：田中先生 (恰当翻译敬语)
```

### 韩文（한국어）- K文化与阶级制度

**特点**：
- K-pop、K-drama 流行语
- 韩文中的敬语和阶级关系
- \"应援\"（追星应援）、\"偶像\"等文化概念

**示例**：
```
原文：화이팅! (加油)
✅ 翻译：加油！(保留韩文的战斗精神)
```

### 法文（Français）- 浪漫与诗意

**特点**：
- 浪漫优雅的表达
- 诗意和哲学气质
- 法国电影和文学风格

**示例**：
```
原文：C'est magnifique!
✅ 翻译：这太精妙绝伦了！(诗意表达)
```

## 🔍 上下文智能判断系统 ⭐ NEW

### 工作原理

插件会智能判断是否需要使用上下文：

1. **判断场景一致性** - 检查是否在同一场景/对话
2. **评估上下文相关性** - 判断历史字幕是否有帮助
3. **条件性使用** - 相关时使用历史，无关时独立翻译

### 典型场景

**✅ 应该使用上下文**：
```
字幕1：\"These ancient ruins hold the secret.\"
字幕2：\"Let's explore them.\"
↓
上下文有助于理解\"them\"指什么，翻译时需要用上前文
```

**❌ 不应该使用上下文**：
```
电影1：\"The mission is complete.\"  (第一部电影结尾)
[场景切换20分钟]
电影2：\"Let's start the new mission.\"
↓
上下文无关，应该独立翻译，不受前面的影响
```

### 配置建议

- **连续对话** → 使用 5-8 条上下文
- **独立场景** → 使用 0-2 条上下文
- **文艺作品** → 使用 3-5 条上下文（保持节奏）

## 🔍 AI自检机制 ⭐ NEW

### 自检项目

翻译完成后，AI会在返回结果前进行以下检查：

1. **语法检查** - 确保中文表达正确
   - 成分残缺：主语、谓语、宾语完整
   - 搭配恰当：词语搭配自然流畅
   - 标点正确：逗号、句号、问号使用恰当

2. **逻辑检查** - 确保意思准确
   - 因果关系正确
   - 顺序逻辑合理
   - 不产生矛盾含义

3. **一致性检查** - 确保风格和用词统一
   - 同一概念用词一致
   - 人物性格表达一致
   - 术语选择一致

4. **拼写与错别字检查**
   - 没有生僻错别字
   - 常见词语正确
   - 专有名词准确

5. **格式检查**
   - 只返回翻译文本，不含解释
   - 不含多余换行
   - 符合字幕显示格式

### 示例

```
原文：\"I can't even begin to express how much I love you.\"

第一遍生成：\"我甚至无法开始表达我有多爱你。\"
↓ 自检发现：\"甚至无法开始\"显得生硬
自纠正为：\"我真的无法言喻有多爱你。\"
↓ 再次检查：语法✓ 逻辑✓ 一致✓
最终返回：\"我真的无法言喻有多爱你。\"
```

## ⚠️ 注意事项

1. **网络要求**：需要稳定的网络连接访问API服务
2. **费用**：AI API通常按使用量收费，请注意控制成本
3. **延迟**：由于需要网络请求，翻译会有一定延迟
4. **准确性**：AI翻译质量取决于所选模型，建议使用GPT-4或DeepSeek-chat
5. **场景检测**：自定义SceneThreshold时，1000ms太快易误触，30000ms+太慢可能不清缓存

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

### Q: 什么是 SceneThreshold 场景切换检测？ ⭐ NEW
A: SceneThreshold 是指多久没有新字幕时自动清空翻译历史。
- 1000ms (1秒) - 反应灵敏，快速场景切换
- 6000ms (6秒) - 默认值，适合大多数内容
- 10000ms (10秒) - 慢速场景，避免过早清除上下文
- 30000ms (30秒) - 长剧情片，保持更长的对话记录

### Q: 口语化翻译会影响专业术语吗？ ⭐ NEW
A: 不会。口语化翻译优先自然日常表达，但在科幻、医学、技术等专业领域仍会使用准确的专业术语。例如游戏开发教程中，Collider、Prefab 等术语会保留，同时用日常语言说明其含义。

### Q: 俚语识别有遗漏怎么办？ ⭐ NEW
A: 内置识别 15+ 常见英文俚语和成语。如果有遗漏，AI 会根据上下文和文化背景推断含义。建议在 Genre 中选择对应的文化背景（anime/western-comic/scifi等）以获得更准确的俚语翻译。

### Q: 上下文智能判断会不会判断错误？ ⭐ NEW
A: AI 会基于以下因素判断：对话连贯性、时间间隔（通过 SceneThreshold 检测）、场景和角色一致性。虽然极少数情况可能判断错误，但可以通过调整 ContextCount 来手动控制（0 = 完全不用上下文）。

### Q: 是否支持自定义俚语库？ ⭐ NEW
A: 目前暂不支持直接自定义俚语库，但可以通过提高 ContextCount 和选择合适的 Genre 来改善俚语翻译。未来可能添加自定义俚语库功能。

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
3. **场景检测** - 6秒无新字幕自动清空历史（检测场景切换）
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
**维护者**：castlepower666  
**协作**：GitHub Copilot  
**状态**：Production Ready ✅

---

## 🎯 完整功能矩阵 ⭐ NEW

| 功能 | 状态 | 版本 | 说明 |
|------|------|------|------|
| 基础翻译 | ✅ | 1.0+ | OpenAI 兼容 API |
| 多模型支持 | ✅ | 1.0+ | GPT/DeepSeek/通义千问/Gemini |
| 上下文感知 | ✅ | 1.0+ | 0-20 条历史记录 |
| 场景检测 | ✅ | 1.0+ | 可配置 1-60000ms |
| Genre 分类 | ✅ | 1.0+ | 9 种内容类型 |
| 完整缓存 | ✅ | 1.0+ | 避免重复调用 |
| **口语化翻译** | ✅ | 2.0+ | 日常自然表达 ⭐ NEW |
| **俚语识别** | ✅ | 2.0+ | 15+ 成语库 + 预检查 ⭐ NEW |
| **文化适配** | ✅ | 2.0+ | 4种语言文化背景 ⭐ NEW |
| **上下文智能** | ✅ | 2.0+ | 自动判断相关性 ⭐ NEW |
| **AI自检** | ✅ | 2.0+ | 5项质量检查 ⭐ NEW |

---

## 📈 版本历史

### v1.0.0 - Official Release ⭐
**当前版本（生产环境推荐）**
- ✅ 实时AI字幕翻译（支持OpenAI、DeepSeek、通义千问、Gemini）
- ✅ 8种内容类型特定翻译模式
- ✅ 口语化翻译引擎（避免平淡生硬）
- ✅ 智能上下文管理与场景检测
- ✅ 完整翻译缓存机制
- ✅ 6步质量检查流程
- ✅ 英文提示词系统（多语言适配）
- ✅ 自动平淡度检查机制

### v0.9.0 - Beta
**测试版（不再维护）**
- 基础翻译功能
- 多模型支持
- 上下文感知（初级）
- 9 种 Genre 分类
- 完整缓存机制
