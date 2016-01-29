#pragma once

#define MAXSTRING 500
extern char returnString[MAXSTRING];
enum lootType {gold, elix, dark};
struct MATCHPOINTS
{
	int x;
	int y;
	double val;
};

Mat DoMatch(Mat img, Mat templ, int match_method);
CLSID GetEncoderClsid(const WCHAR* format);
Mat ConvertBitmapToMat(Gdiplus::Bitmap *frame);
void PrepareReturnString(const std::vector<MATCHPOINTS> matches);

extern "C" char* __stdcall Initialize(char* scriptDir);
extern "C" char* __stdcall TownHallSearch(char* haystack, double threshold); 
extern "C" char* __stdcall FindBestStorage(char* type, char* haystack, double threshold);
extern "C" char* __stdcall FindAllStorages(char* type, char* haystack, double threshold, int maxMatch);

extern "C" char* __stdcall FindMatch(char* haystack, char* needle); 
extern "C" char* __stdcall FindAllMatches(char* haystack, char* needle, int max_matches, double threshold); 


