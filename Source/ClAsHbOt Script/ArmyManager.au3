Func AutoQueueTroops(Const ByRef $initialFill, ByRef $buildTimeRemaining)
   DebugWrite("AutoQueueTroops()")

   Local $hHBITMAP = CaptureFrameHBITMAP("AutoQueueTroops")

   If WhereAmI($hHBITMAP) <> $eScreenMain Then
	  DebugWrite("AutoQueueTroops() Not on main screen, exiting")
	  _WinAPI_DeleteObject($hHBITMAP)
	  Return
   EndIf

   ; Open Army Manager window
   If OpenArmyManagerWindow($hHBITMAP) = False Then
	  DebugWrite("AutoQueueTroops(): Not on army manager screen, resetting")
	  ResetToCoCMainScreen($hHBITMAP)
	  _WinAPI_DeleteObject($hHBITMAP)
	  Return
   EndIf

   ; Read status on Army Overview window
   Local $remainingToQueue = 999
   Local $armyOverviewStatus = ScrapeFuzzyText($hHBITMAP, $fontArmyOverviewStatus, $rArmyOverviewWindowTextBox)
   DebugWrite("AutoQueueTroops() Army Overview status: " & $armyOverviewStatus)

   Local $stringLoc = StringInStr($armyOverviewStatus, "Troops:")
   If ($stringLoc <> 0) Then
	  $armyOverviewStatus = StringMid($armyOverviewStatus, $stringLoc+7)
	  ;DebugWrite("Army Overview status separated: " & $queueStatus)

	  Local $armyOverviewStatSplit = StringSplit($armyOverviewStatus, "/")
	  ;DebugWrite("Army Overview status split: " & $queueStatSplit[1] & " " & $queueStatSplit[2])

	  If $armyOverviewStatSplit[0] = 2 Then
		 $remainingToQueue = Number($armyOverviewStatSplit[2]) - Number($armyOverviewStatSplit[1])
	  EndIf
   EndIf

   DebugWrite("AutoQueueTroops() Remaining to queue: " & $remainingToQueue)
   Local $armyCampsFull = ($remainingToQueue=0 ? True : False)
   If $armyCampsFull Then DebugWrite("Army Camps full.")

   ; Count how many troops are already built
   Local $builtTroopCounts[$eTroopCount][5]
   For $i = 0 To $eTroopCount-1
	  $builtTroopCounts[$i][0] = -1
	  $builtTroopCounts[$i][1] = -1
	  $builtTroopCounts[$i][2] = -1
	  $builtTroopCounts[$i][3] = -1
	  $builtTroopCounts[$i][4] = 0
   Next

   LocateSlots($eActionTypeCamp, $eSlotTypeTroop, $builtTroopCounts)
   LocateSlots($eActionTypeCamp, $eSlotTypeHero, $builtTroopCounts)
   UpdateArmyCampSlotCounts($builtTroopCounts)

   ; Get time remaining for troop build
   $buildTimeRemaining = 0

   If IsTextBoxPresent($hHBITMAP, $rArmyOverviewTroopTimeRemainingTextBox) = False Then
	  DebugWrite("AutoQueueTroops: TroopTimeRemaining text not present, wait time = 0")
   Else
	  Local $troopTimeRemainingStr = ScrapeFuzzyText($hHBITMAP, $fontArmyOverviewTimeRemaining, $rArmyOverviewTroopTimeRemainingTextBox)
	  DebugWrite("AutoQueueTroops: TroopTimeRemaining string scrape: " & $troopTimeRemainingStr)

	  If StringInStr($troopTimeRemainingStr, "s") Then
		 DebugWrite("AutoQueueTroops: TroopTimeRemaining < 1 minute left, wait time = 0")
	  Else
		 $buildTimeRemaining = Number($troopTimeRemainingStr) * 60 * 1000
		 $buildTimeRemaining += Random(60*1, 60*5, 1) * 1000 ; Add between 1 and 5 minutes of additional random wait time
		 DebugWrite("AutoQueueTroops: Will wait " & millisecondToMMSS($buildTimeRemaining) & " for troop build")
	  EndIf
   EndIf

   ; Check if we are waiting for heroes
   Local $heroWait = _GUICtrlComboBox_GetCurSel($GUI_AutoRaidWaitForHeroesCombo)
   Local $heroCount = $builtTroopCounts[$eTroopKing][4] + $builtTroopCounts[$eTroopQueen][4] + $builtTroopCounts[$eTroopWarden][4]
   If $heroWait>0 Then
	  If $heroCount>=$heroWait Then
		 DebugWrite("Heroes ready.")
	  Else
		 DebugWrite("Waiting for heroes, " & $heroCount & " of " & $heroWait & " are ready")

		 If $buildTimeRemaining = 0 Then
			$buildTimeRemaining = Random(60*3, 60*8, 1) * 1000 ; Between 3 and 8 random minutes
			DebugWrite("AutoQueueTroops: Will wait " & millisecondToMMSS($buildTimeRemaining) & " for hero regeneration")
		 EndIf
	  EndIf
   EndIf

   ; Fill
   Switch _GUICtrlComboBox_GetCurSel($GUI_AutoRaidStrategyCombo)
   Case 0
	  FillBarracksStrategy0($hHBITMAP, $initialFill, $builtTroopCounts)
   Case 1
	  FillBarracksStrategy1($hHBITMAP, $initialFill, $builtTroopCounts)
   Case 2
	  FillBarracksStrategy2($hHBITMAP, $initialFill, $builtTroopCounts)
   Case 3
	  FillBarracksStrategy3($hHBITMAP, $initialFill, $builtTroopCounts)
   Case 4
	  FillBarracksStrategy4($hHBITMAP, $initialFill, $builtTroopCounts)
   EndSwitch

   ; Close army manager window
   CloseArmyManagerWindow($hHBITMAP)

   ; Set next stage
   If $armyCampsFull And _
	  ($heroWait=0 Or $heroCount>=$heroWait) Then
		 $gAutoStage = $eAutoFindMatch
		 GUICtrlSetData($GUI_AutoStatus, "Auto: Find Match")

   Else
	  If $initialFill Then
		 $gAutoStage = $eAutoWaitForTrainingToComplete
	  EndIf
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Waiting For Troops " & millisecondToMMSS($buildTimeRemaining))

   EndIf

   _WinAPI_DeleteObject($hHBITMAP)
