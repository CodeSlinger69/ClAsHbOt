// ImageMatch.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"
#include <gdiplus.h>
#pragma comment(lib, "gdiplus.lib")
#include "opencv2/opencv.hpp"
#include "opencv2/imgproc/imgproc.hpp"
///* Debug
//#include "opencv2/highgui/highgui.hpp"
using namespace cv;
#include "ImageMatchDLL.h"

char* __stdcall FindMatch(char *haystack, char *needle, int match_method)
{
	Mat img = imread(haystack);
	Mat templ = imread(needle);
	Mat result = DoMatch(img, templ, match_method);
	
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

	// For SQDIFF and SQDIFF_NORMED, the best matches are lower values. For all the other methods, the higher the better
	Point matchLoc = (match_method  == CV_TM_SQDIFF || match_method == CV_TM_SQDIFF_NORMED) ? minLoc : maxLoc; 
	double matchVal = (match_method  == CV_TM_SQDIFF || match_method == CV_TM_SQDIFF_NORMED) ? minVal : maxVal;
	//int x = matchLoc.x + templ.cols/2; // for midpoint
	//int y = matchLoc.y + templ.rows/2;
	int x = matchLoc.x;
	int y = matchLoc.y;

	/*// Debug
	rectangle( img_display, matchLoc, Point( matchLoc.x + templ.cols , matchLoc.y + templ.rows ), Scalar(0,0xff,0), 2, 8, 0 );
	imshow( image_window, img_display );
	waitKey(0);
	*/

	sprintf_s(returnString, MAXSTRING, "%d|%d|%.4f", x, y, matchVal);
	//MessageBox(NULL, returnString, "FindMatch End", MB_OK);
	
	return returnString;
}

char* __stdcall FindAllMatches(char *haystack, char *needle, int match_method, int max_matches, double threshold)
{
	Mat img = imread(haystack);
	Mat templ = imread(needle);
	Mat result = DoMatch(img, templ, match_method);

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

		// For SQDIFF and SQDIFF_NORMED, the best matches are lower values. For all the other methods, the higher the better
		double matchVal = (match_method==CV_TM_SQDIFF || match_method==CV_TM_SQDIFF_NORMED) ? minVal : maxVal;

		if ( ((match_method==CV_TM_SQDIFF || match_method==CV_TM_SQDIFF_NORMED) && matchVal <= threshold) ||
			 (match_method!=CV_TM_SQDIFF && match_method!=CV_TM_SQDIFF_NORMED && matchVal >= threshold) )
		{
			Point matchLoc = (match_method==CV_TM_SQDIFF || match_method==CV_TM_SQDIFF_NORMED) ? minLoc : maxLoc; 

			// Fill haystack with pure green so we don't match this same location
			rectangle(img, matchLoc, cv::Point(matchLoc.x + templ.cols, matchLoc.y + templ.rows),
							CV_RGB(0,255,0), 2);

			// Fill results array with hi or lo vals, so we don't match this same location
			Scalar fillVal = (match_method==CV_TM_SQDIFF || match_method==CV_TM_SQDIFF_NORMED) ? 1 : 0;
			floodFill(result, matchLoc, fillVal, 0, Scalar(0.1), Scalar(1.0));

			// Add matched location to the vector
			//matches[count].x = matchLoc.x + templ.cols/2; // for midpoint
			//matches[count].y = matchLoc.y + templ.rows/2;
			matches[count].x = matchLoc.x;
			matches[count].y = matchLoc.y;
			matches[count].val = matchVal;
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