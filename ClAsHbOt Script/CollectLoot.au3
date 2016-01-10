
Func CollectLoot()
   ; Method = 0: CV_TM_SQDIFF, 1: CV_TM_SQDIFF_NORMED 2: CV_TM_CCORR 3: CV_TM_CCORR_NORMED 4: CV_TM_CCOEFF 5: CV_TM_CCOEFF_NORMED
   Local $totalMatches = 0, $currIndex = 0
   Local $matchX[1], $matchY[1]
   Local $mX[1], $mY[1], $mCount

   DebugWrite("CollectLoot()")

   ; Grab frame
   GrabFrameToFile("CollectLootFrame.bmp")

   ; Find all the dark elixir collectors that need clicking in the frame
   $mCount = LocateBuildings("Dark Elixir Collectors", "CollectLootFrame.bmp", $CollectDarkLootBMPs, $gConfidenceCollectLoot, $mX, $mY)

   For $i = 0 To $mCount-1
	  ;DebugWrite("Dark Match " & $i & ": " & $mX[$i] & "," & $mY[$i])

	  $totalMatches += 1
	  ReDim $matchX[$totalMatches]
	  ReDim $matchY[$totalMatches]
	  $matchX[$totalMatches-1] = $mX[$i]
	  $matchY[$totalMatches-1] = $mY[$i]
   Next

   ; Find all the gold collectors that need clicking in the frame
   $mCount = LocateBuildings("Gold Collectors", "CollectLootFrame.bmp", $CollectGoldLootBMPs, $gConfidenceCollectLoot, $mX, $mY)

   For $i = 0 To $mCount-1
	  ;DebugWrite("Gold Match " & $i & ": " & $mX[$i] & "," & $mY[$i])

	  $totalMatches += 1
	  ReDim $matchX[$totalMatches]
	  ReDim $matchY[$totalMatches]
	  $matchX[$totalMatches-1] = $mX[$i]
	  $matchY[$totalMatches-1] = $mY[$i]
   Next

   ; Find all the elixir collectors that need clicking in the frame
   $mCount = LocateBuildings("Elixir Collectors", "CollectLootFrame.bmp", $CollectElixLootBMPs, $gConfidenceCollectLoot, $mX, $mY)

   For $i = 0 To $mCount-1
	  ;DebugWrite("Elix Match " & $i & ": " & $mX[$i] & "," & $mY[$i])

	  $totalMatches += 1
	  ReDim $matchX[$totalMatches]
	  ReDim $matchY[$totalMatches]
	  $matchX[$totalMatches-1] = $mX[$i]
	  $matchY[$totalMatches-1] = $mY[$i]
   Next

   If _GUICtrlButton_GetCheck($GUI_CollectLootCheckBox)<>$BST_CHECKED Then Return

   ; Do the collecting
   If $totalMatches > 0 Then
	  ; Sort the matches
	  Local $sortedX[$totalMatches], $sortedY[$totalMatches]
	  SortArrayByClosestNeighbor($totalMatches, $matchX, $matchY, $sortedX, $sortedY)

	  ; Collect the gold and elixir loot
	  For $i = 0 To $totalMatches-1

		 Local $button[4] = [$sortedX[$i]+$rCollectorButton[0], $sortedY[$i]+$rCollectorButton[1], _
						     $sortedX[$i]+$rCollectorButton[2], $sortedY[$i]+$rCollectorButton[3]]
		 RandomWeightedClick($button)

		 ;DebugWrite("Loot: " & $sortedX[$i] & "," & $sortedY[$i])

		 Sleep(Random(100, 500, 1))
	  Next
   EndIf
EndFunc

Func SortArrayByClosestNeighbor(Const $numElements, Const ByRef $x, Const ByRef $y, ByRef $sortedX, ByRef $sortedY)
   ; Find leftmost point
   Local $leftmost = 9999, $leftMatch
   For $i = 0 To $numElements-1
	  If $x[$i] < $leftmost Then
		 $leftMatch = $i
		 $leftmost = $x[$i]
	  EndIf
   Next

   ; Build array of closest neighbors to leftmost match
   $sortedX[0] = $x[$leftMatch]
   $sortedY[0] = $y[$leftMatch]
   Local $sortedCount=1
   Local $alreadySorted[$numElements]
   $alreadySorted[$leftMatch] = True

   Local $nextClosest
   Local $lastClosest=$leftMatch
   Do
	  Local $bestDist=999
	  $nextClosest=999
	  For $i = 0 To $numElements-1
		 If $alreadySorted[$i]<>True Then
			Local $dist = Sqrt(($x[$i]-$x[$lastClosest])^2 + ($y[$i]-$y[$lastClosest])^2)
			If $dist<$bestDist Then
			   $bestDist = $dist
			   $nextClosest = $i
			EndIf
		 EndIf
	  Next

	  If $nextClosest<>999 Then
		 $alreadySorted[$nextClosest] = True
		 $sortedX[$sortedCount] = $x[$nextClosest]
		 $sortedY[$sortedCount] = $y[$nextClosest]
		 $sortedCount += 1
		 $lastClosest = $nextClosest
	  EndIf
   Until $nextClosest=999
EndFunc
