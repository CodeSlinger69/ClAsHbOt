Func AutoQueueTroops()
   DebugWrite("AutoQueueTroops()")

   If WhereAmI() <> $eScreenMain Then
	  DebugWrite("AutoQueueTroops(): Not on main screen, resetting.")
	  ResetToCoCMainScreen()
	  Return
   EndIf

   ; Count how many troops are in the Army Camps
   Local $availableTroopCounts[$eTroopCount-2]
   If OpenArmyCampWindow() = False Then
	  DebugWrite("AutoQueueTroops(): Unable to locate Army Camp.")
	  Return
   EndIf

   GetArmyCampTroopCounts($availableTroopCounts)

   CloseArmyCampWindow()

   ; Open barracks window
   OpenBarracksWindow()

   If WhereAmI() <> $eScreenTrainTroops Then
	  DebugWrite("AutoQueueTroops(): Not on train troops screen, resetting.")
	  ResetToCoCMainScreen()
	  Return
   EndIf

   ; Get spells window
   If FindSpellsQueueingWindow() = False Then
	 DebugWrite("AutoQueueTroops(): Queue Troops failed - can't find Spells or Dark window.")
	 ResetToCoCMainScreen()
	 Return
   EndIf

   ; Queue spells?
   QueueSpells()

   ; Fill
   Local $redStripe = False

   If _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox) = $BST_CHECKED Then
	  FillBarracksStrategy0(True, $availableTroopCounts, $redStripe)
   Else
	  Switch _GUICtrlComboBox_GetCurSel($GUI_AutoRaidStrategyCombo)
	  Case 0
		 FillBarracksStrategy0(True, $availableTroopCounts, $redStripe)
	  Case 1
		 FillBarracksStrategy1(True, $availableTroopCounts, $redStripe)
	  Case 2
		 ContinueCase
	  Case 3
		 ContinueCase
	  EndSwitch
   EndIf

   If $redStripe Then DebugWrite("Barracks full.")

   ; Close barracks
   CloseBarracksWindow()

   ; Set next stage
   If $redStripe Then
	  $gAutoStage = $eAutoFindMatch
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Find Match")

   Else
	  $gAutoStage = $eAutoWaitForTrainingToComplete
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Waiting For Training (0:00)")

   EndIf
EndFunc

Func AutoCheckIfTroopsReady()
   DebugWrite("AutoCheckIfTroopsReady()")

   If WhereAmI() <> $eScreenMain Then
	  DebugWrite("AutoCheckIfTroopsReady(): Not on main screen, resetting.")
	  ResetToCoCMainScreen()
	  Return
   EndIf

   ; Count how many troops are in the Army Camps
   Local $availableTroopCounts[$eTroopCount-2]
   If OpenArmyCampWindow() = False Then
	  DebugWrite("AutoCheckIfTroopsReady(): Unable to locate Army Camp.")
	  Return
   EndIf

   GetArmyCampTroopCounts($availableTroopCounts)

   CloseArmyCampWindow()

   ; Open barracks window
   OpenBarracksWindow()

   If WhereAmI() <> $eScreenTrainTroops Then
	  DebugWrite("AutoCheckIfTroopsReady(): Not on train troops screen, resetting.")
	  ResetToCoCMainScreen()
	  Return
   EndIf

   ; Top off the barracks queues
   If FindSpellsQueueingWindow() = False Then
	 DebugWrite("AutoCheckIfTroopsReady(): Queue Troops failed - can't find Spells or Dark window")
	 ResetToCoCMainScreen()
	 Return
   EndIf

   ; Queue spells?
   QueueSpells()

   ; Fill type
   Local $redStripe = False

   If _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox) = $BST_CHECKED Then
	  FillBarracksStrategy0(False, $availableTroopCounts, $redStripe)
   Else
	  Switch _GUICtrlComboBox_GetCurSel($GUI_AutoRaidStrategyCombo)
	  Case 0
		 FillBarracksStrategy0(False, $availableTroopCounts, $redStripe)
	  Case 1
		 FillBarracksStrategy1(False, $availableTroopCounts, $redStripe)
	  Case 2
		 ContinueCase
	  Case 3
		 ContinueCase
	  EndSwitch
   EndIf

   ; If there is a red stripe on the bottom of any of the train troops windows, then time to attack
   If $redStripe Then
	  ;DebugWrite("Troop training is complete!")
	  $gAutoStage = $eAutoFindMatch
  	  GUICtrlSetData($GUI_AutoStatus, "Auto: Find Match")
   EndIf

   ; Close barracks
   CloseBarracksWindow()
EndFunc

Func QueueSpells()
   ; If not spells queueing window, then return
   If IsColorPresent($rWindowBarracksSpellsColor1) <> True And IsColorPresent($rWindowBarracksSpellsColor2) <> True Then
	  Return
   EndIf

   ; maybe queue spells?
   If _GUICtrlButton_GetCheck($GUI_AutoRaidZapDE) = $BST_CHECKED Then

	  ; Get count
	  Local $spellSlots[$eSpellCount][4]
	  FindBarracksTroopSlots($gBarracksSpellSlotBMPs, $spellSlots)

	  ; How many are queued/created?
	  Local $queueStatus = ScrapeFuzzyText($gLargeCharacterMaps, $rBarracksWindowTextBox, $gLargeCharMapsMaxWidth, $eScrapeDropSpaces)
	  ;DebugWrite("$queueStatus: " & $queueStatus)

	  If (StringInStr($queueStatus, "CreateSpells")=1) Then
		 $queueStatus = StringMid($queueStatus, 13)

		 Local $queueStatSplit = StringSplit($queueStatus, "/")
		 If $queueStatSplit[0] = 2 Then
			Local $spellsToFill = Number($queueStatSplit[2]) - Number($queueStatSplit[1])
			DebugWrite("Spells queued: " & Number($queueStatSplit[1]) & " of " & Number($queueStatSplit[2]))

			$gMyMaxSpells = Number($queueStatSplit[2]) ; Used when deciding to DE Zap or not

			Local $lightningButton[4] = [$spellSlots[$eSpellLightning][0], $spellSlots[$eSpellLightning][1], _
									     $spellSlots[$eSpellLightning][2], $spellSlots[$eSpellLightning][3]]
			For $i = 1 To $spellsToFill
			   RandomWeightedClick($lightningButton)
			   Sleep($gDeployTroopClickDelay)
			Next
		 EndIf
	  EndIf
   EndIf
EndFunc
