Func AutoRaid(ByRef $timer)
   ;DebugWrite("AutoRaid()")

   Switch $gAutoStage

   ; Stage Queue Training
   Case $eAutoQueueTraining
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Queue Training")

	  ResetToCoCMainScreen()

	  AutoQueueTroops(True)
	  $timer = TimerInit()

   ; Stage Wait For Training To Complete
   Case $eAutoWaitForTrainingToComplete

	  If TimerDiff($timer) >= $gTroopTrainingCheckInterval Then
		 ResetToCoCMainScreen()
		 AutoQueueTroops(False)
		 $timer = TimerInit()
	  EndIf

   ; Stage Find Match
   Case $eAutoFindMatch
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Find Match")

	  ResetToCoCMainScreen()

	  If AutoRaidFindMatch()=False Then
		 ; Reset if there was an error
		 DebugWrite("Auto: Error finding match, resetting.")
		 ResetToCoCMainScreen()
		 $gAutoStage = $eAutoQueueTraining
	  Else
		 $gAutoStage = $eAutoExecute
	  EndIf

   ; Stage Execute Raid
   Case $eAutoExecute
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Execute Raid")

	  Switch _GUICtrlComboBox_GetCurSel($GUI_AutoRaidStrategyCombo)
	  Case 0
		 If AutoRaidExecuteRaidStrategy0() Then  ; BARCH
			$gAutoStage = $eAutoQueueTraining
			UpdateWinnings()
		 EndIf
	  Case 1
		 If AutoRaidExecuteRaidStrategy1() Then  ; GiBarch
			$gAutoStage = $eAutoQueueTraining
			UpdateWinnings()
		 EndIf
	  Case 2
		 If AutoRaidExecuteRaidStrategy2() Then  ; BAM
			$gAutoStage = $eAutoQueueTraining
			UpdateWinnings()
		 EndIf
	  Case 3
		 If AutoRaidExecuteRaidStrategy3() Then  ; Loonian
			$gAutoStage = $eAutoQueueTraining
			UpdateWinnings()
		 EndIf
	  EndSwitch

	  GUICtrlSetData($GUI_AutoStatus, "Auto: Raid Complete")
   EndSwitch
EndFunc

