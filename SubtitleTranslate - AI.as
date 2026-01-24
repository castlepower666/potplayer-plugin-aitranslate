/*
	PotPlayer 字幕实时翻译插件 - AI大模型版本
	支持: OpenAI, DeepSeek, 通义千问等兼容API
*/

// string GetTitle()                     -> get title for UI
// string GetVersion                     -> get version for manage
// string GetDesc()                      -> get detail information
// string GetLoginTitle()                -> get title for login dialog
// string GetLoginDesc()                 -> get desc for login dialog
// string GetUserText()                  -> get user text for login dialog
// string GetPasswordText()              -> get password text for login dialog
// string ServerLogin(string User, string Pass) -> login
// string ServerLogout()                 -> logout
// array<string> GetSrcLangs()           -> get source language
// array<string> GetDstLangs()           -> get target language
// string Translate(string Text, string &in SrcLang, string &in DstLang) -> do translate

string GetTitle()
{
	return "{$CP936=AI大模型翻译}AI Translate";
}

string GetVersion()
{
	return "1.0";
}

string GetDesc()
{
	return "{$CP936=使用AI大模型进行字幕实时翻译(支持DeepSeek/OpenAI/通义千问/Gemini等)}Translate subtitles using AI (DeepSeek/OpenAI/Qwen/Gemini...)";
}

string GetLoginTitle()
{
	return "{$CP936=API设置}API Settings";
}

string GetLoginDesc()
{
		return "{$CP936=配置格式: URL|Model|Context|Genre|SceneThreshold|CustomPrompt\n"
			+ "示例: https://api.deepseek.com|deepseek-chat|5|anime|6000|你是一个翻译助手...\n\n"
			+ "Genre选项: anime(日漫) western-comic(美漫) scifi fantasy drama horror disney gamedev general\n"
			+ "Context: 0(无上下文) 3-5(推荐) 10+(强一致性)\n"
			+ "SceneThreshold: 场景变更阈值(毫秒, 默认6000)\n"
			+ "CustomPrompt: 自定义提示词(可选)，会追加到系统提示词末尾\n"
			+ "默认: Model=deepseek-chat, Context=5, Genre=general, SceneThreshold=6000, CustomPrompt=无"
			+ "}Format: URL|Model|Context|Genre|SceneThreshold|CustomPrompt\n"
			+ "Example: https://api.deepseek.com|deepseek-chat|5|anime|6000|You are a translator...\n\n"
			+ "Genre: anime western-comic scifi fantasy drama horror disney gamedev general\n"
			+ "Context: 0(no context) 3-5(recommended) 10+(strong consistency)\n"
			+ "SceneThreshold: Scene change threshold in milliseconds (default: 6000)\n"
			+ "CustomPrompt: Optional custom prompt, appended to system prompt\n"
			+ "Default: deepseek-chat, 5, general, 6000, CustomPrompt=none";
}
string GetUserText()
{
	return "{$CP936=API地址|模型|上下文:}URL|Model|Context:";
}

string GetPasswordText()
{
	return "API Key:";
}

// ============ 全局配置 ============
string g_apiKey = "";
string g_baseUrl = "";
string g_model = "deepseek-chat";
string g_genre = "general";
string g_customPrompt = "";  // 用户自定义提示词
uint g_sceneChangeThreshold = 6000;  // 毫秒，场景切换阈值

