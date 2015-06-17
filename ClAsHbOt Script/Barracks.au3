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

   If $barracksIndex = 0 Then
	  DebugWrite("OpenBarracksWindow failed - could not find Barracks building.")
	  ResetToCoCMainScreen()
	  Return
   EndIf

   ; Look through list of barracks for an available training screen, and get Train Troops button location
   Local $trainTroopsButtonX = -1, $trainTroopsButtonY = -1
   Local $barracksButtonBox[4] = [250, 454, 773, 521]
   Local $failCount

   For $i = 0 To $barracksIndex - 1
	  DebugWrite("Barracks " & $i & " found at " & $barracksPoints[$i][1] & "," & $barracksPoints[$i][2] & " confidence " & Round($barracksPoints[$i][0]*100, 2) & "%")

	  ; Click on barracks
	  Local $button[4] = [$barracksPoints[$i][1]+$rBarracksButton[0], $barracksPoints[$i][2]+$rBarracksButton[1], _
						  $barracksPoints[$i][1]+$rBarracksButton[2], $barracksPoints[$i][2]+$rBarracksButton[3] ]
	  RandomWeightedClick($button, .5, 3, 0, $rBarracksButton[3]/2)
	  Sleep(500)

	  ; Wait for barracks button panel to show up (Train Troops button)
	  $failCount = 10 ; 2 seconds, should be instant

	  While $failCount > 0
		 ; Grab a frame
		 GrabFrameToFile("BarracksButtonBarFrame.bmp", $barracksButtonBox[0], $barracksButtonBox[1], $barracksButtonBox[2], $barracksButtonBox[3])
		 Local $bestMatch, $bestConfidence
		 ScanFrameForBestBMP("BarracksButtonBarFrame.bmp", $gTrainTroopsButtonBMPs, $gConfidenceTrainTroopsButton, _
						     $bestMatch, $bestConfidence, $trainTroopsButtonX, $trainTroopsButtonY)
		 DebugWrite("Train Troops button found at " & $trainTroopsButtonX & "," & $trainTroopsButtonY & " confidence " & Round($bestConfidence*100, 2) & "%")

		 If $bestConfidence >= $gConfidenceTrainTroopsButton Then ExitLoop 2

		 Sleep(200)
		 $failCount -= 1
	  WEnd

	  If $failCount <= 0 Then
		 DebugWrite("OpenBarracksWindow failed - error finding available Barracks Button panel.")
		 ResetToCoCMainScreen()
		 Return
	  EndIf
   Next

   ; Click on Train Troops button
   Local $trainTroopsButton[4] = [ _
	  $barracksButtonBox[0]+$trainTroopsButtonX, _
	  $barracksButtonBox[1]+$trainTroopsButtonY-6 , _
	  $barracksButtonBox[0]+$trainTroopsButtonX+53, _
	  $barracksButtonBox[1]+$trainTroopsButtonY+48 ]
   RandomWeightedClick($trainTroopsButton)
   Sleep(200)

   ; Wait for Train Troops window to show up
   $failCount = 10 ; 2 seconds, should be instant
   While IsButtonPresent($rBarracksWindowNextButton) = False And $failCount>0
	  Sleep(200)
	  $failCount -= 1
   WEnd

   If $failCount = 0 Then
	  DebugWrite("OpenBarracksWindow failed - timeout waiting for Train Troops window")
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

   While $failCount>0
	  If OnTrainTroopsDarkWindow() Then Return True

	  If OnTrainTroopsSpellWindow() Then Return True

	  ; Next window
	  RandomWeightedClick($rBarracksWindowPrevButton)
	  Sleep(500)
	  $failCount -= 1
   WEnd

   Return False
EndFunc

Func OnTrainTroopsStandardWindow()
   ; Check colored slots
   Local $troopSlots[$eTroopCount][4]
   FindBarracksTroopSlots($gBarracksTroopSlotBMPs, $troopSlots)

   For $i=$eTroopBarbarian To $eTroopPekka
	  If $troopSlots[$i][0] <> -1 Then Return True
   Next

   ; Check grayed slots
   Local $troopSlots[$eTroopCount][4]
   FindBarracksTroopSlots($gBarracksTroopSlotGrayedBMPs, $troopSlots)

   For $i=$eTroopBarbarian To $eTroopPekka
	  If $troopSlots[$i][0] <> -1 Then Return True
   Next

   Return False
EndFunc

Func OnTrainTroopsDarkWindow()
   ; Check colored slots
   Local $troopSlots[$eTroopCount][4]
   FindBarracksTroopSlots($gBarracksTroopSlotBMPs, $troopSlots)

   For $i=$eTroopMinion To $eTroopLavaHound
	  If $troopSlots[$i][0] <> -1 Then Return True
   Next

   ; Check grayed slots
   Local $troopSlots[$eTroopCount][4]
   FindBarracksTroopSlots($gBarracksTroopSlotGrayedBMPs, $troopSlots)

   For $i=$eTroopMinion To $eTroopLavaHound
	  If $troopSlots[$i][0] <> -1 Then Return True
   Next

   Return False
EndFunc

Func OnTrainTroopsSpellWindow()
   ; Check colored slots
   Local $spellSlots[$eSpellCount][4]
   FindBarracksTroopSlots($gBarracksSpellSlotBMPs, $spellSlots)

   For $i=$eSpellLightning To $eSpellFreeze
	  If $spellSlots[$i][0] <> -1 Then Return True
   Next

   ; Check grayed slots
   ; TODO: uncomment once bmps are captured
   ;Local $spellSlots[$eSpellCount][4]
   ;FindBarracksTroopSlots($gBarracksSpellSlotGrayedBMPs, $spellSlots)

   ;For $i=$eSpellLightning To $eSpellFreeze
	;  If $spellSlots[$i][0] <> -1 Then Return True
   ;Next

   Return False
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

Func DequeueTroops()
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
EndFunc

Func QueueTroopsEvenly(Const $troop, Const ByRef $troopSlots, Const $troopsToQueue)

   If $troopSlots[$eTroopWallBreaker][0] <> -1 Then
	  Local $button[4] = [$troopSlots[$troop][0], $troopSlots[$troop][1], $troopSlots[$troop][2], $troopSlots[$troop][3]]

	  If $troopsToQueue/4 < 1 Then
		 DebugWrite("Queueing 1 " & $gTroopNames[$troop])
		 RandomWeightedClick($button)
		 Sleep(500)
	  Else
		 DebugWrite("Queueing " & Int($troopsToQueue/4) & " " & $gTroopNames[$troop])
		 For $i = 1 To Int($troopsToQueue/4)
			RandomWeightedClick($button)
			Sleep(500)
		 Next
	  EndIf
   EndIf
EndFunc


Func FillBarracksWithTroops(Const $troop, Const ByRef $troopSlots)
   Local $troopsToFill = 999

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
