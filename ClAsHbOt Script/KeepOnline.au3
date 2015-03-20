Func CheckForAndroidMessageBox()
   Local $cPos = GetClientPos()

   ; Check for Android message boxes
   If PixelGetColor($cPos[0]+$AndroidMessageButton[4], $cPos[1]+$AndroidMessageButton[5]) = $AndroidMessageButton[6] Then
	  DebugWrite("Online check: Clicking Android Msg Box")

	  WinActivate($title)
	  WinWaitActive($title)

	  Local $xClick, $yClick
	  RandomWeightedCoords($AndroidMessageButton, $xClick, $yClick)
	  MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)
	  Sleep(2000)

	  ; Wait for main screen
	  Local $failCount = 15

	  Local $s = WhereAmI()
	  While $s <> $ScreenMain And $failCount>0 And $ExitApp = False
		 Sleep(1000)
		 UpdateCountdownTimers()
		 $failCount -= 1
		 $s = WhereAmI()
	  WEnd

	  If $failCount>0 Then ZoomOut(False)
   EndIf
EndFunc



