Func DefenseFarm(ByRef $f, ByRef $timer)

   ; If we are waiting for the timer to expire, then make sure we are offline
   If TimerDiff($timer)<$gDefenseFarmOfflineTime Then
	  If WhereAmI($f)<>$eScreenAndroidHome Then
		 ResetToCoCMainScreen($f)

		 If _GUICtrlButton_GetCheck($GUI_DonateTroopsCheckBox) = $BST_CHECKED Then
			DonateTroops($f)
		 EndIf

		 If _GUICtrlButton_GetCheck($GUI_CollectLootCheckBox) = $BST_CHECKED Then
			CollectLoot($f)
		 EndIf

		 DumpCups($f)

		 If DefenseFarmGoOffline($f) = False Then
			ResetToCoCMainScreen($f)
		 EndIf

		 $timer = TimerInit()
	  EndIf
	  Return
   EndIf

   ; Otherwise, start up the game and dump cups
   DebugWrite("DefenseFarm() Starting Clash of Clans app and dumping cups")
   ResetToCoCMainScreen($f)
   DumpCups($f)
   $timer = TimerInit()
EndFunc


Func DefenseFarmGoOffline(ByRef $f)
   ; Return to main clash screen
   DebugWrite("DefenseFarmGoOffline() Exiting Clash of Clans app")
   ResetToCoCMainScreen($f)

   If WhereAmI($f)<>$eScreenMain Then
	  DebugWrite("DefenseFarmGoOffline() Error, could not return to main screen")
	  Return False
   EndIf

   ; Dismiss guard if present
   If IsButtonPresent($f, $rVillageGuardActiveInfoButton) Then
	  DebugWrite("DefenseFarmGoOffline() Dismissing Village Guard")
	  If DefenseFarmDismissGuard($f) = False Then
		 Return False
	  EndIf
   EndIf

   ; Click Android back button
   DebugWrite("DefenseFarmGoOffline() Clicking Android back button")
   RandomWeightedClick($rAndroidBackButton)

   ; Wait for Confirm Exit button
   If WaitForButton($f, 5000, $rConfirmExitButton) = False Then
	  DebugWrite("DefenseFarmGoOffline() Error, timeout waiting for Confirm Exit button")
	  Return False
   EndIf

   ; Click Confirm Exit button
   DebugWrite("DefenseFarmGoOffline() Clicking Confirm Exit button")
   RandomWeightedClick($rConfirmExitButton)

   ; Wait for Android home screen
   If WaitForScreen($f, 10000, $eScreenAndroidHome) = False Then
	  DebugWrite("DefenseFarmGoOffline() Error, timeout waiting for Android home screen")
	  Return False
   EndIf

   Return True
EndFunc

Func DefenseFarmDismissGuard(ByRef $f)
   ; Click Guard info button
   RandomWeightedClick($rVillageGuardActiveInfoButton)

   ; Wait for Village Guard info screen
   If WaitForButton($f, 5000, $rVillageGuardRemoveButton) = False Then
	  DebugWrite("DefenseFarmDismissGuard() Error, timeout waiting for Village Guard info screen")
	  Return
   EndIf

   ; Click Remove Guard button
   RandomWeightedClick($rVillageGuardRemoveButton)

   ; Wait for Remove Guard confirmation screen
   If WaitForButton($f, 5000, $rVillageGuardRemoveConfirmationButton) = False Then
	  DebugWrite("DefenseFarmDismissGuard() Error, timeout waiting for Village Guard info screen")
	  Return
   EndIf

   ; Click Remove Guard confirmation button
   RandomWeightedClick($rVillageGuardRemoveConfirmationButton)
   Sleep(500)

   ; Wait for main screen
   If WaitForScreen($f, 5000, $eScreenMain) = False Then
	  DebugWrite("DefenseFarmDismissGuard() Error, timeout waiting for main screen")
   EndIf

   Return True
EndFunc
