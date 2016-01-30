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

char* __stdcall FindTownHall(HBITMAP hBmp, double threshold)
{
	MATCHPOINTS match;
	int thLevel = scraper->FindTownHall(hBmp, threshold, &match);
	
	sprintf_s(returnString, MAXSTRING, "%d|%d|%d|%.4f", thLevel, match.x, match.y, match.val);
	return returnString;
}

char* __stdcall FindLootCart(HBITMAP hBmp, double threshold)
{
	MATCHPOINTS match;
	scraper->FindLootCart(hBmp, threshold, &match);
	
	sprintf_s(returnString, MAXSTRING, "%d|%d|%.4f", match.x, match.y, match.val);
	return returnString;
}

char* __stdcall FindBestStorage(lootType type, HBITMAP hBmp, double threshold)
{
	MATCHPOINTS match;
	std::string matchedString;

	matchedString = scraper->FindBestStorage(type, hBmp, threshold, &match);

	if (matchedString.length() > 0)
		sprintf_s(returnString, MAXSTRING, "%s|%d|%d|%.4f", matchedString.c_str(), match.x, match.y, match.val);
	else
		sprintf_s(returnString, MAXSTRING, "%s|%d|%d|%.4f", "", -1, -1, 0);

	return returnString;
}

char* __stdcall FindAllStorages(lootType type, HBITMAP hBmp, double threshold, int maxMatch)
{
	std::vector<MATCHPOINTS> matches;

	scraper->FindAllStorages(type, hBmp, threshold, maxMatch, &matches);
	PrepareReturnString(matches);

	return returnString;
}

char* __stdcall LocateRaidSlots(slotType type, HBITMAP hBmp, double threshold)
{
	std::vector<MATCHPOINTS> matches;

	scraper->LocateRaidSlots(type, hBmp, threshold, &matches);
	PrepareReturnString(matches);

	return returnString;
}

char* __stdcall FindMatch(char* haystack, char* needle)
{
	//Mat img = ConvertBitmapToMat(frame);
	Mat img = imread(haystack);
	Mat templ = imread(needle);
	Mat result = DoMatch(img, templ, CV_TM_CCORR_NORMED);
	
	/*// Debug
	char* image_window = "Source Image";	
	namedWindow( image_window, CV_WINDOW_AUTOSIZE );
	Mat img_display;
	img.copyTo( img_display );
	*/
	
	// Localize the best match with minMaxLoc
	double minVal, maxVal;
	Point minLoc, maxLoc;
	minMaxLoc( result, &minVal, &maxVal, &minLoc, &maxLoc, Mat() );

	/*// Debug
	rectangle( img_display, maxLoc, Point( maxLoc.x + templ.cols , maxLoc.y + templ.rows ), Scalar(0,0xff,0), 2, 8, 0 );
	imshow( image_window, img_display );
	waitKey(0);
	*/

	sprintf_s(returnString, MAXSTRING, "%d|%d|%.4f", maxLoc.x, maxLoc.y, maxVal);
	return returnString;
}

char* __stdcall FindAllMatches(char* haystack, char* needle, int max_matches, double threshold)
{
	//Mat img = ConvertBitmapToMat(frame);
	Mat img = imread(haystack);
	Mat templ = imread(needle);
	Mat result = DoMatch(img, templ, CV_TM_CCORR_NORMED);

	int count = 0;
	struct MATCHPOINTS {
		int x;
		int y;
		double val;
	};
	MATCHPOINTS *matches = new MATCHPOINTS[max_matches];

	while (count < max_matches)
	{
		double minVal, maxVal;
		Point minLoc, maxLoc;
		minMaxLoc(result, &minVal, &maxVal, &minLoc, &maxLoc);

		if (maxVal>=threshold)
		{
			// Fill haystack with pure green so we don't match this same location
			rectangle(img, maxLoc, cv::Point(maxLoc.x + templ.cols, maxLoc.y + templ.rows), CV_RGB(0,255,0), 2);

			// Fill results array with lo vals, so we don't match this same location
			floodFill(result, maxLoc, 0, 0, Scalar(0.1), Scalar(1.0));

			// Add matched location to the vector
			matches[count].x = maxLoc.x;
			matches[count].y = maxLoc.y;
			matches[count].val = maxVal;
			count++;
		}
		else
		{
			break;
		}
	}

	sprintf_s(returnString, MAXSTRING, "%d", count);
	for (int i = 0; i<count; i++)
	{
		char curMatch[MAXSTRING];
		sprintf_s(curMatch, MAXSTRING, "|%d|%d|%.4f", matches[i].x, matches[i].y, matches[i].val);
		strcat_s(returnString, MAXSTRING, curMatch);
	}

	delete [] matches;

	return returnString;
}

Mat DoMatch(Mat img, Mat templ, int match_method)
{
	Mat result;

	// Create the result matrix
	int result_cols =  img.cols - templ.cols + 1;
	int result_rows = img.rows - templ.rows + 1;

	result.create( result_cols, result_rows, CV_32FC1 );

	// Do the Matching and Normalize
	//  Method = 0: CV_TM_SQDIFF, 1: CV_TM_SQDIFF_NORMED 2: CV_TM_CCORR 3: CV_TM_CCORR_NORMED 4: CV_TM_CCOEFF 5: CV_TM_CCOEFF_NORMED
	//match_method = CV_TM_CCOEFF_NORMED;
	matchTemplate(img, templ, result, match_method );
	threshold(result, result, 0.9, 1.0, CV_THRESH_TOZERO);
	//normalize( result, result, 1, 100, NORM_MINMAX, -1, Mat() );

	return result;
}

CLSID GetEncoderClsid(const WCHAR* format)
{
	UINT  num = 0;          // number of image encoders
	UINT  size = 0;         // size of the image encoder array in bytes

	Gdiplus::ImageCodecInfo* pImageCodecInfo = NULL;

	Gdiplus::GetImageEncodersSize(&num, &size);
	if (size == 0)
		return CLSID();  // Failure

	pImageCodecInfo = (Gdiplus::ImageCodecInfo*)(malloc(size));
	if (pImageCodecInfo == NULL)
		return CLSID();  // Failure

	Gdiplus::GetImageEncoders(num, size, pImageCodecInfo);

	for (UINT j = 0; j < num; ++j)
	{
		if (wcscmp(pImageCodecInfo[j].MimeType, format) == 0)
		{
			CLSID clsid = pImageCodecInfo[j].Clsid;
			free(pImageCodecInfo);
			return clsid;  // Success
		}
	}

	free(pImageCodecInfo);
	return CLSID();
}

Mat ConvertBitmapToMat(Gdiplus::Bitmap *frame)
{
	CLSID clsid = GetEncoderClsid(L"image/bmp");
	frame->Save(L"c:\\temp.bmp", &clsid);
	Mat m = imread("c:\\temp.bmp");

	return m;
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
		sprintf_s(returnString, MAXSTRING, "%d|%d|%d|%.4f", 0, -1, -1, 0);
	}
}
