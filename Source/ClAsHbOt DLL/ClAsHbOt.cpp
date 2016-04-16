// ImageMatch.cpp : Defines the exported functions for the DLL application.
//
#include "stdafx.h"
#include "Logger.h"
#include "Scraper.h"
#include "OCR.h"
#include "ClAsHbOt.h"

string version("20160415");
string scriptdir("");

bool __stdcall Initialize(char* scriptDir, bool debugGlobal, bool debugOCR)
{
	scriptdir = scriptDir;

	// Setup logger
	logger.reset(new Logger(scriptDir, debugGlobal));

	// Setup GdiPlus and persistent objects
	CGdiPlus::Init();
	scraper.reset(new Scraper(scriptDir));
	ocr.reset(new OCR(scriptDir, debugOCR));

	logger->WriteLog("Initialization complete");
	return true;
}

bool __stdcall FindBestBMP(searchType type, HBITMAP hBmp, double threshold, MATCHPOINTS* matchResult, char* matchedBMP)
{
	matchResult->x = -1;
	matchResult->y = -1;
	matchResult->val = 0;

	return scraper->FindBestBMP(type, hBmp, threshold, matchResult, matchedBMP);
}

bool __stdcall FindAllBMPs(searchType type, HBITMAP hBmp, double threshold, int maxMatch, MATCHPOINTS* matchResults, unsigned int* matchCount)
{
	vector<MATCHPOINTS> matches;

	if (scraper->FindAllBMPs(type, hBmp, threshold, maxMatch, matches))
	{
	
		for (int i = 0; i < (int) matches.size(); i++)
		{
			matchResults[i].x = matches[i].x;
			matchResults[i].y = matches[i].y;
			matchResults[i].val = matches[i].val;
		}

		*matchCount = matches.size();

		return true;
	}
	else
	{
		return false;
	}
}

bool __stdcall LocateSlots(actionType aType, slotType sType, HBITMAP hBmp, double threshold, MATCHPOINTS* matchResults)
{
	vector<MATCHPOINTS> matches;

	if (scraper->LocateSlots(aType, sType, hBmp, threshold, matches))
	{
	
		for (int i = 0; i < (int) matches.size(); i++)
		{
			matchResults[i].x = matches[i].x;
			matchResults[i].y = matches[i].y;
			matchResults[i].val = matches[i].val;
		}

		return true;
	}
	else
	{
		return false;
	}
}

bool __stdcall ScrapeFuzzyText(HBITMAP hBmp, const fontType fontT, const FontRegion fontR, const bool keepSpaces, char* scrapedString)
{
	string s;

	bool r = ocr->ScrapeFuzzyText(hBmp, fontT, fontR, keepSpaces, s);
	sprintf_s(scrapedString, MAXSTRING, s.c_str());

	return r;
}

bool __stdcall ScrapeExactText(HBITMAP hBmp, const fontType fontT, const FontRegion fontR, const bool keepSpaces, char* scrapedString)
{
	string s;
	bool r = ocr->ScrapeExactText(hBmp, fontT, fontR, keepSpaces, s);
	sprintf_s(scrapedString, MAXSTRING, s.c_str());

	return r;
}

void split(const string &s, const char delim, vector<string> &elems)
{
    stringstream ss(s);
    string item;
    while (getline(ss, item, delim)) {
        elems.push_back(item);
    }
}

int GetEncoderClsid(const WCHAR* format, CLSID* pClsid)
{
   UINT  num = 0;          // number of image encoders
   UINT  size = 0;         // size of the image encoder array in bytes

   Gdiplus::ImageCodecInfo* pImageCodecInfo = NULL;

   Gdiplus::GetImageEncodersSize(&num, &size);
   if(size == 0)
      return -1;  // Failure

   pImageCodecInfo = (Gdiplus::ImageCodecInfo*)(malloc(size));
   if(pImageCodecInfo == NULL)
      return -1;  // Failure

   GetImageEncoders(num, size, pImageCodecInfo);

   for(UINT j = 0; j < num; ++j)
   {
      if( wcscmp(pImageCodecInfo[j].MimeType, format) == 0 )
      {
         *pClsid = pImageCodecInfo[j].Clsid;
         free(pImageCodecInfo);
         return j;  // Success
      }    
   }

   free(pImageCodecInfo);
   return -1;  // Failure
}

// Convert a wide Unicode string to an UTF8 string
std::string utf8_encode(const std::wstring &wstr)
{
    if( wstr.empty() ) return std::string();
    int size_needed = WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(), NULL, 0, NULL, NULL);
    std::string strTo( size_needed, 0 );
    WideCharToMultiByte                  (CP_UTF8, 0, &wstr[0], (int)wstr.size(), &strTo[0], size_needed, NULL, NULL);
    return strTo;
}

// Convert an UTF8 string to a wide Unicode String
std::wstring utf8_decode(const std::string &str)
{
    if( str.empty() ) return std::wstring();
    int size_needed = MultiByteToWideChar(CP_UTF8, 0, &str[0], (int)str.size(), NULL, 0);
    std::wstring wstrTo( size_needed, 0 );
    MultiByteToWideChar                  (CP_UTF8, 0, &str[0], (int)str.size(), &wstrTo[0], size_needed);
    return wstrTo;
}
