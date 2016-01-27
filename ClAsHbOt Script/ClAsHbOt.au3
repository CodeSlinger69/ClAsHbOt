#cs
ClAsHbOt!

Atutomatic farming bot for Clash of Clans, with a few other features.

Dec 10 Update To Do
- Finish collecting storage images
  - Dark: 5.50
  - Gold: 10.75, 12.25, 12.50
  - Elix: 12.00, 12.75
- Test BAM and loonion strategies

Massive rework todo
- Battle end bonus char maps - "74" needed?
- $rAttackingDisabledPoint1Color, 2, 3

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
#include <SendMessage.au3>

; CoC Bot Includes
#include <Globals.au3>
#include <FileNames.au3>
#include <Version.au3>
#include <ClAsHbOtDlL.au3>
#include <CharMaps.au3>
#include <RegionDefs.au3>
#include <GUI.au3>
#include <Settings.au3>
#include <Scraper.au3>
#include <ArmyManager.au3>
#include <CollectLoot.au3>
#include <AutoPush.au3>
#include <AutoRaid.au3>
#include <AutoRaidDumpCups.au3>
#include <AutoRaidStrategy0.au3>
#include <AutoRaidStrategy1.au3>
#include <AutoRaidStrategy2.au3>
#include <AutoRaidStrategy3.au3>
#include <Mouse.au3>
#include <BlueStacks.au3>
#include <Screen.au3>
#include <Donate.au3>
#include <Test.au3>
#include <DefenseFarm.au3>

Main()

Func Main()
   DLLLoad()

   StartBlueStacks()

   InitScraper()

   ReadSettings()

;MsgBox($MB_OK, "", "Waiting")
;Local $f = CaptureFrame("Test")
;DebugWrite("WhereAmI: " & WhereAmI($f))
;ZoomOut2()
;$gScraperDebug = True
;$gDebugSaveScreenCaptures = True
;TestMyStuff()
;TestRaidLoot()
;TestRaidTroopsCount()
;TestBarracksStatus()
;TestBuiltTroops()
;TestEndBattleLoot()
;TestEndBattleBonus()
;TestDeployBoxCalcs()
;TestDonate()
;TestTownHall()
;TestCollectors()
;TestStorage()
;DLLStoreFrame($f)
;_GDIPlus_BitmapDispose($f)
;TestCollectMyLoot()
;Exit

   InitGUI()

   MainApplicationLoop()
EndFunc

