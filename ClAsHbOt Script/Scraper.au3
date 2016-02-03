Func InitScraper()
   _GDIPlus_Startup()
EndFunc

Func ExitScraper()
   _GDIPlus_Shutdown()
   DebugWrite("ExitScraper() Scraper shut down")
EndFunc

Func ScrapeFuzzyText2(Const $type, Const $textBox)
   Local $hHBITMAP = CaptureFrameHBITMAP("ScrapeFuzzyText2" & $gFontNames[$type], $textBox[0], $textBox[1], $textBox[2], $textBox[3])
   If $gDebugSaveScreenCaptures Then SaveDebugHBITMAP($hHBITMAP, "ScrapeFuzzyText2" & $gFontNames[$type] & "Frame.bmp")
   Local $res = DllCall($gDllHandle, "str", "ScrapeFuzzyText", "handle", $hHBITMAP, "int", $type, "uint", $textBox[4], "uint", $textBox[5], "bool", False)
   _WinAPI_DeleteObject($hHBITMAP)

   If @error Then
	  DebugWrite("ScrapeFuzzyText2() " & $gFontNames[$type] & " DllCall @error=" & @error)
	  MsgBox(BitOR($MB_ICONERROR, $MB_OK), "ImageMatch DLL Error", "Error with DLL, ScrapeFuzzyText" & @CRLF & _
		 "This is catastrophic, exiting.")
	  Exit
   EndIf

   ;DebugWrite("My " & $type & ": " & $res[0])

   Return $res[0]
EndFunc

; Non fuzzy character matching - only good for chat box right now
Func ScrapeExactText(Const $frame, Const ByRef $charMapArray, Const ByRef $box, Const $maxCharSize, Const $keepSpaces)
   Local $w = $box[2] - $box[0] + 1
   Local $h = $box[3] - $box[1] + 1
   Local $pix[$w][$h]
   Local $pY

   ; Get map of foreground pixels
   GetForegroundPixels($frame, $box, $pix, $pY)

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
	  ConsoleWrite("RESULT: " & $textString & @CRLF)
	  ConsoleWrite("-------------------------------------------------------------------------" & @CRLF)
   EndIf

   Return $textString
EndFunc

Func GetForegroundPixels(Const $frame, Const ByRef $box, ByRef $pix, ByRef $rows)
   $rows = 0

   If $gScraperDebug Then ConsoleWrite("-------------------------------------------------------------------------" & @CRLF)

   For $y = $box[1] To $box[3]

	  ; See if this line contains valid pixels
	  Local $BlankLine = True
	  For $x = $box[0] To $box[2]
		 Local $pixelColor = _GDIPlus_BitmapGetPixel($frame, $x, $y)
		 If InColorSphere($pixelColor, $box[4], $box[5]) = True Then
			$BlankLine = False
			ExitLoop
		 EndIf
	  Next

	  If $BlankLine = False Then
		 For $x = $box[0] To $box[2]
			Local $pixelColor = _GDIPlus_BitmapGetPixel($frame, $x, $y)

			If InColorSphere($pixelColor, $box[4], $box[5]) = True Then
			   $pix[$x-$box[0]][$rows] = 1
			Else
			   $pix[$x-$box[0]][$rows] = 0
			EndIf
		 Next

		 If $gScraperDebug Then
			For $x = $box[0] To $box[2]
			   If $pix[$x-$box[0]][$rows] = 1 Then
				  ConsoleWrite("x")
			   Else
				  ConsoleWrite(" ")
			   EndIf
			Next
			ConsoleWrite(@CRLF)
		 EndIf

		 $rows+=1
	  EndIf
   Next

   If $gScraperDebug Then ConsoleWrite("-------------------------------------------------------------------------" & @CRLF)
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

Func IsTextBoxPresent(Const $frame, Const ByRef $textBox)
   Local $pixelColor = _GDIPlus_BitmapGetPixel($frame, $textBox[6], $textBox[7])
   Return InColorSphere($pixelColor, $textBox[8], $textBox[9])
EndFunc

Func IsButtonPresent(Const $frame, Const ByRef $buttonBox)
   Local $pixelColor = _GDIPlus_BitmapGetPixel($frame, $buttonBox[4], $buttonBox[5])
   Return InColorSphere($pixelColor, $buttonBox[6], $buttonBox[7])
