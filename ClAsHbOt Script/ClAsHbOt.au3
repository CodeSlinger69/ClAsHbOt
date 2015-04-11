#cs
ClAsHbOt!
#ce
Global $version = "20150411"

; AutoIt includes
#include <ScreenCapture.au3>
#include <Date.au3>
#include <GDIPlus.au3>
#include <Math.au3>
#include <Array.au3>
#include <WinAPI.au3>

; CoC Bot Includes
#include <Globals.au3>
#include <GUI.au3>
#include <Scraper.au3>
#include <KeepOnline.au3>
#include <CollectLoot.au3>
#include <FindMatch.au3>
#include <FindSnipableTH.au3>
#include <AutoRaid.au3>
#include <AutoRaidStrategy.au3>
#include <Mouse.au3>

Opt("MustDeclareVars", 1)
Opt("GUIOnEventMode", 1)




Main()

Func Main()
   If WinExists($title) = 0 Then
	  MsgBox($MB_OK, "BlueStacks Not Running", "BlueStacks is not running." & @CRLF & @CRLF & "Exiting.")
	  Exit
   EndIf

   Local $clientPos = GetClientPos()
   If $clientPos[2]-$clientPos[0]+1<>1024 Or $clientPos[3]-$clientPos[1]+1<>600 Then
	  MsgBox($MB_OK, "BlueStacks Wrong Size", "BlueStacks window is the wrong size." & @CRLF & _
		 "Has the registry been changed?" & @CRLF & @CRLF & "Exiting.")
	  Exit
   EndIf

   WinActivate($title)
   WinWaitActive($title)
   WinMove($title, "", 4, 4)

   InitScraper()

   InitGUI()

