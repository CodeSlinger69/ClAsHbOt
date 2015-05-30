Func OpenBarracksWindow()
   DebugWrite("OpenBarracksWindow()")

   ; Grab a frame
   GrabFrameToFile("BarracksFrame.bmp")

   ; Find all the barracks on the screen
   Local $barracksIndex = 0
   Local $barracksPoints[1][3]
   For $i = 0 To UBound($BarracksBMPs)-1
	  ; Get matches for this resource
	  Local $res = DllCall("ImageMatch.dll", "str", "FindAllMatches", "str", "BarracksFrame.bmp", _
			   "str", "Images\"&$BarracksBMPs[$i], "int", 3, "int", 6, "double", $gConfidenceBarracks)
	  Local $split = StringSplit($res[0], "|", 2)
	  Local $j
	  For $j = 0 To $split[0]-1
		 If $split[$j*3+3] > $gConfidenceBarracks Then
			$barracksIndex += 1
			ReDim $barracksPoints[$barracksIndex][3]
			$barracksPoints[$barracksIndex-1][0] = $split[$j*3+3] ; confidence
			$barracksPoints[$barracksIndex-1][1] = $split[$j*3+1] ; X
			$barracksPoints[$barracksIndex-1][2] = $split[$j*3+2] ; Y
		 EndIf
	  Next
   Next
   _ArraySort($barracksPoints, 1)

   ; Look through list of barracks for an available training screen, and get Train Troops button location
   Local $trainTroopsButtonX = -1, $trainTroopsButtonY = -1
   Local $barracksButtonBox[4] = [250, 454, 773, 521]

   For $i = 0 To $barracksIndex - 1
	  DebugWrite("Barracks " & $i & " found at " & $barracksPoints[$i][1] & "," & $barracksPoints[$i][2] & " confidence: " & $barracksPoints[$i][0])

	  ; Click on barracks
	  Local $button[4] = [$barracksPoints[$i][1]+$rBarracksButton[0], $barracksPoints[$i][2]+$rBarracksButton[1], _
						  $barracksPoints[$i][1]+$rBarracksButton[2], $barracksPoints[$i][2]+$rBarracksButton[3] ]
	  RandomWeightedClick($button, .5, 3, 0, $rBarracksButton[3]/2)
	  Sleep(200)

	  ; Wait for barracks button panel to show up (Train Troops button)
	  Local $failCount = 10 ; 2 seconds, should be instant

	  While $failCount > 0
		 ; Grab a frame
		 GrabFrameToFile("BarracksButtonBarFrame.bmp", $barracksButtonBox[0], $barracksButtonBox[1], $barracksButtonBox[2], $barracksButtonBox[3])
		 Local $bestMatch = 99, $bestConfidence = 0
		 ScanFrameForBestBMP("BarracksButtonBarFrame.bmp", $gTrainTroopsButtonBMPs, $gConfidenceTrainTroopsButton, _
						     $bestMatch, $bestConfidence, $trainTroopsButtonX, $trainTroopsButtonY)
		 DebugWrite("Train Troops button found at " & $trainTroopsButtonX & "," & $trainTroopsButtonY & " confidence: " & $bestConfidence)

		 If $bestConfidence >= $gConfidenceTrainTroopsButton Then ExitLoop 2

		 Sleep(200)
		 $failCount -= 1
	  WEnd
   Next

   If $failCount <= 0 Then
	  DebugWrite("Auto Raid, Queue Troops failed - error finding available Barracks Button panel.")
	  ResetToCoCMainScreen()
	  Return
   EndIf

   ; Click on Train Troops button
   Local $trainTroopsButton[4] = [ _
	  $barracksButtonBox[0]+$trainTroopsButtonX-7, _
	  $barracksButtonBox[1]+$trainTroopsButtonY-13 , _
	  $barracksButtonBox[0]+$trainTroopsButtonX+60, _
	  $barracksButtonBox[1]+$trainTroopsButtonY+55 ]
   RandomWeightedClick($trainTroopsButton)
   Sleep(200)

   ; Wait for Train Troops window to show up
   $failCount = 10 ; 2 seconds, should be instant
   While IsButtonPresent($rBarracksWindowNextButton) = False And $failCount>0
	  Sleep(200)
	  $failCount -= 1
   WEnd

   If $failCount = 0 Then
	  DebugWrite("Auto Raid, Queue Troops failed - timeout waiting for Train Troops window")
	  ResetToCoCMainScreen()
	  Return
   EndIf
EndFunc

Func CloseBarracksWindow()
   DebugWrite("CloseBarracksWindow()")
   ; Close Barracks window
   RandomWeightedClick($rBarracksWindowCloseButton)
   Sleep(500)

   ; Click on safe area to close Barracks Toolbar
   RandomWeightedClick($rSafeAreaButton)
   Sleep(500)
EndFunc

Func FindSpellsQueueingWindow()
   DebugWrite("FindSpellsQueueingWindow()")

   ; Click left arrow until the spells screen or a dark troops screen comes up
   Local $failCount = 6

   While IsColorPresent($rWindowBarracksSpellsColor1) = False And _
		 IsColorPresent($rWindowBarracksSpellsColor2) = False And _
		 IsColorPresent($rWindowBarracksDarkColor1) = False And _
		 IsColorPresent($rWindowBarracksDarkColor2) = False And _
		 $failCount > 0

	  RandomWeightedClick($rBarracksWindowPrevButton)
	  Sleep(500)
	  $failCount -= 1
   WEnd

   If $failCount <= 0 Then Return False

   Return True
EndFunc

Func FindBarracksTroopSlots(Const ByRef $bitmaps, ByRef $index)
   ; Populates index with the client area coords of all available troop buttons
   Local $barracksTroopBox[4] = [289, 224, 739, 400]
   Local $buttonOffset[4] = [0, 17, 74, 63]

   GrabFrameToFile("BarracksFrame.bmp", $barracksTroopBox[0], $barracksTroopBox[1], $barracksTroopBox[2], $barracksTroopBox[3])

   For $i = 0 To UBound($bitmaps)-1
	  Local $res = DllCall("ImageMatch.dll", "str", "FindMatch", "str", "BarracksFrame.bmp", "str", "Images\"&$bitmaps[$i], "int", 3)
	  Local $split = StringSplit($res[0], "|", 2) ; x, y, conf
	  ;DebugWrite("Barracks troop " & $bitmaps[$i] & " found at " & $split[0] & ", " & $split[1] & " conf: " & $split[2])

	  If $split[2] > $gConfidenceBarracksTroopSlot Then
		 $index[$i][0] = $split[0]+$barracksTroopBox[0]+$buttonOffset[0]
		 $index[$i][1] = $split[1]+$barracksTroopBox[1]+$buttonOffset[1]
		 $index[$i][2] = $split[0]+$barracksTroopBox[0]+$buttonOffset[2]
		 $index[$i][3] = $split[1]+$barracksTroopBox[1]+$buttonOffset[3]
		 ;DebugWrite("Barracks troop " & $bitmaps[$i] & " found at " & $index[$i][0] & ", " & $index[$i][1] & " conf: " & $split[2])
	  Else
		 $index[$i][0] = -1
		 $index[$i][1] = -1
		 $index[$i][2] = -1
		 $index[$i][3] = -1
	  EndIf
   Next
EndFunc


Func FillBarracks(Const $initialFillFlag, Const ByRef $availableTroopCounts)
   DebugWrite("FillBarracks()")

   ; See how many breakers we need
   Local $breakersToQueue = Number(GUICtrlRead($GUI_AutoRaidBreakerCountEdit)) - $availableTroopCounts[$eTroopWallBreaker]
   If _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED Then
	  DebugWrite("Wall Breakers needed: " & ($breakersToQueue>0 ? $breakersToQueue : 0))
   EndIf

   ; Loop through barracks and queue troops, until we get to a dark or spells screen, or we've done 4
   ; This function assumes that we are already on a spells window, or the last dark troops window (i.e. the starting point)
   Local $barracksCount = 1
   Local $failCount = 5

   While $barracksCount <= 4 And $failCount>0

	  ; Click right arrow to get the next standard troops window
	  RandomWeightedClick($rBarracksWindowNextButton)
	  Sleep(400)
	  $failCount-=1

	  ; Make sure we are on a standard troops window
	  If IsColorPresent($rWindowBarracksStandardColor1) = False And IsColorPresent($rWindowBarracksStandardColor2) = False Then
		 Local $cPos = GetClientPos()
		 DebugWrite("Not on Standard Troops Window: " & Hex(PixelGetColor($cPos[0]+$rWindowBarracksStandardColor1[0], $cPos[1]+$rWindowBarracksStandardColor1[1])))
		 ExitLoop
	  EndIf

	  If _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED And _
		 _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox)=$BST_UNCHECKED Then Return

	  ; Find the slots for the troops
	  Local $troopSlots[$eTroopCount][4]
	  FindBarracksTroopSlots($gBarracksTroopSlotBMPs, $troopSlots)

	  ; If breakers are included and this is an initial fill then queue up breakercount/4 in each barracks
	  If _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED And $initialFillFlag And $breakersToQueue>0 Then
		 ; Dequeue troops if needed, so breaker get built first
		 Local $dequeueTries = 6
		 While IsButtonPresent($rTrainTroopsWindowDequeueButton) And $dequeueTries>0 And _
			   (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_CHECKED Or _
			    _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox)=$BST_CHECKED)

			DebugWrite("Dequeueing troops.")
			Local $xClick, $yClick
			RandomWeightedCoords($rTrainTroopsWindowDequeueButton, $xClick, $yClick)
			_ClickHold($xClick, $yClick, 4000)
			$dequeueTries-=1
			Sleep(500)
		 WEnd

		 FindBarracksTroopSlots($gBarracksTroopSlotBMPs, $troopSlots)

		 ; Now queue the breakers
		 If $troopSlots[$eTroopWallBreaker][0] <> -1 Then
			Local $breakerButton[4] = [$troopSlots[$eTroopWallBreaker][0], $troopSlots[$eTroopWallBreaker][1], $troopSlots[$eTroopWallBreaker][2], $troopSlots[$eTroopWallBreaker][3]]

			If $breakersToQueue/4 < 1 Then
			   DebugWrite("Queueing 1 Wall Breaker.")
			   RandomWeightedClick($breakerButton)
			   Sleep(500)
			   $breakersToQueue-=1
			Else
			   For $i = 1 To Int($breakersToQueue/4)
			   DebugWrite("Queueing " & Int($breakersToQueue/4) & " Wall Breakers.")
				  RandomWeightedClick($breakerButton)
				  Sleep(500)
				  $breakersToQueue-=1
			   Next
			EndIf
		 EndIf
	  EndIf

	  FindBarracksTroopSlots($gBarracksTroopSlotBMPs, $troopSlots)

	  ; Fill up this barracks
	  Local $fillTries=1
	  Local $troopsToFill
	  Do
		 ; Get number of troops already queued in this barracks
		 Local $queueStatus = ScrapeFuzzyText($gLargeCharacterMaps, $rBarracksWindowTextBox, $gLargeCharMapsMaxWidth, $eScrapeDropSpaces)
		 ;DebugWrite("Barracks debug " & $barracksCount & " queue status: " & $queueStatus)

		 If (StringInStr($queueStatus, "Train")=1) Then
			$queueStatus = StringMid($queueStatus, 6)

			Local $queueStatSplit = StringSplit($queueStatus, "/")
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
				  DebugWrite("Barracks " & $barracksCount & ": Adding " & $troopsToFill & " troops.")

				  ; Alternate between archers and barbs
				  Local $xClick, $yClick
				  If $barracksCount/2 = Int($barracksCount/2) Then
					 If $troopSlots[$eTroopBarbarian][0] <> -1 Then
						Local $button[4] = [$troopSlots[$eTroopBarbarian][0], $troopSlots[$eTroopBarbarian][1], _
											$troopSlots[$eTroopBarbarian][2], $troopSlots[$eTroopBarbarian][3]]
						RandomWeightedCoords($button, $xClick, $yClick)

						_ClickHold($xClick, $yClick, $fillTime)
						Sleep(500)
					 EndIf

				  Else
					 If $troopSlots[$eTroopArcher][0] <> -1 Then
						Local $button[4] = [$troopSlots[$eTroopArcher][0], $troopSlots[$eTroopArcher][1], _
											$troopSlots[$eTroopArcher][2], $troopSlots[$eTroopArcher][3]]
						RandomWeightedCoords($button, $xClick, $yClick)
						RandomWeightedCoords($button, $xClick, $yClick)

						_ClickHold($xClick, $yClick, $fillTime)
						Sleep(500)
					 EndIf

				  EndIf

			   EndIf
			EndIf
		 EndIf

		 $fillTries+=1
	  Until $troopsToFill=0 Or $fillTries>=6 Or _
		 (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox)=$BST_UNCHECKED)

	  $barracksCount+=1
   WEnd
