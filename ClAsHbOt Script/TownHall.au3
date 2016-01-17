Func GetTownHallLevel(Const $fullScan, ByRef $location, ByRef $left, ByRef $top, Const $x1 = -1, Const $y1 = -1, Const $x2 = -1, Const $y2 = -1)
   ;DebugWrite("GetTownHallLevel()")

   ; Method = 0: CV_TM_SQDIFF, 1: CV_TM_SQDIFF_NORMED, 2: CV_TM_CCORR, 3: CV_TM_CCORR_NORMED
   ;          4: CV_TM_CCOEFF, 5: CV_TM_CCOEFF_NORMED

   ; Returns best TH level match, 0 if no good match
   Local $bestMatch, $bestConfidence

   ; Grab and scan frame
   If $fullScan=True Then DragScreenDown()
   GrabFrameToFile("TownHallTopFrame.bmp", $x1, $y1, $x2, $y2)
   ScanFrameForBestBMP("TownHallTopFrame.bmp", $TownHallBMPs, $gConfidenceTownHall, $bestMatch, $bestConfidence, $left, $top)

   If $bestMatch <> -1 And ($fullScan=False Or $top+12<=$gScreenCenterDraggedDown[1]) Then
	  $location = "Top"
	  ;DebugWrite("Likely TH Level " & $bestMatch+6 & " conf: " & $bestConfidence)
	  Return $bestMatch+6
   EndIf

   If $fullScan=False Then Return -1

   ; If TH is not found, it might be in the bottommost corner and obscured
   DragScreenUp()
   GrabFrameToFile("TownHallTopFrame.bmp", $x1, $y1, $x2, $y2)
   ScanFrameForBestBMP("TownHallTopFrame.bmp", $TownHallBMPs, $gConfidenceTownHall, $bestMatch, $bestConfidence, $left, $top)

   If $bestMatch <> -1 Then
	  $location = "Bot"
	  ;DebugWrite("Likely TH Level " & $bestMatch+6 & " conf: " & $bestConfidence & @CRLF)
	  Return $bestMatch+6
   EndIf

   ; Couldn't get TH level
   ;DebugWrite("Unknown TH Level")
   Return -1
EndFunc
