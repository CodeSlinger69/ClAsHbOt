Func AutoRaid(ByRef $f, ByRef $timer, ByRef $THCorner)
   ;DebugWrite("AutoRaid()")

   Switch $gAutoStage

   ; Stage Queue Training
   Case $eAutoQueueTraining
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Queue Training")

	  ResetToCoCMainScreen($f)

	  AutoQueueTroops($f, True)
	  $timer = TimerInit()

   ; Stage Wait For Training To Complete
   Case $eAutoWaitForTrainingToComplete

	  If TimerDiff($timer) >= $gTroopTrainingCheckInterval Then
		 ResetToCoCMainScreen($f)
		 AutoQueueTroops($f, False)
		 $timer = TimerInit()
	  EndIf

   ; Stage Find Match
   Case $eAutoFindMatch
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Find Match")

	  ResetToCoCMainScreen($f)

	  Local $findResults = AutoRaidFindMatch($f, False, $THCorner)
	  If $findResults = False Then
		 ; Reset if there was an error
		 DebugWrite("AutoRaid() Error finding match, resetting")
		 ResetToCoCMainScreen($f)
		 $gAutoStage = $eAutoQueueTraining
	  ElseIf $findResults = $eAutoManualRaid Then
		 DebugWrite("AutoRaid() Manual raid notified")
		 ResetToCoCMainScreen($f)
		 $gAutoStage = $eAutoQueueTraining
	  Else
		 $gAutoStage = $findResults
	  EndIf

   ; Stage Execute Raid
   Case $eAutoExecuteRaid
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Execute Raid")

	  Switch _GUICtrlComboBox_GetCurSel($GUI_AutoRaidStrategyCombo)
	  Case 0
		 AutoRaidExecuteRaidStrategy0($f)  ; BARCH
	  Case 1
		 AutoRaidExecuteRaidStrategy1($f)  ; GiBarch
	  Case 2
		 AutoRaidExecuteRaidStrategy2($f)  ; BAM
	  Case 3
		 AutoRaidExecuteRaidStrategy3($f)  ; Loonian
	  EndSwitch

	  $gAutoStage = $eAutoQueueTraining
	  UpdateWinnings($f)
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Raid Complete")

   Case $eAutoExecuteSnipe
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Execute TH Snipe")

	  THSnipeExecute($f, $THCorner)
	  $gAutoStage = $eAutoQueueTraining
	  UpdateWinnings($f)

	  GUICtrlSetData($GUI_AutoStatus, "Auto: TH Snipe Complete")

   EndSwitch
EndFunc

Func AutoRaidFindMatch(ByRef $f, Const $returnFirstMatch, ByRef $THCorner)
   ; Click Attack
   DebugWrite("AutoRaidFindMatch() Click Attack button")
   RandomWeightedClick($rMainScreenAttackButton)

   ; Wait for Find a Match button
   If WaitForButton($f, 10000, $rFindMatchScreenFindAMatchNoShieldButton, $rFindMatchScreenFindAMatchWithShieldButton) = False Then
	  DebugWrite("AutoRaidFindMatch() Find Match failed - timeout waiting for Find a Match button")
	  Return False
   EndIf

   ; Click Find a Match
   DebugWrite("AutoRaidFindMatch() Click Find a Match button")
   If IsButtonPresent($f, $rFindMatchScreenFindAMatchNoShieldButton) Then
	  RandomWeightedClick($rFindMatchScreenFindAMatchNoShieldButton)
   ElseIf IsButtonPresent($f, $rFindMatchScreenFindAMatchWithShieldButton) Then
	  RandomWeightedClick($rFindMatchScreenFindAMatchWithShieldButton)
   EndIf
   Sleep(1000)

   ; Return now, if we are calling this function to dump cups
   If $returnFirstMatch Then
	  If AutoWaitForNextButton($f) = False Then
		 DebugWrite("AutoRaidFindMatch() Error returning on first match, waiting for Next button")
		 Return False
	  Else
		 DebugWrite("AutoRaidFindMatch() Returning on first match")
		 Sleep(2000)

		 _GDIPlus_BitmapDispose($f)
		 $f = CaptureFrame("AutoRaidFindMatch")
		 Return True
	  EndIf
   EndIf


   ; Loop with Next until we get a match
   While 1
	  If _GUICtrlButton_GetCheck($GUI_FindMatchCheckBox) = $BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_UNCHECKED Then
		 Return False
	  EndIf

	  ; Wait for Next button
	  If AutoWaitForNextButton($f) = False Then
		 Return False
	  EndIf
	  Sleep(2000)

	  ; Grab new frame
	  _GDIPlus_BitmapDispose($f)
	  $f = CaptureFrame("AutoRaidFindMatch")

	  ; Update my loot status on GUI
	  GetMyLootNumbers($f)

	  ; Get this bases loot
	  Local $thLevel, $thLeft, $thTop, $gold, $elix, $dark, $cups, $deadBase
	  AutoRaidGetDisplayedLoot($f, $thLevel, $thLeft, $thTop, $gold, $elix, $dark, $cups, $deadbase)

	  ; If raidable, then go do it
	  Local $raidable = CheckForRaidableBase($f, $thLevel, $gold, $elix, $dark, $cups, $deadbase)
	  If $raidable<>False Then
		 If _GUICtrlButton_GetCheck($GUI_FindMatchCheckBox) = $BST_CHECKED Then
			ShowFindMatchPopup()
			$raidable = $eAutoManualRaid
		 EndIf

		 Return $raidable
	  EndIf

	  ; If not raidable, see if it is snipable
	  If _GUICtrlButton_GetCheck($GUI_AutoRaidSnipeExposedTH)=$BST_CHECKED Then
		 If $gold>=GUICtrlRead($GUI_GoldEdit) And $elix>=GUICtrlRead($GUI_ElixEdit) And $dark>=GUICtrlRead($GUI_DarkEdit) Then
			Local $snipable = CheckForSnipableTH($THCorner, $thLevel, $thLeft, $thTop, $gold, $elix, $dark, $cups, $deadbase)
			If $snipable<>False Then
			   If _GUICtrlButton_GetCheck($GUI_FindMatchCheckBox) = $BST_CHECKED Then
				  ShowFindMatchPopup()
				  $snipable = $eAutoManualRaid
			   EndIf

			   Return $snipable
			EndIf
		 EndIf
	  EndIf

	  ; Not raidable or snipable - click Next
	  Sleep($gPauseBetweenNexts)

	  If IsButtonPresent($f, $rWaitRaidScreenNextButton) Then
		 DebugWrite("AutoRaidFindMatch() Click Next button")
		 RandomWeightedClick($rWaitRaidScreenNextButton)
		 Sleep(1000)

	  Else
		 DebugWrite("AutoRaidFindMatch() Next Button disappeared, resetting.")

		 If IsButtonPresent($f, $rLiveRaidScreenEndBattleButton) Then
			RandomWeightedClick($rLiveRaidScreenEndBattleButton)

			If WaitForButton($f, 5000, $rLiveRaidScreenEndBattleConfirmButton) = False Then
			   DebugWrite("AutoRaidFindMatch() Timeout waiting for End Battle Confirm button")
			Else
			   RandomWeightedClick($rLiveRaidScreenEndBattleConfirmButton)
			   Sleep(1000)
			EndIf
		 EndIf

		 Return False
	  EndIf
   WEnd
