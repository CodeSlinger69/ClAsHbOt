#include "stdafx.h"
#include "Logger.h"
#include "ClAsHbOt.h"
#include "OCR.h"

shared_ptr<OCR> ocr;

OCR::OCR(const char* scriptDir, const bool dOCR)
	: fontDataPath(scriptDir), debugOCR(dOCR)
{
	fontDataPath.append("\\CharMaps.data");

	// Read font data
	// Open file
	ifstream f (fontDataPath);
    if (!f.is_open())
	{
		char err[500];
		strerror_s(err, 500, errno);

		string s("Error opening " + fontDataPath + ": " + err);

		logger->WriteLog(s);
		return;
	}

    // Read the file
	Font newFont;
	bool classInProgress = false;
	string fontTypeInProgress;

	string line;
    while (getline(f, line))
	{
		vector<string> elems;
		split(line, ' ', elems);

		// Comment
		if (line.empty() || elems[0].find("//")!=string::npos)
		{
			if (classInProgress)
			{
				fonts.push_back(newFont);
				classInProgress = false;

				char s[500];
				sprintf_s(s, 500, "Loaded %d font characters for font type %s.", newFont.maps.size(), fontTypeInProgress.c_str());
				logger->WriteLog(s);
			}
		}

		// New font class
		else if (elems[0].find("Class")!=string::npos)
		{
			// New class in progress
			newFont.maps.clear();
			newFont.maxWidth = 0;

			// Find font type
			bool foundFontType = false;
			for (int i = 0; i < fontTypeCount; i++)
			{
				if (elems[1].find(fontTypes[i])!=string::npos)
				{
					newFont.fType = (fontType) i;
					foundFontType = true;
					break;
				}
			}

			if (!foundFontType)
			{
				string s("Font type " + elems[1] + " is unrecognized");
				logger->WriteLog(s);
			}
			else
			{
				classInProgress = true;
				fontTypeInProgress = elems[1];
			}
		}

		// Add char/hexvals to ongoing class definition
		else if (elems.size() > 1)
		{
			CharMap map;
			map.s = elems[0];
			for (unsigned int i=1; i<=elems.size()-1; i++)
				map.hexVal.push_back(atoi(elems[i].c_str()));

			newFont.maps.push_back(map);
			if ((int) elems.size()-1 > newFont.maxWidth)
				newFont.maxWidth = elems.size()-1;
		}
	}

	// Store last font class that was being worked on
	if (classInProgress)
	{
		fonts.push_back(newFont);
		classInProgress = false;
		char s[500];
		sprintf_s(s, 500, "Loaded %d font characters for font type %s.", newFont.maps.size(), fontTypeInProgress.c_str());
		logger->WriteLog(s);
	}

	// Handle read error
    if (f.bad())
	{
		char err[500];
		strerror_s(err, 500, errno);

		string s("Error reading " + fontDataPath + ": " + err);
		logger->WriteLog(s);
	}

	f.close();

	logger->WriteLog("Fonts loaded");
}

