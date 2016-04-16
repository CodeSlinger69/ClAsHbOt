// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//

#pragma once

#include "targetver.h"

//#define WIN32_LEAN_AND_MEAN             // Exclude rarely-used stuff from Windows headers
// Windows Header Files:
#include <windows.h>

// TODO: reference additional headers your program requires here

#include <ctime>
#include <vector>
#include <fstream>

#include <gdiplus.h>
#pragma comment(lib, "gdiplus.lib")
#include "opencv2/opencv.hpp"
#include "opencv2/imgproc/imgproc.hpp"
//#include "opencv2/highgui/highgui.hpp" // debugging

#include "CGdiPlus.h"

using namespace cv;
using namespace std;