// ============ 内容类型相关函数 ============
string GetGenrePromptSuffix(string genre)
{
	if (genre == "anime")
	{
		return "\nSpecial Notes for Japanese Anime:\n"
			+ "- Use appropriate Chinese terms for anime-specific concepts (e.g., 法师 for mage, 魔法 for magic)\n"
			+ "- Maintain consistent naming for character titles and abilities\n"
			+ "- Preserve Japanese honorifics appropriately translated (如：-chan, -san, -sama)\n"
			+ "- Use natural expressions common in Chinese anime translations\n"
			+ "- Capture the emotional and dramatic style typical of Japanese animation\n";
	}
	else if (genre == "western-comic")
	{
		return "\nSpecial Notes for Western Comics/Animation:\n"
			+ "- Use dynamic and straightforward English-origin terminology (e.g., Superhero超级英雄, Villain恶棍)\n"
			+ "- Maintain consistency with Western pop culture references and expressions\n"
			+ "- Preserve bold, direct, and action-oriented dialogue style\n"
			+ "- Use energetic and impactful expressions common in Western animation\n"
			+ "- Focus on humor, sarcasm, and witty remarks typical of Western storytelling\n";
	}
	else if (genre == "scifi")
	{
		return "\nSpecial Notes for Science Fiction:\n"
			+ "- Use precise technical terminology (e.g., 粒子加速器 for particle accelerator)\n"
			+ "- Maintain consistency in scientific terms and concepts\n"
			+ "- Preserve futuristic and technical jargon appropriately\n"
			+ "- Use professional scientific language\n";
	}
	else if (genre == "disney")
	{
		return "\nSpecial Notes for Disney/Children's Content:\n"
			+ "- Use warm, friendly, and whimsical language\n"
			+ "- Make expressions more endearing (e.g., 小姐姐, 亲爱的)\n"
			+ "- Maintain magical and fantastical tone\n"
			+ "- Use family-friendly expressions\n";
	}
	else if (genre == "fantasy")
	{
		return "\nSpecial Notes for Fantasy:\n"
			+ "- Use epic and mystical language\n"
			+ "- Maintain consistency in fantasy world terminology (魔法, 精灵, 龙等)\n"
			+ "- Preserve grand and heroic tone\n"
			+ "- Create immersive fantasy atmosphere\n";
	}
	else if (genre == "drama")
	{
		return "\nSpecial Notes for Drama:\n"
			+ "- Use natural, realistic, and emotional language\n"
			+ "- Capture subtle emotions and nuances\n"
			+ "- Maintain authentic dialogue feel\n"
			+ "- Preserve human relationships and emotional depth\n";
	}
	else if (genre == "horror")
	{
		return "\nSpecial Notes for Horror:\n"
			+ "- Use ominous, atmospheric, and unsettling language\n"
			+ "- Create tension and suspense through word choice\n"
			+ "- Maintain eerie and creepy atmosphere\n"
			+ "- Use dark and foreboding expressions\n";
	}
	else if (genre == "gamedev")
	{
		return "\nSpecial Notes for Game Development Tutorials:\n"
			+ "- Use precise game engine terminology (Unity: Component, Prefab, Scene; Unreal: Actor, Blueprint, Pawn)\n"
			+ "- Maintain consistency in technical concepts (Shader着色器, Asset资源, Animation动画, Physics物理等)\n"
			+ "- Keep programming terms accurate (Variable变量, Function函数, Loop循环, Class类等)\n"
			+ "- Preserve technical accuracy for game development concepts (Rigidbody刚体, Collider碰撞器, Transform变换, Material材质等)\n"
			+ "- Use professional, precise Chinese terminology for game development\n";
	}
	
	return "";  // general 类型不添加额外提示
}

// 内容类型：anime, scifi, disney, fantasy, drama, horror, gamedev, general
string UserAgent = "PotPlayer/1.0";

// ============ 上下文历史记录 ============
int g_maxHistory = 5;  // 用于AI上下文的条数
array<string> g_allSource;  // 全量原文缓存
array<string> g_allTarget;  // 全量译文缓存
string g_lastDstLang = "";  // 上次目标语言，语言切换时清空历史
int g_lastIndex = -1;  // 上次访问的缓存索引，用于检测快进/后退
array<string> g_contextSource;  // 当前连续上下文原文
array<string> g_contextTarget;  // 当前连续上下文译文
uint g_lastTranslateTime = 0;  // 上次翻译时间，用于检测场景切换

