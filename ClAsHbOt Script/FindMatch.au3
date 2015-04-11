
Func FindAValidMatch(Const $returnFirstMatch = False)
   DebugWrite("FindAValidMatch()")

   ; Get starting gold, to calculate cost of Next'ing
   Local $startGold = GUICtrlRead($GUI_MyGold)

   ; Click Attack
   RandomWeightedClick($MainScreenAttackButton)

   ; Wait for Find a Match button
   Local $failCount = 10
   Local $pixMatch = False
   While $pixMatch = False And $failCount>0 And $ExitApp = False
	  Sleep(1000)
	  $failCount -= 1

	  Local $cPos = GetClientPos()
	  Local $pixelColor = PixelGetColor($cPos[0]+$FindMatchScreenFindAMatchButton[4], $cPos[1]+$FindMatchScreenFindAMatchButton[5])
	  $pixMatch = InColorSphere($pixelColor, $FindMatchScreenFindAMatchButton[6], $FindMatchScreenFindAMatchButton[7])
   WEnd

   If $ExitApp Then Return False

   If $failCount = 0 Then
	  DebugWrite(_NowTime() & " Find Match failed - timeout waiting for Find a Match button" & @CRLF)
	  ResetToCoCMainScreen()
	  Return False
   EndIf

   ; Click Find a Match
   RandomWeightedClick($FindMatchScreenFindAMatchButton)

   ; Wait for Next button
   $failCount = 30
   $pixMatch = False
   While $pixMatch = False And $failCount>0 And $ExitApp = False

	  ; See if Shield Is Active screen pops up
	  Local $scr = WhereAmI()

	  If $scr = $ScreenShieldIsActive Then
		 RandomWeightedClick($ShieldIsActivePopupButton)
		 Sleep(500)
	  EndIf

	  Sleep(1000)
	  $failCount -= 1
	  Local $pixelColor = PixelGetColor($cPos[0]+$WaitRaidScreenNextButton[4], $cPos[1]+$WaitRaidScreenNextButton[5])
	  $pixMatch = InColorSphere($pixelColor, $WaitRaidScreenNextButton[6], $WaitRaidScreenNextButton[7])
   WEnd

   If $ExitApp Then Return False

   If $failCount = 0 Then
	  DebugWrite(_NowTime() & " Find Match failed - timeout waiting for Wait Raid screen" & @CRLF)
	  ResetToCoCMainScreen()
	  Return False
   EndIf

   ; Return now, if we are calling this function to dump cups
   If $returnFirstMatch Then Return True

   ; Loop with Next until we get a match
   Local $match = False
   Local $gold, $elix, $dark, $cups, $townHall

   While $ExitApp = False
	  If _GUICtrlButton_GetCheck($GUI_FindMatchCheckBox) = $BST_UNCHECKED And _
		 _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_UNCHECKED Then
		 ExitLoop
	  EndIf

	  $match = CheckForLootMatch($gold, $elix, $dark, $cups, $townHall)
	  If $match <> -1 Then ExitLoop

	  ; Click Next button
	  DebugWrite("No match:  " & $gold & " / " & $elix & " / " & $dark &  " / " & $cups & " / " & $townHall)
	  RandomWeightedClick($WaitRaidScreenNextButton)

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
		 DebugWrite(_NowTime() & " Find Match failed - timeout waiting for Wait Raid screen" & @CRLF)
		 ResetToCoCMainScreen()
		 Return False
	  EndIf
   WEnd

   ; Get ending gold, to calculate cost of Next'ing
   Local $endGold = GUICtrlRead($GUI_MyGold)
   DebugWrite(_NowTime() & " Gold cost this match: " & $startGold - $endGold & @CRLF)

   If $match <> -1 Then

	  ; Pop up a message box if we are not auto raiding right now
	  If _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_UNCHECKED Then
		 ; 5 beeps
		 Local $i
		 For $i = 1 To 5
			Beep(500, 200)
			Sleep(100)
		 Next

		 DebugWrite("Got match: " & $gold & " / " & $elix & " / " & $dark &  " / " & $cups)
		 MsgBox($MB_OK, "Match!", $gold & " / " & $elix & " / " & $dark &  " / " & $cups &  " / " & $townHall & _
			@CRLF & @CRLF & "Click OK after completing raid," & @CRLF & _
			"or deciding to skip this raid." & @CRLF & @CRLF & _
			"Cost of this search: " & $startGold - $endGold)
	  EndIf

	  Return $match
   EndIf

   Return -1