EndFunc

Func IsColorPresent(Const $frame, Const ByRef $colorLocation)
   Local $pixelColor = _GDIPlus_BitmapGetPixel($frame, $colorLocation[0], $colorLocation[1])
   Return InColorSphere($pixelColor, $colorLocation[2], $colorLocation[3])
EndFunc

Func WaitForButton(ByRef $f, Const $wait, Const $b1, Const $b2=0, Const $b3=0)
   Local $t = TimerInit()
   Local $p1 = IsButtonPresent($f, $b1)
   Local $p2 = $b2=0 ? False : IsButtonPresent($f, $b2)
   Local $p3 = $b3=0 ? False : IsButtonPresent($f, $b3)
   Local $lastTimeRem = Round($wait/1000)
   _GDIPlus_BitmapDispose($f)
   $f = CaptureFrame("WaitForButton " & $lastTimeRem)

   While TimerDiff($t)<$wait And $p1=False And $p2=False And $p3=False
	  If IsButtonPresent($f, $rAndroidMessageButton1) Or IsButtonPresent($f, $rAndroidMessageButton2) Then
		 Return SetError($eErrorAndroidMessageBox, 0, False)
	  EndIf

	  If IsColorPresent($f, $rWaitForPersonalBreakPoint1Color) And _
		 IsColorPresent($f, $rWaitForPersonalBreakPoint2Color) And _
		 IsColorPresent($f, $rWaitForPersonalBreakPoint3Color) Then

		 Return SetError($eErrorAttackingDisabled, 0, False)
	  EndIf

	  Local $timeRem = Round(($wait-TimerDiff($t))/1000)
	  If $timeRem<>$lastTimeRem Then
		 $lastTimeRem = $timeRem
		 _GDIPlus_BitmapDispose($f)
		 $f = CaptureFrame("WaitForButton " & $lastTimeRem)

		 $p1 = IsButtonPresent($f, $b1)
		 $p2 = $b2=0 ? False : IsButtonPresent($f, $b2)
		 $p3 = $b3=0 ? False : IsButtonPresent($f, $b3)
	  EndIf

	  Sleep(100)
   WEnd

   If $p1=False And $p2=False And $p3=False Then
	  Return False
   Else
	  Return True
   EndIf
EndFunc

Func WaitForColor(ByRef $f, Const $wait, Const $c1, Const $c2=0, Const $c3=0)
   Local $t = TimerInit()
   Local $p1 = IsColorPresent($f, $c1)
   Local $p2 = $c2=0 ? False : IsColorPresent($f, $c2)
   Local $p3 = $c3=0 ? False : IsColorPresent($f, $c3)
   Local $lastTimeRem = Round($wait/1000)
   _GDIPlus_BitmapDispose($f)
   $f = CaptureFrame("WaitForColor " & $lastTimeRem)

   While TimerDiff($t)<$wait And $p1=False And $p2=False And $p3=False
	  If IsButtonPresent($f, $rAndroidMessageButton1) Or IsButtonPresent($f, $rAndroidMessageButton2) Then
		 Return SetError($eErrorAndroidMessageBox, 0, False)
	  EndIf

	  If IsColorPresent($f, $rWaitForPersonalBreakPoint1Color) And _
		 IsColorPresent($f, $rWaitForPersonalBreakPoint2Color) And _
		 IsColorPresent($f, $rWaitForPersonalBreakPoint3Color) Then

		 Return SetError($eErrorAttackingDisabled, 0, False)
	  EndIf

	  Local $timeRem = Round(($wait-TimerDiff($t))/1000)
	  If $timeRem<>$lastTimeRem Then
		 $lastTimeRem = $timeRem
		 _GDIPlus_BitmapDispose($f)
		 $f = CaptureFrame("WaitForColor " & $timeRem)
		 $p1 = IsColorPresent($f, $c1)
		 $p2 = $c2=0 ? False : IsColorPresent($f, $c2)
		 $p3 = $c3=0 ? False : IsColorPresent($f, $c3)
	  EndIf

	  Sleep(100)
   WEnd

   If $p1=False And $p2=False And $p3=False Then
	  Return False
   Else
	  Return True
   EndIf
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

