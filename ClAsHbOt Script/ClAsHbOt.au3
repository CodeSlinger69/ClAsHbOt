#cs
ClAsHbOt!

Dec 10 Update To Do
- get 74 charmap for end bonus
- test on laptop screen
- donate function
- finish collecting storage images
- finish collecting collectors images

#ce

Opt("MustDeclareVars", 1)
Opt("GUIOnEventMode", 1)

; AutoIt includes
#include <ScreenCapture.au3>
#include <Date.au3>
#include <GDIPlus.au3>
#include <Math.au3>
#include <Array.au3>
#include <WinAPI.au3>
#include <File.au3>
#include <WindowsConstants.au3>

; CoC Bot Includes
#include <Globals.au3>
#include <FileNames.au3>
#include <GUI.au3>
#include <Settings.au3>
#include <Scraper.au3>
#include <TownHall.au3>
#include <ArmyManager.au3>
#include <KeepOnline.au3>
#include <CollectLoot.au3>
#include <AutoSnipe.au3>
#include <AutoRaid.au3>
#include <AutoQueue.au3>
#include <AutoRaidDumpCups.au3>
#include <AutoRaidStrategy0.au3>
#include <AutoRaidStrategy1.au3>
#include <AutoRaidStrategy2.au3>
#include <AutoRaidStrategy3.au3>
#include <Mouse.au3>
#include <BlueStacks.au3>
#include <Screen.au3>
#include <Donate.au3>


Main()

Func Main()

   StartBlueStacks()

   InitScraper()

   ReadSettings()
;DebugWrite("WhereAmI: " & WhereAmI())
;ZoomOut(False)

#cs
; Center 512, 398
Local $box[21][4]
Local $y = 325
Local $i = 0
For $x = 70 To 470 Step 20 ; x 70 to 510   y 398 to 70
   $box[$i][0] = $x
   $box[$i][1] = $y
   $box[$i][2] = $x+60
   $box[$i][3] = $y+40
   DebugWrite("NW Box: " & $i & " " & $box[$i][0] & "  " & $box[$i][1] & "  " & $box[$i][2] & "  " & $box[$i][3])
   $i+=1
   $y-=13
Next
#ce

;$gScraperDebug = True
;Local $gold = Number(ScrapeFuzzyText($gRaidLootCharMaps, $rGoldTextBox, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))
;DebugWrite("Gold: " & $gold)
;Local $elix = Number(ScrapeFuzzyText($gRaidLootCharMaps, $rElixTextBox, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))
;DebugWrite("Elix: " & $elix)
;Local $dark = 0
;Local $cups = 0
;If IsTextBoxPresent($rDarkTextBox)=False Then
;   $cups = Number(ScrapeFuzzyText($gRaidLootCharMaps, $rCupsTextBox1, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))
;Else
;   $dark = Number(ScrapeFuzzyText($gRaidLootCharMaps, $rDarkTextBox, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))
;   $cups = Number(ScrapeFuzzyText($gRaidLootCharMaps, $rCupsTextBox2, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))
;EndIf
;DebugWrite("Dark: " & $dark)
;DebugWrite("Cups: " & $cups)
;Local $deadBase = IsColorPresent($rDeadBaseIndicatorColor)
;DebugWrite("Dead: " & $deadBase)
;Local $location, $top, $left
;Local $townHall = GetTownHallLevel($location, $left, $top)
;DebugWrite("TH: " & $townHall)

#cs
Local $goldWin = ScrapeFuzzyText($gBattleEndCharacterMaps, $rEndBattleGoldTextBox, $gBattleEndCharMapsMaxWidth, $eScrapeDropSpaces)
Local $elixWin = ScrapeFuzzyText($gBattleEndCharacterMaps, $rEndBattleElixTextBox, $gBattleEndCharMapsMaxWidth, $eScrapeDropSpaces)
Local $darkWin = IsTextBoxPresent($rEndBattleDarkTextBox) ? ScrapeFuzzyText($gBattleEndCharacterMaps, $rEndBattleDarkTextBox, $gBattleEndCharMapsMaxWidth, $eScrapeDropSpaces) : 0
Local $cupsWin = IsTextBoxPresent($rEndBattleCups1TextBox) ? _
				 ScrapeFuzzyText($gBattleEndCharacterMaps, $rEndBattleCups1TextBox, $gBattleEndCharMapsMaxWidth, $eScrapeDropSpaces) : _
				 ScrapeFuzzyText($gBattleEndCharacterMaps, $rEndBattleCups2TextBox, $gBattleEndCharMapsMaxWidth, $eScrapeDropSpaces)
