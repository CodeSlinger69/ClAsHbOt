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
    static void  Init();
    static Mat  ImgRead(const WCHAR* u16_File);
    static void ImgWrite(Mat i_Mat, const WCHAR* u16_File);
    static Mat  CopyBmpToMat(Gdiplus::Bitmap* pi_Bmp);
    static Mat  CopyBmpDataToMat(Gdiplus::BitmapData* pi_Data);
    static Gdiplus::Bitmap* CopyMatToBmp(Mat& i_Mat);

private:
    static CLSID GetEncoderClsid(const WCHAR* u16_File);

    static BOOL mb_InitDone;
};