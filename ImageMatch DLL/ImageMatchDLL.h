#pragma once

#define MAXSTRING 500
char returnString[MAXSTRING];
Mat DoMatch(Mat img, Mat templ, int match_method);

extern "C" char* __stdcall FindMatch(char *haystack, char *needle, int match_method); 
extern "C" char* __stdcall FindAllMatches(char *haystack, char *needle, int match_method, int max_matches, double threshold); 