EndFunc

Func AutoWaitForNextButton(ByRef $f)
   If WaitForButton($f, 30000, $rWaitRaidScreenNextButton) = False Then
	  If @error = $eErrorAttackingDisabled Then
		 DebugWrite("Find Match failed - Attacking is Disabled")
		 $gPossibleKick = 2
		 $gLastPossibleKickTime = TimerInit()

	  Else
		 DebugWrite("Find Match failed - timeout waiting for Wait Raid screen")

		 If $gPossibleKick < 2 Then
			$gPossibleKick+=1
			DebugWrite("Possible kick detected, count = " & $gPossibleKick)
		 EndIf

		 If $gPossibleKick = 2 Then
			$gLastPossibleKickTime = TimerInit()
		 EndIf

	  EndIf

	  Return False
   EndIf

   Return True
EndFunc

Func ShowFindMatchPopup()
   ; 5 beeps
   For $i = 1 To 5
	  Beep(500, 200)
	  Sleep(100)
   Next

   MsgBox(BitOR($MB_OK, $MB_ICONINFORMATION), "Match!", "Click OK after completing raid," & @CRLF & "or deciding to skip this raid.")
EndFunc

Func CheckForRaidableBase(Const $frame, Const $townHall, Const $gold, Const $elix, Const $dark, Const $cups, Const $deadbase)
   ; Grab settings from the GUI
   Local $GUIGold = GUICtrlRead($GUI_GoldEdit)
   Local $GUIElix = GUICtrlRead($GUI_ElixEdit)
   Local $GUIDark = GUICtrlRead($GUI_DarkEdit)
   Local $GUITownHall = GUICtrlRead($GUI_TownHallEdit)
   Local $GUIIgnoreStorages = (_GUICtrlButton_GetCheck($GUI_AutoRaidIgnoreStorages) = $BST_CHECKED)
   Local $GUIDeadBasesOnly = (_GUICtrlButton_GetCheck($GUI_AutoRaidDeadBases) = $BST_CHECKED)
   Local $myTHLevel = GUICtrlRead($GUI_MyTownHall)

   ; Dead base check
   If $GUIDeadBasesOnly And $deadbase=False Then
	  DebugWrite("CheckForRaidableBase() No match (deadbase)")
	  Return False
   EndIf

   ; Town Hall match?
   If $townHall=-1 Then
	  DebugWrite("CheckForRaidableBase() No match, (obscured Town Hall?)")
	  Return False
   EndIf

   If $townHall>$GUITownHall Then
	  DebugWrite("CheckForRaidableBase() No match (town hall)")
	  Return False
   EndIf

   ; Adjust available loot to exclude storages?
   If $GUIIgnoreStorages And ($myTHLevel-$townHall<2 Or $myTHLevel>=11) Then ; "ignore storages" only valid if target TH<2 levels from my TH level. or my TH level>=11
	  ; Check unadjusted first to possibly skip adjustment scan
	  If $gold<$GUIGold Or $elix<$GUIElix Or $dark<$GUIDark Then
		 DebugWrite("CheckForRaidableBase() No match (loot)")
		 Return False
	  EndIf

	  Local $adjGold=$gold, $adjElix=$elix
	  AdjustLootForStorages($frame, $townHall, $gold, $elix, $adjGold, $adjElix)

	  If $adjGold<$GUIGold Or $adjElix<$GUIElix Or $dark<$GUIDark Then
		 DebugWrite("CheckForRaidableBase() No match (adj loot) (Adj: " & $adjGold & " / " & $adjElix & ")" )
		 Return False
	  Else
		 DebugWrite("CheckForRaidableBase() Match!" & @CRLF)
		 Return $eAutoExecuteRaid
	  EndIf
   EndIf

   ; Unadjusted loot match?
   If $gold<$GUIGold Or $elix<$GUIElix Or $dark<$GUIDark Then
	  DebugWrite("CheckForRaidableBase() No match (loot)")
	  Return False
   Else
	  DebugWrite("CheckForRaidableBase() Match!" & @CRLF)
	  Return $eAutoExecuteRaid
   EndIf
