#cs
ClAsHbOt!

Atutomatic farming bot for Clash of Clans, with a few other features.

3/21/2016 update todo
- Storage images; Gold: L10.76

Other To Do
- Capture "grayed" raid slot images for L1-L4 warden

#ce

Global $gVersion = "20160403"

; For compiling
#pragma compile(Icon, "cube.ico")
#pragma compile(FileDescription, ClAsHbOt - fully open source farm bot)
#pragma compile(ProductName, ClAsHbOt)
#pragma compile(ProductVersion, 2016.04.03)
#pragma compile(FileVersion, 2016.04.03)
#pragma compile(LegalCopyright, https://github.com/CodeSlinger69/ClAsHbOt)
#pragma compile(Out, ClAsHbOt.exe)


Opt("MustDeclareVars", 1)
Opt("GUIOnEventMode", 1)

; AutoIt includes
#include <ScreenCapture.au3>
#include <Date.au3>
#include <Math.au3>
#include <Array.au3>
#include <WinAPI.au3>
#include <File.au3>
#include <WindowsConstants.au3>
#include <SendMessage.au3>

; CoC Bot Includes
#include <Globals.au3>
#include <Version.au3>
#include <CharMaps.au3>
#include <RegionDefs.au3>
#include <GUI.au3>
#include <Settings.au3>
#include <Scraper.au3>
#include <ArmyManager.au3>
#include <CollectLoot.au3>
#include <ReloadDefenses.au3>
#include <AutoPush.au3>
#include <AutoRaid.au3>
#include <AutoRaidDumpCups.au3>
#include <AutoRaidStrategy0.au3>
#include <AutoRaidStrategy1.au3>
#include <AutoRaidStrategy2.au3>
#include <AutoRaidStrategy3.au3>
#include <AutoRaidStrategy4.au3>
#include <Mouse.au3>
#include <BlueStacks.au3>
#include <Screen.au3>
#include <Donate.au3>
#include <Test.au3>
#include <DefenseFarm.au3>

Main()

Func Main()

; Uncomment next line when testing DLL, and have a need to attach a debugger
;MsgBox($MB_OK, "", "Attach debugger!")

; Uncomment next line to run .au3 script from "source" directory, for development/debugging
;FileChangeDir("..\..\ClAsHbOt")

   ReadSettings()

   StartBlueStacks()

   InitScraper()

; Uncomment lines below to quickly test various features of the bot
;Local $hHBITMAP = CaptureFrameHBITMAP("Debug")
;ZoomOut2()
;$gScraperDebug = True
;$gDebugSaveScreenCaptures = True
;TestMyStuff()
;TestRaidLoot()
;TestRaidTroopsCount()
;TestBarracksStatus()
;TestBarracksTroopSlots()
;TestBuiltTroops()
;TestEndBattleLoot()
;TestEndBattleBonus()
;TestDeployBoxCalcs()
;TestDonate()
;TestTownHall()
;TestCollectors()
;TestStorage()
;TestFindAllStorages()
;TestCollectMyLoot()
;TestReloadDefenses()
;_WinAPI_DeleteObject($hHBITMAP)
;Exit

   InitGUI()

   MainApplicationLoop()
EndFunc

