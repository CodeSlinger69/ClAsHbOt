Func CheckForAndroidMessageBox(ByRef $f)
   ;DebugWrite("CheckForAndroidMessageBox()")

   Local $boxPresent = False

   If IsButtonPresent($f, $rAndroidMessageButton1) Then
	  DebugWrite("CheckForAndroidMessageBox() Clicking short Android Msg Box")

	  RandomWeightedClick($rAndroidMessageButton1)

	  $boxPresent = True
   EndIf

   If IsButtonPresent($f, $rAndroidMessageButton2) Then
	  DebugWrite("CheckForAndroidMessageBox() Clicking long Android Msg Box")

	  RandomWeightedClick($rAndroidMessageButton2)

	  $boxPresent = True
   EndIf

   ; Wait for main screen
   If $boxPresent = True Then
	  If WaitForScreen($f, 15000, $eScreenMain) Then ZoomOut2($f)
	  _GDIPlus_BitmapDispose($f)
	  $f = CaptureFrame("CheckForAndroidMessageBox")
   EndIf
EndFunc

Func ResetToCoCMainScreen(ByRef $f)
   Local $countdown = 5000

   CheckForAndroidMessageBox($f)

   ; Get our current screen
   Local $s = WhereAmI($f)

   Switch $s

   ; Main screen, do nothing
   Case $eScreenMain
	  Return True

   ; Live raid screen - do nothing - don't interrupt a live raid
   Case $eScreenLiveRaid
	  DebugWrite("ResetToCoCMainScreen() On Live Raid Screen - doing nothing")
	  Return False

   ; Wait raid screen - do nothing - don't interrupt a Find Match or Auto Raid in progress
   Case $eScreenWaitRaid
	  DebugWrite("ResetToCoCMainScreen() On Wait Raid Screen - doing nothing")
	  Return False

   ; Unknown screen - don't do anything
   Case $eScreenUnknown
	  DebugWrite("ResetToCoCMainScreen() On Unknown Screen - doing nothing")
	  _GDIPlus_ImageSaveToFile($f, "UnknownFrame" & Random(0, 100000, 1) & ".bmp")
	  Return False

   ; Android Home Screen - start CoC
   Case $eScreenAndroidHome
	  DebugWrite("ResetToCoCMainScreen() On Android Home Screen - Starting Clash of Clans")
      Local $bestMatch = 99, $bestConfidence = 0, $bestX = 0, $bestY = 0
	  ScanFrameForBestBMP($f, $CoCIconBMPs, 0.95, $bestMatch, $bestConfidence, $bestX, $bestY)
	  If $bestMatch <> 99 Then
		 Local $button[4] = [$bestX, $bestY, $bestX+$rScreenAndroidHomeCoCIconButton[2], $bestY+$rScreenAndroidHomeCoCIconButton[3]]
		 RandomWeightedClick($button)
		 $countdown = 30000
	  EndIf

   ; Clash screen in Play Store
   Case $eScreenPlayStore
	  DebugWrite("ResetToCoCMainScreen() On Clash Play Store Screen - Starting Clash of Clans")
      Local $bestMatch = 99, $bestConfidence = 0, $bestX = 0, $bestY = 0
	  ScanFrameForBestBMP($f, $gPlayStoreOpenButton, 0.95, $bestMatch, $bestConfidence, $bestX, $bestY)
	  If $bestMatch <> 99 Then
		 Local $button[4] = [$bestX, $bestY, $bestX+$rScreenPlayStoreOpenButton[2], $bestY+$rScreenPlayStoreOpenButton[3]]
		 RandomWeightedClick($button)
		 $countdown = 30000
	  EndIf

   ; Android message box is open
   Case $eScreenAndroidMessageBox
	  If IsButtonPresent($f, $rAndroidMessageButton1) Then
		 DebugWrite("ResetToCoCMainScreen() On Android Message Screen (1) - clicking message box")
		 RandomWeightedClick($rAndroidMessageButton1)
	  EndIf

	  If IsButtonPresent($f, $rAndroidMessageButton2) Then
		 DebugWrite("ResetToCoCMainScreen() On Android Message Screen (2) - clicking message box")
		 RandomWeightedClick($rAndroidMessageButton2)
	  EndIf

   ; CoC Chat Open
   Case $eScreenChatOpen
	  DebugWrite("ResetToCoCMainScreen() On Chat Open Screen - closing chat")
	  RandomWeightedClick($rMainScreenOpenChatButton)

   ; Chat window open but dimmed - click on safe spot
   Case $eScreenChatDimmed
	  DebugWrite("ResetToCoCMainScreen() On Chat Dimmed Screen - clicking safe spot")
	  RandomWeightedClick($rSafeAreaButton)
	  Sleep(1000)

	  _GDIPlus_BitmapDispose($f)
	  $f = CaptureFrame("ResetToCoCMainScreen")
	  If WhereAmI($f)=$eScreenChatOpen Then
		 DebugWrite("ResetToCoCMainScreen() On Chat Open Screen - closing chat")
		 RandomWeightedClick($rMainScreenOpenChatButton)
	  EndIf

   ; CoC Find Match screen
   Case $eScreenFindMatch
	  DebugWrite("ResetToCoCMainScreen() On Find Match Screen - clicking close button")
	  RandomWeightedClick($rFindMatchScreenCloseWindowButton)

   ; End Battle screen
   Case $eScreenEndBattle
	  DebugWrite("ResetToCoCMainScreen() On End Battle Screen - clicking Return Home button")
	  RandomWeightedClick($rBattleHasEndedScreenReturnHomeButton)

   ; Live Replay End Battle screen
   Case $eScreenLiveReplayEndBattle
	  DebugWrite("ResetToCoCMainScreen() On Live Replay End Battle Screen - clicking Return Home button")
	  RandomWeightedClick($rLiveReplayEndScreenReturnHomeButton)

   ; Village Was Attacked screen
   Case $eScreenVillageWasAttacked
	  DebugWrite("ResetToCoCMainScreen() On Village Was Attached Screen - clicking Okay button")
	  RandomWeightedClick($rWindowVillageWasAttackedOkayButton)

   ; Army Manager window
   Case $eWindowArmyManager
	  DebugWrite("ResetToCoCMainScreen() On Army Manager window - clicking close button")
	  RandomWeightedClick($rArmyManagerWindowCloseButton)

   ; Shop or Layout windows
   Case $eShopOrLayout
	  DebugWrite("ResetToCoCMainScreen() On Shop or Layout window - clicking close button")
	  RandomWeightedClick($rShopOrLayoutWindowsCloseButton)

   ; Profile window
   Case $eProfile
   DebugWrite("ResetToCoCMainScreen() On Profile window - clicking close button")
	  RandomWeightedClick($rProfileWindowCloseButton)

   ; Achievements window
   Case $eAchievements
   DebugWrite("ResetToCoCMainScreen() On Achievements window - clicking close button")
	  RandomWeightedClick($rAchievementsWindowCloseButton)

   ; Settings window
   Case $eSettings
   DebugWrite("ResetToCoCMainScreen() On Settings window - clicking close button")
	  RandomWeightedClick($rSettingsWindowCloseButton)

   ; Star Bonus window
   Case $eStarBonus
   DebugWrite("ResetToCoCMainScreen() On Star Bonus window - clicking close button")
	  RandomWeightedClick($rStarBonusWindowOkayButton)


   EndSwitch



   ; Wait for main screen to appear
   If WaitForScreen($f, $countdown, $eScreenMain) Then
	  ZoomOut2($f)
	  Return True
   EndIf

   ; Check for Village was Attacked screen
   If WhereAmI($f) = $eScreenVillageWasAttacked Then
	  DebugWrite("ResetToCoCMainScreen() On Village Was Attacked Screen - clicking Okay button")
	  RandomWeightedClick($rWindowVillageWasAttackedOkayButton)
   EndIf

   ; Wait for main screen to appear
   If WaitForScreen($f, $countdown, $eScreenMain) Then
	  ZoomOut2($f)
	  Return True
   EndIf

   Return False
