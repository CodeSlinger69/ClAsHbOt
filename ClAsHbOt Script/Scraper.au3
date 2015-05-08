#include <CharMaps.au3>
#include <RegionDefs.au3>

; Scraper Globals
Global $CoCIconBMPs[1] = ["CoCIcon.bmp"]
Global $TownHallBMPs[4] = ["TH7.bmp", "TH8.bmp", "TH9.bmp", "TH10.bmp"]
Global $CollectLootBMPs[3] = ["FullGoldCollector.bmp", "FullElixCollector.bmp", "FullDarkCollector.bmp"]
Global $BarracksBMPs[2] = ["BarracksL10.bmp", "BarracksL9.bmp"]
Global $DonateButtonBMPs[1] = ["DonateButton.bmp"]
Global $CollectorBMPs[8] = ["GoldCollectorL12.bmp", "GoldCollectorL11.bmp", "GoldCollectorL10.bmp", "GoldCollectorL9.bmp", _
						    "ElixCollectorL12.bmp", "ElixCollectorL11.bmp", "ElixCollectorL10.bmp", "ElixCollectorL9.bmp"]
Global $DarkStorageBMPs[10] = ["DarkStorageL6.25.bmp", "DarkStorageL6.00.bmp", "DarkStorageL5.25.bmp", "DarkStorageL4.50.bmp", _
							   "DarkStorageL4.00.bmp", "DarkStorageL3.00.bmp", "DarkStorageL2.25.bmp", "DarkStorageL2.00.bmp", _
							   "DarkStorageL1.25.bmp", "DarkStorageL1.00.bmp"]
Global $gArmyCampBMPs[3] = ["ArmyCampL6.bmp", "ArmyCampL7.bmp", "ArmyCampL8.bmp"]

; TODO: get bmps for freeze spell
Global $gTroopSlotBMPs[$eTroopCount] = _
		 ["SlotBarbarian.bmp", "SlotArcher.bmp", "SlotGiant.bmp", "SlotGoblin.bmp", _
		  "SlotWallBreaker.bmp", "SlotBalloon.bmp", "SlotWizard.bmp", "SlotHealer.bmp", _
		  "SlotDragon.bmp", "SlotPekka.bmp", _
		  "SlotMinion.bmp", "SlotHogRider.bmp", "SlotValkyrie.bmp", "SlotGolem.bmp", _
		  "SlotWitch.bmp", "SlotLavaHound.bmp", _
		  "SlotKing.bmp", "SlotQueen.bmp"]
Global $gSpellSlotBMPs[$eSpellCount] = _
		 ["SlotLightningSpell.bmp", "SlotHealSpell.bmp", "SlotRageSpell.bmp", "SlotJumpSpell.bmp", "SlotDummy.bmp"]
Global $gDonateSlotBMPs[16] = _
		 ["DonateBarbarian.bmp", "DonateArcher.bmp", "DonateGiant.bmp", "DonateGoblin.bmp", _
		  "DonateWallBreaker.bmp", "DonateBalloon.bmp", "DonateWizard.bmp", "DonateHealer.bmp", _
		  "DonateDragon.bmp", "DonatePekka.bmp", "DonateMinion.bmp", "DonateHogRider.bmp", _
		  "DonateValkyrie.bmp", "DonateGolem.bmp", "DonateWitch.bmp", "DonateLavaHound.bmp"]
Global $gCampTroopSlotBMPs [$eTroopCount-2] = _
		 ["CampBarbarian.bmp", "CampArcher.bmp", "CampGiant.bmp", "CampGoblin.bmp", _
		  "CampWallBreaker.bmp", "CampBalloon.bmp", "CampWizard.bmp", "CampHealer.bmp", _
		  "CampDragon.bmp", "CampPekka.bmp", _
		  "CampMinion.bmp", "CampHogRider.bmp", "CampValkyrie.bmp", "CampGolem.bmp", _
		  "CampWitch.bmp", "CampLavaHound.bmp"]