bool OCR::ScrapeFuzzyText(HBITMAP hBmp, const fontType fontT, const FontRegion fontR, const bool keepSpaces, string& textString)
{
	textString = "";

	// Get index into font list
	int fontIndex = -1;
	for (unsigned int i = 0; i<fonts.size(); i++)
		if (fonts[i].fType == fontT)
			fontIndex = i;

	if (fontIndex == -1) 
	{
		char s[500];
		sprintf_s(s, 500, "Error finding font record for type: %d", fontT);
		logger->WriteLog(s);
		return false;
	}

	//
	// Separate foreground pixels
	//
	unique_ptr<Gdiplus::Bitmap> pBitmap;
	pBitmap.reset(Gdiplus::Bitmap::FromHBITMAP(hBmp, NULL));

	vector< vector<bool> > pix;
	int left=fontR.left, top=fontR.top, right=fontR.right, bottom=fontR.bottom;

	GetForegroundPixels(pBitmap.get(), fontR.color, fontR.radius, pix, left, top, right, bottom);

	pBitmap.reset();

	int w = right-left+1;
	int h = bottom-top+1;

	// Scan left to right through foreground pixel map to identify individual characters
	int x = 0;
	do
	{
		// Find start of char
		int charStart = -1;
		bool blankCol = true;
		int blankColCount = 0;
		do
		{
			for (int by=0; by<h; by++)
				if (pix[x][by])
					blankCol = false;

			if (blankCol)
			{
				x++;
				blankColCount++;

				// add a space if multiple blank columns are detected
				if (blankColCount==3 && keepSpaces)
					textString.append(" ");
			}
		}
		while (blankCol && x < w);

		if (!blankCol)
			charStart = x;

		// Find end of char
		int charEnd = charStart+1;

		if (charEnd >= w)
			charEnd = w-1;

		else
		{
			bool nonBlankCol;
			do
			{
				nonBlankCol = false;
				for (int by=0; by<h; by++)
					if (pix[charEnd][by])
						nonBlankCol = true;
				
				if (nonBlankCol)
					charEnd++;
			}
			while (nonBlankCol == true && charEnd < w);

			charEnd--;
		}

		if (charEnd-charStart+1 > fonts[fontIndex].maxWidth)
			charEnd = charStart + fonts[fontIndex].maxWidth;

		if (debugOCR) 
		{
			char s[500];
			sprintf_s(s, 500, "Char start/end %d / %d of %d", charStart, charEnd, w-1);
			logger->WriteLog(s, false, true);
		}

		// Find match with greatest width
		int largestMatchIndex=-1;
		int bestWidth = -1;
		double bestWeight = 999.;

		if (charStart != -1)
		{
			int charWidth = charEnd - charStart + 1;

			// Find the first non blank row, starting from the bottom
			int bottomOfChar = -1;
			for (int cY = h-1; cY >= 0; cY--)
			{
				for (int cX = 0; cX < charWidth; cX++)
				{
					if (pix[charStart+cX][cY])
					{
						bottomOfChar = cY;
						break;
					}
				}
				if (bottomOfChar != -1)
					break;
			}

			// Calculate colValues
			if (debugOCR) 
			{
				char s[500];
				sprintf_s(s, 500, "charWidth=%d ColValues=", charWidth);
				logger->WriteLog(s, false, false);
			}

			vector<int> colValues;
			colValues.resize(charWidth);
			for (int cX = 0; cX < charWidth; cX++)
			{
				int powerof2 = 1;
				colValues[cX] = 0;
				for (int cY = bottomOfChar; cY >= 0; cY--)
				{
					if (pix[charStart+cX][cY])
						colValues[cX] += powerof2;
					powerof2 *= 2;
				}

				if (debugOCR)
				{
					char s[500];
					sprintf_s(s, 500, "%d ", colValues[cX]);
					logger->WriteLog(s, false, false);
				}
			}

			if (debugOCR) logger->WriteLog("", false, true);

			// Find a match
			double weight;
			int bestMatchIndex = FindFuzzyCharInArray(fontIndex, colValues, charWidth, weight);

			if (bestMatchIndex!=-1 && weight<1 && weight<bestWeight)
			{
				largestMatchIndex = bestMatchIndex;
				bestWidth = charWidth;
				bestWeight = weight;
			}

			if (debugOCR)
			{
				char s[500];
				sprintf_s(s, 500, "width=%d index=%d weight=%.4f (bestweight=%.4f)", charWidth, bestMatchIndex, weight, bestWeight);
				logger->WriteLog(s, false, true);
			}
		}

		// Debug
		if (debugOCR && charEnd != -1)
		{
			char s[500];
			sprintf_s(s, 500, "%d to %d: %s", charStart, charStart+bestWidth-1, largestMatchIndex!=-1 ? fonts[fontIndex].maps[largestMatchIndex].s.c_str() : "`");
			logger->WriteLog(s, false, true);
		}

		// Got a match or not?
		if (largestMatchIndex != -1)
		{
			textString += fonts[fontIndex].maps[largestMatchIndex].s;
			x = charStart + bestWidth;
		}
		else if (charEnd != -1)
		{
			//textString += "?"
			x++;
		}
	}
	while (x < w);

	if (debugOCR)
	{
		char s[500];
		sprintf_s(s, 500, "RESULT: %s", textString.c_str());
		logger->WriteLog(s, false, true);
		logger->WriteLog("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", false, true);
	}

	return true;
}