Func AutoRaidFindMatch(Const $returnFirstMatch = False)
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
	  Local $cPos = GetClientPos()
	  Local $color = PixelGetColor($cPos[0]+$rFindMatchScreenFindAMatchButton[4], $cPos[1]+$rFindMatchScreenFindAMatchButton[5])
	  DebugWrite("Find Match failed - timeout waiting for Find a Match button, color = " & Hex($color))
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
		 $raidable = CheckForRaidableBase()

	  EndIf

	  ; If raidable, then go do it
	  If $raidable<>False Then
		 If _GUICtrlButton_GetCheck($GUI_FindMatchCheckBox) = $BST_CHECKED Then ShowFindMatchPopup()
		 Return $raidable
	  EndIf

	  ; Not raidable - click Next
	  Sleep($gPauseBetweenNexts)
	  If IsButtonPresent($rWaitRaidScreenNextButton) Then
		 RandomWeightedClick($rWaitRaidScreenNextButton)
		 Sleep(500)
	  Else
		 DebugWrite("Next Button disappeared, resetting.")

		 If IsButtonPresent($rLiveRaidScreenEndBattleButton) Then
			RandomWeightedClick($rLiveRaidScreenEndBattleButton)
			Sleep(1000)

			If IsButtonPresent($rLiveRaidScreenEndBattleConfirmButton) Then
			   RandomWeightedClick($rLiveRaidScreenEndBattleConfirmButton)
			   Sleep(1000)
			EndIf

		 Else
			ResetToCoCMainScreen()

		 EndIf

		 Return False
	  EndIf

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
   Local $dark = 0
   Local $cups = 0
   Local $townHall = -1

   If IsTextBoxPresent($rDarkTextBox)=False Then
	  $cups = Number(ScrapeFuzzyText($gRaidLootCharMaps, $rCupsTextBox1, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))
   Else
	  $dark = Number(ScrapeFuzzyText($gRaidLootCharMaps, $rDarkTextBox, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))
	  $cups = Number(ScrapeFuzzyText($gRaidLootCharMaps, $rCupsTextBox2, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))
   EndIf

   Local $deadBase = IsColorPresent($rDeadBaseIndicatorColor)

   ; Grab settings from the GUI
   Local $GUIGold = GUICtrlRead($GUI_GoldEdit)
   Local $GUIElix = GUICtrlRead($GUI_ElixEdit)
   Local $GUIDark = GUICtrlRead($GUI_DarkEdit)
   Local $GUITownHall = GUICtrlRead($GUI_TownHallEdit)
   Local $GUIIgnoreStorages = (_GUICtrlButton_GetCheck($GUI_AutoRaidIgnoreStorages) = $BST_CHECKED)
   Local $myTHLevel = GUICtrlRead($GUI_MyTownHall)

   ; Adjust available loot to exclude storages
   Local $adjGold=$gold, $adjElix=$elix, $adjDark=$dark
   If $GUIIgnoreStorages Then
	  If $gold>=$GUIGold And $elix>=$GUIElix And $dark>=$GUIDark Then
		 ; Get Town Hall level
		 Local $location, $top, $left
		 $townHall = GetTownHallLevel($location, $left, $top)
		 SetAutoRaidResults($gold, $elix, $dark, $cups, $townHall, $deadBase)

		 If $townHall = -1 Or $townHall>$GUITownHall Then
			DebugWrite("No match:  " & $gold & " / " & $elix & " / " & $dark &  " / " & $cups & " / " & $townHall & " / " & $deadBase)
			Return False
		 EndIf

		 ; Figure the adjustment
		 AutoRaidAdjustLootForStorages($townHall, $gold, $elix, $adjGold, $adjElix)
	  Else
		 SetAutoRaidResults($gold, $elix, $dark, $cups, $townHall, $deadBase)
		 DebugWrite("No match:  " & $gold & " / " & $elix & " / " & $dark &  " / " & $cups & " / " & $townHall & " / " & $deadBase)
		 Return False
	  EndIf
   EndIf

   SetAutoRaidResults($gold, $elix, $dark, $cups, $townHall, $deadBase)

   ; Do we have a gold/elix/dark/townhall/dead match?
   If $GUIIgnoreStorages And $myTHLevel-$townHall<2 Then ; "ignore storages" only valid if target TH < 2 levels from my TH level
	  If $adjGold>=$GUIGold And $adjElix>=$GUIElix And $adjDark>=$GUIDark Then
		 DebugWrite("Found Match: " & $gold & " / " & $elix & " / " & $dark & " / " & $townHall & " / " & $deadBase & _
					" (Adj: " & $adjGold & " / " & $adjElix & ")" )
		 Return $eAutoExecute
	  Else
		 DebugWrite("No match:  " & $gold & " / " & $elix & " / " & $dark &  " / " & $cups & " / " & $townHall & " / " & $deadBase & _
					" (Adj: " & $adjGold & " / " & $adjElix & ")" )
		 Return False
	  EndIf

   Else
	  If $gold >= $GUIGold And $elix >= $GUIElix And $dark >= $GUIDark Then
		 ; Get Town Hall level
		 Local $location, $top, $left
		 $townHall = GetTownHallLevel($location, $left, $top)
		 SetAutoRaidResults($gold, $elix, $dark, $cups, $townHall, $deadBase)

		 If $townHall = -1 Or $townHall>$GUITownHall Then
			DebugWrite("No match:  " & $gold & " / " & $elix & " / " & $dark &  " / " & $cups & " / " & $townHall & " / " & $deadBase)
			Return False
		 Else
			DebugWrite("Found Match: " & $gold & " / " & $elix & " / " & $dark & " / " & $townHall & " / " & $deadBase)
			Return $eAutoExecute
		 EndIf
	  Else
		 DebugWrite("No match:  " & $gold & " / " & $elix & " / " & $dark &  " / " & $cups & " / " & $townHall & " / " & $deadBase)
		 Return False
	  EndIf
   EndIf

EndFunc

