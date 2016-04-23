#pragma once

enum fontType { fontMyStuff, fontRaidTroopCountUnselected, fontRaidTroopCountSelected, fontRaidLoot, fontBarracksStatus,
				fontBattleEndWinnings, fontBattleEndBonus, fontChat, fontArmyOverviewStatus, fontArmyOverviewTimeRemaining };

struct FontRegion
{
	unsigned int left;
	unsigned int top;
	unsigned int right;
	unsigned int bottom;
	Gdiplus::Color color;
	unsigned int radius;
};

struct CharMap
{
	string s;
	vector<unsigned int> hexVal;
};

struct Font
{
	fontType fType;
	int maxWidth;
	vector<CharMap> maps;
};

class OCR {
public:
	OCR(const char* scriptDir, const bool dOCR);
	bool ScrapeFuzzyText(HBITMAP hBmp, const fontType fontT, const FontRegion fontR, const bool keepSpaces, string& textString);
	bool ScrapeExactText(HBITMAP hBmp, const fontType fontT, const FontRegion fontR, const bool keepSpaces, string& textString);
 
private:
	string fontDataPath;
	bool debugOCR;

	static const int fontTypeCount = 10;
	static const char* fontTypes[fontTypeCount];
	vector<Font> fonts;

	void GetForegroundPixels(Gdiplus::Bitmap* pBmp, const Gdiplus::Color cC, const int cR, vector< vector<bool> > &pix, int &left, int &top, int &right, int &bottom);
	int FindFuzzyCharInArray(const int fontIndex, const vector<int> nums, const int width, double &bestWeightedHD);
	int OCR::FindExactCharInArray(const int fontIndex, const vector<int> nums, const int width);
	int CalcHammingDistance(const int x, const int y);
	int BitCount(const int n);
	bool InColorSphere(const Gdiplus::Color c, const Gdiplus::Color cC, const int cR);
	
};

extern shared_ptr<OCR> ocr;