Func MainApplicationLoop()
   Local $lastOnlineCheckTimer = TimerInit()
   Local $lastCollectLootTimer = TimerInit()
   Local $lastReloadDefensesTimer = TimerInit()
   Local $lastTrainingCheckTimer = TimerInit()
   Local $lastDefenseFarmTimer = TimerInit()
   Local $snipeTHCorner

   While 1
	  ; Get frame
	  Local $hBITMAP = CaptureFrameHBITMAP("MainApplicationLoop, Stage " & $gAutoStage)

	  ; Update status on GUI
	  GetMyLootNumbers($hBITMAP)

	  ; Does loot tracking need updating?
	  If $gAutoNeedToCollectStartingLoot Then
		 CaptureAutoBeginLoot()
		 $gAutoNeedToCollectStartingLoot = False
	  EndIf

	  If $gAutoNeedToCollectEndingLoot Then
		 CaptureAutoEndLoot()
		 $gAutoNeedToCollectEndingLoot = False
	  EndIf

	  ; If Background Mode was clicked, run a check
	  If $gBackgroundModeClicked Then
		 TestBackgroundScrape()
		 $gBackgroundModeClicked = False
	  EndIf

	  ; Check for offline issues
	  If _GUICtrlButton_GetCheck($GUI_KeepOnlineCheckBox) = $BST_CHECKED And _
		 (TimerDiff($lastOnlineCheckTimer) >= $gOnlineCheckInterval Or $gKeepOnlineClicked) Then

		 $gKeepOnlineClicked = False

		 If WhereAmI($hBITMAP)=$eScreenAndroidHome Then ResetToCoCMainScreen($hBITMAP)

		 CheckForAndroidMessageBox($hBITMAP)
		 $lastOnlineCheckTimer = TimerInit()
		 UpdateCountdownTimers($lastOnlineCheckTimer, $lastCollectLootTimer, $lastReloadDefensesTimer, $lastTrainingCheckTimer, $lastDefenseFarmTimer)
	  EndIf

	  Local $autoInProgress = $gAutoStage=$eAutoFindMatch Or $gAutoStage=$eAutoExecuteRaid Or $gAutoStage=$eAutoExecuteSnipe Or _
		 _GUICtrlButton_GetCheck($GUI_DefenseFarmCheckBox)=$BST_CHECKED

	  If $autoInProgress=False Then

		 ; Donate Troops
		 If _GUICtrlButton_GetCheck($GUI_DonateTroopsCheckBox) = $BST_CHECKED And _
			$gPossibleKick < 2 And _
			($gDonateTroopsClicked Or IsColorPresent($hBITMAP, $rNewChatMessagesColor)) Then

			$gDonateTroopsClicked = False

			ResetToCoCMainScreen($hBITMAP)

			If WhereAmI($hBITMAP)=$eScreenMain Then DonateTroops($hBITMAP)
		 EndIf

		 ; Collect loot
		 If _GUICtrlButton_GetCheck($GUI_CollectLootCheckBox) = $BST_CHECKED And _
			$gPossibleKick < 2 And _
			(TimerDiff($lastCollectLootTimer) >= $gCollectLootInterval Or $gCollectLootClicked) Then

			$gCollectLootClicked = False

			If WhereAmI($hBITMAP) = $eScreenMain Then
			   ZoomOut($hBITMAP)
			Else
			   ResetToCoCMainScreen($hBITMAP)
			EndIf

			If WhereAmI($hBITMAP)=$eScreenMain Then CollectLoot()
			$lastCollectLootTimer = TimerInit()
			UpdateCountdownTimers($lastOnlineCheckTimer, $lastCollectLootTimer, $lastReloadDefensesTimer, $lastTrainingCheckTimer, $lastDefenseFarmTimer)
		 EndIf

		 ; Reload defenses
		 If _GUICtrlButton_GetCheck($GUI_ReloadDefensesCheckBox) = $BST_CHECKED And _
			$gPossibleKick < 2 And _
			(TimerDiff($lastReloadDefensesTimer) >= $gReloadDefensesInterval Or $gReloadDefensesClicked) Then

			$gReloadDefensesClicked = False

			If WhereAmI($hBITMAP) = $eScreenMain Then
			   ZoomOut($hBITMAP)
			Else
			   ResetToCoCMainScreen($hBITMAP)
			EndIf

			If WhereAmI($hBITMAP)=$eScreenMain Then ReloadDefenses($hBITMAP)
			$lastReloadDefensesTimer = TimerInit()
			UpdateCountdownTimers($lastOnlineCheckTimer, $lastCollectLootTimer, $lastReloadDefensesTimer, $lastTrainingCheckTimer, $lastDefenseFarmTimer)
		 EndIf

	  Endif ; If $autoInProgress=False...

	  ; Find a match
	  If _GUICtrlButton_GetCheck($GUI_FindMatchCheckBox) = $BST_CHECKED And _
		 $gPossibleKick < 2 Then

		 $gFindMatchClicked = False

		 If WhereAmI($hBITMAP) = $eScreenMain Then
			ZoomOut($hBITMAP)
		 Else
			ResetToCoCMainScreen($hBITMAP)
		 EndIf

		 If WhereAmI($hBITMAP)=$eScreenMain Then
			Local $dummy
			If AutoRaidFindMatch($hBITMAP, False, $dummy) = True Then
			   _GUICtrlButton_SetCheck($GUI_FindMatchCheckBox, $BST_UNCHECKED)
			   _GUICtrlButton_Enable($GUI_AutoPushCheckBox, True)
			   _GUICtrlButton_Enable($GUI_AutoRaidCheckBox, True)
			EndIf
		 EndIf
	  EndIf

	  ; Auto Push
	  If _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox) = $BST_CHECKED And _
		 $gPossibleKick < 2 And _
		 IsButtonPresent($hBITMAP, $rAndroidMessageButton1) = False And _
		 IsButtonPresent($hBITMAP, $rAndroidMessageButton2) = False Then

		 $gAutoPushClicked = False
		 CheckForAndroidMessageBox($hBITMAP)

		 AutoPush($hBITMAP, $lastTrainingCheckTimer, $snipeTHCorner)
	  EndIf

	  ; Auto Raid / AutoPush, Dump Cups
	  If (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_CHECKED Or _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox) = $BST_CHECKED) And _
		 _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups) = $BST_CHECKED And _
		 $gPossibleKick < 2 And _
		 IsButtonPresent($hBITMAP, $rAndroidMessageButton1) = False And _
		 IsButtonPresent($hBITMAP, $rAndroidMessageButton2) = False Then

		 DumpCups($hBITMAP)
	  EndIf

	  ; Auto Raid, Attack
	  If _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_CHECKED And _
		 $gPossibleKick < 2 And _
		 IsButtonPresent($hBITMAP, $rAndroidMessageButton1) = False And _
		 IsButtonPresent($hBITMAP, $rAndroidMessageButton2) = False Then

		 $gAutoRaidClicked = False
		 CheckForAndroidMessageBox($hBITMAP)

		 AutoRaid($hBITMAP, $lastTrainingCheckTimer, $snipeTHCorner)
	  EndIf

	  ; Defense Farm
	  If _GUICtrlButton_GetCheck($GUI_DefenseFarmCheckBox) = $BST_CHECKED And _
		 $gPossibleKick < 2 And _
		 IsButtonPresent($hBITMAP, $rAndroidMessageButton1) = False And _
		 IsButtonPresent($hBITMAP, $rAndroidMessageButton2) = False Then

		 $gDefenseFarmClicked = False

		 DefenseFarm($hBITMAP, $lastDefenseFarmTimer)
	  EndIf

	  ; Pause for 5 seconds
	  Local $t=TimerInit()
	  While TimerDiff($t)<5000
		 UpdateCountdownTimers($lastOnlineCheckTimer, $lastCollectLootTimer, $lastReloadDefensesTimer, $lastTrainingCheckTimer, $lastDefenseFarmTimer)

		 Local $somethingWasClicked = _
			$gKeepOnlineClicked Or _
			$gCollectLootClicked Or _
			$gDonateTroopsClicked Or _
			$gReloadDefensesClicked Or _
			$gFindMatchClicked Or _
			$gAutoPushClicked Or _
			$gAutoRaidClicked Or _
			$gBackgroundModeClicked

		 If $somethingWasClicked And _GUICtrlButton_GetCheck($GUI_DefenseFarmCheckBox)<>$BST_CHECKED Then ExitLoop
		 If $gAutoStage=$eAutoFindMatch Or $gAutoStage=$eAutoExecuteRaid Or $gAutoStage=$eAutoExecuteSnipe Then ExitLoop
		 If _GUICtrlButton_GetCheck($GUI_KeepOnlineCheckBox) = $BST_CHECKED And TimerDiff($lastOnlineCheckTimer) >= $gOnlineCheckInterval Then ExitLoop
		 If _GUICtrlButton_GetCheck($GUI_CollectLootCheckBox) = $BST_CHECKED And TimerDiff($lastCollectLootTimer) >= $gCollectLootInterval Then ExitLoop
		 If _GUICtrlButton_GetCheck($GUI_ReloadDefensesCheckBox) = $BST_CHECKED And TimerDiff($lastReloadDefensesTimer) >= $gReloadDefensesInterval Then ExitLoop
		 If _GUICtrlButton_GetCheck($GUI_DefenseFarmCheckBox) = $BST_CHECKED And TimerDiff($lastDefenseFarmTimer) >= $gDefenseFarmOfflineTime Then ExitLoop
		 If _GUICtrlButton_GetCheck($GUI_DonateTroopsCheckBox) = $BST_CHECKED And IsColorPresent($hBITMAP, $rNewChatMessagesColor) Then ExitLoop

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


	  _WinAPI_DeleteObject($hBITMAP)
   WEnd