Func MainApplicationLoop()
   Local $lastOnlineCheckTimer = TimerInit()
   Local $lastCollectLootTimer = TimerInit()
   Local $lastQueueDonatableTroopsTimer = TimerInit()
   Local $lastTrainingCheckTimer = TimerInit()
   Local $lastDefenseFarmTimer = TimerInit()
   Local $snipeTHCorner

   While 1
	  ; Get frame
	  Local $frame = CaptureFrame("MainApplicationLoop, Stage " & $gAutoStage)

	  ; Update status on GUI
	  GetMyLootNumbers($frame)

	  ; Does loot tracking need updating?
	  If $gAutoNeedToCollectStartingLoot Then
		 CaptureAutoBeginLoot()
		 $gAutoNeedToCollectStartingLoot = False
	  EndIf

	  If $gAutoNeedToCollectEndingLoot Then
		 CaptureAutoEndLoot()
		 $gAutoNeedToCollectEndingLoot = False
	  EndIf

	  ; Check for offline issues
	  If _GUICtrlButton_GetCheck($GUI_KeepOnlineCheckBox) = $BST_CHECKED And _
		 (TimerDiff($lastOnlineCheckTimer) >= $gOnlineCheckInterval Or $gKeepOnlineClicked) Then

		 $gKeepOnlineClicked = False

		 If WhereAmI($frame)=$eScreenAndroidHome Then ResetToCoCMainScreen($frame)

		 CheckForAndroidMessageBox($frame)
		 $lastOnlineCheckTimer = TimerInit()
		 UpdateCountdownTimers($lastOnlineCheckTimer, $lastCollectLootTimer, $lastTrainingCheckTimer, $lastDefenseFarmTimer)
	  EndIf

	  Local $autoInProgress = $gAutoStage=$eAutoFindMatch Or $gAutoStage=$eAutoExecuteRaid Or $gAutoStage=$eAutoExecuteSnipe Or _
		 _GUICtrlButton_GetCheck($GUI_DefenseFarmCheckBox)=$BST_CHECKED

	  If $autoInProgress=False Then

		 ; Donate Troops
		 If _GUICtrlButton_GetCheck($GUI_DonateTroopsCheckBox) = $BST_CHECKED And _
			$gPossibleKick < 2 And _
			($gDonateTroopsClicked Or IsColorPresent($frame, $rNewChatMessagesColor)) Then

			$gDonateTroopsClicked = False

			ResetToCoCMainScreen($frame)

			If WhereAmI($frame)=$eScreenMain Then DonateTroops($frame)
		 EndIf

		 ; Collect loot
		 If _GUICtrlButton_GetCheck($GUI_CollectLootCheckBox) = $BST_CHECKED And _
			$gPossibleKick < 2 And _
			(TimerDiff($lastCollectLootTimer) >= $gCollectLootInterval Or $gCollectLootClicked) Then

			$gCollectLootClicked = False

			If WhereAmI($frame) = $eScreenMain Then
			   ZoomOut2($frame)
			Else
			   ResetToCoCMainScreen($frame)
			EndIf

			If WhereAmI($frame)=$eScreenMain Then CollectLoot($frame)
			$lastCollectLootTimer = TimerInit()
			UpdateCountdownTimers($lastOnlineCheckTimer, $lastCollectLootTimer, $lastTrainingCheckTimer, $lastDefenseFarmTimer)
		 EndIf

	  Endif ; If $autoInProgress=False...

	  ; Find a match
	  If _GUICtrlButton_GetCheck($GUI_FindMatchCheckBox) = $BST_CHECKED And _
		 $gPossibleKick < 2 Then

		 $gFindMatchClicked = False

		 If WhereAmI($frame) = $eScreenMain Then
			ZoomOut2($frame)
		 Else
			ResetToCoCMainScreen($frame)
		 EndIf

		 If WhereAmI($frame)=$eScreenMain Then
			Local $dummy
			If AutoRaidFindMatch($frame, False, $dummy) = True Then
			   _GUICtrlButton_SetCheck($GUI_FindMatchCheckBox, $BST_UNCHECKED)
			   _GUICtrlButton_Enable($GUI_AutoPushCheckBox, True)
			   _GUICtrlButton_Enable($GUI_AutoRaidCheckBox, True)
			EndIf
		 EndIf
	  EndIf

	  ; Auto Push
	  If _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox) = $BST_CHECKED And _
		 $gPossibleKick < 2 And _
		 IsButtonPresent($frame, $rAndroidMessageButton1) = False And _
		 IsButtonPresent($frame, $rAndroidMessageButton2) = False Then

		 $gAutoPushClicked = False
		 CheckForAndroidMessageBox($frame)

		 AutoPush($frame, $lastTrainingCheckTimer, $snipeTHCorner)
	  EndIf

	  ; Auto Raid / AutoPush, Dump Cups
	  If (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_CHECKED Or _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox) = $BST_CHECKED) And _
		 _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups) = $BST_CHECKED And _
		 $gPossibleKick < 2 And _
		 IsButtonPresent($frame, $rAndroidMessageButton1) = False And _
		 IsButtonPresent($frame, $rAndroidMessageButton2) = False Then

		 DumpCups($frame)
	  EndIf

	  ; Auto Raid, Attack
	  If _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_CHECKED And _
		 $gPossibleKick < 2 And _
		 IsButtonPresent($frame, $rAndroidMessageButton1) = False And _
		 IsButtonPresent($frame, $rAndroidMessageButton2) = False Then

		 $gAutoRaidClicked = False
		 CheckForAndroidMessageBox($frame)

		 AutoRaid($frame, $lastTrainingCheckTimer, $snipeTHCorner)
	  EndIf

	  ; Defense Farm
	  If _GUICtrlButton_GetCheck($GUI_DefenseFarmCheckBox) = $BST_CHECKED And _
		 $gPossibleKick < 2 And _
		 IsButtonPresent($frame, $rAndroidMessageButton1) = False And _
		 IsButtonPresent($frame, $rAndroidMessageButton2) = False Then

		 $gDefenseFarmClicked = False

		 DefenseFarm($frame, $lastDefenseFarmTimer)
	  EndIf

	  ; Pause for 5 seconds
	  Local $t=TimerInit()
	  While TimerDiff($t)<5000
		 UpdateCountdownTimers($lastOnlineCheckTimer, $lastCollectLootTimer, $lastTrainingCheckTimer, $lastDefenseFarmTimer)

		 If ($gKeepOnlineClicked Or $gCollectLootClicked Or $gDonateTroopsClicked Or $gFindMatchClicked Or $gAutoPushClicked Or $gAutoRaidClicked) And _
			_GUICtrlButton_GetCheck($GUI_DefenseFarmCheckBox)<>$BST_CHECKED Then ExitLoop
		 If $gAutoStage=$eAutoFindMatch Or $gAutoStage=$eAutoExecuteRaid Or $gAutoStage=$eAutoExecuteSnipe Then ExitLoop
		 If _GUICtrlButton_GetCheck($GUI_KeepOnlineCheckBox) = $BST_CHECKED And TimerDiff($lastOnlineCheckTimer) >= $gOnlineCheckInterval Then ExitLoop
		 If _GUICtrlButton_GetCheck($GUI_CollectLootCheckBox) = $BST_CHECKED And TimerDiff($lastCollectLootTimer) >= $gCollectLootInterval Then ExitLoop
		 If _GUICtrlButton_GetCheck($GUI_DefenseFarmCheckBox) = $BST_CHECKED And TimerDiff($lastDefenseFarmTimer) >= $gDefenseFarmOfflineTime Then ExitLoop
		 If _GUICtrlButton_GetCheck($GUI_DonateTroopsCheckBox) = $BST_CHECKED And IsColorPresent($frame, $rNewChatMessagesColor) Then ExitLoop

		 Sleep(400)
	  WEnd

	  ; Reset kick detection if timer > 5 minutes
	  If $gPossibleKick > 0 And TimerDiff($gLastPossibleKickTime) > 60000*5 Then
		 DebugWrite("Possible Kick timer expiration, resetting.")
		 $gPossibleKick = 0
	  EndIf

	  If $gPossibleKick >= 2 Then
		 Local $ms = 60000*5 - TimerDiff($gLastPossibleKickTime)
		 GUICtrlSetData($GUI_AutoStatus, "Auto: Possible kick, waiting " & millisecondToMMSS($ms))
	  EndIf


	  _GDIPlus_BitmapDispose($frame)
   WEnd
