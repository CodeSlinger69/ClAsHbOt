#include "stdafx.h"
#include "Logger.h"
#include "OCR.h"

shared_ptr<OCR> ocr;

OCR::OCR(const char* scriptDir, const bool dOCR)
	: debugOCR(dOCR)
{
	char s[MAX_PATH];
	sprintf_s(s, MAX_PATH, "%s\\CharMaps.data", scriptDir);
	fontDataPath = s;

	// Read font data
	// Open file
	ifstream f (fontDataPath);
    if (!f.is_open())
	{
		char err[500];
		strerror_s(err, 500, errno);
		char s[500];
		sprintf_s(s, 500, "Error opening %s: %s", fontDataPath.c_str(), err);
		logger->WriteLog(s);
		return;
	}

    // Read the file
	Font newFont;
	bool classInProgress = false;

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
			}
		}

		// New font class
		else if (elems[0].find("Class")!=string::npos)
		{
			// New class in progress
			newFont.maps.clear();
			newFont.maxWidth = 0;

			if (elems[1].find("fontMyStuff")!=string::npos) 
				newFont.fType = fontMyStuff;

			else if (elems[1].find("fontRaidTroopCountUnselected")!=string::npos) 
				newFont.fType = fontRaidTroopCountUnselected;

			else if (elems[1].find("fontRaidTroopCountSelected")!=string::npos) 
				newFont.fType = fontRaidTroopCountSelected;

			else if (elems[1].find("fontRaidLoot")!=string::npos) 
				newFont.fType = fontRaidLoot;

			else if (elems[1].find("fontBarracksStatus")!=string::npos) 
				newFont.fType = fontBarracksStatus;

			else if (elems[1].find("fontBattleEndWinnings")!=string::npos) 
				newFont.fType = fontBattleEndWinnings;

			else if (elems[1].find("fontBattleEndBonus")!=string::npos) 
				newFont.fType = fontBattleEndBonus;

			else if (elems[1].find("fontChat")!=string::npos) 
				newFont.fType = fontChat;
			
			classInProgress = true;
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

	// Handle read error
    if (f.bad())
	{
		char err[500];
		strerror_s(err, 500, errno);
		char s[500];
		sprintf_s(s, 500, "Error reading %s: %s", fontDataPath.c_str(), err);
		logger->WriteLog(s);
	}

	f.close();
}

string OCR::ScrapeFuzzyText(HBITMAP hBmp, const fontType fontT, const Gdiplus::Color colorCenter, const int colorRadius, const bool keepSpaces)
{
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
		return string("");
	}

	//
	// Separate foreground pixels
	//
	Gdiplus::Bitmap* pBitmap = Gdiplus::Bitmap::FromHBITMAP(hBmp, NULL);
	int w = pBitmap->GetWidth();
	int h = pBitmap->GetHeight();

	vector< vector<bool> > pix;
	int left, top, right, bottom;

	GetForegroundPixels(pBitmap, colorCenter, colorRadius, pix, left, top, right, bottom);

	w = right-left+1;
	h = bottom-top+1;

	delete pBitmap;

	// Scan left to right through foreground pixel map to identify individual characters
	string textString("");
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
		vector<int> colValues;
		colValues.resize(fonts[fontIndex].maxWidth);

		if (charStart != -1)
		{
			// Scan through varying sized character, starting at charWidth, down to charWidth/2
			int charWidth = charEnd - charStart + 1;
			for (int testWidth = charWidth; testWidth >= charWidth; testWidth--)  // not needed: charWidth/2
			{
				// Find the first non blank row for this char, starting from the bottom
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

				// Calculate colValues for this test width
				if (debugOCR) 
				{
					char s[500];
					sprintf_s(s, 500, "TestWidth=%d ColValues=", testWidth);
					logger->WriteLog(s, false, false);
				}

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

				if (debugOCR) logger->WriteLog("", false, true);

				// Find a match
				double weight;
				int bestMatchIndex = FindFuzzyCharInArray(fontIndex, colValues, testWidth, weight);

				if (bestMatchIndex!=-1 && weight<1 && weight<bestWeight)
				{
					largestMatchIndex = bestMatchIndex;
					bestWidth = testWidth;
					bestWeight = weight;
				}

				if (debugOCR)
				{
					char s[500];
					sprintf_s(s, 500, "width=%d index=%d weight=%.4f (bestweight=%.4f)", testWidth, bestMatchIndex, weight, bestWeight);
					logger->WriteLog(s, false, true);
				}
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
		logger->WriteLog("-------------------------------------------------------------------------", false, true);
   }

   return textString;
}