EndFunc

Func AutoRaidGetDisplayedLoot(Const $frame, ByRef $thLevel, ByRef $thLeft, ByRef $thTop, _
						      ByRef $gold, ByRef $elix, ByRef $dark, ByRef $cups, ByRef $deadbase)

   $gold = Number(ScrapeFuzzyText($frame, $gRaidLootCharMaps, $rGoldTextBox, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))
   $elix = Number(ScrapeFuzzyText($frame, $gRaidLootCharMaps, $rElixTextBox, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))

   If IsTextBoxPresent($frame, $rDarkTextBox)=False Then
	  $cups = Number(ScrapeFuzzyText($frame, $gRaidLootCharMaps, $rCupsTextBoxNoDE, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))
   Else
	  $dark = Number(ScrapeFuzzyText($frame, $gRaidLootCharMaps, $rDarkTextBox, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))
	  $cups = Number(ScrapeFuzzyText($frame, $gRaidLootCharMaps, $rCupsTextBoxWithDE, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))
   EndIf

   $deadBase = IsColorPresent($frame, $rDeadBaseIndicatorColor)

   ; Get Town Hall level
   $thLevel = GetTownHallLevel($frame, $thLeft, $thTop)

   SetAutoRaidResults($gold, $elix, $dark, $cups, $thLevel, $deadBase)

   DebugWrite("AutoRaidGetDisplayedLoot() " & $gold & " / " & $elix & " / " & $dark &  " / " & $cups & " / " & $thLevel & " / " & $deadBase)

EndFunc

; Based on loot calculation information here: http://clashofclans.wikia.com/wiki/Raids
Func AdjustLootForStorages(Const $frame, Const $townHall, Const $gold, Const $elix, ByRef $adjGold, ByRef $adjElix)
   Local $x, $y, $conf, $matchIndex
   Local $usageAdj = 10
   Local $myTHLevel = GUICtrlRead($GUI_MyTownHall)

   ; Gold
   ScanFrameForBestBMP($frame, $GoldStorageBMPs, $gConfidenceStorages, $matchIndex, $conf, $x, $y)

   If $matchIndex = -1 Then
	  DebugWrite("AdjustLootForStorages() Could not find gold storage match.")
	  _GDIPlus_ImageSaveToFile($frame, "StorageUsageFrameGold" & FileGetTime("StorageUsageFrame.bmp", 0, $FT_STRING) & ".bmp")
   Else
	  Local $s = $GoldStorageBMPs[$matchIndex]
	  Local $level = Number(StringMid($s, StringInStr($s, "GoldStorageL")+12, 2))
	  Local $usage = Number(StringMid($s, StringInStr($s, "GoldStorageL")+15, 2))
	  $usage = ($usage+$usageAdj>100 ? 100 : $usage+$usageAdj) ; number in the filename is lower bound of range, adjust for better filtering
	  DebugWrite("AdjustLootForStorages() Found gold storage level " & $level & ", average " & $usage & "% full, confidence " & Round($conf*100, 2) & "%")
	  $adjGold = $gold - CalculateLootInStorage($myTHLevel, $townHall, $level, $usage/100)
	  $adjGold = ($adjGold<0 ? 0 : Round($adjGold))
   EndIf

   ; Elixir
   ScanFrameForBestBMP($frame, $ElixStorageBMPs, $gConfidenceStorages, $matchIndex, $conf, $x, $y)

   If $matchIndex = -1 Then
	  DebugWrite("AdjustLootForStorages() Could not find elixir storage match.")
	  _GDIPlus_ImageSaveToFile($frame, "StorageUsageFrameElix" & FileGetTime("StorageUsageFrame.bmp", 0, $FT_STRING) & ".bmp")
   Else
	  Local $s = $ElixStorageBMPs[$matchIndex]
	  Local $level = Number(StringMid($s, StringInStr($s, "ElixStorageL")+12, 2))
	  Local $usage = Number(StringMid($s, StringInStr($s, "ElixStorageL")+15, 2))
	  $usage = ($usage+$usageAdj>100 ? 100 : $usage+$usageAdj) ; number in the filename is lower bound of range, adjust for better filtering
	  DebugWrite("AdjustLootForStorages() Found elix storage level " & $level & ", average " & $usage & "% full, confidence " & Round($conf*100, 2) & "%")
	  $adjElix = $elix - CalculateLootInStorage($myTHLevel, $townHall, $level, $usage/100)
	  $adjElix = ($adjElix<0 ? 0 : Round($adjElix))
   EndIf

   ; Dark - Just temporarily, to fill out saved bitmaps
   ScanFrameForBestBMP($frame, $DarkStorageBMPs, $gConfidenceStorages, $matchIndex, $conf, $x, $y)
   If $matchIndex = -1 Then
	  _GDIPlus_ImageSaveToFile($frame, "StorageUsageFrameDark" & FileGetTime("StorageUsageFrame.bmp", 0, $FT_STRING) & ".bmp")
   EndIf

EndFunc

