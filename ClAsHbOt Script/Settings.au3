Func ReadSettings()
   ; Debug
   $gScraperDebug = _Boolean(IniRead($gIniFile, "Debug", "Scraper Debug", False))
   $gDebug = _Boolean(IniRead($gIniFile, "Debug", "Global Debug", True))

   ; Mouse
   ; Clicking method; use "MouseClick" for old way, or "ControlClick" for new way
   Global $gMouseClickMethod = IniRead($gIniFile, "Mouse", "Click Method", "MouseClick")
   DebugWrite("Setting Mouse Click Method = " & $gMouseClickMethod)
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

   ; Confidence Levels
   Global $gConfidenceTownHall = IniRead($gIniFile, "Confidence", "Town Hall", 0.95)
   Global $gConfidenceCollectLoot = IniRead($gIniFile, "Confidence", "Collect Loot", 0.95)
   Global $gConfidenceArmyCamp = IniRead($gIniFile, "Confidence", "Army Camp", 0.94)
   Global $gConfidenceBarracks = IniRead($gIniFile, "Confidence", "Barracks", 0.95)
   Global $gConfidenceCollector =IniRead($gIniFile, "Confidence", "Collector",  0.92)
   Global $gConfidenceDEStorage = IniRead($gIniFile, "Confidence", "Dark Elixir Storage", 0.95)
   Global $gConfidenceRaidTroopSlot = IniRead($gIniFile, "Confidence", "Raid Troop Slot", 0.98)
   Global $gConfidenceDonateTroopSlot = IniRead($gIniFile, "Confidence", "Donate Troop Slot", 0.99)
   Global $gConfidenceBarracksTroopSlot = IniRead($gIniFile, "Confidence", "Barracks Troop Slot", 0.99)
   Global $gConfidenceTrainTroopsButton = IniRead($gIniFile, "Confidence", "Train Troops Button", 0.99)
   Global $gConfidenceStorages = IniRead($gIniFile, "Confidence", "Storages", 0.95)

   ; Intervals
   Global $gOnlineCheckInterval = IniRead($gIniFile, "Interval", "Online Check", 15000)
   DebugWrite("Setting Interval Online Check = " & $gOnlineCheckInterval)
   Global $gCollectLootInterval = IniRead($gIniFile, "Interval", "Collect Loot", 180000)
   DebugWrite("Setting Interval Collect Loot = " & $gCollectLootInterval)
   Global $gTroopTrainingCheckInterval = IniRead($gIniFile, "Interval", "Troop Training Check", 180000)
   DebugWrite("Setting Interval Troop Training Check = " & $gTroopTrainingCheckInterval)
   ;Global $gQueueDonatableTroopsInterval = IniRead($gIniFile, "Interval", "Queue Donatable Troops", 600000)
   ;DebugWrite("Setting Interval Queue Donatable Troops = " & $gQueueDonatableTroopsInterval)
   Global $gPauseBetweenNexts = IniRead($gIniFile, "Interval", "Pause Between Nexts", 2000)  ; 2 seconds to avoid client out of sync errors
   DebugWrite("Setting Interval Pause Between Nexts = " & $gPauseBetweenNexts)

   ; Donate
   Global $gDonateMatchTroopStrings[$eTroopCount-2]
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

   ;Global $gDonateBarracksStandardMaximum = IniRead($gIniFile, "Donate", "Donate Barracks Standard Maximum", 4)
   ;Global $gDonateBarracksDarkMaximum = IniRead($gIniFile, "Donate", "Donate Barracks Dark Maximum", 2)

   ;Global $gDonateTroopStock[$eTroopCount-2]
   ;$gDonateTroopStock[$eTroopBarbarian] = Number(IniRead($gIniFile, "Donate", "Barbarian Stock Amount", 0))
   ;$gDonateTroopStock[$eTroopArcher] = Number(IniRead($gIniFile, "Donate", "Archer Stock Amount", 0))
   ;$gDonateTroopStock[$eTroopGoblin] = Number(IniRead($gIniFile, "Donate", "Goblin Stock Amount", 0))
   ;$gDonateTroopStock[$eTroopGiant] = Number(IniRead($gIniFile, "Donate", "Giant Stock Amount", 0))
   ;$gDonateTroopStock[$eTroopWallBreaker] = Number(IniRead($gIniFile, "Donate", "Wall Breaker Stock Amount", 0))
   ;$gDonateTroopStock[$eTroopBalloon] = Number(IniRead($gIniFile, "Donate", "Balloon Stock Amount", 0))
   ;$gDonateTroopStock[$eTroopWizard] = Number(IniRead($gIniFile, "Donate", "Wizard Stock Amount", 0))
   ;$gDonateTroopStock[$eTroopHealer] = Number(IniRead($gIniFile, "Donate", "Healer Stock Amount", 0))
   ;$gDonateTroopStock[$eTroopDragon] = Number(IniRead($gIniFile, "Donate", "Dragon Stock Amount", 0))
   ;$gDonateTroopStock[$eTroopPekka] = Number(IniRead($gIniFile, "Donate", "Pekka Stock Amount", 0))
   ;$gDonateTroopStock[$eTroopMinion] = Number(IniRead($gIniFile, "Donate", "Minion Stock Amount", 0))
   ;$gDonateTroopStock[$eTroopHogRider] = Number(IniRead($gIniFile, "Donate", "Hog Rider Stock Amount", 0))
   ;$gDonateTroopStock[$eTroopValkyrie] = Number(IniRead($gIniFile, "Donate", "Valkyrie Stock Amount", 0))
   ;$gDonateTroopStock[$eTroopGolem] = Number(IniRead($gIniFile, "Donate", "Golem Stock Amount", 0))
   ;$gDonateTroopStock[$eTroopWitch] = Number(IniRead($gIniFile, "Donate", "Witch Stock Amount", 0))
   ;$gDonateTroopStock[$eTroopLavaHound] = Number(IniRead($gIniFile, "Donate", "Lava Hound Stock Amount", 0))

   ; TODO: Here are lines for the .ini file, once the "Queue to stock" logic is figured out
#cs
; This setting specifies the maximum number of barracks to use for stocking troops
Donate Barracks Standard Maximum=2
Donate Barracks Dark Maximum=2
; These settings dictate how much of each troop type to keep stocked for donations
Barbarian Stock Amount=5
Archer Stock Amount=5
Goblin Stock Amount=0
Giant Stock Amount=0
Wall Breaker Stock Amount=0
Balloon Stock Amount=0
Wizard Stock Amount=0
Healer Stock Amount=0
Dragon Stock Amount=0
Pekka Stock Amount=2
Minion Stock Amount=0
Hog Rider Stock Amount=0
Valkyrie Stock Amount=0
Golem Stock Amount=0
Witch Stock Amount=0
Lava Hound Stock Amount=0
#ce

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
   IniWrite($gIniFile, "General", "Raid Strategy", _GUICtrlComboBox_GetCurSel($GUI_AutoRaidStrategyCombo))
EndFunc

Func _Boolean($fValue)
   If IsBool($fValue) Then Return $fValue
   If IsString($fValue) Then Return $fValue="True"
   Return Number($fValue) >= 1
EndFunc