Func FindBestBMP(Const $searchType, ByRef $left, ByRef $top, ByRef $conf)
   ; Get frame
   Local $box[4], $thresh
   If $searchType = $eSearchTypeTownHall Then
	  $box[0] = $gWestPoint[0]
	  $box[1] = $gNorthPoint[1]-10
	  $box[2] = $gEastPoint[0]
	  $box[3] = $gSouthPoint[1]
	  $thresh = $gConfidenceTownHall

   ElseIf $searchType = $eSearchTypeLootCart Then
	  $box[0] = $gWestPoint[0]
	  $box[1] = $gNorthPoint[1]-10
	  $box[2] = $gEastPoint[0]
	  $box[3] = $gSouthPoint[1]
	  $thresh = $gConfidenceLootCart

   ElseIf $searchType=$eSearchClashIcon Then
	  $box[0] = 0
	  $box[1] = 0
	  $box[2] = $gBlueStacksWidth
	  $box[3] = $gBlueStacksHeight
	  $thresh = $gConfidenceClashIcon

   ElseIf $searchType=$eSearchPlayStoreOpenButton Then
	  $box[0] = 0
	  $box[1] = 0
	  $box[2] = $gBlueStacksWidth
	  $box[3] = $gBlueStacksHeight
	  $thresh = $gConfidencePlayStoreOpenButton

   ElseIf $searchType=$eSearchTypeGoldStorage Or $searchType=$eSearchTypeElixStorage Or $searchType=$eSearchTypeDarkStorage Then
	  $box[0] = $gScreenCenter[0]-150
	  $box[1] = $gScreenCenter[1]-150
	  $box[2] = $gScreenCenter[0]+150
	  $box[3] = $gScreenCenter[1]+150
	  $thresh = $gConfidenceStorages

   Else
	  DebugWrite("FindBestBMP() Error, searchType not recognized: " & $searchType)
	  Return

   EndIf

   Local $hHBITMAP = CaptureFrameHBITMAP("FindBestBMP" & $gSearchTypeNames[$searchType], $box[0], $box[1], $box[2], $box[3])
   If $gDebugSaveScreenCaptures Then SaveDebugHBITMAP($hHBITMAP, "FindBestBMP" & $gSearchTypeNames[$searchType] & "Frame.bmp")
   Local $res = DllCall($gDllHandle, "str", "FindBestBMP", "int", $searchType, "handle", $hHBITMAP, "double", $thresh)
   ;DebugWrite("FindBestBMP() $res[0]=" & $res[0])

   If @error Then
	  DebugWrite("FindBestBMP() " & $gSearchTypeNames[$searchType] & " DllCall @error=" & @error)
	  MsgBox(BitOR($MB_ICONERROR, $MB_OK), "ImageMatch DLL Error", "Error with DLL, FindBestBMP" & @CRLF & _
		 "This is catastrophic, exiting.")
	  Exit
   EndIf

   Local $split = StringSplit($res[0], "|", 2)
   If $split[1]<> -1 Then
	  $left = Number($split[1] + $box[0])
	  $top = Number($split[2] + $box[1])
	  $conf = Number($split[3])
	  ;DebugWrite("FindBestBMP() " & $gSearchTypeNames[$SearchType] & " " & $left & "," & $top & " conf: " & $conf)
   Else
	  $left = -1
	  $top = -1
	  $conf = Number($split[3])
   EndIf

   _WinAPI_DeleteObject($hHBITMAP)

   If $searchType = $eSearchTypeTownHall Then
	  If $split[1] = -1 Then
		 Return -1
	  Else
		 Local $a = StringInStr($split[0], "TH")
		 Local $b = StringInStr($split[0], ".bmp")
		 Local $c = StringMid($split[0], $a+2, $b-$a-2)
		 Return Number($c)
	  EndIf
   Else
	  Return $split[0]
   EndIf
EndFunc