;Debug
;Local $troopSlotIndex[$countOfSlots]
;FindTroopSlots($troopSlotIndex)
;DebugWrite("JSpell: " & $troopSlotIndex[$jumpSpellSlot] & @CRLF)
;DebugWrite("FSpell: " & $troopSlotIndex[$freezeSpellSlot] & @CRLF)
;Local $troopSlotIndex[$countOfSlots]
;GrabFrameToFile("frame.bmp")
;Exit

   HotKeySet("{F6}", HotKeyPressed)
   HotKeySet("{F7}", HotKeyPressed)
   HotKeySet("{F8}", HotKeyPressed)
   HotKeySet("{F9}", HotKeyPressed)
   HotKeySet("{F10}", HotKeyPressed)
   HotKeySet("{F11}", HotKeyPressed)

   While $ExitApp = False
	  DebugWrite("Main loop")

	  ; Update status on GUI
	  GetMyLootNumbers()

	  ; Check for offline issues
	  If _GUICtrlButton_GetCheck($GUI_KeepOnlineCheckBox) = $BST_CHECKED And _
		 (TimerDiff($lastOnlineCheck) >= $onlineCheckDelay Or $keepOnlineClicked) And _
		 $ExitApp = False And _
		 $autoRaidStage <> $AutoRaidExecuteRaid And $autoRaidStage <> $AutoRaidExecuteDEZap Then

		 $keepOnlineClicked = False

		 If WhereAmI()=$ScreenAndroidHome Then
			ResetToCoCMainScreen()
			ZoomOut(False)
		 EndIf

		 CheckForAndroidMessageBox()
		 $lastOnlineCheck = TimerInit()
		 UpdateCountdownTimers()
	  EndIf

	  ; Collect loot
	  If _GUICtrlButton_GetCheck($GUI_CollectLootCheckBox) = $BST_CHECKED  And _
		 (TimerDiff($lastCollectLoot) >= $collectLootDelay Or $collectLootClicked) And _
		 $ExitApp = False And _
		 $autoRaidStage <> $AutoRaidFindMatch And _
		 $autoRaidStage <> $AutoRaidExecuteRaid And _
		 $autoRaidStage <> $AutoRaidExecuteDEZap Then

		 $collectLootClicked = False
		 ResetToCoCMainScreen()
		 ZoomOut(False)
		 If WhereAmI()=$ScreenMain Then CollectLoot()
		 $lastCollectLoot = TimerInit()
		 UpdateCountdownTimers()
	  EndIf

	  ; Find a raiding match
	  If _GUICtrlButton_GetCheck($GUI_FindMatchCheckBox) = $BST_CHECKED And _
		 $ExitApp = False Then

		 $findMatchClicked = False
		 ResetToCoCMainScreen()
		 ZoomOut(False)
		 If WhereAmI()=$ScreenMain Then
			If FindAValidMatch() = True Then
			   _GUICtrlButton_SetCheck($GUI_FindMatchCheckBox, $BST_UNCHECKED)
			   _GUICtrlButton_Enable($GUI_FindSnipableTHCheckBox, True)
			   _GUICtrlButton_Enable($GUI_AutoRaidCheckBox, True)
			EndIf
		 EndIf
	  EndIf

	  ; Find a snipable TH
	  If _GUICtrlButton_GetCheck($GUI_FindSnipableTHCheckBox) = $BST_CHECKED And _
		 $ExitApp = False Then

		 $findSnipableTHClicked = False
		 ResetToCoCMainScreen()
		 ZoomOut(False)
		 If WhereAmI()=$ScreenMain Then
			If FindASnipableTH() = True Then
			   _GUICtrlButton_SetCheck($GUI_FindSnipableTHCheckBox, $BST_UNCHECKED)
			   _GUICtrlButton_Enable($GUI_FindMatchCheckBox, True)
			   _GUICtrlButton_Enable($GUI_AutoRaidCheckBox, True)
			EndIf
		 EndIf
	  EndIf

	  ; Auto Raid, Dump Cups
	  Local $cPos = GetClientPos()
	  If _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_CHECKED And _
		 _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups) = $BST_CHECKED And _
		 PixelGetColor($cPos[0]+$AndroidMessageButton[4], $cPos[1]+$AndroidMessageButton[5]) <> $AndroidMessageButton[6] And _
		 $ExitApp = False Then

		 ResetToCoCMainScreen()
		 If WhereAmI()=$ScreenMain Then DumpCups()
	  EndIf

	  ; Auto Raid, Attack
	  $cPos = GetClientPos()
	  If _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_CHECKED And _
		 PixelGetColor($cPos[0]+$AndroidMessageButton[4], $cPos[1]+$AndroidMessageButton[5]) <> $AndroidMessageButton[6] And _
		 $ExitApp = False Then

		 If $beginGold=-1 Or $beginElix=-1 Or $beginDark=-1 Or $beginCups=-1 Then CaptureAutoRaidBegin()

		 $autoRaidClicked = False
		 CheckForAndroidMessageBox()
		 AutoRaid()
	  EndIf

	  ; Pause for 5 seconds
	  Local $i
	  For $i = 1 To 10
		 UpdateCountdownTimers()

		 If $ExitApp Then ExitLoop
		 If $findMatchClicked Or $findSnipableTHClicked Or $keepOnlineClicked Or $collectLootClicked Or $autoRaidClicked Then ExitLoop
		 If $autoRaidStage=$AutoRaidFindMatch Or $autoRaidStage=$AutoRaidExecuteRaid Then ExitLoop
		 If _GUICtrlButton_GetCheck($GUI_KeepOnlineCheckBox) = $BST_CHECKED And TimerDiff($lastOnlineCheck) >= $onlineCheckDelay Then ExitLoop
		 If _GUICtrlButton_GetCheck($GUI_CollectLootCheckBox) = $BST_CHECKED And TimerDiff($lastCollectLoot) >= $collectLootDelay Then ExitLoop

		 Sleep(500)
	  Next
   WEnd

   HotKeySet("{F6}")
   HotKeySet("{F7}")
   HotKeySet("{F8}")
   HotKeySet("{F9}")
   HotKeySet("{F10}")
   HotKeySet("{F11}")

   ExitGUI()
   ExitScraper()
