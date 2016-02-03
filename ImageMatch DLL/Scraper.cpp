#include "stdafx.h"
#include "CGdiPlus.h"
#include "Logger.h"
#include "Scraper.h"

shared_ptr<Scraper> scraper;

Scraper::Scraper(const char* scriptDir) 
{
	strcpy_s(scriptPath, MAX_PATH, scriptDir);

	// Town Hall Images
	for (int i=0; i<townHallBMPCount; i++)
	{
		char path[MAX_PATH];
		sprintf_s(path, MAX_PATH, "%s\\Images\\%s", scriptPath, townHallBMPs[i]);
		townHalls[i] = imread(path);
	}
	logger->WriteLog("TownHall images loaded");

	// Loot Cart Image
	for (int i=0; i<lootCartBMPCount; i++)
	{
		char path[MAX_PATH];
		sprintf_s(path, MAX_PATH, "%s\\Images\\%s", scriptPath, lootCartBMPs[i]);
		lootCarts[i] = imread(path);
	}
	logger->WriteLog("Loot Cart images loaded");

	// Clash Icon Images
	for (int i=0; i<clashIconBMPCount; i++)
	{
		char path[MAX_PATH];
		sprintf_s(path, MAX_PATH, "%s\\Images\\%s", scriptPath, clashIconBMPs[i]);
		clashIcons[i] = imread(path);
	}
	logger->WriteLog("Clash Icon images loaded");
	
	// Play Store Open Button Images
	for (int i=0; i<playStoreOpenButtonBMPCount; i++)
	{
		char path[MAX_PATH];
		sprintf_s(path, MAX_PATH, "%s\\Images\\%s", scriptPath, playStoreOpenButtonBMPs[i]);
		playStoreOpenButtons[i] = imread(path);
	}
	logger->WriteLog("Play Store Open Button images loaded");

	// Donate Button Images
	for (int i=0; i<donateButtonBMPCount; i++)
	{
		char path[MAX_PATH];
		sprintf_s(path, MAX_PATH, "%s\\Images\\%s", scriptPath, donateButtonBMPs[i]);
		donateButtons[i] = imread(path);
	}
	logger->WriteLog("Donate Button images loaded");
	
	// Gold Storage Images
	for (int i=0; i<goldStorageBMPCount; i++)
	{
		char path[MAX_PATH];
		sprintf_s(path, MAX_PATH, "%s\\Images\\%s", scriptPath, goldStorageBMPs[i]);
		goldStorages[i] = imread(path);
	}
	logger->WriteLog("Gold Storages images loaded");

	// Elixir Storage Images
	for (int i=0; i<elixStorageBMPCount; i++)
	{
		char path[MAX_PATH];
		sprintf_s(path, MAX_PATH, "%s\\Images\\%s", scriptPath, elixStorageBMPs[i]);
		elixStorages[i] = imread(path);
	}
	logger->WriteLog("Elixir Storages images loaded");

	// Dark Elixir Storage Images
	for (int i=0; i<darkStorageBMPCount; i++)
	{
		char path[MAX_PATH];
		sprintf_s(path, MAX_PATH, "%s\\Images\\%s", scriptPath, darkStorageBMPs[i]);
		darkStorages[i] = imread(path);
	}
	logger->WriteLog("Dark Elixir Storages images loaded");

	// Raid Troop Slot Images
	for (int i=0; i<raidTroopSlotBMPCount; i++)
	{
		char path[MAX_PATH];
		sprintf_s(path, MAX_PATH, "%s\\Images\\%s", scriptPath, raidTroopSlotBMPs[i]);
		raidTroopSlots[i] = imread(path);
	}
	logger->WriteLog("Raid Troop Slot images loaded");

	// Raid Spell Slot Images
	for (int i=0; i<raidSpellSlotBMPCount; i++)
	{
		char path[MAX_PATH];
		sprintf_s(path, MAX_PATH, "%s\\Images\\%s", scriptPath, raidSpellSlotBMPs[i]);
		raidSpellSlots[i] = imread(path);
	}
	logger->WriteLog("Raid Spell Slot images loaded");

	// Army Camp Troop Images
	for (int i=0; i<armyCampTroopBMPCount; i++)
	{
		char path[MAX_PATH];
		sprintf_s(path, MAX_PATH, "%s\\Images\\%s", scriptPath, armyCampTroopBMPs[i]);
		armyCampSlots[i] = imread(path);
	}
	logger->WriteLog("Army Camp Troop images loaded");

	// Barracks Troop Slot Images
	for (int i=0; i<barracksTroopSlotBMPCount; i++)
	{
		char path[MAX_PATH];
		sprintf_s(path, MAX_PATH, "%s\\Images\\%s", scriptPath, barracksTroopSlotBMPs[i]);
		barracksTroopSlots[i] = imread(path);
	}
	logger->WriteLog("Barracks Troop Slot images loaded");

	// Donate Troop Slot Images
	for (int i=0; i<donateTroopSlotBMPCount; i++)
	{
		char path[MAX_PATH];
		sprintf_s(path, MAX_PATH, "%s\\Images\\%s", scriptPath, donateTroopSlotBMPs[i]);
		donateTroopSlots[i] = imread(path);
	}
	logger->WriteLog("Donate Troop Slot images loaded");

	// Donate Spell Slot Images
	for (int i=0; i<donateSpellSlotBMPCount; i++)
	{
		char path[MAX_PATH];
		sprintf_s(path, MAX_PATH, "%s\\Images\\%s", scriptPath, donateSpellSlotBMPs[i]);
		donateSpellSlots[i] = imread(path);
	}
	logger->WriteLog("Donate Spell Slot images loaded");

	// Reload Button Images
	for (int i=0; i<reloadButtonBMPCount; i++)
	{
		char path[MAX_PATH];
		sprintf_s(path, MAX_PATH, "%s\\Images\\%s", scriptPath, reloadButtonBMPs[i]);
		reloadButtons[i] = imread(path);
	}
	logger->WriteLog("Reload Button images loaded");

	// Collector Images
	for (int i=0; i<collectorBMPCount; i++)
	{
		char path[MAX_PATH];
		sprintf_s(path, MAX_PATH, "%s\\Images\\%s", scriptPath, collectorBMPs[i]);
		collectors[i] = imread(path);
	}
	logger->WriteLog("Collector images loaded");

	// Loot Bubble Images
	for (int i=0; i<lootBubbleBMPCount; i++)
	{
		char path[MAX_PATH];
		sprintf_s(path, MAX_PATH, "%s\\Images\\%s", scriptPath, lootBubbleBMPs[i]);
		lootBubbles[i] = imread(path);
	}
	logger->WriteLog("Loot Bubble images loaded");
}