EndFunc

Func UpdateCountdownTimers(Const $onlineTimer, Const $lootTimer, Const $trainingTimer, Const $defenseFarmTimer)

   ; Keep online
   If _GUICtrlButton_GetCheck($GUI_KeepOnlineCheckBox) = $BST_UNCHECKED Then
	  GUICtrlSetData($GUI_KeepOnlineCheckBox, "F5 Keep Online 0:00")
   Else
	  Local $ms = $gOnlineCheckInterval - TimerDiff($onlineTimer)
	  If $ms < 0 Then $ms = 0
	  GUICtrlSetData($GUI_KeepOnlineCheckBox, "F5 Keep Online " & millisecondToMMSS($ms))
   EndIf

   ; Collect loot
   If _GUICtrlButton_GetCheck($GUI_CollectLootCheckBox) = $BST_UNCHECKED Then
	  GUICtrlSetData($GUI_CollectLootCheckBox, "F6 Collect Loot 0:00")
   ElseIf _GUICtrlButton_GetCheck($GUI_DefenseFarmCheckBox) = $BST_CHECKED Then
	  GUICtrlSetData($GUI_CollectLootCheckBox, "F6 Collect Loot -:--")
   Else
	  Local $ms = $gCollectLootInterval - TimerDiff($lootTimer)
	  If $ms < 0 Then $ms = 0
	  GUICtrlSetData($GUI_CollectLootCheckBox, "F6 Collect Loot " & millisecondToMMSS($ms))
   EndIf

   ; Auto Raid
   If (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_CHECKED Or _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox) = $BST_CHECKED) And _
	  $gAutoStage = $eAutoWaitForTrainingToComplete Then

	  Local $ms = $gTroopTrainingCheckInterval - TimerDiff($trainingTimer)
	  If $ms < 0 Then $ms = 0
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Waiting For Training " & millisecondToMMSS($ms))
   EndIf

   ; Defense Farm
   If _GUICtrlButton_GetCheck($GUI_DefenseFarmCheckBox) = $BST_UNCHECKED Then
	  GUICtrlSetData($GUI_DefenseFarmCheckBox, "Defense Farm 00:00")
   Else
	  Local $ms = $gDefenseFarmOfflineTime - TimerDiff($defenseFarmTimer)
	  If $ms < 0 Then $ms = 0
	  GUICtrlSetData($GUI_DefenseFarmCheckBox, "Defense Farm " & millisecondToMMSS($ms))
   EndIf

