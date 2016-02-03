#include "stdafx.h"
#include "Logger.h"

shared_ptr<Logger> logger;

Logger::Logger(const char* scriptDir, const bool dGlob)
{
	sprintf_s(logFilePath, MAX_PATH, "%s\\ClashBotLog.txt", scriptDir);
	debugGlobal = dGlob;
}

void Logger::WriteLog(string text, const bool withDateTime, const bool withCR)
{
	if (!debugGlobal) return;

	FILE* f;
	errno_t err;

	err = fopen_s(&f, logFilePath, "a");

	if (err==0)
	{
		time_t t = time(0);
		struct tm now;

		err = localtime_s (&now, &t); 
        if (err)
        {	
			if (withDateTime) fprintf_s(f, "00/00/0000 00:00:00 ImageMatchDLL ");
		}
		else
		{
			if (withDateTime) fprintf_s(f, "%d/%d/%d %02d:%02d:%02d ImageMatchDLL ", now.tm_mon+1, now.tm_mday, now.tm_year+1900, now.tm_hour, now.tm_min, now.tm_sec);
		}

		fprintf_s(f, "%s", text.c_str());
		if (withCR) fprintf_s(f, "\n");

		err = fclose(f);
	}
}