// Non fuzzy character matching - only good for chat box right now
bool OCR::ScrapeExactText(HBITMAP hBmp, const fontType fontT, const FontRegion fontR, const bool keepSpaces, string& textString)
{
	textString = "";

	// Get index into font list
	int fontIndex = -1;
	for (unsigned int i = 0; i<fonts.size(); i++)
		if (fonts[i].fType == fontT)
			fontIndex = i;

	if (fontIndex == -1) 
	{
		char s[500];
		sprintf_s(s, 500, "Error finding font record for type: %d", fontT);
		logger->WriteLog(s);
		return false;
	}

	//
	// Separate foreground pixels
	//
	unique_ptr<Gdiplus::Bitmap> pBitmap;
	pBitmap.reset(Gdiplus::Bitmap::FromHBITMAP(hBmp, NULL));

	vector< vector<bool> > pix;
	int left=fontR.left, top=fontR.top, right=fontR.right, bottom=fontR.bottom;

	GetForegroundPixels(pBitmap.get(), fontR.color, fontR.radius, pix, left, top, right, bottom);

	pBitmap.reset();

	int w = right-left+1;
	int h = bottom-top+1;

	// Scan left to right through foreground pixel map to identify individual characters
	int x = 0;
	do
	{
	   	// Find start of char
		int charStart = -1;
		bool blankCol = true;
		int blankColCount = 0;
		do
		{
			for (int by=0; by<h; by++)
				if (pix[x][by])
					blankCol = false;

			if (blankCol)
			{
				x++;
				blankColCount++;

				// add a space if multiple blank columns are detected
				if (blankColCount==3 && keepSpaces)
					textString.append(" ");
			}
		}
		while (blankCol && x < w);

		if (!blankCol)
			charStart = x;

		// Find end of char
		int charEnd = -1;
		if (charStart != -1)
			charEnd = (charStart + fonts[fontIndex].maxWidth > w-1) ? w-1 : charStart + fonts[fontIndex].maxWidth;

		// Find exact match with greatest width
		int largestMatchIndex = -1;
		vector<int> colValues;
		if (charStart != -1)
		{
			for (int testWidth = 1; testWidth <= charEnd-charStart+1; testWidth++)
			{
				// Find the first non blank row, starting from the bottom
				int bottomOfChar = -1;
				for (int cY = h-1; cY >= 0; cY--)
				{
					for (int cX = 0; cX < testWidth; cX++)
					{
						if (pix[charStart+cX][cY])
						{
							bottomOfChar = cY;
							break;
						}
					}
					if (bottomOfChar != -1)
						break;
				}

				// Calculate colValues for this character
				colValues.resize(testWidth);
				for (int cX = 0; cX < testWidth; cX++)
				{
					int powerof2 = 1;
					colValues[cX] = 0;
					for (int cY = bottomOfChar; cY >= 0; cY--)
					{
						if (pix[charStart+cX][cY])
							colValues[cX] += powerof2;
						powerof2 *= 2;
					}

					if (debugOCR)
					{
						char s[500];
						sprintf_s(s, 500, "%d ", colValues[cX]);
						logger->WriteLog(s, false, false);
					}
				}

				// Find a match
				int bestMatchIndex = FindExactCharInArray(fontIndex, colValues, testWidth);
				if (bestMatchIndex != -1)
					largestMatchIndex = bestMatchIndex;
			}
		}

		int largestSize = largestMatchIndex != -1 ? fonts[fontIndex].maps[largestMatchIndex].hexVal.size() : 0;

		// Debug
		if (debugOCR && charEnd != -1)
		{
			char s[500];
			sprintf_s(s, 500, "%d to %d: %s", charStart, charStart+largestSize-1, largestMatchIndex!=-1 ? fonts[fontIndex].maps[largestMatchIndex].s.c_str() : "`");
			logger->WriteLog(s, false, true);

			for (int cX = charStart; cX <= (largestMatchIndex!=-1 ? charStart+largestSize-1 : charStart); cX++)
			{
				sprintf_s(s, 500, "%d ", colValues[cX-charStart]);
				logger->WriteLog(s, false, false);
			}
			logger->WriteLog("", false, true);
		}

		// Got a match or not?
		if (largestMatchIndex != -1)
		{
			textString += fonts[fontIndex].maps[largestMatchIndex].s;
			x = charStart + largestSize;
		}
		else if (charEnd != -1)
		{
			//textString += "?"
			x++;
		}
	}
	while (x < w);

	if (debugOCR)
	{
		char s[500];
		sprintf_s(s, 500, "RESULT: %s", textString.c_str());
		logger->WriteLog(s, false, true);
		logger->WriteLog("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", false, true);
	}

	return true;
}