EndFunc

Func millisecondToMMSS(Const $ms)
   Local $m = Int(Mod($ms, 1000*60*60) / (1000*60))
   Local $s = Int(Mod(Mod($ms, 1000*60*60), 1000*60) / 1000)

   Return $m & ":" & StringRight("00" & $s, 2);
EndFunc

Func GetMyLootNumbers($frame)
   ;DebugWrite("GetMyLootNumbers()")

   ; My loot is only scrapable on some screens
   If WhereAmI($frame)=$eScreenMain Or WhereAmI($frame)=$eScreenWaitRaid Or WhereAmI($frame)=$eScreenLiveRaid Then

	  Local $MyGold = 0
	  If IsTextBoxPresent($frame, $rMyGoldTextBox) = True Then
		 $MyGold = Number(ScrapeFuzzyText($frame, $gSmallCharacterMaps, $rMyGoldTextBox, $gSmallCharMapsMaxWidth, $eScrapeDropSpaces))
		 GUICtrlSetData($GUI_MyGold, $MyGold)
	  EndIf

	  Local $MyElix = 0
	  If IsTextBoxPresent($frame, $rMyElixTextBox) = True Then
		 $MyElix = Number(ScrapeFuzzyText($frame, $gSmallCharacterMaps, $rMyElixTextBox, $gSmallCharMapsMaxWidth, $eScrapeDropSpaces))
		 GUICtrlSetData($GUI_MyElix, $MyElix)
	  EndIf

	  Local $MyDark = 0
	  If IsTextBoxPresent($frame, $rMyGemsTextBoxWithDE) = True Then
		 $MyDark = Number(ScrapeFuzzyText($frame, $gSmallCharacterMaps, $rMyDarkTextBox, $gSmallCharMapsMaxWidth, $eScrapeDropSpaces))
		 GUICtrlSetData($GUI_MyDark, $MyDark)
	  EndIf

	  Local $MyGems = 0
	  If IsTextBoxPresent($frame, $rMyGemsTextBoxNoDE) = True Then
		 $MyGems = Number(ScrapeFuzzyText($frame, $gSmallCharacterMaps, $rMyGemsTextBoxNoDE, $gSmallCharMapsMaxWidth, $eScrapeDropSpaces))
		 GUICtrlSetData($GUI_MyGems, $MyGems)
	  ElseIf IsTextBoxPresent($frame, $rMyGemsTextBoxWithDE) = True Then
		 $MyGems = Number(ScrapeFuzzyText($frame, $gSmallCharacterMaps, $rMyGemsTextBoxWithDE, $gSmallCharMapsMaxWidth, $eScrapeDropSpaces))
		 GUICtrlSetData($GUI_MyGems, $MyGems)
	  EndIf

	  ; My cups and my town hall can only be scraped from the main screen
	  If WhereAmI($frame) = $eScreenMain Then
		 Local $MyCups = Number(ScrapeFuzzyText($frame, $gSmallCharacterMaps, $rMyCupsTextBox, $gSmallCharMapsMaxWidth, $eScrapeDropSpaces))
		 GUICtrlSetData($GUI_MyCups, $MyCups)

		 ; Only search for my town hall level if we don't already know it
		 Local $GUIMyTownHall = GUICtrlRead($GUI_MyTownHall)
		 If $GUIMyTownHall = 0 Then
			ZoomOut2($frame)

			Local $top, $left
			Local $MyTownHall = GetTownHallLevel($frame, $left, $top)

			If $MyTownHall = -1 Then
				  DebugWrite("Could not detect Town Hall level")
				  $MyTownHall = InputBox("Town Hall level not found", "Please enter the Town Hall level of your village.")
			EndIf

			GUICtrlSetData($GUI_MyTownHall, $MyTownHall)
		 EndIf
	  EndIf
   EndIf
