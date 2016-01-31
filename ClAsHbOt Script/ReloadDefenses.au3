Func ReloadDefenses(ByRef $f)
   ;DebugWrite("ReloadDefenses()")

   If ResetToCoCMainScreen($f) = False Then
	  DebugWrite("ReloadDefenses() Not on main screen, exiting")
	  Return
   EndIf

   ; Find town hall
   RandomWeightedClick($rSafeAreaButton)
   Sleep(500)
   Local $conf, $x, $y
   Local $th = FindBestBMP($eSearchTypeTownHall, $x, $y, $conf)
   If $th = -1 Then
	  DebugWrite("ReloadDefenses() Could not find Town Hall, exiting")
	  Return
   EndIf

   ; Click on town hall
   Local $button[4] = [ $x + 6, $y + 15, $x + 16, $y + 25 ]
   DebugWrite("ReloadDefenses() Clicking Town Hall " & $button[0] & ", " & $button[1] & ", " & $button[2] & ", " & $button[3])
   RandomWeightedClick($button)
   Sleep(500)

   ; Wait for reload bar
   Local $buttonIndex[4][4]

   If WaitForReloadBar($buttonIndex) = False Then
	  DebugWrite("ReloadDefenses() Could not find Reload button bar, exiting")
	  Return
   EndIf

   DebugWrite("ReloadDefenses() Found Reload button bar")

   ; See if each reload button is present
   For $i = 1 To 3
	  If $buttonIndex[$i][0] <> -1 Then
		 ; Click button
		 Local $button[4]
		 For $j = 0 To 3
			$button[$j] = $buttonIndex[$i][$j]
		 Next
		 DebugWrite("ReloadDefenses() Found " & $gReloadButtonNames[$i] & " button, clicking")
		 RandomWeightedClick($button)

		 ; Wait for Reload confirmation window
		 If WaitForButton($f, 5000, $rReloadDefensesOkayButton) = False Then
			DebugWrite("ReloadDefenses() Failed - timeout waiting for Reload Confirmation window, resetting")
			_GDIPlus_BitmapDispose($f)
			$f = CaptureFrame("ReloadDefenses")
			ResetToCoCMainScreen($f)
			Return
		 Else
			Sleep(500)

			; Click OK button
			DebugWrite("ReloadDefenses() Found confirmation window, clicking OK button")
			RandomWeightedClick($rReloadDefensesOkayButton)

			; Wait for reload bar
			If WaitForReloadBar($buttonIndex) = False Then
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

Func WaitForReloadBar(ByRef $index)
   Local $t = TimerInit()
   For $i=0 To 3
	  $index[$i][0] = -1
	  $index[$i][1] = -1
	  $index[$i][2] = -1
	  $index[$i][3] = -1
   Next
   Local $matchCount = LocateSlots($eActionTypeReloadButton, $eSlotTypeTroop, $index)

   While TimerDiff($t)<5000 And $index[0][0]=-1
	  Sleep(500)
	  For $i=0 To 3
		 $index[$i][0] = -1
		 $index[$i][1] = -1
		 $index[$i][2] = -1
		 $index[$i][3] = -1
	  Next
	  $matchCount = LocateSlots($eActionTypeReloadButton, $eSlotTypeTroop, $index)
   WEnd

   If $index[0][0] = -1 Then
	  Return False
   EndIf

   Return True
EndFunc
