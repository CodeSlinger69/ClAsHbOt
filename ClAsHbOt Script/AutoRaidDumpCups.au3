Func DumpCups()
   ;DebugWrite("DumpCups()")

   Local $myCups = Number(GUICtrlRead($GUI_MyCups))
   Local $cupsThreshold = Number(GUICtrlRead($GUI_AutoRaidDumpCupsThreshold))

   If $myCups > $cupsThreshold Then
	  ResetToCoCMainScreen()
   EndIf

   While (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_CHECKED Or _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox) = $BST_CHECKED) And _
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
   AutoRaidFindMatch(True)

   ; What troops are available?
   Local $troopIndex[$eTroopCount][4]
   FindRaidTroopSlots($gTroopSlotBMPs, $troopIndex)

   If GetAvailableTroops($eTroopBarbarian, $troopIndex)<1 Then
	  DebugWrite("Can't dump cups, no available barbarians.")

	  ; Click End Battle button
	  RandomWeightedClick($rLiveRaidScreenEndBattleButton)
	  Sleep(500)

	  Return False
   EndIf

   ; Deploy from top or bottom?
   Local $direction = (Random()>0.5) ? "Top" : "Bot"
   If $direction = "Bot" Then
	  DragScreenUp()
   Else
	  DragScreenDown()
   EndIf

   If _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups)=$BST_UNCHECKED Then Return False


   ; Deploy one barb
   Local $barbButton[4] = [$troopIndex[$eTroopBarbarian][0], $troopIndex[$eTroopBarbarian][1], _
						   $troopIndex[$eTroopBarbarian][2], $troopIndex[$eTroopBarbarian][3]]
   RandomWeightedClick($barbButton)
   Sleep(500)
   DeployTroopsToSides($eTroopBarbarian, $troopIndex, $eAutoRaidDeployOneTroop, $direction, $gMaxDeployBoxes)
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
	  DebugWrite("Error getting end battle confirmation button.")
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
	  DebugWrite("Error getting end battle screen.")
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
	  DebugWrite("Error waiting for main screen.")
	  Return False
   EndIf

   Return True
EndFunc
