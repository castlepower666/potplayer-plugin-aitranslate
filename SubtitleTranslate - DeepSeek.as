/*
	PotPlayer 字幕实时翻译插件 - DeepSeek专用版
	
	专门针对DeepSeek API优化
	DeepSeek官网: https://www.deepseek.com
	API文档: https://platform.deepseek.com/api-docs
	
	作者: AI Assistant
	版本: 1.0
*/

// 插件名称
string GetTitle()
{
	return "{$CP936=DeepSeek翻译}";
}

// 插件版本
string GetVersion()
{
	return "1.0";
}

// 插件描述
string GetDesc()
{
	return "{$CP936=使用DeepSeek AI进行字幕实时翻译（高性价比）}";
}

// 登录标题
string GetLoginTitle()
{
	return "{$CP936=DeepSeek API配置}";
}

// 登录用户名标签
string GetLoginUsernameTitle()
{
	return "API Key";
}

// 登录密码标签
string GetLoginPasswordTitle()
{
	return "{$CP936=模型选择}";
}

// 用户名输入框提示
string GetLoginUsernameDesc()
{
	return "{$CP936=在 platform.deepseek.com 获取API Key}";
}

// 密码输入框提示
string GetLoginPasswordDesc()
{
	return "{$CP936=输入模型名: deepseek-chat 或 deepseek-reasoner}";
}

// 用户代理
string GetUserAgent()
{
	return "PotPlayer-AI-Translate/1.0";
}

// ================= 配置 =================

string g_apiKey = "";
string g_model = "deepseek-chat";
string g_srcLang = "auto";
string g_dstLang = "Simplified Chinese";

// DeepSeek API地址
string API_BASE_URL = "https://api.deepseek.com";

// 登录
string ServerLogin(string apiKey, string model)
{
	g_apiKey = apiKey.Trim();
	
	if (model.length() > 0)
	{
		g_model = model.Trim();
	}
	else
	{
		g_model = "deepseek-chat";
	}
	
	// 保存配置
	HostSaveString("DeepSeek_ApiKey", g_apiKey);
	HostSaveString("DeepSeek_Model", g_model);
	
	// 验证API Key
	if (g_apiKey.length() == 0)
	{
		return "400 API Key is required";
	}
	
	return "200 OK";
}

// 注销
void ServerLogout()
{
	g_apiKey = "";
}

// ================= 语言支持 =================

int GetSrcLanCount() { return 12; }
int GetDstLanCount() { return 11; }

string GetSrcLanName(int idx)
{
	switch(idx)
	{
		case 0:  return "{$CP936=自动检测}";
		case 1:  return "English";
		case 2:  return "{$CP936=简体中文}";
		case 3:  return "{$CP936=繁體中文}";
		case 4:  return "{$CP936=日本語}";
		case 5:  return "{$CP936=한국어}";
		case 6:  return "Français";
		case 7:  return "Deutsch";
		case 8:  return "Español";
		case 9:  return "Русский";
		case 10: return "Italiano";
		case 11: return "Português";
	}
	return "";
}

string GetDstLanName(int idx)
{
	switch(idx)
	{
		case 0:  return "{$CP936=简体中文}";
		case 1:  return "{$CP936=繁體中文}";
		case 2:  return "English";
		case 3:  return "{$CP936=日本語}";
		case 4:  return "{$CP936=한국어}";
		case 5:  return "Français";
		case 6:  return "Deutsch";
		case 7:  return "Español";
		case 8:  return "Русский";
		case 9:  return "Italiano";
		case 10: return "Português";
	}
	return "";
}

string GetSrcLangCode(int idx)
{
	switch(idx)
	{
		case 0:  return "auto";
		case 1:  return "English";
		case 2:  return "Simplified Chinese";
		case 3:  return "Traditional Chinese";
		case 4:  return "Japanese";
		case 5:  return "Korean";
		case 6:  return "French";
		case 7:  return "German";
		case 8:  return "Spanish";
		case 9:  return "Russian";
		case 10: return "Italian";
		case 11: return "Portuguese";
	}
	return "auto";
}

string GetDstLangCode(int idx)
{
	switch(idx)
	{
		case 0:  return "Simplified Chinese";
		case 1:  return "Traditional Chinese";
		case 2:  return "English";
		case 3:  return "Japanese";
		case 4:  return "Korean";
		case 5:  return "French";
		case 6:  return "German";
		case 7:  return "Spanish";
		case 8:  return "Russian";
		case 9:  return "Italian";
		case 10: return "Portuguese";
	}
	return "Simplified Chinese";
}

void SetSrcLan(int idx)
{
	g_srcLang = GetSrcLangCode(idx);
}

void SetDstLan(int idx)
{
	g_dstLang = GetDstLangCode(idx);
}

// ================= 翻译功能 =================

string EscapeJson(string s)
{
	string r = s;
	r.replace("\\", "\\\\");
	r.replace("\"", "\\\"");
	r.replace("\n", "\\n");
	r.replace("\r", "\\r");
	r.replace("\t", "\\t");
	return r;
}

string Translate(string text)
{
	// 加载配置
	if (g_apiKey.length() == 0)
	{
		g_apiKey = HostLoadString("DeepSeek_ApiKey", "");
		g_model = HostLoadString("DeepSeek_Model", "deepseek-chat");
	}
	
	if (g_apiKey.length() == 0)
	{
		return "";
	}
	
	string trimmedText = text.Trim();
	if (trimmedText.length() == 0)
	{
		return "";
	}
	
	// 构建系统提示词
	string systemPrompt;
	if (g_srcLang == "auto")
	{
		systemPrompt = "You are a subtitle translator. Translate the text to " + g_dstLang + ". Rules: 1) Output ONLY the translation, no explanations 2) Keep original formatting 3) Be concise and natural 4) Preserve tone and style";
	}
	else
	{
		systemPrompt = "You are a subtitle translator. Translate from " + g_srcLang + " to " + g_dstLang + ". Rules: 1) Output ONLY the translation, no explanations 2) Keep original formatting 3) Be concise and natural 4) Preserve tone and style";
	}
	
	// 构建请求体
	string body = "{";
	body += "\"model\":\"" + g_model + "\",";
	body += "\"messages\":[";
	body += "{\"role\":\"system\",\"content\":\"" + EscapeJson(systemPrompt) + "\"},";
	body += "{\"role\":\"user\",\"content\":\"" + EscapeJson(text) + "\"}";
	body += "],";
	body += "\"temperature\":0.1,";
	body += "\"max_tokens\":500,";
	body += "\"stream\":false";
	body += "}";
	
	// 发送请求
	string url = API_BASE_URL + "/v1/chat/completions";
	string header = "Content-Type: application/json\r\nAuthorization: Bearer " + g_apiKey;
	
	string response = HostUrlGetString(url, GetUserAgent(), header, body);
	
	if (response.length() == 0)
	{
		return "";
	}
	
	// 解析响应
	JsonReader reader;
	JsonValue root;
	
	if (!reader.parse(response, root))
	{
		HostPrintUTF8("DeepSeek: JSON parse error\n");
		return "";
	}
	
	// 检查错误
	if (!root["error"].isNull())
	{
		string errMsg = root["error"]["message"].asString();
		HostPrintUTF8("DeepSeek Error: " + errMsg + "\n");
		return "";
	}
	
	// 获取翻译结果
	JsonValue choices = root["choices"];
	if (choices.isNull() || choices.size() == 0)
	{
		return "";
	}
	
	string result = choices[0]["message"]["content"].asString();
	return result.Trim();
}
