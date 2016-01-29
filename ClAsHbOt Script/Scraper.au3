Func InitScraper()
   _GDIPlus_Startup()

   If $gBackgroundScraping = True Then
	  If TestBackGroundScrape() = False Then
		 $gBackgroundScraping = False

		 DebugWrite("InitScraper() Background scraping disabled")
		 Local $res = MsgBox(BitOR($MB_OK, $MB_ICONINFORMATION), "Background scraping disabled", _
			"Background scraping has been disabled, as it appears to not be working." & @CRLF & @CRLF & _
			"If you are running BlueStacks inside of another virtual machine, this may be the cause. " & _
			"For ClAsHbOt to work correctly in this situation, the BlueStacks window must be visible " & _
			"and not obscured at any time.")
	  Else
		 DebugWrite("InitScraper() Background scraping enabled")
	  EndIf
   EndIf
EndFunc

Func ExitScraper()
   _GDIPlus_Shutdown()
   DebugWrite("ExitScraper() Scraper shut down")
EndFunc

Func ScrapeFuzzyText(Const $frame, Const ByRef $charMapArray, Const ByRef $box, Const $maxCharSize, Const $keepSpaces)
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

			If $gScraperDebug Then ConsoleWrite("width=" & $testWidth & " index=" & $bestMatchIndex & " weight=" & Round($weight, 2) & "(bestweight=" & $bestWeight & ")" & @CRLF)
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
	  ConsoleWrite("RESULT: " & $textString & @CRLF)
	  ConsoleWrite("-------------------------------------------------------------------------" & @CRLF)
   EndIf

   Return $textString
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

	  If AttackingIsDisabled($f) Then
		 Return SetError($eErrorAttackingDisabled, 0, False)
	  EndIf

	  Local $timeRem = Round(($wait-TimerDiff($t))/1000)
	  If $timeRem<>$lastTimeRem Then
		 $lastTimeRem = $timeRem
		 _GDIPlus_BitmapDispose($f)
		 $f = CaptureFrame("WaitForButton " & $timeRem)
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

	  If AttackingIsDisabled($f) Then
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

Func AttackingIsDisabled(Const $f)
   If IsColorPresent($f, $rAttackingDisabledPoint1Color) And _
	  IsColorPresent($f, $rAttackingDisabledPoint2Color) And _
	  IsColorPresent($f, $rAttackingDisabledPoint3Color) Then Return True

   If IsColorPresent($f, $rWaitForPersonalBreakPoint1Color) And _
	  IsColorPresent($f, $rWaitForPersonalBreakPoint2Color) And _
	  IsColorPresent($f, $rWaitForPersonalBreakPoint3Color) Then Return True

   Return False
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

Func GetTownHallLevel(ByRef $left, ByRef $top)
   Local $frame = CaptureFrame("GetTownHallLevel", $gWestPoint[0], $gNorthPoint[1]-10, $gEastPoint[0], $gSouthPoint[1])
   _GDIPlus_ImageSaveToFile($frame, "temp.bmp")   ; temporary
   _GDIPlus_BitmapDispose($frame)

   Local $res = DllCall($gDllHandle, "str", "TownHallSearch", "str", "temp.bmp", "double", $gConfidenceTownHall)

   If @error Then
	  DebugWrite("GetTownHallLevel() DllCall @error=" & @error)
	  MsgBox(BitOR($MB_ICONERROR, $MB_OK), "ClAsHbOt DLL Error", "Error with DLL, TownHallSearch" & @CRLF & _
		 "This is catastrophic, exiting.")
	  Exit
   EndIf

   FileDelete("temp.bmp")  ; temporary

   Local $split = StringSplit($res[0], "|", 2)
   Local $thLevel = Number($split[0])
   $left = Number($split[1] + $gWestPoint[0])
   $top = Number($split[2] + $gNorthPoint[1]-10)
   ;DebugWrite("GetTownHallLevel() TH: " & $thLevel & " loc: " & $left & "," & $top & " conf: " & $split[3])

   Return $thLevel
