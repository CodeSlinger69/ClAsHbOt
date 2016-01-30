#pragma once
#include "ImageMatchDLL.h"

class Scraper
{
public:
	Scraper(void);
	~Scraper(void);
	
	void SetDirectories(const char* scriptDir);
	void LoadNeedles(void);
	int FindTownHall(HBITMAP hBmp, const double threshold, MATCHPOINTS* match);
	int FindLootCart(HBITMAP hBmp, const double threshold, MATCHPOINTS* match);
	std::string FindBestStorage(const lootType type, HBITMAP hBmp, const double threshold, MATCHPOINTS* match);
	void FindAllStorages(const lootType type, HBITMAP hBmp, const double threshold, const int maxMatch, std::vector<MATCHPOINTS>* matches);
	void LocateRaidSlots(const slotType type, HBITMAP hBmp, const double threshold, std::vector<MATCHPOINTS>* matches);

private:
	char scriptPath[MAX_PATH];  // no terminating backslash
	char logFilePath[MAX_PATH];
	ULONG_PTR u32_Token;


	static const Point northPoint;
	static const Point eastPoint;
	static const Point westPoint;
	static const Point southPoint;

	static const int townHallBMPCount = 6;
	static const char* townHallBMPs[townHallBMPCount];
	Mat townHalls[townHallBMPCount];

	static const char* lootCartBMPs[1];
	Mat lootCart[1];

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

	Mat FindMatch(Mat haystack, Mat needle);
	double DistanceBetweenTwoPoints(const double x1, const double y1, const double x2, const double y2);
	void WriteLog(const char* text);
};

extern Scraper* scraper;

string type2str(int type);