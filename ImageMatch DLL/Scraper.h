#pragma once

enum imageType { townHall, lootCart, clashIcon, playStoreOpenButton, donateButton, goldStorage, elixStorage, darkStorage, raidTroopSlot, 
				 raidSpellSlot, armyCampTroop, barracksTroopSlot, donateTroopSlot, donateSpellSlot, reloadButton, collector, lootBubble };
enum searchType { searchTownHall, searchLootCart, searchClashIcon, searchPlayStoreOpenButton, searchDonateButton, 
				  searchGoldStorage, searchElixStorage, searchDarkStorage, searchLootCollector, searchLootBubble };
enum actionType { actionRaid, actionDonate, actionBarracks, actionCamp, actionReloadButton };
enum slotType { slotTroop, slotSpell, slotHero };
enum troopClass { troopClassNormal, troopClassHero };
enum troopType {
	troopBarbarian, troopArcher, troopGiant, troopGoblin, troopWallBreaker,
	troopBalloon, troopWizard, troopHealer, troopDragon, troopPekka,
	troopMinion, troopHogRider, troopValkyrie, troopGolem, troopWitch,
	troopLavaHound,
	troopKing, troopQueen, troopWarden };

struct MATCHPOINTS
{
	int x;
	int y;
	double val;
};

struct ImageGroup
{
	imageType iType;
	vector<string> imagePaths;
	vector<Mat> mats;
};

class Scraper {
public:
	Scraper(const char* scriptDir);
	std::string FindBestBMP(const searchType type, HBITMAP hBmp, const double threshold, MATCHPOINTS &match);
	void FindAllBMPs(const searchType type, HBITMAP hBmp, const double threshold, const int maxMatch, std::vector<MATCHPOINTS> &matches);
	void LocateSlots(const actionType aType, const slotType sType, HBITMAP hBmp, const double threshold, std::vector<MATCHPOINTS> &matches);

private:
	string imageDataPath;
	char scriptPath[MAX_PATH];  // no terminating backslash

	static const int imageClassCount = 17;
	static const char* imageClasses[imageClassCount];
	vector<ImageGroup> imageGroups;

	static const Point northPoint;
	static const Point eastPoint;
	static const Point westPoint;
	static const Point southPoint;

	Mat FindMatch(Mat haystack, Mat needle);
	bool BeachSideOfSWLine(const int x, const int y);
	double DistanceBetweenTwoPoints(const double x1, const double y1, const double x2, const double y2);
};

extern shared_ptr<Scraper> scraper;