EndFunc

Func WhereAmI(Const $f)
   If $gDebugSaveScreenCaptures Then _GDIPlus_ImageSaveToFile($f, "WhereAmIFrame.bmp")

   ; $ScreenAndroidHome
   Local $bestMatch, $bestConfidence, $bestX, $bestY
   ScanFrameForBestBMP($f, $CoCIconBMPs, 0.95, $bestMatch, $bestConfidence, $bestX, $bestY)
   ;DebugWrite("Android Home Scan: " & $bestMatch & " " & $bestConfidence & " " & $bestX & " " & $bestY)

   If $bestMatch <> -1 Then
	  Return $eScreenAndroidHome
   EndIf

   ; $eScreenPlayStore
   Local $bestMatch, $bestConfidence, $bestX, $bestY
   ScanFrameForBestBMP($f, $gPlayStoreOpenButton, 0.99, $bestMatch, $bestConfidence, $bestX, $bestY)
   ;DebugWrite("Play Store scan: " & $bestMatch & " " & $bestConfidence & " " & $bestX & " " & $bestY)

   If $bestMatch <> -1 Then
	  Return $eScreenPlayStore
   EndIf

   ; $eScreenAndroidMessageBox
   If IsButtonPresent($f, $rAndroidMessageButton1) Then Return $eScreenAndroidMessageBox
   If IsButtonPresent($f, $rAndroidMessageButton2) Then Return $eScreenAndroidMessageBox

   ; $ScreenMain
   If IsButtonPresent($f, $rMainScreenAttackNoStarsButton) Or IsButtonPresent($f, $rMainScreenAttackWithStarsButton) Then Return $eScreenMain

   ; $ScreenChatOpen
   If IsButtonPresent($f, $rMainScreenOpenChatButton) Then Return $eScreenChatOpen

   ; $WindowChatDimmed
   If IsColorPresent($f, $rWindowChatDimmedColor) Then Return $eScreenChatDimmed

   ; $ScreenFindMatch
   If IsButtonPresent($f, $rFindMatchScreenFindAMatchNoShieldButton) Or _
	  IsButtonPresent($f, $rFindMatchScreenFindAMatchWithShieldButton) Then Return $eScreenFindMatch

   ; $ScreenWaitRaid (with "Next")
   If IsButtonPresent($f, $rWaitRaidScreenNextButton) Then Return $eScreenWaitRaid

   ; $ScreenLiveRaid (live attack)
   If IsButtonPresent($f, $rLiveRaidScreenEndBattleButton) And IsButtonPresent($f, $rWaitRaidScreenNextButton)=False Then Return $eScreenLiveRaid

   ; $ScreenEndBattle
   If IsButtonPresent($f, $rBattleHasEndedScreenReturnHomeButton) Then Return $eScreenEndBattle

   ; $ScreenLiveReplayEndBattle
   If IsButtonPresent($f, $rLiveReplayEndScreenReturnHomeButton) Then Return $eScreenLiveReplayEndBattle

   ; $WindowVillageWasAttacked
   If IsButtonPresent($f, $rWindowVillageWasAttackedOkayButton) Then Return $eScreenVillageWasAttacked

   ; $eWindowArmyManager
   If IsButtonPresent($f, $rArmyManagerWindowCloseButton) Then Return $eWindowArmyManager

   ; $eShopOrLayout
   If IsButtonPresent($f, $rShopOrLayoutWindowsCloseButton) Then Return $eShopOrLayout

   ; $eProfile
   If IsButtonPresent($f, $rProfileWindowCloseButton) Then Return $eProfile

   ; $eAchievements
   If IsButtonPresent($f, $rAchievementsWindowCloseButton) Then Return $eAchievements

   ; $eSettings
   If IsButtonPresent($f, $rSettingsWindowCloseButton) Then Return $eSettings

   ; $eStarBonus
   If IsButtonPresent($f, $rStarBonusWindowOkayButton) Then Return $eStarBonus

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