EndFunc

Func OpenArmyManagerWindow(ByRef $hBMP)
   DebugWrite("OpenArmyManagerWindow()")

   ; Click the Army Manager button
   RandomWeightedClick($rArmyManagerButton)
   Sleep(250)

   ; Wait for Army Manager window to appear
   If WaitForScreen($hBMP, 5000, $eWindowArmyManager) = False Then
	  DebugWrite("OpenArmyManagerWindow() Failed - timeout opening Army Manager Window")
	  Return False
   EndIf

   Return True
EndFunc

Func CloseArmyManagerWindow(ByRef $hBMP)
   DebugWrite("CloseArmyManagerWindow()")
   RandomWeightedClick($rArmyManagerWindowCloseButton)
   Sleep(500)

   ; Wait for main screen to appear
   If WaitForScreen($hBMP, 5000, $eScreenMain) = False Then
	  DebugWrite("CloseArmyManagerWindow() Failed - timeout waiting for main screen")
	  Return False
   EndIf

   Return True
EndFunc

Func UpdateArmyCampSlotCounts(ByRef $index)
   Local $hHBITMAP = CaptureFrameHBITMAP("UpdateArmyCampSlotCounts")

   For $i = 0 To $eTroopCount-1
	  If $index[$i][0] <> -1 Then

		 If $i=$eTroopKing Or $i=$eTroopQueen Or $i=$eTroopWarden Then
			$index[$i][4] = 1

		 Else
			; Troop is not "selected"
			Local $textBox[10] = [ _
			   $index[$i][0] + $rCampSlotTroopCountTextBox[0], _
			   $index[$i][1] + $rCampSlotTroopCountTextBox[1], _
			   $index[$i][2] + $rCampSlotTroopCountTextBox[2], _
			   $index[$i][1] + $rCampSlotTroopCountTextBox[3], _
			   $rCampSlotTroopCountTextBox[4], $rCampSlotTroopCountTextBox[5], 0, 0, 0, 0]
			;DebugWrite("Text box: " & $textBox[0] & " " & $textBox[1] & " " & $textBox[2] & " " & $textBox[3] & " " & $textBox[4] & " " & _
			 ;  Hex($textBox[5]) & " " & $textBox[6] & " " & $textBox[7] & " " & $textBox[8] & " " & $textBox[9] )

			Local $t = ScrapeFuzzyText($hHBITMAP, $fontBarracksStatus, $textBox)
			;DebugWrite("UpdateArmyCampSlotCounts() = " & $t)

			$index[$i][4] = Number(StringMid($t, 2))

		 EndIf
	  EndIf
   Next

   _WinAPI_DeleteObject($hHBITMAP)
