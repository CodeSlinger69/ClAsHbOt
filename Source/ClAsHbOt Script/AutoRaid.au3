Func AutoRaid(ByRef $hBMP, ByRef $timer, ByRef $THCorner)
   ;DebugWrite("AutoRaid()")

   Switch $gAutoStage

   ; Stage Queue Training
   Case $eAutoQueueTraining
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Queue Training")

	  ResetToCoCMainScreen($hBMP)

	  AutoQueueTroops(True)
	  $timer = TimerInit()

   ; Stage Wait For Training To Complete
   Case $eAutoWaitForTrainingToComplete

	  If TimerDiff($timer) >= $gTroopTrainingCheckInterval Then
		 ResetToCoCMainScreen($hBMP)

		 AutoQueueTroops(False)
		 $timer = TimerInit()
	  EndIf

   ; Stage Find Match
   Case $eAutoFindMatch
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Find Match")

	  ResetToCoCMainScreen($hBMP)
	  ZoomOut($hBMP)

	  Local $findResults = AutoRaidFindMatch($hBMP, False, $THCorner)
	  If $findResults = False Then
		 ; Reset if there was an error
		 DebugWrite("AutoRaid() Error finding match, resetting")
		 ResetToCoCMainScreen($hBMP)
		 $gAutoStage = $eAutoQueueTraining
	  ElseIf $findResults = $eAutoManualRaid Then
		 DebugWrite("AutoRaid() Manual raid notified")
		 ResetToCoCMainScreen($hBMP)
		 $gAutoStage = $eAutoQueueTraining
	  Else
		 $gAutoStage = $findResults
	  EndIf

   ; Stage Execute Raid
   Case $eAutoExecuteRaid
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Execute Raid")

	  Switch _GUICtrlComboBox_GetCurSel($GUI_AutoRaidStrategyCombo)
	  Case 0
		 AutoRaidExecuteRaidStrategy0($hBMP)  ; BARCH
	  Case 1
		 AutoRaidExecuteRaidStrategy1($hBMP)  ; GiBarch
	  Case 2
		 AutoRaidExecuteRaidStrategy2($hBMP)  ; BAM
	  Case 3
		 AutoRaidExecuteRaidStrategy3($hBMP)  ; Loonian
	  Case 4
		 AutoRaidExecuteRaidStrategy4($hBMP)  ; HoBarch
	  EndSwitch

	  $gAutoStage = $eAutoQueueTraining
	  UpdateWinnings($hBMP)
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Raid Complete")

   Case $eAutoExecuteSnipe
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Execute TH Snipe")

	  THSnipeExecute($hBMP, $THCorner)
	  $gAutoStage = $eAutoQueueTraining
	  UpdateWinnings($hBMP)

	  GUICtrlSetData($GUI_AutoStatus, "Auto: TH Snipe Complete")

   EndSwitch
EndFunc

