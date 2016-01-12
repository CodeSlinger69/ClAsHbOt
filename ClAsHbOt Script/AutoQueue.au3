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
   Local $builtTroopCounts[$eTroopCount]
   For $i = $eTroopBarbarian To $eTroopWarden
	  $builtTroopCounts[$i] = 0
   Next

   GetBuiltTroops($gArmyCampTroopsBMPs, $builtTroopCounts)

   ; Check if we are waiting for heroes
   Local $heroWait = _GUICtrlComboBox_GetCurSel($GUI_AutoRaidWaitForHeroesCombo)
   Local $heroCount = $builtTroopCounts[$eTroopKing] + $builtTroopCounts[$eTroopQueen] + $builtTroopCounts[$eTroopWarden]
   If $heroWait>0 And $heroCount>=$heroWait Then DebugWrite("Heroes ready.")

   ; Fill
   Local $armyCampsFull = False

   If _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox) = $BST_CHECKED Then
	  FillBarracksStrategy0($initialFill, $builtTroopCounts, $armyCampsFull)
   Else
	  Switch _GUICtrlComboBox_GetCurSel($GUI_AutoRaidStrategyCombo)
	  Case 0
		 FillBarracksStrategy0($initialFill, $builtTroopCounts, $armyCampsFull)
	  Case 1
		 FillBarracksStrategy1($initialFill, $builtTroopCounts, $armyCampsFull)
	  Case 2
		 FillBarracksStrategy2($initialFill, $builtTroopCounts, $armyCampsFull)
	  Case 3
		 FillBarracksStrategy3($initialFill, $builtTroopCounts, $armyCampsFull)
	  EndSwitch
   EndIf

   If $armyCampsFull Then DebugWrite("Army Camps full.")

   ; Close army manager window
   CloseArmyManagerWindow()

   ; Set next stage
   If $armyCampsFull And _
	  ($heroWait=0 Or $heroCount>=$heroWait) Then
		 $gAutoStage = $eAutoFindMatch
		 GUICtrlSetData($GUI_AutoStatus, "Auto: Find Match")

   Else
	  If $initialFill Then
		 $gAutoStage = $eAutoWaitForTrainingToComplete
		 GUICtrlSetData($GUI_AutoStatus, "Auto: Waiting For Training (0:00)")
	  EndIf

   EndIf
EndFunc

Func GetBuiltTroops(Const ByRef $bitmaps, ByRef $index)

   ; Normal troops
   GrabFrameToFile("BuiltTroopsFrame1.bmp", $rCampTroopBox1[0], $rCampTroopBox1[1], $rCampTroopBox1[2], $rCampTroopBox1[3])

   For $i = $eTroopBarbarian To $eTroopLavaHound
	  Local $res = DllCall("ImageMatch.dll", "str", "FindMatch", "str", "BuiltTroopsFrame1.bmp", "str", "Images\"&$bitmaps[$i], "int", 3)
	  Local $split = StringSplit($res[0], "|", 2) ; x, y, conf

	  If $split[2] > $gConfidenceCampTroopSlot Then
		 Local $textBox[10] = [ _
			$split[0]+$rCampTroopBox1[0]+$rCampSlotTroopCountTextBox[0], _
			$split[1]+$rCampTroopBox1[1]+$rCampSlotTroopCountTextBox[1], _
			$split[0]+$rCampTroopBox1[0]+$rCampSlotTroopCountTextBox[2], _
			$split[1]+$rCampTroopBox1[1]+$rCampSlotTroopCountTextBox[3], _
			$rCampSlotTroopCountTextBox[4], _
			$rCampSlotTroopCountTextBox[5], _
			$rCampSlotTroopCountTextBox[6], _
			$rCampSlotTroopCountTextBox[7], _
			$rCampSlotTroopCountTextBox[8], _
			$rCampSlotTroopCountTextBox[9] ]

		 ;DebugWrite("box: " & $textBox[0] & " " & $textBox[1] & " " & $textBox[2] & " " & $textBox[3])

		 Local $t = ScrapeFuzzyText($gBarracksCharacterMaps, $textBox, $gBarracksCharMapsMaxWidth, $eScrapeDropSpaces)
		 ;DebugWrite("text: " & $gTroopNames[$i] & " " & $t)

		 $index[$i] = Number(StringMid($t, 2))
		 DebugWrite("GetBuiltTroops() " & $gTroopNames[$i] & " " & $index[$i])
	  EndIf
   Next

   ; Heroes
   GrabFrameToFile("BuiltTroopsFrame2.bmp", $rCampTroopBox2[0], $rCampTroopBox2[1], $rCampTroopBox2[2], $rCampTroopBox2[3])

   For $i = $eTroopKing To $eTroopWarden
	  Local $res = DllCall("ImageMatch.dll", "str", "FindMatch", "str", "BuiltTroopsFrame2.bmp", "str", "Images\"&$bitmaps[$i], "int", 3)
	  Local $split = StringSplit($res[0], "|", 2) ; x, y, conf

	  If $split[2] > $gConfidenceCampTroopSlot Then
		 $index[$i] = 1
		 DebugWrite("GetBuiltTroops() " & $gTroopNames[$i] & " " & $index[$i])
	  EndIf
   Next

EndFunc