string ServerLogin(string User, string Pass)
{
	// User = API URL|Model|ContextCount|Genre, Pass = API Key
	g_apiKey = Pass;
	
	// ===== 验证必不可少的参数 =====
	// 必须有API Key
	if (Pass.length() == 0)
	{
		return "fail|{$CP936=错误: API Key不能为空}Error: API Key is required";
	}
	
	// 必须有URL
	if (User.length() == 0)
	{
		return "fail|{$CP936=错误: URL不能为空}Error: URL is required";
	}
	
	// 分割字符串
	array<string> parts = User.split("|");
	
	// 验证URL
	if (parts.length() < 1 || parts[0].length() == 0)
	{
		return "fail|{$CP936=错误: URL不能为空}Error: URL is required";
	}
	g_baseUrl = parts[0];
	
	// ===== 可选参数，有错才提示 =====
	
	// 解析Model（可选，有自动检测）
	if (parts.length() >= 2 && parts[1].length() > 0)
	{
		g_model = parts[1];
	}
	else
	{
		// 根据URL自动选择默认模型
		if (g_baseUrl.findFirst("deepseek") >= 0)
			g_model = "deepseek-chat";
		else if (g_baseUrl.findFirst("openai") >= 0)
			g_model = "gpt-3.5-turbo";
		else if (g_baseUrl.findFirst("dashscope") >= 0 || g_baseUrl.findFirst("aliyun") >= 0)
			g_model = "qwen-turbo";
		else if (g_baseUrl.findFirst("googleapis") >= 0 || g_baseUrl.findFirst("gemini") >= 0)
			g_model = "gemini-pro";
		else
			g_model = "gpt-3.5-turbo";
	}
	
	// 解析ContextCount（可选，有值时才验证）
	g_maxHistory = 5;  // 默认5条
	if (parts.length() >= 3 && parts[2].length() > 0)
	{
		int count = parseInt(parts[2]);
		if (count >= 0 && count <= 20)  // 限制范围 0-20
			g_maxHistory = count;
		else
		{
			// 用户明确输入了无效值，才提示
			return "fail|{$CP936=错误: Context必须是0-20之间的数字}Error: Context must be 0-20";
		}
	}
	
	// 解析Genre（可选，有值时才验证）
	g_genre = "general";  // 默认为 general
	if (parts.length() >= 4 && parts[3].length() > 0)
	{
		string genreInput = parts[3];
		// 验证 genre 是否有效
		if (genreInput == "anime" || genreInput == "western-comic" || genreInput == "scifi" || 
		    genreInput == "disney" || genreInput == "fantasy" || genreInput == "drama" || 
		    genreInput == "horror" || genreInput == "gamedev" || genreInput == "general")
		{
			g_genre = genreInput;
		}
		else
		{
			// 用户明确输入了无效值，才提示
			return "fail|{$CP936=错误: Genre无效. 有效值: anime|western-comic|scifi|disney|fantasy|drama|horror|gamedev|general}Error: Invalid Genre";
		}
	}
	
	// 解析SceneThreshold（可选，有值时才验证）
	g_sceneChangeThreshold = 6000;  // 默认6000毫秒
	if (parts.length() >= 5 && parts[4].length() > 0)
	{
		int threshold = parseInt(parts[4]);
		if (threshold > 0 && threshold <= 60000)  // 允许1毫秒到60秒
			g_sceneChangeThreshold = uint(threshold);
		else
		{
			// 用户明确输入了无效值，才提示
			return "fail|{$CP936=错误: SceneThreshold必须是1-60000毫秒之间的数字}Error: SceneThreshold must be 1-60000 milliseconds";
		}
	}
	
	// 解析CustomPrompt（可选，有值时才读取）
	g_customPrompt = "";  // 默认无自定义提示词
	if (parts.length() >= 6 && parts[5].length() > 0)
	{
		g_customPrompt = parts[5];
	}
	
	// 去除末尾斜杠
	if (g_baseUrl.Right(1) == "/") g_baseUrl = g_baseUrl.Left(g_baseUrl.length() - 1);
	
	// 保存配置
	HostSaveString("AI_Trans_Key", g_apiKey);
	HostSaveString("AI_Trans_Url", g_baseUrl);
	HostSaveString("AI_Trans_Model", g_model);
	HostSaveString("AI_Trans_History", "" + g_maxHistory);
	HostSaveString("AI_Trans_Genre", g_genre);
	HostSaveString("AI_Trans_SceneThreshold", "" + g_sceneChangeThreshold);
	HostSaveString("AI_Trans_CustomPrompt", g_customPrompt);
	
	// 打印调试信息到控制台
	HostPrintUTF8("=== AI Translator Config Loaded ===\n");
	HostPrintUTF8("URL: " + g_baseUrl + "\n");
	HostPrintUTF8("Model: " + g_model + "\n");
	HostPrintUTF8("Context: " + g_maxHistory + "\n");
	HostPrintUTF8("Genre: " + g_genre + "\n");
	HostPrintUTF8("SceneThreshold: " + g_sceneChangeThreshold + "ms\n");
	HostPrintUTF8("CustomPrompt: " + (g_customPrompt.length() > 0 ? g_customPrompt : "(none)") + "\n");
	
	return "200 ok|{$CP936=配置成功! Model:" + g_model + " Context:" + g_maxHistory + " Genre:" + g_genre + " Threshold:" + g_sceneChangeThreshold + "ms" + (g_customPrompt.length() > 0 ? " CustomPrompt:已设置" : "") + "}OK! Model:" + g_model + " Context:" + g_maxHistory + " Genre:" + g_genre + " Threshold:" + g_sceneChangeThreshold + "ms" + (g_customPrompt.length() > 0 ? " CustomPrompt:set" : "");
}

void ServerLogout()
{
	g_apiKey = "";
	g_customPrompt = "";
	ClearHistory();
}

// ============ 历史记录管理 ============
void ClearHistory()
{
	g_allSource.resize(0);
	g_allTarget.resize(0);
	g_contextSource.resize(0);
	g_contextTarget.resize(0);
	g_lastIndex = -1;
}

// 清空当前上下文（快进时调用）
void ClearContext()
{
	g_contextSource.resize(0);
	g_contextTarget.resize(0);
}

