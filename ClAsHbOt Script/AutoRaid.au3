Func AutoRaid(ByRef $timer)
   ;DebugWrite("AutoRaid()")

   Switch $gAutoStage

   ; Stage Queue Training
   Case $eAutoQueueTraining
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Queue Training")

	  ResetToCoCMainScreen()

	  AutoQueueTroops()
	  $timer = TimerInit()

   ; Stage Wait For Training To Complete
   Case $eAutoWaitForTrainingToComplete

	  If TimerDiff($timer) >= $gTroopTrainingCheckInterval Then
		 ResetToCoCMainScreen()
		 AutoCheckIfTroopsReady()
		 $timer = TimerInit()
	  EndIf

   ; Stage Find Match
   Case $eAutoFindMatch
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Find Match")

	  ResetToCoCMainScreen()
	  Local $zappable
	  Local $findMatchResults = AutoRaidFindMatch($zappable)

	  ; Something went wrong, reset to start
	  If $findMatchResults = False Then
		 DebugWrite("Auto: Error finding match, resetting.")
		 ResetToCoCMainScreen()
		 $gAutoStage = $eAutoQueueTraining
	  EndIf

	  If $zappable Then
		 GUICtrlSetData($GUI_AutoStatus, "Auto: Execute DE Zap")
		 AutoDEZap(False)
		 GUICtrlSetData($GUI_AutoStatus, "Auto: DE Zap Complete")
	  EndIf

	  If $findMatchResults = $eAutoExecute Then $gAutoStage = $eAutoExecute

   ; Stage Execute Raid
   Case $eAutoExecute
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Execute Raid")

	  Switch _GUICtrlComboBox_GetCurSel($GUI_AutoRaidStrategyCombo)
	  Case 0
		 If AutoRaidExecuteRaidStrategy0() Then
			$gAutoStage = $eAutoQueueTraining
			AutoRaidUpdateProgress()
		 EndIf
	  Case 1
		 ContinueCase
	  Case 2
		 ContinueCase
	  Case 3
		 GUICtrlSetData($GUI_AutoStatus, "Auto: Unimplemented strategy")
		 MsgBox($MB_OK, "Unimplemented strategy", "This strategy has not yet been implemented")
	  EndSwitch

	  GUICtrlSetData($GUI_AutoStatus, "Auto: Raid Complete")
   EndSwitch
EndFunc