EndFunc

Func FindBestStorage(Const $type, ByRef $left, ByRef $top, ByRef $conf)
   ; Type must be "gold", "elix", or "dark"
   Local $frame = CaptureFrame("TestStorage", $gScreenCenter[0]-150, $gScreenCenter[1]-150, $gScreenCenter[0]+150, $gScreenCenter[1]+150)
   _GDIPlus_ImageSaveToFile($frame, "temp.bmp")   ; temporary

   Local $res = DllCall($gDllHandle, "str", "FindBestStorage", "str", $type, "str", "temp.bmp", "double", $gConfidenceStorages)

   If @error Then
	  DebugWrite("FindBestStorage() DllCall @error=" & @error)
	  MsgBox(BitOR($MB_ICONERROR, $MB_OK), "ClAsHbOt DLL Error", "Error with DLL, FindBestStorage" & @CRLF & _
		 "This is catastrophic, exiting.")
	  Exit
   EndIf

   Local $split = StringSplit($res[0], "|", 2)
   $left = Number($split[1] + $gScreenCenter[0]-150)
   $top = Number($split[2] + $gScreenCenter[1]-150)
   $conf = Number($split[3])
   DebugWrite("FindBestStorage() " & $split[0] & ", loc: " & $left & "," & $top & " conf: " & $split[3])

   If $split[0] = "" Then SaveDebugImage($frame, "StorageUsageFrame" & StringUpper($type) & FileGetTime("temp.bmp", 0, $FT_STRING) & ".bmp")

   FileDelete("temp.bmp")  ; temporary
   _GDIPlus_BitmapDispose($frame)

   Return $split[0]
EndFunc

Func FindAllStorages(Const $type, Const $maxMatch, ByRef $x, ByRef $y)
   ; Type must be "gold", "elix", or "dark"
   Local $frame = CaptureFrame("FindAllStorages", $gScreenCenter[0]-150, $gScreenCenter[1]-150, $gScreenCenter[0]+150, $gScreenCenter[1]+150)
   _GDIPlus_ImageSaveToFile($frame, "temp.bmp")   ; temporary

   Local $res = DllCall($gDllHandle, "str", "FindAllStorages", "str", $type, "str", "temp.bmp", "double", $gConfidenceStorages, "int", $maxMatch)

   If @error Then
	  DebugWrite("FindAllStorages() DllCall @error=" & @error)
	  MsgBox(BitOR($MB_ICONERROR, $MB_OK), "ClAsHbOt DLL Error", "Error with DLL, FindAllStorages" & @CRLF & _
		 "This is catastrophic, exiting.")
	  Exit
   EndIf

   Local $split = StringSplit($res[0], "|", 2)
   ;DebugWrite("Num matches " & $type & ": " & $split[0])

   For $j = 0 To $split[0]-1
	  $x[$j] = Number($split[$j*3+1] + $gScreenCenter[0]-150)
	  $y[$j] = Number($split[$j*3+2] + $gScreenCenter[1]-150)
	  ;DebugWrite("Match " & $j & ": " & $x[$j] & "," & $y[$j] & "  conf: " & $split[$j*3+3])
   Next

   FileDelete("temp.bmp")  ; temporary
   _GDIPlus_BitmapDispose($frame)

   Return $split[0]
EndFunc

Func ScanFrameForOneBMP(Const $f, Const ByRef $needle, ByRef $confidence, ByRef $x, ByRef $y)
   $confidence = 0
   $x = -1
   $y = -1

; temporary
_GDIPlus_ImageSaveToFile($f, "temp.bmp")

   Local $res = DllCall($gDllHandle, "str", "FindMatch", "str", "temp.bmp", "str", $needle)

   If @error Then
	  DebugWrite("ScanFrameForOneBMP() DllCall @error=" & @error)
	  MsgBox(BitOR($MB_ICONERROR, $MB_OK), "ClAsHbOt DLL Error", "Error with DLL." & @CRLF & _
		 "This is catastrophic, exiting.")
	  Exit
   EndIf

   Local $split = StringSplit($res[0], "|", 2)
   $x = $split[0]
   $y = $split[1]
   $confidence = $split[2]

