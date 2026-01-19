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
	return "{$CP936=格式: API地址|模型名称 和 API Key}Format: URL|Model and API Key";
}

string GetUserText()
{
	return "{$CP936=API地址|模型:}URL|Model:";
}

string GetPasswordText()
{
	return "API Key:";
}

// ============ 全局配置 ============
string g_apiKey = "";
string g_baseUrl = "";
string g_model = "deepseek-chat";
string UserAgent = "PotPlayer/1.0";

string ServerLogin(string User, string Pass)
{
	// User = API URL|Model, Pass = API Key
	g_apiKey = Pass;
	
	// 解析 URL|Model 格式
	if (User.length() > 0)
	{
		int pos = User.findFirst("|");
		if (pos > 0)
		{
			g_baseUrl = User.substr(0, pos);
			g_model = User.substr(pos + 1);
		}
		else
		{
			g_baseUrl = User;
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
		// 去除末尾斜杠
		if (g_baseUrl.Right(1) == "/") g_baseUrl = g_baseUrl.Left(g_baseUrl.length() - 1);
	}
	
	HostSaveString("AI_Trans_Key", g_apiKey);
	HostSaveString("AI_Trans_Url", g_baseUrl);
	HostSaveString("AI_Trans_Model", g_model);
	
	if (g_apiKey.length() == 0) return "fail";
	return "200 ok";
}

void ServerLogout()
{
	g_apiKey = "";
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
	
	// 检查配置
	if (g_apiKey.length() == 0) return "";
	if (Text.Trim().length() == 0) return "";
	
	// 构建翻译提示
	string dstLangName = GetLangName(DstLang);
	string srcLangName = "";
	if (SrcLang.length() > 0) srcLangName = GetLangName(SrcLang);
	
	string prompt;
	if (srcLangName.length() == 0)
		prompt = "You are a subtitle translator. Translate the following text to " + dstLangName + ". Output ONLY the translation, no explanations:";
	else
		prompt = "You are a subtitle translator. Translate from " + srcLangName + " to " + dstLangName + ". Output ONLY the translation, no explanations:";
	
	// 构建请求体 - 使用动态模型名
	string body = "{\"model\":\"" + g_model + "\",";
	body += "\"messages\":[";
	body += "{\"role\":\"system\",\"content\":\"" + JsonEscape(prompt) + "\"},";
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
	
	// 设置输出编码
	SrcLang = "UTF8";
	DstLang = "UTF8";
	
	return result.Trim();
}