Func CalculateLootInStorage(Const $myTHLevel, Const $targetTHLevel, Const $level, Const $usage)
   ; How much is in the storage, based on storage level and usage amount?
   ; Assume maximum number of storages for a given TH level
   ; TH9 and higher can have 4 storages
   ; TH8 can have 3 storages
   ; TH7 and lower can have 2 storages
   ; Calculations include assumption of proportional storage in TH, as of 12/10/2015 update
   Local $THStorage, $numStorages
   If $targetTHLevel=11 Then
	  $THStorage = 2000000
	  $numStorages = 4
   ElseIf $targetTHLevel=10 Then
	  $THStorage = 1500000
	  $numStorages = 4
   ElseIf $targetTHLevel=9 Then
	  $THStorage = 1000000
	  $numStorages = 4
   ElseIf $targetTHLevel=8 Then
	  $THStorage = 750000
	  $numStorages = 3
   ElseIf $targetTHLevel=7 Then
	  $THStorage = 500000
	  $numStorages = 2
   ElseIf $targetTHLevel=6 Then
	  $THStorage = 300000
	  $numStorages = 2
   ElseIf $targetTHLevel=5 Then
	  $THStorage = 100000
	  $numStorages = 2
   Else
	  $THStorage=50000
	  $numStorages = 2
   EndIf

   Local $capacityPerStorage
   If $level=12 Then
	  $capacityPerStorage = 2000000
   ElseIf $level=11 Then
	  $capacityPerStorage = 1750000
   ElseIf $level=10 Then
	  $capacityPerStorage = 850000
   Else
	  ; TODO: add logic here for other level storages once/if those images are captured
	  $capacityPerStorage = 450000
   EndIf

   Local $totalInStorage = ($THStorage + $capacityPerStorage*$numStorages) * $usage
   DebugWrite("CalculateLootInStorage() Total=" & $totalInStorage & " TH:" & $THStorage & _
			   " Per:" & $capacityPerStorage & " Num:" & $numStorages & " Usg:" & $usage)

   ; How much of what is in the storage is available to loot, given the target TH level?
   Local $availabletoLoot
   If $targetTHLevel>=11 Then
	  $availabletoLoot = $totalInStorage*0.1
	  If $availabletoLoot > 450000 Then $availabletoLoot = 450000
   ElseIf $targetTHLevel=10 Then
	  $availabletoLoot = $totalInStorage*0.12
	  If $availabletoLoot > 400000 Then $availabletoLoot = 400000
   ElseIf $targetTHLevel=9 Then
	  $availabletoLoot = $totalInStorage*0.14
	  If $availabletoLoot > 350000 Then $availabletoLoot = 350000
   ElseIf $targetTHLevel=8 Then
	  $availabletoLoot = $totalInStorage*0.16
	  If $availabletoLoot > 300000 Then $availabletoLoot = 300000
   ElseIf $targetTHLevel=7 Then
	  $availabletoLoot = $totalInStorage*0.18
	  If $availabletoLoot > 250000 Then $availabletoLoot = 250000
   Else ; $targetTHLevel<=6
	  $availabletoLoot = $totalInStorage*0.20
	  If $availabletoLoot > 200000 Then $availabletoLoot = 200000
   EndIf

   ; Adjust available to loot amount by loot penalty
   Local $availableToLootAfterPenalty
   If $myTHLevel-$targetTHLevel <= 0 Then
	  $availableToLootAfterPenalty = $availabletoLoot * 1 ; no penalty if raiding a base that is my town hall level or higher
   ElseIf $myTHLevel-$targetTHLevel = 1 Then
	  $availableToLootAfterPenalty = $availabletoLoot * 0.80
   ElseIf $myTHLevel-$targetTHLevel = 2 Then
	  $availableToLootAfterPenalty = $availabletoLoot * 0.50
   ElseIf $myTHLevel-$targetTHLevel = 3 Then
	  $availableToLootAfterPenalty = $availabletoLoot * 0.25
   Else
	  $availableToLootAfterPenalty = $availabletoLoot * 0.05
   EndIf

   DebugWrite("CalculateLootInStorage() Estimated loot in storage=" & $totalInStorage & _
			  ", Available=" & $availabletoLoot & _
			  ", After Penalty=" & $availableToLootAfterPenalty)

   Return $availableToLootAfterPenalty
EndFunc

