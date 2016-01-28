#pragma once

class NeedleCache
{
public:
	NeedleCache(void);
	~NeedleCache(void);

	enum lootType {gold, elix, dark};
	struct MATCHPOINTS
	{
		int x;
		int y;
		double val;
	};
	
	void SetDirectories(const char* scriptDir);
	void LoadNeedles(void);
	int TownHallSearch(const char* haystack, MATCHPOINTS* match);
	std::string BestStorageSearch(const lootType type, const char* haystack, const double threshold, MATCHPOINTS* match);
	int FindAllStorages(const lootType type, const char* haystack, const double threshold, const int maxMatch, std::vector<NeedleCache::MATCHPOINTS>* matches);

private:
	char scriptPath[MAX_PATH];  // no terminating backslash
	char logFilePath[MAX_PATH];

	static const int townHallBMPCount = 6;
	static const char* townHallBMPs[townHallBMPCount];
	Mat townHalls[townHallBMPCount];

	static const int goldStorageBMPCount = 14;
	static const char* goldStorageBMPs[goldStorageBMPCount];
	Mat goldStorages[goldStorageBMPCount];

	static const int elixStorageBMPCount = 15;
	static const char* elixStorageBMPs[elixStorageBMPCount];
	Mat elixStorages[elixStorageBMPCount];

	static const int darkStorageBMPCount = 16;
	static const char* darkStorageBMPs[darkStorageBMPCount];
	Mat darkStorages[darkStorageBMPCount];

	Mat FindMatch(Mat haystack, Mat needle);
	double DistanceBetweenTwoPoints(const double x1, const double y1, const double x2, const double y2);
	void WriteLog(const char* text);
};

extern NeedleCache* needleCache;