string Scraper::FindBestBMP(const searchType type, HBITMAP hBmp, const double threshold, MATCHPOINTS &match)
{
	Gdiplus::Bitmap* pBitmap = Gdiplus::Bitmap::FromHBITMAP(hBmp, NULL);
	Mat img = CGdiPlus::CopyBmpToMat(pBitmap);
	delete pBitmap;

	cvtColor( img, img, CV_BGRA2BGR );

	int bmpCount = type==searchTownHall ? townHallBMPCount :
				   type==searchLootCart ? lootCartBMPCount :
				   type==searchClashIcon ? clashIconBMPCount :
				   type==searchPlayStoreOpenButton ? playStoreOpenButtonBMPCount :
				   type==searchGoldStorage ? goldStorageBMPCount : 
				   type==searchElixStorage ? elixStorageBMPCount :
				   type==searchDarkStorage ? darkStorageBMPCount : 0;

	double bestMaxVal = 0;
	Point bestMaxLoc(0, 0);
	string bestNeedle("");

	for (int i=0; i<bmpCount; i++)
	{
		Mat needle(	type==searchTownHall ? townHalls[i] : 
					type==searchLootCart ? lootCarts[i] : 
				    type==searchClashIcon ? clashIcons[i] :
				    type==searchPlayStoreOpenButton ? playStoreOpenButtons[i] :
					type==searchGoldStorage ? goldStorages[i] : 
					type==searchElixStorage ? elixStorages[i] :
					type==searchDarkStorage ? darkStorages[i] : Mat() );

		Mat result( FindMatch(img, needle) );

		// Localize the best match with minMaxLoc
		double minVal, maxVal;
		Point minLoc, maxLoc;
		minMaxLoc(result, &minVal, &maxVal, &minLoc, &maxLoc);

		bool beachSideOfSWLine = BeachSideOfSWLine((westPoint.x+maxLoc.x), (northPoint.y-10+maxLoc.y));

		if (maxVal >= threshold && maxVal > bestMaxVal && (type!=searchTownHall || !beachSideOfSWLine))
		{
			bestMaxVal = maxVal;
			bestMaxLoc = maxLoc;
			bestNeedle = type==searchTownHall ? townHallBMPs[i] : 
						 type==searchLootCart ? lootCartBMPs[i] : 
						 type==searchClashIcon ? clashIconBMPs[i] :
						 type==searchPlayStoreOpenButton ? playStoreOpenButtonBMPs[i] :
						 type==searchGoldStorage ? goldStorageBMPs[i] : 
						 type==searchElixStorage ? elixStorageBMPs[i] : 
						 type==searchDarkStorage ? darkStorageBMPs[i] : "";
		}
	}

	if (bestMaxVal > 0)
	{
		match.val = bestMaxVal;
		match.x = bestMaxLoc.x;
		match.y = bestMaxLoc.y;
	}

	return bestNeedle;
}