Func AutoRaidFindMatch(ByRef $zappable, Const $returnFirstMatch = False)
   DebugWrite("FindAValidMatch()")

   ; Make sure we are on the main screen
   If WhereAmI() <> $eScreenMain Then
	  DebugWrite("Find Match failed - not on main screen")
	  Return False
   EndIf

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
   While IsButtonPresent($rWaitRaidScreenNextButton) = False And _
	  IsButtonPresent($rAndroidMessageButton) = False And _
	  AttackingIsDisabled() = False And _
	  $failCount>0

	  ; See if Shield Is Active screen pops up
	  If WhereAmI() = $eScreenShieldIsActive Then
		 RandomWeightedClick($rShieldIsActivePopupButton)
		 Sleep(500)
	  EndIf

	  Sleep(1000)
	  $failCount -= 1
   WEnd

   If AttackingIsDisabled() Then
	  DebugWrite("Find Match failed (AR1) - Attacking is Disabled")
	  ResetToCoCMainScreen()

	  $gPossibleKick = 2
	  $gLastPossibleKickTime = TimerInit()

	  Return False
   EndIf

   If $failCount = 0 Then
	  DebugWrite("Find Match failed (AR1) - timeout waiting for Wait Raid screen")
	  ResetToCoCMainScreen()

	  If $gPossibleKick < 2 Then
		 $gPossibleKick+=1
		 DebugWrite("Possible kick detected, count = " & $gPossibleKick)
	  EndIf

	  If $gPossibleKick = 2 Then
		 $gLastPossibleKickTime = TimerInit()
	  EndIf

	  Return False
   EndIf

   ; Return now, if we are calling this function to dump cups
   If $returnFirstMatch Then Return True

   ; Loop with Next until we get a match
   While 1
	  If _GUICtrlButton_GetCheck($GUI_FindMatchCheckBox) = $BST_UNCHECKED And _
		 _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_UNCHECKED Then
		 Return False
	  EndIf

	  ; Update my loot status on GUI
	  GetMyLootNumbers()

	  Local $raidable = False

	  ; Check dead base settings
	  Local $GUIDeadBasesOnly = (_GUICtrlButton_GetCheck($GUI_AutoRaidDeadBases) = $BST_CHECKED)
	  If $GUIDeadBasesOnly And IsColorPresent($rDeadBaseIndicatorColor)=False Then
		 DebugWrite("Not dead base, skipping.")
		 SetAutoRaidResults("-", "-", "-", "-", "-", False)

	  Else
		 $zappable = CheckZappableBase()
		 $raidable = CheckForRaidableBase()

	  EndIf

	  ; If zappable and/or raidable, then go do it
	  If $zappable=True Or $raidable<>False Then
		 If _GUICtrlButton_GetCheck($GUI_FindMatchCheckBox) = $BST_CHECKED Then ShowFindMatchPopup()
		 Return $raidable
	  EndIf

	  ; Not raidable or zappable - click Next
	  Sleep($gPauseBetweenNexts)
	  RandomWeightedClick($rWaitRaidScreenNextButton)
	  Sleep(500)

	  ; Sleep and wait for Next button to reappear
	  $failCount = 30
	  While IsButtonPresent($rWaitRaidScreenNextButton) = False And _
		    IsButtonPresent($rAndroidMessageButton) = False And _
			AttackingIsDisabled() = False And _
			$failCount>0

		 Sleep(1000)
		 $failCount -= 1
	  WEnd

	  If AttackingIsDisabled() Then
		 DebugWrite("Find Match failed (AR2) - Attacking is Disabled")
		 If WhereAmI() = $eScreenWaitRaid Then
			RandomWeightedClick($rLiveRaidScreenEndBattleButton)
			Sleep(500)
		 Else
			ResetToCoCMainScreen()
		 EndIf

		 $gPossibleKick = 2
		 $gLastPossibleKickTime = TimerInit()

		 Return False
	  EndIf

	  If $failCount = 0 Or IsButtonPresent($rAndroidMessageButton) Then
		 If $failCount = 0 Then
			DebugWrite("Find Match failed (AR2) - timeout waiting for Wait Raid screen")
		 Else
			DebugWrite("Find Match failed (AR2) - Android message box popup")
		 EndIf

		 If $gPossibleKick < 2 Then
			$gPossibleKick+=1
			DebugWrite("Possible kick detected, count = " & $gPossibleKick)
		 EndIf

		 If $gPossibleKick > 0 Then
			$gLastPossibleKickTime = TimerInit()
		 EndIf

		 ResetToCoCMainScreen()

		 Return False
	  EndIf
   WEnd

EndFunc

Func ShowFindMatchPopup()
   ; 5 beeps
   For $i = 1 To 5
	  Beep(500, 200)
	  Sleep(100)
   Next

   MsgBox($MB_OK, "Match!", "Click OK after completing raid," & @CRLF & "or deciding to skip this raid.")
EndFunc