Global $gBarracksTroopSlotBMPs [$eTroopCount-2] = _
		 ["BarracksBarbarian.bmp", "BarracksArcher.bmp", "BarracksGiant.bmp", "BarracksGoblin.bmp", _
		  "BarracksWallBreaker.bmp", "BarracksBalloon.bmp", "BarracksWizard.bmp", "BarracksHealer.bmp", _
		  "BarracksDragon.bmp", "BarracksPekka.bmp", _
		  "BarracksMinion.bmp", "BarracksHogRider.bmp", "BarracksValkyrie.bmp", "BarracksGolem.bmp", _
		  "BarracksWitch.bmp", "BarracksLavaHound.bmp"]
Global Enum $eScrapeDropSpaces, $eScrapeKeepSpaces

Func InitScraper()
   _GDIPlus_Startup()

   ; Auto Raid deploy locations
   Local $x, $y, $i

   $y = 325
   $i=0
   For $x = 70 To 470 Step 20
	  $NWDeployBoxes[$i][0] = $x
	  $NWDeployBoxes[$i][1] = $y
	  $NWDeployBoxes[$i][2] = $x+60
	  $NWDeployBoxes[$i][3] = $y+40
	  ;DebugWrite("NW Box: " & $i & " " & $NWDeployBoxes[$i][0] & "  " & $NWDeployBoxes[$i][1] & "  " & $NWDeployBoxes[$i][2] & "  " & $NWDeployBoxes[$i][3] & @CRLF)
	  $i+=1
	  $y-=14
   Next

   $y = 325
   $i=0
   For $x = 950 To 550 Step -20
	  $NEDeployBoxes[$i][0] = $x-60
	  $NEDeployBoxes[$i][1] = $y
	  $NEDeployBoxes[$i][2] = $x
	  $NEDeployBoxes[$i][3] = $y+40
	  ;DebugWrite("NE Box: " & $i & " " & $NEDeployBoxes[$i][0] & "  " & $NEDeployBoxes[$i][1] & "  " & $NEDeployBoxes[$i][2] & "  " & $NEDeployBoxes[$i][3] & @CRLF)
	  $i+=1
	  $y-=14
   Next

   $y = 125
   $i=0
   For $x = 70 To 470 Step 20
	  $SWDeployBoxes[$i][0] = $x
	  $SWDeployBoxes[$i][1] = $y
	  $SWDeployBoxes[$i][2] = $x+60
	  $SWDeployBoxes[$i][3] = $y+40
	  ;DebugWrite("SW Box: " & $i & " " & $SWDeployBoxes[$i][0] & "  " & $SWDeployBoxes[$i][1] & "  " & $SWDeployBoxes[$i][2] & "  " & $SWDeployBoxes[$i][3] & @CRLF)
	  $i+=1
	  $y+=14
   Next

   $y = 125
   $i=0
   For $x = 950 To 550 Step -20
	  $SEDeployBoxes[$i][0] = $x-60
	  $SEDeployBoxes[$i][1] = $y
	  $SEDeployBoxes[$i][2] = $x
	  $SEDeployBoxes[$i][3] = $y+40
	  ;DebugWrite("SE Box: " & $i & " " & $SEDeployBoxes[$i][0] & "  " & $SEDeployBoxes[$i][1] & "  " & $SEDeployBoxes[$i][2] & "  " & $SEDeployBoxes[$i][3] & @CRLF)
	  $i+=1
	  $y+=14
   Next

EndFunc

Func ExitScraper()
   _GDIPlus_Shutdown()
EndFunc