void OCR::GetForegroundPixels(Gdiplus::Bitmap* pBmp, const Gdiplus::Color cC, const int cR, vector< vector<bool> > &pix, int &left, int &top, int &right, int &bottom)
{
	// Determine actual left/right boundaries of foreground pixels
	int actualLeft = -1;
	int actualRight = -1;
	for (int x = left; x <= right; x++)
	{
		bool blankCol = true;
		for (int y = top; y <= bottom; y++)
		{
			Gdiplus::Color pixelColor;
			pBmp->GetPixel(x, y, &pixelColor);
			if ( InColorSphere(pixelColor, cC, cR) )
			{
				blankCol = false;
				break;
			}
		}
		if (!blankCol && actualLeft == -1) actualLeft = x;
		if (!blankCol && x > actualRight) actualRight = x;
	}

	left = actualLeft;
	right = actualRight;

	// Determine actual top/bottom boundaries of foreground pixels
	int actualTop = -1;
	int actualBottom = -1;
	for (int y = top;  y <= bottom; y++)
	{
		bool blankRow = true;
		for (int x = left; x <= right; x++)
		{
			Gdiplus::Color pixelColor;
			pBmp->GetPixel(x, y, &pixelColor);
			if ( InColorSphere(pixelColor, cC, cR) )
			{
				blankRow = false;
				break;
			}
		}
		if (!blankRow && actualTop == -1) actualTop = y;
		if (!blankRow && y > actualBottom) actualBottom = y;
	}

	top = actualTop;
	bottom = actualBottom;

	// Resize the 2D vector
	for (int x = 0; x <= right-left+1; x++)
	{
		vector<bool> col;
		col.resize(bottom-top+1);
		pix.push_back(col);
	}

	// Fill the vector
	for (int y = top; y <= bottom; y++)
	{
		for (int x = left; x <= right; x++)
		{
			Gdiplus::Color pixelColor;
			pBmp->GetPixel(x, y, &pixelColor);
			pix[x-left][y-top] = InColorSphere(pixelColor, cC, cR);
		}
	}

	if (debugOCR)
	{
		for (int i=left; i<=right; i++)
			logger->WriteLog("-", false, false);
		logger->WriteLog("", false, true);

		int w = right-left+1;
		int h = bottom-top+1;

		for (int y = 0; y < h; y++)
		{
			for (int x = 0; x < w; x++)
			{
				if (pix[x][y])
					logger->WriteLog("x", false, false);
				else
					logger->WriteLog(" ", false, false);
			}
			logger->WriteLog("", false, true);
		}

		for (int i=left; i<=right; i++)
			logger->WriteLog("-", false, false);
		logger->WriteLog("", false, true);

	}
}

int OCR::FindFuzzyCharInArray(const int fontIndex, const vector<int> nums, const int width, double &bestWeightedHD)
{
	// Loop through each row in the maps vector for this font
	int bestMatch = -1;
	bestWeightedHD = 9999.;

	for (int i = 0; i < (int) fonts[fontIndex].maps.size(); i++)
	{
		int sizeOfThisChar = fonts[fontIndex].maps[i].hexVal.size();

		if (sizeOfThisChar >= width-1 && sizeOfThisChar <= width+1)
		{
			// Loop through each column in the passed in array of numbers
			int totalHD = 0;
			int pixels = 0;
			for (int c = 0; c < (width < sizeOfThisChar ? width : sizeOfThisChar); c++)
			{
				totalHD += CalcHammingDistance(nums[c], fonts[fontIndex].maps[i].hexVal[c]);
				pixels += BitCount(nums[c]);
			}

			double weightedHD = (double) totalHD / (double) pixels;

			if (weightedHD < bestWeightedHD)
			{
				bestWeightedHD = weightedHD;
				bestMatch = i;
			}
		}
	}

	return bestMatch;
}

int OCR::FindExactCharInArray(const int fontIndex, const vector<int> nums, const int width)
{
	int bestMatch = -1;

	// Loop through each row in the $charMapArray array
	for (int i = 0; i < (int) fonts[fontIndex].maps.size(); i++)
	{
		// If number of columns match, then check the colvalues
		if (width == fonts[fontIndex].maps[i].hexVal.size())
		{
			// Loop through each column in the passed in array of numbers
			bool match=true;
			for (int c = 0; c < width; c++)
			{
				if (nums[c] != fonts[fontIndex].maps[i].hexVal[c])
				{
					match = false;
					break;
				}
			}

			if (match)
			{
				bestMatch = i;
				break;
			}
		}
	}

	return bestMatch;
}

int OCR::CalcHammingDistance(const int x, const int y)
{
	int dist = 0;
	int val = x ^ y;

	while (val != 0)
	{
		dist++;
		val = val & val-1;
	}
	
	return dist;
}

int OCR::BitCount(const int n)
{
	int c = 0;
	int nP = n;

	while (nP != 0)
	{
		c++;
		nP = nP & nP-1;
	}

	return c;
}

bool OCR::InColorSphere(const Gdiplus::Color c, const Gdiplus::Color cC, const int cR)
{
	double rDiff = pow((double) cC.GetR() - (double) c.GetR(), 2);
	double gDiff = pow((double) cC.GetG() - (double) c.GetG(), 2);
	double bDiff = pow((double) cC.GetB() - (double) c.GetB(), 2);

	double dist = sqrt(rDiff + gDiff + bDiff);

	return dist < cR;
}

const char* OCR::fontTypes[fontTypeCount] = { 
	"MyStuff", "RaidTroopCountUnselected", "RaidTroopCountSelected", "RaidLoot", "BarracksStatus",
	"BattleEndWinnings", "BattleEndBonus", "Chat", "ArmyOverviewStatus" };