Func CheckForRaidableBase()
   ; Scrape info
   Local $gold = Number(ScrapeFuzzyText($gRaidLootCharMaps, $rGoldTextBox, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))
   Local $elix = Number(ScrapeFuzzyText($gRaidLootCharMaps, $rElixTextBox, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))
   Local $dark = Number(ScrapeFuzzyText($gRaidLootCharMaps, $rDarkTextBox, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))
   Local $cups = 0

   If IsTextBoxPresent($rCupsTextBox1) Then
	  $cups = Number(ScrapeFuzzyText($gRaidLootCharMaps, $rCupsTextBox1, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))
   ElseIf IsTextBoxPresent($rCupsTextBox2) Then
	  $cups = Number(ScrapeFuzzyText($gRaidLootCharMaps, $rCupsTextBox2, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))
   EndIf

   Local $deadBase = IsColorPresent($rDeadBaseIndicatorColor)

   ; Grab settings from the GUI
   Local $GUIGold = GUICtrlRead($GUI_GoldEdit)
   Local $GUIElix = GUICtrlRead($GUI_ElixEdit)
   Local $GUIDark = GUICtrlRead($GUI_DarkEdit)
   Local $GUITownHall = GUICtrlRead($GUI_TownHallEdit)
   Local $GUIIgnoreStorages = (_GUICtrlButton_GetCheck($GUI_AutoRaidIgnoreStorages) = $BST_CHECKED)

   ; Adjust available loot to estimate collectors only?
   Local $adjGold, $adjElix, $adjDark
   If $GUIIgnoreStorages Then
	  GrabFrameToFile("StorageUsageFrame.bmp", 261, 100, 761, 450)
	  Local $x, $y, $conf, $matchIndex, $saveFrame = False

	  ; Gold
	  ScanFrameForBestBMP("StorageUsageFrame.bmp", $GoldStorageUsageBMPs, $gConfidenceStorages, $matchIndex, $conf, $x, $y)
	  DebugWrite("Gold match: " & $matchIndex & " / " & $x & " / " & $y & " / " & $conf)

	  If $matchIndex = -1 Then
		 $saveFrame = True
	  Else
		 Local $s = $GoldStorageUsageBMPs[$matchIndex]
		 Local $usage = Number(StringMid($s, StringInStr($s, "GoldStorageL")+15, 2))
		 $adjGold = Int($gold * (1-($usage/100)))
	  EndIf

	  ; Elixir
	  ScanFrameForBestBMP("StorageUsageFrame.bmp", $ElixirStorageUsageBMPs, $gConfidenceStorages, $matchIndex, $conf, $x, $y)
	  DebugWrite("Elix match: " & $matchIndex & " / " & $x & " / " & $y & " / " & $conf)

	  If $matchIndex = -1 Then
		 $saveFrame = True
	  Else
		 Local $s = $ElixirStorageUsageBMPs[$matchIndex]
		 Local $usage = Number(StringMid($s, StringInStr($s, "ElixStorageL")+15, 2))
		 $adjElix = Int($elix * (1-($usage/100)))
	  EndIf

	  ; Dark Elixir
	  ScanFrameForBestBMP("StorageUsageFrame.bmp", $DarkStorageUsageBMPs, $gConfidenceStorages, $matchIndex, $conf, $x, $y)
	  DebugWrite("Dark match: " & $matchIndex & " / " & $x & " / " & $y & " / " & $conf)

	  If $matchIndex = -1 Then
		 $saveFrame = True
	  Else
		 Local $s = $DarkStorageUsageBMPs[$matchIndex]
		 Local $usage = Number(StringMid($s, StringInStr($s, "DarkStorageL")+14, 2))
		 $adjDark = Int($dark * (1-($usage/100)))
	  EndIf

	  If $gold >= $GUIGold And $elix >= $GUIElix And $dark >= $GUIDark And $saveFrame = True Then
		 Local $datetimestamp = _
		 StringMid(_NowCalc(), 1,4) & _
		 StringMid(_NowCalc(), 6,2) & _
		 StringMid(_NowCalc(), 9,2) & _
		 StringMid(_NowCalc(), 12,2) & _
		 StringMid(_NowCalc(), 15,2) & _
		 StringMid(_NowCalc(), 18,2)
		 FileMove("StorageUsageFrame.bmp", "Storage-" & $datetimestamp & ".bmp")
	  EndIf
   EndIf

   ; Default townhall
   Local $townHall = -1

   SetAutoRaidResults($gold, $elix, $dark, $cups, $townHall, $deadBase)

   ; Only get Town Hall Level if the other criteria are a match
   If $gold >= $GUIGold And $elix >= $GUIElix And $dark >= $GUIDark Then
	  Local $location, $top, $left
	  $townHall = GetTownHallLevel($location, $left, $top)
	  SetAutoRaidResults($gold, $elix, $dark, $cups, $townHall, $deadBase)
   EndIf

   ; Do we have a gold/elix/dark/townhall/dead match?
   If ($GUIIgnoreStorages = False And $gold >= $GUIGold And $elix >= $GUIElix And $dark >= $GUIDark) Or _
	  ($GUIIgnoreStorages = True And $adjGold >= $GUIGold And $adjElix >= $GUIElix And $adjDark >= $GUIDark) Then

	  If $townHall <= $GUITownHall And $townHall > 0 Then
		 If $GUIIgnoreStorages = True Then
			DebugWrite("Found Match: " & $gold & " / " & $elix & " / " & $dark & " / " & $townHall & " / " & $deadBase & _
					   " (Adj: " & $adjGold & " / " & $adjElix & " / " & $adjDark & ")")
		 Else
			DebugWrite("Found Match: " & $gold & " / " & $elix & " / " & $dark & " / " & $townHall & " / " & $deadBase)
		 EndIf

		 SetAutoRaidResults($gold, $elix, $dark, $cups, $townHall, $deadBase)
		 Return $eAutoExecute
	  EndIf
   EndIf

   If $GUIIgnoreStorages = True Then
	  DebugWrite("No match:  " & $gold & " / " & $elix & " / " & $dark &  " / " & $cups & " / " & $townHall & " / " & $deadBase & _
				 " (Adj: " & $adjGold & " / " & $adjElix & " / " & $adjDark & ")")
   Else
	  DebugWrite("No match:  " & $gold & " / " & $elix & " / " & $dark &  " / " & $cups & " / " & $townHall & " / " & $deadBase)
   EndIf

   SetAutoRaidResults($gold, $elix, $dark, $cups, $townHall, $deadBase)
   Return False