; Based on loot calculation information here: http://clashofclans.wikia.com/wiki/Raids
Func AutoRaidAdjustLootForStorages(Const $townHall, Const $gold, Const $elix, ByRef $adjGold, ByRef $adjElix)
   GrabFrameToFile("StorageUsageFrame.bmp", 261, 100, 761, 450)
   Local $x, $y, $conf, $matchIndex, $saveFrame = False
   Local $usageAdj = 10; 12.5
   Local $myTHLevel = GUICtrlRead($GUI_MyTownHall)

   ; Gold
   ScanFrameForBestBMP("StorageUsageFrame.bmp", $GoldStorageBMPs, $gConfidenceStorages, $matchIndex, $conf, $x, $y)

   If $matchIndex = -1 Then
	  $saveFrame = True
	  DebugWrite("Could not find gold storage match.")
   Else
	  Local $s = $GoldStorageBMPs[$matchIndex]
	  Local $level = Number(StringMid($s, StringInStr($s, "GoldStorageL")+12, 2))
	  Local $usage = Number(StringMid($s, StringInStr($s, "GoldStorageL")+15, 2))
	  $usage = ($usage+$usageAdj>100 ? 100 : $usage+$usageAdj) ; number in the filename is lower bound of range, adjust for better filtering
	  DebugWrite("Found gold storage level " & $level & ", average " & $usage & "% full, confidence " & Round($conf*100, 2) & "%")
	  $adjGold = $gold - CalculateLootInStorage($myTHLevel, $townHall, $level, $usage/100)
	  $adjGold = ($adjGold<0 ? 0 : $adjGold)
   EndIf

   ; Elixir
   ScanFrameForBestBMP("StorageUsageFrame.bmp", $ElixStorageBMPs, $gConfidenceStorages, $matchIndex, $conf, $x, $y)

   If $matchIndex = -1 Then
	  $saveFrame = True
	  DebugWrite("Could not find elixir storage match.")
   Else
	  Local $s = $ElixStorageBMPs[$matchIndex]
	  Local $level = Number(StringMid($s, StringInStr($s, "ElixStorageL")+12, 2))
	  Local $usage = Number(StringMid($s, StringInStr($s, "ElixStorageL")+15, 2))
	  $usage = ($usage+$usageAdj>100 ? 100 : $usage+$usageAdj) ; number in the filename is lower bound of range, adjust for better filtering
	  DebugWrite("Found elix storage level " & $level & ", average " & $usage & "% full, confidence " & Round($conf*100, 2) & "%")
	  $adjElix = $elix - CalculateLootInStorage($myTHLevel, $townHall, $level, $usage/100)
	  $adjElix = ($adjElix<0 ? 0 : $adjElix)
   EndIf
EndFunc

Func CalculateLootInStorage(Const $myTHLevel, Const $targetTHLevel, Const $level, Const $usage)
   ; How much is in the storage, based on storage level and usage amount?
   ; Assume maximum number of storages for a given TH level
   Local $inStorage
   If $level=11 And $targetTHLevel>=9 Then ; TH9 and higher can have 4 storages
	  $inStorage = 8000000 * $usage
   ElseIf $level=11 And $targetTHLevel=8 Then ; TH8 can have 3 storages
	  $inStorage = 6000000 * $usage
   ElseIf $level=11 And $targetTHLevel<=7 Then ; TH7 and lower can have 2 storages
	  $inStorage = 4000000 * $usage
   ElseIf $level=10 And $targetTHLevel>=9 Then ; TH9 and higher can have 4 storages
	  $inStorage = 4000000 * $usage
   ElseIf $level=10 And $targetTHLevel=8 Then ; TH8 can have 3 storages
	  $inStorage = 3000000 * $usage
   ElseIf $level=10 And $targetTHLevel<=7 Then ; TH7 and lower can have 2 storages
	  $inStorage = 2000000 * $usage
   Else
	  ; TODO: add logic here for other level storages once/if those images are captured
	  $inStorage = 2000000
   EndIf
   DebugWrite("Estimated amount in storage = " & $inStorage)

   ; How much of what is in the storage is available to loot, given the target TH level?
   Local $availabletoLoot
   If $targetTHLevel=10 Then
	  $availabletoLoot = $inStorage*0.1
	  If $availabletoLoot > 400000 Then $availabletoLoot = 400000
   ElseIf $targetTHLevel=9 Then
	  $availabletoLoot = $inStorage*0.12
	  If $availabletoLoot > 350000 Then $availabletoLoot = 350000
   ElseIf $targetTHLevel=8 Then
	  $availabletoLoot = $inStorage*0.14
	  If $availabletoLoot > 300000 Then $availabletoLoot = 300000
   ElseIf $targetTHLevel=7 Then
	  $availabletoLoot = $inStorage*0.16
	  If $availabletoLoot > 250000 Then $availabletoLoot = 250000
   ElseIf $targetTHLevel=6 Then
	  $availabletoLoot = $inStorage*0.18
	  If $availabletoLoot > 200000 Then $availabletoLoot = 200000
   Else
	  $availabletoLoot = $inStorage*0.20
	  If $availabletoLoot > 200000 Then $availabletoLoot = 200000
   EndIf
   DebugWrite("Available to loot from storage = " & $availabletoLoot)

   ; Adjust available to loot amount by loot penalty
   If $myTHLevel-$targetTHLevel <= 0 Then
	  $availabletoLoot*=1 ; no penalty if raiding a base that is my town hall level or higher
   ElseIf $myTHLevel-$targetTHLevel = 1 Then
	  $availabletoLoot*=0.90
   ElseIf $myTHLevel-$targetTHLevel = 2 Then
	  $availabletoLoot*=0.50
   ElseIf $myTHLevel-$targetTHLevel = 3 Then
	  $availabletoLoot*=0.25
   Else
	  $availabletoLoot*=0.05
   EndIf
   DebugWrite("Available to loot from storage after penalty = " & $availabletoLoot)

   Return $availabletoLoot
