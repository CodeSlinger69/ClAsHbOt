Func OpenArmyCampWindow()
   DebugWrite("OpenArmyCampWindow()")

   ; Locate Army Camp
   Local $bestMatch, $bestConfidence, $bestX, $bestY
   GrabFrameToFile("ArmyCampSearchFrame.bmp")
   ScanFrameForBestBMP("ArmyCampSearchFrame.bmp", $gArmyCampBMPs, $gConfidenceArmyCamp, $bestMatch, $bestConfidence, $bestX, $bestY)

   If $bestMatch = -1 Then Return False

   DebugWrite("Located Level " & $bestMatch+6 & " Army Camp at " & $bestX & ", " & $bestY & " confidence " & Round($bestConfidence*100, 2) & "%")

   ; Select Army Camp
   Local $campButton[4] = [$bestX-8, $bestY-8, $bestX+40, $bestY+40]
   RandomWeightedClick($campButton)

   ; Wait for Army Camp info button
   Local $failCount=10
   Do
	  Sleep(100)
	  $failCount-=1
   Until IsButtonPresent($rArmyCampInfoButton1) Or IsButtonPresent($rArmyCampInfoButton2) Or $failCount<=0

   If $failCount<=0 Then
	  DebugWrite("Error getting Army Camp info button.")
	  Return False
   EndIf

   ; Click Army Camp info button
   If IsButtonPresent($rArmyCampInfoButton1) Then
	  RandomWeightedClick($rArmyCampInfoButton1)
   Else
	  RandomWeightedClick($rArmyCampInfoButton2)
   EndIf

   ; Wait for Army Camp info screen
   Local $failCount=10
   Do
	  Sleep(100)
	  $failCount-=1
   Until IsButtonPresent($rArmyCampInfoScreenCloseWindowButton) Or $failCount<=0

   If $failCount<=0 Then
	  DebugWrite("Error getting Army Camp info screen.")
	  Return False
   EndIf

   Return True
EndFunc

Func CloseArmyCampWindow()
   ; Close Army Camp Window
   ResetToCoCMainScreen()
EndFunc

Func FindArmyCampTroopSlots(Const ByRef $bitmaps, ByRef $index)
   DebugWrite("FindArmyCampTroopSlots()")
   ; Populates index with the absolute screen coords of all available troop buttons
   Local $buttonOffset[4] = [0, -0, 51, 69]
   Local $armyCampTroopBox[4] = [291, 287, 753, 331]

   GrabFrameToFile("AvailableRaidTroopsFrame.bmp", $armyCampTroopBox[0], $armyCampTroopBox[1], $armyCampTroopBox[2], $armyCampTroopBox[3])

   For $i = 0 To UBound($bitmaps)-1
	  Local $res = DllCall("ImageMatch.dll", "str", "FindMatch", "str", "AvailableRaidTroopsFrame.bmp", "str", "Images\"&$bitmaps[$i], "int", 3)
	  Local $split = StringSplit($res[0], "|", 2) ; x, y, conf
	  ;DebugWrite("Troop " & $bitmaps[$i] & " found at " & $split[0] & ", " & $split[1] & " conf: " & $split[2])

	  If $split[2] > $gConfidenceArmyCampTroopSlot Then
		 $index[$i][0] = $split[0]+$armyCampTroopBox[0]+$buttonOffset[0]
		 $index[$i][1] = $split[1]+$armyCampTroopBox[1]+$buttonOffset[1]
		 $index[$i][2] = $split[0]+$armyCampTroopBox[0]+$buttonOffset[2]
		 $index[$i][3] = $split[1]+$armyCampTroopBox[1]+$buttonOffset[3]
		 ;DebugWrite("Troop " & $bitmaps[$i] & " found at " & $index[$i][0] & ", " & $index[$i][1] & " confidence: " & $split[2])
	  Else
		 $index[$i][0] = -1
		 $index[$i][1] = -1
		 $index[$i][2] = -1
		 $index[$i][3] = -1
	  EndIf
   Next
EndFunc

Func GetArmyCampTroopCounts(ByRef $counts)
   Local $troopIndex[$eTroopCount][4]
   FindArmyCampTroopSlots($gCampTroopSlotBMPs, $troopIndex)

   ; Count troops
   For $i = $eTroopBarbarian To $eTroopLavaHound
	  $counts[$i] = 0

	  If $troopIndex[$i][0] <> -1 Then
		 Local $textBox[10] = [$troopIndex[$i][0]+16, $troopIndex[$i][1]+54, $troopIndex[$i][0]+50, $troopIndex[$i][1]+63, _
							   $rArmyCampTroopCountTextBox[4], $rArmyCampTroopCountTextBox[5], _
							   0, 0, 0, 0]

		 Local $t = Number(ScrapeFuzzyText($gArmyCampCharacterMaps, $textBox, $gArmyCampCharMapsMaxWidth, $eScrapeDropSpaces))

		 $counts[$i] = Number($t)
		 DebugWrite("Troop " & $gTroopNames[$i] & " available: " & $counts[$i])
	  EndIf
   Next
EndFunc