// Non fuzzy character matching - only good for chat box right now
/*
Func ScrapeExactText(Const $frame, Const ByRef $charMapArray, Const ByRef $box, Const $maxCharSize, Const $keepSpaces)
   Local $w = $box[2] - $box[0] + 1
   Local $h = $box[3] - $box[1] + 1
   Local $pix[$w][$h]
   Local $pY

   ; Get map of foreground pixels
   GetForegroundPixels($frame, $box, $pix, $pY)

   ; Scan left to right through foreground pixel map to identify individual characters
   Local $textString = ""
   Local $x = 0
   Do
	  Local $charStart = -1, $charEnd = -1

	  ; Find start of char
	  Local $blankCol, $blankColCount = 0
	  Do
		 $blankCol = True
		 For $by = 0 To $pY-1
			If $pix[$x][$by] = 1 Then $blankCol = False
		 Next

		 If $blankCol = True Then
			$x+=1
			$blankColCount+=1

			; add a space if multiple blank columns are detected
			If $blankColCount=3 And StringLen($textString)>0 And $keepSpaces=$eScrapeKeepSpaces Then $textString &= " "
		 EndIf
	  Until $blankCol = False Or $x > $w-1

	  If $blankCol = False Then
		 $charStart = $x
		 $charEnd = $charStart
	  EndIf

	  ; Find end of char
	  If $charStart <> -1 Then
		 $charEnd = ($charStart+$maxCharSize > $w-1) ? $w-1 : $charStart+$maxCharSize
	  EndIf

	  ; Find exact match with greatest width
	  Local $largestMatchIndex=-1
	  If $charStart <> -1 Then
		 Local $testWidth
		 For $testWidth = 1 To $charEnd-$charStart+1
			; Find the first non blank row, starting from the bottom
			Local $cX, $cY, $bottomOfChar = -1
			For $cY = $pY-1 To 0 Step -1
			   For $cX = $charStart To $charStart+$testWidth-1
				  If $pix[$cX][$cY] = 1 Then
					 $bottomOfChar = $cY
					 ExitLoop
				  EndIf
			   Next
			   If $bottomOfChar <> -1 Then ExitLoop
			Next

			; Calculate colValues for this character
			Local $colValues[$testWidth]
			For $cX = $charStart To $charStart+$testWidth-1
			   Local $factor = 1
			   $colValues[$cX-$charStart] = 0
			   For $cY = $bottomOfChar To 0 Step -1
				  $colValues[$cX-$charStart] += ($pix[$cX][$cY] * $factor)
				  $factor*=2
			   Next
			Next

			; Find a match
			Local $bestMatchIndex = FindExactCharInArray($charMapArray, $colValues, $testWidth)
			If $bestMatchIndex <> -1 Then $largestMatchIndex = $bestMatchIndex
		 Next
	  EndIf

	  ; Debug
	  If $gScraperDebug And $charEnd<>-1 Then
		 ConsoleWrite($charStart & " to " & _
						($largestMatchIndex<>-1 ? $charStart+$charMapArray[$largestMatchIndex][1]-1 : $charStart) & ": " & _
						($largestMatchIndex<>-1 ? $charMapArray[$largestMatchIndex][0] : "`" ) & " : ")
		 For $cX = $charStart To ($largestMatchIndex<>-1 ? $charStart+$charMapArray[$largestMatchIndex][1]-1 : $charStart)
			ConsoleWrite($colValues[$cX-$charStart] & ", ")
		 Next
		 ConsoleWrite(@CRLF)
	  EndIf

	  ; Got a match or not?
	  If $largestMatchIndex <> -1 Then
		 $textString &= $charMapArray[$largestMatchIndex][0]
		 $x = $charStart+$charMapArray[$largestMatchIndex][1]
	  ElseIf $charEnd<>-1 Then
		 ;$textString &= "?"
		 $x += 1
	  EndIf

   Until $x > $w-1

   $textString = StringStripWS($textString, $STR_STRIPTRAILING)

   ; Debug
   If $gScraperDebug Then
	  ConsoleWrite("RESULT: " & $textString & @CRLF)
	  ConsoleWrite("-------------------------------------------------------------------------" & @CRLF)
   EndIf

   Return $textString
EndFunc
*/

void OCR::GetForegroundPixels(Gdiplus::Bitmap* pBmp, const Gdiplus::Color cC, const int cR, vector< vector<bool> > &pix, int &left, int &top, int &right, int &bottom)
{
	// Determine actual left/right boundaries of foreground pixels
	left = -1;
	right = -1;
	for (int x = 0; x < (int) pBmp->GetWidth(); x++)
	{
		bool blankCol = true;
		for (int y = 0; y < (int) pBmp->GetHeight(); y++)
		{
			Gdiplus::Color pixelColor;
			pBmp->GetPixel(x, y, &pixelColor);
			if ( InColorSphere(pixelColor, cC, cR) )
			{
				blankCol = false;
				break;
			}
		}
		if (!blankCol && left == -1) left = x;
		if (!blankCol && x > right) right = x;
	}

	// Determine actual top/bottom boundaries of foreground pixels
	top = -1;
	bottom = -1;
	for (int y = 0;  y < (int) pBmp->GetHeight(); y++)
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
		if (!blankRow && top == -1) top = y;
		if (!blankRow && y > bottom) bottom = y;
	}

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
/*
	if (debugOCR)
	{
		char s[500];
		sprintf_s(s, 500, "Best %d %.4f", bestMatch, bestWeightedHD);
		logger->WriteLog(s, false, true);
	}
*/
	return bestMatch;
}


/*
Func FindExactCharInArray(Const ByRef $charMapArray, Const ByRef $nums, Const $count)
   ; Loop through each row in the $charMapArray array
   Local $bestMatch = -1
   For $i = 0 To UBound($charMapArray)-1

	  ; If number of columns match, then check the colvalues
	  If $count = $charMapArray[$i][1] Then

		 ; Loop through each column in the passed in array of numbers
		 Local $c, $match=True
		 For $c = 0 To $count-1
			If $nums[$c] <> $charMapArray[$i][$c+2] Then
			   $match = False
			   ExitLoop
			EndIf
		 Next

		 If $match Then
			$bestMatch = $i
			ExitLoop
		 EndIf
	  EndIf
   Next

   Return $bestMatch
EndFunc
*/

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

vector<string> &OCR::split(const string &s, const char delim, vector<string> &elems) {
    stringstream ss(s);
    string item;
    while (getline(ss, item, delim)) {
        elems.push_back(item);
    }
    return elems;
}
