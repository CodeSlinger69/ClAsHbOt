; Returns true if base found, False otherwise
Func FindASnipableTH()
   DebugWrite("FindASnipableTH()")
   Local $cPos = GetClientPos()
   Local $xClick, $yClick, $failCount, $pixelColor, $pixMatch

   ; Get starting gold, to calculate cost of Next'ing
   Local $startGold = GUICtrlRead($GUI_MyGold)

   ; Click Attack
   RandomWeightedCoords($MainScreenAttackButton, $xClick, $yClick)
   MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)

   ; Wait for Find a Match button
   $failCount = 10
   $pixMatch = False
   While $pixMatch = False And $failCount>0 And $ExitApp = False
	  Sleep(1000)
	  $failCount -= 1
	  $pixelColor = PixelGetColor($cPos[0]+$FindMatchScreenFindAMatchButton[4], $cPos[1]+$FindMatchScreenFindAMatchButton[5])
	  $pixMatch = InColorSphere($pixelColor, $FindMatchScreenFindAMatchButton[6], $FindMatchScreenFindAMatchButton[7])
   WEnd

   If $ExitApp Then Return
   If $failCount = 0 Then
	  ConsoleWrite(_NowTime() & " Find Snipable TH failed - timeout waiting for Find a Match button" & @CRLF)
	  ResetToCoCMainScreen()
	  Return False
   EndIf

   ; Click Find a Match
   RandomWeightedCoords($FindMatchScreenFindAMatchButton, $xClick, $yClick)
   MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)

   ; Wait for Next button
   $failCount = 30
   $pixMatch = False
   While $pixMatch = False And $failCount>0 And $ExitApp = False

	  ; See if Shield Is Active screen pops up
	  Local $scr = WhereAmI()

	  If $scr = $ScreenShieldIsActive Then
		 RandomWeightedCoords($ShieldIsActivePopupButton, $xClick, $yClick)
		 MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)
		 Sleep(500)
	  EndIf

	  Sleep(1000)
	  $failCount -= 1
	  $pixelColor = PixelGetColor($cPos[0]+$WaitRaidScreenNextButton[4], $cPos[1]+$WaitRaidScreenNextButton[5])
	  $pixMatch = InColorSphere($pixelColor, $WaitRaidScreenNextButton[6], $WaitRaidScreenNextButton[7])
   WEnd

   If $ExitApp Then Return
   If $failCount = 0 Then
	  ConsoleWrite(_NowTime() & " Find Snipable TH failed - timeout waiting for Wait Raid screen" & @CRLF)
	  ResetToCoCMainScreen()
	  Return False
   EndIf

   ; Loop with Next until we get two matches in a row
   Local $match = False, $count = 1

   While $ExitApp = False
	  If _GUICtrlButton_GetCheck($GUI_FindSnipableTHCheckBox) = $BST_UNCHECKED Then ExitLoop

	  ; Update my loot status on GUI
	  GetMyLootNumbers()

	  ; See if we do not have a TH in the specified box, or we have a TH level <= what is on the GUI
	  Local $GUITownHall = GUICtrlRead($GUI_TownHallEdit)
	  Local $townHall = GetTownHallLevel(300, 125, 724, 425)

	  If $townHall<>0 And $townHall<=$GUITownHall Then
		 $match = True
		 ExitLoop
	  EndIf

	  If $townHall = 0 Then

		 ; Check again, in case something was obscuring it the first time
		 Sleep(2000)
		 $townHall = GetTownHallLevel(300, 125, 724, 425)
		 If $townHall = 0 Then

			; And one more time, just to be sure
			Sleep(2000)
			$townHall = GetTownHallLevel(300, 125, 724, 425)
			If $townHall = 0 Then
			   $match = True
			   ExitLoop
			EndIf
		 EndIf
	  EndIf

	  ; Click Next button
	  RandomWeightedCoords($WaitRaidScreenNextButton, $xClick, $yClick)
	  MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)
	  $count+=1

	  ; Sleep and wait for Next button to reappear
	  Sleep(500) ; So the click on the Wait button has time to register
	  $failCount = 30
	  $pixMatch = False
	  While $pixMatch = False And $failCount>0 And $ExitApp = False
		 Sleep(1000)
		 $failCount -= 1
		 $pixelColor = PixelGetColor($cPos[0]+$WaitRaidScreenNextButton[4], $cPos[1]+$WaitRaidScreenNextButton[5])
		 $pixMatch = InColorSphere($pixelColor, $WaitRaidScreenNextButton[6], $WaitRaidScreenNextButton[7])
	  WEnd

	  If $ExitApp Then Return
	  If $failCount = 0 Then
		 ConsoleWrite(_NowTime() & " Find Snipable TH failed - timeout waiting for Wait Raid screen" & @CRLF)
		 ResetToCoCMainScreen()
		 Return False
	  EndIf
   WEnd

   ; Get ending gold, to calculate cost of Next'ing
   Local $endGold = GUICtrlRead($GUI_MyGold)

   ConsoleWrite(_NowTime() & " Gold cost this search: " & $startGold - $endGold & _
	  " (" & $count & " nexts)." & @CRLF)

   If $match = True Then
	  ; Pop up a message box
	  ; 5 beeps
	  Local $i
	  For $i = 1 To 5
		 Beep(500, 200)
		 Sleep(100)
	  Next

	  MsgBox($MB_OK, "Snipable TH!", _
		 "Click OK after completing raid," & @CRLF & _
		 "or deciding to skip this raid." & @CRLF & @CRLF & _
		 "Cost of this search: " & $startGold - $endGold)

	  Return True
   EndIf

   Return False
EndFunc