Func ZoomOut2(ByRef $f)
   ; Virtual key codes: https://msdn.microsoft.com/en-us/library/dd375731(VS.85).aspx
   Local $VK_DOWN = 0x28

   ; Zoom out for 5 seconds, or until black strip appears on top of screen, indicating full zoom out
   ; If we can't zoom out within 5 seconds, then something is wrong; stop bot and display message box.
   Local $t = TimerInit()
   Local $p = IsColorPresent($f, $rZoomedOutFullColor)

   If WhereAmI($f)<>$eScreenMain Then Return
   If IsColorPresent($f, $rZoomedOutFullColor) Then Return

   While TimerDiff($t)<5000 And $p=False
	  _SendMessage($gBlueStacksHwnd, $WM_KEYDOWN, $VK_DOWN, 0)
	  Sleep(100)
	  _SendMessage($gBlueStacksHwnd, $WM_KEYUP, $VK_DOWN, 0)
	  _GDIPlus_BitmapDispose($f)
	  $f = CaptureFrame("ZoomOut2")
	  $p = IsColorPresent($f, $rZoomedOutFullColor)
   WEnd

   If $p=False Then
	  MsgBox(BitOr($MB_OK, $MB_ICONERROR), "Error zooming out", "Error zooming out.  This is a catastropic error, the bot will now halt.")
	  If $gDebugSaveScreenCaptures Then _GDIPlus_ImageSaveToFile($f, "ZoomOutErrorFrame.bmp")
	  _GDIPlus_BitmapDispose($f)
	  Exit
   EndIf

   ; Clear any inadvertent selections
   RandomWeightedClick($rSafeAreaButton)
   Sleep(250)
EndFunc

Func WaitForScreen(ByRef $f, Const $wait, Const $s1, Const $s2=-1)
   Local $t = TimerInit()
   Local $s = WhereAmI($f)
   Local $lastTimeRem = Round($wait/1000)
   $f = CaptureFrame("WaitForScreen " & $lastTimeRem)
   $s = WhereAmI($f)

   While TimerDiff($t)<$wait And $s<>$s1 And $s<>$s2
	  Local $timeRem = Round(($wait-TimerDiff($t))/1000)

	  If $timeRem<>$lastTimeRem Then
		 $lastTimeRem = $timeRem
		 _GDIPlus_BitmapDispose($f)
		 $f = CaptureFrame("WaitForScreen " & $timeRem)
		 $s = WhereAmI($f)
	  EndIf

	  Sleep(100)
   WEnd

   If $s=$s1 Or $s=$s2 Then
	  Return True
   Else
	  Return False
   EndIf
EndFunc