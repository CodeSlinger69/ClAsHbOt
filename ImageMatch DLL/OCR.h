#pragma once

enum fontType { fontMyStuff, fontRaidTroopCountUnselected, fontRaidTroopCountSelected, fontRaidLoot, fontBarracksStatus,
				fontBattleEndWinnings, fontBattleEndBonus, fontChat };

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
	string ScrapeFuzzyText(HBITMAP hBmp, const fontType fontT, const Gdiplus::Color foregroundColor, const int colorRadius, const bool keepSpaces);
 
private:
	string fontDataPath;
	bool debugOCR;
	vector<Font> fonts;

	void GetForegroundPixels(Gdiplus::Bitmap* pBmp, const Gdiplus::Color cC, const int cR, vector< vector<bool> > &pix, int &left, int &top, int &right, int &bottom);
	int FindFuzzyCharInArray(const int fontIndex, const vector<int> nums, const int width, double &bestWeightedHD);
	int CalcHammingDistance(const int x, const int y);
	int BitCount(const int n);
	bool InColorSphere(const Gdiplus::Color c, const Gdiplus::Color cC, const int cR);
	vector<string> &split(const string &s, const char delim, vector<string> &elems);

	//static fontInfo fonts;

	static const int myStuffN = 10;
	static const string myStuffChars[myStuffN];
	static const int myStuffMaxWidth = 10;
	static const int myStuffMap[myStuffN][myStuffMaxWidth+1];
	//static const vector<int> myStuffMap[];

	static const int raidTroopCountUnselectedN = 11;
	static const char* raidTroopCountUnselectedChars[raidTroopCountUnselectedN];
	static const int raidTroopCountUnselectedMaxWidth = 12;
	static const int raidTroopCountUnselectedMap[raidTroopCountUnselectedN][raidTroopCountUnselectedMaxWidth+1];

	static const int raidTroopCountSelectedN = 11;
	static const char* raidTroopCountSelectedChars[raidTroopCountSelectedN];
	static const int raidTroopCountSelectedMaxWidth = 12;
	static const int raidTroopCountSelectedMap[raidTroopCountSelectedN][raidTroopCountSelectedMaxWidth+1];

	static const int raidLootN = 10;
	static const char* raidLootChars[raidLootN];
	static const int raidLootMaxWidth = 11;
	static const int raidLootMap[raidLootN][raidLootMaxWidth+1];

	static const int barracksStatusN = 22;
	static const char* barracksStatusChars[barracksStatusN];
	static const int barracksStatusMaxWidth = 14;
	static const int barracksStatusMap[barracksStatusN][barracksStatusMaxWidth+1];

	static const int battleEndWinningsN = 12;
	static const char* battleEndWinningsChars[battleEndWinningsN];
	static const int battleEndWinningsMaxWidth = 28;
	static const int battleEndWinningsMap[battleEndWinningsN][battleEndWinningsMaxWidth+1];

	static const int battleEndBonusN = 12;
	static const char* battleEndBonusChars[battleEndBonusN];
	static const int battleEndBonusMaxWidth = 11;
	static const int battleEndBonusMap[battleEndBonusN][battleEndBonusMaxWidth+1];

	static const int chatN = 60;
	static const char* chatChars[chatN];
	static const int chatMaxWidth = 11;
	static const int chatMap[chatN][chatMaxWidth+1];

};

extern shared_ptr<OCR> ocr;