// 在缓存中查找文本，返回索引，未找到返回-1
int FindInCache(string text)
{
	for (uint i = 0; i < g_allSource.length(); i++)
	{
		if (g_allSource[i] == text) return int(i);
	}
	return -1;
}

// 添加到全量缓存
void AddToCache(string source, string target)
{
	if (FindInCache(source) >= 0) return;
	g_allSource.insertLast(source);
	g_allTarget.insertLast(target);
}

// 添加到当前上下文
void AddToContext(string source, string target)
{
	g_contextSource.insertLast(source);
	g_contextTarget.insertLast(target);
	
	// 保持上下文在限制范围内
	while (g_contextSource.length() > uint(g_maxHistory))
	{
		g_contextSource.removeAt(0);
		g_contextTarget.removeAt(0);
	}
}

// 从缓存中构建上下文（后退时使用，从指定位置向前取）
void BuildContextFromCache(int currentIndex)
{
	ClearContext();
	int startIdx = currentIndex - g_maxHistory;
	if (startIdx < 0) startIdx = 0;
	
	for (int i = startIdx; i < currentIndex; i++)
	{
		g_contextSource.insertLast(g_allSource[i]);
		g_contextTarget.insertLast(g_allTarget[i]);
	}
}

// 构建上下文消息JSON
string BuildContextMessages()
{
	string context = "";
	for (uint i = 0; i < g_contextSource.length(); i++)
	{
		context += "{\"role\":\"user\",\"content\":\"" + JsonEscape(g_contextSource[i]) + "\"},";
		context += "{\"role\":\"assistant\",\"content\":\"" + JsonEscape(g_contextTarget[i]) + "\"},";
	}
	return context;
}

// ============ 语言列表 ============
array<string> LangTable = 
{
	"en",
	"zh-CN",
	"zh-TW", 
	"ja",
	"ko",
	"fr",
	"de",
	"es",
	"ru",
	"pt",
	"it",
	"ar",
	"th",
	"vi"
};

array<string> LangNameTable = 
{
	"English",
	"Simplified Chinese",
	"Traditional Chinese",
	"Japanese",
	"Korean",
	"French",
	"German",
	"Spanish",
	"Russian",
	"Portuguese",
	"Italian",
	"Arabic",
	"Thai",
	"Vietnamese"
};

array<string> GetSrcLangs()
{
	array<string> ret = LangTable;
	ret.insertAt(0, "");  // empty = auto detect
	return ret;
}

array<string> GetDstLangs()
{
	array<string> ret = LangTable;
	return ret;
}

// ============ JSON处理 ============
string JsonEscape(string s)
{
	s.replace("\\", "\\\\");
	s.replace("\"", "\\\"");
	s.replace("\n", "\\n");
	s.replace("\r", "\\r");
	s.replace("\t", "\\t");
	return s;
}

string GetLangName(string code)
{
	for (uint i = 0; i < LangTable.length(); i++)
	{
		if (LangTable[i] == code) return LangNameTable[i];
	}
	if (code == "zh-CN") return "Simplified Chinese";
	if (code == "zh-TW") return "Traditional Chinese";
	return code;
}

