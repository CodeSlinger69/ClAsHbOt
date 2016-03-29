#include "stdafx.h"
#include "Logger.h"
#include "ClAsHbOt.h"
#include "Scraper.h"

shared_ptr<Scraper> scraper;

Scraper::Scraper(const char* scriptDir)
	: scriptPath(scriptDir), imageDataPath(scriptDir)
{
	imageDataPath.append("\\ImageFiles.data");

	// Read image data
	// Open file
	ifstream f (imageDataPath);
    if (!f.is_open())
	{
		char err[500];
		strerror_s(err, 500, errno);

		string s("Error opening " + imageDataPath + ": " + err);

		logger->WriteLog(s);
		return;
	}

    // Read the file
	ImageGroup newImageGroup;

	string line("");
    while (getline(f, line))
	{
		vector<string> elems;
		split(line, ' ', elems);

		// Comment
		if (line.empty() || elems[0].find("//") != string::npos)
		{
			continue;
		}

		// Find image class
		bool foundImageType = false;
		for (int i = 0; i < imageClassCount; i++)
		{
			if (elems[0].find(imageClasses[i])!=string::npos)
			{
				newImageGroup.iType = (imageType) i;
				foundImageType = true;
				break;
			}
		}

		// Found the right group?
		if (!foundImageType)
		{
			string s("Image group " + elems[0] + " is unrecognized");
			logger->WriteLog(s);
		}

		else
		{
			newImageGroup.imagePaths.clear();
			newImageGroup.mats.clear();
			newImageGroup.imagePaths.resize(elems.size()-1);
			newImageGroup.mats.resize(elems.size()-1);
			imageGroups.push_back(newImageGroup);
			int lastGroup = imageGroups.size()-1;

			// Create a Mat for each path in the group
			for (int i = 1; i < (int) elems.size(); i++)
			{
				imageGroups[lastGroup].imagePaths[i-1] = elems[i];
				
				string path(scriptPath + "\\Images\\" + elems[i]);
				wstring ws = utf8_decode(path);
				imageGroups[lastGroup].mats[i-1] = CGdiPlus::ImgRead(ws.c_str());
			}

			char s[500];
			sprintf_s(s, 500, "Loaded %d images for image group %s.", elems.size()-1, elems[0].c_str());
			logger->WriteLog(s);
		}
	}

	// Handle read error
    if (f.bad())
	{
		char err[500];
		strerror_s(err, 500, errno);

		string s("Error reading " + imageDataPath + ": " + err);

		logger->WriteLog(s);
	}

	f.close();

	logger->WriteLog("Images loaded");
}

bool Scraper::FindBestBMP(const searchType type, HBITMAP hBmp, const double threshold, MATCHPOINTS* match, char* matchedBMP)
{
	// Convert HBITMAP to Mat
	unique_ptr<Gdiplus::Bitmap> pBitmap;
	pBitmap.reset(Gdiplus::Bitmap::FromHBITMAP(hBmp, NULL));
	Mat img = CGdiPlus::CopyBmpToMat(pBitmap.get());
	pBitmap.reset();

	cvtColor( img, img, CV_BGRA2BGR );

	// Find right image group
	imageType iType = 
		type==searchTownHall ? townHall :
		type==searchLootCart ? lootCart :
		type==searchClashIcon ? clashIcon :
		type==searchPlayStoreOpenButton ? playStoreOpenButton :
		type==searchGoldStorage ? goldStorage : 
		type==searchElixStorage ? elixStorage : (imageType) 0;

	int iTypeIndex = -1;
	for (int i = 0; i < (int) imageGroups.size(); i++)
		if (imageGroups[i].iType == iType)
			iTypeIndex = i;
	if (iTypeIndex == -1)
		return false;

	// Scan through each Mat in this image group
	double bestMaxVal = 0;
	Point bestMaxLoc(0, 0);
	string bestNeedlePath("");

	for (int i = 0; i < (int) imageGroups[iTypeIndex].mats.size(); i++)
	{
		Mat result = FindMatch(img, imageGroups[iTypeIndex].mats[i]);

		// Localize the best match with minMaxLoc
		double minVal, maxVal;
		Point minLoc, maxLoc;
		minMaxLoc(result, &minVal, &maxVal, &minLoc, &maxLoc);

		bool beachSideOfSWLine = BeachSideOfSWLine((westPoint.x+maxLoc.x), (northPoint.y-10+maxLoc.y));

		if (maxVal >= threshold && maxVal > bestMaxVal && (type!=searchTownHall || !beachSideOfSWLine))
		{
			bestMaxVal = maxVal;
			bestMaxLoc = maxLoc;
			bestNeedlePath = imageGroups[iTypeIndex].imagePaths[i];
		}
	}

	if (bestMaxVal > 0)
	{
		match->val = bestMaxVal;
		match->x = bestMaxLoc.x;
		match->y = bestMaxLoc.y;
		sprintf_s(matchedBMP, MAXSTRING, "%s", bestNeedlePath.c_str());
		return true;
	}

	return false;
}