EndFunc

Func UpdateCountdownTimers(Const $onlineTimer, Const $lootTimer, Const $defensesTimer, Const $trainingTimer, Const $defenseFarmTimer)

   ; Keep online
   If _GUICtrlButton_GetCheck($GUI_KeepOnlineCheckBox) = $BST_UNCHECKED Then
	  GUICtrlSetData($GUI_KeepOnlineCheckBox, "Keep Online 0:00")
   Else
	  Local $ms = $gOnlineCheckInterval - TimerDiff($onlineTimer)
	  If $ms < 0 Then $ms = 0
	  GUICtrlSetData($GUI_KeepOnlineCheckBox, "Keep Online " & millisecondToMMSS($ms))
   EndIf

   ; Collect loot
   If _GUICtrlButton_GetCheck($GUI_CollectLootCheckBox) = $BST_UNCHECKED Then
	  GUICtrlSetData($GUI_CollectLootCheckBox, "Collect Loot 0:00")
   ElseIf _GUICtrlButton_GetCheck($GUI_DefenseFarmCheckBox) = $BST_CHECKED Then
	  GUICtrlSetData($GUI_CollectLootCheckBox, "Collect Loot -:--")
   Else
	  Local $ms = $gCollectLootInterval - TimerDiff($lootTimer)
	  If $ms < 0 Then $ms = 0
	  GUICtrlSetData($GUI_CollectLootCheckBox, "Collect Loot " & millisecondToMMSS($ms))
   EndIf

   ; Reload defenses
   If _GUICtrlButton_GetCheck($GUI_ReloadDefensesCheckBox) = $BST_UNCHECKED Then
	  GUICtrlSetData($GUI_ReloadDefensesCheckBox, "Reload Defenses 00:00")
   ElseIf _GUICtrlButton_GetCheck($GUI_DefenseFarmCheckBox) = $BST_CHECKED Then
	  GUICtrlSetData($GUI_ReloadDefensesCheckBox, "Reload Defenses --:--")
   Else
	  Local $ms = $gReloadDefensesInterval - TimerDiff($defensesTimer)
	  If $ms < 0 Then $ms = 0
	  GUICtrlSetData($GUI_ReloadDefensesCheckBox, "Reload Defenses " & millisecondToMMSS($ms))
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

