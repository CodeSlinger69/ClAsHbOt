// ImageMatch.cpp : Defines the exported functions for the DLL application.
//
#include "stdafx.h"
#include "ImageMatchDLL.h"
#include "CGdiPlus.h"
#include "Logger.h"
#include "Scraper.h"
#include "OCR.h"

char returnString[MAXSTRING];

char* __stdcall Initialize(char* scriptDir, bool debugGlobal, bool debugOCR)
{
	CGdiPlus::Init();
	logger.reset(new Logger(scriptDir, debugGlobal));
	scraper.reset(new Scraper(scriptDir));
	ocr.reset(new OCR(scriptDir, debugOCR));

	logger->WriteLog("Initialization complete");
	sprintf_s(returnString, MAXSTRING, "Success");
	return returnString;
}

char* __stdcall FindBestBMP(searchType type, HBITMAP hBmp, double threshold)
{
	MATCHPOINTS match;
	string matchedString = scraper->FindBestBMP(type, hBmp, threshold, match);
	
	if (matchedString.length() > 0)
		sprintf_s(returnString, MAXSTRING, "%s|%d|%d|%.4f", matchedString.c_str(), match.x, match.y, match.val);
	else
		sprintf_s(returnString, MAXSTRING, "%s|%d|%d|%.4f", "", -1, -1, 0.0);

	return returnString;
}

char* __stdcall FindAllBMPs(searchType type, HBITMAP hBmp, double threshold, int maxMatch)
{
	vector<MATCHPOINTS> matches;

	scraper->FindAllBMPs(type, hBmp, threshold, maxMatch, matches);
	PrepareReturnString(matches);

	return returnString;
}

char* __stdcall LocateSlots(actionType aType, slotType sType, HBITMAP hBmp, double threshold)
{
	vector<MATCHPOINTS> matches;

	scraper->LocateSlots(aType, sType, hBmp, threshold, matches);
	PrepareReturnString(matches);

	return returnString;
}

char*__stdcall ScrapeFuzzyText(HBITMAP hBmp, const fontType fontT, const Gdiplus::Color foregroundColor, const unsigned int colorRadius, const bool keepSpaces)
{
	string s = ocr->ScrapeFuzzyText(hBmp, fontT, foregroundColor, colorRadius, keepSpaces);

	sprintf_s(returnString, MAXSTRING, "%s", s.c_str());

	return returnString;
}


void PrepareReturnString(const vector<MATCHPOINTS> matches)
{
	if (!matches.empty())
	{
		sprintf_s(returnString, MAXSTRING, "%d", matches.size());
		for (int i=0; i<(int) matches.size(); i++)
		{
			char curMatch[MAXSTRING];
			sprintf_s(curMatch, MAXSTRING, "|%d|%d|%.4f", matches.at(i).x, matches.at(i).y, matches.at(i).val);
			strcat_s(returnString, MAXSTRING, curMatch);
		}
	}
	else
	{
		sprintf_s(returnString, MAXSTRING, "%d|%d|%d|%.4f", 0, -1, -1, 0.0);
	}
}