EndFunc

; howMany: $eAutoRaidDeployFiftyPercent, $eAutoRaidDeploySixtyPercent, $eAutoRaidDeployRemaining, $eAutoRaidDeployOneTroop
Func DeployTroopsToSides(Const $troop, Const ByRef $index, Const $howMany, Const $dir, Const $boxesPerSide)
   DebugWrite("DeployTroopsToSides()")
   Local $xClick, $yClick
   Local $troopButton[4] = [$index[$troop][0], $index[$troop][1], $index[$troop][2], $index[$troop][3]]

   ; Handle the deploy one troop situation first
   If $howMany=$eAutoRaidDeployOneTroop Then
	  RandomWeightedClick($troopButton)
	  RandomWeightedCoords( ($dir = "Top" ? $NWSafeDeployBox : $SWSafeDeployBox), $xClick, $yClick)
	  _MouseClickFast($xClick, $yClick)
	  Return
   EndIf

   ; Firgure out how many of the available to deploy
   Local $troopsAvailable = GetAvailableTroops($troop, $index)
   Local $troopsToDeploy
   If $howMany = $eAutoRaidDeploySixtyPercent Then
	    $troopsToDeploy = Int($troopsAvailable * 0.6)
   ElseIf $howMany = $eAutoRaidDeployFiftyPercent Then
	    $troopsToDeploy = Int($troopsAvailable * 0.5)
   Else
	    $troopsToDeploy = $troopsAvailable
	 EndIf

   DebugWrite("Available: " & $troopsAvailable & ", deploying " & $troopsToDeploy)

   ; Deploy the troops
   Local $clickPoints1[$troopsToDeploy][2]
   ; Always deploy first set of troops left to right to avoid accidentally clicking the Next button
   GetAutoRaidClickPoints(0, $dir, $troopsToDeploy, $boxesPerSide, $clickPoints1)

   RandomWeightedClick($troopButton)
   Sleep(200)

   For $i = 0 To $troopsToDeploy-1
	  _MouseClickFast($clickPoints1[$i][0], $clickPoints1[$i][1])
	  Sleep($gDeployTroopClickDelay)
   Next

   ; If we are only deploying 50% or 60% then we are done
   If $howMany=$eAutoRaidDeploySixtyPercent Or $howMany=$eAutoRaidDeployFiftyPercent Then Return

   ; If we are deploying all, then check remaining and continue to deploy to make sure they all get out there
   $troopsAvailable = GetAvailableTroops($troop, $index)

   If $troopsAvailable>0 Then
	  DebugWrite("Continuing: " & $troopsAvailable & " troops available.")

	  Local $clickPoints2[$troopsAvailable][2]
	  GetAutoRaidClickPoints(Random(0,1,1), $dir, $troopsAvailable, $boxesPerSide, $clickPoints2)

	  RandomWeightedClick($troopButton)
	  Sleep(200)

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
   Local $troopButton[4] = [$index[$troop][0], $index[$troop][1], $index[$troop][2], $index[$troop][3]]

   ; Deploy half to left
   Local $troopsAvailable = Int(GetAvailableTroops($troop, $index) / 2)
   DebugWrite("Deploying to left safe box: " & $troopsAvailable & " troops.")
   $count=0
   RandomWeightedClick($troopButton)
   Sleep(200)

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
   RandomWeightedClick($troopButton)
   Sleep(200)

   For $i = 1 To $troopsAvailable
   	  RandomWeightedCoords( ($dir = "Top" ? $NESafeDeployBox : $SESafeDeployBox), $xClick, $yClick)
	  _MouseClickFast($xClick, $yClick)
	  Sleep($gDeployTroopClickDelay)
	  $count+=1
   Next
