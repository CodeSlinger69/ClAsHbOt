#include "stdafx.h"
#include "Scraper.h"
#include "ImageMatchDLL.h"
#include "CGdiPlus.h"

Scraper::Scraper(void)
{
	CGdiPlus::Init();
}


Scraper::~Scraper(void)
{
	CGdiPlus::Shutdown();
}

void Scraper::SetDirectories(const char* scriptDir)
{
	strcpy_s(scriptPath, MAX_PATH, scriptDir);
	sprintf_s(logFilePath, MAX_PATH, "%s\\ClashBotLog.txt", scriptPath);

	WriteLog("Directory paths set successfully");
}

void Scraper::LoadNeedles(void)
{
	// Town Hall Images
	for (int i=0; i<townHallBMPCount; i++)
	{
		char path[MAX_PATH];
		sprintf_s(path, MAX_PATH, "%s\\Images\\%s", scriptPath, townHallBMPs[i]);
		townHalls[i] = imread(path);
	}
	WriteLog("TownHall images loaded");

	// Loot Cart Image
	char path[MAX_PATH];
	sprintf_s(path, MAX_PATH, "%s\\Images\\%s", scriptPath, lootCartBMPs[0]);
	lootCart[0] = imread(path);
	WriteLog("Loot Cart images loaded");

	// Gold Storage Images
	for (int i=0; i<goldStorageBMPCount; i++)
	{
		char path[MAX_PATH];
		sprintf_s(path, MAX_PATH, "%s\\Images\\%s", scriptPath, goldStorageBMPs[i]);
		goldStorages[i] = imread(path);
	}
	WriteLog("Gold Storages images loaded");

	// Elixir Storage Images
	for (int i=0; i<elixStorageBMPCount; i++)
	{
		char path[MAX_PATH];
		sprintf_s(path, MAX_PATH, "%s\\Images\\%s", scriptPath, elixStorageBMPs[i]);
		elixStorages[i] = imread(path);
	}
	WriteLog("Elixir Storages images loaded");

	// Dark Elixir Storage Images
	for (int i=0; i<darkStorageBMPCount; i++)
	{
		char path[MAX_PATH];
		sprintf_s(path, MAX_PATH, "%s\\Images\\%s", scriptPath, darkStorageBMPs[i]);
		darkStorages[i] = imread(path);
	}
	WriteLog("Dark Elixir Storages images loaded");

	// Raid Troop Slot Images
	for (int i=0; i<raidTroopSlotBMPCount; i++)
	{
		char path[MAX_PATH];
		sprintf_s(path, MAX_PATH, "%s\\Images\\%s", scriptPath, raidTroopSlotBMPs[i]);
		raidTroopSlots[i] = imread(path);
	}
	WriteLog("Raid Troop Slot images loaded");

	// Raid Spell Slot Images
	for (int i=0; i<raidSpellSlotBMPCount; i++)
	{
		char path[MAX_PATH];
		sprintf_s(path, MAX_PATH, "%s\\Images\\%s", scriptPath, raidSpellSlotBMPs[i]);
		raidSpellSlots[i] = imread(path);
	}
	WriteLog("Raid Spell Slot images loaded");

}

