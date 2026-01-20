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
		return "{$CP936=配置格式: URL|Model|Context|Genre|SceneThreshold\n"
			+ "示例: https://api.deepseek.com|deepseek-chat|5|anime|6000\n\n"
			+ "Genre选项: anime(日漫) western-comic(美漫) scifi fantasy drama horror disney gamedev general\n"
			+ "Context: 0(无上下文) 3-5(推荐) 10+(强一致性)\n"
			+ "SceneThreshold: 场景变更阈值(毫秒, 默认6000)\n"
			+ "默认: Model=deepseek-chat, Context=5, Genre=general, SceneThreshold=6000"
			+ "}Format: URL|Model|Context|Genre|SceneThreshold\n"
			+ "Example: https://api.deepseek.com|deepseek-chat|5|anime|6000\n\n"
			+ "Genre: anime western-comic scifi fantasy drama horror disney gamedev general\n"
			+ "Context: 0(no context) 3-5(recommended) 10+(strong consistency)\n"
			+ "SceneThreshold: Scene change threshold in milliseconds (default: 6000)\n"
			+ "Default: deepseek-chat, 5, general, 6000";}
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
	
	// 去除末尾斜杠
	if (g_baseUrl.Right(1) == "/") g_baseUrl = g_baseUrl.Left(g_baseUrl.length() - 1);
	
	// 保存配置
	HostSaveString("AI_Trans_Key", g_apiKey);
	HostSaveString("AI_Trans_Url", g_baseUrl);
	HostSaveString("AI_Trans_Model", g_model);
	HostSaveString("AI_Trans_History", "" + g_maxHistory);
	HostSaveString("AI_Trans_Genre", g_genre);
	HostSaveString("AI_Trans_SceneThreshold", "" + g_sceneChangeThreshold);
	
	// 打印调试信息到控制台
	HostPrintUTF8("=== AI Translator Config Loaded ===\n");
	HostPrintUTF8("URL: " + g_baseUrl + "\n");
	HostPrintUTF8("Model: " + g_model + "\n");
	HostPrintUTF8("Context: " + g_maxHistory + "\n");
	HostPrintUTF8("Genre: " + g_genre + "\n");
	HostPrintUTF8("SceneThreshold: " + g_sceneChangeThreshold + "ms\n");
	
	return "200 ok|{$CP936=配置成功! Model:" + g_model + " Context:" + g_maxHistory + " Genre:" + g_genre + " Threshold:" + g_sceneChangeThreshold + "ms}OK! Model:" + g_model + " Context:" + g_maxHistory + " Genre:" + g_genre + " Threshold:" + g_sceneChangeThreshold + "ms";
}