Func ScrapeFuzzyText(Const ByRef $charMapArray, Const ByRef $textBox, Const $maxCharSize, Const $keepSpaces)
   ; Grab frame
   Local $cPos = GetClientPos()
   Local $hBitmap = _ScreenCapture_Capture("", $cPos[0], $cPos[1], $cPos[2], $cPos[3], False)
   Local $frame = _GDIPlus_BitmapCreateFromHBITMAP($hBitmap)


   ; Figure out dimensions of text box
   Local $w = $textBox[2] - $textBox[0] + 1
   Local $h = $textBox[3] - $textBox[1] + 1

   ; Get map of foreground pixels
   Local $pix[$w][$h]
   Local $pY
   GetForegroundPixels($frame, $textBox, $pix, $pY)

   ; Clean up GDI and WinAPI objects
   _GDIPlus_BitmapDispose($frame)
   _WinAPI_DeleteObject($hBitmap)

   ; Scan left to right through foreground pixel map to identify individual characters
   Local $textString = ""
   Local $x = 0
   Do
	  ; Find start of char
	  Local $charStart = -1
	  Local $blankCol, $blankColCount = 0
	  Do
		 $blankCol = True
		 For $by = 0 To $pY-1
			If $pix[$x][$by] = 1 Then $blankCol = False
		 Next

		 If $blankCol = True Then
			$x+=1
			$blankColCount+=1

			; add a space if multiple blank columns are detected
			If $blankColCount=3 And StringLen($textString)>0 And $keepSpaces=$eScrapeKeepSpaces Then
			   $textString &= " "
			EndIf
		 EndIf
	  Until $blankCol = False Or $x >= $w

	  If $blankCol = False Then
		 $charStart = $x
	  EndIf

	  ; Find end of char
	  Local $nonBlankCol
	  Local $charEnd = $charStart+1

	  If $charEnd >= $w Then
		 $charEnd = $w-1
	  Else
		 Do
			$nonBlankCol = False
			For $by = 0 To $pY-1
			   If $pix[$charEnd][$by] = 1 Then $nonBlankCol = True
			Next

			If $nonBlankCol = True Then
			   $charEnd+=1
			EndIf
		 Until $nonBlankCol = False Or $charEnd >= $w
		 $charEnd-=1
	  EndIf

	  If $charEnd-$charStart+1>$maxCharSize Then $charEnd=$charStart+$maxCharSize-1

	  If $gScraperDebug Then DebugWrite("Char start/end " & $charStart & "/" & $charEnd & " of " & $w-1)

	  ; Find match with greatest width
	  Local $largestMatchIndex=-1
	  Local $bestWidth = -1
	  Local $bestWeight = 999
	  Local $colValues[$maxCharSize]

	  If $charStart <> -1 Then
		 ; Scan through varying sized character, starting at $charWidth, down to $charWidth/2
		 Local $charWidth = $charEnd-$charStart+1
		 For $testWidth = $charWidth To $charWidth ;Int($charWidth/2) Step -1

			; Find the first non blank row, starting from the bottom
			Local $bottomOfChar = -1
			For $cY = $pY-1 To 0 Step -1
			   For $cX = 0 To $testWidth-1
				  If $pix[$charStart+$cX][$cY] = 1 Then
					 $bottomOfChar = $cY
					 ExitLoop
				  EndIf
			   Next
			   If $bottomOfChar <> -1 Then ExitLoop
			Next

			; Calculate colValues for this test width
			If $gScraperDebug Then ConsoleWrite("TestWidth=" & $testWidth & " ColValues=")
			For $cX = 0 To $testWidth-1
			   Local $factor = 1
			   $colValues[$cX] = 0
			   For $cY = $bottomOfChar To 0 Step -1
				  $colValues[$cX] += ($pix[$charStart+$cX][$cY] * $factor)
				  $factor*=2
			   Next
			   If $gScraperDebug Then ConsoleWrite($colValues[$cX] & ", ")
			Next
			If $gScraperDebug Then ConsoleWrite(@CRLF)

			; Find a match
			Local $weight
			Local $bestMatchIndex = FindFuzzyCharInArray($charMapArray, $colValues, $testWidth, $weight)

			If $gScraperDebug Then ConsoleWrite("width=" & $testWidth & " index=" & $bestMatchIndex & " weight=" & $weight & "(bestweight=" & $bestWeight & ")" & @CRLF)
			If $bestMatchIndex<>-1 And $weight<1 And $weight<$bestWeight Then
			   $largestMatchIndex = $bestMatchIndex
			   $bestWidth = $testWidth
			   $bestWeight = $weight
			EndIf
		 Next
	  EndIf

	  ; Debug
	  If $gScraperDebug And $charEnd<>-1 Then
		 ConsoleWrite($charStart & " to " & $charStart+$bestWidth-1 & ": " & _
						($largestMatchIndex<>-1 ? $charMapArray[$largestMatchIndex][0] : "`" ) & @CRLF)
	  EndIf

	  ; Got a match or not?
	  If $largestMatchIndex <> -1 Then
		 $textString &= $charMapArray[$largestMatchIndex][0]
		 $x = $charStart+$bestWidth
	  ElseIf $charEnd<>-1 Then
		 ;$textString &= "?"
		 $x += 1
	  EndIf

   Until $x >= $w

   $textString = StringStripWS($textString, $STR_STRIPTRAILING)

   ; Debug
   If $gScraperDebug Then
	  ConsoleWrite($textString & @CRLF)
	  ConsoleWrite("-------------------------------------------------------------------------" & @CRLF)
	  For $y = 0 To $pY-1
		ConsoleWrite("|")
		 For $x = 0 To $w-1
			If $pix[$x][$y] = 1 Then
			   ConsoleWrite("x")
			Else
			   ConsoleWrite(" ")
			EndIf
		 Next
		 ConsoleWrite("|" & @CRLF)
	  Next
	  ConsoleWrite("-------------------------------------------------------------------------" & @CRLF)
   EndIf

   Return $textString