EndFunc

Func GetBarracksTroopCounts(Const ByRef $bitmaps, ByRef $counts)
   Local $barracksTroopBox[4] = [289, 224, 739, 400]
   Local $textOffset[4] = [0, -15, 35, 0]

   ; Grab frame
   GrabFrameToFile("BarracksFrame.bmp", $barracksTroopBox[0], $barracksTroopBox[1], _
				   $barracksTroopBox[2], $barracksTroopBox[3])

   ; Count queued number of each troop
   For $i = 0 To UBound($bitmaps)-1
	  Local $res = DllCall("ImageMatch.dll", "str", "FindMatch", "str", "BarracksFrame.bmp", _
						   "str", "Images\"&$bitmaps[$i], "int", 3)
	  Local $split = StringSplit($res[0], "|", 2) ; x, y, conf
	  ;DebugWrite("Troop " & $gBarracksTroopSlotBMPs[$i] & " conf: " & $split[2])

	  If $split[2] > $gConfidenceBarracksTroopSlot Then
		 Local $textBox[10] = [$barracksTroopBox[0] + $split[0] + $textOffset[0], _
							   $barracksTroopBox[1] + $split[1] + $textOffset[1], _
							   $barracksTroopBox[0] + $split[0] + $textOffset[2], _
							   $barracksTroopBox[1] + $split[1] + $textOffset[3], _
							   $rBarracksTroopCountTextBox[4], $rBarracksTroopCountTextBox[5], _
							   0, 0, 0, 0]

		 ; Parse queue text
		 Local $rawText = ScrapeFuzzyText($gLargeCharacterMaps, $textBox, $gLargeCharMapsMaxWidth, $eScrapeDropSpaces)
		 $counts[$i] = Number(StringReplace($rawText, "x", ""))
		 If $counts[$i]>0 Then DebugWrite("Barracks queued: " & $gTroopNames[$i] & " = " & $counts[$i])

	  EndIf
   Next
EndFunc