Func AutoRaidFindMatch(ByRef $hBMP, Const $returnFirstMatch, ByRef $THCorner)
   ; Click Attack
   DebugWrite("AutoRaidFindMatch() Click Attack button")
   If IsButtonPresent($hBMP, $rMainScreenAttackNoStarsButton) Then
	  RandomWeightedClick($rMainScreenAttackNoStarsButton)
   ElseIf IsButtonPresent($hBMP, $rMainScreenAttackWithStarsButton) Then
	  RandomWeightedClick($rMainScreenAttackWithStarsButton)
   Else
	  DebugWrite("AutoRaidFindMatch() Find Match failed - could not find Attack! button")
   EndIf

   ; Wait for Find a Match button
   If WaitForButton($hBMP, 10000, $rFindMatchScreenFindAMatchNoShieldButton, $rFindMatchScreenFindAMatchWithShieldButton) = False Then
	  DebugWrite("AutoRaidFindMatch() Find Match failed - timeout waiting for Find a Match button")
	  Return False
   EndIf

   ; Click Find a Match
   DebugWrite("AutoRaidFindMatch() Click Find a Match button")
   If IsButtonPresent($hBMP, $rFindMatchScreenFindAMatchNoShieldButton) Then
	  RandomWeightedClick($rFindMatchScreenFindAMatchNoShieldButton)
   ElseIf IsButtonPresent($hBMP, $rFindMatchScreenFindAMatchWithShieldButton) Then
	  RandomWeightedClick($rFindMatchScreenFindAMatchWithShieldButton)
   EndIf
   Sleep(1000)

   ; Return now, if we are calling this function to dump cups
   If $returnFirstMatch Then
	  If AutoWaitForNextButton($hBMP) = False Then
		 DebugWrite("AutoRaidFindMatch() Error returning on first match, waiting for Next button")
		 Return False
	  Else
		 DebugWrite("AutoRaidFindMatch() Returning on first match")
		 Sleep(2000)

		 _WinAPI_DeleteObject($hBMP)
		 $hBMP = CaptureFrameHBITMAP("AutoRaidFindMatch")
		 Return True
	  EndIf
   EndIf


   ; Loop with Next until we get a match
   While 1
	  If _GUICtrlButton_GetCheck($GUI_FindMatchCheckBox) = $BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_UNCHECKED Then
		 Return False
	  EndIf

	  ; Wait for Next button
	  If AutoWaitForNextButton($hBMP) = False Then
		 Return False
	  EndIf
	  Sleep(2000)

	  ; Grab new frame
	  _WinAPI_DeleteObject($hBMP)
	  $hBMP = CaptureFrameHBITMAP("AutoRaidFindMatch")

	  ; Update my loot status on GUI
	  GetMyLootNumbers($hBMP)

	  ; Get this bases loot
	  Local $thLevel, $thLeft, $thTop, $gold, $elix, $dark, $cups, $deadBase
	  AutoRaidGetDisplayedLoot($thLevel, $thLeft, $thTop, $gold, $elix, $dark, $cups, $deadbase)

	  ; If raidable, then go do it
	  Local $raidable = CheckForRaidableBase($thLevel, $gold, $elix, $dark, $cups, $deadbase)
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

	  If IsButtonPresent($hBMP, $rWaitRaidScreenNextButton) Then
		 DebugWrite("AutoRaidFindMatch() Click Next button")
		 RandomWeightedClick($rWaitRaidScreenNextButton)
		 Sleep(250)

	  Else
		 DebugWrite("AutoRaidFindMatch() Next Button disappeared, resetting.")

		 If IsButtonPresent($hBMP, $rLiveRaidScreenEndBattleButton) Then
			RandomWeightedClick($rLiveRaidScreenEndBattleButton)

			If WaitForButton($hBMP, 5000, $rLiveRaidScreenEndBattleConfirmButton) = False Then
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

Func AutoWaitForNextButton(ByRef $hBMP)
   Sleep(1000)
   _WinAPI_DeleteObject($hBMP)
   $hBMP = CaptureFrameHBITMAP("AutoWaitForNextButton")
   If $gDebugSaveScreenCaptures Then _ScreenCapture_SaveImage("AutoWaitForNextButtonFrame.bmp", $hBMP, False)

   If WaitForButton($hBMP, 30000, $rWaitRaidScreenNextButton) = False Then
	  If @error = $eErrorAttackingDisabled Then
		 DebugWrite("Find Match failed - Attacking is Disabled")
		 $gPossibleKick = 0
		 $gLastPossibleKickTime = TimerInit()

		 ; Exit the game
		 GoOffline($hBMP)

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