void Scraper::FindAllBMPs(const searchType type, HBITMAP hBmp, const double threshold, const int maxMatch, vector<MATCHPOINTS> &matches)
{
	Gdiplus::Bitmap* pBitmap = Gdiplus::Bitmap::FromHBITMAP(hBmp, NULL);
	Mat img = CGdiPlus::CopyBmpToMat(pBitmap);
	delete pBitmap;

	cvtColor( img, img, CV_BGRA2BGR );

	int bmpCount = type==searchGoldStorage ? goldStorageBMPCount : 
				   type==searchElixStorage ? elixStorageBMPCount : 
				   type==searchDarkStorage ? darkStorageBMPCount : 
				   type==searchLootCollector ? collectorBMPCount : 
				   type==searchLootBubble ? lootBubbleBMPCount : 
				   type==searchDonateButton ? donateButtonBMPCount : 0;

	int count = 0;

	for (int i=0; i<bmpCount; i++)
	{
		// Get matches for this storage
		Mat needle(	type==searchGoldStorage ? goldStorages[i] : 
					type==searchElixStorage ? elixStorages[i] : 
					type==searchDarkStorage ? darkStorages[i] : 
					type==searchLootCollector ? collectors[i] : 
					type==searchLootBubble ? lootBubbles[i] : 
					type==searchDonateButton ? donateButtons[i] : Mat() );

		Mat result( FindMatch(img, needle) );

		// Parse through matches in result set
		while (count < maxMatch)
		{
			double minVal, maxVal;
			Point minLoc, maxLoc;
			minMaxLoc(result, &minVal, &maxVal, &minLoc, &maxLoc);

			// Fill haystack with pure green so we don't match this same location
			rectangle(img, maxLoc, cv::Point(maxLoc.x + needle.cols, maxLoc.y + needle.rows), CV_RGB(0,255,0), 2);

			// Fill results array with lo vals, so we don't match this same location
			floodFill(result, maxLoc, 0, 0, Scalar(0.1), Scalar(1.0));

			if (maxVal >= threshold)
			{
				// Check if this point is within 10 pixels of an existing match to avoid dupes
				bool alreadyFound = false;

				for (int k=0; k<count; k++)
				{
					if (DistanceBetweenTwoPoints((double) maxLoc.x, (double) maxLoc.y, (double) matches.at(k).x, (double) matches.at(k).y) < 10.0)
					{
						alreadyFound = true;
						break;
					}
				}

				// Add matched location to the vector
				if (alreadyFound == false)
				{
					MATCHPOINTS match;
					match.val = maxVal;
					match.x = maxLoc.x;
					match.y = maxLoc.y;
					matches.push_back(match);
					count++;
				}
			}
			else
			{
				break;
			}
		}

		if (count >= maxMatch)
			break;
	}
}

