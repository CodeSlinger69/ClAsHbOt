// ImageMatch.cpp : Defines the exported functions for the DLL application.
//
#include "stdafx.h"
#include "ImageMatchDLL.h"
#include "Scraper.h"

char returnString[MAXSTRING];

char* __stdcall Initialize(char* scriptDir)
{
	scraper = new Scraper();
	scraper->SetDirectories(scriptDir);
	scraper->LoadNeedles();

	sprintf_s(returnString, MAXSTRING, "Success");
	return returnString;
}

char* __stdcall FindBestBMP(searchType type, HBITMAP hBmp, double threshold)
{
	MATCHPOINTS match;
	std::string matchedString = scraper->FindBestBMP(type, hBmp, threshold, &match);
	
	if (matchedString.length() > 0)
		sprintf_s(returnString, MAXSTRING, "%s|%d|%d|%.4f", matchedString.c_str(), match.x, match.y, match.val);
	else
		sprintf_s(returnString, MAXSTRING, "%s|%d|%d|%.4f", "", -1, -1, 0.0);

	return returnString;
}

char* __stdcall FindAllBMPs(searchType type, HBITMAP hBmp, double threshold, int maxMatch)
{
	std::vector<MATCHPOINTS> matches;

	scraper->FindAllBMPs(type, hBmp, threshold, maxMatch, &matches);
	PrepareReturnString(matches);

	return returnString;
}

char* __stdcall LocateSlots(actionType aType, slotType sType, HBITMAP hBmp, double threshold)
{
	std::vector<MATCHPOINTS> matches;

	scraper->LocateSlots(aType, sType, hBmp, threshold, &matches);
	PrepareReturnString(matches);

	return returnString;
}

char* __stdcall CountBuiltTroops(troopClass type, HBITMAP hBmp, double threshold)
{
	std::vector<MATCHPOINTS> matches;

	scraper->CountBuiltTroops(type, hBmp, threshold, &matches);
	PrepareReturnString(matches);

	return returnString;
}

void PrepareReturnString(const std::vector<MATCHPOINTS> matches)
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