Func FindAllBMPs(Const $searchType, Const $maxMatch, ByRef $matchX, ByRef $matchY, ByRef $confs)
   Local $box[4], $thresh
   If $searchType=$eSearchTypeGoldStorage Or $searchType=$eSearchTypeElixStorage Or $searchType=$eSearchTypeDarkStorage Then
	  $box[0] = $gScreenCenter[0]-150
	  $box[1] = $gScreenCenter[1]-150
	  $box[2] = $gScreenCenter[0]+150
	  $box[3] = $gScreenCenter[1]+150
	  $thresh = $gConfidenceStorages

   ElseIf $searchType = $eSearchTypeLootCollector Then
	  $box[0] = $gWestPoint[0]
	  $box[1] = $gNorthPoint[1]-10
	  $box[2] = $gEastPoint[0]
	  $box[3] = $gSouthPoint[1]
	  $thresh = $gConfidenceCollector

   ElseIf $searchType = $eSearchTypeLootBubble Then
	  $box[0] = $gWestPoint[0]
	  $box[1] = $gNorthPoint[1]
	  $box[2] = $gEastPoint[0]
	  $box[3] = $gSouthPoint[1]
	  $thresh = $gConfidenceCollectLoot

   ElseIf $searchType = $eSearchDonateButton Then
	  For $i=0 To 3
		 $box[$i] = $rChatBox[$i]
	  Next
	  $thresh = $gConfidenceDonateButton

   Else
	  DebugWrite("FindAllBMPs() Error, searchType not recognized: " & $searchType)
	  Return

   EndIf

   Local $hHBITMAP = CaptureFrameHBITMAP("FindAllBMPs" & $gSearchTypeNames[$searchType], $box[0], $box[1], $box[2], $box[3])
   If $gDebugSaveScreenCaptures Then SaveDebugHBITMAP($hHBITMAP, "FindAllBMPs" & $gSearchTypeNames[$searchType] & "Frame.bmp")
   Local $res = DllCall($gDllHandle, "str", "FindAllBMPs", "int", $searchType, "handle", $hHBITMAP, "double", $thresh, "int", $maxMatch)
   ;DebugWrite("FindAllBMPs() $res[0]=" & $res[0])

   If @error Then
	  DebugWrite("FindAllBMPs() DllCall @error=" & @error)
	  MsgBox(BitOR($MB_ICONERROR, $MB_OK), "ImageMatch DLL Error", "Error with DLL, FindAllBMPs" & @CRLF & _
		 "This is catastrophic, exiting.")
	  Exit
   EndIf

   Local $split = StringSplit($res[0], "|", 2)
   Local $matchCount = $split[0]
   ;DebugWrite("Num matches " & $gSearchTypeNames[$searchType] & ": " & $matchCount)

   ReDim $matchX[$matchCount]
   ReDim $matchY[$matchCount]
   ReDim $confs[$matchCount]

   For $j = 0 To $split[0]-1
	  $matchX[$j] = $split[$j*3+1] + $box[0]
	  $matchY[$j] = $split[$j*3+2] + $box[1]
	  $confs[$j] = $split[$j*3+3]
   Next

   _WinAPI_DeleteObject($hHBITMAP)
   Return $matchCount
EndFunc

Func FindTopOfDonateBox()
   Local $frame = CaptureFrame("FindTopOfDonateBox")
   Local $topDonateBox = -1
   For $i = 0 To 300
	  Local $c[4] = [650, $i, 0xFFFFFF, 0]
	  If IsColorPresent($frame, $c) Then
		 $topDonateBox = $i
		 ExitLoop
	  EndIf
   Next
   _GDIPlus_BitmapDispose($frame)

   Return $topDonateBox
EndFunc

