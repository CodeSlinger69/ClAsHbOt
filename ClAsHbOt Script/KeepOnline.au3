Func CheckForAndroidMessageBox()

   ; Check for Android message boxes
   If IsButtonPresent($AndroidMessageButton) Then
	  DebugWrite("Online check: Clicking Android Msg Box")

	  WinActivate($gTitle)
	  WinWaitActive($gTitle)

	  RandomWeightedClick($AndroidMessageButton)
	  Sleep(2000)

	  ; Wait for main screen
	  Local $failCount = 15

	  Local $s = WhereAmI()
	  While $s <> $eScreenMain And $failCount>0
		 Sleep(1000)
		 $failCount -= 1
		 $s = WhereAmI()
	  WEnd

	  If $failCount>0 Then ZoomOut(False)
   EndIf
EndFunc