; howMany: $eAutoRaidDeployFiftyPercent, $eAutoRaidDeploySixtyPercent, $eAutoRaidDeployRemaining, $eAutoRaidDeployOneTroop
Func DeployTroopsToSides(ByRef $f, Const $troop, ByRef $index, Const $howMany, Const $dir, Const $boxesPerSide)
   DebugWrite("DeployTroopsToSides()")
   Local $xClick, $yClick
   Local $troopButton[4] = [$index[$troop][0], $index[$troop][1], $index[$troop][2], $index[$troop][3]]

   ; Handle the deploy one troop situation first
   If $howMany=$eAutoRaidDeployOneTroop Then
	  RandomWeightedClick($troopButton)
	  RandomWeightedCoords( ($dir = "Top" ? $NWSafeDeployBox : $SWSafeDeployBox), $xClick, $yClick)
	  _ControlClick($xClick, $yClick)
	  Return
   EndIf

   ; Figure out how many of the available to deploy
   Local $troopsAvailable = $index[$troop][4]
   Local $troopsToDeploy
   If $howMany = $eAutoRaidDeploySixtyPercent Then
	    $troopsToDeploy = Int($troopsAvailable * 0.6)
   ElseIf $howMany = $eAutoRaidDeployFiftyPercent Then
	    $troopsToDeploy = Int($troopsAvailable * 0.5)
   Else
	    $troopsToDeploy = $troopsAvailable
   EndIf

   ;DebugWrite("Available: " & $troopsAvailable & ", deploying " & $troopsToDeploy)

   ; Deploy the troops
   Local $clickPoints1[$troopsToDeploy][2]
   ; Always deploy first set of troops left to right to avoid accidentally clicking the Next button
   GetAutoRaidClickPoints(0, $dir, $troopsToDeploy, $boxesPerSide, $clickPoints1)

   RandomWeightedClick($troopButton)
   Sleep(200)

   For $i = 0 To $troopsToDeploy-1
	  _ControlClick($clickPoints1[$i][0], $clickPoints1[$i][1])
	  Sleep($gDeployTroopClickDelay)
   Next

   ; If we are only deploying 50% or 60% then we are done
   If $howMany=$eAutoRaidDeploySixtyPercent Or $howMany=$eAutoRaidDeployFiftyPercent Then Return

   ; If we are deploying all, then check remaining and continue to deploy to make sure they all get out there
   UpdateRaidTroopCounts($f, $index)

   $troopsAvailable = $index[$troop][4]

   If $troopsAvailable>0 Then
	  DebugWrite("Continuing: " & $troopsAvailable & " troops available.")

	  Local $clickPoints2[$troopsAvailable][2]
	  GetAutoRaidClickPoints(Random(0,1,1), $dir, $troopsAvailable, $boxesPerSide, $clickPoints2)

	  RandomWeightedClick($troopButton)
	  Sleep(200)

	  For $i = 0 To $troopsAvailable-1
		 _ControlClick($clickPoints2[$i][0], $clickPoints2[$i][1])
		 Sleep($gDeployTroopClickDelay)
	  Next
   EndIf

   UpdateRaidTroopCounts($f, $index)
   $troopsAvailable = $index[$troop][4]

   If $troopsAvailable>0 Then
	  DebugWrite("Finishing to safe boxes: " & $troopsAvailable & " troops available.")
	  DeployTroopsToSafeBoxes($f, $troop, $index, $dir)
   EndIf
EndFunc

Func DeployTroopsToSafeBoxes(ByRef $f, Const $troop, ByRef $index, Const $dir)
   DebugWrite("DeployTroopsToSafeBoxes()")
   Local $xClick, $yClick, $count
   Local $troopButton[4] = [$index[$troop][0], $index[$troop][1], $index[$troop][2], $index[$troop][3]]

   ; Deploy half to left
   Local $troopsAvailable = Int($index[$troop][4] / 2)
   DebugWrite("Deploying to left safe box: " & $troopsAvailable & " troops.")
   $count=0
   RandomWeightedClick($troopButton)
   Sleep(200)

   For $i = 1 To $troopsAvailable
	  RandomWeightedCoords( ($dir = "Top" ? $NWSafeDeployBox : $SWSafeDeployBox), $xClick, $yClick)
	  _ControlClick($xClick, $yClick)
	  Sleep($gDeployTroopClickDelay)
	  $count+=1
   Next

   ; Deploy half to right
   UpdateRaidTroopCounts($f, $index)
   $troopsAvailable = $index[$troop][4]

   DebugWrite("Deploying to right safe box: " & $troopsAvailable & " troops.")
   $count=0
   RandomWeightedClick($troopButton)
   Sleep(200)

   For $i = 1 To $troopsAvailable
   	  RandomWeightedCoords( ($dir = "Top" ? $NESafeDeployBox : $SESafeDeployBox), $xClick, $yClick)
	  _ControlClick($xClick, $yClick)
	  Sleep($gDeployTroopClickDelay)
	  $count+=1
   Next
EndFunc

Func GetRandomAutoRaidDeployBox(Const $direction, Const $boxesPerSide, ByRef $box)
   Local $side = Random()>0.5 ? "Left" : "Right"
   Local $boxIndex = Random($gMaxDeployBoxes-$boxesPerSide, $gMaxDeployBoxes-1, 1)

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

Func AutoRaidEndBattle(ByRef $f)
   DebugWrite("AutoRaidEndBattle() Clicking End Battle button")
   RandomWeightedClick($rLiveRaidScreenEndBattleButton)

   ; Wait for confirmation button
   WaitForButton($f, 5000, $rLiveRaidScreenEndBattleConfirmButton)

   ; Click confirmation button
   DebugWrite("AutoRaidEndBattle() Clicking End Battle confirmation button")
   RandomWeightedClick($rLiveRaidScreenEndBattleConfirmButton)

   ; Wait for main screen
   If WaitForScreen($f, 5000, $eScreenMain, $eScreenEndBattle) = False Then
	  DebugWrite("AutoRaidEndBattle() Error waiting for main screen")
   EndIf
EndFunc

