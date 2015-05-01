
Func ResetToCoCMainScreen()
   Local $countdown = 5

   CheckForAndroidMessageBox()

   ; Get our current screen
   Local $s = WhereAmI()

   Switch $s

   ; Main screen, do nothing
   Case $eScreenMain
	  Return

   ; Live raid screen - do nothing - don't interrupt a live raid
   Case $eScreenLiveRaid
	  Return

   ; Wait raid screen - do nothing - don't interrupt a Find Match or Auto Raid in progress
   Case $eScreenWaitRaid
	  Return

   ; Unknown screen - don't do anything
   Case $eScreenUnknown
	  Return

   ; Barracks button panel - click on safe area
   Case $eScreenBarracksButtons
	  RandomWeightedClick($SafeAreaButton)

   ; Train troops window - close it
   Case $eScreenTrainTroops
	  RandomWeightedClick($TrainTroopsWindowCloseButton)

   ; Train troops info window - close it
   Case $eScreenTrainTroopsInfo
	  RandomWeightedClick($TrainTroopsWindowCloseButton)

   ; Android Home Screen - start CoC
   Case $eScreenAndroidHome
	  DebugWrite("On Android Home Screen - Starting Clash of Clans.")
      Local $bestMatch = 99, $bestConfidence = 0, $bestX = 0, $bestY = 0
	  GrabFrameToFile("HomeScanFrame.bmp")
	  ScanFrameForBestBMP("HomeScanFrame.bmp", $CoCIconBMPs, 0.95, $bestMatch, $bestConfidence, $bestX, $bestY)
	  If $bestMatch <> 99 Then
		 Local $button[8] = [$bestX, $bestY, $bestX+$ScreenAndroidHomeCoCIconButton[2], $bestY+$ScreenAndroidHomeCoCIconButton[3], 0, 0, 0, 0]
		 RandomWeightedClick($button)
		 $countdown = 30
	  EndIf

   ; CoC Chat Open - Close it
   Case $eScreenChatOpen
	  RandomWeightedClick($MainScreenOpenChatButton)

   ; Chat window open but dimmed - click on safe spot
   Case $eScreenChatDimmed
	  RandomWeightedClick($SafeAreaButton)
	  Sleep(1000)
	  If WhereAmI()=$eScreenChatOpen Then RandomWeightedClick($MainScreenOpenChatButton)

   ; CoC Find Match screen - exit
   Case $eScreenFindMatch
	  RandomWeightedClick($FindMatchScreenCloseWindowButton)

   ; CoC Wait Raid screen - exit
   Case $eScreenWaitRaid
	  RandomWeightedClick($LiveRaidScreenEndBattleButton)

   ; End Battle screen - click button
   Case $eScreenEndBattle
	  RandomWeightedClick($BattleHasEndedScreenReturnHomeButton)

   ; Live Replay End Battle screen - click "Return Home"
   Case $eScreenLiveReplayEndBattle
	  RandomWeightedClick($LiveReplayEndScreenReturnHomeButton)

   Case $eScreenVilliageWasAttacked
	  RandomWeightedClick($WindowVilliageWasAttackedOkayButton)

   ; Shield Is Active screen
   Case $eScreenShieldIsActive
	  RandomWeightedClick($ShieldIsActivePopupButton)

   ; Army camp buttons - click on safe spot
   Case $eScreenArmyCampButtons
	  RandomWeightedClick($SafeAreaButton)

   ; Army Camp info screen - close it
   Case $eScreenArmyCampInfo
	  RandomWeightedClick($rArmyCampInfoScreenCloseWindowButton)

   EndSwitch

   ; Wait for main screen to appear
   While WhereAmI() <> $eScreenMain And $countdown > 0
	  Sleep(1000)
	  $countdown -= 1
   WEnd

   ZoomOut(True)
EndFunc

Func WhereAmI()
   ; $ScreenAndroidHome
   Local $bestMatch = 99, $bestConfidence = 0, $bestX = 0, $bestY = 0
   GrabFrameToFile("HomeScanFrame.bmp")
   ScanFrameForBestBMP("HomeScanFrame.bmp", $CoCIconBMPs, 0.95, $bestMatch, $bestConfidence, $bestX, $bestY)
   ;DebugWrite("Android Home Scan: " & $bestMatch & " " & $bestConfidence & " " & $bestX & " " & $bestY)

   If $bestMatch <> 99 Then
	  Return $eScreenAndroidHome
   EndIf

   ; Barracks button panel is up
   If IsButtonPresent($BarracksPanelTrainTroops1Button) Then Return $eScreenBarracksButtons
   If IsButtonPresent($BarracksPanelTrainTroops2Button) Then Return $eScreenBarracksButtons

   ; Train troops window is open
   If IsButtonPresent($TrainTroopsWindowNextButton) Then Return $eScreenTrainTroops

   ; Train troops info window is open
   If IsColorPresent($rWindowTrainTroopsInfoColor) Then Return $eScreenTrainTroopsInfo

   ; $ScreenMain
   If IsColorPresent($rScreenMainColor) Then Return $eScreenMain

   ; $ScreenChatOpen
   If IsButtonPresent($MainScreenOpenChatButton) Then Return $eScreenChatOpen

   ; $WindowChatDimmed
   If IsColorPresent($rWindowChatDimmedColor) Then Return $eScreenChatDimmed

   ; $ScreenShieldIsActive
   If IsButtonPresent($ShieldIsActivePopupButton) Then Return $eScreenShieldIsActive

   ; $ScreenFindMatch
   If IsButtonPresent($FindMatchScreenFindAMatchButton) Then Return $eScreenFindMatch

   ; $ScreenWaitRaid (with "Next")
   If IsButtonPresent($WaitRaidScreenNextButton) Then Return $eScreenWaitRaid

   ; $ScreenLiveRaid (live attack)
   If IsColorPresent($rScreenLiveRaid1Color) And IsColorPresent($rScreenLiveRaid2Color) Then Return $eScreenLiveRaid

   ; $ScreenEndBattle
   If IsButtonPresent($BattleHasEndedScreenReturnHomeButton) Then Return $eScreenEndBattle

   ; $ScreenLiveReplayEndBattle
   If IsButtonPresent($LiveReplayEndScreenReturnHomeButton) Then Return $eScreenLiveReplayEndBattle

   ; $WindowVilliageWasAttacked
   If IsButtonPresent($WindowVilliageWasAttackedOkayButton) Then Return $eScreenVilliageWasAttacked

   ; $eScreenArmyCampButtons
   If IsButtonPresent($rArmyCampInfoButton) Then Return $eScreenArmyCampButtons

   ; $eScreenArmyCampInfo
   If IsButtonPresent($rArmyCampInfoScreenCloseWindowButton) Then Return $eScreenArmyCampInfo

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
   Return $eScreenUnknown

EndFunc

Func ZoomOut(Const $clearOnSafeSpot)
   WinActivate($gTitle)
   WinWaitActive($gTitle)

   Local $s = WhereAmI()
   If $s=$eScreenMain Or $s=$eScreenWaitRaid Or $s=$eScreenLiveRaid Then
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

   _ClickDrag($startX, $startY, $endX, $endY)
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

   _ClickDrag($startX, $startY, $endX, $startY-$dist)
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

   _ClickDrag($startX, $startY, $endX, $endY)
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

   _ClickDrag($startX, $startY, $startY, $startY+$dist)
   Sleep(250)
EndFunc
