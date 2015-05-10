
Func FindAValidMatch(Const $returnFirstMatch = False)
   DebugWrite("FindAValidMatch()")

   ; Get starting gold, to calculate cost of Next'ing
   Local $startGold = GUICtrlRead($GUI_MyGold)

   ; Click Attack
   RandomWeightedClick($rMainScreenAttackButton)

   ; Wait for Find a Match button
   Local $failCount = 10
   While IsButtonPresent($rFindMatchScreenFindAMatchButton) = False And $failCount>0
	  Sleep(1000)
	  $failCount -= 1
   WEnd

   If $failCount = 0 Then
	  DebugWrite("Find Match failed - timeout waiting for Find a Match button")
	  ResetToCoCMainScreen()
	  Return False
   EndIf

   ; Click Find a Match
   RandomWeightedClick($rFindMatchScreenFindAMatchButton)

   ; Wait for Next button
   $failCount = 30
   While IsButtonPresent($rWaitRaidScreenNextButton) = False And $failCount>0

	  ; See if Shield Is Active screen pops up
	  If WhereAmI() = $eScreenShieldIsActive Then
		 RandomWeightedClick($rShieldIsActivePopupButton)
		 Sleep(500)
	  EndIf

	  Sleep(1000)
	  $failCount -= 1
   WEnd

   If $failCount = 0 Then
	  DebugWrite("Find Match failed - timeout waiting for Wait Raid screen")
	  ResetToCoCMainScreen()
	  Return False
   EndIf

   ; Return now, if we are calling this function to dump cups
   If $returnFirstMatch Then Return True

   ; Loop with Next until we get a match
   Local $match = False
   Local $gold, $elix, $dark, $cups, $townHall, $deadBase

   While 1
	  If _GUICtrlButton_GetCheck($GUI_FindMatchCheckBox) = $BST_UNCHECKED And _
		 _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_UNCHECKED Then
		 ExitLoop
	  EndIf

	  $match = CheckForMatch($gold, $elix, $dark, $cups, $townHall, $deadBase)
	  If $match <> -1 Then ExitLoop

	  ; Click Next button
	  DebugWrite("No match:  " & $gold & " / " & $elix & " / " & $dark &  " / " & $cups & " / " & $townHall & " / " & $deadBase)
	  Sleep($gPauseBetweenNexts)
	  RandomWeightedClick($rWaitRaidScreenNextButton)

	  ; Sleep and wait for Next button to reappear
	  Sleep(500) ; So the click on the Wait button has time to register
	  $failCount = 30
	  While IsButtonPresent($rWaitRaidScreenNextButton) = False And $failCount>0
		 Sleep(1000)
		 $failCount -= 1
	  WEnd

	  If $failCount = 0 Then
		 DebugWrite("Find Match failed - timeout waiting for Wait Raid screen")
		 ResetToCoCMainScreen()
		 Return False
	  EndIf
   WEnd

   ; Get ending gold, to calculate cost of Next'ing
   Local $endGold = GUICtrlRead($GUI_MyGold)
   DebugWrite("Gold cost this match: " & $startGold - $endGold)

   If $match <> -1 Then

	  ; Pop up a message box if we are not auto raiding right now
	  If _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_UNCHECKED Then
		 ; 5 beeps
		 For $i = 1 To 5
			Beep(500, 200)
			Sleep(100)
		 Next

		 DebugWrite("Got match: " & $gold & " / " & $elix & " / " & $dark &  " / " & $cups & " / " & $deadBase)
		 MsgBox($MB_OK, "Match!", $gold & " / " & $elix & " / " & $dark &  " / " & $cups &  " / " & $townHall & " / " & $deadBase & _
			@CRLF & @CRLF & "Click OK after completing raid," & @CRLF & _
			"or deciding to skip this raid." & @CRLF & @CRLF & _
			"Cost of this search: " & $startGold - $endGold)
	  EndIf

	  Return $match
   EndIf

   Return -1
EndFunc

