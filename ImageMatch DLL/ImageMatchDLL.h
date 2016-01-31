#pragma once

#define MAXSTRING 500
extern char returnString[MAXSTRING];
enum searchType { searchTownHall, searchLootCart, searchClashIcon, searchPlayStoreOpenButton, searchDonateButton, 
				  searchGoldStorage, searchElixStorage, searchDarkStorage, searchLootCollector, searchLootBubble };
enum actionType { actionRaid, actionDonate, actionBarracks, actionReloadButton };
enum slotType { slotTroop, slotSpell };
enum troopClass { troopClassNormal, troopClassHero };

struct MATCHPOINTS
{
	int x;
	int y;
	double val;
};

void PrepareReturnString(const std::vector<MATCHPOINTS> matches);

extern "C" char* __stdcall Initialize(char* scriptDir);
extern "C" char* __stdcall FindBestBMP(searchType type, HBITMAP hBmp, double threshold);
extern "C" char* __stdcall FindAllBMPs(searchType type, HBITMAP hBmp, double threshold, int maxMatch);
extern "C" char* __stdcall LocateSlots(actionType aType, slotType sType, HBITMAP hBmp, double threshold);
extern "C" char* __stdcall CountBuiltTroops(troopClass type, HBITMAP hBmp, double threshold);