// ============ 增强的提示词生成函数 ============
string BuildEnhancedPrompt(string Text, string &in SrcLang, string &in DstLang, int contextLen)
{
	string dstLangName = GetLangName(DstLang);
	string srcLangName = "";
	if (SrcLang.length() > 0) srcLangName = GetLangName(SrcLang);
	
	string prompt = "You are a professional subtitle translator specializing in natural dialogue.\n\n";
	
	// === 口语化第一原则 ===
	prompt += "=== COLLOQUIAL SPEECH FIRST (Most Critical) ===\n";
	prompt += "FORGET formal Chinese. FORGET textbook language.\n";
	prompt += "Think: How would a real person SAY this while chatting with friends?\n";
	prompt += "Use: Casual particles (啊、呢、吧、嘛、呀、哈、啦、嗯), contractions, natural flow\n";
	prompt += "Avoid: 我认为、被动句、成语堆积、书面语、学究式表达\n";
	prompt += "Examples:\n";
	prompt += "  ✗ Bad: \"我要去往那个地方\" (formal)\n";
	prompt += "  ✓ Good: \"我要去那儿\" (natural)\n";
	prompt += "  ✓ Better: \"我得去那儿一趟\" (colloquial)\n";
	prompt += "  ✓ Best: \"我得过去一下\" (very natural)\n";
	prompt += "Special Particles:\n";
	prompt += "  啦: Completion/obviousness (\"搞定啦\"、\"来啦\")\n";
	prompt += "  呢: Questioning/wondering (\"咋整呢\"、\"怎么办呢\")\n";
	prompt += "  吧: Suggestion/uncertainty (\"走吧\"、\"这样吧\")\n";
	prompt += "  嘛: Emphasis/obviousness (\"这不是嘛\"、\"谁都知道嘛\")\n";
	prompt += "  呀: Exclamation (\"真的呀\"、\"天哪呀\")\n\n";
	
	// === 核心指导 ===
	prompt += "=== CORE MANDATE ===\n";
	prompt += "Translate subtitles as native " + dstLangName + " speakers would naturally SAY them while watching.\n";
	prompt += "Priority: Natural speech > Dictionary meaning > Literal words\n";
	prompt += "Style: Colloquial, conversational, emotionally authentic, NOT 平淡/boring\n";
	prompt += "Output: TRANSLATION ONLY - no explanations, no commentary\n\n";
	
	// === 字幕约束 ===
	prompt += "=== SUBTITLE CONSTRAINTS ===\n";
	prompt += "• Conciseness: Subtitles are READ while watching, not studied\n";
	prompt += "• Pacing: Match pace of original dialogue\n";
	prompt += "• Authenticity: Preserve tone, emotion, speaker personality\n";
	prompt += "• Clarity: Every word must earn its place\n";
	prompt += "• Vividness: Make it interesting, not boring (NO 平淡 translations!)\n\n";
	
	// === 翻译决策树 ===
	prompt += "=== TRANSLATION DECISION TREE ===\n";
	prompt += "STEP 1 - Literal Check: Can word-for-word be natural?\n";
	prompt += "  → YES: Use literal (most direct)\n";
	prompt += "  → NO: Go to Step 2\n\n";
	
	prompt += "STEP 2 - Idiom Detection: Phrases with idioms/slang/culture?\n";
	prompt += "  SIGNALS:\n";
	prompt += "  🔴 STRONG (animals, body parts, weather) = Definitely idiom\n";
	prompt += "  🟡 MEDIUM (doesn't make literal sense) = Likely idiom  \n";
	prompt += "  🟢 WEAK (general metaphor) = Might be literal\n";
	prompt += "  → Detected: Go to Step 3\n";
	prompt += "  → No signal: Use literal translation\n\n";
	
	prompt += "STEP 3 - Idiom Translation: Render MEANING not WORDS\n";
	prompt += "  Ask yourself: What is speaker REALLY saying?\n";
	prompt += "  Find equivalent that conveys same emotion/effect\n\n";
	
	prompt += "STEP 4 - Sanity Check: Would native speaker say this?\n";
	prompt += "  → NO: Adjust until natural\n";
	prompt += "  → YES: Continue\n\n";
	
	prompt += "STEP 5 - Consistency: Match character voice + previous terms?\n";
	prompt += "  → Same character = same speech style\n";
	prompt += "  → Same concept = same term\n\n";
	
	prompt += "STEP 6 - Vividness Check: Is it 平淡 (boring/dull)?\n";
	prompt += "  ❌ BORING SIGNS: 没有感情、生硬、教科书式、字对字翻\n";
	prompt += "  ✅ VIVID SIGNS: 有语气、自然顺畅、有人味、会说人话\n";
	prompt += "  → Too plain: Re-translate with more character/emotion\n";
	prompt += "  → Good: Accept\n\n";
	
	// === 语言特定指导 ===
	if (SrcLang == "en")
	{
		prompt += "=== ENGLISH IDIOM MASTERY ===\n";
		prompt += "ANIMALS (Always non-literal):\n";
		prompt += "  'break a leg' → 祝你好运 | 'wolf down' → 狼吞虎咽\n";
		prompt += "  'fish out of water' → 格格不入 | 'let cat out of bag' → 泄露秘密\n\n";
		
		prompt += "BODY PARTS (Always non-literal):\n";
		prompt += "  'blow your mind' → 震撼 | 'break your neck' → 拼命\n";
		prompt += "  'cost arm & leg' → 非常贵 | 'on someone's nerves' → 惹恼\n\n";
		
		prompt += "EMOTION SLANG:\n";
		prompt += "  'lit' → 太棒了 | 'salty' → 心烦 | 'flex' → 炫耀\n";
		prompt += "  'slay' → 完美 | 'not gonna lie' → 说实话\n\n";
		
		prompt += "POP CULTURE & HUMOR:\n";
		prompt += "  Keep names, explain if joke lost | Sarcasm → amplify\n";
		prompt += "  Self-deprecation → maintain tone | Wordplay → find Chinese equivalent\n\n";
	}
	else if (SrcLang == "ja")
	{
		prompt += "=== JAPANESE ANIME CULTURE ===\n";
		prompt += "EMOTIONAL AUTHENTICITY > Literal translation\n";
		prompt += "Exaggeration/dramatic delivery → Match energy level\n\n";
		
		prompt += "HONORIFICS (translate via formality, not literally):\n";
		prompt += "  -san/-sama → formal | -chan/-kun → casual\n";
		prompt += "  Aggressive (だ/よ) → 呀/咦 | Feminine (-わ/-の) → 啦/呢/哪\n\n";
		
		prompt += "ANIME TERMS:\n";
		prompt += "  必殺技 → 必杀技 | 魔法 → 魔法/法术 | キャラ → 角色\n\n";
		
		prompt += "INTENSITY MARKERS:\n";
		prompt += "  Passionate → 绝对/一定/非要 | Cute → 啦/呀/哪\n";
		prompt += "  Angry → 你.../我... repetition | Shocked → 什么!?/怎么可能\n\n";
		
		prompt += "MODERN SLANG:\n";
		prompt += "  草(wara) → 笑死 | やばい → 糟了/太棒了 (context)\n";
		prompt += "  推し → 最爱 | ウケる → 超搞笑\n\n";
	}
	else if (SrcLang == "ko")
	{
		prompt += "=== KOREAN K-CULTURE ===\n";
		prompt += "HONORIFICS HIERARCHY (Critical):\n";
		prompt += "  -님 → 敬语对待 | -어요 → 友好 | -어/-아 → 亲密\n";
		prompt += "  -냐/-니 → 直接/亲密\n\n";
		
		prompt += "K-DRAMA EXPRESSIONS:\n";
		prompt += "  뭐하는 거야? → 你在干什么呢 | 미워 → 讨厌你 (playful)\n";
		prompt += "  사랑해 → 我爱你 (dramatic context)\n\n";
		
		prompt += "SLANG:\n";
		prompt += "  헐(heul) → 什么!? | 개꿀 → 太爽了 | 뭔소리 → 说什么呢\n\n";
	}
	else if (SrcLang == "fr")
	{
		prompt += "=== FRENCH ELEGANCE ===\n";
		prompt += "Tu/Vous → 你(casual)/您(formal)\n";
		prompt += "Match elegance with poetic Chinese where appropriate\n";
		prompt += "Preserve romantic and subtle subtext\n\n";
	}
	
	// === 内容类型指导 ===
	if (g_genre != "general")
	{
		prompt += GetGenreSpecificGuide(g_genre) + "\n";
	}
	
	// === 上下文指导 ===
	if (contextLen > 0)
	{
		prompt += "=== CONTEXT STRATEGY ===\n";
		prompt += "Previous translations provided for reference.\n";
		prompt += "USE IF: Same speaker (maintain voice) | Same topic (keep terms) | Same scene (emotional flow)\n";
		prompt += "IGNORE IF: Different speaker/topic | Context contradicts meaning\n\n";
	}
	
	// === 质量检查 ===
	prompt += "=== QUALITY CHECKS ===\n";
	prompt += "Before output:\n";
	prompt += "✓ Naturalness: Would native speaker say this?\n";
	prompt += "✓ Meaning: Does it capture original intent?\n";
	prompt += "✓ Tone: Does it match character/context?\n";
	prompt += "✓ Consistency: Does it match previous terms?\n";
	prompt += "✓ Length: Appropriate for subtitles?\n\n";
	
	// === 最终翻译指令 ===
	if (srcLangName.length() == 0)
		prompt += "Translate to " + dstLangName + ".";
	else
		prompt += "Translate from " + srcLangName + " to " + dstLangName + ".";
	
	// === 用户自定义提示词（追加到末尾） ===
	if (g_customPrompt.length() > 0)
	{
		prompt += "\n\n=== USER CUSTOM PROMPT ===\n";
		prompt += "USER'S REQUEST HAS HIGHER PRIORITY WHEN CONFLICTS OCCUR. ";
		prompt += "If user's request conflicts with system rules (colloquial speech, genre guidelines, etc.), ";
		prompt += "FOLLOW USER'S REQUEST. Otherwise, combine both system rules and user preferences.\n\n";
		prompt += JsonEscape(g_customPrompt) + "\n";
	}
	
	return prompt;
}