int Scraper::FindTownHall(HBITMAP hBmp, const double threshold, MATCHPOINTS* match)
{
	Point bestPoint(0, 0);
	double bestConfidence = 0;
	int bestTH = -1;
	
	Gdiplus::Bitmap* pBitmap = Gdiplus::Bitmap::FromHBITMAP(hBmp, NULL);
	Mat img = CGdiPlus::CopyBmpToMat(pBitmap);
	delete pBitmap;

	cvtColor( img, img, CV_BGRA2BGR );

	// Debug
	//namedWindow( "Display window", WINDOW_AUTOSIZE );
	//imshow( "Display window", img );
	//waitKey(0); 

	for (int i=0; i<townHallBMPCount; i++)
	{
		Mat result( FindMatch(img, townHalls[i]) );

		// Localize the best match with minMaxLoc
		double minVal, maxVal;
		Point minLoc, maxLoc;
		
		minMaxLoc(result, &minVal, &maxVal, &minLoc, &maxLoc);

		if (maxVal > bestConfidence && maxVal >= threshold)
		{
			// Need to check for case where a town hall is "found" in the sandy beach area, this is a false positive.
			// http://stackoverflow.com/questions/1560492/how-to-tell-whether-a-point-is-to-the-right-or-left-side-of-a-line
			// return (b.x - a.x)*(c.y - a.y) > (b.y - a.y)*(c.x - a.x);
			bool beachSideOfSWLine = (southPoint.x - westPoint.x)*((northPoint.y-10+maxLoc.y) - westPoint.y) > (southPoint.y - westPoint.y)*((westPoint.x+maxLoc.x) - westPoint.x);

			if (beachSideOfSWLine == false)
			{
				bestConfidence = maxVal;
				bestPoint.x = maxLoc.x;
				bestPoint.y = maxLoc.y;
				bestTH = i+6;
			}
		}
	}

	match->x = bestPoint.x;
	match->y = bestPoint.y;
	match->val = bestConfidence;
	return bestTH;
}

int Scraper::FindLootCart(HBITMAP hBmp, const double threshold, MATCHPOINTS* match)
{
	Gdiplus::Bitmap* pBitmap = Gdiplus::Bitmap::FromHBITMAP(hBmp, NULL);
	Mat img = CGdiPlus::CopyBmpToMat(pBitmap);
	delete pBitmap;

	cvtColor( img, img, CV_BGRA2BGR );

	Mat result( FindMatch(img, lootCart[0]) );

	double minVal, maxVal;
	Point minLoc, maxLoc;
	minMaxLoc(result, &minVal, &maxVal, &minLoc, &maxLoc);

	match->val = maxVal;
	if (maxVal >= threshold)
	{
		match->x = maxLoc.x;
		match->y = maxLoc.y;
		return 1;
	}
	else
	{
		match->x = -1;
		match->y = -1;
		return 0;
	}
}

std::string Scraper::FindBestStorage(const lootType type, HBITMAP hBmp, const double threshold, MATCHPOINTS* match)
{
	Gdiplus::Bitmap* pBitmap = Gdiplus::Bitmap::FromHBITMAP(hBmp, NULL);
	Mat img = CGdiPlus::CopyBmpToMat(pBitmap);
	delete pBitmap;

	cvtColor( img, img, CV_BGRA2BGR );

	int storageCount = type==lootGold ? goldStorageBMPCount : 
					   type==lootElix ? elixStorageBMPCount : 
					   type==lootDark ? darkStorageBMPCount : 0;

	double bestMaxVal = 0;
	Point bestMaxLoc(0, 0);
	std::string bestNeedle("");

	for (int i=0; i<storageCount; i++)
	{
		Mat needle(	type==lootGold ? goldStorages[i] : 
					type==lootElix ? elixStorages[i] : 
					type==lootDark ? darkStorages[i] : Mat() );

		Mat result( FindMatch(img, needle) );

		// Localize the best match with minMaxLoc
		double minVal, maxVal;
		Point minLoc, maxLoc;
		minMaxLoc(result, &minVal, &maxVal, &minLoc, &maxLoc);

		if (maxVal >= threshold && maxVal > bestMaxVal)
		{
			bestMaxVal = maxVal;
			bestMaxLoc = maxLoc;
			bestNeedle = type==lootGold ? goldStorageBMPs[i] : type==lootElix ? elixStorageBMPs[i] : type==lootDark ? darkStorageBMPs[i] : "";
		}
	}

	if (bestMaxVal > 0)
	{
		match->val = bestMaxVal;
		match->x = bestMaxLoc.x;
		match->y = bestMaxLoc.y;
	}

	return bestNeedle;
}