EndFunc

Func CaptureAutoBeginLoot()
   Local $frame = CaptureFrame("CaptureAutoBeginLoot")
   GetMyLootNumbers($frame)
   _GDIPlus_BitmapDispose($frame)

   Local $n = GUICtrlRead($GUI_MyGold)
   If $n <> "-" Then $gAutoRaidBeginLoot[0] = $n
   $n = GUICtrlRead($GUI_MyElix)
   If $n <> "-" Then $gAutoRaidBeginLoot[1] = $n
   $n = GUICtrlRead($GUI_MyDark)
   If $n <> "-" Then $gAutoRaidBeginLoot[2] = $n
   $n = GUICtrlRead($GUI_MyCups)
   If $n <> "-" Then $gAutoRaidBeginLoot[3] = $n

   DebugWrite("Auto Begin: " & _
	  " Gold:" & $gAutoRaidBeginLoot[0] & _
	  " Elix:" & $gAutoRaidBeginLoot[1] & _
	  " Dark:" & $gAutoRaidBeginLoot[2] & _
	  " Cups:" & $gAutoRaidBeginLoot[3])

   GUICtrlSetData($GUI_Winnings, "Net winnings: 0 / 0 / 0 / 0")
EndFunc

Func CaptureAutoEndLoot()
   Local $netGold = GUICtrlRead($GUI_MyGold) - $gAutoRaidBeginLoot[0]
   Local $netElix = GUICtrlRead($GUI_MyElix) - $gAutoRaidBeginLoot[1]
   Local $netDark = GUICtrlRead($GUI_MyDark) - $gAutoRaidBeginLoot[2]
   Local $netCups = GUICtrlRead($GUI_MyCups) - $gAutoRaidBeginLoot[3]
   DebugWrite("Auto Profit: " & _
	  " Gold:" & $netGold & _
	  " Elix:" & $netElix & _
	  " Dark:" & $netDark & _
	  " Cups:" & $netCups)
EndFunc

Func DebugWrite($text)
   If $gDebug Then
	  ConsoleWrite(_NowDate() & " " & _NowTime() & " " & $text & @CRLF)
	  FileWrite("ClashBotLog.txt", _NowDate() & " " & _NowTime(5) & " " & $text & @CRLF)
   EndIf
EndFunc

Func TimeStamp()
   Return StringReplace(StringReplace(StringStripWS(_NowCalc(),$STR_STRIPALL),"/",""),":","")
EndFunc