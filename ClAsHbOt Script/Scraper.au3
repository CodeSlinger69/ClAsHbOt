Func InitScraper()
   _GDIPlus_Startup()
EndFunc

Func ExitScraper()
   _GDIPlus_Shutdown()
EndFunc

Func ScrapeFuzzyText(Const ByRef $charMapArray, Const ByRef $box, Const $maxCharSize, Const $keepSpaces)
   Local $w = $box[2] - $box[0] + 1
   Local $h = $box[3] - $box[1] + 1
   Local $pix[$w][$h]
   Local $pY

   ; Get map of foreground pixels
   Local $frame = CaptureFrame($box[0], $box[1], $box[2], $box[3])
   GetForegroundPixels($frame, $box, $pix, $pY)
   _GDIPlus_BitmapDispose($frame)

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
Func ScrapeExactText(Const ByRef $charMapArray, Const ByRef $box, Const $maxCharSize, Const $keepSpaces)
   Local $w = $box[2] - $box[0] + 1
   Local $h = $box[3] - $box[1] + 1
   Local $pix[$w][$h]
   Local $pY

   ; Get map of foreground pixels
   Local $frame = CaptureFrame($box[0], $box[1], $box[2], $box[3])
   GetForegroundPixels($frame, $box, $pix, $pY)
   _GDIPlus_BitmapDispose($frame)

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

   For $y = 0 To $box[3]-$box[1]

	  ; See if this line contains valid pixels
	  Local $BlankLine = True
	  For $x = 0 To $box[2]-$box[0]
		 Local $pixelColor = _GDIPlus_BitmapGetPixel($frame, $x, $y)
		 If InColorSphere($pixelColor, $box[4], $box[5]) = True Then
			$BlankLine = False
			ExitLoop
		 EndIf
	  Next

	  If $BlankLine = False Then
		 For $x = 0 To $box[2]-$box[0]
			Local $pixelColor = _GDIPlus_BitmapGetPixel($frame, $x, $y)

			If InColorSphere($pixelColor, $box[4], $box[5]) = True Then
			   $pix[$x][$rows] = 1
			Else
			   $pix[$x][$rows] = 0
			EndIf
		 Next

		 If $gScraperDebug Then
			For $x = 0 To $box[2]-$box[0]
			   If $pix[$x][$rows] = 1 Then
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

Func IsTextBoxPresent(Const ByRef $textBox)
   Local $frame = CaptureFrame($textBox[6], $textBox[7], $textBox[6], $textBox[7])
   Local $pixelColor = _GDIPlus_BitmapGetPixel($frame, 0, 0)
   _GDIPlus_BitmapDispose($frame)

   Return InColorSphere($pixelColor, $textBox[8], $textBox[9])
EndFunc

Func IsButtonPresent(Const ByRef $buttonBox)
   Local $frame = CaptureFrame($buttonBox[4], $buttonBox[5], $buttonBox[4], $buttonBox[5])
   Local $pixelColor = _GDIPlus_BitmapGetPixel($frame, 0, 0)
   _GDIPlus_BitmapDispose($frame)

   Return InColorSphere($pixelColor, $buttonBox[6], $buttonBox[7])
EndFunc

Func IsColorPresent(Const ByRef $colorLocation)
   Local $frame = CaptureFrame($colorLocation[0], $colorLocation[1], $colorLocation[0], $colorLocation[1])
   Local $pixelColor = _GDIPlus_BitmapGetPixel($frame, 0, 0)
   _GDIPlus_BitmapDispose($frame)

   Return InColorSphere($pixelColor, $colorLocation[2], $colorLocation[3])
EndFunc

Func ScanFrameForBestBMP(Const $filename, Const ByRef $bmpArray, Const $threshold, ByRef $bestMatch, ByRef $bestConfidence, ByRef $bestX, ByRef $bestY)
   $bestMatch = -1
   $bestConfidence = 0
   $bestX = -1
   $bestY = -1

   For $i = 0 to UBound($bmpArray)-1
	  Local $res = DllCall("ImageMatch.dll", "str", "FindMatch", "str", $filename, "str", "Images\"&$bmpArray[$i], "int", 3)

	  ;DebugWrite($bmpArray[$i] & ": " & $res[0])

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

Func CaptureFrame($x1=-1, $y1=-1, $x2=-1, $y2=-1)
   If $x1 = -1 Then
	  $x1 = 0
	  $y1 = 0
	  $x2 = $gBlueStacksWidth
	  $y2 = $gBlueStacksHeight
   EndIf

   Local $hDC = _WinAPI_GetWindowDC($gBlueStacksControlHwnd)
   Local $memDC = _WinAPI_CreateCompatibleDC($hDC)
   Local $memBmp = _WinAPI_CreateCompatibleBitmap($hDC, $x2-$x1+1, $y2-$y1+1)
   Local $bmpOriginal  = _WinAPI_SelectObject($memDC, $memBmp)

   DllCall("user32.dll", "int", "PrintWindow", "hwnd", $gBlueStacksControlHwnd, "handle", $memDC, "int", 0)

   _WinAPI_BitBlt($memDC, 0, 0, $x2-$x1+1, $y2-$y1+1, $hDC, $x1, $y1, $SRCCOPY)

   Local $hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($memBmp)

   _WinAPI_DeleteObject($memBmp)
   _WinAPI_SelectObject($memDC, $bmpOriginal)
   _WinAPI_DeleteDC($memDC)
   _WinAPI_ReleaseDC($gBlueStacksControlHwnd, $hDC)

   Return $hBitmap
EndFunc

Func GrabFrameToFile2(Const $filename, $x1=-1, $y1=-1, $x2=-1, $y2=-1)
   Local $hBitmap = CaptureFrame($x1, $y1, $x2, $y2)
   Local $res = _GDIPlus_ImageSaveToFile($hBitmap, $filename)
   _GDIPlus_BitmapDispose($hBitmap)
   Return $res
EndFunc