EndFunc

Func AutoRaidUpdateProgress()
   GetMyLootNumbers()

   $gAutoRaidEndLoot[0] = GUICtrlRead($GUI_MyGold)
   $gAutoRaidEndLoot[1] = GUICtrlRead($GUI_MyElix)
   $gAutoRaidEndLoot[2] = GUICtrlRead($GUI_MyDark)
   $gAutoRaidEndLoot[3] = GUICtrlRead($GUI_MyCups)

   DebugWrite("AutoRaid Change: " & _
	  " Gold:" & $gAutoRaidEndLoot[0] - $gAutoRaidBeginLoot[0] & _
	  " Elix:" & $gAutoRaidEndLoot[1] - $gAutoRaidBeginLoot[1] & _
	  " Dark:" & $gAutoRaidEndLoot[2] - $gAutoRaidBeginLoot[2] & _
	  " Cups:" & $gAutoRaidEndLoot[3] - $gAutoRaidBeginLoot[3] & @CRLF)
EndFunc

; howMany: $eAutoRaidDeploySixtyPercent, $eAutoRaidDeployRemaining, $eAutoRaidDeployOneTroop
Func DeployTroopsToSides(Const $troop, Const ByRef $index, Const $howMany, Const $dir)
   DebugWrite("DeployTroopsToSides()")
   Local $xClick, $yClick

   ; Handle the deploy one troop situation first
   If $howMany=$eAutoRaidDeployOneTroop Then
	  RandomWeightedCoords( ($dir = "Top" ? $NWSafeDeployBox : $SWSafeDeployBox), $xClick, $yClick)
	  _MouseClickFast($xClick, $yClick)
	  Return
   EndIf

   ; Do initial deployment
   Local $troopsAvailable = GetAvailableTroops($troop, $index)
   Local $troopsToDeploy = ($howMany=$eAutoRaidDeploySixtyPercent ? Int($troopsAvailable * 0.6) : $troopsAvailable)

   DebugWrite("Available: " & $troopsAvailable & ", deploying " & ($howMany=$eAutoRaidDeploySixtyPercent ? "60% " : "Remaining ") & _
	  " =" & $troopsToDeploy)

   Local $clickPoints1[$troopsToDeploy][2]
   ; Always deploy first set of troops left to right to avoid accidentally clicking the Next button
   GetAutoRaidClickPoints(0, $dir, $troopsToDeploy, $clickPoints1)

   For $i = 0 To $troopsToDeploy-1
	  _MouseClickFast($clickPoints1[$i][0], $clickPoints1[$i][1])
	  Sleep($gDeployTroopClickDelay)
   Next

   ; If we are only deploying 60% then we are done
   If $howMany=$eAutoRaidDeploySixtyPercent Then Return

   ; If we are deploying all, then check remaining and continue to deploy to make sure they all get out there
   $troopsAvailable = GetAvailableTroops($troop, $index)

   If $troopsAvailable>0 Then
	  DebugWrite("Continuing: " & $troopsAvailable & " troops available.")

	  Local $clickPoints2[$troopsAvailable][2]
	  GetAutoRaidClickPoints(Random(0,1,1), $dir, $troopsAvailable, $clickPoints2)

	  For $i = 0 To $troopsAvailable-1
		 _MouseClickFast($clickPoints2[$i][0], $clickPoints2[$i][1])
		 Sleep($gDeployTroopClickDelay)
	  Next
   EndIf

   $troopsAvailable = GetAvailableTroops($troop, $index)
   If $troopsAvailable>0 Then
	  DebugWrite("Finishing to safe boxes: " & $troopsAvailable & " troops available.")
	  DeployTroopsToSafeBoxes($troop, $index, $dir)
   EndIf
