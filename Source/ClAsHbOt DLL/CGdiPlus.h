// http://stackoverflow.com/questions/24725155/opencv-tesseract-how-to-replace-libpng-libtiff-etc-with-gdi-bitmap-load-in

#pragma once

#include <gdiplus.h>
#pragma comment(lib, "gdiplus.lib")

// IMPORTANT:
// This must be included AFTER gdiplus !!
// (OpenCV #undefine's min(), max())
#include "opencv2/core/core.hpp"
#include "opencv2/highgui/highgui.hpp"

using namespace cv;

class CGdiPlus
{
public:
    static void Init();
	static void Shutdown();
    static Mat ImgRead(const WCHAR* u16_File);
    static Mat CopyBmpToMat(Gdiplus::Bitmap* pi_Bmp);
    static Mat CopyBmpDataToMat(Gdiplus::BitmapData* pi_Data);
	static std::string CVtype2str(const int type);

private:
	static ULONG_PTR u32_Token;
    static BOOL mb_InitDone;
};
