Func DefenseFarm(ByRef $timer)

   ; If we are waiting for the timer to expire, then make sure we are offline
   If TimerDiff($timer)<$gDefenseFarmOfflineTime Then
	  If WhereAmI()<>$eScreenAndroidHome Then
		 ResetToCoCMainScreen()
		 If _GUICtrlButton_GetCheck($GUI_DonateTroopsCheckBox) = $BST_CHECKED Then DonateTroops()
		 If _GUICtrlButton_GetCheck($GUI_CollectLootCheckBox) = $BST_CHECKED Then CollectLoot()
		 DumpCups()
		 DefenseFarmGoOffline()
		 $timer = TimerInit()
	  EndIf

	  Return
   EndIf

   ; Otherwise, start up the game and dump cups
   DebugWrite("DefenseFarm(), Starting Clash of Clans app and dumping cups.")
   ResetToCoCMainScreen()
   DumpCups()
   $timer = TimerInit()
EndFunc


Func DefenseFarmGoOffline()
   ; Return to main clash screen
   DebugWrite("DefenseFarmGoOffline(), Exiting Clash of Clans app.")
   ResetToCoCMainScreen()
   If WhereAmI()<>$eScreenMain Then
	  DebugWrite("DefenseFarmGoOffline(), error: could not return to main screen.")
	  Return
   EndIf

   ; Dismiss guard if present
   If IsButtonPresent($rVilliageGuardActiveInfoButton) Then
	  DebugWrite("DefenseFarmGoOffline(), dismissing Villiage Guard.")
	  DefenseFarmDismissGuard()
   EndIf

   ; Click Android back button
   RandomWeightedClick($rAndroidBackButton)

   ; Wait for Confirm Exit button
   Local $failCount = 10
   While IsButtonPresent($rConfirmExitButton)=False And $failCount>0
	  Sleep(500)
	  $failCount -= 1
   WEnd

   If $failCount = 0 Then
	  DebugWrite("DefenseFarmGoOffline(), error: timeout waiting for Confirm Exit button")
	  ResetToCoCMainScreen()
	  Return
   EndIf

   ; Click Confirm Exit button
   RandomWeightedClick($rConfirmExitButton)

   ; Wait for Android home screen
   Local $failCount = 10
   While WhereAmI() <> $eScreenAndroidHome And $failCount>0
	  Sleep(1000)
	  $failCount -= 1
   WEnd

   If $failCount = 0 Then
	  DebugWrite("DefenseFarmGoOffline(), error: timeout waiting for Android home screen")
	  ResetToCoCMainScreen()
	  Return False
   EndIf
EndFunc

Func DefenseFarmDismissGuard()
   ; Click Guard info button
   RandomWeightedClick($rVilliageGuardActiveInfoButton)

   ; Wait for Villiage Guard info screen
   Local $failCount = 10
   While IsButtonPresent($rVilliageGuardRemoveButton)=False And $failCount>0
	  Sleep(500)
	  $failCount -= 1
   WEnd

   If $failCount = 0 Then
	  DebugWrite("DefenseFarmDismissGuard(), error: timeout waiting for Villiage Guard info screen")
	  ResetToCoCMainScreen()
	  Return
   EndIf

   ; Click Remove Guard button
   RandomWeightedClick($rVilliageGuardRemoveButton)

   ; Wait for Remove Guard confirmation screen
   Local $failCount = 10
   While IsButtonPresent($rVilliageGuardRemoveConfirmationButton)=False And $failCount>0
	  Sleep(500)
	  $failCount -= 1
   WEnd

   If $failCount = 0 Then
	  DebugWrite("DefenseFarmDismissGuard(), error: timeout waiting for Villiage Guard info screen")
	  ResetToCoCMainScreen()
	  Return
   EndIf

   ; Click Remove Guard confirmation button
   RandomWeightedClick($rVilliageGuardRemoveConfirmationButton)

EndFunc