Func GetMyLootNumbers(ByRef $hBMP)
   ;DebugWrite("GetMyLootNumbers()")

   ; My loot is only scrapable on some screens
   If WhereAmI($hBMP)=$eScreenMain Or WhereAmI($hBMP)=$eScreenWaitRaid Or WhereAmI($hBMP)=$eScreenLiveRaid Then

	  ; Grab frame for OCR
	  If $gDebugSaveScreenCaptures Then _ScreenCapture_SaveImage("GetMyLootNumbersFrame.bmp", $hBMP, False)

	  Local $MyGold = 0
	  If IsTextBoxPresent($hBMP, $rMyGoldTextBox) = True Then
		 $MyGold = Number(ScrapeFuzzyText($hBMP, $fontMyStuff, $rMyGoldTextBox))
		 GUICtrlSetData($GUI_MyGold, $MyGold)
	  EndIf

	  Local $MyElix = 0
	  If IsTextBoxPresent($hBMP, $rMyElixTextBox) = True Then
		 $MyElix = Number(ScrapeFuzzyText($hBMP, $fontMyStuff, $rMyElixTextBox))
		 GUICtrlSetData($GUI_MyElix, $MyElix)
	  EndIf

	  Local $MyDark = 0
	  If IsTextBoxPresent($hBMP, $rMyGemsTextBoxWithDE) = True Then
		 $MyDark = Number(ScrapeFuzzyText($hBMP, $fontMyStuff, $rMyDarkTextBox))
		 GUICtrlSetData($GUI_MyDark, $MyDark)
	  EndIf

	  Local $MyGems = 0
	  If IsTextBoxPresent($hBMP, $rMyGemsTextBoxNoDE) = True Then
		 $MyGems = Number(ScrapeFuzzyText($hBMP, $fontMyStuff, $rMyGemsTextBoxNoDE))
		 GUICtrlSetData($GUI_MyGems, $MyGems)
	  ElseIf IsTextBoxPresent($hBMP, $rMyGemsTextBoxWithDE) = True Then
		 $MyGems = Number(ScrapeFuzzyText($hBMP, $fontMyStuff, $rMyGemsTextBoxWithDE))
		 GUICtrlSetData($GUI_MyGems, $MyGems)
	  EndIf

	  ; My cups and my town hall can only be scraped from the main screen
	  If WhereAmI($hBMP) = $eScreenMain Then
		 Local $MyCups = Number(ScrapeFuzzyText($hBMP, $fontMyStuff, $rMyCupsTextBox))
		 GUICtrlSetData($GUI_MyCups, $MyCups)

		 ; Only search for my town hall level if we don't already know it
		 Local $GUIMyTownHall = GUICtrlRead($GUI_MyTownHall)
		 If $GUIMyTownHall = 0 Then
			ZoomOut($hBMP)

			RandomWeightedClick($rSafeAreaButton)
			Sleep(500)
			Local $top, $left, $conf, $MyTownHall
			If FindBestBMP($eSearchTypeTownHall, $left, $top, $conf, $MyTownHall) = False Then
				  DebugWrite("Could not detect Town Hall level")
				  $MyTownHall = InputBox("Town Hall level not found", "Please enter the Town Hall level of your village.")
			EndIf

			GUICtrlSetData($GUI_MyTownHall, $MyTownHall)
		 EndIf
	  EndIf
   EndIf
EndFunc

Func CaptureAutoBeginLoot()
   Local $hBITMAP = CaptureFrameHBITMAP("CaptureAutoBeginLoot")
   GetMyLootNumbers($hBITMAP)
   _WinAPI_DeleteObject($hBITMAP)

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

Func DebugWrite($text, $withDateTime = True, $withCR = True)
   If $gDebug Then
	  If $withDateTime Then ConsoleWrite(_NowDate() & " " & _NowTime(5) & " ")
	  ConsoleWrite($text)
	  If $withCR Then ConsoleWrite(@CRLF)

	  If $withDateTime Then FileWrite("ClashBotLog.txt", _NowDate() & " " & _NowTime(5) & " ")
	  FileWrite("ClashBotLog.txt", $text)
	  If $withCR Then FileWrite("ClashBotLog.txt", @CRLF)
   EndIf
EndFunc

Func TimeStamp()
   Return StringReplace(StringReplace(StringStripWS(_NowCalc(),$STR_STRIPALL),"/",""),":","")
EndFunc