Func CheckForRaidableBase(Const $townHall, Const $gold, Const $elix, Const $dark, Const $cups, Const $deadbase)
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
	  DebugWrite("CheckForRaidableBase() No match (deadbase=false)")
	  Return False
   EndIf

   ; Town Hall match?
   If $townHall=-1 Then
	  DebugWrite("CheckForRaidableBase() No match, Town Hall unknown (obscured?)")
	  Return False
   EndIf

   If $townHall>$GUITownHall Then
	  DebugWrite("CheckForRaidableBase() No match (town hall=" & $townHall & ")")
	  Return False
   EndIf

   ; Adjust available loot to exclude storages?
   If $GUIIgnoreStorages And ($myTHLevel-$townHall<2 Or $myTHLevel>=11) Then ; "ignore storages" only valid if target TH<2 levels from my TH level. or my TH level>=11
	  ; Check unadjusted first to possibly skip adjustment scan
	  If $gold<$GUIGold Or $elix<$GUIElix Or $dark<$GUIDark Then
		 DebugWrite("CheckForRaidableBase() No match (loot) gold=" & $gold & " elix=" & $elix & " dark=" & $dark)
		 Return False
	  EndIf

	  Local $adjGold=$gold, $adjElix=$elix
	  AdjustLootForStorages($townHall, $gold, $elix, $adjGold, $adjElix)

	  If $adjGold<$GUIGold Or $adjElix<$GUIElix Or $dark<$GUIDark Then
		 DebugWrite("CheckForRaidableBase() No match (adj loot) (Adj: " & $adjGold & " / " & $adjElix & ")" )
		 Return False
	  Else
		 DebugWrite("CheckForRaidableBase() Match!  Adjusted loot: " & $adjGold & " / " & $adjElix & @CRLF)
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

Func AutoRaidGetDisplayedLoot(ByRef $thLevel, ByRef $thLeft, ByRef $thTop, _
						      ByRef $gold, ByRef $elix, ByRef $dark, ByRef $cups, ByRef $deadbase)

   Local $hHBITMAP = CaptureFrameHBITMAP("AutoRaidGetDisplayedLoot")

   $gold = Number(ScrapeFuzzyText($hHBITMAP, $fontRaidLoot, $rGoldTextBox))
   $elix = Number(ScrapeFuzzyText($hHBITMAP, $fontRaidLoot, $rElixTextBox))
   $dark = Number(ScrapeFuzzyText($hHBITMAP, $fontRaidLoot, $rDarkTextBox))
   $cups = Number(ScrapeFuzzyText($hHBITMAP, $fontRaidLoot, $rCupsTextBox))

   $deadBase = IsColorPresent($hHBITMAP, $rDeadBaseIndicatorColor)

   ; Get Town Hall level
   Local $conf
   FindBestBMP($eSearchTypeTownHall, $thLeft, $thTop, $conf, $thLevel)

   Local $townHallIndiator = $thLevel<>-1 ? $thLevel : "-"
   Local $deadBaseIndicator = _GUICtrlButton_GetCheck($GUI_AutoRaidDeadBases) = $BST_CHECKED ? ($deadBase=True ? "T" : "F") : "-"
   GUICtrlSetData($GUI_Results, "Last scan: " & $gold & " / " & $elix & " / " & $dark & " / " & $cups & " / " & $townHallIndiator & " / " & $deadBaseIndicator)
   DebugWrite("AutoRaidGetDisplayedLoot() " & $gold & " / " & $elix & " / " & $dark &  " / " & $cups & " / " & $thLevel & " / " & $deadBase)

   _WinAPI_DeleteObject($hHBITMAP)
EndFunc

