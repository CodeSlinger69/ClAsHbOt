Func DefenseFarm(ByRef $hBMP, ByRef $timer)
   ; If we are waiting for the timer to expire, then make sure we are offline
   If TimerDiff($timer)<$gDefenseFarmOfflineTime Then
	  If WhereAmI($hBMP)<>$eScreenAndroidHome Then
		 DebugWrite("DefenseFarm() Not on Android Home screen, doing work")
		 DefenseFarmDoWork($hBMP)

		 If GoOffline($hBMP) = False Then
			ResetToCoCMainScreen($hBMP)
		 Else
			DebugWrite("DefenseFarm() On Android Home screen, waiting " & Round($gDefenseFarmOfflineTime/1000/60) & " minutes")
			$timer = TimerInit()
		 EndIf
	  EndIf

   ; Otherwise, start up the game and do work
   Else
	  DebugWrite("DefenseFarm() Starting Clash of Clans app and dumping cups")
	  DefenseFarmDoWork($hBMP)
	  $timer = TimerInit()

   EndIf
EndFunc

Func DefenseFarmDoWork(ByRef $hBMP)
   ResetToCoCMainScreen($hBMP)

   If WhereAmI($hBMP)<>$eScreenMain Then Return

   If _GUICtrlButton_GetCheck($GUI_DonateTroopsCheckBox) = $BST_CHECKED Then
	  DebugWrite("DefenseFarmDoWork() Donating troops")
	  DonateTroops($hBMP)
   EndIf

   If _GUICtrlButton_GetCheck($GUI_CollectLootCheckBox) = $BST_CHECKED Then
	  DebugWrite("DefenseFarmDoWork() Collecting loot")
	  CollectLoot()
   EndIf

   If _GUICtrlButton_GetCheck($GUI_ReloadDefensesCheckBox) = $BST_CHECKED Then
	  DebugWrite("DefenseFarmDoWork() Reloading defenses")
	  ReloadDefenses($hBMP)
   EndIf

   DebugWrite("DefenseFarmDoWork() Dumping cups")
   DumpCups($hBMP)
EndFunc

Func GoOffline(ByRef $hBMP)
   ; Return to main clash screen
   DebugWrite("GoOffline() Exiting Clash of Clans app")
   ResetToCoCMainScreen($hBMP)

   If WhereAmI($hBMP)<>$eScreenMain Then
	  DebugWrite("GoOffline() Error, could not return to main screen")
	  Return False
   EndIf

   ; Dismiss guard if present
   If IsButtonPresent($hBMP, $rVillageGuardActiveInfoButton) Then
	  DebugWrite("GoOffline() Dismissing Village Guard")
	  If DismissGuard($hBMP) = False Then
		 Return False
	  EndIf
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

   Sleep(10000)

   Return True
EndFunc

Func DismissGuard(ByRef $hBMP)
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
