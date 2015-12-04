#cs
ClAsHbOt!
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
		 IsButtonPresent($rAndroidMessageButton) = False Then

		 $gAutoSnipeClicked = False
		 CheckForAndroidMessageBox()

		 AutoSnipe($lastTrainingCheckTimer, $autoSnipeTHLevel, $autoSnipeTHLocation, $autoSnipeTHLeft, $autoSnipeTHTop)
	  EndIf

	  ; Auto Raid / AutoSnipe, Dump Cups
	  If (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_CHECKED Or _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox) = $BST_CHECKED) And _
		 _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups) = $BST_CHECKED And _
		 $gPossibleKick < 2 And _
		 IsButtonPresent($rAndroidMessageButton) = False Then

		 DumpCups()
	  EndIf

	  ; Auto Raid, Attack
	  If _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_CHECKED And _
		 $gPossibleKick < 2 And _
		 IsButtonPresent($rAndroidMessageButton) = False Then

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