Func LocateSlots(Const $actionType, Const $slotType, ByRef $index)
   ; Get frame
   Local $box[4], $thresh
   If $actionType = $eActionTypeRaid Then
	  For $i=0 To 3
		 $box[$i] = $rRaidTroopBox[$i]
	  Next
	  $thresh = $gConfidenceRaidTroopSlot

   ElseIf $actionType = $eActionTypeDonate Then
	  Local $topDonateBox = FindTopOfDonateBox()
	  If $topDonateBox = -1 Then
		 DebugWrite("LocateSlots() for Donate failed - cound not find top of donate troops window")
		 Return
	  EndIf
	  $box[0] = ($slotType = $eSlotTypeTroop ? $rDonateTroopsBox[0] : $rDonateSpellsBox[0])
	  $box[1] = ($slotType = $eSlotTypeTroop ? $rDonateTroopsBox[1] : $rDonateSpellsBox[1]) + $topDonateBox
	  $box[2] = ($slotType = $eSlotTypeTroop ? $rDonateTroopsBox[2] : $rDonateSpellsBox[2])
	  $box[3] = ($slotType = $eSlotTypeTroop ? $rDonateTroopsBox[3] : $rDonateSpellsBox[3]) + $topDonateBox
	  $thresh = $gConfidenceDonateTroopSlot

   ElseIf $actionType = $eActionTypeBarracks Then
	  For $i=0 To 3
		  $box[$i] = $rBarracksTroopBox[$i]
	  Next
	  $thresh = $gConfidenceBarracksTroopSlot

   ElseIf $actionType = $eActionTypeCamp And $slotType = $eSlotTypeTroop Then
	  For $i=0 To 3
		  $box[$i] = $rCampTroopBox1[$i]
	  Next
	  $thresh = $gConfidenceArmyCamp

   ElseIf $actionType = $eActionTypeCamp And $slotType = $eSlotTypeHero Then
	  For $i=0 To 3
		  $box[$i] = $rCampTroopBox2[$i]
	  Next
	  $thresh = $gConfidenceArmyCamp

   ElseIf $actionType = $eActionTypeReloadButton Then
	  For $i=0 To 3
		 $box[$i] = $rReloadDefensesBox[$i]
	  Next
	  $thresh = $gConfidenceReloadButton

   Else
	  DebugWrite("FindAllBMPs() Error, actionType/slotType not recognized: " & $actionType)
	  Return

   EndIf

   Local $hHBITMAP = CaptureFrameHBITMAP("LocateSlots" & $gActionTypeNames[$actionType] & $gSlotTypeNames[$slotType], _
	  $box[0], $box[1], $box[2], $box[3])
   If $gDebugSaveScreenCaptures Then SaveDebugHBITMAP($hHBITMAP, _
	  "LocateSlots" & $gActionTypeNames[$actionType] & $gSlotTypeNames[$slotType] & "Frame.bmp")
   Local $res = DllCall($gDllHandle, "str", "LocateSlots", "int", $actionType, "int", $slotType, "handle", $hHBITMAP, "double", $thresh)
   ;DebugWrite("DLL $res=" & $res[0])

   If @error Then
	  DebugWrite("LocateSlots() DllCall @error=" & @error)
	  MsgBox(BitOR($MB_ICONERROR, $MB_OK), "ImageMatch DLL Error", "Error with DLL, LocateSlots" & @CRLF & _
		 "This is catastrophic, exiting.")
	  Exit
   EndIf

   Local $split = StringSplit($res[0], "|", 2)
   ;DebugWrite("Num matches " & $gActionTypeNames[$actionType] & $gSlotTypeNames[$slotType] & ": " & $split[0])

   For $i = 0 To $split[0]-1
	  Local $x = Number($split[$i*3+1])
	  Local $y = Number($split[$i*3+2])
	  Local $conf = Number($split[$i*3+3])

	  If $actionType = $eActionTypeRaid Then
		 If $index[$i][0]=-1 And $x<>-1 Then
			$index[$i][0] = $box[0] + $x + $rRaidButtonOffset[0]
			$index[$i][1] = $box[1] + $y + $rRaidButtonOffset[1]
			$index[$i][2] = $box[0] + $x + $rRaidButtonOffset[2]
			$index[$i][3] = $box[1] + $y + $rRaidButtonOffset[3]
			;DebugWrite("Raid " & $gSlotTypeNames[$slotType] & " " & (($slotType=$eSlotTypeTroop) ? $gTroopNames[$i] : $gSpellNames[$i]) & " found, confidence " & Round($conf*100, 2) & "%" & _
			 ;  " box: " & $index[$i][0] & "," & $index[$i][1] & "," & $index[$i][2] & "," & $index[$i][3])
		 EndIf

	  ElseIf $actionType = $eActionTypeDonate Then
		 If $x<>-1 Then
			Local $iP = ($slotType=$eSlotTypeTroop ? $i : $eSpellPoison+$i)
			   $index[$iP][0] = $box[0] + $x + $rDonateButtonOffset[0]
			   $index[$iP][1] = $box[1] + $y + $rDonateButtonOffset[1]
			   $index[$iP][2] = $box[0] + $x + $rDonateButtonOffset[2]
			   $index[$iP][3] = $box[1] + $y + $rDonateButtonOffset[3]
			DebugWrite("Donate " & $gSlotTypeNames[$slotType] & " " & (($slotType=$eSlotTypeTroop) ? $gTroopNames[$iP] : $gSpellNames[$iP]) & " found, confidence " & Round($conf*100, 2) & "%" & _
				  " box: " & $index[$iP][0] & "," & $index[$iP][1] & "," & $index[$iP][2] & "," & $index[$iP][3])
		 EndIf

	  ElseIf $actionType = $eActionTypeBarracks Then
		 If $x<>-1 Then
			$index[$i][0] = $box[0] + $x + $rRaidButtonOffset[0]
			$index[$i][1] = $box[1] + $y + $rRaidButtonOffset[1]
			$index[$i][2] = $box[0] + $x + $rRaidButtonOffset[2]
			$index[$i][3] = $box[1] + $y + $rRaidButtonOffset[3]
		 EndIf

	  ElseIf $actionType = $eActionTypeCamp Then
		 If $x<>-1 Then
			$index[$i][0] = $box[0] + $x
			$index[$i][1] = $box[1] + $y
			$index[$i][2] = $box[0] + $x
			$index[$i][3] = $box[1] + $y
		 EndIf

	  ElseIf $actionType = $eActionTypeReloadButton Then
		 If $x<>-1 Then
			$index[$i][0] = $box[0] + $x + $rReloadDefensesButtonOffset[0]
			$index[$i][1] = $box[1] + $y + $rReloadDefensesButtonOffset[1]
			$index[$i][2] = $box[0] + $x + $rReloadDefensesButtonOffset[2]
			$index[$i][3] = $box[1] + $y + $rReloadDefensesButtonOffset[3]
		 EndIf

	  EndIf
   Next

   _WinAPI_DeleteObject($hHBITMAP)
   Return $split[0]