Func WaitForBattleEnd(ByRef $f, Const $kingDeployed, Const $queenDeployed, Const $wardenDeployed)
   Local $lastGold = 0, $lastElix = 0, $lastDark = 0
   Local $activeTimer = TimerInit()
   Local $maxTimer = TimerInit()

   While TimerDiff($maxTimer)<$gMaxRaidDuration
	  If WhereAmI($f) = $eScreenEndBattle Then
		 ExitLoop
	  EndIf

	  ; Get available loot remaining
	  Local $goldRemaining = Number(ScrapeFuzzyText($f, $gRaidLootCharMaps, $rGoldTextBox, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))
	  Local $elixRemaining = Number(ScrapeFuzzyText($f, $gRaidLootCharMaps, $rElixTextBox, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))
	  Local $darkRemaining = Number(ScrapeFuzzyText($f, $gRaidLootCharMaps, $rDarkTextBox, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))

	  ; If loot has changed, then reset timer
	  If $goldRemaining<>$lastGold Or $elixRemaining<>$lastElix Or $darkRemaining<>$lastDark Then
		 $lastGold = $goldRemaining
		 $lastElix = $elixRemaining
		 $lastDark = $darkRemaining
		 $activeTimer = TimerInit()
	  EndIf

	  ; End early?
	  ; If $gAutoRaidEndDelay=0, the use the legacy logic: If 30 seconds have passed with no change in available loot, then
	  ;   exit battle, but only if we have not deployed a hero.  If a hero has been deployed, then do not end early.
	  ; Otherwise end after $gAutoRaidEndDelay number of seconds.
	  If ($gAutoRaidEndDelay=0 And TimerDiff($activeTimer)>30000 And $kingDeployed=False And $queenDeployed=False And $wardenDeployed=False) Or _
		 ($gAutoRaidEndDelay<>0 And TimerDiff($activeTimer)>$gAutoRaidEndDelay*1000) Then

		 If $gAutoRaidEndDelay=0 Then
			DebugWrite("WaitForBattleEnd() No change in available loot for 30 seconds, ending battle.")
		 Else
			DebugWrite("WaitForBattleEnd() No change in available loot for " & $gAutoRaidEndDelay & " seconds, ending battle.")
		 EndIf

		 AutoRaidEndBattle($f)
		 ExitLoop
	  EndIf

	  _GDIPlus_BitmapDispose($f)
	  $f = CaptureFrame("WaitForBattleEnd1")
	  Sleep(1000)
   WEnd

   If WaitForScreen($f, 5000, $eScreenEndBattle) Then
	  Local $goldWin = ScrapeFuzzyText($f, $gBattleEndWinningsCharacterMaps, $rEndBattleGoldTextBox, $gBattleEndWinningsCharMapsMaxWidth, $eScrapeDropSpaces)
	  Local $elixWin = ScrapeFuzzyText($f, $gBattleEndWinningsCharacterMaps, $rEndBattleElixTextBox, $gBattleEndWinningsCharMapsMaxWidth, $eScrapeDropSpaces)
	  Local $darkWin = IsTextBoxPresent($f, $rEndBattleDarkTextBox) ? ScrapeFuzzyText($f, $gBattleEndWinningsCharacterMaps, $rEndBattleDarkTextBox, $gBattleEndWinningsCharMapsMaxWidth, $eScrapeDropSpaces) : 0
	  Local $cupsWin = IsTextBoxPresent($f, $rEndBattleCupsWithDETextBox) ? _
					   ScrapeFuzzyText($f, $gBattleEndWinningsCharacterMaps, $rEndBattleCupsWithDETextBox, $gBattleEndWinningsCharMapsMaxWidth, $eScrapeDropSpaces) : _
					   ScrapeFuzzyText($f, $gBattleEndWinningsCharacterMaps, $rEndBattleCupsNoDETextBox, $gBattleEndWinningsCharMapsMaxWidth, $eScrapeDropSpaces)

	  Local $goldBonus = 0
	  Local $elixBonus = 0
	  Local $darkBonus = 0
	  If IsTextBoxPresent($f, $rEndBattleBonusGoldTextBox) Or _
		 IsTextBoxPresent($f, $rEndBattleBonusElixTextBox) Or _
		 IsTextBoxPresent($f, $rEndBattleBonusDarkTextBox) Then

		 $goldBonus = ScrapeFuzzyText($f, $gBattleEndBonusCharacterMaps, $rEndBattleBonusGoldTextBox, $gBattleEndBonusCharMapsMaxWidth, $eScrapeDropSpaces)
		 $goldBonus = StringLeft($goldBonus, 1) = "+" ? StringMid($goldBonus, 2) : 0
		 $elixBonus = ScrapeFuzzyText($f, $gBattleEndBonusCharacterMaps, $rEndBattleBonusElixTextBox, $gBattleEndBonusCharMapsMaxWidth, $eScrapeDropSpaces)
		 $elixBonus = StringLeft($f, 1) = "+" ? StringMid($elixBonus, 2) : 0
		 $darkBonus = ScrapeFuzzyText($f, $gBattleEndBonusCharacterMaps, $rEndBattleBonusDarkTextBox, $gBattleEndBonusCharMapsMaxWidth, $eScrapeDropSpaces)
		 $darkBonus = StringLeft($darkBonus, 1) = "+" ? StringMid($darkBonus, 2) : 0
	  EndIf

	  DebugWrite("WaitForBattleEnd() Winnings this match: " & $goldWin & " / " & $elixWin & " / " & $darkWin & " / " & $cupsWin)
	  DebugWrite("WaitForBattleEnd() Bonus this match: " & $goldBonus & " / " & $elixBonus & " / " & $darkBonus)

	  ; Close battle end screen
	  DebugWrite("WaitForBattleEnd() Clicking Return Home button")
	  Sleep(500)
	  RandomWeightedClick($rBattleHasEndedScreenReturnHomeButton)

	  ; Wait for main screen
	  If WaitForScreen($f, 10000, $eScreenMain) = False Then
		 DebugWrite("WaitForBattleEnd() Error waiting for main screen")
	  EndIf
   EndIf
EndFunc