EndFunc

Func DeployTroopsToSafeBoxes(Const $troop, Const ByRef $index, Const $dir)
   DebugWrite("DeployTroopsToSafeBoxes()")
   Local $xClick, $yClick, $count

   ; Deploy half to left
   Local $troopsAvailable = Int(GetAvailableTroops($troop, $index) / 2)
   DebugWrite("Deploying to left safe box: " & $troopsAvailable & " troops.")
   $count=0
   For $i = 1 To $troopsAvailable
	  RandomWeightedCoords( ($dir = "Top" ? $NWSafeDeployBox : $SWSafeDeployBox), $xClick, $yClick)
	  _MouseClickFast($xClick, $yClick)
	  Sleep($gDeployTroopClickDelay)
	  $count+=1
   Next

   ; Deploy half to right
   $troopsAvailable = GetAvailableTroops($troop, $index)
   DebugWrite("Deploying to right safe box: " & $troopsAvailable & " troops.")
   $count=0
   For $i = 1 To $troopsAvailable
   	  RandomWeightedCoords( ($dir = "Top" ? $NESafeDeployBox : $SESafeDeployBox), $xClick, $yClick)
	  _MouseClickFast($xClick, $yClick)
	  Sleep($gDeployTroopClickDelay)
	  $count+=1
   Next
EndFunc