EndFunc

Func CaptureFrame(Const $fromFunc, $x1=0, $y1=0, $x2=$gBlueStacksWidth, $y2=$gBlueStacksHeight)
   Local $backgroundMode = _GUICtrlButton_GetCheck($GUI_BackgroundModeCheckBox)

   If $gDebugLogCallsToCaptureFrame = True Then
	  DebugWrite("CaptureFrame() from " & $fromFunc & ($backgroundMode ? " (background)" : " (foreground)"))
   EndIf

   Local $hGdipBitmap

   If $backgroundMode Then
	  Local $hDC = _WinAPI_GetWindowDC($gBlueStacksControlHwnd)
	  Local $memDC = _WinAPI_CreateCompatibleDC($hDC)
	  Local $hHBITMAP = _WinAPI_CreateCompatibleBitmap($hDC, $x2-$x1, $y2-$y1)
	  Local $bmpOriginal  = _WinAPI_SelectObject($memDC, $hHBITMAP)

	  DllCall("user32.dll", "int", "PrintWindow", "hwnd", $gBlueStacksControlHwnd, "handle", $memDC, "int", 0)
	  _WinAPI_SelectObject($memDC, $hHBITMAP)
	  _WinAPI_BitBlt($memDC, 0, 0, $x2-$x1+1, $y2-$y1+1, $hDC, $x1, $y1, $SRCCOPY)

	  $hGdipBitmap = _GDIPlus_BitmapCreateFromHBITMAP($hHBITMAP)
	  If $hGdipBitmap=0 Then
		 DebugWrite("RefreshFrame() Error creating bitmap @error=" & @error & " @extended=" & @extended)
	  EndIf

	  _WinAPI_DeleteObject($hHBITMAP)
	  _WinAPI_SelectObject($memDC, $bmpOriginal)
	  _WinAPI_DeleteDC($memDC)
	  _WinAPI_ReleaseDC($gBlueStacksControlHwnd, $hDC)

   Else
	  Local $cPos = GetClientPos()
	  Local $hHBITMAP = _ScreenCapture_Capture("", $cPos[0]+$x1, $cPos[1]+$y1, $cPos[0]+$x2, $cPos[1]+$y2)
	  $hGdipBitmap = _GDIPlus_BitmapCreateFromHBITMAP($hHBITMAP)
	  _WinAPI_DeleteObject($hHBITMAP)

   EndIf

   Return $hGdipBitmap