EndFunc

; Returns true if next standard barracks was selected, false otherwise
Func OpenNextAvailableStandardBarracks(ByRef $hBMP)
   ; First see which one is open
   Local $c1[4] = [$rArmyManagerWindowStandard1Button[4], $rArmyManagerWindowStandard1Button[5], $rArmyManagerSelectedColor[2]]
   Local $c2[4] = [$rArmyManagerWindowStandard2Button[4], $rArmyManagerWindowStandard2Button[5], $rArmyManagerSelectedColor[2]]
   Local $c3[4] = [$rArmyManagerWindowStandard3Button[4], $rArmyManagerWindowStandard3Button[5], $rArmyManagerSelectedColor[2]]
   Local $c4[4] = [$rArmyManagerWindowStandard4Button[4], $rArmyManagerWindowStandard4Button[5], $rArmyManagerSelectedColor[2]]

   Local $selectedBarracks = 0
   If IsColorPresent($hBMP, $c1) Then
	  $selectedBarracks = 1
   ElseIf IsColorPresent($hBMP, $c2) Then
	  $selectedBarracks = 2
   ElseIf IsColorPresent($hBMP, $c3) Then
	  $selectedBarracks = 3
   ElseIf IsColorPresent($hBMP, $c4) Then
	  $selectedBarracks = 4
   EndIf
   ;DebugWrite("Current standard barracks selection: " & $selectedBarracks)

   ; If the last standard barracks was selected, then return false, as there are no others remaining
   If $selectedBarracks = 4 Then Return False

   ; Scan for the next available standard barracks, and click it
   For $i = $selectedBarracks+1 To 4
	  If $i = 1 Then
		 If IsButtonPresent($hBMP, $rArmyManagerWindowStandard1Button) Then
			RandomWeightedClick($rArmyManagerWindowStandard1Button)
			Sleep(500)
			_WinAPI_DeleteObject($hBMP)
			$hBMP = CaptureFrameHBITMAP("OpenNextAvailableStandardBarracks")
			Return True
		 EndIf
	  ElseIf $i = 2 Then
		 If IsButtonPresent($hBMP, $rArmyManagerWindowStandard2Button) Then
			RandomWeightedClick($rArmyManagerWindowStandard2Button)
			Sleep(500)
			_WinAPI_DeleteObject($hBMP)
			$hBMP = CaptureFrameHBITMAP("OpenNextAvailableStandardBarracks")
			Return True
		 EndIf
	  ElseIf $i = 3 Then
		 If IsButtonPresent($hBMP, $rArmyManagerWindowStandard3Button) Then
			RandomWeightedClick($rArmyManagerWindowStandard3Button)
			Sleep(500)
			_WinAPI_DeleteObject($hBMP)
			$hBMP = CaptureFrameHBITMAP("OpenNextAvailableStandardBarracks")
			Return True
		 EndIf
	  ElseIf $i = 4 Then
		 If IsButtonPresent($hBMP, $rArmyManagerWindowStandard4Button) Then
			RandomWeightedClick($rArmyManagerWindowStandard4Button)
			Sleep(500)
			_WinAPI_DeleteObject($hBMP)
			$hBMP = CaptureFrameHBITMAP("OpenNextAvailableStandardBarracks")
			Return True
		 EndIf
	  EndIf
   Next

   Return False
EndFunc

