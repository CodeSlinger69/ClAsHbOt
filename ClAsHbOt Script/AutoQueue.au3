Func AutoQueueTroops(Const ByRef $initialFill)
   DebugWrite("AutoQueueTroops()")

   If WhereAmI() <> $eScreenMain Then
	  DebugWrite("AutoQueueTroops(): Not on main screen, resetting.")
	  ResetToCoCMainScreen()
	  Return
   EndIf

   ; Open Army Manager window
   If OpenArmyManagerWindow() = False Then
	  DebugWrite("AutoQueueTroops(): Not on army manager screen, resetting.")
	  ResetToCoCMainScreen()
	  Return
   EndIf

   ; Count how many troops are already built
   ; TODO: capture images, etc for this
   Local $availableTroopCounts[$eTroopCount-2]
   For $i = $eTroopBarbarian To $eTroopLavaHound
	  $availableTroopCounts[$i] = 0
   Next

   ; Fill
   Local $armyCampsFull = False

   If _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox) = $BST_CHECKED Then
	  FillBarracksStrategy0($initialFill, $availableTroopCounts, $armyCampsFull)
   Else
	  Switch _GUICtrlComboBox_GetCurSel($GUI_AutoRaidStrategyCombo)
	  Case 0
		 FillBarracksStrategy0($initialFill, $availableTroopCounts, $armyCampsFull)
	  Case 1
		 FillBarracksStrategy1($initialFill, $availableTroopCounts, $armyCampsFull)
	  Case 2
		 FillBarracksStrategy2($initialFill, $availableTroopCounts, $armyCampsFull)
	  Case 3
		 FillBarracksStrategy3($initialFill, $availableTroopCounts, $armyCampsFull)
	  EndSwitch
   EndIf

   If $armyCampsFull Then DebugWrite("Army Camps full.")

   ; Close army manager window
   CloseArmyManagerWindow()

   ; Set next stage
   If $armyCampsFull Then
	  $gAutoStage = $eAutoFindMatch
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Find Match")

   Else
	  If $initialFill Then
		 $gAutoStage = $eAutoWaitForTrainingToComplete
		 GUICtrlSetData($GUI_AutoStatus, "Auto: Waiting For Training (0:00)")
	  EndIf

   EndIf
EndFunc