; Based on loot calculation information here: http://clashofclans.wikia.com/wiki/Raids
Func AdjustLootForStorages(Const $townHall, Const $gold, Const $elix, ByRef $adjGold, ByRef $adjElix)
   Local $myTHLevel = GUICtrlRead($GUI_MyTownHall)

   ; Gold
   Local $x, $y, $conf, $value
   If FindBestBMP($eSearchTypeGoldStorage, $x, $y, $conf, $value) = False Then
	  DebugWrite("AdjustLootForStorages() Could not find gold storage match.")
   Else
	  Local $level = Number(StringMid($value, StringInStr($value, "GoldStorageL")+12, 2))
	  Local $usage = Number(StringMid($value, StringInStr($value, "GoldStorageL")+15, 2))
	  DebugWrite("AdjustLootForStorages() Found gold storage level " & $level & ", average " & $usage & "% full, confidence " & Round($conf*100, 2) & "%")
	  $adjGold = $gold - CalculateLootInStorage($myTHLevel, $townHall, $level, $usage/100)
	  $adjGold = ($adjGold<0 ? 0 : Round($adjGold))
   EndIf

   ; Elixir
   If FindBestBMP($eSearchTypeElixStorage, $x, $y, $conf, $value) = False Then
	  DebugWrite("AdjustLootForStorages() Could not find elixir storage match.")
   Else
	  Local $level = Number(StringMid($value, StringInStr($value, "ElixStorageL")+12, 2))
	  Local $usage = Number(StringMid($value, StringInStr($value, "ElixStorageL")+15, 2))
	  DebugWrite("AdjustLootForStorages() Found elix storage level " & $level & ", average " & $usage & "% full, confidence " & Round($conf*100, 2) & "%")
	  $adjElix = $elix - CalculateLootInStorage($myTHLevel, $townHall, $level, $usage/100)
	  $adjElix = ($adjElix<0 ? 0 : Round($adjElix))
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
Func DeployTroopsToSides(Const $troop, ByRef $index, Const $howMany, Const $dir, Const $boxesPerSide)
   DebugWrite("DeployTroopsToSides()")

   Local $troopButton[4] = [ $index[$troop][0], $index[$troop][1], $index[$troop][2], $index[$troop][3]]

   ; Handle the deploy one troop situation first
   If $howMany=$eAutoRaidDeployOneTroop Then
	  RandomWeightedClick($troopButton)
	  Local $xClick, $yClick
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
   UpdateRaidSlotCounts($index)

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

   UpdateRaidSlotCounts($index)
   $troopsAvailable = $index[$troop][4]

   If $troopsAvailable>0 Then
	  DebugWrite("Finishing to safe boxes: " & $troopsAvailable & " troops available.")
	  DeployTroopsToSafeBoxes($troop, $index, $dir)
   EndIf
EndFunc

Func DeployTroopsToSafeBoxes(Const $troop, ByRef $index, Const $dir)
   DebugWrite("DeployTroopsToSafeBoxes()")

   Local $troopButton[4] = [ $index[$troop][0], $index[$troop][1], $index[$troop][2], $index[$troop][3]]

   ; Deploy half to left
   Local $troopsAvailable = Int($index[$troop][4] / 2)
   DebugWrite("Deploying to left safe box: " & $troopsAvailable & " troops.")
   RandomWeightedClick($troopButton)
   Sleep(200)

   For $i = 1 To $troopsAvailable
	  Local $xClick, $yClick
	  RandomWeightedCoords( ($dir = "Top" ? $NWSafeDeployBox : $SWSafeDeployBox), $xClick, $yClick)
	  _ControlClick($xClick, $yClick)
	  Sleep($gDeployTroopClickDelay)
   Next

   ; Deploy half to right
   UpdateRaidSlotCounts($index)
   $troopsAvailable = $index[$troop][4]

   DebugWrite("Deploying to right safe box: " & $troopsAvailable & " troops.")
   RandomWeightedClick($troopButton)
   Sleep(200)

   For $i = 1 To $troopsAvailable
	  Local $xClick, $yClick
   	  RandomWeightedCoords( ($dir = "Top" ? $NESafeDeployBox : $SESafeDeployBox), $xClick, $yClick)
	  _ControlClick($xClick, $yClick)
	  Sleep($gDeployTroopClickDelay)
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

Func AutoRaidEndBattle(ByRef $hBMP)
   DebugWrite("AutoRaidEndBattle() Clicking End Battle button")
   RandomWeightedClick($rLiveRaidScreenEndBattleButton)

   ; Wait for confirmation button
   WaitForButton($hBMP, 5000, $rLiveRaidScreenEndBattleConfirmButton)

   ; Click confirmation button
   DebugWrite("AutoRaidEndBattle() Clicking End Battle confirmation button")
   RandomWeightedClick($rLiveRaidScreenEndBattleConfirmButton)

   ; Wait for main screen
   If WaitForScreen($hBMP, 5000, $eScreenMain, $eScreenEndBattle) = False Then
	  DebugWrite("AutoRaidEndBattle() Error waiting for main screen")
   EndIf