; temporary
FileDelete("temp.bmp")

EndFunc

Func ScanFrameForBestBMP(Const $f, Const ByRef $bmpArray, Const $threshold, ByRef $bestMatch, ByRef $bestConfidence, ByRef $bestX, ByRef $bestY)
   $bestMatch = -1
   $bestConfidence = 0
   $bestX = -1
   $bestY = -1

; temporary
_GDIPlus_ImageSaveToFile($f, "temp.bmp")

   For $i = 0 to UBound($bmpArray)-1
	  ;DebugWrite("Frame handle: " & Hex($f))
	  ;Local $res = DllCall("ClAsHbOtDlL.dll", "str", "FindMatch", "ptr", $f, "str", "Images\"&$bmpArray[$i])
	  Local $res = DllCall($gDllHandle, "str", "FindMatch", "str", "temp.bmp", "str", "Images\"&$bmpArray[$i])

	  If @error Then
		 DebugWrite("ScanFrameForBestBMP() DllCall @error=" & @error)
		 MsgBox(BitOR($MB_ICONERROR, $MB_OK), "ClAsHbOt DLL Error", "Error with DLL." & @CRLF & _
			"This is catastrophic, exiting.")
		 Exit
	  EndIf

	  ;DebugWrite($bmpArray[$i] & ": " & $res[0])

	  Local $split = StringSplit($res[0], "|", 2)
	  If $split[2] > $threshold And $split[2] > $bestConfidence Then
		 $bestX = $split[0]
		 $bestY = $split[1]
		 $bestConfidence = $split[2]
		 $bestMatch = $i
	  EndIf
   Next

; temporary
FileDelete("temp.bmp")

EndFunc

Func ScanFrameForAllBMPs(Const $f, Const ByRef $bmpArray, Const $threshold, Const $maxMatches, ByRef $matchX, ByRef $matchY)
; temporary
_GDIPlus_ImageSaveToFile($f, "temp.bmp")

    ; Find all the buildings of the specified type
   Local $matchCount = 0
   For $i = 0 To UBound($bmpArray)-1
	  ; Get matches for this resource
	  Local $res = DllCall($gDllHandle, "str", "FindAllMatches", "str", "temp.bmp", "str", "Images\"&$bmpArray[$i], "int", $maxMatches, "double", $threshold)

	  If @error Then
		 DebugWrite("ScanFrameForAllBMPs() DllCall @error=" & @error)
		 MsgBox(BitOR($MB_ICONERROR, $MB_OK), "ClAsHbOt DLL Error", "Error with DLL." & @CRLF & _
			"This is catastrophic, exiting.")
		 Exit
	  EndIf

	  Local $split = StringSplit($res[0], "|", 2)
	  ;DebugWrite("Num matches " & $bmpArray[$i] & ": " & $split[0])

	  For $j = 0 To $split[0]-1
		 ; Loop through all captured points so far, if this one is within 8 pix of an existing one, then skip it.
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
			If $split[$j*3+3] > $threshold Then
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

; temporary
FileDelete("temp.bmp")

Return $matchCount

EndFunc

Func CaptureFrame(Const $fromFunc, $x1=0, $y1=0, $x2=$gBlueStacksWidth, $y2=$gBlueStacksHeight)
   ;DebugWrite("CaptureFrame() from " & $fromFunc & ($gBackgroundScraping ? " (background)" : " (foreground)"))

   Local $hGdipBitmap

   If $gBackgroundScraping Then
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

Func SaveDebugImage(Const $hGdipBitmap, Const $filename)
   ;Local $hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($hHBITMAP)
   _GDIPlus_ImageSaveToFile($hGdipBitmap, $filename)
   ;_GDIPlus_BitmapDispose($hHBITMAP)
EndFunc

Func TestBackGroundScrape()
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

   Return $notBlackPixel
EndFunc

