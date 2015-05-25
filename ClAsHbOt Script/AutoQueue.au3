Func AutoQueueTroops()
   DebugWrite("AutoQueueTroops()")

   If WhereAmI() <> $eScreenMain Then
	  ResetToCoCMainScreen()
	  Return
   EndIf

   OpenBarracksWindow()

   ; See if we have a red stripe on the bottom of the train troops window, and move to next stage
   Local $redStripe = IsColorPresent($rWindowBarracksFullColor)
   If $redStripe Then DebugWrite("Barracks full.")

   ; Get spells window
   If FindSpellsQueueingWindow() = False Then
	 DebugWrite(" Auto: Queue Troops failed - can't find Spells or Dark window.")
	 ResetToCoCMainScreen()
	 Return
   EndIf

   ; Queue spells?
   QueueSpells()

   ; Fill
   Switch _GUICtrlComboBox_GetCurSel($GUI_AutoRaidStrategyCombo)
   Case 0
	  FillBarracks(True)
   Case 1
	  ContinueCase
   Case 2
	  ContinueCase
   Case 3
	  ContinueCase
   EndSwitch

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

   OpenBarracksWindow()

   If WhereAmI() <> $eScreenTrainTroops Then
	  ResetToCoCMainScreen()
	  Return
   EndIf

   ; See if we have a red stripe on the bottom of the train troops window, which means we are full up
   If IsColorPresent($rWindowBarracksFullColor) Then
	  ;DebugWrite("Troop training is complete!")
	  $gAutoStage = $eAutoFindMatch
  	  GUICtrlSetData($GUI_AutoStatus, "Auto: Find Match")

   Else
	  ; Top off the barracks queues
	  If FindSpellsQueueingWindow() = False Then
		DebugWrite(" Auto: Queue Troops failed - can't find Spells or Dark window")
		ResetToCoCMainScreen()
		Return
	  EndIf

	  ; Queue spells?
	  QueueSpells()

	  ; Fill type
	  Switch _GUICtrlComboBox_GetCurSel($GUI_AutoRaidStrategyCombo)
	  Case 0
		 FillBarracks(False)
	  Case 1
		 ContinueCase
	  Case 2
		 ContinueCase
	  Case 3
		 ContinueCase
	  EndSwitch
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