EndFunc

; Non fuzzy character matching - only good for chat box right now
Func ScrapeExactText(Const ByRef $charMapArray, Const ByRef $textBox, Const $maxCharSize, Const $keepSpaces)
   ; Grab frame
   Local $cPos = GetClientPos()
   Local $hBitmap = _ScreenCapture_Capture("", $cPos[0], $cPos[1], $cPos[2], $cPos[3], False)
   Local $frame = _GDIPlus_BitmapCreateFromHBITMAP($hBitmap)

   ; Figure out dimensions of text box
   Local $w = $textBox[2] - $textBox[0] + 1
   Local $h = $textBox[3] - $textBox[1] + 1

   ; Get map of foreground pixels
   Local $pix[$w][$h]
   Local $pY
   GetForegroundPixels($frame, $textBox, $pix, $pY)

   ; Clean up GDI and WinAPI objects
   _GDIPlus_BitmapDispose($frame)
   _WinAPI_DeleteObject($hBitmap)

   ; Scan left to right through foreground pixel map to identify individual characters
   Local $textString = ""
   Local $x = 0
   Do
	  Local $charStart = -1, $charEnd = -1

	  ; Find start of char
	  Local $blankCol, $blankColCount = 0
	  Do
		 $blankCol = True
		 For $by = 0 To $pY-1
			If $pix[$x][$by] = 1 Then $blankCol = False
		 Next

		 If $blankCol = True Then
			$x+=1
			$blankColCount+=1

			; add a space if multiple blank columns are detected
			If $blankColCount=3 And StringLen($textString)>0 And $keepSpaces=$eScrapeKeepSpaces Then $textString &= " "
		 EndIf
	  Until $blankCol = False Or $x > $w-1

	  If $blankCol = False Then
		 $charStart = $x
		 $charEnd = $charStart
	  EndIf

	  ; Find end of char
	  If $charStart <> -1 Then
		 $charEnd = ($charStart+$maxCharSize > $w-1) ? $w-1 : $charStart+$maxCharSize
	  EndIf

	  ; Find exact match with greatest width
	  Local $largestMatchIndex=-1
	  If $charStart <> -1 Then
		 Local $testWidth
		 For $testWidth = 1 To $charEnd-$charStart+1
			; Find the first non blank row, starting from the bottom
			Local $cX, $cY, $bottomOfChar = -1
			For $cY = $pY-1 To 0 Step -1
			   For $cX = $charStart To $charStart+$testWidth-1
				  If $pix[$cX][$cY] = 1 Then
					 $bottomOfChar = $cY
					 ExitLoop
				  EndIf
			   Next
			   If $bottomOfChar <> -1 Then ExitLoop
			Next

			; Calculate colValues for this character
			Local $colValues[$testWidth]
			For $cX = $charStart To $charStart+$testWidth-1
			   Local $factor = 1
			   $colValues[$cX-$charStart] = 0
			   For $cY = $bottomOfChar To 0 Step -1
				  $colValues[$cX-$charStart] += ($pix[$cX][$cY] * $factor)
				  $factor*=2
			   Next
			Next

			; Find a match
			Local $bestMatchIndex = FindExactCharInArray($charMapArray, $colValues, $testWidth)
			If $bestMatchIndex <> -1 Then $largestMatchIndex = $bestMatchIndex
		 Next
	  EndIf

	  ; Debug
	  If $gScraperDebug And $charEnd<>-1 Then
		 ConsoleWrite($charStart & " to " & _
						($largestMatchIndex<>-1 ? $charStart+$charMapArray[$largestMatchIndex][1]-1 : $charStart) & ": " & _
						($largestMatchIndex<>-1 ? $charMapArray[$largestMatchIndex][0] : "`" ) & " : ")
		 For $cX = $charStart To ($largestMatchIndex<>-1 ? $charStart+$charMapArray[$largestMatchIndex][1]-1 : $charStart)
			ConsoleWrite($colValues[$cX-$charStart] & ", ")
		 Next
		 ConsoleWrite(@CRLF)
	  EndIf

	  ; Got a match or not?
	  If $largestMatchIndex <> -1 Then
		 $textString &= $charMapArray[$largestMatchIndex][0]
		 $x = $charStart+$charMapArray[$largestMatchIndex][1]
	  ElseIf $charEnd<>-1 Then
		 ;$textString &= "?"
		 $x += 1
	  EndIf

   Until $x > $w-1

   $textString = StringStripWS($textString, $STR_STRIPTRAILING)

   ; Debug
   If $gScraperDebug Then
	  ConsoleWrite($textString & @CRLF)
	  ConsoleWrite("-------------------------------------------------------------------------" & @CRLF)
	  For $y = 0 To $pY-1
		ConsoleWrite("|")
		 For $x = 0 To $w-1
			If $pix[$x][$y] = 1 Then
			   ConsoleWrite("x")
			Else
			   ConsoleWrite(" ")
			EndIf
		 Next
		 ConsoleWrite("|" & @CRLF)
	  Next
	  ConsoleWrite("-------------------------------------------------------------------------" & @CRLF)
   EndIf

   Return $textString
