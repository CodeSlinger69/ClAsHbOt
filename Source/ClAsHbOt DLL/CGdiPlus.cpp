// http://stackoverflow.com/questions/24725155/opencv-tesseract-how-to-replace-libpng-libtiff-etc-with-gdi-bitmap-load-in

#include "stdafx.h"
#include "CGdiPlus.h"

using namespace Gdiplus;

BOOL CGdiPlus::mb_InitDone = false;
ULONG_PTR CGdiPlus::u32_Token = 0;

// Do not call this function in the DLL loader lock!
void CGdiPlus::Init()
{
    if (mb_InitDone)
        return;

    GdiplusStartupInput k_Input;
    if (Ok != GdiplusStartup(&u32_Token, &k_Input, NULL))
        throw L"Error initializing GDI+";

    mb_InitDone = true;
}

void CGdiPlus::Shutdown()
{
    if (mb_InitDone)
        return;

    //GdiplusShutdown(u32_Token);

    mb_InitDone = false;
}

Mat CGdiPlus::CopyBmpToMat(Bitmap* pi_Bmp)
{
    assert(mb_InitDone);

    BitmapData i_Data;
    Gdiplus::Rect k_Rect(0, 0, pi_Bmp->GetWidth(), pi_Bmp->GetHeight());
    if (Ok != pi_Bmp->LockBits(&k_Rect, ImageLockModeRead, pi_Bmp->GetPixelFormat(), &i_Data))
        throw L"Error locking Bitmap.";

    Mat i_Mat = CopyBmpDataToMat(&i_Data);

    pi_Bmp->UnlockBits(&i_Data);
    return i_Mat;
}

Mat CGdiPlus::CopyBmpDataToMat(BitmapData* pi_Data)
{
    assert(mb_InitDone);

    int s32_CvType;
    switch (pi_Data->PixelFormat)
    {
        case PixelFormat1bppIndexed:
        case PixelFormat8bppIndexed:
            // Special case treated separately below
            break;

        case PixelFormat24bppRGB:  // 24 bit
            s32_CvType = CV_8UC3; 
            break;

        case PixelFormat32bppRGB:  // 32 bit
        case PixelFormat32bppARGB: // 32 bit + Alpha channel    
            s32_CvType = CV_8UC4; 
            break; 

        default: 
            throw L"Image format not supported.";
    }

    Mat i_Mat;
    if (pi_Data->PixelFormat == PixelFormat1bppIndexed) // 1 bit (special case)
    {
        i_Mat = Mat(pi_Data->Height, pi_Data->Width, CV_8UC1);

        for (UINT Y=0; Y<pi_Data->Height; Y++)
        {
            BYTE* pu8_Src = (BYTE*)pi_Data->Scan0 + Y * pi_Data->Stride;
            BYTE* pu8_Dst = i_Mat.ptr<BYTE>(Y);

            BYTE u8_Mask = 0x80;
            for (UINT X=0; X<pi_Data->Width; X++)
            {
                pu8_Dst[0] = (pu8_Src[0] & u8_Mask) ? 255 : 0;
                pu8_Dst++;

                u8_Mask >>= 1;
                if (u8_Mask == 0)
                {
                    pu8_Src++;
                    u8_Mask = 0x80;
                }
            }
        }
    }
    else if (pi_Data->PixelFormat == PixelFormat8bppIndexed) // 8 bit gray scale palette (special case)
    {
        i_Mat = Mat(pi_Data->Height, pi_Data->Width, CV_8UC1);

        BYTE* u8_Src = (BYTE*)pi_Data->Scan0;
        BYTE* u8_Dst = i_Mat.data;

        for (UINT R=0; R<pi_Data->Height; R++)
        {
            memcpy(u8_Dst, u8_Src, pi_Data->Width);
            u8_Src += pi_Data->Stride;
            u8_Dst += i_Mat.step;
        }
    }
    else // 24 Bit / 32 Bit
    {
        // Create a Mat pointing to external memory
        Mat i_Ext(pi_Data->Height, pi_Data->Width, s32_CvType, pi_Data->Scan0, pi_Data->Stride);

        // Create a Mat with own memory
        i_Ext.copyTo(i_Mat);
    }
    return i_Mat;
}

std::string CGdiPlus::CVtype2str(const int type) 
{
	string r;

	uchar depth = type & CV_MAT_DEPTH_MASK;
	uchar chans = 1 + (type >> CV_CN_SHIFT);

	switch ( depth ) {
	case CV_8U:  r = "8U"; break;
	case CV_8S:  r = "8S"; break;
	case CV_16U: r = "16U"; break;
	case CV_16S: r = "16S"; break;
	case CV_32S: r = "32S"; break;
	case CV_32F: r = "32F"; break;
	case CV_64F: r = "64F"; break;
	default:     r = "User"; break;
	}

	r += "C";
	r += (chans+'0');

	return r;
}

Mat CGdiPlus::ImgRead(const WCHAR* u16_File)
{
    assert(mb_InitDone);

    Bitmap i_Bmp(u16_File);
    if (!i_Bmp.GetWidth() || !i_Bmp.GetHeight())
        throw L"Error loading image from file.";

    return CopyBmpToMat(&i_Bmp);
}