DebugWrite("Gold: " & $goldWin)
DebugWrite("Elix: " & $elixWin)
DebugWrite("Dark: " & $darkWin)
DebugWrite("Cups: " & $cupsWin)
#ce

#cs
Local $goldBonus = 0
Local $elixBonus = 0
Local $darkBonus = 0
If IsTextBoxPresent($rEndBattleBonusGoldTextBox) Or _
   IsTextBoxPresent($rEndBattleBonusElixTextBox) Or _
   IsTextBoxPresent($rEndBattleBonusDarkTextBox) Then

   $goldBonus = ScrapeFuzzyText($gSmallCharacterMaps, $rEndBattleBonusGoldTextBox, $gSmallCharMapsMaxWidth, $eScrapeDropSpaces)
   $goldBonus = StringLeft($goldBonus, 1) = "+" ? StringMid($goldBonus, 2) : 0
   $elixBonus = ScrapeFuzzyText($gSmallCharacterMaps, $rEndBattleBonusElixTextBox, $gSmallCharMapsMaxWidth, $eScrapeDropSpaces)
   $elixBonus = StringLeft($elixBonus, 1) = "+" ? StringMid($elixBonus, 2) : 0
   $darkBonus = ScrapeFuzzyText($gSmallCharacterMaps, $rEndBattleBonusDarkTextBox, $gSmallCharMapsMaxWidth, $eScrapeDropSpaces)
   $darkBonus = StringLeft($darkBonus, 1) = "+" ? StringMid($darkBonus, 2) : 0
   DebugWrite("Bonus this match: " & $goldBonus & " / " & $elixBonus & " / " & $darkBonus)
EndIf
#ce

#cs
GrabFrameToFile("StorageUsageFrame.bmp", 261, 200, 761, 550)
Local $x, $y, $conf, $matchIndex
Local $usageAdj = 10

ScanFrameForBestBMP("StorageUsageFrame.bmp", $GoldStorageBMPs, $gConfidenceStorages, $matchIndex, $conf, $x, $y)
DebugWrite("Gold Match Index: " & $matchIndex)
If $matchIndex <> -1 Then
   Local $s = $GoldStorageBMPs[$matchIndex]
   Local $level = Number(StringMid($s, StringInStr($s, "GoldStorageL")+12, 2))
   Local $usage = Number(StringMid($s, StringInStr($s, "GoldStorageL")+15, 2))
   $usage = ($usage+$usageAdj>100 ? 100 : $usage+$usageAdj)
   DebugWrite("Level " & $level & ", average " & $usage & "% full, confidence " & Round($conf*100, 2) & "%")
EndIf

ScanFrameForBestBMP("StorageUsageFrame.bmp", $ElixStorageBMPs, $gConfidenceStorages, $matchIndex, $conf, $x, $y)
DebugWrite("Elix Match Index: " & $matchIndex)
If $matchIndex <> -1 Then
   Local $s = $ElixStorageBMPs[$matchIndex]
   Local $level = Number(StringMid($s, StringInStr($s, "ElixStorageL")+12, 2))
   Local $usage = Number(StringMid($s, StringInStr($s, "ElixStorageL")+15, 2))
   $usage = ($usage+$usageAdj>100 ? 100 : $usage+$usageAdj)
   DebugWrite("Level " & $level & ", average " & $usage & "% full, confidence " & Round($conf*100, 2) & "%")
EndIf

ScanFrameForBestBMP("StorageUsageFrame.bmp", $DarkStorageBMPs, $gConfidenceStorages, $matchIndex, $conf, $x, $y)
DebugWrite("Dark Match Index: " & $matchIndex)
If $matchIndex <> -1 Then
   Local $s = $DarkStorageBMPs[$matchIndex]
   Local $level = Number(StringMid($s, StringInStr($s, "DarkStorageL")+12, 1))
   Local $usage = Number(StringMid($s, StringInStr($s, "DarkStorageL")+14, 2))
   $usage = ($usage+$usageAdj>100 ? 100 : $usage+$usageAdj)
   DebugWrite("Level " & $level & ", average " & $usage & "% full, confidence " & Round($conf*100, 2) & "%")