EndFunc

Func GetForegroundPixels(Const $frame, Const ByRef $textBox, ByRef $pix, ByRef $rows)

   $rows = 0

   Local $y
   For $y = $textBox[1] To $textBox[3]

	  ; See if this line contains valid pixels
	  Local $BlankLine = True
	  Local $x
	  For $x = $textBox[0] To $textBox[2]
		 Local $pixelColor = _GDIPlus_BitmapGetPixel($frame, $x, $y)

		 If InColorSphere($pixelColor, $textBox[4], $textBox[5]) = True Then
			$BlankLine = False
			ExitLoop
		 EndIf
	  Next

	  If $BlankLine = False Then
		 Local $x
		 For $x = $textBox[0] To $textBox[2]
			Local $pixelColor = _GDIPlus_BitmapGetPixel($frame, $x, $y)

			If InColorSphere($pixelColor, $textBox[4], $textBox[5]) = True Then
			   $pix[$x-$textBox[0]][$rows] = 1
			Else
			   $pix[$x-$textBox[0]][$rows] = 0
			EndIf
		 Next
		 $rows+=1
	  EndIf
   Next
EndFunc

Func FindFuzzyCharInArray(Const ByRef $charMapArray, Const ByRef $nums, Const $width, ByRef $bestWeightedHD)
   ; Loop through each row in the $charMapArray array
   Local $bestMatch = -1
   $bestWeightedHD = 9999
   For $i = 0 To UBound($charMapArray)-1

	  If $charMapArray[$i][1] >= $width-1 And $charMapArray[$i][1] <= $width+1 Then

		 ; Loop through each column in the passed in array of numbers
		 Local $c, $totalHD = 0, $pixels = 0
		 For $c = 0 To ($width < $charMapArray[$i][1] ? $width-1 : $charMapArray[$i][1]-1)
			$totalHD += CalcHammingDistance($nums[$c], $charMapArray[$i][$c+2])
			$pixels += BitCount($nums[$c])
		 Next

		 Local $weightedHD = $totalHD / $pixels

		 If $weightedHD < $bestWeightedHD Then
			$bestWeightedHD = $weightedHD
			$bestMatch = $i
		 EndIf
	  EndIf
   Next

   ; Debug
   ;DebugWrite("Best " & $bestMatch & " " & $bestWeightedHD & @CRLF)

   Return $bestMatch