Func LocateCollectors(ByRef $matchX, ByRef $matchY)
   DebugWrite("LocateCollectors()")

   ; Move screen up 65 pixels
   MoveScreenUpToCenter(65)

   ; Grab frame
   GrabFrameToFile("AutoRaidCollectorFrame.bmp")

   ; Find all the collectors that need clicking in the frame
   Local $matchCount = 0

   For $i = 0 To UBound($CollectorBMPs)-1
	  ; Get matches for this resource
	  Local $res = DllCall("ImageMatch.dll", "str", "FindAllMatches", "str", "AutoRaidCollectorFrame.bmp", _
			   "str", "Images\"&$CollectorBMPs[$i], "int", 3, "int", 6, "double", $gConfidenceCollector)
	  Local $split = StringSplit($res[0], "|", 2)
	  ;DebugWrite("Num matches " & $CollectorBMPs[$i] & ": " & $split[0])

	  For $j = 0 To $split[0]-1
		 ; Loop through all captured points so far, if this one is within 8 pix of an existing one,
		 ; then skip it.
		 Local $alreadyFound = False
		 For $k = 0 To $matchCount-1
			If DistBetweenTwoPoints($split[$j*3+1], $split[$j*3+2], $matchX[$k], $matchY[$k]) < 8 Then
			   $alreadyFound = True
			   ;DebugWrite("    Already found " & $j & ": " & $split[$j*3+1] & "," & $split[$j*3+2] & "  " & $split[$j*3+3])
			   ExitLoop
			EndIf
		 Next

		 ; Otherwise add it to the growing list of matches, if it is $gConfidenceCollectorsSearch % or greater confidence
		 If $alreadyFound = False Then
			If $split[$j*3+3] > $gConfidenceCollector Then
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

   ; Move screen back down 65 pixels
   MoveScreenDownToCenter(65)
EndFunc

Func GetRandomAutoRaidDeployBox(Const $direction, ByRef $box)
   Local $side = Random()>0.5 ? "Left" : "Right"
   Local $boxIndex = Random(0, 20, 1)

   If $direction = "Top" Then
	  For $j = 0 To 3
		 $box[$j] = ($side = "Left") ? $NWDeployBoxes[$boxIndex][$j] : $NEDeployBoxes[$boxIndex][$j]
	  Next
   Else
	  For $j = 0 To 3
		 $box[$j] = ($side = "Left") ? $SWDeployBoxes[$boxIndex][$j] : $SEDeployBoxes[$boxIndex][$j]
	  Next
   EndIf

EndFunc

Func GetAutoRaidClickPoints(Const $order, Const $topBotDirection, Const $numberPoints, ByRef $points)
   ; First parameter is 0 = ascending, 1 = descending
   For $i = 0 To $numberPoints-1
	  Local $deployBox[4]
	  GetRandomAutoRaidDeployBox($topBotDirection, $deployBox)
	  RandomCoords($deployBox, $points[$i][0], $points[$i][1])
   Next

   _ArraySort($points, $order)
EndFunc

Func WaitForBattleEnd(Const $kingDeployed, Const $queenDeployed)
   DebugWrite("WaitForBattleEnd()")
   ; Wait for battle end screen

   Local $lastGold = 0, $lastElix = 0, $lastDark = 0
   Local $activeTimer = TimerInit()

   For $i = 1 To 180  ; 3 minutes max until battle end screen appears
	  If WhereAmI() = $eScreenEndBattle Then ExitLoop

	  ; Get available loot remaining
	  Local $goldRemaining = Number(ScrapeFuzzyText($gRaidLootCharMaps, $rGoldTextBox, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))
	  Local $elixRemaining = Number(ScrapeFuzzyText($gRaidLootCharMaps, $rElixTextBox, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))
	  Local $darkRemaining = Number(ScrapeFuzzyText($gRaidLootCharMaps, $rDarkTextBox, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))

	  ; If loot has changed, then reset timer
	  If $goldRemaining<>$lastGold Or $elixRemaining<>$lastElix Or $darkRemaining<>$lastDark Then
		 $lastGold = $goldRemaining
		 $lastElix = $elixRemaining
		 $lastDark = $darkRemaining
		 $activeTimer = TimerInit()
	  EndIf

	  ; If 30 seconds have passed, with no change in available loot, then exit battle, but only if we have not
	  ; deployed a king or queen
	  If TimerDiff($activeTimer) > 30000 And $kingDeployed = False And $queenDeployed = False Then
		 $activeTimer = TimerInit()
		 DebugWrite("No change in available loot for 30 seconds, ending battle.")

		 ; Click End Battle button
		 RandomWeightedClick($rLiveRaidScreenEndBattleButton)

		 ; Wait for confirmation button
		 Local $failCount=20
		 While IsButtonPresent($rLiveRaidScreenEndBattleConfirmButton)=False And $failCount>0
			Sleep(100)
			$failCount-=1
		 WEnd

		 If $failCount>0 Then
			RandomWeightedClick($rLiveRaidScreenEndBattleConfirmButton)
			Sleep(500)
		 EndIf
	  EndIf

	  Sleep(1000)
   Next

   Sleep(2000)

   If WhereAmI() = $eScreenEndBattle Then
	  GrabFrameToFile("EndBattleFrame.bmp")
	  Local $goldWin = ScrapeFuzzyText($gExtraLargeCharacterMaps, $rEndBattleGoldTextBox, $gExtraLargeCharMapsMaxWidth, $eScrapeDropSpaces)
	  Local $elixWin = ScrapeFuzzyText($gExtraLargeCharacterMaps, $rEndBattleElixTextBox, $gExtraLargeCharMapsMaxWidth, $eScrapeDropSpaces)
	  Local $darkWin = IsTextBoxPresent($rEndBattleDarkTextBox) ? ScrapeFuzzyText($gExtraLargeCharacterMaps, $rEndBattleDarkTextBox, $gExtraLargeCharMapsMaxWidth, $eScrapeDropSpaces) : 0
	  Local $cupsWin = IsTextBoxPresent($rEndBattleCups1TextBox) ? _
					   ScrapeFuzzyText($gExtraLargeCharacterMaps, $rEndBattleCups1TextBox, $gExtraLargeCharMapsMaxWidth, $eScrapeDropSpaces) : _
					   ScrapeFuzzyText($gExtraLargeCharacterMaps, $rEndBattleCups2TextBox, $gExtraLargeCharMapsMaxWidth, $eScrapeDropSpaces)

	  Local $goldBonus = 0
	  Local $elixBonus = 0
	  Local $darkBonus = 0
	  If IsTextBoxPresent($rEndBattleBonusGoldTextBox) Or _
		 IsTextBoxPresent($rEndBattleBonusElixTextBox) Or _
		 IsTextBoxPresent($rEndBattleBonusDarkTextBox) Then

		 $goldBonus = ScrapeFuzzyText($gSmallCharacterMaps, $rEndBattleBonusGoldTextBox, $gExtraLargeCharMapsMaxWidth, $eScrapeDropSpaces)
		 If StringLeft($goldBonus, 1) = "+" Then $goldBonus = StringMid($goldBonus, 2)
		 $elixBonus = ScrapeFuzzyText($gSmallCharacterMaps, $rEndBattleBonusElixTextBox, $gExtraLargeCharMapsMaxWidth, $eScrapeDropSpaces)
		 If StringLeft($elixBonus, 1) = "+" Then $elixBonus = StringMid($elixBonus, 2)
		 $darkBonus = ScrapeFuzzyText($gSmallCharacterMaps, $rEndBattleBonusDarkTextBox, $gExtraLargeCharMapsMaxWidth, $eScrapeDropSpaces)
		 If StringLeft($darkBonus, 1) = "+" Then $darkBonus = StringMid($darkBonus, 2)
	  EndIf

	  DebugWrite("Winnings this match: " & $goldWin & " / " & $elixWin & " / " & $darkWin & " / " & $cupsWin)
	  DebugWrite("Bonus this match: " & $goldBonus & " / " & $elixBonus & " / " & $darkBonus)

	  $gAutoRaidWinnings[0] += $goldWin+$goldBonus
	  $gAutoRaidWinnings[1] += $elixWin+$elixBonus
	  $gAutoRaidWinnings[2] += $darkWin+$darkBonus
	  $gAutoRaidWinnings[3] += $cupsWin
	  GUICtrlSetData($GUI_Winnings, "Winnings: " & $gAutoRaidWinnings[0] & " / " & $gAutoRaidWinnings[1] & " / " _
					 & $gAutoRaidWinnings[2] & " / " & $gAutoRaidWinnings[3])

	  ; Close battle end screen
	  RandomWeightedClick($rBattleHasEndedScreenReturnHomeButton)

	  ; Wait for main screen
	  Local $failCount=10
	  While WhereAmI()<>$eScreenMain And $failCount>0
		 Sleep(1000)
		 $failCount-=1
	  WEnd

	  If $failCount=0 Then
		 DebugWrite("Battle end - error waiting for main screen")
	  EndIf
   EndIf
EndFunc

Func FindRaidTroopSlots(Const ByRef $bitmaps, ByRef $index)
   ; Populates index with the client area coords of all available troop buttons
   Local $buttonOffset[4] = [0, -15, 52, 54]
   Local $raidTroopBox[4] = [0, 456, 1023, 531]

   GrabFrameToFile("AvailableRaidTroopsFrame.bmp", $raidTroopBox[0], $raidTroopBox[1], $raidTroopBox[2], $raidTroopBox[3])

   For $i = 0 To UBound($bitmaps)-1
	  Local $res = DllCall("ImageMatch.dll", "str", "FindMatch", "str", "AvailableRaidTroopsFrame.bmp", "str", "Images\"&$bitmaps[$i], "int", 3)
	  Local $split = StringSplit($res[0], "|", 2) ; x, y, conf

	  If $split[2] > $gConfidenceRaidTroopSlot Then
		 $index[$i][0] = $split[0]+$raidTroopBox[0]+$buttonOffset[0]
		 $index[$i][1] = $split[1]+$raidTroopBox[1]+$buttonOffset[1]
		 $index[$i][2] = $split[0]+$raidTroopBox[0]+$buttonOffset[2]
		 $index[$i][3] = $split[1]+$raidTroopBox[1]+$buttonOffset[3]
		 DebugWrite("Raid troop " & $bitmaps[$i] & " found at " & $index[$i][0] & ", " & $index[$i][1] & " conf: " & $split[2])
	  Else
		 $index[$i][0] = -1
		 $index[$i][1] = -1
		 $index[$i][2] = -1
		 $index[$i][3] = -1
	  EndIf
   Next
EndFunc

Func GetAvailableTroops(Const $troop, Const ByRef $index)
   If $index[$troop][0] = -1 Then Return 0

   Local $textBox[10] = [$index[$troop][0]+5, $index[$troop][1], $index[$troop][2]-5, $index[$troop][1]+10, _
						 $rBarracksTroopCountTextBox[4], $rBarracksTroopCountTextBox[5], _
						 0, 0, 0, 0]
   Local $t = ScrapeFuzzyText($gSmallCharacterMaps, $textBox, $gSmallCharMapsMaxWidth, $eScrapeDropSpaces)
   ;DebugWrite("GetAvailableTroops() = " & $t)

   Return StringMid($t, 2)
EndFunc

