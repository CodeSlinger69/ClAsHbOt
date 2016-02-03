#pragma once

class Logger {
public:
	Logger(const char* scriptDir, const bool dGlob);
	void WriteLog(string text, const bool withDateTime = true, const bool withCR = true);
 
private:
	char logFilePath[MAX_PATH];
	bool debugGlobal;
};

extern shared_ptr<Logger> logger;