void Scraper::LocateSlots(const actionType aType, const slotType sType, HBITMAP hBmp, const double threshold, vector<MATCHPOINTS> &matches)
{
	Gdiplus::Bitmap* pBitmap = Gdiplus::Bitmap::FromHBITMAP(hBmp, NULL);
	Mat img = CGdiPlus::CopyBmpToMat(pBitmap);
	delete pBitmap;

	cvtColor( img, img, CV_BGRA2BGR );

	int slotCount = (aType==actionRaid && sType==slotTroop) ? raidTroopSlotBMPCount :
					(aType==actionRaid && sType==slotSpell) ? raidSpellSlotBMPCount :
					(aType==actionDonate && sType==slotTroop) ? donateTroopSlotBMPCount :
					(aType==actionDonate && sType==slotSpell) ? donateSpellSlotBMPCount :
					(aType==actionBarracks) ? barracksTroopSlotBMPCount : 
					(aType==actionCamp) ? armyCampTroopBMPCount :
					(aType==actionReloadButton) ? reloadButtonBMPCount : 0;

	for (int i=0; i<slotCount; i++)
	{
		Mat needle( (aType==actionRaid && sType==slotTroop) ? raidTroopSlots[i] :
					(aType==actionRaid && sType==slotSpell) ? raidSpellSlots[i] :
					(aType==actionDonate && sType==slotTroop) ? donateTroopSlots[i] :
					(aType==actionDonate && sType==slotSpell) ? donateSpellSlots[i] :
					(aType==actionBarracks) ? barracksTroopSlots[i] : 
					(aType==actionCamp) ? armyCampSlots[i] :
				    (aType==actionReloadButton) ? reloadButtons[i] : Mat() );

		Mat result( FindMatch(img, needle) );

		double minVal, maxVal;
		Point minLoc, maxLoc;
		minMaxLoc(result, &minVal, &maxVal, &minLoc, &maxLoc);

		MATCHPOINTS match;
		match.val = maxVal;

		if (maxVal >= threshold)
		{
			match.x = maxLoc.x;
			match.y = maxLoc.y;
		}
		else
		{
			match.x = -1;
			match.y = -1;
		}

		matches.push_back(match);
	}
}

Mat Scraper::FindMatch(Mat haystack, Mat needle)
{
	Mat result;

	// Create the result matrix
	int result_cols =  haystack.cols - needle.cols + 1;
	int result_rows = haystack.rows - needle.rows + 1;
	result.create( result_cols, result_rows, CV_32FC1 );

	// Do the Matching and evaluate Threshold
	//  Method = 0: CV_TM_SQDIFF, 1: CV_TM_SQDIFF_NORMED 2: CV_TM_CCORR 3: CV_TM_CCORR_NORMED 4: CV_TM_CCOEFF 5: CV_TM_CCOEFF_NORMED
	matchTemplate(haystack, needle, result, CV_TM_CCORR_NORMED );
	threshold(result, result, 0.9, 1.0, CV_THRESH_TOZERO);

	return result;
}

bool Scraper::BeachSideOfSWLine(const int x, const int y)
{
	// Need to check for case where a town hall is "found" in the sandy beach area, this is a false positive.
	// http://stackoverflow.com/questions/1560492/how-to-tell-whether-a-point-is-to-the-right-or-left-side-of-a-line
	// return (b.x - a.x)*(c.y - a.y) > (b.y - a.y)*(c.x - a.x);
	return (southPoint.x - westPoint.x)*(y - westPoint.y) > (southPoint.y - westPoint.y)*(x - westPoint.x);
}

double Scraper::DistanceBetweenTwoPoints(const double x1, const double y1, const double x2, const double y2)
{
	return sqrt( pow((x1 - x2), 2.0) + pow((y1 - y2), 2.0) );
}
	
const Point Scraper::northPoint = Point(429, 69);
const Point Scraper::westPoint = Point(71, 337);
const Point Scraper::eastPoint = Point(787, 337);
const Point Scraper::southPoint = Point(429, 605);

const char* Scraper::townHallBMPs[townHallBMPCount] = { 
	"TownHall\\TH6.bmp", "TownHall\\TH7.bmp", "TownHall\\TH8.bmp", "TownHall\\TH9.bmp", "TownHall\\TH10.bmp", "TownHall\\TH11.bmp" };

const char* Scraper::lootCartBMPs[lootCartBMPCount] = { "Loot\\LootCart1.bmp" };

const char* Scraper::clashIconBMPs[clashIconBMPCount] = { "ClashIcon.bmp" };

const char* Scraper::playStoreOpenButtonBMPs[playStoreOpenButtonBMPCount] = { "PlayStoreOpenButton.bmp" };

const char* Scraper::donateButtonBMPs[donateButtonBMPCount] = { "Donate\\DonateButton.bmp" };