EndIf
#ce


;Exit

   InitGUI()

   MainApplicationLoop()
EndFunc

Func MainApplicationLoop()
   Local $lastOnlineCheckTimer = TimerInit()
   Local $lastCollectLootTimer = TimerInit()
   Local $lastQueueDonatableTroopsTimer = TimerInit()
   Local $lastTrainingCheckTimer = TimerInit()
   Local $autoSnipeTHLevel, $autoSnipeTHLocation, $autoSnipeTHLeft, $autoSnipeTHTop

   While 1
	  ;DebugWrite("Main loop: AutoRaid Stage " & $gAutoRaidStage)

	  ; Update status on GUI
	  GetMyLootNumbers()

	  ; Check for offline issues
	  If _GUICtrlButton_GetCheck($GUI_KeepOnlineCheckBox) = $BST_CHECKED And _
		 (TimerDiff($lastOnlineCheckTimer) >= $gOnlineCheckInterval Or $gKeepOnlineClicked) Then

		 $gKeepOnlineClicked = False

		 If WhereAmI()=$eScreenAndroidHome Then
			ResetToCoCMainScreen()
		 EndIf

		 CheckForAndroidMessageBox()
		 $lastOnlineCheckTimer = TimerInit()
		 UpdateCountdownTimers($lastOnlineCheckTimer, $lastCollectLootTimer, $lastTrainingCheckTimer)
	  EndIf

	  Local $autoInProgress = $gAutoStage=$eAutoFindMatch Or $gAutoStage=$eAutoExecute
	  If $autoInProgress=False Then

		 ; Donate Troops
		 If _GUICtrlButton_GetCheck($GUI_DonateTroopsCheckBox) = $BST_CHECKED  And _
			$gPossibleKick < 2 And _
			($gDonateTroopsClicked Or IsColorPresent($rNewChatMessagesColor)) Then

			$gDonateTroopsClicked = False

			ResetToCoCMainScreen()
			If WhereAmI()=$eScreenMain Then
			   ZoomOut(True)
			   DonateTroops()
			EndIf
		 EndIf

		 ; Queue Troops for Donation
		 #cs
		 If _GUICtrlButton_GetCheck($GUI_DonateTroopsCheckBox) = $BST_CHECKED And _
			$gPossibleKick < 2 And _
			(TimerDiff($lastQueueDonatableTroopsTimer) >= $gQueueDonatableTroopsInterval Or $gDonateTroopsStartup = True) Then

			$gDonateTroopsStartup = False

			ResetToCoCMainScreen()
			If WhereAmI()=$eScreenMain Then QueueDonatableTroops()
			$lastQueueDonatableTroopsTimer = TimerInit()
		 EndIf
		 #ce

		 ; Collect loot
		 If _GUICtrlButton_GetCheck($GUI_CollectLootCheckBox) = $BST_CHECKED  And _
			$gPossibleKick < 2 And _
			(TimerDiff($lastCollectLootTimer) >= $gCollectLootInterval Or $gCollectLootClicked) Then

			$gCollectLootClicked = False

			ResetToCoCMainScreen()
			If WhereAmI()=$eScreenMain Then
			   ZoomOut(True)
			   CollectLoot()
			EndIf
			$lastCollectLootTimer = TimerInit()
			UpdateCountdownTimers($lastOnlineCheckTimer, $lastCollectLootTimer, $lastTrainingCheckTimer)
		 EndIf

	  Endif ; If $autoRaidInProgress=False And $autoSnipeInProgress=False

	  ; Find a match
	  If _GUICtrlButton_GetCheck($GUI_FindMatchCheckBox) = $BST_CHECKED And _
		 $gPossibleKick < 2 Then

		 $gFindMatchClicked = False

		 ResetToCoCMainScreen()
		 ZoomOut(True)

		 If WhereAmI()=$eScreenMain Then
			If AutoRaidFindMatch() = True Then
			   _GUICtrlButton_SetCheck($GUI_FindMatchCheckBox, $BST_UNCHECKED)
			   _GUICtrlButton_Enable($GUI_AutoSnipeCheckBox, True)
			   _GUICtrlButton_Enable($GUI_AutoRaidCheckBox, True)
			EndIf
		 EndIf
	  EndIf

	  ; Auto Snipe
	  If _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox) = $BST_CHECKED And _
		 $gPossibleKick < 2 And _
		 IsButtonPresent($rAndroidMessageButton1) = False And _
		 IsButtonPresent($rAndroidMessageButton2) = False Then

		 $gAutoSnipeClicked = False
		 CheckForAndroidMessageBox()

		 AutoSnipe($lastTrainingCheckTimer, $autoSnipeTHLevel, $autoSnipeTHLocation, $autoSnipeTHLeft, $autoSnipeTHTop)
	  EndIf

	  ; Auto Raid / AutoSnipe, Dump Cups
	  If (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_CHECKED Or _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox) = $BST_CHECKED) And _
		 _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups) = $BST_CHECKED And _
		 $gPossibleKick < 2 And _
		 IsButtonPresent($rAndroidMessageButton1) = False And _
		 IsButtonPresent($rAndroidMessageButton2) = False Then

		 DumpCups()
	  EndIf

	  ; Auto Raid, Attack
	  If _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_CHECKED And _
		 $gPossibleKick < 2 And _
		 IsButtonPresent($rAndroidMessageButton1) = False And _
		 IsButtonPresent($rAndroidMessageButton2) = False Then

		 $gAutoRaidClicked = False
		 CheckForAndroidMessageBox()

		 AutoRaid($lastTrainingCheckTimer)
	  EndIf

	  ; Pause for 5 seconds
	  For $i = 1 To 10
		 UpdateCountdownTimers($lastOnlineCheckTimer, $lastCollectLootTimer, $lastTrainingCheckTimer)

		 If $gKeepOnlineClicked Or $gCollectLootClicked Or $gDonateTroopsClicked Or $gFindMatchClicked Or $gAutoSnipeClicked Or $gAutoRaidClicked Then ExitLoop
		 If $gAutoStage=$eAutoFindMatch Or $gAutoStage=$eAutoExecute Then ExitLoop
		 If _GUICtrlButton_GetCheck($GUI_KeepOnlineCheckBox) = $BST_CHECKED And TimerDiff($lastOnlineCheckTimer) >= $gOnlineCheckInterval Then ExitLoop
		 If _GUICtrlButton_GetCheck($GUI_CollectLootCheckBox) = $BST_CHECKED And TimerDiff($lastCollectLootTimer) >= $gCollectLootInterval Then ExitLoop
		 If _GUICtrlButton_GetCheck($GUI_DonateTroopsCheckBox) = $BST_CHECKED And IsColorPresent($rNewChatMessagesColor) Then ExitLoop

		 Sleep(500)
	  Next

	  ; Reset kick detection if timer > 5 minutes
	  If $gPossibleKick > 0 And TimerDiff($gLastPossibleKickTime) > 60000*5 Then
		 DebugWrite("Possible Kick timer expiration, resetting.")
		 $gPossibleKick = 0
	  EndIf

	  If $gPossibleKick >= 2 Then
		 Local $ms = 60000*5 - TimerDiff($gLastPossibleKickTime)
		 GUICtrlSetData($GUI_AutoStatus, "Auto: Possible kick, waiting " & millisecondToMMSS($ms))
	  EndIf

   WEnd
