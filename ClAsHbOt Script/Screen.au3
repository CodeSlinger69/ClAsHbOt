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
	  DebugWrite("ResetToCoCMainScreen(), On Live Raid Screen - doing nothing.")
	  Return

   ; Wait raid screen - do nothing - don't interrupt a Find Match or Auto Raid in progress
   Case $eScreenWaitRaid
	  DebugWrite("ResetToCoCMainScreen(), On Wait Raid Screen - doing nothing.")
	  Return

   ; Unknown screen - don't do anything
   Case $eScreenUnknown
	  DebugWrite("ResetToCoCMainScreen(), On Unknown Screen - doing nothing.")
	  Return

   ; Android Home Screen - start CoC
   Case $eScreenAndroidHome
	  DebugWrite("ResetToCoCMainScreen(), On Android Home Screen - Starting Clash of Clans.")
      Local $bestMatch = 99, $bestConfidence = 0, $bestX = 0, $bestY = 0
	  GrabFrameToFile("WhereAmIFrame.bmp")
	  ScanFrameForBestBMP("WhereAmIFrame.bmp", $CoCIconBMPs, 0.95, $bestMatch, $bestConfidence, $bestX, $bestY)
	  If $bestMatch <> 99 Then
		 Local $button[4] = [$bestX, $bestY, $bestX+$rScreenAndroidHomeCoCIconButton[2], $bestY+$rScreenAndroidHomeCoCIconButton[3]]
		 RandomWeightedClick($button)
		 $countdown = 30
	  EndIf

   ; Clash screen in Play Store
   Case $eScreenPlayStore
	  DebugWrite("ResetToCoCMainScreen(), On Clash Play Store Screen - Starting Clash of Clans.")
      Local $bestMatch = 99, $bestConfidence = 0, $bestX = 0, $bestY = 0
	  GrabFrameToFile("WhereAmIFrame.bmp")
	  ScanFrameForBestBMP("WhereAmIFrame.bmp", $gPlayStoreOpenButton, 0.95, $bestMatch, $bestConfidence, $bestX, $bestY)
	  If $bestMatch <> 99 Then
		 Local $button[4] = [$bestX, $bestY, $bestX+$rScreenPlayStoreOpenButton[2], $bestY+$rScreenPlayStoreOpenButton[3]]
		 RandomWeightedClick($button)
		 $countdown = 30
	  EndIf

   ; Android message box is open
   Case $eScreenAndroidMessageBox
	  If IsButtonPresent($rAndroidMessageButton1) Then
		 DebugWrite("ResetToCoCMainScreen(), On Android Message Screen (1) - clicking message box.")
		 RandomWeightedClick($rAndroidMessageButton1)
	  EndIf

	  If IsButtonPresent($rAndroidMessageButton2) Then
		 DebugWrite("ResetToCoCMainScreen(), On Android Message Screen (1) - clicking message box.")
		 RandomWeightedClick($rAndroidMessageButton2)
	  EndIf

   ; CoC Chat Open - Close it
   Case $eScreenChatOpen
	  DebugWrite("ResetToCoCMainScreen(), On Chat Open Screen - closing chat.")
	  RandomWeightedClick($rMainScreenOpenChatButton)

   ; Chat window open but dimmed - click on safe spot
   Case $eScreenChatDimmed
	  DebugWrite("ResetToCoCMainScreen(), On Chat Dimmed Screen - clicking safe spot.")
	  RandomWeightedClick($rSafeAreaButton)
	  Sleep(1000)
	  If WhereAmI()=$eScreenChatOpen Then
		 DebugWrite("ResetToCoCMainScreen(), On Chat Open Screen - closing chat.")
		 RandomWeightedClick($rMainScreenOpenChatButton)
	  EndIf

   ; CoC Find Match screen - exit
   Case $eScreenFindMatch
	  DebugWrite("ResetToCoCMainScreen(), On Find Match Screen - clicking close button.")
	  RandomWeightedClick($rFindMatchScreenCloseWindowButton)

   ; End Battle screen - click button
   Case $eScreenEndBattle
	  DebugWrite("ResetToCoCMainScreen(), On End Battle Screen - clicking Return Home button.")
	  RandomWeightedClick($rBattleHasEndedScreenReturnHomeButton)

   ; Live Replay End Battle screen - click "Return Home"
   Case $eScreenLiveReplayEndBattle
	  DebugWrite("ResetToCoCMainScreen(), On Live Replay End Battle Screen - clicking Return Home button.")
	  RandomWeightedClick($rLiveReplayEndScreenReturnHomeButton)

   Case $eScreenVilliageWasAttacked
	  DebugWrite("ResetToCoCMainScreen(), On Villiage Was Attached Screen - clicking Okay button.")
	  RandomWeightedClick($rWindowVilliageWasAttackedOkayButton)

   ; Army Manager window
   Case $eWindowArmyManager
	  DebugWrite("ResetToCoCMainScreen(), On Army Manager window - clicking close button.")
	  RandomWeightedClick($rArmyManagerWindowCloseButton)

   EndSwitch

   ; Wait for main screen to appear
   While WhereAmI()<>$eScreenMain And WhereAmI()<>$eScreenVilliageWasAttacked And $countdown>0
	  Sleep(1000)
	  $countdown -= 1
   WEnd

   If WhereAmI() = $eScreenVilliageWasAttacked Then
	  DebugWrite("ResetToCoCMainScreen(), On Villiage Was Attached Screen - clicking Okay button.")
	  RandomWeightedClick($rWindowVilliageWasAttackedOkayButton)
   EndIf

   ZoomOut(True)
   DragScreenDown()