EndFunc

Func CheckForLootMatch(ByRef $gold, ByRef $elix, ByRef $dark, ByRef $cups, ByRef $townHall)
   Local $cPos = GetClientPos()

   ; Update my loot status on GUI
   GetMyLootNumbers()

   ; Scrape text fields
   $gold = Number(ScrapeText($raidLootCharMaps, $goldTextBox))
   $elix = Number(ScrapeText($raidLootCharMaps, $elixTextBox))
   $dark = Number(ScrapeText($raidLootCharMaps, $darkTextBox))
   $cups = 0

   Local $pixelColor = PixelGetColor($cPos[0]+$cupsTextBox1[6], $cPos[1]+$cupsTextBox1[7])
   Local $pixMatch = InColorSphere($pixelColor, $cupsTextBox1[8], $cupsTextBox1[9])
   If $pixMatch = 1 Then $cups = Number(ScrapeText($raidLootCharMaps, $cupsTextBox1))

   $pixelColor = PixelGetColor($cPos[0]+$cupsTextBox2[6], $cPos[1]+$cupsTextBox2[7])
   $pixMatch = InColorSphere($pixelColor, $cupsTextBox2[8], $cupsTextBox2[9])
   If $pixMatch = 1 Then $cups = Number(ScrapeText($raidLootCharMaps, $cupsTextBox2))

   $townHall = 0
   GUICtrlSetData($GUI_Results, "Last scan: " & $gold & " / " & $elix & " / " & $dark & " / " & $cups & " / " & $townHall)

   ; Grab settings from the GUI
   Local $GUIGold = GUICtrlRead($GUI_GoldEdit)
   Local $GUIElix = GUICtrlRead($GUI_ElixEdit)
   Local $GUIDark = GUICtrlRead($GUI_DarkEdit)
   Local $GUITownHall = GUICtrlRead($GUI_TownHallEdit)
   Local $GUIAutoRaid = (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_CHECKED)
   Local $GUIZapDE = (_GUICtrlButton_GetCheck($GUI_AutoRaidZapDE) = $BST_CHECKED)
   Local $GUIZapDEMin = GUICtrlRead($GUI_AutoRaidZapDEMin)

   ; Only get Town Hall Level if the other criteria are a match
   If $gold >= $GUIGold And $elix >= $GUIElix And $dark >= $GUIDark Then
	  $townHall = GetTownHallLevel()
	  GUICtrlSetData($GUI_Results, "Last scan: " & $gold & " / " & $elix & " / " & $dark & " / " & $cups & " / " & $townHall)
   EndIf

   ; Do we have a gold/elix/dark match?
   If $gold >= $GUIGold And $elix >= $GUIElix And $dark >= $GUIDark And $townHall <= $GUITownHall And $townHall<>0 Then
	  DebugWrite(_NowTime() & " Found Match: " & $gold & " / " & $elix & " / " & $dark  & " / " & $townHall & @CRLF)
	  Return $AutoRaidExecuteRaid
   EndIf

   ; If auto raiding, and zap DE is checked, and available DE > zap DE min, and we have all lightnings cooked up,
   ; then we have a match
   If $GUIAutoRaid And $GUIZapDE And $dark>=$GUIZapDEMin Then
	  If CountLightningSpells()>=$myMaxSpells Then
		 DebugWrite(_NowTime() & " Found zappable base: " & $dark & @CRLF)
		 Return $AutoRaidExecuteDEZap
	  EndIf
   EndIf

   Return -1
EndFunc