EndFunc

Func UpdateCountdownTimers(Const $onlineTimer, Const $lootTimer, Const $trainingTimer)
   If _GUICtrlButton_GetCheck($GUI_KeepOnlineCheckBox) = $BST_UNCHECKED Then
	  GUICtrlSetData($GUI_KeepOnlineCheckBox, "F5 Keep Online 0:00")
   Else
	  Local $ms = $gOnlineCheckInterval - TimerDiff($onlineTimer)
	  If $ms < 0 Then $ms = 0
	  GUICtrlSetData($GUI_KeepOnlineCheckBox, "F5 Keep Online " & millisecondToMMSS($ms))
   EndIf

   If _GUICtrlButton_GetCheck($GUI_CollectLootCheckBox) = $BST_UNCHECKED Then
	  GUICtrlSetData($GUI_CollectLootCheckBox, "F6 Collect Loot 0:00")
   Else
	  Local $ms = $gCollectLootInterval - TimerDiff($lootTimer)
	  If $ms < 0 Then $ms = 0
	  GUICtrlSetData($GUI_CollectLootCheckBox, "F6 Collect Loot " & millisecondToMMSS($ms))
   EndIf

   If (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_CHECKED Or _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox) = $BST_CHECKED) And _
	  $gAutoStage = $eAutoWaitForTrainingToComplete Then

	  Local $ms = $gTroopTrainingCheckInterval - TimerDiff($trainingTimer)
	  If $ms < 0 Then $ms = 0
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Waiting For Training " & millisecondToMMSS($ms))
   EndIf