bool Scraper::FindAllBMPs(const searchType type, HBITMAP hBmp, const double threshold, const int maxMatch, vector<MATCHPOINTS> &matches)
{
	// Convert HBITMAP to Mat
	unique_ptr<Gdiplus::Bitmap> pBitmap;
	pBitmap.reset(Gdiplus::Bitmap::FromHBITMAP(hBmp, NULL));
	Mat img = CGdiPlus::CopyBmpToMat(pBitmap.get());
	pBitmap.reset();

	cvtColor( img, img, CV_BGRA2BGR );

	// Find right image group
	imageType iType = 
		type==searchGoldStorage ? goldStorage : 
		type==searchElixStorage ? elixStorage :
		type==searchLootCollector ? collector : 
		type==searchLootBubble ? lootBubble : 
		type==searchDonateButton ? donateButton : (imageType) 0;

	int iTypeIndex = -1;
	for (int i = 0; i < (int) imageGroups.size(); i++)
		if (imageGroups[i].iType == iType)
			iTypeIndex = i;
	if (iTypeIndex == -1)
		return false;

	// Scan through each Mat in this image group
	int count = 0;

	for (int i = 0; i < (int) imageGroups[iTypeIndex].mats.size(); i++)
	{
		// Get matches for this image
		Mat result( FindMatch(img, imageGroups[iTypeIndex].mats[i]) );

		// Parse through matches in result set
		while (count < maxMatch)
		{
			double minVal, maxVal;
			Point minLoc, maxLoc;
			minMaxLoc(result, &minVal, &maxVal, &minLoc, &maxLoc);

			// Fill haystack with pure green so we don't match this same location
			rectangle(img, maxLoc, cv::Point(maxLoc.x + imageGroups[iTypeIndex].mats[i].cols, maxLoc.y + imageGroups[iTypeIndex].mats[i].rows), CV_RGB(0,255,0), 2);

			// Fill results array with lo vals, so we don't match this same location
			floodFill(result, maxLoc, 0, 0, Scalar(0.1), Scalar(1.0));

			bool beachSideOfSWLine = BeachSideOfSWLine((westPoint.x+maxLoc.x), (northPoint.y+maxLoc.y));

			if (maxVal >= threshold && maxVal > 0 && (type!=searchLootBubble || !beachSideOfSWLine))
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

	return true;
}

bool Scraper::LocateSlots(const actionType aType, const slotType sType, HBITMAP hBmp, const double threshold, vector<MATCHPOINTS> &matches)
{
	// Convert HBITMAP to Mat
	unique_ptr<Gdiplus::Bitmap> pBitmap;
	pBitmap.reset(Gdiplus::Bitmap::FromHBITMAP(hBmp, NULL));
	Mat img = CGdiPlus::CopyBmpToMat(pBitmap.get());
	pBitmap.reset();

	cvtColor( img, img, CV_BGRA2BGR );

	// Find right image group
	imageType iType = 
		(aType==actionRaid && sType==slotTroop) ? raidTroopSlot :
		(aType==actionRaid && sType==slotSpell) ? raidSpellSlot :
		(aType==actionDonate && sType==slotTroop) ? donateTroopSlot :
		(aType==actionDonate && sType==slotSpell) ? donateSpellSlot :
		(aType==actionBarracks) ? barracksTroopSlot : 
		(aType==actionCamp) ? armyCampTroop :
		(aType==actionReloadButton) ? reloadButton : (imageType) 0;

	int iTypeIndex = -1;
	for (int i = 0; i < (int) imageGroups.size(); i++)
		if (imageGroups[i].iType == iType)
			iTypeIndex = i;
	if (iTypeIndex == -1)
		return false;

	// Scan through each Mat in this image group
	for (int i=0; i<(int) imageGroups[iTypeIndex].mats.size(); i++)
	{
		Mat result( FindMatch(img, imageGroups[iTypeIndex].mats[i]) );

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

	return true;
}

Mat Scraper::GetMat(const imageType iType, const string imageName)
{
	int iTypeIndex = -1;
	for (int i = 0; i < (int) imageGroups.size(); i++)
	{
		if (imageGroups[i].iType == iType)
		{
			iTypeIndex = i;
			break;
		}
	}

	if (iTypeIndex == -1)
		return Mat();

	for (int i = 0; i < (int) imageGroups[iTypeIndex].imagePaths.size(); i++)
	{
		if (imageGroups[iTypeIndex].imagePaths[i].find(imageName) != string::npos)
			return imageGroups[iTypeIndex].mats[i];
	}

	return Mat();
}

Mat Scraper::FindMatch(const Mat haystack, const Mat needle)
{
	Mat result = Mat();

	if (needle.cols > haystack.cols || needle.rows > haystack.rows)
		return result;

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

const char* Scraper::imageClasses[imageClassCount] = { 
	"TownHall", "LootCart", "ClashIcon", "PlayStoreOpenButton", "DonateButton", "GoldStorage", "ElixStorage", 
	"RaidTroopSlot", "RaidSpellSlot", "ArmyCampTroop", "BarracksTroopSlot", "DonateTroopSlot", "DonateSpellSlot", 
	"ReloadButton", "Collector", "LootBubble", "Wall" };
