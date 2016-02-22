Func ReadSettings()
   ; Debug
   $gDebug = _Boolean(IniRead($gIniFile, "Debug", "Global Debug", False))
   $gScraperDebug = _Boolean(IniRead($gIniFile, "Debug", "Scraper Debug", False))
   $gDebugSaveScreenCaptures = _Boolean(IniRead($gIniFile, "Debug", "Save Screen Captures", False))
   $gDebugSaveUnknownStorageFrames = _Boolean(IniRead($gIniFile, "Debug", "Save Unknown Storage Frames", False))
   $gDebugLogCallsToCaptureFrame = _Boolean(IniRead($gIniFile, "Debug", "Log Calls to Capture Frame", False))

   ; Mouse
   Global $gDeployTroopClickDelay = IniRead($gIniFile, "Mouse", "Deploy Troop Click Delay", 60) ; Delay between mouse clicks for raiding
   DebugWrite("Setting Mouse Deploy Troop Click Delay = " & $gDeployTroopClickDelay)
   Global $gDonateTroopClickDelay = IniRead($gIniFile, "Mouse", "Donate Troop Click Delay", 250) ; Delay between mouse clicks for donating
   DebugWrite("Setting Mouse Donate Troop Click Delay = " & $gDonateTroopClickDelay)

   ; Auto Raid
   Global $gAutoRaidEndDelay = IniRead($gIniFile, "AutoRaid", "End Delay", 0) ; After available resources stop changing the raid will end in this many seconds
   DebugWrite("Setting AutoRaid End Delay = " & $gAutoRaidEndDelay)

   ; Auto Snipe
   ; If set to true, the bot will stop when it detects a snipable base, and wait for you to manually raid
   Global $gAutoSnipeNotifyOnly = _Boolean(IniRead($gIniFile, "AutoSnipe", "Auto Snipe Notify Only", False))
   DebugWrite("Setting AutoSnipe Notify Only = " & $gAutoSnipeNotifyOnly)
   Global $gTHSnipeMaxDistFromCorner = IniRead($gIniFile, "AutoSnipe", "Max Distance From Corner", 90)
   DebugWrite("Setting TH Snipe Max Distance From Corner = " & $gTHSnipeMaxDistFromCorner)

   ; Defense Farm
   Global $gDefenseFarmOfflineTime = IniRead($gIniFile, "DefenseFarm", "Defense Farm Offline Time", 1200000) ; Duration to wait before logging in and dumping cups
   DebugWrite("Setting Defense Farm Offline Time = " & millisecondToMMSS($gDefenseFarmOfflineTime))

   ; Intervals
   Global $gOnlineCheckInterval = IniRead($gIniFile, "Interval", "Online Check", 15000)
   DebugWrite("Setting Interval Online Check = " & $gOnlineCheckInterval)
   Global $gCollectLootInterval = IniRead($gIniFile, "Interval", "Collect Loot", 180000)
   DebugWrite("Setting Interval Collect Loot = " & $gCollectLootInterval)
   Global $gReloadDefensesInterval = IniRead($gIniFile, "Interval", "Reload Defenses", 1200000)
   DebugWrite("Setting Interval Reload Defenses = " & $gReloadDefensesInterval)
   Global $gTroopTrainingCheckInterval = IniRead($gIniFile, "Interval", "Troop Training Check", 180000)
   DebugWrite("Setting Interval Troop Training Check = " & $gTroopTrainingCheckInterval)
   Global $gPauseBetweenNexts = IniRead($gIniFile, "Interval", "Pause Between Nexts", 2000)  ; 2 seconds to avoid client out of sync errors
   DebugWrite("Setting Interval Pause Between Nexts = " & $gPauseBetweenNexts)

   ; Donate
   Global $gDonateMatchTroopStrings[$gTroopCountExcludingHeroes]
   $gDonateMatchTroopStrings[$eTroopBarbarian] = IniRead($gIniFile, "Donate", "Barbarian Match Strings", "barb")
   $gDonateMatchTroopStrings[$eTroopArcher] = IniRead($gIniFile, "Donate", "Archer Match Strings", "barb")
   $gDonateMatchTroopStrings[$eTroopGoblin] = IniRead($gIniFile, "Donate", "Goblin Match Strings", "barb")
   $gDonateMatchTroopStrings[$eTroopGiant] = IniRead($gIniFile, "Donate", "Giant Match Strings", "barb")
   $gDonateMatchTroopStrings[$eTroopWallBreaker] = IniRead($gIniFile, "Donate", "Wall Breaker Match Strings", "barb")
   $gDonateMatchTroopStrings[$eTroopBalloon] = IniRead($gIniFile, "Donate", "Balloon Match Strings", "barb")
   $gDonateMatchTroopStrings[$eTroopWizard] = IniRead($gIniFile, "Donate", "Wizard Match Strings", "barb")
   $gDonateMatchTroopStrings[$eTroopHealer] = IniRead($gIniFile, "Donate", "Healer Match Strings", "barb")
   $gDonateMatchTroopStrings[$eTroopDragon] = IniRead($gIniFile, "Donate", "Dragon Match Strings", "barb")
   $gDonateMatchTroopStrings[$eTroopPekka] = IniRead($gIniFile, "Donate", "Pekka Match Strings", "barb")
   $gDonateMatchTroopStrings[$eTroopMinion] = IniRead($gIniFile, "Donate", "Minion Match Strings", "barb")
   $gDonateMatchTroopStrings[$eTroopHogRider] = IniRead($gIniFile, "Donate", "Hog Rider Match Strings", "barb")
   $gDonateMatchTroopStrings[$eTroopValkyrie] = IniRead($gIniFile, "Donate", "Valkyrie Match Strings", "barb")
   $gDonateMatchTroopStrings[$eTroopGolem] = IniRead($gIniFile, "Donate", "Golem Match Strings", "barb")
   $gDonateMatchTroopStrings[$eTroopWitch] = IniRead($gIniFile, "Donate", "Witch Match Strings", "barb")
   $gDonateMatchTroopStrings[$eTroopLavaHound] = IniRead($gIniFile, "Donate", "Lava Hound Match Strings", "barb")

   Global $gDonateMatchSpellStrings[$eSpellCount]
   $gDonateMatchSpellStrings[$eSpellPoison] = IniRead($gIniFile, "Donate", "Poison Match Strings", "poison")
   $gDonateMatchSpellStrings[$eSpellEarthquake] = IniRead($gIniFile, "Donate", "Earthquake Match Strings", "quake")
   $gDonateMatchSpellStrings[$eSpellHaste] = IniRead($gIniFile, "Donate", "Haste Match Strings", "haste")
   Global $gSpellDefaultDonate = IniRead($gIniFile, "Donate", "Spell Default", "poison")

   Global $gDonateMatchNegativeStrings = StringSplit(IniRead($gIniFile, "Donate", "Negative Match Strings", "but|except"), "|")

   Global $gDonateMatchDarkStrings = StringSplit(IniRead($gIniFile, "Donate", "Dark Match Strings", "any"), "|")
   Global $gDonateMatchDarkTroops = StringSplit(IniRead($gIniFile, "Donate", "Use For Dark", _
	  "Lava Hound|Witch|Golem|Valkyrie|Minion"), "|")

   Global $gDonateMatchAirStrings = StringSplit(IniRead($gIniFile, "Donate", "Air Match Strings", "air|fly|flies"), "|")
   Global $gDonateMatchAirTroops = StringSplit(IniRead($gIniFile, "Donate", "Use For Air", _
	  "Lava Hound|Minion|Dragon|Healer|Balloon"), "|")

   Global $gDonateMatchGroundStrings = StringSplit(IniRead($gIniFile, "Donate", "Gound Match Strings", "ground"), "|")
   Global $gDonateMatchGroundTroops = StringSplit(IniRead($gIniFile, "Donate", "Use For Gound", _
	  "Witch|Golem|Valkyrie|Hog Rider|Pekka|Wizard|Giant|Archer|Barbarian"), "|")

   Global $gDonateMatchFarmStrings = StringSplit(IniRead($gIniFile, "Donate", "Farm Match Strings", "farm|defense"), "|")
   Global $gDonateMatchFarmTroops = StringSplit(IniRead($gIniFile, "Donate", "Use For Farm", _
	  "Witch|Minion|Pekka|Dragon|Wizard|Balloon|Giant|Archer|Barbarian"), "|")

   Global $gDonateMatchAnyStrings = StringSplit(IniRead($gIniFile, "Donate", "Any Match Strings", "any"), "|")
   Global $gDonateMatchAnyTroops = StringSplit(IniRead($gIniFile, "Donate", "Use For Any", _
	  "Lava Hound|Witch|Golem|Valkyrie|Minion|Pekka|Dragon|Wizard|Balloon|Giant|Archer|Barbarian"), "|")
