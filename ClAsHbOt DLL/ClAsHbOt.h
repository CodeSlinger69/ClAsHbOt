#pragma once
#include "Scraper.h"
#include "OCR.h"

#define MAXSTRING 500
extern char returnString[MAXSTRING];
extern string version;
extern string scriptdir;

void PrepareReturnString(const std::vector<MATCHPOINTS> matches);
void split(const string &s, const char delim, vector<string> &elems);
int GetEncoderClsid(const WCHAR* format, CLSID* pClsid);
std::string utf8_encode(const std::wstring &wstr);
std::wstring utf8_decode(const std::string &str);
BOOL WINAPI CrashRptHandler(LPVOID lpvState);

extern "C" char* __stdcall Initialize(char* scriptDir, bool debugGlobal, bool debugOCR);
extern "C" bool __stdcall FindBestBMP(searchType type, HBITMAP hBmp, double threshold, MATCHPOINTS* matchResult, char* matchedBMP);
extern "C" char* __stdcall FindAllBMPs(searchType type, HBITMAP hBmp, double threshold, int maxMatch);
extern "C" char* __stdcall LocateSlots(actionType aType, slotType sType, HBITMAP hBmp, double threshold);
extern "C" char* __stdcall ScrapeFuzzyText(HBITMAP hBmp, fontType fontT, FontRegion fontR, bool keepSpaces);
extern "C" char* __stdcall ScrapeExactText(HBITMAP hBmp, fontType fontT, FontRegion fontR, bool keepSpaces);