EndFunc

Func GetRandomAutoRaidDeployBox(Const $direction, Const $boxesPerSide, ByRef $box)
   Local $side = Random()>0.5 ? "Left" : "Right"
   Local $boxIndex = Random(20-$boxesPerSide+1, 20, 1)

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

Func GetAutoRaidClickPoints(Const $order, Const $topBotDirection, Const $numberPoints, Const $boxesPerSide, ByRef $points)
   ; First parameter is 0 = ascending, 1 = descending
   For $i = 0 To $numberPoints-1
	  Local $deployBox[4]
	  GetRandomAutoRaidDeployBox($topBotDirection, $boxesPerSide, $deployBox)
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

	  ; End early?
	  ; If $gAutoRaidEndDelay=0, the use the legacy logic: If 30 seconds have passed with no change in available loot, then
	  ;   exit battle, but only if we have not deployed a king or queen.  If BK or AQ deployed, then do not end early.
	  ; Otherwise end after $gAutoRaidEndDelay number of seconds.
	  If ($gAutoRaidEndDelay=0 And TimerDiff($activeTimer)>30000 And $kingDeployed=False And $queenDeployed=False) Or _
		 ($gAutoRaidEndDelay<>0 And TimerDiff($activeTimer)>$gAutoRaidEndDelay*1000) Then

		 If $gAutoRaidEndDelay=0 Then
			DebugWrite("No change in available loot for 30 seconds, ending battle.")
		 Else
			DebugWrite("No change in available loot for " & $gAutoRaidEndDelay & " seconds, ending battle.")
		 EndIf

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
		 $goldBonus = StringLeft($goldBonus, 1) = "+" ? StringMid($goldBonus, 2) : 0
		 $elixBonus = ScrapeFuzzyText($gSmallCharacterMaps, $rEndBattleBonusElixTextBox, $gExtraLargeCharMapsMaxWidth, $eScrapeDropSpaces)
		 $elixBonus = StringLeft($elixBonus, 1) = "+" ? StringMid($elixBonus, 2) : 0
		 $darkBonus = ScrapeFuzzyText($gSmallCharacterMaps, $rEndBattleBonusDarkTextBox, $gExtraLargeCharMapsMaxWidth, $eScrapeDropSpaces)
		 $darkBonus = StringLeft($darkBonus, 1) = "+" ? StringMid($darkBonus, 2) : 0
	  EndIf

	  DebugWrite("Winnings this match: " & $goldWin & " / " & $elixWin & " / " & $darkWin & " / " & $cupsWin)
	  DebugWrite("Bonus this match: " & $goldBonus & " / " & $elixBonus & " / " & $darkBonus)

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
   Local $raidTroopBox1[4] = [173, 456, 228, 531] ; first button only
   Local $raidTroopBox2[4] = [235, 456, 850, 531] ; buttons 2-11

   For $i = 0 To UBound($index)-1
	  $index[$i][0] = -1
	  $index[$i][1] = -1
	  $index[$i][2] = -1
	  $index[$i][3] = -1
   Next

   ; Check first button
   RandomWeightedClick($rRaidSlotsButton2)
   Sleep(200)

   GrabFrameToFile("AvailableRaidTroopsFrame1.bmp", $raidTroopBox1[0], $raidTroopBox1[1], $raidTroopBox1[2], $raidTroopBox1[3])

   For $i = 0 To UBound($bitmaps)-1
	  Local $res = DllCall("ImageMatch.dll", "str", "FindMatch", "str", "AvailableRaidTroopsFrame1.bmp", "str", "Images\"&$bitmaps[$i], "int", 3)
	  Local $split = StringSplit($res[0], "|", 2) ; x, y, conf

	  If $split[2] > $gConfidenceRaidTroopSlot Then
		 $index[$i][0] = $split[0]+$raidTroopBox1[0]+$buttonOffset[0]
		 $index[$i][1] = $split[1]+$raidTroopBox1[1]+$buttonOffset[1]
		 $index[$i][2] = $split[0]+$raidTroopBox1[0]+$buttonOffset[2]
		 $index[$i][3] = $split[1]+$raidTroopBox1[1]+$buttonOffset[3]
		 ;DebugWrite("Pass 1 Raid troop " & $bitmaps[$i] & " found at " & $index[$i][0] & ", " & $index[$i][1] &  ", " & _
			;		 $index[$i][2] & ", " & $index[$i][3] & " confidence " & Round($split[2]*100, 2) & "%")
		 ExitLoop ; only one possible button in this pass
	  EndIf
   Next

   ; Check buttons 2-11
   RandomWeightedClick($rRaidSlotsButton1)
   Sleep(200)

   GrabFrameToFile("AvailableRaidTroopsFrame2.bmp", $raidTroopBox2[0], $raidTroopBox2[1], $raidTroopBox2[2], $raidTroopBox2[3])

   For $i = 0 To UBound($bitmaps)-1
	  Local $res = DllCall("ImageMatch.dll", "str", "FindMatch", "str", "AvailableRaidTroopsFrame2.bmp", "str", "Images\"&$bitmaps[$i], "int", 3)
	  Local $split = StringSplit($res[0], "|", 2) ; x, y, conf

	  If $split[2] > $gConfidenceRaidTroopSlot Then
		 $index[$i][0] = $split[0]+$raidTroopBox2[0]+$buttonOffset[0]
		 $index[$i][1] = $split[1]+$raidTroopBox2[1]+$buttonOffset[1]
		 $index[$i][2] = $split[0]+$raidTroopBox2[0]+$buttonOffset[2]
		 $index[$i][3] = $split[1]+$raidTroopBox2[1]+$buttonOffset[3]
		 ;DebugWrite("Pass 2 Raid troop " & $bitmaps[$i] & " found at " & $index[$i][0] & ", " & $index[$i][1] &  ", " & _
			;		 $index[$i][2] & ", " & $index[$i][3] & " confidence " & Round($split[2]*100, 2) & "%")
	  EndIf
   Next
EndFunc

Func GetAvailableTroops(Const $troop, Const ByRef $index)
   If $index[$troop][0] = -1 Then Return 0

   Local $midX = $index[$troop][0] + ($index[$troop][2]- $index[$troop][0])/2

   If $midX>$rRaidSlotsButton1[0] And $midX<$rRaidSlotsButton1[2] Then
	  ; This is button 1
	  RandomWeightedClick($rRaidSlotsButton2)
	  Sleep(200)
   Else
	  ; This is not button 1
	  RandomWeightedClick($rRaidSlotsButton1)
	  Sleep(200)
   EndIf

   Local $textBox[10] = [$index[$troop][0]+5, $index[$troop][1], $index[$troop][2]-5, $index[$troop][1]+10, _
						 $rBarracksTroopCountTextBox[4], $rBarracksTroopCountTextBox[5], _
						 0, 0, 0, 0]
   Local $t = ScrapeFuzzyText($gSmallCharacterMaps, $textBox, $gSmallCharMapsMaxWidth, $eScrapeDropSpaces)
   ;DebugWrite("GetAvailableTroops() = " & $t)

   Return StringMid($t, 2)
EndFunc

Func DeployAndMonitorHeroes(Const ByRef $troopIndex, Const $deployStart, Const $direction, Const $boxIndex, ByRef $kingDeployed, ByRef $queenDeployed)

   Local $kingButton[4] = [$troopIndex[$eTroopKing][0], $troopIndex[$eTroopKing][1], $troopIndex[$eTroopKing][2], $troopIndex[$eTroopKing][3]]
   Local $queenButton[4] = [$troopIndex[$eTroopQueen][0], $troopIndex[$eTroopQueen][1], $troopIndex[$eTroopQueen][2], $troopIndex[$eTroopQueen][3]]

   ; Get box to deploy into
   Local $deployBox[4]
   If $direction = "Top" Then
	  If Random() > 0.5 Then
		 $deployBox[0] = $NWDeployBoxes[$boxIndex][0]
		 $deployBox[1] = $NWDeployBoxes[$boxIndex][1]
		 $deployBox[2] = $NWDeployBoxes[$boxIndex][0]+10
		 $deployBox[3] = $NWDeployBoxes[$boxIndex][1]+10
	  Else
		 $deployBox[0] = $NEDeployBoxes[$boxIndex][2]-10
		 $deployBox[1] = $NEDeployBoxes[$boxIndex][1]
		 $deployBox[2] = $NEDeployBoxes[$boxIndex][2]
		 $deployBox[3] = $NEDeployBoxes[$boxIndex][1]+10
	  EndIf

   ElseIf $direction = "Bot" Then
	  If Random() > 0.5 Then
		 $deployBox[0] = $SWDeployBoxes[$boxIndex][0]
		 $deployBox[1] = $SWDeployBoxes[$boxIndex][3]-10
		 $deployBox[2] = $SWDeployBoxes[$boxIndex][0]+10
		 $deployBox[3] = $SWDeployBoxes[$boxIndex][3]
	  Else
		 $deployBox[0] = $SEDeployBoxes[$boxIndex][2]-10
		 $deployBox[1] = $SEDeployBoxes[$boxIndex][3]-10
		 $deployBox[2] = $SEDeployBoxes[$boxIndex][2]
		 $deployBox[3] = $SEDeployBoxes[$boxIndex][3]
	  EndIf
   EndIf

   ; Loop, while monitoring King / Queen health bars, power up king/queen when health falls below green (50%)
   ; Also, deploy queen after specified amount of time after king deploys
   Local $kingDeployTime, $queenDeployTime
   Local $kingPoweredUp=False, $queenPoweredUp=False
   Local $queenDeployDelay = 5000 ; 5 seconds after king
   Local $royaltyDeploySide = Random()

   While (($kingPoweredUp=False And $troopIndex[$eTroopKing][0]<>-1) Or _
	      ($queenPoweredUp=False And $troopIndex[$eTroopQueen][0]<>-1)) And _
		 TimerDiff($deployStart) < 180000 ; 3 minutes

	  ; Get King's health color, and power up if needed
	  If $kingDeployed And $kingPoweredUp = False Then
		 Local $kingColor[4] = [$troopIndex[$eTroopKing][0]+6, $troopIndex[$eTroopKing][1]-8, $rRoyaltyHealthGreenColor[2], $rRoyaltyHealthGreenColor[3]]

		 If IsColorPresent($kingColor) = False Then
			;GrabFrameToFile("PreKingPowerUpFrame" & _Date_Time_GetTickCount() & ".bmp")
			DebugWrite("Powering up King")
			RandomWeightedClick($kingButton)
			$kingPoweredUp = True
		 EndIf
	  EndIf

	  ; Get Queen's health color, and power up if needed
	  If $queenDeployed And $queenPoweredUp = False Then
		 Local $queenColor[4] = [$troopIndex[$eTroopQueen][0]+6, $troopIndex[$eTroopQueen][1]-8, $rRoyaltyHealthGreenColor[2], $rRoyaltyHealthGreenColor[3]]

		 If IsColorPresent($queenColor) = False Then
			;GrabFrameToFile("PreQueenPowerUpFrame" & _Date_Time_GetTickCount() & ".bmp")
			DebugWrite("Powering up Queen")
			RandomWeightedClick($queenButton)
			$queenPoweredUp = True
		 EndIf
	  EndIf

	  ; Deploy King if not already deployed
	  If $kingButton[0]<>-1 And $kingDeployed=False Then
		 DebugWrite("Deploying Barbarian King")
		 RandomWeightedClick($kingButton)
		 Sleep(500)

		 RandomWeightedClick($deployBox)
		 Sleep(500)

		 $kingDeployTime = TimerInit()
		 $kingDeployed = True
	  EndIf

	  ; Deploy Queen after specified amount of time after king deploy, if not already deployed
	  If $queenButton[0]<>-1 And TimerDiff($kingDeployTime)>$queenDeployDelay And $queenDeployed=False Then
		 DebugWrite("Deploying Archer Queen")
		 RandomWeightedClick($queenButton)
		 Sleep(500)

		 RandomWeightedClick($deployBox)
		 Sleep(500)

		 $queenDeployTime = TimerInit()
		 $queenDeployed = True
	  EndIf

	  Sleep(1000)
   WEnd
EndFunc
