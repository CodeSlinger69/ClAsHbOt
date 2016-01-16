Func DumpCups()
   ;DebugWrite("DumpCups()")

   ; Cups I currently have
   Local $myCups = Number(GUICtrlRead($GUI_MyCups))
   If $myCups = 0 Then
	  ResetToCoCMainScreen()
	  GetMyLootNumbers()
	  $myCups = Number(GUICtrlRead($GUI_MyCups))
   EndIf

   ; Max cups I want to have
   Local $cupsThreshold = Number(GUICtrlRead($GUI_AutoRaidDumpCupsThreshold))

   ; Make sure we are on the main Clash screen
   If $myCups > $cupsThreshold Then
	  If WhereAmI() = $eScreenMain Then
		 ZoomOut(True)
	  Else
		 ResetToCoCMainScreen()

		 If WhereAmI()<>$eScreenMain Then
			DebugWrite("DumpCups(), error: Not on Clash main screen")
			Return
		 EndIf
	  EndIf
   EndIf

   ; Dump 'em
   While (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_CHECKED Or _
		  _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox) = $BST_CHECKED Or _
		  _GUICtrlButton_GetCheck($GUI_DefenseFarmCheckBox) = $BST_CHECKED) And _
		 _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups) = $BST_CHECKED And _
		 $myCups > $cupsThreshold

	  DebugWrite("Dumping cups, current=" & $myCups & ", threshold=" & $cupsThreshold)
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Dumping Cups")
	  If DoCupsDump()=False Then Return

	  GetMyLootNumbers()
	  $myCups = GUICtrlRead($GUI_MyCups)
   WEnd
EndFunc

Func DoCupsDump()
   ; Get first available match
   Local $dummy
   AutoRaidFindMatch(True, $dummy)
   DragScreenDown()

   ; What troops are available?
   Local $troopIndex[$eTroopCount][5]
   FindRaidTroopSlots($gTroopSlotBMPs, $troopIndex)
   UpdateRaidTroopCounts($troopIndex)

   Local $kingCount = $troopIndex[$eTroopKing][4]
   Local $queenCount = $troopIndex[$eTroopQueen][4]
   Local $wardenCount = $troopIndex[$eTroopWarden][4]
   Local $barbCount = $troopIndex[$eTroopBarbarian][4]
   Local $archCount = $troopIndex[$eTroopArcher][4]

   DebugWrite("DoCupsDump(), king, queen, warden, barb, arch: " & $kingCount & ", " & $queenCount & ", " &  $wardenCount & ", " & $barbCount & ", " & $archCount)

   If $kingCount<1 And $queenCount<1 And $wardenCount<1 And $barbCount<1 And $archCount<1 Then
	  DebugWrite("DoCupsDump(), Can't dump cups, no available king, queen, warden, arch or barb.")

	  Return False
   EndIf

   If _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups)=$BST_UNCHECKED And _
	  _GUICtrlButton_GetCheck($GUI_DefenseFarmCheckBox)=$BST_UNCHECKED Then
	  Return False
   EndIf

   ; Deploy either king, queen, warden, barb or arch, which ever is available, in this order
   Local $button[4]

   If $kingCount>0 Then
	  For $i = 0 To 3
		 $button[$i] = $troopIndex[$eTroopKing][$i]
	  Next

   ElseIf $queenCount>0 Then
	  For $i = 0 To 3
		 $button[$i] = $troopIndex[$eTroopQueen][$i]
	  Next

   ElseIf $wardenCount>0 Then
	  For $i = 0 To 3
		 $button[$i] = $troopIndex[$eTroopWarden][$i]
	  Next

   ElseIf $barbCount>0 Then
	  For $i = 0 To 3
		 $button[$i] = $troopIndex[$eTroopBarbarian][$i]
	  Next

   Else ; Archer
	  For $i = 0 To 3
		 $button[$i] = $troopIndex[$eTroopArcher][$i]
	  Next
   EndIf

   ; Select the troop to be deployed
   RandomWeightedClick($button)
   Sleep(500)

   ; Drop troop
   Local $deploySpot[4]
   $deploySpot[0] = $NWDeployBoxes[0][0]
   $deploySpot[1] = $NWDeployBoxes[0][1]
   $deploySpot[2] = $NWDeployBoxes[0][0]+10
   $deploySpot[3] = $NWDeployBoxes[0][1]+10
   RandomWeightedClick($deploySpot)
   Sleep(500)

   ; Click End Battle button
   ;DebugWrite("Ending battle")
   RandomWeightedClick($rLiveRaidScreenEndBattleButton)

   ; Wait for confirmation button
   Local $failCount=20
   Do
	  Sleep(100)
	  $failCount-=1
   Until IsButtonPresent($rLiveRaidScreenEndBattleConfirmButton) Or $failCount<=0 Or _
		 _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups)=$BST_UNCHECKED

   If _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups)=$BST_UNCHECKED Then Return False

   If $failCount>0 Then
	  ;DebugWrite("Clicking end battle confirmation button")
	  RandomWeightedClick($rLiveRaidScreenEndBattleConfirmButton)
	  Sleep(500)
   Else
	  DebugWrite("DoCupsDump(), Error getting end battle confirmation button.")
	  Return False
   EndIf

   ; Wait for battle end screen
   ;DebugWrite("Waiting for battle end screen")
   $failCount=20
   While WhereAmI()<>$eScreenEndBattle And $failCount>0 And _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups)=$BST_CHECKED
	  Sleep(200)
	  $failCount-=1
   WEnd

   If _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups)=$BST_UNCHECKED Then Return False

   If $failCount<=0 Then
	  DebugWrite("DoCupsDump(), Error getting end battle screen.")
	  Return False
   EndIf

   ; Close battle end screen
   RandomWeightedClick($rBattleHasEndedScreenReturnHomeButton)

   ; Wait for main screen to reappear
   $failCount=20
   While WhereAmI()<>$eScreenMain And $failCount>0 And _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups)=$BST_CHECKED
	  Sleep(1000)
	  $failCount -= 1
   WEnd

   If _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups)=$BST_UNCHECKED Then Return False

   If $failCount<=0 Then
	  DebugWrite("DoCupsDump(), Error waiting for main screen.")
	  Return False
   EndIf

   Return True
EndFunc