EndFunc

Func WhereAmI()
   GrabFrameToFile("WhereAmIFrame.bmp")

   ; $ScreenAndroidHome
   Local $bestMatch, $bestConfidence, $bestX, $bestY
   ScanFrameForBestBMP("WhereAmIFrame.bmp", $CoCIconBMPs, 0.95, $bestMatch, $bestConfidence, $bestX, $bestY)
   ;DebugWrite("Android Home Scan: " & $bestMatch & " " & $bestConfidence & " " & $bestX & " " & $bestY)

   If $bestMatch <> -1 Then
	  Return $eScreenAndroidHome
   EndIf

   ; $eScreenPlayStore
   Local $bestMatch, $bestConfidence, $bestX, $bestY
   ScanFrameForBestBMP("WhereAmIFrame.bmp", $gPlayStoreOpenButton, 0.99, $bestMatch, $bestConfidence, $bestX, $bestY)
   ;DebugWrite("Play Store scan: " & $bestMatch & " " & $bestConfidence & " " & $bestX & " " & $bestY)

   If $bestMatch <> -1 Then
	  Return $eScreenPlayStore
   EndIf

   ; $eScreenAndroidMessageBox
   If IsButtonPresent($rAndroidMessageButton1) Then Return $eScreenAndroidMessageBox
   If IsButtonPresent($rAndroidMessageButton2) Then Return $eScreenAndroidMessageBox

   ; $ScreenMain
   If IsColorPresent($rScreenMainColor) Then Return $eScreenMain

   ; $ScreenChatOpen
   If IsButtonPresent($rMainScreenOpenChatButton) Then Return $eScreenChatOpen

   ; $WindowChatDimmed
   If IsColorPresent($rWindowChatDimmedColor) Then Return $eScreenChatDimmed

   ; $ScreenFindMatch
   If IsButtonPresent($rFindMatchScreenFindAMatchNoShieldButton) Or _
	  IsButtonPresent($rFindMatchScreenFindAMatchWithShieldButton) Then Return $eScreenFindMatch

   ; $ScreenWaitRaid (with "Next")
   If IsButtonPresent($rWaitRaidScreenNextButton) Then Return $eScreenWaitRaid

   ; $ScreenLiveRaid (live attack)
   If IsColorPresent($rScreenLiveRaid1Color) And IsColorPresent($rScreenLiveRaid2Color) Then Return $eScreenLiveRaid

   ; $ScreenEndBattle
   If IsButtonPresent($rBattleHasEndedScreenReturnHomeButton) Then Return $eScreenEndBattle

   ; $ScreenLiveReplayEndBattle
   If IsButtonPresent($rLiveReplayEndScreenReturnHomeButton) Then Return $eScreenLiveReplayEndBattle

   ; $WindowVilliageWasAttacked
   If IsButtonPresent($rWindowVilliageWasAttackedOkayButton) Then Return $eScreenVilliageWasAttacked

   ; $eWindowArmyManager
   If IsButtonPresent($rArmyManagerWindowCloseButton) Then Return $eWindowArmyManager

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

	  ; Send 4 ctrl-minus keystrokes
	  For $i = 1 To 4
		 If $gMouseClickMethod = "MouseClick" Then
			Send("^-")
		 Else
			ControlSend($gTitle, "", "", "^-", 0)
		 EndIf

		 Sleep(250)
	  Next

	  If $clearOnSafeSpot Then
		 RandomWeightedClick($rSafeAreaButton)
		 Sleep(250)
	  EndIf

   EndIf
EndFunc

Func DragScreenDown()
   ; Drag down to set consistent location
   Local $startX, $startY
   Local $startBox[4] = [419, 65, 439, 110]
   RandomWeightedCoords($startBox, $startX, $startY)

   Local $endX, $endY
   Local $endBox[4] = [419, 240, 439, 285]
   RandomWeightedCoords($endBox, $endX, $endY)

   _ClickDrag($startX, $startY, $endX, $endY)
   Sleep(250)
EndFunc

Func DragScreenUp()
   ; Drag down to set consistent location
   Local $startX, $startY
   Local $startBox[4] = [419, 240, 439, 285]
   RandomWeightedCoords($startBox, $startX, $startY)

   Local $endX, $endY
   Local $endBox[4] = [419, 65, 439, 110]
   RandomWeightedCoords($endBox, $endX, $endY)

   _ClickDrag($startX, $startY, $endX, $endY)
   Sleep(250)
EndFunc
