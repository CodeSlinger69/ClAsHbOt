Func GetTownHallLevel(ByRef $left, ByRef $top, Const $x1 = -1, Const $y1 = -1, Const $x2 = -1, Const $y2 = -1)
   ;DebugWrite("GetTownHallLevel()")

   ; Method = 0: CV_TM_SQDIFF, 1: CV_TM_SQDIFF_NORMED, 2: CV_TM_CCORR, 3: CV_TM_CCORR_NORMED
   ;          4: CV_TM_CCOEFF, 5: CV_TM_CCOEFF_NORMED

   ; Returns best TH level match, 0 if no good match
   Local $bestMatch, $bestConfidence

   ; Grab and scan frame
   GrabFrameToFile2("TownHallFrame.bmp", $x1, $y1, $x2, $y2)
   ScanFrameForBestBMP("TownHallFrame.bmp", $TownHallBMPs, $gConfidenceTownHall, $bestMatch, $bestConfidence, $left, $top)

   If $bestMatch <> -1 Then
	  ;DebugWrite("Likely TH Level " & $bestMatch+6 & " conf: " & $bestConfidence)
	  Return $bestMatch+6
   EndIf
EndFunc

Func LocateBuildings(Const $type, Const $frame, Const ByRef $buildingBMPs, Const $buildingConfidence, ByRef $matchX, ByRef $matchY)
   DebugWrite("LocateBuildings() " & $type)

   ; Find all the buildings of the specified type
   Local $matchCount = 0

   For $i = 0 To UBound($buildingBMPs)-1
	  ; Get matches for this resource
	  Local $res = DllCall("ImageMatch.dll", "str", "FindAllMatches", "str", $frame, _
			   "str", "Images\"&$buildingBMPs[$i], "int", 3, "int", 6, "double", $buildingConfidence)
	  Local $split = StringSplit($res[0], "|", 2)
	  ;DebugWrite("Num matches " & $buildingBMPs[$i] & ": " & $split[0])

	  For $j = 0 To $split[0]-1
		 ; Loop through all captured points so far, if this one is within 8 pix of an existing one,
		 ; then skip it.
		 Local $alreadyFound = False
		 For $k = 0 To $matchCount-1
			If DistBetweenTwoPoints($split[$j*3+1], $split[$j*3+2], $matchX[$k], $matchY[$k]) < 8 Then
			   $alreadyFound = True
			   ;DebugWrite("    Already found " & $j & ": " & $split[$j*3+1] & "," & $split[$j*3+2] & "  " & $split[$j*3+3])
			   ExitLoop
			EndIf
		 Next

		 ; Otherwise add it to the growing list of matches, if it is $buildingConfidence % or greater confidence
		 If $alreadyFound = False Then
			If $split[$j*3+3] > $buildingConfidence Then
			   ;DebugWrite("    Adding " & $j & ": " & $split[$j*3+1] & "," & $split[$j*3+2] & "  " & $split[$j*3+3])
			   $matchCount += 1
			   ReDim $matchX[$matchCount]
			   ReDim $matchY[$matchCount]
			   $matchX[$matchCount-1] = $split[$j*3+1]
			   $matchY[$matchCount-1] = $split[$j*3+2]
			EndIf
		 EndIf
	  Next
   Next

   Return $matchCount
EndFunc
