
Func CollectLoot()
   ; Method = 0: CV_TM_SQDIFF, 1: CV_TM_SQDIFF_NORMED 2: CV_TM_CCORR 3: CV_TM_CCORR_NORMED 4: CV_TM_CCOEFF 5: CV_TM_CCOEFF_NORMED
   Local $totalMatches = 0, $currIndex = 0
   Local $cpos = GetClientPos()
   Local $matchX[1], $matchY[1]
   Local $xClick, $yClick

   DebugWrite("CollectLoot()")

   ; Grab frame
   GrabFrameToFile("CollectorsFrame.bmp")

   ; Find all the collectors that need clicking in the frame
   For $loop = 0 To UBound($CollectorFullBMPs)-1
	  ; Get matches for this resource
	  Local $res = DllCall("ImageMatch.dll", "str", "FindAllMatches", "str", "CollectorsFrame.bmp", _
			   "str", "Images\"&$CollectorFullBMPs[$loop], "int", 3, "int", 6, "double", $confidenceCollectorLootSearch)
	  Local $split = StringSplit($res[0], "|", 2)
	  $totalMatches += $split[0]
	  ;ConsoleWrite("Num matches: " & %i & " " & $split[0] & @CRLF)
	  ReDim $matchX[$totalMatches]
	  ReDim $matchY[$totalMatches]
	  Local $i
	  For $i = 0 To $split[0]-1
		 $matchX[$currIndex] = $split[$i*3+1]
		 $matchY[$currIndex] = $split[$i*3+2]
		 $currIndex += 1
		 ;ConsoleWrite("Match " & $currIndex & ": " & $split[$i*3+1] & "," & $split[$i*3+2] & @CRLF)
	  Next
   Next

   ; Do the collecting
   If $totalMatches > 0 Then
	  ; Sort the matches
	  Local $sortedX[$totalMatches], $sortedY[$totalMatches]
	  SortArrayByClosestNeighbor($totalMatches, $matchX, $matchY, $sortedX, $sortedY)

	  ; Collect the gold and elixir loot
	  For $i = 0 To $totalMatches-1
		 RandomWeightedCoords($CollectorButton, $xClick, $yClick)
		 ;ConsoleWrite("Loot: " & $sortedX[$i] & "," & $sortedY[$i] & " " & Int($xClick) & "," & Int($yClick) & " " & Int($cPos[0]+$sortedX[$i]+$xClick) & "," & Int($cPos[1]+$sortedY[$i]+$yClick) & @CRLF)

		 If $ExitApp Then ExitLoop

		 Sleep(Random(100, 500, 1))
		 MouseClick("left", $cPos[0]+$sortedX[$i]+$xClick, $cPos[1]+$sortedY[$i]+$yClick)
	  Next
   EndIf
EndFunc