EndFunc

Func SaveSettings()
   ; Settings derived from the GUI are saved on close
   IniWrite($gIniFile, "General", "Gold", GUICtrlRead($GUI_GoldEdit))
   IniWrite($gIniFile, "General", "Elixir", GUICtrlRead($GUI_ElixEdit))
   IniWrite($gIniFile, "General", "Dark Elixir", GUICtrlRead($GUI_DarkEdit))
   IniWrite($gIniFile, "General", "Town Hall", GUICtrlRead($GUI_TownHallEdit))
   IniWrite($gIniFile, "General", "Use Breakers", _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers))
   IniWrite($gIniFile, "General", "Breaker Count", GUICtrlRead($GUI_AutoRaidBreakerCountEdit))
   IniWrite($gIniFile, "General", "Dump Cups", _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups))
   IniWrite($gIniFile, "General", "Dump Cups Threshold", GUICtrlRead($GUI_AutoRaidDumpCupsThreshold))
   IniWrite($gIniFile, "General", "Dead Bases Only", _GUICtrlButton_GetCheck($GUI_AutoRaidDeadBases))
   IniWrite($gIniFile, "General", "Ignore Storages", _GUICtrlButton_GetCheck($GUI_AutoRaidIgnoreStorages))
   IniWrite($gIniFile, "General", "Snipe Exposed TH",  _GUICtrlButton_GetCheck($GUI_AutoRaidSnipeExposedTH))
   IniWrite($gIniFile, "General", "Wait For Heroes", _GUICtrlComboBox_GetCurSel($GUI_AutoRaidWaitForHeroesCombo))
   IniWrite($gIniFile, "General", "Raid Strategy", _GUICtrlComboBox_GetCurSel($GUI_AutoRaidStrategyCombo))
   IniWrite($gIniFile, "General", "Background Mode", _GUICtrlButton_GetCheck($GUI_BackgroundModeCheckBox))

   DebugWrite("SaveSettings() Settings saved")
EndFunc

Func _Boolean($fValue)
   If IsBool($fValue) Then Return $fValue
   If IsString($fValue) Then Return $fValue="True"
   Return Number($fValue) >= 1
EndFunc
