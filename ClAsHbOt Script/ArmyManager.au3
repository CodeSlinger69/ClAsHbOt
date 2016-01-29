Func AutoQueueTroops(ByRef $f, Const ByRef $initialFill)
   DebugWrite("AutoQueueTroops()")

   If ResetToCoCMainScreen($f) = False Then
	  DebugWrite("AutoQueueTroops() Not on main screen, exiting")
	  Return
   EndIf

   ; Open Army Manager window
   If OpenArmyManagerWindow($f) = False Then
	  DebugWrite("AutoQueueTroops(): Not on army manager screen, resetting")
	  ResetToCoCMainScreen($f)
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
	  FillBarracksStrategy0($f, $initialFill, $builtTroopCounts, $armyCampsFull)
   Else
	  Switch _GUICtrlComboBox_GetCurSel($GUI_AutoRaidStrategyCombo)
	  Case 0
		 FillBarracksStrategy0($f, $initialFill, $builtTroopCounts, $armyCampsFull)
	  Case 1
		 FillBarracksStrategy1($f, $initialFill, $builtTroopCounts, $armyCampsFull)
	  Case 2
		 FillBarracksStrategy2($f, $initialFill, $builtTroopCounts, $armyCampsFull)
	  Case 3
		 FillBarracksStrategy3($f, $initialFill, $builtTroopCounts, $armyCampsFull)
	  EndSwitch
   EndIf

   If $armyCampsFull Then DebugWrite("Army Camps full.")

   ; Close army manager window
   CloseArmyManagerWindow($f)

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
   Local $frame = CaptureFrame("GetBuiltTroops1", $rCampTroopBox1[0], $rCampTroopBox1[1], $rCampTroopBox1[2], $rCampTroopBox1[3])
   If $gDebugSaveScreenCaptures Then SaveDebugImage($frame, "BuiltTroopsFrame1.bmp")

   For $i = $eTroopBarbarian To $eTroopLavaHound
	  Local $conf, $x, $y
	  ScanFrameForOneBMP($frame, "Images\"&$bitmaps[$i], $conf, $x, $y)

	  If $conf > $gConfidenceCampTroopSlot Then
		 Local $textBox[10] = [ _
			$x+$rCampSlotTroopCountTextBox[0], _
			$y+$rCampSlotTroopCountTextBox[1], _
			$x+$rCampSlotTroopCountTextBox[2], _
			$y+$rCampSlotTroopCountTextBox[3], _
			$rCampSlotTroopCountTextBox[4], _
			$rCampSlotTroopCountTextBox[5], _
			$rCampSlotTroopCountTextBox[6], _
			$rCampSlotTroopCountTextBox[7], _
			$rCampSlotTroopCountTextBox[8], _
			$rCampSlotTroopCountTextBox[9] ]

		 ;DebugWrite("box: " & $textBox[0] & " " & $textBox[1] & " " & $textBox[2] & " " & $textBox[3])

		 Local $t = ScrapeFuzzyText($frame, $gBarracksCharacterMaps, $textBox, $gBarracksCharMapsMaxWidth, $eScrapeDropSpaces)
		 ;DebugWrite("text: " & $gTroopNames[$i] & " " & $t)

		 $index[$i] = Number(StringMid($t, 2))
		 DebugWrite("GetBuiltTroops() " & $gTroopNames[$i] & " " & $index[$i])
	  EndIf
   Next

   _GDIPlus_BitmapDispose($frame)


   $frame = CaptureFrame("GetBuiltTroops2", $rCampTroopBox2[0], $rCampTroopBox2[1], $rCampTroopBox2[2], $rCampTroopBox2[3])
   If $gDebugSaveScreenCaptures Then SaveDebugImage($frame, "BuiltTroopsFrame2.bmp")

   For $i = $eTroopKing To $eTroopWarden
	  Local $conf, $x, $y
	  ScanFrameForOneBMP($frame, "Images\"&$bitmaps[$i], $conf, $x, $y)

	  If $conf > $gConfidenceCampTroopSlot Then
		 $index[$i] = 1
		 DebugWrite("GetBuiltTroops() " & $gTroopNames[$i] & " " & $index[$i])
	  EndIf
   Next

   _GDIPlus_BitmapDispose($frame)

EndFunc

Func OpenArmyManagerWindow(ByRef $f)
   DebugWrite("OpenArmyManagerWindow()")

   ; Click the Army Manager button
   RandomWeightedClick($rArmyManagerButton)
   Sleep(250)

   ; Wait for Army Manager window to appear
   If WaitForScreen($f, 5000, $eWindowArmyManager) = False Then
	  DebugWrite("OpenArmyManagerWindow() Failed - timeout opening Army Manager Window")
	  Return False
   EndIf

   Return True
EndFunc

Func CloseArmyManagerWindow(ByRef $f)
   DebugWrite("CloseArmyManagerWindow()")
   RandomWeightedClick($rArmyManagerWindowCloseButton)
   Sleep(500)

   ; Wait for main screen to appear
   If WaitForScreen($f, 5000, $eScreenMain) = False Then
	  DebugWrite("CloseArmyManagerWindow() Failed - timeout waiting for min screen")
	  Return False
   EndIf

   Return True
EndFunc

; Returns true if next standard barracks was selected, false otherwise
Func OpenNextAvailableStandardBarracks(ByRef $f)
   ; First see which one is open
   Local $c1[4] = [$rArmyManagerWindowStandard1Button[4], $rArmyManagerWindowStandard1Button[5], $rArmyManagerSelectedColor[2]]
   Local $c2[4] = [$rArmyManagerWindowStandard2Button[4], $rArmyManagerWindowStandard2Button[5], $rArmyManagerSelectedColor[2]]
   Local $c3[4] = [$rArmyManagerWindowStandard3Button[4], $rArmyManagerWindowStandard3Button[5], $rArmyManagerSelectedColor[2]]
   Local $c4[4] = [$rArmyManagerWindowStandard4Button[4], $rArmyManagerWindowStandard4Button[5], $rArmyManagerSelectedColor[2]]

   Local $selectedBarracks = 0
   If IsColorPresent($f, $c1) Then
	  $selectedBarracks = 1
   ElseIf IsColorPresent($f, $c2) Then
	  $selectedBarracks = 2
   ElseIf IsColorPresent($f, $c3) Then
	  $selectedBarracks = 3
   ElseIf IsColorPresent($f, $c4) Then
	  $selectedBarracks = 4
   EndIf
   ;DebugWrite("Current standard barracks selection: " & $selectedBarracks)

   ; If the last standard barracks was selected, then return false, as there are no others remaining
   If $selectedBarracks = 4 Then Return False

   ; Scan for the next available standard barracks, and click it
   For $i = $selectedBarracks+1 To 4
	  If $i = 1 Then
		 If IsButtonPresent($f, $rArmyManagerWindowStandard1Button) Then
			RandomWeightedClick($rArmyManagerWindowStandard1Button)
			Sleep(500)
			_GDIPlus_BitmapDispose($f)
			$f = CaptureFrame("OpenNextAvailableStandardBarracks")
			Return True
		 EndIf
	  ElseIf $i = 2 Then
		 If IsButtonPresent($f, $rArmyManagerWindowStandard2Button) Then
			RandomWeightedClick($rArmyManagerWindowStandard2Button)
			Sleep(500)
			_GDIPlus_BitmapDispose($f)
			$f = CaptureFrame("OpenNextAvailableStandardBarracks")
			Return True
		 EndIf
	  ElseIf $i = 3 Then
		 If IsButtonPresent($f, $rArmyManagerWindowStandard3Button) Then
			RandomWeightedClick($rArmyManagerWindowStandard3Button)
			Sleep(500)
			_GDIPlus_BitmapDispose($f)
			$f = CaptureFrame("OpenNextAvailableStandardBarracks")
			Return True
		 EndIf
	  ElseIf $i = 4 Then
		 If IsButtonPresent($f, $rArmyManagerWindowStandard4Button) Then
			RandomWeightedClick($rArmyManagerWindowStandard4Button)
			Sleep(500)
			_GDIPlus_BitmapDispose($f)
			$f = CaptureFrame("OpenNextAvailableStandardBarracks")
			Return True
		 EndIf
	  EndIf
   Next

   ; If there are no more available standard barracks, then return false
   Return False
EndFunc

; Returns true if next dark barracks was selected, false otherwise
Func OpenNextAvailableDarkBarracks(ByRef $f)
   ; First see which one is open
   Local $c1[4] = [$rArmyManagerWindowDark1Button[4], $rArmyManagerWindowDark1Button[5], $rArmyManagerSelectedColor[2]]
   Local $c2[4] = [$rArmyManagerWindowDark2Button[4], $rArmyManagerWindowDark2Button[5], $rArmyManagerSelectedColor[2]]

   Local $selectedBarracks = 0
   If IsColorPresent($f, $c1) Then
	  $selectedBarracks = 1
   ElseIf IsColorPresent($f, $c2) Then
	  $selectedBarracks = 2
   EndIf
   ;DebugWrite("Current dark barracks selection: " & $selectedBarracks)

   ; If the last dark barracks was selected, then return false, as there are no others remaining
   If $selectedBarracks = 2 Then Return False

   ; Scan for the next available dark barracks, and click it
   For $i = $selectedBarracks+1 To 2
	  If $i = 1 Then
		 If IsButtonPresent($f, $rArmyManagerWindowDark1Button) Then
			RandomWeightedClick($rArmyManagerWindowDark1Button)
			Sleep(500)
			_GDIPlus_BitmapDispose($f)
			$f = CaptureFrame("OpenNextAvailableDarkBarracks")
			Return True
		 EndIf
	  ElseIf $i = 2 Then
		 If IsButtonPresent($f, $rArmyManagerWindowDark2Button) Then
			RandomWeightedClick($rArmyManagerWindowDark2Button)
			Sleep(500)
			_GDIPlus_BitmapDispose($f)
			$f = CaptureFrame("OpenNextAvailableDarkBarracks")
			Return True
		 EndIf
	  EndIf
   Next

   ; If there are no more available dark barracks, then return false
   Return False
EndFunc

Func FindBarracksTroopSlots(Const ByRef $bitmaps, ByRef $index)
   ; Populates index with the client area coords of all available troop buttons

   Local $frame = CaptureFrame("GetTownHallLevel", $rBarracksTroopBox[0], $rBarracksTroopBox[1], $rBarracksTroopBox[2], $rBarracksTroopBox[3])
   _GDIPlus_ImageSaveToFile($frame, "temp.bmp")   ; temporary
   _GDIPlus_BitmapDispose($frame)

   If $gDebugSaveScreenCaptures Then SaveDebugImage($frame, "BarracksFrame.bmp")

   For $i = 0 To UBound($bitmaps)-1
	  Local $conf, $x, $y
	  ScanFrameForOneBMP($frame, "Images\"&$bitmaps[$i], $conf, $x, $y)

	  If $conf > $gConfidenceBarracksTroopSlot Then
		 $index[$i][0] = $rBarracksTroopBox[0] + $x + $rBarracksButtonOffset[0]
		 $index[$i][1] = $rBarracksTroopBox[1] + $y + $rBarracksButtonOffset[1]
		 $index[$i][2] = $rBarracksTroopBox[0] + $x + $rBarracksButtonOffset[2]
		 $index[$i][3] = $rBarracksTroopBox[1] + $y + $rBarracksButtonOffset[3]
	  Else
		 $index[$i][0] = -1
		 $index[$i][1] = -1
		 $index[$i][2] = -1
		 $index[$i][3] = -1
	  EndIf
   Next
EndFunc

Func DequeueTroops(ByRef $f)
   Local $dequeueTries = 6

   While IsButtonPresent($f, $rTrainTroopsWindowDequeueButton) And $dequeueTries>0 And _
		 (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_CHECKED Or _
		  _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox)=$BST_CHECKED)

	  DebugWrite("Dequeueing troops.")
	  Local $xClick, $yClick
	  RandomWeightedCoords($rTrainTroopsWindowDequeueButton, $xClick, $yClick)
	  _ClickHold($xClick, $yClick, 4000)
	  $dequeueTries-=1
	  Sleep(500)

	  _GDIPlus_BitmapDispose($f)
	  $f = CaptureFrame("DequeueTroops")
   WEnd
EndFunc

Func QueueTroopsEvenly(Const $troop, Const ByRef $troopSlots, Const $troopsToQueue)

   If $troopSlots[$eTroopWallBreaker][0] <> -1 Then
	  Local $button[4] = [$troopSlots[$troop][0], $troopSlots[$troop][1], $troopSlots[$troop][2], $troopSlots[$troop][3]]

	  If $troopsToQueue/4 < 1 Then
		 DebugWrite("Queueing 1 " & $gTroopNames[$troop])
		 RandomWeightedClick($button)
		 Sleep(150)
	  Else
		 DebugWrite("Queueing " & Int($troopsToQueue/4) & " " & $gTroopNames[$troop])
		 For $i = 1 To Int($troopsToQueue/4)
			RandomWeightedClick($button)
			Sleep(150)
		 Next
	  EndIf
   EndIf
EndFunc

Func FillBarracksWithTroops(Const $frame, Const $troop, Const ByRef $troopSlots)
   Local $troopsToFill = 999

   ; Get number of troops already queued in this barracks
   Local $queueStatus = ScrapeFuzzyText($frame, $gBarracksCharacterMaps, $rBarracksWindowTextBox, $gBarracksCharMapsMaxWidth, $eScrapeDropSpaces)
   ;DebugWrite("Barracks queue status: " & $queueStatus)

   Local $stringLoc = StringInStr($queueStatus, "troops")
   If ($stringLoc <> 0) Then
	  $queueStatus = StringMid($queueStatus, $stringLoc+6)
	  ;DebugWrite("Barracks queue status separated: " & $queueStatus)

	  Local $queueStatSplit = StringSplit($queueStatus, "/")
	  ;DebugWrite("Barracks queue status split: " & $queueStatSplit[1] & " " & $queueStatSplit[2])

	  If $queueStatSplit[0] = 2 Then
		 $troopsToFill = Number($queueStatSplit[2]) - Number($queueStatSplit[1])

		 ; How long to click and hold?
		 Local $fillTime
		 If $troopsToFill>60 Then
			$fillTime = 3500 + Random(-250, 250, 1)
		 ElseIf $troopsToFill>25 Then
			$fillTime = 2700 + Random(-250, 250, 1)
		 ElseIf $troopsToFill>10 Then
			$fillTime = 2300 + Random(-250, 250, 1)
		 Else
			$fillTime = 1800 + Random(-250, 250, 1)
		 EndIf

		 ; Click and hold to fill up queue
		 If $troopsToFill>0 Then
			DebugWrite("FillBarracksWithTroops(), Adding " & $troopsToFill & " " & $gTroopNames[$troop])
			Local $button[4] = [$troopSlots[$troop][0], $troopSlots[$troop][1], $troopSlots[$troop][2], $troopSlots[$troop][3]]

			Local $xClick, $yClick
			RandomWeightedCoords($button, $xClick, $yClick)

			_ClickHold($xClick, $yClick, $fillTime)
			Sleep(500)
		 EndIf
	  EndIf
   EndIf

   Return $troopsToFill
EndFunc