EndFunc

Func millisecondToMMSS(Const $ms)
   Local $m = Int(Mod($ms, 1000*60*60) / (1000*60))
   Local $s = Int(Mod(Mod($ms, 1000*60*60), 1000*60) / 1000)

   Return $m & ":" & StringRight("00" & $s, 2);
EndFunc

Func GetMyLootNumbers()
   ;DebugWrite("GetMyLootNumbers()")

   ; My loot is only scrapable on some screens
   If WhereAmI()<>$eScreenMain And WhereAmI()<>$eScreenWaitRaid And WhereAmI()<>$eScreenLiveRaid Then
	  Return
   EndIf

   ; My loot info can't be seen for some reason
   If IsTextBoxPresent($rMyGoldTextBox) = True Then
	  ; Scrape text fields
	  Local $MyGold = Number(ScrapeFuzzyText($gSmallCharacterMaps, $rMyGoldTextBox, $gSmallCharMapsMaxWidth, $eScrapeDropSpaces))
	  Local $MyElix = Number(ScrapeFuzzyText($gSmallCharacterMaps, $rMyElixTextBox, $gSmallCharMapsMaxWidth, $eScrapeDropSpaces))

	  Local $MyDark = 0
	  If IsTextBoxPresent($rMyGemsTextBoxWithDE) = True Then
		 $MyDark = Number(ScrapeFuzzyText($gSmallCharacterMaps, $rMyDarkTextBox, $gSmallCharMapsMaxWidth, $eScrapeDropSpaces))
	  EndIf

	  Local $MyGems = 0
	  If IsTextBoxPresent($rMyGemsTextBoxNoDE) = True Then
		 $MyGems = Number(ScrapeFuzzyText($gSmallCharacterMaps, $rMyGemsTextBoxNoDE, $gSmallCharMapsMaxWidth, $eScrapeDropSpaces))
	  Else
		 $MyGems = Number(ScrapeFuzzyText($gSmallCharacterMaps, $rMyGemsTextBoxWithDE, $gSmallCharMapsMaxWidth, $eScrapeDropSpaces))
	  EndIf

	  GUICtrlSetData($GUI_MyGold, $MyGold)
	  GUICtrlSetData($GUI_MyElix, $MyElix)
	  GUICtrlSetData($GUI_MyDark, $MyDark)
	  GUICtrlSetData($GUI_MyGems, $MyGems)
   EndIf

   ; My cups and my town hall can only be scraped from the main screen
   If WhereAmI() = $eScreenMain Then
	  Local $MyCups = Number(ScrapeFuzzyText($gSmallCharacterMaps, $rMyCupsTextBox, $gSmallCharMapsMaxWidth, $eScrapeDropSpaces))
	  GUICtrlSetData($GUI_MyCups, $MyCups)

	  ; Only search for my town hall level if we don't already know it
	  Local $GUIMyTownHall = GUICtrlRead($GUI_MyTownHall)
	  If $GUIMyTownHall = 0 Then
		 ZoomOut(False)

		 Local $location, $top, $left
		 Local $MyTownHall = GetTownHallLevel($location, $left, $top)

		 If $MyTownHall = -1 Then
			   DebugWrite("Could not detect Town Hall level")
			   $MyTownHall = InputBox("Town Hall level not found", "Please enter the Town Hall level of your village.")
		 EndIf

		 GUICtrlSetData($GUI_MyTownHall, $MyTownHall)
	  EndIf
   EndIf

EndFunc

Func DebugWrite($text)
   If $gDebug Then
	  ConsoleWrite(_NowDate() & " " & _NowTime() & " " & $text & @CRLF)
	  FileWrite("ClashBotLog.txt", _NowDate() & " " & _NowTime() & " " & $text & @CRLF)
   EndIf
EndFunc

Func TimeStamp()
   Return StringReplace(StringReplace(StringStripWS(_NowCalc(),$STR_STRIPALL),"/",""),":","")
EndFunc