EndFunc

Func WaitForBattleEnd(ByRef $hBMP, Const $kingDeployed, Const $queenDeployed, Const $wardenDeployed)
   Local $lastGold = 0, $lastElix = 0, $lastDark = 0
   Local $activeTimer = TimerInit()
   Local $maxTimer = TimerInit()

   While TimerDiff($maxTimer)<$gMaxRaidDuration
	  If WhereAmI($hBMP) = $eScreenEndBattle Then
		 ExitLoop
	  EndIf

	  ; Get available loot remaining
	  Local $goldRemaining = Number(ScrapeFuzzyText($hBMP, $fontRaidLoot, $rGoldTextBox))
	  Local $elixRemaining = Number(ScrapeFuzzyText($hBMP, $fontRaidLoot, $rElixTextBox))
	  Local $darkRemaining = Number(ScrapeFuzzyText($hBMP, $fontRaidLoot, $rDarkTextBox))

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

		 AutoRaidEndBattle($hBMP)
		 ExitLoop
	  EndIf

	  _WinAPI_DeleteObject($hBMP)
	  $hBMP = CaptureFrameHBITMAP("WaitForBattleEnd1")
	  Sleep(1000)
   WEnd

   If WaitForScreen($hBMP, 5000, $eScreenEndBattle) Then
	  Sleep(3000) ; Long wait due to bonus numbers "flying in"
	  If $gDebugSaveScreenCaptures Then _ScreenCapture_SaveImage("EndBattleFrame.bmp", $hBMP, False)

	  Local $goldWin = Number(ScrapeFuzzyText($hBMP, $fontBattleEndWinnings, $rEndBattleGoldTextBox))
	  Local $elixWin = Number(ScrapeFuzzyText($hBMP, $fontBattleEndWinnings, $rEndBattleElixTextBox))
	  Local $darkWin = IsTextBoxPresent($hBMP, $rEndBattleDarkTextBox) ? _
					   Number(ScrapeFuzzyText($hBMP, $fontBattleEndWinnings, $rEndBattleDarkTextBox)) : 0
	  Local $cupsWin = IsTextBoxPresent($hBMP, $rEndBattleCupsWithDETextBox) ? _
					   Number(ScrapeFuzzyText($hBMP, $fontBattleEndWinnings, $rEndBattleCupsWithDETextBox)) : _
					   Number(ScrapeFuzzyText($hBMP, $fontBattleEndWinnings, $rEndBattleCupsNoDETextBox))

	  Local $goldBonus = 0
	  Local $elixBonus = 0
	  Local $darkBonus = 0
	  If IsTextBoxPresent($hBMP, $rEndBattleBonusGoldTextBox) Or _
		 IsTextBoxPresent($hBMP, $rEndBattleBonusElixTextBox) Or _
		 IsTextBoxPresent($hBMP, $rEndBattleBonusDarkTextBox) Then

		 $goldBonus = ScrapeFuzzyText($hBMP, $fontBattleEndBonus, $rEndBattleBonusGoldTextBox)
		 $goldBonus = StringLeft($goldBonus, 1) = "+" ? Number(StringMid($goldBonus, 2)) : 0
		 $elixBonus = ScrapeFuzzyText($hBMP, $fontBattleEndBonus, $rEndBattleBonusElixTextBox)
		 $elixBonus = StringLeft($elixBonus, 1) = "+" ? Number(StringMid($elixBonus, 2)) : 0
		 $darkBonus = ScrapeFuzzyText($hBMP, $fontBattleEndBonus, $rEndBattleBonusDarkTextBox)
		 $darkBonus = StringLeft($darkBonus, 1) = "+" ? Number(StringMid($darkBonus, 2)) : 0
	  EndIf

	  DebugWrite("WaitForBattleEnd() Winnings this match: " & $goldWin & " / " & $elixWin & " / " & $darkWin & " / " & $cupsWin)
	  DebugWrite("WaitForBattleEnd() Bonus this match: " & $goldBonus & " / " & $elixBonus & " / " & $darkBonus)

	  ; Close battle end screen
	  DebugWrite("WaitForBattleEnd() Clicking Return Home button")
	  Sleep(500)
	  RandomWeightedClick($rBattleHasEndedScreenReturnHomeButton)

	  ; Wait for main screen
	  If WaitForScreen($hBMP, 10000, $eScreenMain) = False Then
		 DebugWrite("WaitForBattleEnd() Error waiting for main screen")
	  EndIf
   EndIf