void ServerLogout()
{
	g_apiKey = "";
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
	
	// 构建翻译提示 - 改进版本
	string dstLangName = GetLangName(DstLang);
	string srcLangName = "";
	if (SrcLang.length() > 0) srcLangName = GetLangName(SrcLang);
	
	string prompt = "You are a professional subtitle translator for colloquial speech and dialogue (e.g., movies, TV shows, anime).\n";
	prompt += "PRIMARY GOAL: Translate dialogue naturally and conversationally - as if native Chinese speakers would actually SAY it.\n\n";
	prompt += "COLLOQUIAL TRANSLATION PRINCIPLES:\n";
	prompt += "- Use natural, everyday Chinese expressions (日常口语)\n";
	prompt += "- Avoid overly formal or literary language (文言文/书面语)\n";
	prompt += "- Reflect how real people speak: incomplete sentences, interruptions, contractions, informal phrasing\n";
	prompt += "- Prioritize natural flow over grammatical perfection\n";
	prompt += "- Match the character's personality and speech patterns in the translation\n";
	prompt += "- Keep the tone, attitude, and emotion of the original speaker\n";
	prompt += "- Use colloquial particles and conversational markers (啊、呢、吧、嘛等)\n";
	prompt += "- Slang, idioms, and informal expressions ARE PART OF natural speech - handle them appropriately\n\n";
	prompt += "Translation rules:\n";
	prompt += "1. Translate naturally and fluently, maintaining the original tone and style.\n";
	prompt += "2. Keep character names, proper nouns, and technical terms CONSISTENT with previous translations in context.\n";
	prompt += "3. Preserve the original meaning, emotion, and nuance.\n";
	prompt += "4. Check your translation for obvious errors before returning (grammar, logic, consistency, typos).\n";
	prompt += "5. If the text contains sounds or onomatopoeia, translate them appropriately.\n";
	prompt += "6. Output ONLY the final corrected translation, no explanations or notes.\n";
	
	// 根据源语言添加文化背景指导
	if (SrcLang == "en")
	{
		prompt += "\nCULTURAL & SLANG CONTEXT (English Source):\n";
		prompt += "This is English-language content. Focus on:\n";
		prompt += "- AMERICAN ENGLISH slang: 'lit' (cool), 'salty' (upset), 'flex' (show off), 'vibe' (feeling)\n";
		prompt += "- BRITISH ENGLISH slang: 'brilliant' (great), 'mate' (friend), 'cheeky' (playful)\n";
		prompt += "- INTERNET/MODERN slang: 'slay' (do great), 'no cap' (no lie), 'lowkey' (subtly)\n";
		prompt += "- Cultural references to American/British culture, Hollywood, pop music\n";
		prompt += "- Humor styles: sarcasm, self-deprecation, wordplay\n";
		prompt += "- Find Chinese translations that match the attitude and cultural context\n\n";
		prompt += "CRITICAL: English Phrasal & Idiom Translation Guide:\n";
		prompt += "These specific English expressions have FIXED meanings, NOT literal translations:\n";
		prompt += "- 'It is on' -> '准备开始/要来了/有戏了'\n";
		prompt += "- 'Bring it on' -> '来吧/放马过来'\n";
		prompt += "- 'That's on fire' -> '太火了/太牛了' (NOT: 那在着火)\n";
		prompt += "- 'Rain check' -> '改天再说/延期' (NOT: 雨的支票)\n";
		prompt += "- 'Piece of cake' -> '轻而易举' (NOT: 蛋糕片)\n";
		prompt += "- 'Break the ice' -> '打破僵局' (NOT: 破冰)\n";
		prompt += "- 'Hit the books' -> '开始学习' (NOT: 打书)\n";
		prompt += "- 'Ball is in your court' -> '轮到你了/你来决定'\n";
		prompt += "- 'Spill the tea' -> '说出秘密/爆料' (modern slang)\n";
		prompt += "- 'Salty' -> '生气/不开心' (NOT: 咸的)\n";
		prompt += "- 'Savage' -> '狠/无情/很厉害'\n";
		prompt += "- 'Flex' -> '炫耀/显摆'\n";
		prompt += "- 'Vibe' -> '感觉/氛围' (NOT: 振动)\n";
		prompt += "- 'Lowkey' -> '其实/不太显眼地'\n";
		prompt += "ALWAYS check if an English phrase is an idiom or slang before translating literally.\n";
	}
	else if (SrcLang == "ja")
	{
		prompt += "\nCULTURAL & SLANG CONTEXT (Japanese Source):\n";
		prompt += "This is Japanese-language content. Focus on:\n";
		prompt += "- Japanese anime/manga culture references\n";
		prompt += "- Japanese honorifics and politeness levels (敬語)\n";
		prompt += "- Japanese internet slang: '草' (lol), '推し' (favorite), 'やばい' (cool/scary)\n";
		prompt += "- Cultural humor: slapstick, wordplay, reference humor\n";
		prompt += "- School/youth culture specific terms\n";
		prompt += "- Preserve emotional expressions typical of Japanese media\n";
	}
	else if (SrcLang == "ko")
	{
		prompt += "\nCULTURAL & SLANG CONTEXT (Korean Source):\n";
		prompt += "This is Korean-language content. Focus on:\n";
		prompt += "- Korean pop culture references (K-pop, K-drama)\n";
		prompt += "- Korean honorifics and formality levels\n";
		prompt += "- Korean internet slang and trendy expressions\n";
		prompt += "- Hierarchy and respectful language patterns\n";
		prompt += "- Korean youth culture specific terms\n";
	}
	else if (SrcLang == "fr")
	{
		prompt += "\nCULTURAL & SLANG CONTEXT (French Source):\n";
		prompt += "This is French-language content. Focus on:\n";
		prompt += "- French cultural references and humor\n";
		prompt += "- French internet/youth slang\n";
		prompt += "- Romantic and poetic language patterns common in French\n";
		prompt += "- Preserve sophistication and elegance in translation\n";
	}
	else
	{
		prompt += "\nCULTURAL & SLANG CONTEXT:\n";
		prompt += "Understand the cultural background of the source language and adapt slang/idioms accordingly.\n";
	}
	
	prompt += "\nSlang & Informal Language (PART OF COLLOQUIAL SPEECH):\n";
	prompt += "Slang and idioms are natural parts of how people actually speak. Handle them authentically:\n";
	prompt += "- FIRST, BEFORE translating: Carefully check if the text contains slang, colloquialisms, idioms, or informal speech\n";
	prompt += "- DO NOT instantly translate word-for-word (literal translation of idioms = completely wrong meaning)\n";
	prompt += "- For EVERY phrase with multiple words, ask: 'Is this possibly an idiom or slang expression?'\n";
	prompt += "- If uncertain whether something is literal or figurative, ALWAYS assume it might be slang first\n";
	prompt += "- Find Chinese equivalents that capture the SPIRIT and TONE of the slang, keeping it natural and conversational\n";
	prompt += "- Examples of slang->colloquial translation:\n";
	prompt += "  * 'That's lit' (cool) -> '这太牛了' or '这真不错' (matches natural speech)\n";
	prompt += "  * 'Yo, wassup' (hey) -> '嘿，怎么样' (keeps informal greeting tone)\n";
	prompt += "  * 'Sucks' (bad) -> '太糟了' (matches everyday emotional expression)\n";
	prompt += "  * 'It is on like Donkey Kong' (things are about to start) -> '要开干了' (NOT literal Donkey Kong, but natural slang)\n";
	prompt += "- Use context clues to understand slang meaning when uncertain\n";
	prompt += "- IMPORTANT: Keep the colloquial/casual tone in Chinese - slang HELPS maintain natural dialogue\n";
	prompt += "- Adapt slang based on the cultural origin (American vs British vs Japanese vs Korean, etc.)\n";
	prompt += "- CRITICAL: Always check multi-word English phrases - they are often idioms with hidden meanings!\n";
	
	// 添加翻译前的自检清单
	prompt += "\n=== PRE-TRANSLATION CHECKLIST ===\n";
	prompt += "Before translating, ALWAYS go through these checks:\n";
	prompt += "1. Read the entire text carefully\n";
	prompt += "2. Identify ANY phrases that might be slang/idioms (especially multi-word expressions)\n";
	prompt += "3. Ask yourself: 'If I translate this word-for-word, does it make sense?'\n";
	prompt += "4. If the literal translation seems odd or out of place, it's probably slang -> Find the actual meaning\n";
	prompt += "5. Check the provided IDIOM LIST above for matches\n";
	prompt += "6. Use context (previous translations) to confirm cultural appropriateness\n";
	prompt += "7. Only THEN provide the final translation\n\n";
	prompt += "RED FLAGS (high chance of slang/idiom):\n";
	prompt += "- Phrases with animals mentioned literally ('like Donkey Kong', 'fish out of water')\n";
	prompt += "- Phrases with body parts ('break your neck', 'blow my mind', 'cost an arm and a leg')\n";
	prompt += "- Phrases with weather/nature ('under the weather', 'raining cats and dogs')\n";
	prompt += "- Phrases with 'like' ('like a fish out of water', 'like Donkey Kong')\n";
	prompt += "- Single-word slang that's informal (lit, salty, flex, vibe, savage, slay)\n";
	prompt += "- Any phrase that doesn't make literal sense\n";
	
	if (srcLangName.length() == 0)
		prompt += "\nTranslate to " + dstLangName + ".";
	else
		prompt += "\nTranslate from " + srcLangName + " to " + dstLangName + ".";
	
	// 添加上下文使用指引 - 加入智能判断机制
	if (g_contextSource.length() > 0)
	{
		prompt += "\n\nCONTEXT INTELLIGENCE REQUIRED:\n";
		prompt += "Previous translations are provided below as conversation context.\n";
		prompt += "IMPORTANT: Evaluate if this context is relevant to the current text:\n";
		prompt += "- If the context is from the SAME conversation/scene -> Use it for consistency\n";
		prompt += "- If the context is from a DIFFERENT scene/topic -> Ignore it, translate independently\n";
		prompt += "- If context mentions SAME characters/topics -> Use it\n";
		prompt += "- If context is about COMPLETELY DIFFERENT content -> Discard it\n\n";
		prompt += "When using context, ensure:\n";
		prompt += "- Character names match previous translations\n";
		prompt += "- Terminology is consistent with context\n";
		prompt += "- Tone and style align with conversation flow\n";
		prompt += "- Technical/specialized terms use same definitions as context\n";
		prompt += "- For slang: Use context to understand the exact meaning and attitude before translating\n\n";
		prompt += "When NOT using context (different scene):\n";
		prompt += "- Translate independently with high quality\n";
		prompt += "- Maintain professional tone\n";
		prompt += "- Do NOT force artificial consistency\n";
	}
	else
	{
		prompt += "\n\nNo previous context available. Translate independently and ensure quality.\n";
	}
	
	// 根据内容类型添加特定提示词
	string genrePrompt = GetGenrePromptSuffix(g_genre);
	if (genrePrompt.length() > 0)
	{
		prompt += genrePrompt;
	}
	
	// 构建请求体 - 使用当前上下文
	string body = "{\"model\":\"" + g_model + "\",";
	body += "\"messages\":[";
	body += "{\"role\":\"system\",\"content\":\"" + JsonEscape(prompt) + "\"},";
	
	// 使用当前连续上下文
	string contextMsgs = BuildContextMessages();
	body += contextMsgs;
	
	// 添加当前要翻译的文本
	body += "{\"role\":\"user\",\"content\":\"" + JsonEscape(Text) + "\"}";
	body += "],\"temperature\":0.3,\"max_tokens\":1000}";
	
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
