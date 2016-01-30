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

Bitmap* CGdiPlus::CopyMatToBmp(Mat& i_Mat)
{
    assert(mb_InitDone);

    PixelFormat e_Format;
    switch (i_Mat.channels())
    {
        case 1: e_Format = PixelFormat8bppIndexed; break;
        case 3: e_Format = PixelFormat24bppRGB;    break;
        case 4: e_Format = PixelFormat32bppARGB;   break;
        default: throw L"Image format not supported.";
    }

    // Create Bitmap with own memory
    Bitmap* pi_Bmp = new Bitmap(i_Mat.cols, i_Mat.rows, e_Format);

    BitmapData i_Data;
    Gdiplus::Rect k_Rect(0, 0, i_Mat.cols, i_Mat.rows);
    if (Ok != pi_Bmp->LockBits(&k_Rect, ImageLockModeWrite, e_Format, &i_Data))
    {
        delete pi_Bmp;
        throw L"Error locking Bitmap.";
    }

    if (i_Mat.elemSize1() == 1) // 1 Byte per channel (8 bit gray scale palette)
    {
        BYTE* u8_Src = i_Mat.data;
        BYTE* u8_Dst = (BYTE*)i_Data.Scan0;

        int s32_RowLen = i_Mat.cols * i_Mat.channels(); // != i_Mat.step !!

        // The Windows Bitmap format requires all rows to be DWORD aligned (always!)
        // while OpenCV by default stores bitmap data sequentially.
        for (int R=0; R<i_Mat.rows; R++)
        {
            memcpy(u8_Dst, u8_Src, s32_RowLen);
            u8_Src += i_Mat.step;    // step may be e.g 3729
            u8_Dst += i_Data.Stride; // while Stride is 3732
        }
    }
    else // i_Mat may contain e.g. float data (CV_32F -> 4 Bytes per pixel grayscale)
    {
        int s32_Type;
        switch (i_Mat.channels())
        {
            case 1: s32_Type = CV_8UC1; break;
            case 3: s32_Type = CV_8UC3; break;
            default: throw L"Image format not supported.";
        }

        CvMat i_Dst;
        cvInitMatHeader(&i_Dst, i_Mat.rows, i_Mat.cols, s32_Type, i_Data.Scan0, i_Data.Stride);

        CvMat i_Img = i_Mat;
        cvConvertImage(&i_Img, &i_Dst, 0);
    }

    pi_Bmp->UnlockBits(&i_Data);

    // Add the grayscale palette if required.
    if (e_Format == PixelFormat8bppIndexed)
    {
        std::vector<unsigned char> i_Arr;
		i_Arr.reserve(sizeof(ColorPalette) + 256 * sizeof(ARGB));
		ColorPalette* pk_Palette = (ColorPalette*)i_Arr.data();

        pk_Palette->Count = 256;
        pk_Palette->Flags = PaletteFlagsGrayScale;

        ARGB* pk_Color = &pk_Palette->Entries[0];
        for (int i=0; i<256; i++)
        {
            pk_Color[i] = Color::MakeARGB(255, i, i, i);
        }

        if (Ok != pi_Bmp->SetPalette(pk_Palette))
        {
            delete pi_Bmp;
            throw L"Error setting grayscale palette.";
        }
    }
    return pi_Bmp;
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

void CGdiPlus::ImgWrite(Mat i_Mat, const WCHAR* u16_File)
{
    assert(mb_InitDone);

    CLSID k_Clsid = GetEncoderClsid(u16_File);

    Bitmap* pi_Bmp = CopyMatToBmp(i_Mat);

    Status e_Status = pi_Bmp->Save(u16_File, &k_Clsid);

    delete pi_Bmp;

    if (e_Status != Ok)
        throw L"Error saving image to file.";
}

// Get the class identifier of the image encoder for the given file extension.
// e.g. {557CF406-1A04-11D3-9A73-0000F81EF32E}  for PNG images
CLSID CGdiPlus::GetEncoderClsid(const WCHAR* u16_File)
{
    assert(mb_InitDone);

    UINT u32_Encoders, u32_Size;
    if (Ok != GetImageEncodersSize(&u32_Encoders, &u32_Size))
        throw L"Error obtaining image encoders size";

    std::vector<unsigned char> i_Arr;
	i_Arr.reserve(u32_Size);
    ImageCodecInfo* pi_Info = (ImageCodecInfo*)i_Arr.data();

    if (Ok != GetImageEncoders(u32_Encoders, u32_Size, pi_Info))
        throw L"Error obtaining image encoders";

    std::wstring s_Ext(u16_File);
	int Pos = s_Ext.rfind('.');
    if (Pos < 0)
        throw L"Invalid image filename.";

    // s_Ext = "*.TIF;"
	s_Ext = L"*" + s_Ext.substr(Pos) + L";";

    // Search the file extension
    for (UINT i=0; i<u32_Encoders; i++)
    {
        std::wstring s_Extensions(pi_Info->FilenameExtension);
        s_Extensions += ';';

        // s_Extensions = "*.TIFF;*.TIF;"
        if (s_Extensions.find(s_Ext) >= 0)
            return pi_Info->Clsid;

        pi_Info ++;
    }

    throw L"No image encoder found for file extension " + s_Ext;
}