void Scraper::FindAllStorages(const lootType type, HBITMAP hBmp, const double threshold, const int maxMatch, std::vector<MATCHPOINTS>* matches)
{
	Gdiplus::Bitmap* pBitmap = Gdiplus::Bitmap::FromHBITMAP(hBmp, NULL);
	Mat img = CGdiPlus::CopyBmpToMat(pBitmap);
	delete pBitmap;

	cvtColor( img, img, CV_BGRA2BGR );

	int storageCount = type==lootGold ? goldStorageBMPCount : 
					   type==lootElix ? elixStorageBMPCount : 
					   type==lootDark ? darkStorageBMPCount : 0;

	int count = 0;

	for (int i=0; i<storageCount; i++)
	{
		// Get matches for this storage
		Mat needle(	type==lootGold ? goldStorages[i] : 
					type==lootElix ? elixStorages[i] : 
					type==lootDark ? darkStorages[i] : Mat() );

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

			/*
			if (maxVal>0)
			{
				char a[500];
				sprintf(a, "%d match %d %d %.4f", i, maxLoc.x+429-150, maxLoc.y+337-150, maxVal);
				WriteLog(a);
			}
			*/

			if (maxVal >= threshold)
			{
				// Check if this point is within 10 pixels of an existing match to avoid dups
				bool alreadyFound = false;

				for (int k=0; k<count; k++)
				{
					if (DistanceBetweenTwoPoints((double) maxLoc.x, (double) maxLoc.y, (double) matches->at(k).x, (double) matches->at(k).y) < 10.0)
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
					matches->push_back(match);
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

void Scraper::LocateRaidSlots(const slotType type, HBITMAP hBmp, const double threshold, std::vector<MATCHPOINTS>* matches)
{
	Gdiplus::Bitmap* pBitmap = Gdiplus::Bitmap::FromHBITMAP(hBmp, NULL);
	Mat img = CGdiPlus::CopyBmpToMat(pBitmap);
	delete pBitmap;

	cvtColor( img, img, CV_BGRA2BGR );

	int slotCount = type==slotTroop ? raidTroopSlotBMPCount : 
					type==slotSpell ? raidSpellSlotBMPCount : 0;

	int count = 0;

	for (int i=0; i<slotCount; i++)
	{
		// Get matches for this storage
		Mat needle(	type==slotTroop ? raidTroopSlots[i] : 
					type==slotSpell ? raidSpellSlots[i] : Mat() );

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

		matches->push_back(match);
		count++;
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

double Scraper::DistanceBetweenTwoPoints(const double x1, const double y1, const double x2, const double y2)
{
	return sqrt( pow((x1 - x2), 2.0) + pow((y1 - y2), 2.0) );
}
	
void Scraper::WriteLog(const char* text)
{
	FILE* f;
	errno_t err;

	err = fopen_s(&f, logFilePath, "a");

	if (err==0)
	{
		time_t t = time(0);
		struct std::tm now;

		err = localtime_s (&now, &t); 
        if (err)
        {
			fprintf_s(f, "00/00/0000 00:00:00 ImageMatchDLL %s\n", text);
		}
		else
		{
			fprintf_s(f, "%d/%d/%d %02d:%02d:%02d ImageMatchDLL %s\n", now.tm_mon+1, now.tm_mday, now.tm_year+1900, now.tm_hour, now.tm_min, now.tm_sec, text);
		}

		err = fclose(f);
	}
}

const Point Scraper::northPoint = Point(429, 69);
const Point Scraper::westPoint = Point(71, 337);
const Point Scraper::eastPoint = Point(787, 337);
const Point Scraper::southPoint = Point(429, 605);

const char* Scraper::townHallBMPs[townHallBMPCount] = { 
	"TownHall\\TH6.bmp", "TownHall\\TH7.bmp", "TownHall\\TH8.bmp", "TownHall\\TH9.bmp", "TownHall\\TH10.bmp", "TownHall\\TH11.bmp" };

const char* Scraper::lootCartBMPs[1] = { "Loot\\LootCart1.bmp" };

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