// ============ 内容类型特定指导 ============
string GetGenreSpecificGuide(string genre)
{
	if (genre == "anime")
	{
		return "=== ANIME: Energetic, Expressive, Character-Driven ===\n"
			+ "1. NATURAL DIALOGUE: Casual banter, jokes, playful tone\n"
			+ "   Use particles, contractions, energetic expressions\n"
			+ "2. CHARACTER DIFFERENTIATION: Cute girl ≠ cool boy\n"
			+ "3. ACTION SCENES: Use power words, exclamations\n"
			+ "4. EVERYDAY TALK: Casual, spontaneous, surprising reactions\n"
			+ "5. PRESERVE CULTURE: Keep anime flavor while sounding natural";
	}
	else if (genre == "western-comic")
	{
		return "=== WESTERN COMIC: Hilarious, Sarcastic, Punchy ===\n"
			+ "1. HUMOR LANDS: Jokes must be funny, use exaggeration and contrast\n"
			+ "2. CASUAL LANGUAGE WELCOME: Rough talk, slang, colloquial allowed\n"
			+ "3. ONE-LINERS: Punch lines sharp and brief, no long setup\n"
			+ "4. SARCASM: Make it obvious, use tone to signal mockery\n"
			+ "5. ACTION IMPACTS: Sound effects, dynamic expressions for combat";
	}
	else if (genre == "scifi")
	{
		return "=== SCI-FI: Terminology Clear, Worldbuilding Consistent ===\n"
			+ "1. CONSISTENT JARGON: Define terms first time they appear\n"
			+ "2. FUTURISTIC FEEL: Tech words should sound advanced, not archaic\n"
			+ "3. SIMPLIFY COMPLEX IDEAS: Use analogies for clarity\n"
			+ "4. EXPLAIN TECHNOLOGY: What is it? Why does it matter?\n"
			+ "5. NATURAL LANGUAGE: Terminology doesn't mean alien phrasing";
	}
	else if (genre == "drama")
	{
		return "=== DRAMA: Authentic, Nuanced, Emotionally Resonant ===\n"
			+ "1. DIALOGUE AUTHENTICITY: Pauses, repetition, emotional shifts matter\n"
			+ "2. SUBTEXT IS KEY: Unspoken emotion must be felt in phrasing\n"
			+ "3. COLLOQUIAL EXTREME: Everyday conversation, not melodrama\n"
			+ "4. RELATIONSHIPS IN WORDS: Intimacy, distance reflected in speech\n"
			+ "5. SILENCE & RESTRAINT: One perfect line beats ten explanations";
	}
	else if (genre == "horror")
	{
		return "=== HORROR: Oppressive, Eerie, Tension-Filled ===\n"
			+ "1. ATMOSPHERE OVER PLOT: Word choice creates DREAD\n"
			+ "2. SHORT SENTENCES FOR TENSION: Brief, sharp dialogue\n"
			+ "3. SCREAMS ARE PRIMAL: Raw, authentic emotional reactions\n"
			+ "4. THREATS ARE COLD: Quiet menace scarier than rage\n"
			+ "5. TONE IS RESTRAINED: Every line carries suppressed anxiety";
	}
	else if (genre == "disney")
	{
		return "=== DISNEY: Warm, Hopeful, Family-Friendly ===\n"
			+ "1. WARMTH IS PRIMARY: Draw people in, don't lecture\n"
			+ "2. GENTLE WORD CHOICE: Inclusion, connection, belonging\n"
			+ "3. LAUGHTER IS KINDNESS: Humor with heart, not mockery\n"
			+ "4. MUSICAL QUALITY: Rhythmic dialogue, sing-song flow\n"
			+ "5. COURAGE IS ORDINARY: Everyday people being brave";
	}
	else if (genre == "gamedev")
	{
		return "=== GAMEDEV: Clear, Encouraging, Practical ===\n"
			+ "1. TERMINOLOGY PRECISION: Standard terms or plain language\n"
			+ "2. PROGRESSION: Build concepts progressively, no info dumps\n"
			+ "3. PROCESS-FIRST: Explain workflow before abstract theory\n"
			+ "4. HONEST BUT SUPPORTIVE: Don't oversimplify, say 'this takes learning'\n"
			+ "5. TONE: Like a knowledgeable friend teaching code";
	}
	else
	{
		return "=== GENERAL: Natural, Authentic, Engaging ===\n"
			+ "1. DIALOGUE FIRST: Comfortable to read/hear, not study material\n"
			+ "2. MEANING NOT WORDS: Literal translation always sounds wooden\n"
			+ "3. CHARACTER VOICE: Different people speak differently\n"
			+ "4. WHEN IN DOUBT: Use the most common phrasing\n"
			+ "5. NATURAL LANGUAGE: If it sounds good, it IS good";
	}
}