; Returns true if next dark barracks was selected, false otherwise
Func OpenNextAvailableDarkBarracks(ByRef $hBMP)
   ; First see which one is open
   Local $c1[4] = [$rArmyManagerWindowDark1Button[4], $rArmyManagerWindowDark1Button[5], $rArmyManagerSelectedColor[2]]
   Local $c2[4] = [$rArmyManagerWindowDark2Button[4], $rArmyManagerWindowDark2Button[5], $rArmyManagerSelectedColor[2]]

   Local $selectedBarracks = 0
   If IsColorPresent($hBMP, $c1) Then
	  $selectedBarracks = 1
   ElseIf IsColorPresent($hBMP, $c2) Then
	  $selectedBarracks = 2
   EndIf
   ;DebugWrite("Current dark barracks selection: " & $selectedBarracks)

   ; If the last dark barracks was selected, then return false, as there are no others remaining
   If $selectedBarracks = 2 Then Return False

   ; Scan for the next available dark barracks, and click it
   For $i = $selectedBarracks+1 To 2
	  If $i = 1 Then
		 If IsButtonPresent($hBMP, $rArmyManagerWindowDark1Button) Then
			RandomWeightedClick($rArmyManagerWindowDark1Button)
			Sleep(500)
			_WinAPI_DeleteObject($hBMP)
			$hBMP = CaptureFrameHBITMAP("OpenNextAvailableDarkBarracks")
			Return True
		 EndIf
	  ElseIf $i = 2 Then
		 If IsButtonPresent($hBMP, $rArmyManagerWindowDark2Button) Then
			RandomWeightedClick($rArmyManagerWindowDark2Button)
			Sleep(500)
			_WinAPI_DeleteObject($hBMP)
			$hBMP = CaptureFrameHBITMAP("OpenNextAvailableDarkBarracks")
			Return True
		 EndIf
	  EndIf
   Next

   Return False
EndFunc

Func DequeueTroops(ByRef $hBMP)
   Local $dequeueTries = 6
   While IsButtonPresent($hBMP, $rTrainTroopsWindowDequeueButton) And $dequeueTries>0 And _
		 _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_CHECKED

	  DebugWrite("Dequeueing troops.")
	  Local $xClick, $yClick
	  RandomWeightedCoords($rTrainTroopsWindowDequeueButton, $xClick, $yClick)
	  _ClickHold($xClick, $yClick, 4000)
	  $dequeueTries-=1
	  Sleep(500)

	  _WinAPI_DeleteObject($hBMP)
	  $hBMP = CaptureFrameHBITMAP("DequeueTroops")
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

Func FillBarracksWithTroops(Const $hBMP, Const $troop, Const ByRef $troopSlots)
   Local $spaceToFill = 999

   ; Get number of troops already queued in this barracks
   Local $queueStatus = ScrapeFuzzyText($hBMP, $fontBarracksStatus, $rBarracksWindowTextBox)
   DebugWrite("FillBarracksWithTroops() Barracks queue status: " & $queueStatus)

   Local $stringLoc = StringInStr($queueStatus, "troops")
   If ($stringLoc <> 0) Then
	  $queueStatus = StringMid($queueStatus, $stringLoc+6)
	  ;DebugWrite("Barracks queue status separated: " & $queueStatus)

	  Local $queueStatSplit = StringSplit($queueStatus, "/")
	  ;DebugWrite("Barracks queue status split: " & $queueStatSplit[1] & " " & $queueStatSplit[2])

	  If $queueStatSplit[0] = 2 Then
		 $spaceToFill = Number($queueStatSplit[2]) - Number($queueStatSplit[1])

		 ; How long to click and hold?
		 Local $fillTime
		 If $spaceToFill/$gTroopSpace[$troop] > 60 Then
			$fillTime = 3500 + Random(-250, 250, 1)
		 ElseIf $spaceToFill/$gTroopSpace[$troop] > 25 Then
			$fillTime = 2700 + Random(-250, 250, 1)
		 ElseIf $spaceToFill/$gTroopSpace[$troop] > 10 Then
			$fillTime = 2300 + Random(-250, 250, 1)
		 Else
			$fillTime = 1800 + Random(-250, 250, 1)
		 EndIf

		 ; Click and hold to fill up queue
		 If $spaceToFill >= $gTroopSpace[$troop] Then
			DebugWrite("FillBarracksWithTroops() Adding " & Int($spaceToFill/$gTroopSpace[$troop]) & " " & $gTroopNames[$troop])
			Local $button[4] = [$troopSlots[$troop][0], $troopSlots[$troop][1], $troopSlots[$troop][2], $troopSlots[$troop][3]]

			Local $xClick, $yClick
			RandomWeightedCoords($button, $xClick, $yClick)

			_ClickHold($xClick, $yClick, $fillTime)
			Sleep(500)
		 EndIf
	  EndIf
   EndIf

   Return $spaceToFill >= $gTroopSpace[$troop] ? $spaceToFill : 0
EndFunc