EndFunc

Func UpdateCountdownTimers()
   If _GUICtrlButton_GetCheck($GUI_KeepOnlineCheckBox) = $BST_UNCHECKED Then
	  GUICtrlSetData($GUI_KeepOnlineCheckBox, "F6 Keep Online 0:00")
   Else
	  Local $ms = $onlineCheckDelay - TimerDiff($lastOnlineCheck)
	  If $ms < 0 Then $ms = 0
	  GUICtrlSetData($GUI_KeepOnlineCheckBox, "F6 Keep Online " & millisecondToMMSS($ms))
   EndIf

   If _GUICtrlButton_GetCheck($GUI_CollectLootCheckBox) = $BST_UNCHECKED Then
	  GUICtrlSetData($GUI_CollectLootCheckBox, "F7 Collect Loot 0:00")
   Else
	  Local $ms = $collectLootDelay - TimerDiff($lastCollectLoot)
	  If $ms < 0 Then $ms = 0
	  GUICtrlSetData($GUI_CollectLootCheckBox, "F7 Collect Loot " & millisecondToMMSS($ms))
   EndIf

   If _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_CHECKED And _
	  $autoRaidStage = $AutoRaidWaitForTrainingToComplete Then
	  Local $ms = $troopTrainingCheckDelay - TimerDiff($lastTrainingCheck)
	  If $ms < 0 Then $ms = 0
	  GUICtrlSetData($GUI_AutoRaid, "Auto Raid: Waiting For Training " & millisecondToMMSS($ms))
   EndIf
EndFunc

Func ZoomOut(Const $clearOnSafeSpot)
   WinActivate($title)
   WinWaitActive($title)

   Local $s = WhereAmI()
   If $s=$ScreenMain Or $s=$ScreenWaitRaid Or $s=$ScreenLiveRaid Then
	  Local $i
	  For $i = 1 To 3
		 Send("^-")
		 Sleep(250)
	  Next

	  Sleep(150)

	  If $clearOnSafeSpot Then
		 RandomWeightedClick($SafeAreaButton)
		 Sleep(250)
	  EndIf
   EndIf
EndFunc

Func MoveScreenDownToTop(Const $clearOnSafeSpot)
   Local $startX, $startY
   Local $startBox[4] = [300, 65, 725, 110]
   RandomWeightedCoords($startBox, $startX, $startY)

   Local $endX, $endY
   Local $endBox[4] = [300, 365, 725, 410]
   RandomWeightedCoords($endBox, $endX, $endY)

   If $clearOnSafeSpot = True Then
	  RandomWeightedClick($SafeAreaButton)
	  Sleep(250)
   EndIf

   ControlClickDrag($startX, $startY, $endX, $endY)
   Sleep(250)
EndFunc

Func MoveScreenUpToCenter(Const $dist=83)
   ; Always 83 pixels up
   Local $startX, $startY
   Local $startBox[4] = [450, 365, 575, 410]
   RandomWeightedCoords($startBox, $startX, $startY)

   Local $endX, $endY
   Local $endBox[4] = [450, 365, 575, 410]
   RandomWeightedCoords($endBox, $endX, $endY)

   ControlClickDrag($startX, $startY, $endX, $startY-$dist)
   Sleep(250)
EndFunc

Func MoveScreenUpToBottom(Const $clearOnSafeSpot)
   If $clearOnSafeSpot = True Then
	  RandomWeightedClick($SafeAreaButton)
	  Sleep(250)
   EndIf

   Local $startX, $startY
   Local $startBox[4] = [300, 365, 725, 410]
   RandomWeightedCoords($startBox, $startX, $startY)

   Local $endX, $endY
   Local $endBox[4] = [300, 65, 725, 110]
   RandomWeightedCoords($endBox, $endX, $endY)

   ControlClickDrag($startX, $startY, $endX, $endY)
   Sleep(250)