// ============ 核心翻译函数 ============
string Translate(string Text, string &in SrcLang, string &in DstLang)
{
	// 从保存的配置加载
	if (g_apiKey.length() == 0)
	{
		g_apiKey = HostLoadString("AI_Trans_Key", "");
	}
	if (g_baseUrl.length() == 0)
	{
		g_baseUrl = HostLoadString("AI_Trans_Url", "https://api.deepseek.com");
	}
	if (g_model.length() == 0)
	{
		g_model = HostLoadString("AI_Trans_Model", "deepseek-chat");
	}
	
	// 加载历史记录条数配置
	string savedHistory = HostLoadString("AI_Trans_History", "5");
	int historyCount = parseInt(savedHistory);
	if (historyCount >= 0 && historyCount <= 20)
		g_maxHistory = historyCount;
	else
		g_maxHistory = 5;
	
	// 加载内容类型配置
	string savedGenre = HostLoadString("AI_Trans_Genre", "general");
	if (savedGenre == "anime" || savedGenre == "western-comic" || savedGenre == "scifi" || savedGenre == "disney" || 
	    savedGenre == "fantasy" || savedGenre == "drama" || savedGenre == "horror" || savedGenre == "gamedev")
	{
		g_genre = savedGenre;
	}
	else
	{
		g_genre = "general";
	}
	
	// 加载场景变更阈值配置
	string savedThreshold = HostLoadString("AI_Trans_SceneThreshold", "6000");
	int thresholdVal = parseInt(savedThreshold);
	if (thresholdVal > 0 && thresholdVal <= 60000)
		g_sceneChangeThreshold = uint(thresholdVal);
	else
		g_sceneChangeThreshold = 6000;
	
	// 加载自定义提示词配置
	g_customPrompt = HostLoadString("AI_Trans_CustomPrompt", "");
	
	// 检查配置
	if (g_apiKey.length() == 0) return "";
	if (Text.Trim().length() == 0) return "";
	
	// 检测是否有场景切换
	uint currentTime = HostGetTickCount();
	if (g_lastTranslateTime > 0)
	{
		uint timeDiff = currentTime - g_lastTranslateTime;
		if (timeDiff > g_sceneChangeThreshold)
		{
			// 场景切换，清空过时的上下文
			ClearContext();
		}
	}
	g_lastTranslateTime = currentTime;
	
	// 检查目标语言是否改变，如果改变则清空缓存
	if (g_lastDstLang != DstLang)
	{
		ClearHistory();
		g_lastDstLang = DstLang;
	}
	
	// 在缓存中查找当前文本
	int cacheIndex = FindInCache(Text);
	int cacheSize = int(g_allSource.length());
	
	// ====== 后退/回看场景：在缓存中找到了 ======
	if (cacheIndex >= 0)
	{
		// 检测是否是连续播放（索引+1）还是跳跃
		if (g_lastIndex >= 0 && cacheIndex != g_lastIndex && cacheIndex != g_lastIndex + 1)
		{
			// 跳跃到之前的位置，从缓存中重建上下文
			BuildContextFromCache(cacheIndex);
		}
		
		g_lastIndex = cacheIndex;
		SrcLang = "UTF8";
		DstLang = "UTF8";
		return g_allTarget[cacheIndex];
	}
	
	// 构建增强型翻译提示词
	string prompt = BuildEnhancedPrompt(Text, SrcLang, DstLang, int(g_contextSource.length()));
	
	// 构建请求体 - 使用当前上下文
	string body = "{\"model\":\"" + g_model + "\",";
	body += "\"messages\":[";
	body += "{\"role\":\"system\",\"content\":\"" + JsonEscape(prompt) + "\"},";
	
	// 使用当前连续上下文
	string contextMsgs = BuildContextMessages();
	body += contextMsgs;
	
	// 添加当前要翻译的文本
	body += "{\"role\":\"user\",\"content\":\"" + JsonEscape(Text) + "\"}";
	body += "],\"temperature\":0.0618,\"max_tokens\":1000}";
	
	// 构建URL
	string url = g_baseUrl + "/v1/chat/completions";
	
	string header = "Content-Type: application/json\r\nAuthorization: Bearer " + g_apiKey;
	
	// 发送请求
	string response = HostUrlGetString(url, UserAgent, header, body);
	
	if (response.length() == 0) return "";
	
	// 解析响应
	JsonReader reader;
	JsonValue root;
	
	if (!reader.parse(response, root)) return "";
	
	// 检查错误
	if (!root["error"].isNull())
	{
		HostPrintUTF8("API Error: " + root["error"]["message"].asString() + "\n");
		return "";
	}
	
	JsonValue choices = root["choices"];
	if (choices.isNull() || choices.size() == 0) return "";
	
	string result = choices[0]["message"]["content"].asString();
	result = result.Trim();
	
	// 保存到全量缓存和当前上下文
	if (result.length() > 0)
	{
		AddToCache(Text, result);
		AddToContext(Text, result);
		g_lastIndex = int(g_allSource.length()) - 1;  // 更新为缓存末尾
	}
	
	// 设置输出编码
	SrcLang = "UTF8";
	DstLang = "UTF8";
	
	return result;
}