EndFunc


Func CaptureFrameHBITMAP(Const $fromFunc, $x1=0, $y1=0, $x2=$gBlueStacksWidth, $y2=$gBlueStacksHeight)
   Local $backgroundMode = _GUICtrlButton_GetCheck($GUI_BackgroundModeCheckBox)

   If $gDebugLogCallsToCaptureFrame = True Then
	  DebugWrite("CaptureFrameHBITMAP() from " & $fromFunc & ($backgroundMode ? " (background)" : " (foreground)"))
   EndIf

   Local $hHBITMAP

   If $backgroundMode Then
	  Local $hDC = _WinAPI_GetWindowDC($gBlueStacksControlHwnd)
	  Local $memDC = _WinAPI_CreateCompatibleDC($hDC)
	  $hHBITMAP = _WinAPI_CreateCompatibleBitmap($hDC, $x2-$x1, $y2-$y1)
	  Local $bmpOriginal  = _WinAPI_SelectObject($memDC, $hHBITMAP)

	  DllCall("user32.dll", "int", "PrintWindow", "hwnd", $gBlueStacksControlHwnd, "handle", $memDC, "int", 0)
	  _WinAPI_SelectObject($memDC, $hHBITMAP)
	  _WinAPI_BitBlt($memDC, 0, 0, $x2-$x1+1, $y2-$y1+1, $hDC, $x1, $y1, $SRCCOPY)

	  _WinAPI_SelectObject($memDC, $bmpOriginal)
	  _WinAPI_DeleteDC($memDC)
	  _WinAPI_ReleaseDC($gBlueStacksControlHwnd, $hDC)

   Else
	  Local $cPos = GetClientPos()
	  Local $hHBITMAP = _ScreenCapture_Capture("", $cPos[0]+$x1, $cPos[1]+$y1, $cPos[0]+$x2, $cPos[1]+$y2)

   EndIf

   Return $hHBITMAP
EndFunc

Func SaveDebugImage(Const $hGdipBitmap, Const $filename)
   _GDIPlus_ImageSaveToFile($hGdipBitmap, $filename)
EndFunc

Func SaveDebugHBITMAP(Const $hHBITMAP, Const $filename)
   _ScreenCapture_SaveImage($filename, $hHBITMAP, False)
EndFunc

Func TestBackgroundScrape()
   Local $frame = CaptureFrame("TestBackGroundScrape")
   Local $w = _GDIPlus_ImageGetWidth($frame)
   Local $h = _GDIPlus_ImageGetHeight($frame)

   Local $notBlackPixel = False
   For $i = 1 To 100
	  Local $pix = _GDIPlus_BitmapGetPixel($frame, Random(0, $w-1, 1), Random(0, $h-1, 1))
	  ;DebugWrite($i & " 0x" & Hex(BitAND($pix, 0xffffff)))
	  If  BitAND($pix, 0xffffff) <> 0x000000 Then
		 $notBlackPixel = True
		 ExitLoop
	  EndIf
   Next

   _GDIPlus_BitmapDispose($frame)

   If $notBlackPixel = False Then
	  _GUICtrlButton_SetCheck($GUI_BackgroundModeCheckBox, False)

	  DebugWrite("TestBackgroundScrape() Background mode disabled")
	  Local $res = MsgBox(BitOR($MB_OK, $MB_ICONINFORMATION), "Background mode disabled", _
		 "Background mode has been disabled, as it appears to not be working." & @CRLF & @CRLF & _
		 "If you are running BlueStacks inside of another virtual machine, this may be the cause. " & _
		 "Since ClAsHbOt is now operating in the foreground, the BlueStacks window must be visible " & _
		 "and not obscured at any time.")

   Else
	  DebugWrite("TestBackgroundScrape() Background mode confirmed")

   EndIf
EndFunc