Func FindRaidTroopSlots(Const ByRef $bitmaps, ByRef $index)
   ; Populates index with the client area coords of all available troop buttons
   For $i = 0 To UBound($index)-1
	  $index[$i][0] = -1
	  $index[$i][1] = -1
	  $index[$i][2] = -1
	  $index[$i][3] = -1
	  $index[$i][4] = 0
   Next

   ;
   ; Check buttons 2-11
   ;
   RandomWeightedClick($rRaidSlotsButton1)
   Sleep(200)

   Local $frame = CaptureFrame("FindRaidTroopSlots2to11", $rRaidTroopBox2[0], $rRaidTroopBox2[1], $rRaidTroopBox2[2], $rRaidTroopBox2[3])
   If $gDebugSaveScreenCaptures Then _GDIPlus_ImageSaveToFile($frame, "AvailableRaidTroopsFrame2to11.bmp")

   For $i = 0 To UBound($bitmaps)-1
	  Local $res = DllCall("ImageMatch.dll", "str", "FindMatch", "str", "AvailableRaidTroopsFrame2to11.bmp", "str", "Images\"&$bitmaps[$i], "int", 3)
	  Local $split = StringSplit($res[0], "|", 2) ; x, y, conf

	  If $split[2] > $gConfidenceRaidTroopSlot Then
		 $index[$i][0] = $split[0]+$rRaidTroopBox2[0]+$rRaidButtonOffset[0]
		 $index[$i][1] = $split[1]+$rRaidTroopBox2[1]+$rRaidButtonOffset[1]
		 $index[$i][2] = $split[0]+$rRaidTroopBox2[0]+$rRaidButtonOffset[2]
		 $index[$i][3] = $split[1]+$rRaidTroopBox2[1]+$rRaidButtonOffset[3]
		 ;DebugWrite("Pass 2 Raid troop " & $bitmaps[$i] & " found at " & $index[$i][0] & ", " & $index[$i][1] &  ", " & _
			;		 $index[$i][2] & ", " & $index[$i][3] & " confidence " & Round($split[2]*100, 2) & "%")
	  EndIf
   Next

   _GDIPlus_BitmapDispose($frame)

   ;
   ; Check first button
   ;
   RandomWeightedClick($rRaidSlotsButton2)
   Sleep(200)

   Local $frame = CaptureFrame("FindRaidTroopSlots1", $rRaidTroopBox1[0], $rRaidTroopBox1[1], $rRaidTroopBox1[2], $rRaidTroopBox1[3])
   If $gDebugSaveScreenCaptures Then _GDIPlus_ImageSaveToFile($frame, "AvailableRaidTroopsFrame1.bmp")

   For $i = 0 To UBound($bitmaps)-1
	  Local $res = DllCall("ImageMatch.dll", "str", "FindMatch", "str", "AvailableRaidTroopsFrame1.bmp", "str", "Images\"&$bitmaps[$i], "int", 3)
	  Local $split = StringSplit($res[0], "|", 2) ; x, y, conf

	  If $split[2] > $gConfidenceRaidTroopSlot Then
		 $index[$i][0] = $split[0]+$rRaidTroopBox1[0]+$rRaidButtonOffset[0]
		 $index[$i][1] = $split[1]+$rRaidTroopBox1[1]+$rRaidButtonOffset[1]
		 $index[$i][2] = $split[0]+$rRaidTroopBox1[0]+$rRaidButtonOffset[2]
		 $index[$i][3] = $split[1]+$rRaidTroopBox1[1]+$rRaidButtonOffset[3]
		 ;DebugWrite("Pass 1 Raid troop " & $bitmaps[$i] & " found at " & $index[$i][0] & ", " & $index[$i][1] &  ", " & _
			;		 $index[$i][2] & ", " & $index[$i][3] & " confidence " & Round($split[2]*100, 2) & "%")
		 ExitLoop ; only one possible button in this pass
	  EndIf
   Next

   _GDIPlus_BitmapDispose($frame)
EndFunc

Func UpdateRaidTroopCounts(ByRef $f, ByRef $index)
   _GDIPlus_BitmapDispose($f)
   $f = CaptureFrame("UpdateRaidTroopCounts")

   For $i = 0 To UBound($index) - 1
	  If $index[$i][0] <> -1 Then

		 If $i=$eTroopKing Or $i=$eTroopQueen Or $i=$eTroopWarden Then
			$index[$i][4] = 1
		 Else
			Local $loc[4] = [ $index[$i][0]+31, $rRaidTroopBox1[3], $rRaidTroopSelectedColor[2], $rRaidTroopSelectedColor[3] ]
			;DebugWrite("GetAvailableTroops() loc = " & $loc[0] & " " & $loc[1] & " " & Hex($loc[2]) & " " & $loc[3])

			If IsColorPresent($f, $loc) Then
			   ; Troop is "selected"
			   Local $textBox[10] = [$index[$i][0]+5, $index[$i][1]-4, $index[$i][2]-5, $index[$i][1]+10, _
									 $rRaidSlotTroopCountTextBox[4], $rRaidSlotTroopCountTextBox[5], _
									 0, 0, 0, 0]
			   ;DebugWrite($textBox[0] & " " & $textBox[1] & " " & $textBox[2] & " " & $textBox[3] & " " & $textBox[4] & " " & _
			   ;	$textBox[5] & " " & $textBox[6] & " " & $textBox[7] & " " & $textBox[8] & " " & $textBox[9] )
			   Local $t = ScrapeFuzzyText($f, $gRaidTroopCountsSelectedCharMaps, $textBox, $gRaidTroopCountsSelectedCharMapsMaxWidth, $eScrapeDropSpaces)
			  ; DebugWrite("GetAvailableTroops() (selected) = " & $t)

			Else
			   ; Troop is not "selected"
			   Local $textBox[10] = [$index[$i][0]+5, $index[$i][1], $index[$i][2]-5, $index[$i][1]+18, _
									 $rRaidSlotTroopCountTextBox[4], $rRaidSlotTroopCountTextBox[5], _
									 0, 0, 0, 0]
			   Local $t = ScrapeFuzzyText($f, $gRaidTroopCountsCharMaps, $textBox, $gRaidTroopCountsCharMapsMaxWidth, $eScrapeDropSpaces)
			   ;DebugWrite("GetAvailableTroops() (not selected) = " & $t)

			EndIf

			$index[$i][4] = Number(StringMid($t, 2))
		 EndIf
	  EndIf
   Next
EndFunc

Func DeployAndMonitorHeroes(ByRef $f, Const ByRef $troopIndex, Const $deployStart, Const $direction, Const $boxIndex, _
						    ByRef $kingDeployed, ByRef $queenDeployed, ByRef $wardenDeployed)

   Local $kingButton[4] = [$troopIndex[$eTroopKing][0], $troopIndex[$eTroopKing][1], $troopIndex[$eTroopKing][2], $troopIndex[$eTroopKing][3]]
   Local $queenButton[4] = [$troopIndex[$eTroopQueen][0], $troopIndex[$eTroopQueen][1], $troopIndex[$eTroopQueen][2], $troopIndex[$eTroopQueen][3]]
   Local $wardenButton[4] = [$troopIndex[$eTroopWarden][0], $troopIndex[$eTroopWarden][1], $troopIndex[$eTroopWarden][2], $troopIndex[$eTroopWarden][3]]

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

   ; Loop, while monitoring King / Queen / Warden health bars, power up king/queen/warden when health falls below green (50%)
   ; Also, deploy queen after specified amount of time after king deploys, and warden a specified amount of time after queen or king deploys
   Local $kingDeployTime, $queenDeployTime, $wardenDeployTime
   Local $kingPoweredUp=False, $queenPoweredUp=False, $wardenPoweredUp=False
   Local $queenDeployDelay = 5000 ; 5 seconds after king
   Local $wardenDeployDelay = 3000 ; 3 seconds after queen or king
   Local $royaltyDeploySide = Random()

   While (($kingPoweredUp=False And $troopIndex[$eTroopKing][0]<>-1) Or _
	      ($queenPoweredUp=False And $troopIndex[$eTroopQueen][0]<>-1) Or _
	      ($wardenPoweredUp=False And $troopIndex[$eTroopWarden][0]<>-1)) And _
		 TimerDiff($deployStart) < $gMaxRaidDuration

	  ; Get frame
	  _GDIPlus_BitmapDispose($f)
	  $f = CaptureFrame("DeployAndMonitorHeroes")

	  ; Get King's health color, and power up if needed
	  If $kingDeployed And $kingPoweredUp = False Then
		 Local $kingColor[4] = [ _
			$troopIndex[$eTroopKing][0]+$rKingQueenHealthGreenColor[0], _
			$troopIndex[$eTroopKing][1]+$rKingQueenHealthGreenColor[1], _
			$rKingQueenHealthGreenColor[2], _
			$rKingQueenHealthGreenColor[3]]

		 If IsColorPresent($f, $kingColor) = False Then
			;GrabFrameToFile("PreKingPowerUpFrame" & _Date_Time_GetTickCount() & ".bmp")
			DebugWrite("Powering up King")
			RandomWeightedClick($kingButton)
			$kingPoweredUp = True
		 EndIf
	  EndIf

	  ; Get Queen's health color, and power up if needed
	  If $queenDeployed And $queenPoweredUp = False Then
		 Local $queenColor[4] = [ _
			$troopIndex[$eTroopQueen][0]+$rKingQueenHealthGreenColor[0], _
			$troopIndex[$eTroopQueen][1]+$rKingQueenHealthGreenColor[1], _
			$rKingQueenHealthGreenColor[2], _
			$rKingQueenHealthGreenColor[3]]

		 If IsColorPresent($f, $queenColor) = False Then
			;GrabFrameToFile("PreQueenPowerUpFrame" & _Date_Time_GetTickCount() & ".bmp")
			DebugWrite("Powering up Queen")
			RandomWeightedClick($queenButton)
			$queenPoweredUp = True
		 EndIf
	  EndIf

	  ; Get Warden's health color, and power up if needed
	  If $wardenDeployed And $wardenPoweredUp = False Then
		 Local $wardenColor[4] = [ _
			$troopIndex[$eTroopWarden][0]+$rWardenHealthGreenColor[0], _
			$troopIndex[$eTroopWarden][1]+$rWardenHealthGreenColor[1], _
			$rWardenHealthGreenColor[2], _
			$rWardenHealthGreenColor[3]]

		 If IsColorPresent($f, $wardenColor) = False Then
			;GrabFrameToFile("PreWardenPowerUpFrame" & _Date_Time_GetTickCount() & ".bmp")
			DebugWrite("Powering up Warden")
			RandomWeightedClick($wardenButton)
			$wardenPoweredUp = True
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
	  If $queenButton[0]<>-1 And $queenDeployed=False And TimerDiff($kingDeployTime)>$queenDeployDelay Then
		 DebugWrite("Deploying Archer Queen")
		 RandomWeightedClick($queenButton)
		 Sleep(500)

		 RandomWeightedClick($deployBox)
		 Sleep(500)

		 $queenDeployTime = TimerInit()
		 $queenDeployed = True
	  EndIf

	  ; Deploy Warden after specified amount of time after queen and/or king deploy, if not already deployed
	  If $wardenButton[0]<>-1 And $wardenDeployed=False And _
		 (TimerDiff($kingDeployTime)>$wardenDeployDelay Or TimerDiff($queenDeployTime)>$wardenDeployDelay) Then
		 DebugWrite("Deploying Grand Warden")
		 RandomWeightedClick($wardenButton)
		 Sleep(500)

		 RandomWeightedClick($deployBox)
		 Sleep(500)

		 $wardenDeployTime = TimerInit()
		 $wardenDeployed = True
	  EndIf

	  Sleep(500)
   WEnd
EndFunc
