Func ReloadDefenses(ByRef $f)
   ;DebugWrite("ReloadDefenses()")

   Local $th, $conf, $x, $y
   Local $button[4]

   If ResetToCoCMainScreen($f) = False Then
	  DebugWrite("ReloadDefenses() Not on main screen, exiting")
	  Return
   EndIf

   ; Find town hall
   RandomWeightedClick($rSafeAreaButton)
   Sleep(500)
   FindTownHall($th, $x, $y, $conf)
   If $th = -1 Then
	  DebugWrite("ReloadDefenses() Could not find Town Hall, exiting")
	  Return
   EndIf

   ; Click on town hall
   $button[0] = $x + 6
   $button[1] = $y + 15
   $button[2] = $x + 16
   $button[3] = $y + 25
   DebugWrite("ReloadDefenses() Clicking Town Hall " & $button[0] & ", " & $button[1] & ", " & $button[2] & ", " & $button[3])
   RandomWeightedClick($button)
   Sleep(500)

   ; Wait for reload bar
   If WaitForReloadBar($f) = False Then
	  DebugWrite("ReloadDefenses() Could not find Reload button bar, exiting")
	  Return
   EndIf

   DebugWrite("ReloadDefenses() Found Reload button bar")

   ; See if each reload button is present
   For $i = 0 To UBound($gDefenseReloadButtonsBMPs)-1
	  ScanFrameForOneBMP($f, "Images\"&$gDefenseReloadButtonsBMPs[$i], $conf, $x, $y)

	  If $conf > $gConfidenceReloadBarButton Then
		 ; Click button
		 $button[0] = $rReloadDefensesBox[0] + $x + $rReloadDefensesButtonOffset[0]
		 $button[1] = $rReloadDefensesBox[1] + $y + $rReloadDefensesButtonOffset[1]
		 $button[2] = $rReloadDefensesBox[0] + $x + $rReloadDefensesButtonOffset[2]
		 $button[3] = $rReloadDefensesBox[1] + $y + $rReloadDefensesButtonOffset[3]

		 DebugWrite("ReloadDefenses() Found " & $gDefenseReloadButtonsBMPs[$i] & " button, clicking")
		 RandomWeightedClick($button)

		 ; Wait for Reload confirmation window
		 If WaitForButton($f, 5000, $rReloadDefensesOkayButton) = False Then
			DebugWrite("ReloadDefenses() Failed - timeout waiting for Reload Confirmation window, resetting")
			_GDIPlus_BitmapDispose($f)
			$f = CaptureFrame("ReloadDefenses")
			ResetToCoCMainScreen($f)
			Return
		 Else
			; Click OK button
			RandomWeightedClick($rReloadDefensesOkayButton)

			; Wait for reload bar
			If WaitForReloadBar($f) = False Then
			   DebugWrite("ReloadDefenses() Reload button bar did not reappear, resetting")
			   _GDIPlus_BitmapDispose($f)
			   $f = CaptureFrame("ReloadDefenses")
			   ResetToCoCMainScreen($f)
			   Return
			EndIf
		 EndIf

	  EndIf
   Next

   ; Deselect Town Hall
   RandomWeightedClick($rSafeAreaButton)
   Sleep(500)

   _GDIPlus_BitmapDispose($f)
   $f = CaptureFrame("ReloadDefenses")
EndFunc

Func WaitForReloadBar(ByRef $f)
   Local $t = TimerInit()
   Local $gotBar = False
   $f = CaptureFrame("WaitForReloadBar", $rReloadDefensesBox[0], $rReloadDefensesBox[1], $rReloadDefensesBox[2], $rReloadDefensesBox[3])

   While TimerDiff($t)<5000 And $gotBar = False
	  If $gDebugSaveScreenCaptures Then SaveDebugImage($f, "ReloadDefensesFrame.bmp")

	  Local $conf, $x, $y
	  ScanFrameForOneBMP($f, "Images\"&$gDefenseReloadInfoButtonBMP, $conf, $x, $y)

	  If $conf > $gConfidenceReloadBarButton Then $gotBar = True

	  Sleep(500)
	  _GDIPlus_BitmapDispose($f)
	  $f = CaptureFrame("WaitForReloadBar", $rReloadDefensesBox[0], $rReloadDefensesBox[1], $rReloadDefensesBox[2], $rReloadDefensesBox[3])
   WEnd

   Return $gotBar
EndFunc
