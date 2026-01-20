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
	return "{$CP936=格式: API地址|模型名称|上下文条数(可选,默认5)|内容类型(可选) 和 API Key}Format: URL|Model|ContextCount(optional,default 5)|Genre(optional) and API Key";
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
const uint SCENE_CHANGE_THRESHOLD = 6000;  // 6秒无新字幕，判断为场景切换

string ServerLogin(string User, string Pass)
{
	// User = API URL|Model|ContextCount, Pass = API Key
	g_apiKey = Pass;
	
	// 解析 URL|Model|ContextCount 格式
	if (User.length() > 0)
	{
		// 分割字符串
		array<string> parts = User.split("|");
		
		if (parts.length() >= 1)
		{
			g_baseUrl = parts[0];
		}
		
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
		
		if (parts.length() >= 3 && parts[2].length() > 0)
		{
			int count = parseInt(parts[2]);
			if (count >= 0 && count <= 20)  // 限制范围 0-20
				g_maxHistory = count;
			else
				g_maxHistory = 5;  // 无效值使用默认
		}
		else
		{
			g_maxHistory = 5;  // 默认5条
		}
		
		if (parts.length() >= 4 && parts[3].length() > 0)
		{
			string genreInput = parts[3];
			// 验证 genre 是否有效
			if (genreInput == "anime" || genreInput == "western-comic" || genreInput == "scifi" || genreInput == "disney" || 
			    genreInput == "fantasy" || genreInput == "drama" || genreInput == "horror" || genreInput == "gamedev")
			{
				g_genre = genreInput;
			}
			else
			{
				g_genre = "general";  // 无效genre使用默认
			}
		}
		else
		{
			g_genre = "general";  // 默认为 general
		}

		
		// 去除末尾斜杠
		if (g_baseUrl.Right(1) == "/") g_baseUrl = g_baseUrl.Left(g_baseUrl.length() - 1);
	}
	
	HostSaveString("AI_Trans_Key", g_apiKey);
	HostSaveString("AI_Trans_Url", g_baseUrl);
	HostSaveString("AI_Trans_Model", g_model);
	HostSaveString("AI_Trans_History", "" + g_maxHistory);
	HostSaveString("AI_Trans_Genre", g_genre);
	
	if (g_apiKey.length() == 0) return "fail";
	return "200 ok";
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
	
	// 检查配置
	if (g_apiKey.length() == 0) return "";
	if (Text.Trim().length() == 0) return "";
	
	// 检测是否有场景切换（30秒无新字幕）
	uint currentTime = HostGetTickCount();
	if (g_lastTranslateTime > 0)
	{
		uint timeDiff = currentTime - g_lastTranslateTime;
		if (timeDiff > SCENE_CHANGE_THRESHOLD)
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
	
	string prompt = "You are a professional subtitle translator. ";
	prompt += "Translation rules:\n";
	prompt += "1. Translate naturally and fluently, maintaining the original tone and style.\n";
	prompt += "2. Keep character names, proper nouns, and technical terms consistent with previous translations.\n";
	prompt += "3. Preserve the original meaning, emotion, and nuance.\n";
	prompt += "4. Output ONLY the translation, no explanations or notes.\n";
	prompt += "5. If the text contains sounds or onomatopoeia, translate them appropriately.\n";
	
	if (srcLangName.length() == 0)
		prompt += "\nTranslate to " + dstLangName + ".";
	else
		prompt += "\nTranslate from " + srcLangName + " to " + dstLangName + ".";
	
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
