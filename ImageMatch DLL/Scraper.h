#pragma once
#include "ImageMatchDLL.h"

class Scraper
{
public:
	Scraper(void);
	~Scraper(void);
	
	void SetDirectories(const char* scriptDir);
	void LoadNeedles(void);
	std::string FindBestBMP(const searchType type, HBITMAP hBmp, const double threshold, MATCHPOINTS* match);
	void FindAllBMPs(const searchType type, HBITMAP hBmp, const double threshold, const int maxMatch, std::vector<MATCHPOINTS>* matches);
	void LocateSlots(const actionType aType, const slotType sType, HBITMAP hBmp, const double threshold, std::vector<MATCHPOINTS>* matches);
	void CountBuiltTroops(const troopClass type, HBITMAP hBmp, const double threshold, std::vector<MATCHPOINTS>* matches);

private:
	char scriptPath[MAX_PATH];  // no terminating backslash
	char logFilePath[MAX_PATH];
	ULONG_PTR u32_Token;

	enum troopType {
		troopBarbarian, troopArcher, troopGiant, troopGoblin, troopWallBreaker,
		troopBalloon, troopWizard, troopHealer, troopDragon, troopPekka,
		troopMinion, troopHogRider, troopValkyrie, troopGolem, troopWitch,
		troopLavaHound,
		troopKing, troopQueen, troopWarden };

	static const Point northPoint;
	static const Point eastPoint;
	static const Point westPoint;
	static const Point southPoint;

	static const int townHallBMPCount = 6;
	static const char* townHallBMPs[townHallBMPCount];
	Mat townHalls[townHallBMPCount];

	static const int lootCartBMPCount = 1;
	static const char* lootCartBMPs[lootCartBMPCount];
	Mat lootCarts[lootCartBMPCount];

	static const int clashIconBMPCount = 1;
	static const char* clashIconBMPs[clashIconBMPCount];
	Mat clashIcons[lootCartBMPCount];
		
	static const int playStoreOpenButtonBMPCount = 1;
	static const char* playStoreOpenButtonBMPs[playStoreOpenButtonBMPCount];
	Mat playStoreOpenButtons[lootCartBMPCount];

	static const int donateButtonBMPCount = 1;
	static const char* donateButtonBMPs[donateButtonBMPCount];
	Mat donateButtons[donateButtonBMPCount];

	static const int goldStorageBMPCount = 14;
	static const char* goldStorageBMPs[goldStorageBMPCount];
	Mat goldStorages[goldStorageBMPCount];

	static const int elixStorageBMPCount = 15;
	static const char* elixStorageBMPs[elixStorageBMPCount];
	Mat elixStorages[elixStorageBMPCount];

	static const int darkStorageBMPCount = 16;
	static const char* darkStorageBMPs[darkStorageBMPCount];
	Mat darkStorages[darkStorageBMPCount];

	static const int raidTroopSlotBMPCount = 19;
	static const char* raidTroopSlotBMPs[raidTroopSlotBMPCount];
	Mat raidTroopSlots[raidTroopSlotBMPCount];

	static const int raidSpellSlotBMPCount = 8;
	static const char* raidSpellSlotBMPs[raidSpellSlotBMPCount];
	Mat raidSpellSlots[raidSpellSlotBMPCount];

	static const int armyCampTroopBMPCount = 19;
	static const char* armyCampTroopBMPs[armyCampTroopBMPCount];
	Mat armyCampSlots[armyCampTroopBMPCount];

	static const int barracksTroopSlotBMPCount = 16;
	static const char* barracksTroopSlotBMPs[barracksTroopSlotBMPCount];
	Mat barracksTroopSlots[barracksTroopSlotBMPCount];

	static const int donateTroopSlotBMPCount = 16;
	static const char* donateTroopSlotBMPs[donateTroopSlotBMPCount];
	Mat donateTroopSlots[donateTroopSlotBMPCount];

	static const int donateSpellSlotBMPCount = 3;
	static const char* donateSpellSlotBMPs[donateSpellSlotBMPCount];
	Mat donateSpellSlots[donateSpellSlotBMPCount];

	static const int reloadButtonBMPCount = 4;
	static const char* reloadButtonBMPs[reloadButtonBMPCount];
	Mat reloadButtons[reloadButtonBMPCount];

	static const int collectorBMPCount = 12;
	static const char* collectorBMPs[collectorBMPCount];
	Mat collectors[collectorBMPCount];

	static const int lootBubbleBMPCount = 9;
	static const char* lootBubbleBMPs[lootBubbleBMPCount];
	Mat lootBubbles[lootBubbleBMPCount];

	Mat FindMatch(Mat haystack, Mat needle);
	bool BeachSideOfSWLine(const int x, const int y);
	double DistanceBetweenTwoPoints(const double x1, const double y1, const double x2, const double y2);
	void WriteLog(const char* text);
};

extern Scraper* scraper;

string type2str(int type);