EndFunc

Func UpdateRaidSlotCounts(ByRef $index)
   Local $hHBITMAP = CaptureFrameHBITMAP("UpdateRaidSlotCounts", $rRaidTroopBox[0], $rRaidTroopBox[1], $rRaidTroopBox[2], $rRaidTroopBox[3])
   If $gDebugSaveScreenCaptures Then _ScreenCapture_SaveImage("UpdateRaidTroopCounts.bmp", $hHBITMAP, False)

   For $i = 0 To UBound($index) - 1
	  If $index[$i][0] <> -1 Then

		 If $i=$eTroopKing Or $i=$eTroopQueen Or $i=$eTroopWarden Then
			$index[$i][4] = 1

		 Else
			; Determine if this raid button is "selected"
			Local $loc[4] = [ _
			   $index[$i][0] + $rRaidTroopSelectedColor[0] - $rRaidTroopBox[0], _
			   $index[$i][1] + $rRaidTroopSelectedColor[1] - $rRaidTroopBox[1], _
			   $rRaidTroopSelectedColor[2], _
			   $rRaidTroopSelectedColor[3] ]
			;DebugWrite("UpdateRaidSlotCounts() loc = " & $loc[0] & " " & $loc[1] & " " & Hex($loc[2]) & " " & $loc[3])

			If IsColorPresent($hHBITMAP, $loc) Then
			   ; Troop is "selected"
			   Local $textBox[10] = [ _
				  $index[$i][0] + 5 - $rRaidTroopBox[0], _
				  $index[$i][1] - 4 - $rRaidTroopBox[1], _
				  $index[$i][2] - 5 - $rRaidTroopBox[0], _
				  $index[$i][1] + 10 - $rRaidTroopBox[1], _
				  $rRaidSlotTroopCountTextBox[4], $rRaidSlotTroopCountTextBox[5], 0, 0, 0, 0]
			   ;DebugWrite("Selected text box: " & $textBox[0] & " " & $textBox[1] & " " & $textBox[2] & " " & $textBox[3] & " " & $textBox[4] & " " & _
				;  Hex($textBox[5]) & " " & $textBox[6] & " " & $textBox[7] & " " & $textBox[8] & " " & $textBox[9] )
			   Local $t = ScrapeFuzzyText($hHBITMAP, $fontRaidTroopCountSelected, $textBox)
			   ;DebugWrite("UpdateRaidSlotCounts() (selected) = " & $t)

			Else
			   ; Troop is not "selected"
			   Local $textBox[10] = [ _
				  $index[$i][0] + 5 - $rRaidTroopBox[0], _
				  $index[$i][1] + 0 - $rRaidTroopBox[1], _
				  $index[$i][2] - 5 - $rRaidTroopBox[0], _
				  $index[$i][1] + 18 - $rRaidTroopBox[1], _
				  $rRaidSlotTroopCountTextBox[4], $rRaidSlotTroopCountTextBox[5], 0, 0, 0, 0]
			   ;DebugWrite("Not selected text box: " & $textBox[0] & " " & $textBox[1] & " " & $textBox[2] & " " & $textBox[3] & " " & $textBox[4] & " " & _
				;  Hex($textBox[5]) & " " & $textBox[6] & " " & $textBox[7] & " " & $textBox[8] & " " & $textBox[9] )
			   Local $t = ScrapeFuzzyText($hHBITMAP, $fontRaidTroopCountUnselected, $textBox)
			   ;DebugWrite("UpdateRaidSlotCounts() (not selected) = " & $t)

			EndIf

			$index[$i][4] = Number(StringMid($t, 2))
		 EndIf
	  EndIf
   Next

   _WinAPI_DeleteObject($hHBITMAP)
