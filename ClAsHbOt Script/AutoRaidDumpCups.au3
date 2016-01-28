Func DumpCups(ByRef $f)
   ;DebugWrite("DumpCups()")

   ; Cups I currently have
   GetMyLootNumbers($f)
   Local $myCups = Number(GUICtrlRead($GUI_MyCups))
   If $myCups = 0 Then
	  GetMyLootNumbers($f)
	  $myCups = Number(GUICtrlRead($GUI_MyCups))
	  If $myCups = 0 Then Return
   EndIf

   ; Max cups I want to have
   Local $cupsThreshold = Number(GUICtrlRead($GUI_AutoRaidDumpCupsThreshold))

   If $myCups < $cupsThreshold Then Return

   ; Make sure we are on the main Clash screen
   If WhereAmI($f) <> $eScreenMain Then
	  DebugWrite("DumpCups() Error, not on Clash main screen")
	  Return
   EndIf

   GUICtrlSetData($GUI_AutoStatus, "Auto: Dumping Cups")

   ; Dump 'em
   While (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_CHECKED Or _
		  _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox) = $BST_CHECKED Or _
		  _GUICtrlButton_GetCheck($GUI_DefenseFarmCheckBox) = $BST_CHECKED) And _
		 _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups) = $BST_CHECKED And _
		 $myCups > $cupsThreshold

	  DebugWrite("DumpCups() Dumping cups, current=" & $myCups & ", threshold=" & $cupsThreshold)
	  If DoCupsDump($f)=False Then ExitLoop

	  ; Get new cups count
	  GetMyLootNumbers($f)
	  $myCups = GUICtrlRead($GUI_MyCups)
   WEnd
EndFunc

Func DoCupsDump(ByRef $f)
   ; Get first available match
   Local $dummy
   If AutoRaidFindMatch($f, True, $dummy) = False Then
	  Return False
   EndIf

   ; What troops are available?
   Local $troopIndex[$eTroopCount][5]
   FindRaidTroopSlots($gTroopSlotBMPs, $troopIndex)
   UpdateRaidTroopCounts($troopIndex)

   Local $kingCount = $troopIndex[$eTroopKing][4]
   Local $queenCount = $troopIndex[$eTroopQueen][4]
   Local $wardenCount = $troopIndex[$eTroopWarden][4]
   Local $barbCount = $troopIndex[$eTroopBarbarian][4]
   Local $archCount = $troopIndex[$eTroopArcher][4]

   DebugWrite("DoCupsDump() King=" & $kingCount & " Queen=" & $queenCount & " Warden=" &  $wardenCount & " Barb=" & $barbCount & " Arch=" & $archCount)

   If $kingCount<1 And $queenCount<1 And $wardenCount<1 And $barbCount<1 And $archCount<1 Then
	  DebugWrite("DoCupsDump() Can't dump cups, no available king, queen, warden, arch or barb")
	  Return False
   EndIf

   If _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups)=$BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_DefenseFarmCheckBox)=$BST_UNCHECKED Then
	  Return False
   EndIf

   ; Deploy either warden, king, queen, barb or arch, which ever is available, in this order
   Local $button[4]

   If $wardenCount>0 Then
	  $button[0] = $rRaidTroopBox[0] + $troopIndex[$eTroopWarden][0]
	  $button[1] = $rRaidTroopBox[1] + $troopIndex[$eTroopWarden][1]
	  $button[2] = $rRaidTroopBox[0] + $troopIndex[$eTroopWarden][2]
	  $button[3] = $rRaidTroopBox[1] + $troopIndex[$eTroopWarden][3]
	  DebugWrite("DoCupsDump() Deploying Warden")

   ElseIf $kingCount>0 Then
	  $button[0] = $rRaidTroopBox[0] + $troopIndex[$eTroopKing][0]
	  $button[1] = $rRaidTroopBox[1] + $troopIndex[$eTroopKing][1]
	  $button[2] = $rRaidTroopBox[0] + $troopIndex[$eTroopKing][2]
	  $button[3] = $rRaidTroopBox[1] + $troopIndex[$eTroopKing][3]
	  DebugWrite("DoCupsDump() Deploying King")

   ElseIf $queenCount>0 Then
	  $button[0] = $rRaidTroopBox[0] + $troopIndex[$eTroopQueen][0]
	  $button[1] = $rRaidTroopBox[1] + $troopIndex[$eTroopQueen][1]
	  $button[2] = $rRaidTroopBox[0] + $troopIndex[$eTroopQueen][2]
	  $button[3] = $rRaidTroopBox[1] + $troopIndex[$eTroopQueen][3]
	  DebugWrite("DoCupsDump() Deploying Queen")

   ElseIf $barbCount>0 Then
	  $button[0] = $rRaidTroopBox[0] + $troopIndex[$eTroopBarbarian][0]
	  $button[1] = $rRaidTroopBox[1] + $troopIndex[$eTroopBarbarian][1]
	  $button[2] = $rRaidTroopBox[0] + $troopIndex[$eTroopBarbarian][2]
	  $button[3] = $rRaidTroopBox[1] + $troopIndex[$eTroopBarbarian][3]
	  DebugWrite("DoCupsDump() Deploying Barbarian")

   Else ; Archer
	  $button[0] = $rRaidTroopBox[0] + $troopIndex[$eTroopArcher][0]
	  $button[1] = $rRaidTroopBox[1] + $troopIndex[$eTroopArcher][1]
	  $button[2] = $rRaidTroopBox[0] + $troopIndex[$eTroopArcher][2]
	  $button[3] = $rRaidTroopBox[1] + $troopIndex[$eTroopArcher][3]
	  DebugWrite("DoCupsDump() Deploying Archer")

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
   DebugWrite("DoCupsDump() Clicking End Battle button")
   RandomWeightedClick($rLiveRaidScreenEndBattleButton)

   ; Wait for confirmation button
   If WaitForButton($f, 5000, $rLiveRaidScreenEndBattleConfirmButton) = False Then
	  DebugWrite("DoCupsDump() Error getting end battle confirmation button")
	  Return False
   EndIf

   ; Click end battle confirmation button
   DebugWrite("DoCupsDump() Clicking End Battle confirmation button")
   RandomWeightedClick($rLiveRaidScreenEndBattleConfirmButton)
   Sleep(500)

   ; Wait for battle end screen
   If WaitForScreen($f, 5000, $eScreenEndBattle) = False Then
	  DebugWrite("DoCupsDump() Error getting end battle screen")
	  Return False
   EndIf

   ; Close battle end screen
   DebugWrite("DoCupsDump() Clicking Return Home button" & @CRLF)
   RandomWeightedClick($rBattleHasEndedScreenReturnHomeButton)

   ; Wait for main screen to reappear
   If WaitForScreen($f, 5000, $eScreenMain) = False Then
	  DebugWrite("DoCupsDump() Error waiting for main screen")
	  Return False
   EndIf

   Return True
EndFunc