EndFunc

Func FindExactCharInArray(Const ByRef $charMapArray, Const ByRef $nums, Const $count)
   ; Loop through each row in the $charMapArray array
   Local $bestMatch = -1
   For $i = 0 To UBound($charMapArray)-1

	  ; If number of columns match, then check the colvalues
	  If $count = $charMapArray[$i][1] Then

		 ; Loop through each column in the passed in array of numbers
		 Local $c, $match=True
		 For $c = 0 To $count-1
			If $nums[$c] <> $charMapArray[$i][$c+2] Then
			   $match = False
			   ExitLoop
			EndIf
		 Next

		 If $match Then
			$bestMatch = $i
			ExitLoop
		 EndIf
	  EndIf
   Next

   Return $bestMatch
EndFunc

Func CalcHammingDistance(Const $x, Const $y)
   Local $dist = 0, $val = BitXOR($x, $y)

   While $val <> 0
	  $dist += 1
	  $val = BitAND($val, $val-1)
   WEnd

   Return $dist;
EndFunc

Func BitCount($n)
   Local $c = 0

   While $n <> 0
	  $c += 1
	  $n = BitAND($n, $n-1)
   WEnd

   Return $c
EndFunc

Func GetTownHallLevel(Const $x1 = -1, Const $y1 = -1, Const $x2 = -1, Const $y2 = -1)
   DebugWrite("GetTownHallLevel()")

   ; Method = 0: CV_TM_SQDIFF, 1: CV_TM_SQDIFF_NORMED, 2: CV_TM_CCORR, 3: CV_TM_CCORR_NORMED
   ;          4: CV_TM_CCOEFF, 5: CV_TM_CCOEFF_NORMED

   ; Returns best TH level match, 0 if no good match
   Local $bestMatch = 99, $bestConfidence = 0, $bestX = 0, $bestY = 0

   ; Grab and scan frame
   If $x1 = -1 Then
	   ; full frame
	  GrabFrameToFile("TownHallCenterFrame.bmp")
   Else
	  ; Partial frame for Snipable TH search
	  GrabFrameToFile("TownHallCenterFrame.bmp", $x1, $y1, $x2, $y2)
   EndIf

   ScanFrameForBestBMP("TownHallCenterFrame.bmp", $TownHallBMPs, $gConfidenceTownHall, $bestMatch, $bestConfidence, $bestX, $bestY)

   If $x1 = -1 Then
	  ; No good match, scan top of screen
	  If $bestMatch = 99 Then
		 ZoomOut(False)
		 MoveScreenDownToTop(False)
		 GrabFrameToFile("TownHallTopFrame.bmp")
		 MoveScreenUpToCenter()
		 ScanFrameForBestBMP("TownHallTopFrame.bmp", $TownHallBMPs, $gConfidenceTownHall, $bestMatch, $bestConfidence, $bestX, $bestY)
	  EndIf

	  ; No good match, scan bottom of screen
	  If $bestMatch = 99 Then
		 MoveScreenUpToBottom(False)
		 GrabFrameToFile("TownHallBotFrame.bmp")
		 MoveScreenDownToCenter()
		 ScanFrameForBestBMP("TownHallBotFrame.bmp", $TownHallBMPs, $gConfidenceTownHall, $bestMatch, $bestConfidence, $bestX, $bestY)
	  EndIf
   EndIf

   If $bestMatch = 99 Then
	  ;DebugWrite("Unknown TH Level" & @CRLF)
	  Return 0
   Else
	  ;DebugWrite("Likely TH Level " & $bestMatch+7 & @CRLF)
	  Return $bestMatch+7
   EndIf
EndFunc

Func IsTextBoxPresent(Const ByRef $textBox)
   Local $cPos = GetClientPos()
   Local $pixelColor = PixelGetColor($cPos[0]+$textBox[6], $cPos[1]+$textBox[7])

   Return InColorSphere($pixelColor, $textBox[8], $textBox[9])