EndFunc

Func DeployAndMonitorHeroes(Const ByRef $index, Const $deployStart, Const $direction, Const $boxIndex, _
						    ByRef $kingDeployed, ByRef $queenDeployed, ByRef $wardenDeployed)

   Local $kingButton[4] = [ $index[$eTroopKing][0], $index[$eTroopKing][1], $index[$eTroopKing][2], $index[$eTroopKing][3]]
   Local $queenButton[4] = [ $index[$eTroopQueen][0], $index[$eTroopQueen][1], $index[$eTroopQueen][2], $index[$eTroopQueen][3]]
   Local $wardenButton[4] = [ $index[$eTroopWarden][0], $index[$eTroopWarden][1], $index[$eTroopWarden][2], $index[$eTroopWarden][3]]

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

   Local $kingColor[4] = [ _
	  $index[$eTroopKing][0] - $rRaidTroopBox[0] + $rKingQueenHealthGreenColor[0], _
	  $index[$eTroopKing][1] - $rRaidTroopBox[1] + $rKingQueenHealthGreenColor[1], _
	  $rKingQueenHealthGreenColor[2], _
	  $rKingQueenHealthGreenColor[3]]

   Local $queenColor[4] = [ _
	  $index[$eTroopQueen][0] - $rRaidTroopBox[0] + $rKingQueenHealthGreenColor[0], _
	  $index[$eTroopQueen][1] - $rRaidTroopBox[1] + $rKingQueenHealthGreenColor[1], _
	  $rKingQueenHealthGreenColor[2], _
	  $rKingQueenHealthGreenColor[3]]

   Local $wardenColor[4] = [ _
	  $index[$eTroopWarden][0] - $rRaidTroopBox[0] + $rWardenHealthGreenColor[0], _
	  $index[$eTroopWarden][1] - $rRaidTroopBox[1] + $rWardenHealthGreenColor[1], _
	  $rWardenHealthGreenColor[2], _
	  $rWardenHealthGreenColor[3]]

   While (($kingPoweredUp=False And $index[$eTroopKing][0]<>-1) Or _
	      ($queenPoweredUp=False And $index[$eTroopQueen][0]<>-1) Or _
	      ($wardenPoweredUp=False And $index[$eTroopWarden][0]<>-1)) And _
		 TimerDiff($deployStart) < $gMaxRaidDuration

	  ; Get frame
	  Local $hHBITMAP = CaptureFrameHBITMAP("DeployAndMonitorHeroes", $rRaidTroopBox[0], $rRaidTroopBox[1], $rRaidTroopBox[2], $rRaidTroopBox[3])
	  If $gDebugSaveScreenCaptures Then _ScreenCapture_SaveImage("DeployAndMonitorHeroes.bmp", $hHBITMAP, False)

	  ; Get King's health color, and power up if needed
	  If $kingDeployed And $kingPoweredUp = False Then
		 If IsColorPresent($hHBITMAP, $kingColor) = False Then
			DebugWrite("Powering up Barbarian King")
			RandomWeightedClick($kingButton)
			$kingPoweredUp = True
		 EndIf
	  EndIf

	  ; Get Queen's health color, and power up if needed
	  If $queenDeployed And $queenPoweredUp = False Then
		 If IsColorPresent($hHBITMAP, $queenColor) = False Then
			DebugWrite("Powering up Archer Queen")
			RandomWeightedClick($queenButton)
			$queenPoweredUp = True
		 EndIf
	  EndIf

	  ; Get Warden's health color, and power up if needed
	  If $wardenDeployed And $wardenPoweredUp = False Then
		 If IsColorPresent($hHBITMAP, $wardenColor) = False Then
			DebugWrite("Powering up Grand Warden")
			RandomWeightedClick($wardenButton)
			$wardenPoweredUp = True
		 EndIf
	  EndIf

	  _WinAPI_DeleteObject($hHBITMAP)

	  ; Deploy King if not already deployed
	  If $kingButton[0]<>-1 And $kingDeployed=False Then
		 DebugWrite("Deploying Barbarian King...", True, False)
		 RandomWeightedClick($kingButton)
		 Sleep(500)

		 RandomWeightedClick($deployBox)
		 Sleep(500)

		 ; Check for health bar (L5+) or grayed button (L1-L4) to verify deploy
		 Local $hHBITMAP = CaptureFrameHBITMAP("DeployAndMonitorHeroes", $rRaidTroopBox[0], $rRaidTroopBox[1], $rRaidTroopBox[2], $rRaidTroopBox[3])
		 Local $troopIndex[$eTroopCount][5]
		 $troopIndex[$eTroopKingGrayed][0] = -1
		 LocateSlots($eActionTypeRaid, $eSlotTypeTroop, $troopIndex)

		 If IsColorPresent($hHBITMAP, $kingColor) Or $troopIndex[$eTroopKingGrayed][0] <> -1 Then
			$kingDeployTime = TimerInit()
			$kingDeployed = True
			DebugWrite("deployed", False, True)
		 Else
			DebugWrite("failed, will retry", False, True)
		 EndIf

		 _WinAPI_DeleteObject($hHBITMAP)
	  EndIf

	  ; Deploy Queen after specified amount of time after king deploy, if not already deployed
	  If $queenButton[0]<>-1 And $queenDeployed=False And TimerDiff($kingDeployTime)>$queenDeployDelay Then
		 DebugWrite("Deploying Archer Queen...", True, False)
		 RandomWeightedClick($queenButton)
		 Sleep(500)

		 RandomWeightedClick($deployBox)
		 Sleep(500)

		 ; Check for health bar (L5+) or grayed button (L1-L4) to verify deploy
		 Local $hHBITMAP = CaptureFrameHBITMAP("DeployAndMonitorHeroes", $rRaidTroopBox[0], $rRaidTroopBox[1], $rRaidTroopBox[2], $rRaidTroopBox[3])
		 Local $troopIndex[$eTroopCount][5]
		 $troopIndex[$eTroopQueenGrayed][0] = -1
		 LocateSlots($eActionTypeRaid, $eSlotTypeTroop, $troopIndex)

		 If IsColorPresent($hHBITMAP, $queenColor) Or $troopIndex[$eTroopQueenGrayed][0] <> -1 Then
			$queenDeployTime = TimerInit()
			$queenDeployed = True
			DebugWrite("deployed", False, True)
		 Else
			DebugWrite("failed, will retry", False, True)
		 EndIf

		 _WinAPI_DeleteObject($hHBITMAP)
	  EndIf

	  ; Deploy Warden after specified amount of time after queen and/or king deploy, if not already deployed
	  If $wardenButton[0]<>-1 And $wardenDeployed=False And _
		 (TimerDiff($kingDeployTime)>$wardenDeployDelay Or TimerDiff($queenDeployTime)>$wardenDeployDelay) Then
		 DebugWrite("Deploying Grand Warden...", True, False)
		 RandomWeightedClick($wardenButton)
		 Sleep(500)

		 RandomWeightedClick($deployBox)
		 Sleep(500)

		 ; Check for health bar to verify deploy
		 Local $hHBITMAP = CaptureFrameHBITMAP("DeployAndMonitorHeroes", $rRaidTroopBox[0], $rRaidTroopBox[1], $rRaidTroopBox[2], $rRaidTroopBox[3])
		 Local $troopIndex[$eTroopCount][5]
		 $troopIndex[$eTroopWardenGrayed][0] = -1
		 LocateSlots($eActionTypeRaid, $eSlotTypeTroop, $troopIndex)

		 If IsColorPresent($hHBITMAP, $wardenColor) Or $troopIndex[$eTroopWardenGrayed][0] <> -1 Then
			$wardenDeployTime = TimerInit()
			$wardenDeployed = True
			DebugWrite("deployed", False, True)
		 Else
			DebugWrite("failed, will retry", False, True)
		 EndIf

		 _WinAPI_DeleteObject($hHBITMAP)
	  EndIf

	  Sleep(500)
   WEnd
EndFunc
