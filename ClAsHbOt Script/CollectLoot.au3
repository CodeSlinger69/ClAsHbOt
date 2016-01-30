Func CollectLoot()
   ;DebugWrite("CollectLoot()")

   Local $frame = CaptureFrame("CollectLoot", $gWestPoint[0], $gNorthPoint[1], $gEastPoint[0], $gSouthPoint[1])
   If $gDebugSaveScreenCaptures Then SaveDebugImage($frame, "CollectLootFrame.bmp")

   ; Find all the collectors that need clicking in the frame
   Local $mX[1], $mY[1], $c[1]
   Local $matchCount = ScanFrameForAllBMPs($frame, $CollectLootBMPs, $gConfidenceCollectLoot, 17, $mX, $mY, $c)

   ; Do the collecting
   If $matchCount > 0 Then
	  ; Sort the matches
	  Local $sortedX[$matchCount], $sortedY[$matchCount]
	  SortArrayByClosestNeighbor($matchCount, $mX, $mY, $sortedX, $sortedY)

	  ; Collect the gold, elixir and dark loot
	  For $i = 0 To $matchCount-1

		 Local $button[4] = [ _
			$gWestPoint[0]  + $sortedX[$i] + $rCollectorButton[0], _
			$gNorthPoint[1] + $sortedY[$i] + $rCollectorButton[1], _
			$gWestPoint[0]  + $sortedX[$i] + $rCollectorButton[2], _
			$gNorthPoint[1] + $sortedY[$i] + $rCollectorButton[3]]

		 DebugWrite("CollectLoot() Found collectors, clicking " & $i & " of " & $matchCount & " at " & $button[0] & "," & $button[1])
		 RandomWeightedClick($button)

		 ;DebugWrite("Loot: " & $sortedX[$i] & "," & $sortedY[$i])
		 ;Sleep(Random(100, 500, 1))
	  Next

	  Sleep(1000)
   EndIf

   ; Check for loot cart
   Local $x, $y, $conf
   FindLootCart($x, $y, $conf)

   If $x <> -1 Then
	  Local $button[4] = [$x, $y, $x + 15, $y + 15]
	  DebugWrite("CollectLoot() Found loot cart, clicking at " & $button[0] & "," & $button[1] & " confidence " & Round($conf*100, 2) & "%")
	  RandomWeightedClick($button)

	  If WaitForButton($frame, 5000, $rLootCartCollectButton) = True Then
		 RandomWeightedClick($rLootCartCollectButton)
		 Sleep(1000)
	  EndIf
   EndIf

   _GDIPlus_BitmapDispose($frame)
EndFunc

Func SortArrayByClosestNeighbor(Const $matchCount, Const ByRef $x, Const ByRef $y, ByRef $sortedX, ByRef $sortedY)
   ; Find leftmost point
   Local $leftmost = 9999, $leftMatch
   For $i = 0 To $matchCount-1
	  If $x[$i] < $leftmost Then
		 $leftMatch = $i
		 $leftmost = $x[$i]
	  EndIf
   Next

   ; Build array of closest neighbors to leftmost match
   $sortedX[0] = $x[$leftMatch]
   $sortedY[0] = $y[$leftMatch]
   Local $sortedCount=1
   Local $alreadySorted[$matchCount]
   $alreadySorted[$leftMatch] = True

   Local $nextClosest
   Local $lastClosest=$leftMatch
   Do
	  Local $bestDist=999
	  $nextClosest=999
	  For $i = 0 To $matchCount-1
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