const char* Scraper::goldStorageBMPs[goldStorageBMPCount] = { 
	"Storages\\GoldStorageL12.00.bmp", "Storages\\GoldStorageL12.25.bmp", "Storages\\GoldStorageL12.50.bmp", "Storages\\GoldStorageL12.75.bmp", "Storages\\GoldStorageL12.90.bmp",
	"Storages\\GoldStorageL11.00.bmp", "Storages\\GoldStorageL11.25.bmp", "Storages\\GoldStorageL11.50.bmp", "Storages\\GoldStorageL11.75.bmp", "Storages\\GoldStorageL11.90.bmp",
	"Storages\\GoldStorageL10.00.bmp", "Storages\\GoldStorageL10.25.bmp", "Storages\\GoldStorageL10.50.bmp", "Storages\\GoldStorageL10.90.bmp" };

const char* Scraper::elixStorageBMPs[elixStorageBMPCount] = { 
	"Storages\\ElixStorageL12.00.bmp", "Storages\\ElixStorageL12.25.bmp", "Storages\\ElixStorageL12.50.bmp", "Storages\\ElixStorageL12.75.bmp", "Storages\\ElixStorageL12.90.bmp",
	"Storages\\ElixStorageL11.00.bmp", "Storages\\ElixStorageL11.25.bmp", "Storages\\ElixStorageL11.50.bmp", "Storages\\ElixStorageL11.75.bmp", "Storages\\ElixStorageL11.90.bmp",
	"Storages\\ElixStorageL10.00.bmp", "Storages\\ElixStorageL10.25.bmp", "Storages\\ElixStorageL10.50.bmp", "Storages\\ElixStorageL10.75.bmp", "Storages\\ElixStorageL10.90.bmp" };

const char* Scraper::darkStorageBMPs[darkStorageBMPCount] = { 
	"Storages\\DarkStorageL6.00.bmp", "Storages\\DarkStorageL6.25.bmp", "Storages\\DarkStorageL6.50.bmp", "Storages\\DarkStorageL6.75.bmp", "Storages\\DarkStorageL6.90.bmp",
	"Storages\\DarkStorageL5.00.bmp", "Storages\\DarkStorageL5.25.bmp", "Storages\\DarkStorageL5.50.bmp", 
	"Storages\\DarkStorageL4.00.bmp", "Storages\\DarkStorageL4.25.bmp", "Storages\\DarkStorageL4.50.bmp", "Storages\\DarkStorageL4.90.bmp",
	"Storages\\DarkStorageL3.00.bmp", "Storages\\DarkStorageL3.25.bmp",
	"Storages\\DarkStorageL2.00.bmp", "Storages\\DarkStorageL2.50.bmp" };

const char* Scraper::raidTroopSlotBMPs[raidTroopSlotBMPCount] = {
	"RaidSlots\\SlotBarbarian.bmp", "RaidSlots\\SlotArcher.bmp", "RaidSlots\\SlotGiant.bmp", "RaidSlots\\SlotGoblin.bmp", "RaidSlots\\SlotWallBreaker.bmp",
	"RaidSlots\\SlotBalloon.bmp", "RaidSlots\\SlotWizard.bmp", "RaidSlots\\SlotHealer.bmp", "RaidSlots\\SlotDragon.bmp", "RaidSlots\\SlotPekka.bmp",
	"RaidSlots\\SlotMinion.bmp", "RaidSlots\\SlotHogRider.bmp", "RaidSlots\\SlotValkyrie.bmp", "RaidSlots\\SlotGolem.bmp", "RaidSlots\\SlotWitch.bmp",
	"RaidSlots\\SlotLavaHound.bmp", "RaidSlots\\SlotKing.bmp", "RaidSlots\\SlotQueen.bmp", "RaidSlots\\SlotWarden.bmp" };

const char* Scraper::raidSpellSlotBMPs[raidSpellSlotBMPCount] = {
	"RaidSlots\\SlotLightningSpell.bmp", "RaidSlots\\SlotHealSpell.bmp", "RaidSlots\\SlotRageSpell.bmp", "RaidSlots\\SlotJumpSpell.bmp", "RaidSlots\\SlotFreezeSpell.bmp",
	"RaidSlots\\SlotPoisonSpell.bmp", "RaidSlots\\SlotEarthquakeSpell.bmp", "RaidSlots\\SlotHasteSpell.bmp" };