EndFunc

Func MoveScreenDownToCenter(Const $dist=155)
   ; Always 155 pixels down
   Local $startX, $startY
   Local $startBox[4] = [450, 225, 575, 270]
   RandomWeightedCoords($startBox, $startX, $startY)

   Local $endX, $endY
   Local $endBox[4] = [450, 225, 575, 270]
   RandomWeightedCoords($endBox, $endX, $endY)

   ControlClickDrag($startX, $startY, $startY, $startY+$dist)
   Sleep(250)
EndFunc

Func ResetToCoCMainScreen()
   Local $countdown = 5

   CheckForAndroidMessageBox()

   ; Get our current screen
   Local $s = WhereAmI()
   ;If $s <> $ScreenMain And $s <> $ScreenLiveRaid And $s <> $ScreenWaitRaid Then
	;  DebugWrite(_NowTime() & " Resetting to main screen, current = " & $s & @CRLF)
   ;EndIf

   Switch $s

   ; Main screen, do nothing
   Case $ScreenMain
	  Return

   ; Live raid screen - do nothing - don't interrupt a live raid
   Case $ScreenLiveRaid
	  Return

   ; Wait raid screen - do nothing - don't interrupt a Find Match or Auto Raid in progress
   Case $ScreenWaitRaid
	  Return

   ; Unknown screen - don't do anything
   Case $UnknownScreen
	  Return

   ; Barracks button panel - click on safe area
   Case $PanelBarracksButtons
	  RandomWeightedClick($SafeAreaButton)

   ; Train troops window - close it
   Case $WindowTrainTroops
	  RandomWeightedClick($TrainTroopsWindowCloseButton)

   ; Train troops info window - close it
   Case $WindowTrainTroopsInfo
	  RandomWeightedClick($TrainTroopsWindowCloseButton)

   ; Android Home Screen - start CoC
   Case $ScreenAndroidHome
	  DebugWrite("On Android Home Screen - Starting Clash of Clans.")
      Local $bestMatch = 99, $bestConfidence = 0, $bestX = 0, $bestY = 0
	  GrabFrameToFile("HomeScanFrame.bmp")
	  ScanFrameForBMP("HomeScanFrame.bmp", $CoCIconBMPs, 0.95, $bestMatch, $bestConfidence, $bestX, $bestY)
	  If $bestMatch <> 99 Then
		 Local $button[8] = [$bestX, $bestY, $bestX+$ScreenAndroidHomeCoCIconButton[2], $bestY+$ScreenAndroidHomeCoCIconButton[3], 0, 0, 0, 0]
		 RandomWeightedClick($button)
		 $countdown = 30
	  EndIf

   ; CoC Chat Open - Close it
   Case $ScreenChatOpen
	  RandomWeightedClick($MainScreenOpenChatButton)

   ; CoC Find Match screen - exit
   Case $ScreenFindMatch
	  RandomWeightedClick($FindMatchScreenCloseWindowButton)

   ; CoC Wait Raid screen - exit
   Case $ScreenWaitRaid
	  RandomWeightedClick($LiveRaidScreenEndBattleButton)

   ; End Battle screen - click button
   Case $ScreenEndBattle
	  RandomWeightedClick($BattleHasEndedScreenReturnHomeButton)

   ; Live Replay End Battle screen - click "Return Home"
   Case $ScreenLiveReplayEndBattle
	  RandomWeightedClick($LiveReplayEndScreenReturnHomeButton)

   Case $WindowVilliageWasAttacked
	  RandomWeightedClick($WindowVilliageWasAttackedOkayButton)

   ; Shield Is Active screen
   Case $ScreenShieldIsActive
	  RandomWeightedClick($ShieldIsActivePopupButton)

   EndSwitch

   ; Wait for main screen to appear
   While WhereAmI() <> $ScreenMain And $countdown > 0 And $ExitApp = False
	  Sleep(1000)
	  $countdown -= 1
   WEnd

   ZoomOut(False)