EndFunc

Func IsButtonPresent(Const ByRef $buttonBox)
   Local $cPos = GetClientPos()
   Local $pixelColor = PixelGetColor($cPos[0]+$buttonBox[4], $cPos[1]+$buttonBox[5])

   Return InColorSphere($pixelColor, $buttonBox[6], $buttonBox[7])
EndFunc

Func IsColorPresent(Const ByRef $colorLocation)
   Local $cPos = GetClientPos()
   Local $pixelColor = PixelGetColor($cPos[0]+$colorLocation[0], $cPos[1]+$colorLocation[1])

   Return InColorSphere($pixelColor, $colorLocation[2], $colorLocation[3])
EndFunc

Func ScanFrameForBestBMP(Const $filename, Const ByRef $bmpArray, Const $threshold, ByRef $bestMatch, ByRef $bestConfidence, ByRef $bestX, ByRef $bestY)
   For $i = 0 to UBound($bmpArray)-1
	  Local $res = DllCall("ImageMatch.dll", "str", "FindMatch", "str", $filename, "str", "Images\"&$bmpArray[$i], "int", 3)

	  ;DebugWrite($bmpArray[$i] & ": " & $res[0] & @CRLF)

	  Local $split = StringSplit($res[0], "|", 2)
	  If $split[2] > $threshold And $split[2] > $bestConfidence Then
		 $bestX = $split[0]
		 $bestY = $split[1]
		 $bestConfidence = $split[2]
		 $bestMatch = $i
	  EndIf
   Next
EndFunc

Func InColorSphere(Const $color, Const $center, Const $radius)
   Local $r = BitShift(BitAND($color, 0x00FF0000), 16)
   Local $g = BitShift(BitAND($color, 0x0000FF00), 8)
   Local $b = BitAND($color, 0x000000FF)

   Local $rC = BitShift(BitAND($center, 0x00FF0000), 16)
   Local $gC = BitShift(BitAND($center, 0x0000FF00), 8)
   Local $bC = BitAND($center, 0x000000FF)

   Local $d = Sqrt( ($rC-$r)^2 + ($gC-$g)^2 + ($bC-$b)^2 )

   If $d <= $radius Then Return True

   Return False
EndFunc

Func DistBetweenTwoPoints(Const $x1, Const $y1, Const $x2, Const $y2)
  Return Sqrt( ($x1-$x2)^2 + ($y1-$y2)^2 )
EndFunc

; Returns the absolute position of the client window
Func GetClientPos()
   Local $cPos[4]

   ; Get absolute coordinates of client area
   Local $hWnd = WinGetHandle($gTitle)
   Local $cSize = WinGetClientSize($gTitle)

   Local $tPoint = DllStructCreate("int X;int Y")
   DllStructSetData($tPoint, "X", 0)
   DllStructSetData($tPoint, "Y", 0)

   _WinAPI_ClientToScreen($hWnd, $tPoint)
   $cPos[0] = DllStructGetData($tPoint, "X")
   $cPos[1] = DllStructGetData($tPoint, "Y")
   $cPos[2] = $cPos[0]+$cSize[0]-1
   $cPos[3] = $cPos[1]+$cSize[1]-1

   Return $cPos
EndFunc

Func GrabFrameToFile(Const $filename, $x1=-1, $y1=-1, $x2=-1, $y2=-1)
   Local $cPos = GetClientPos()
   Local $hBitmap

   If $x1 = -1 Then
	  $hBitmap = _ScreenCapture_Capture("", $cPos[0], $cPos[1], $cPos[2], $cPos[3], False)
   Else
	  $hBitmap = _ScreenCapture_Capture("", $cPos[0]+$x1, $cPos[1]+$y1, $cPos[0]+$x2, $cPos[1]+$y2, False)
   EndIf

   Local $frame = _GDIPlus_BitmapCreateFromHBITMAP($hBitmap)
   _GDIPlus_ImageSaveToFile($frame, $filename)
   _GDIPlus_BitmapDispose($frame)
   _WinAPI_DeleteObject($hBitmap)
EndFunc
