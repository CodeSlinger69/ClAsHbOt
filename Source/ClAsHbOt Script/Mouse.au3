Func RandomWeightedClick(Const $button, Const $scale = 1, Const $density = 1, Const $centerX = 0, Const $centerY = 0)
   Local $xClick, $yClick
   RandomWeightedCoords($button, $xClick, $yClick, $scale, $density, $centerX, $centerY)
   _ControlClick($xClick, $yClick)
EndFunc

; Adapted from ClashGameBot https://mybot.run
Func _ControlClick(Const $x, Const $y, Const $numClicks = 1, Const $delay = 0)
   For $i = 1 To $numClicks
	  ControlClick($gTitle, "", "", "left", "1", $x, $y)
	  Sleep($delay)
   Next
EndFunc

Func _ClickHold(Const $x, Const $y, Const $duration)
   Local $MK_LBUTTON  = 0x0001
   Local $WM_LBUTTONDOWN  = 0x0201
   Local $WM_LBUTTONUP  = 0x0202

   DllCall("user32.dll", "int", "SendMessage", "hwnd", $gBlueStacksHwnd, "int", $WM_LBUTTONDOWN, "int", _
			$MK_LBUTTON, "long", _MakeLong($x, $y))
   Sleep($duration)
   DllCall("user32.dll", "int", "SendMessage", "hwnd", $gBlueStacksHwnd, "int", $WM_LBUTTONUP, "int", _
			$MK_LBUTTON, "long", _MakeLong($x, $y))
EndFunc

Func _MakeLong($LoWord, $HiWord)
   Return BitOR($HiWord * 0x10000, BitAND($LoWord, 0xFFFF))
EndFunc


Func RandomWeightedCoords(Const ByRef $boundingBox, ByRef $x, ByRef $y, $scale = 1, $density = 1, _
						  $centerX = 0, $centerY = 0)
   ; http://stackoverflow.com/questions/23700822/weighted-random-coordinates

   Local Const $PI = 3.141592653589793
   Local $boxWidth = $boundingBox[2]-$boundingBox[0]
   Local $boxHeight = $boundingBox[3]-$boundingBox[1]
   Local $boxCenterX = $boundingBox[0] + $boxWidth/2 + $centerX
   Local $boxCenterY = $boundingBox[1] + $boxHeight/2 + $centerY
   ;DebugWrite("Box coord: " & $boundingBox[0] & " " & $boundingBox[1] & " " & $boundingBox[2] & " " & $boundingBox[3])
   ;DebugWrite("Box center: " & $boxCenterX & "," & $boxCenterY)

   Local $loopStartTime = TimerInit()
   Do
	  Local $angle = Random() * 2 *$PI
	  Local $xR = Random()

	  If $xR = 0 Then $xR = 0.000001

	  Local $distance = $scale * (($xR ^ (-1.0/$density)) - 1)

	  Local $offsetX = $distance * Sin($angle)
	  Local $offsetY = $distance * Cos($angle)

	  $x = $boxCenterX + $boxWidth * $offsetX/4
	  $y = $boxCenterY + $boxHeight * $offsetY/4

	  ; Check for long running loop
	  If TimerDiff($loopStartTime)>5000 Then
		 DebugWrite("ERROR in RandomWeightedCoords, long running loop.  Exiting.")
		 $x = $boxCenterX
		 $y = $boxCenterY
		 Return
	  EndIf

   Until $x >= $boundingBox[0] And $x <= $boundingBox[2] And _
		 $y >= $boundingBox[1] And $y <= $boundingBox[3]

   $x = Int($x)
   $y = Int($y)

   ;DebugWrite("Click point: " & $x & "," & $y)
EndFunc

Func RandomCoords(Const ByRef $boundingBox, ByRef $x, ByRef $y)
   $x = Random($boundingBox[0], $boundingBox[2], 1)
   $y = Random($boundingBox[1], $boundingBox[3], 1)
EndFunc
