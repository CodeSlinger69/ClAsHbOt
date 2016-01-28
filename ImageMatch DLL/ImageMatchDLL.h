#pragma once

#define MAXSTRING 500
char returnString[MAXSTRING];
Mat DoMatch(Mat img, Mat templ, int match_method);
CLSID GetEncoderClsid(const WCHAR* format);
Mat ConvertBitmapToMat(Gdiplus::Bitmap *frame);

extern "C" char* __stdcall Initialize(char* scriptDir);
extern "C" char* __stdcall TownHallSearch(char* haystack); 
extern "C" char* __stdcall FindBestStorage(char* type, char* haystack, double threshold);
extern "C" char* __stdcall FindAllStorages(char* type, char* haystack, double threshold, int maxMatch);
extern "C" char* __stdcall FindMatch(char* haystack, char* needle); 
extern "C" char* __stdcall FindAllMatches(char* haystack, char* needle, int max_matches, double threshold); 


