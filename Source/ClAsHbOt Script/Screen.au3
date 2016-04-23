Func CheckForAndroidMessageBox(ByRef $hBMP)
   ;DebugWrite("CheckForAndroidMessageBox()")

   Local $boxPresent = False

   If IsButtonPresent($hBMP, $rAndroidMessageButton1) Then
	  DebugWrite("CheckForAndroidMessageBox() Clicking short Android Msg Box")

	  RandomWeightedClick($rAndroidMessageButton1)
	  Sleep(1000)

	  $boxPresent = True
   EndIf

   If IsButtonPresent($hBMP, $rAndroidMessageButton2) Then
	  DebugWrite("CheckForAndroidMessageBox() Clicking long Android Msg Box")

	  RandomWeightedClick($rAndroidMessageButton2)
	  Sleep(1000)

	  $boxPresent = True
   EndIf

   ; Wait for main screen
   If $boxPresent = True Then
	  If WaitForScreen($hBMP, 15000, $eScreenMain) Then ZoomOut($hBMP)
	  _WinAPI_DeleteObject($hBMP)
	  $hBMP = CaptureFrameHBITMAP("CheckForAndroidMessageBox")
   EndIf
EndFunc

Func GoOffline(ByRef $hBMP)
   ; Return to main clash screen
   DebugWrite("GoOffline() Exiting Clash of Clans app")
   ResetToCoCMainScreen($hBMP)

   If WhereAmI($hBMP)<>$eScreenMain Then
	  DebugWrite("GoOffline() Error, could not return to main screen")
	  Return False
   EndIf

   ; Click Android back button
   DebugWrite("GoOffline() Clicking Android back button")
   RandomWeightedClick($rAndroidBackButton)
   Sleep(500)

   ; Wait for Confirm Exit button (can't use WaitForButton function here, as it detects
   ; Attacking Disabled and can interfere with clicking Confirm Exit, as this function can
   ; be called from AutoRaid or DumpCups when a Attacking Disabled is detected.
   Local $t = TimerInit()
   Local $p1 = IsButtonPresent($hBMP, $rConfirmExitButton)
   While TimerDiff($t)<10000 And $p1=False
	  _WinAPI_DeleteObject($hBMP)
	  $hBMP = CaptureFrameHBITMAP("GoOffline" & Round((10000-TimerDiff($t))/1000))
	  $p1 = IsButtonPresent($hBMP, $rConfirmExitButton)
	  Sleep(500)
   WEnd

   If $p1 = False Then
	  DebugWrite("GoOffline() Error, timeout waiting for Confirm Exit button")
	  Return False
   EndIf

   ; Click Confirm Exit button
   DebugWrite("GoOffline() Clicking Confirm Exit button")
   RandomWeightedClick($rConfirmExitButton)

   ; Wait for Android home screen
   If WaitForScreen($hBMP, 10000, $eScreenAndroidHome) = False Then
	  DebugWrite("GoOffline() Error, timeout waiting for Android home screen")
	  Return False
   EndIf

   Sleep(2000)

   Return True
EndFunc

Func DismissGuard(ByRef $hBMP)
   If IsButtonPresent($hBMP, $rVillageGuardActiveInfoButton) = False Then Return

   DebugWrite("DismissGuard() Dismissing Village Guard")

   ; Click Guard info button
   RandomWeightedClick($rVillageGuardActiveInfoButton)

   ; Wait for Village Guard info screen
   If WaitForButton($hBMP, 5000, $rVillageGuardRemoveButton) = False Then
	  DebugWrite("DismissGuard() Error, timeout waiting for Village Guard info screen")
	  Return
   EndIf

   ; Click Remove Guard button
   RandomWeightedClick($rVillageGuardRemoveButton)

   ; Wait for Remove Guard confirmation screen
   If WaitForButton($hBMP, 5000, $rVillageGuardRemoveConfirmationButton) = False Then
	  DebugWrite("DismissGuard() Error, timeout waiting for Village Guard info screen")
	  Return
   EndIf

   ; Click Remove Guard confirmation button
   RandomWeightedClick($rVillageGuardRemoveConfirmationButton)
   Sleep(500)

   ; Wait for main screen
   If WaitForScreen($hBMP, 5000, $eScreenMain) = False Then
	  DebugWrite("DismissGuard() Error, timeout waiting for main screen")
   EndIf

   Return True
EndFunc

Func ResetToCoCMainScreen(ByRef $hBMP)
   Local $countdown = 5000

   CheckForAndroidMessageBox($hBMP)

   ; Get our current screen
   Local $s = WhereAmI($hBMP)

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
	  ;SaveDebugImage($f, "UnknownFrame" & Random(0, 100000, 1) & ".bmp")
	  Return False

   ; Android Home Screen - start CoC
   Case $eScreenAndroidHome
	  DebugWrite("ResetToCoCMainScreen() On Android Home Screen - Starting Clash of Clans")
	  Local $left, $top, $conf, $value
	  If FindBestBMP($eSearchClashIcon, $left, $top, $conf, $value) Then
		 Local $button[4] = [$left, $top, $left+$rScreenAndroidHomeCoCIconButton[2], $top+$rScreenAndroidHomeCoCIconButton[3]]
		 RandomWeightedClick($button)
		 $countdown = 30000
	  EndIf

   ; Clash screen in Play Store
   Case $eScreenPlayStore
	  DebugWrite("ResetToCoCMainScreen() On Clash Play Store Screen - Starting Clash of Clans")
	  Local $left, $top, $conf, $value
	  If FindBestBMP($eSearchPlayStoreOpenButton, $left, $top, $conf, $value) Then
		 Local $button[4] = [$left, $top, $left+$rScreenPlayStoreOpenButton[2], $top+$rScreenPlayStoreOpenButton[3]]
		 RandomWeightedClick($button)
		 $countdown = 30000
	  EndIf

   ; Android message box is open
   Case $eScreenAndroidMessageBox
	  If IsButtonPresent($hBMP, $rAndroidMessageButton1) Then
		 DebugWrite("ResetToCoCMainScreen() On Android Message Screen (1) - clicking message box")
		 RandomWeightedClick($rAndroidMessageButton1)
	  EndIf

	  If IsButtonPresent($hBMP, $rAndroidMessageButton2) Then
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

	  _WinAPI_DeleteObject($hBMP)
	  $hBMP = CaptureFrameHBITMAP("ResetToCoCMainScreen")
	  If WhereAmI($hBMP)=$eScreenChatOpen Then
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
   If WaitForScreen($hBMP, $countdown, $eScreenMain) Then
	  ZoomOut($hBMP)
	  Return True
   EndIf

   ; Check for Village was Attacked screen
   If WhereAmI($hBMP) = $eScreenVillageWasAttacked Then
	  DebugWrite("ResetToCoCMainScreen() On Village Was Attacked Screen - clicking Okay button")
	  RandomWeightedClick($rWindowVillageWasAttackedOkayButton)
   EndIf

   ; Wait for main screen to appear
   If WaitForScreen($hBMP, $countdown, $eScreenMain) Then
	  ZoomOut($hBMP)
	  Return True
   EndIf

   Return False
EndFunc

Func WhereAmI(Const $hBMP)
   If $gDebugSaveScreenCaptures Then _ScreenCapture_SaveImage("WhereAmIFrame.bmp", $hBMP, False)

   Local $left, $top, $conf, $value

   ; $eScreenAndroidMessageBox
   If IsButtonPresent($hBMP, $rAndroidMessageButton1) Then Return $eScreenAndroidMessageBox
   If IsButtonPresent($hBMP, $rAndroidMessageButton2) Then Return $eScreenAndroidMessageBox

   ; $ScreenMain
   If IsButtonPresent($hBMP, $rMainScreenAttackNoStarsButton) Or IsButtonPresent($hBMP, $rMainScreenAttackWithStarsButton) Then Return $eScreenMain

   ; $ScreenChatOpen
   If IsButtonPresent($hBMP, $rMainScreenOpenChatButton) Then Return $eScreenChatOpen

   ; $WindowChatDimmed
   If IsColorPresent($hBMP, $rWindowChatDimmedColor) Then Return $eScreenChatDimmed

   ; $ScreenFindMatch
   If IsButtonPresent($hBMP, $rFindMatchScreenFindAMatchNoShieldButton) Or _
	  IsButtonPresent($hBMP, $rFindMatchScreenFindAMatchWithShieldButton) Then Return $eScreenFindMatch

   ; $ScreenWaitRaid (with "Next")
   If IsButtonPresent($hBMP, $rWaitRaidScreenNextButton) Then Return $eScreenWaitRaid

   ; $ScreenLiveRaid (live attack)
   If IsButtonPresent($hBMP, $rLiveRaidScreenEndBattleButton) And IsButtonPresent($hBMP, $rWaitRaidScreenNextButton)=False Then Return $eScreenLiveRaid

   ; $ScreenEndBattle
   If IsButtonPresent($hBMP, $rBattleHasEndedScreenReturnHomeButton) Then Return $eScreenEndBattle

   ; $ScreenLiveReplayEndBattle
   If IsButtonPresent($hBMP, $rLiveReplayEndScreenReturnHomeButton) Then Return $eScreenLiveReplayEndBattle

   ; $WindowVillageWasAttacked
   If IsButtonPresent($hBMP, $rWindowVillageWasAttackedOkayButton) Then Return $eScreenVillageWasAttacked

   ; $eWindowArmyManager
   If IsButtonPresent($hBMP, $rArmyManagerWindowCloseButton) Then Return $eWindowArmyManager

   ; $eShopOrLayout
   If IsButtonPresent($hBMP, $rShopOrLayoutWindowsCloseButton) Then Return $eShopOrLayout

   ; $eProfile
   If IsButtonPresent($hBMP, $rProfileWindowCloseButton) Then Return $eProfile

   ; $eAchievements
   If IsButtonPresent($hBMP, $rAchievementsWindowCloseButton) Then Return $eAchievements

   ; $eSettings
   If IsButtonPresent($hBMP, $rSettingsWindowCloseButton) Then Return $eSettings

   ; $eStarBonus
   If IsButtonPresent($hBMP, $rStarBonusWindowOkayButton) Then Return $eStarBonus

   ; $ScreenAndroidHome
   If FindBestBMP($eSearchClashIcon, $left, $top, $conf, $value) Then Return $eScreenAndroidHome

   ; $eScreenPlayStore
   If FindBestBMP($eSearchPlayStoreOpenButton, $left, $top, $conf, $value) Then Return $eScreenPlayStore

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

Func ZoomOut(ByRef $hBMP)
   ; Virtual key codes: https://msdn.microsoft.com/en-us/library/dd375731(VS.85).aspx
   Local $VK_DOWN = 0x28

   ; Zoom out for 5 seconds, or until black strip appears on top of screen, indicating full zoom out
   ; If we can't zoom out within 5 seconds, then something is wrong; stop bot and display message box.
   Local $t = TimerInit()
   Local $p = IsColorPresent($hBMP, $rZoomedOutFullColor)

   If WhereAmI($hBMP)<>$eScreenMain Then Return
   If IsColorPresent($hBMP, $rZoomedOutFullColor) Then Return

   While TimerDiff($t)<5000 And $p=False

	  _SendMessage($gBlueStacksHwnd, $WM_KEYDOWN, $VK_DOWN, 0)
	  Sleep(100)
	  _SendMessage($gBlueStacksHwnd, $WM_KEYUP, $VK_DOWN, 0)

	  _WinAPI_DeleteObject($hBMP)
	  $hBMP = CaptureFrameHBITMAP("ZoomOut")
	  $p = IsColorPresent($hBMP, $rZoomedOutFullColor)
   WEnd

   If $p=False Then
	  MsgBox(BitOr($MB_OK, $MB_ICONERROR), "Error zooming out", "Error zooming out.  This is a catastropic error, the bot will now halt.")
	  If $gDebugSaveScreenCaptures Then _ScreenCapture_SaveImage("ZoomOutErrorFrame.bmp", $hBMP, False)
	  _WinAPI_DeleteObject($hBMP)
	  Exit
   EndIf

   ; Clear any inadvertent selections
   RandomWeightedClick($rSafeAreaButton)
   Sleep(250)
EndFunc

Func WaitForScreen(ByRef $hBMP, Const $wait, Const $s1, Const $s2=-1)
   Local $t = TimerInit()
   Local $s = WhereAmI($hBMP)
   Local $lastTimeRem = Round($wait/1000)

   _WinAPI_DeleteObject($hBMP)
   $hBMP = CaptureFrameHBITMAP("WaitForScreen " & $lastTimeRem)
   $s = WhereAmI($hBMP)

   While TimerDiff($t)<$wait And $s<>$s1 And $s<>$s2
	  Local $timeRem = Round(($wait-TimerDiff($t))/1000)

	  If $timeRem<>$lastTimeRem Then
		 $lastTimeRem = $timeRem
		 _WinAPI_DeleteObject($hBMP)
		 $hBMP = CaptureFrameHBITMAP("WaitForScreen " & $timeRem)
		 $s = WhereAmI($hBMP)
	  EndIf

	  Sleep(100)
   WEnd

   If $s=$s1 Or $s=$s2 Then
	  Return True
   Else
	  Return False
   EndIf
EndFunc