const char* Scraper::armyCampTroopBMPs[armyCampTroopBMPCount] = {
	"Camp\\CampBarbarian.bmp", "Camp\\CampArcher.bmp", "Camp\\CampGiant.bmp", "Camp\\CampGoblin.bmp", "Camp\\CampWallBreaker.bmp", 
	"Camp\\CampBalloon.bmp", "Camp\\CampWizard.bmp", "Camp\\CampHealer.bmp", "Camp\\CampDragon.bmp", "Camp\\CampPekka.bmp",
	"Camp\\CampMinion.bmp", "Camp\\CampHogRider.bmp", "Camp\\CampValkyrie.bmp", "Camp\\CampGolem.bmp", "Camp\\CampWitch.bmp", 
	"Camp\\CampLavaHound.bmp", "Camp\\CampKing.bmp", "Camp\\CampQueen.bmp", "Camp\\CampWarden.bmp" };


const char* Scraper::barracksTroopSlotBMPs[barracksTroopSlotBMPCount] = {
	"Barracks\\BarracksBarbarian.bmp", "Barracks\\BarracksArcher.bmp", "Barracks\\BarracksGiant.bmp", "Barracks\\BarracksGoblin.bmp", "Barracks\\BarracksWallBreaker.bmp", 
	"Barracks\\BarracksBalloon.bmp", "Barracks\\BarracksWizard.bmp", "Barracks\\BarracksHealer.bmp", "Barracks\\BarracksDragon.bmp", "Barracks\\BarracksPekka.bmp",
	"Barracks\\BarracksMinion.bmp", "Barracks\\BarracksHogRider.bmp", "Barracks\\BarracksValkyrie.bmp", "Barracks\\BarracksGolem.bmp", "Barracks\\BarracksWitch.bmp", 
	"Barracks\\BarracksLavaHound.bmp" };

	
const char* Scraper::donateTroopSlotBMPs[donateTroopSlotBMPCount] = { 
	"Donate\\DonateBarbarian.bmp", "Donate\\DonateArcher.bmp", "Donate\\DonateGiant.bmp", "Donate\\DonateGoblin.bmp", "Donate\\DonateWallBreaker.bmp", 
	"Donate\\DonateBalloon.bmp", "Donate\\DonateWizard.bmp", "Donate\\DonateHealer.bmp", "Donate\\DonateDragon.bmp", "Donate\\DonatePekka.bmp",
	"Donate\\DonateMinion.bmp", "Donate\\DonateHogRider.bmp", "Donate\\DonateValkyrie.bmp", "Donate\\DonateGolem.bmp", "Donate\\DonateWitch.bmp", 
	"Donate\\DonateLavaHound.bmp" };

const char* Scraper::donateSpellSlotBMPs[donateSpellSlotBMPCount] = {
	"Donate\\DonatePoisonSpell.bmp", "Donate\\DonateEarthquakeSpell.bmp", "Donate\\DonateHasteSpell.bmp" };

const char* Scraper::reloadButtonBMPs[reloadButtonBMPCount] = { 
	"Reload\\InfoButton.bmp", "Reload\\GoldButton.bmp", "Reload\\ElixButton.bmp", "Reload\\DarkButton.bmp" };

const char* Scraper::collectorBMPs[collectorBMPCount] = {
	"Collectors\\GoldCollectorL12.bmp", "Collectors\\GoldCollectorL11.bmp", "Collectors\\GoldCollectorL10.bmp", "Collectors\\GoldCollectorL9.bmp",
	"Collectors\\ElixCollectorL12.bmp", "Collectors\\ElixCollectorL11.bmp", "Collectors\\ElixCollectorL10.bmp", "Collectors\\ElixCollectorL9.bmp",
	"Collectors\\DarkCollectorL6.bmp", "Collectors\\DarkCollectorL5.bmp", "Collectors\\DarkCollectorL4.bmp", "Collectors\\DarkCollectorL3.bmp" };

const char* Scraper::lootBubbleBMPs[lootBubbleBMPCount] = {
	"Loot\\FullGoldCollector1.bmp", "Loot\\FullGoldCollector2.bmp", "Loot\\FullGoldCollector3.bmp",
	"Loot\\FullElixCollector1.bmp", "Loot\\FullElixCollector2.bmp", "Loot\\FullElixCollector3.bmp",
	"Loot\\FullDarkCollector1.bmp", "Loot\\FullDarkCollector2.bmp", "Loot\\FullDarkCollector3.bmp" };