EndFunc

Func WhereAmI()
   Local $cPos = GetClientPos()
   Local $pixelColor, $pixMatch

   ; $ScreenAndroidHome
   Local $bestMatch = 99, $bestConfidence = 0, $bestX = 0, $bestY = 0
   GrabFrameToFile("HomeScanFrame.bmp")
   ScanFrameForBMP("HomeScanFrame.bmp", $CoCIconBMPs, 0.95, $bestMatch, $bestConfidence, $bestX, $bestY)
   ;DebugWrite("Android Home Scan: " & $bestMatch & " " & $bestConfidence & " " & $bestX & " " & $bestY)

   If $bestMatch <> 99 Then
	  Return $ScreenAndroidHome
   EndIf

   ; Barracks button panel is up
   $pixelColor = PixelGetColor($cPos[0]+$BarracksPanelTrainTroops1Button[4], $cPos[1]+$BarracksPanelTrainTroops1Button[5])
   $pixMatch = InColorSphere($pixelColor, $BarracksPanelTrainTroops1Button[6], $BarracksPanelTrainTroops1Button[7])
   If $pixMatch = True Then Return $PanelBarracksButtons
   $pixelColor = PixelGetColor($cPos[0]+$BarracksPanelTrainTroops2Button[4], $cPos[1]+$BarracksPanelTrainTroops2Button[5])
   $pixMatch = InColorSphere($pixelColor, $BarracksPanelTrainTroops2Button[6], $BarracksPanelTrainTroops2Button[7])
   If $pixMatch = True Then Return $PanelBarracksButtons

   ; Train troops window is open
   $pixelColor = PixelGetColor($cPos[0]+$TrainTroopsWindowNextButton[4], $cPos[1]+$TrainTroopsWindowNextButton[5])
   $pixMatch = InColorSphere($pixelColor, $TrainTroopsWindowNextButton[6], $TrainTroopsWindowNextButton[7])
   If $pixMatch = True Then Return $WindowTrainTroops

   ; Train troops info window is open
   $pixelColor = PixelGetColor($cPos[0]+$WindowTrainTroopsInfoColor[0], $cPos[1]+$WindowTrainTroopsInfoColor[1])
   $pixMatch = InColorSphere($pixelColor, $WindowTrainTroopsInfoColor[2], $WindowTrainTroopsInfoColor[3])
   If $pixMatch = True Then Return $WindowTrainTroopsInfo

   ; $ScreenMain
   $pixelColor = PixelGetColor($cPos[0]+$ScreenMainColor[0], $cPos[1]+$ScreenMainColor[1])
   $pixMatch = InColorSphere($pixelColor, $ScreenMainColor[2], $ScreenMainColor[3])
   If $pixMatch = True Then Return $ScreenMain

   ; $ScreenChatOpen
   $pixelColor = PixelGetColor($cPos[0]+$MainScreenOpenChatButton[4], $cPos[1]+$MainScreenOpenChatButton[5])
   $pixMatch = InColorSphere($pixelColor, $MainScreenOpenChatButton[6], $MainScreenOpenChatButton[7])
   If $pixMatch = True Then Return $ScreenChatOpen

   ; $ScreenShieldIsActive
   $pixelColor = PixelGetColor($cPos[0]+$ShieldIsActivePopupButton[4], $cPos[1]+$ShieldIsActivePopupButton[5])
   $pixMatch = InColorSphere($pixelColor, $ShieldIsActivePopupButton[6], $ShieldIsActivePopupButton[7])
   If $pixMatch = True Then Return $ScreenShieldIsActive

   ; $ScreenFindMatch
   $pixelColor = PixelGetColor($cPos[0]+$FindMatchScreenFindAMatchButton[4], $cPos[1]+$FindMatchScreenFindAMatchButton[5])
   $pixMatch = InColorSphere($pixelColor, $FindMatchScreenFindAMatchButton[6], $FindMatchScreenFindAMatchButton[7])
   If $pixMatch = True Then Return $ScreenFindMatch

   ; $ScreenWaitRaid (with "Next")
   $pixelColor = PixelGetColor($cPos[0]+$WaitRaidScreenNextButton[4], $cPos[1]+$WaitRaidScreenNextButton[5])
   $pixMatch = InColorSphere($pixelColor, $WaitRaidScreenNextButton[6], $WaitRaidScreenNextButton[7])
   If $pixMatch = True Then Return $ScreenWaitRaid

   ; $ScreenLiveRaid (live attack)
   $pixelColor = PixelGetColor($cPos[0]+$ScreenLiveRaid1Color[0], $cPos[1]+$ScreenLiveRaid1Color[1])
   $pixMatch = InColorSphere($pixelColor, $ScreenLiveRaid1Color[2], $ScreenLiveRaid1Color[3])
   $pixelColor = PixelGetColor($cPos[0]+$ScreenLiveRaid2Color[0], $cPos[1]+$ScreenLiveRaid2Color[1])
   Local $pixMatch2 = InColorSphere($pixelColor, $ScreenLiveRaid2Color[2], $ScreenLiveRaid2Color[3])
   If $pixMatch = True And $pixMatch2 = True Then Return $ScreenLiveRaid

   ; $ScreenEndBattle
   $pixelColor = PixelGetColor($cPos[0]+$BattleHasEndedScreenReturnHomeButton[4], $cPos[1]+$BattleHasEndedScreenReturnHomeButton[5])
   $pixMatch = InColorSphere($pixelColor, $BattleHasEndedScreenReturnHomeButton[6], $BattleHasEndedScreenReturnHomeButton[7])
   If $pixMatch = True Then Return $ScreenEndBattle

   ; $ScreenLiveReplayEndBattle
   $pixelColor = PixelGetColor($cPos[0]+$LiveReplayEndScreenReturnHomeButton[4], $cPos[1]+$LiveReplayEndScreenReturnHomeButton[5])
   $pixMatch = InColorSphere($pixelColor, $LiveReplayEndScreenReturnHomeButton[6], $LiveReplayEndScreenReturnHomeButton[7])
   If $pixMatch = True Then Return $ScreenLiveReplayEndBattle

   ; $WindowVilliageWasAttacked
   $pixelColor = PixelGetColor($cPos[0]+$WindowVilliageWasAttackedOkayButton[4], $cPos[1]+$WindowVilliageWasAttackedOkayButton[5])
   $pixMatch = InColorSphere($pixelColor, $WindowVilliageWasAttackedOkayButton[6], $WindowVilliageWasAttackedOkayButton[7])
   If $pixMatch = True Then Return $WindowVilliageWasAttacked

   ; $Unknown
   #cs
   Local $datetimestamp = _
	  StringMid(_NowCalc(), 1,4) & _
	  StringMid(_NowCalc(), 6,2) & _
	  StringMid(_NowCalc(), 9,2) & _
	  StringMid(_NowCalc(), 12,2) & _
	  StringMid(_NowCalc(), 15,2) & _
	  StringMid(_NowCalc(), 18,2)
   FileMove("HomeScanFrame.bmp", "UnknownScreen-" & $datetimestamp & ".bmp")
   #ce
   Return $UnknownScreen

EndFunc

Func millisecondToMMSS(Const $ms)
   Local $m = Int(Mod($ms, 1000*60*60) / (1000*60))
   Local $s = Int(Mod(Mod($ms, 1000*60*60), 1000*60) / 1000)

   Return $m & ":" & StringRight("00" & $s, 2);
EndFunc

Func DebugWrite($text)
   If $Debug Then
	  ConsoleWrite(_NowTime() & " " & $text & @CRLF)
	  FileWrite("ClashBotLog.txt", _NowTime() & " " & $text & @CRLF)
   EndIf
EndFunc