Func CheckForMatch(ByRef $gold, ByRef $elix, ByRef $dark, ByRef $cups, ByRef $townHall, ByRef $deadBase)
   ; Update my loot status on GUI
   GetMyLootNumbers()

   ; Scrape text fields
   $gold = Number(ScrapeFuzzyText($gRaidLootCharMaps, $rGoldTextBox, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))
   $elix = Number(ScrapeFuzzyText($gRaidLootCharMaps, $rElixTextBox, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))
   $dark = Number(ScrapeFuzzyText($gRaidLootCharMaps, $rDarkTextBox, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))
   $cups = 0

   If IsTextBoxPresent($rCupsTextBox1) Then
	  $cups = Number(ScrapeFuzzyText($gRaidLootCharMaps, $rCupsTextBox1, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))
   ElseIf IsTextBoxPresent($rCupsTextBox2) Then
	  $cups = Number(ScrapeFuzzyText($gRaidLootCharMaps, $rCupsTextBox2, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))
   EndIf

   ; See if this is a dead base
   $deadBase = IsColorPresent($rDeadBaseIndicatorColor)

   ; Default townhall
   $townHall = -1

   SetAutoRaidResults($gold, $elix, $dark, $cups, $townHall, $deadBase)

   ; Grab settings from the GUI
   Local $GUIGold = GUICtrlRead($GUI_GoldEdit)
   Local $GUIElix = GUICtrlRead($GUI_ElixEdit)
   Local $GUIDark = GUICtrlRead($GUI_DarkEdit)
   Local $GUITownHall = GUICtrlRead($GUI_TownHallEdit)
   Local $GUIAutoRaid = (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_CHECKED)
   Local $GUIZapDE = (_GUICtrlButton_GetCheck($GUI_AutoRaidZapDE) = $BST_CHECKED)
   Local $GUIZapDEMin = GUICtrlRead($GUI_AutoRaidZapDEMin)
   Local $GUIDeadBasesOnly = (_GUICtrlButton_GetCheck($GUI_AutoRaidDeadBases) = $BST_CHECKED)

   ; If auto raiding, and zap DE is checked, and available DE > zap DE min, and we have all lightnings cooked up,
   ; then we have a match
   If $GUIAutoRaid And $GUIZapDE And $dark>=$GUIZapDEMin Then
	  Local $spellIndexAbsolute[$eSpellCount][4]
	  FindRaidTroopSlots($gSpellSlotBMPs, $spellIndexAbsolute)

	  Local $lightningAvailable = GetAvailableTroops($eSpellLightning, $spellIndexAbsolute)
	  DebugWrite("Found zappable base with " & $dark & " DE. " & _
		 $lightningAvailable & " of " & $gMyMaxSpells & " lightning spells available.")

	  If $lightningAvailable >= $gMyMaxSpells Then Return $eAutoRaidExecuteDEZap
   EndIf

   ; Only get Town Hall Level if the other criteria are a match
   If $gold >= $GUIGold And $elix >= $GUIElix And $dark >= $GUIDark Then
	  If ($GUIDeadBasesOnly=True And $deadBase=True) Or $GUIDeadBasesOnly=False Then
		 $townHall = GetTownHallLevel()
		 SetAutoRaidResults($gold, $elix, $dark, $cups, $townHall, $deadBase)
	  EndIf
   EndIf

   ; Do we have a gold/elix/dark/townhall/dead match?
   If $gold >= $GUIGold And $elix >= $GUIElix And $dark >= $GUIDark Then
	  If $townHall <= $GUITownHall And $townHall > 0 Then
		 If ($GUIDeadBasesOnly=True And $deadBase=True) Or $GUIDeadBasesOnly=False Then
			DebugWrite("Found Match: " & $gold & " / " & $elix & " / " & $dark  & " / " & $townHall & " / " & $deadBase)
			Return $eAutoRaidExecuteRaid
		 EndIf
	  EndIf
   EndIf

   Return -1
EndFunc
