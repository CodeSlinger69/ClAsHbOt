Func AutoPush(ByRef $timer, ByRef $THLevel, ByRef $THLocation, ByRef $THLeft, ByRef $THTop)
   ;DebugWrite("AutoPush()")

   If $gAutoSnipeNotifyOnly Then
	  $gAutoStage = $eAutoFindMatch
	  DebugWrite("Auto Push, notify mode")
   EndIf

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
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Find Snipable TH")

	  Local $findMatchResults = THSnipeFindMatch($THLevel, $THLocation, $THLeft, $THTop)

	  ; Reset if there was an error
	  If $findMatchResults=False Then
		 DebugWrite("Auto: Error finding match, resetting.")
		 ResetToCoCMainScreen()
		 $gAutoStage = $eAutoQueueTraining
		 Return
	  EndIf

	  ; Did we find a snipable base?
	  If $findMatchResults = $eAutoExecuteSnipe And $gAutoSnipeNotifyOnly Then
		 For $i = 1 To 5
			Beep(500, 200)
			Sleep(100)
		 Next

		 MsgBox($MB_OK, "Snipable TH!", "")
		 Return
	  EndIf

	  If $findMatchResults = $eAutoExecuteSnipe Then $gAutoStage = $eAutoExecuteSnipe

   ; Stage Execute TH Snipe to Push
   Case $eAutoExecuteSnipe
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Execute Snipe")
	  If THSnipeExecute($THLevel, $THLocation, $THLeft, $THTop) Then
		 $gAutoStage = $eAutoQueueTraining
		 UpdateWinnings()
	  EndIf

	  GUICtrlSetData($GUI_AutoStatus, "Auto: Snipe Complete")

   EndSwitch

EndFunc

Func THSnipeFindMatch(ByRef $level, ByRef $location, ByRef $left, ByRef $top)
   DebugWrite("AutoPushFindMatch()")

   ; Make sure we are on the main screen
   If WhereAmI() <> $eScreenMain Then
	  DebugWrite("Find Snipable TH failed - not on main screen")
	  Return False
   EndIf

   ; Click Attack
   RandomWeightedClick($rMainScreenAttackButton)

   ; Wait for Find a Match button
   Local $failCount = 10
   While IsButtonPresent($rFindMatchScreenFindAMatchNoShieldButton)=False And _
	  IsButtonPresent($rFindMatchScreenFindAMatchWithShieldButton)=False And _
	  $failCount>0

	  Sleep(1000)
	  $failCount -= 1
   WEnd

   If $failCount = 0 Then
	  DebugWrite("Find Snipable TH failed - timeout waiting for Find a Match button")
	  ResetToCoCMainScreen()
	  Return False
   EndIf

   ; Click Find a Match
   If IsButtonPresent($rFindMatchScreenFindAMatchNoShieldButton) Then
	  RandomWeightedClick($rFindMatchScreenFindAMatchNoShieldButton)
   Else
	  RandomWeightedClick($rFindMatchScreenFindAMatchWithShieldButton)
   EndIf

   ; Wait for Next button
   $failCount = 30
   While IsButtonPresent($rWaitRaidScreenNextButton) = False And _
	  IsButtonPresent($rAndroidMessageButton1) = False And _
	  IsButtonPresent($rAndroidMessageButton2) = False And _
	  AttackingIsDisabled() = False And _
	  $failCount>0

	  Sleep(1000)
	  $failCount -= 1
   WEnd

    If AttackingIsDisabled() Then
	  DebugWrite("Find Match failed (AS1) - Attacking is Disabled")
	  ResetToCoCMainScreen()

	  $gPossibleKick = 2
	  $gLastPossibleKickTime = TimerInit()

	  Return False
   EndIf

   If $failCount = 0 Then
	  DebugWrite("Find Match failed (AS1) - timeout waiting for Wait Raid screen")
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

   ; Loop with Next until we find a snipable TH
   While 1
	  If _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox) = $BST_UNCHECKED Then Return False

	  ; Update my loot status on GUI
	  GetMyLootNumbers()

	  Local $snipable = False

	  ; Check dead base settings
	  Local $GUIDeadBasesOnly = (_GUICtrlButton_GetCheck($GUI_AutoRaidDeadBases) = $BST_CHECKED)
	  If $GUIDeadBasesOnly And IsColorPresent($rDeadBaseIndicatorColor)=False Then
		 DebugWrite("Not dead base, skipping.")

	  Else
		 $snipable = CheckForSnipableTH($level, $location, $left, $top)

	  EndIf

	  ; If snipable, then go do it
	  If $snipable=True Then Return $snipable

	  ; Not snipable - click Next
	  Sleep($gPauseBetweenNexts)
	  RandomWeightedClick($rWaitRaidScreenNextButton)
	  Sleep(500)

	  ; Sleep and wait for Next button to reappear
	  $failCount = 30
	  While IsButtonPresent($rWaitRaidScreenNextButton) = False And _
		    IsButtonPresent($rAndroidMessageButton1) = False And _
		    IsButtonPresent($rAndroidMessageButton2) = False And _
			AttackingIsDisabled() = False And _
			$failCount>0

		 Sleep(1000)
		 $failCount -= 1
	  WEnd

	  If AttackingIsDisabled() Then
		 DebugWrite("Find Match failed (AS2) - Attacking is Disabled")
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

	  If $failCount = 0 Or IsButtonPresent($rAndroidMessageButton1) Or IsButtonPresent($rAndroidMessageButton2) Then
		 If $failCount = 0 Then
			DebugWrite("Find Match failed (AS2) - timeout waiting for Wait Raid screen")
		 Else
			DebugWrite("Find Match failed (AS2) - Android message box popup")
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

Func CheckForSnipableTH(ByRef $level, ByRef $location, ByRef $left, ByRef $top)
   ; See if we can find the Town Hall location
   $level = GetTownHallLevel(True, $location, $left, $top)

   ; Town Hall images are 22x24
   Local $x = $left+11
   Local $y = $top+12

   If $level = -1 Then
	  DebugWrite("Could not find Town Hall.  Obscured?")
	  Return False
   EndIf

   Local $dist
   If $location = "Top" Then
	  $dist = DistBetweenTwoPoints($x, $y, $gScreenCenterDraggedDown[0], $gScreenCenterDraggedDown[1])
   Else
	  $dist = DistBetweenTwoPoints($x, $y, $gScreenCenterDraggedUp[0], $gScreenCenterDraggedUp[1])
   EndIf

   If $dist <= 175 Then
	  DebugWrite("Town Hall level " & $level & " found at " & $left & ", " & $top & ".  Dist = " & Round($dist) & ". Not snipable.")
	  Return False
   Else
	  DebugWrite("Town Hall level " & $level & " found at " & $left & ", " & $top & ".  Dist = " & Round($dist) & ". Snipable!")
	  Return $eAutoExecuteSnipe
   EndIf

EndFunc

Func THSnipeExecute(Const $THLevel, Const $THLocation, Const $THLeft, Const $THTop)
   DebugWrite("THSnipeExecute()")

   Local $deployBoxes[2][4]
   THSnipeFindClosestDeployBoxes($THLocation, $THLeft, $THTop, $deployBoxes)

   ; What troops are available?
   Local $troopIndex[$eTroopCount][5]
   FindRaidTroopSlotsAndCounts($gTroopSlotBMPs, $troopIndex)

   Local $barbButton[4] = [$troopIndex[$eTroopBarbarian][0], $troopIndex[$eTroopBarbarian][1], $troopIndex[$eTroopBarbarian][2], $troopIndex[$eTroopBarbarian][3]]
   Local $archButton[4] = [$troopIndex[$eTroopArcher][0], $troopIndex[$eTroopArcher][1], $troopIndex[$eTroopArcher][2], $troopIndex[$eTroopArcher][3]]
   Local $kingButton[4] = [$troopIndex[$eTroopKing][0], $troopIndex[$eTroopKing][1], $troopIndex[$eTroopKing][2], $troopIndex[$eTroopKing][3]]
   Local $queenButton[4] = [$troopIndex[$eTroopQueen][0], $troopIndex[$eTroopQueen][1], $troopIndex[$eTroopQueen][2], $troopIndex[$eTroopQueen][3]]
   Local $wardenButton[4] = [$troopIndex[$eTroopWarden][0], $troopIndex[$eTroopWarden][1], $troopIndex[$eTroopWarden][2], $troopIndex[$eTroopWarden][3]]

   ; Try deploying heroes first, immediately power them up
   ; Deploy King
   If $troopIndex[$eTroopKing][4]>0 Then
	  DebugWrite("Deploying Barbarian King.")
	  RandomWeightedClick($kingButton)
	  Sleep(200)

	  Local $xClick, $yClick
	  Local $box[4] = [$deployBoxes[0][0], $deployBoxes[0][1], $deployBoxes[0][2], $deployBoxes[0][3]]
	  RandomCoords($box, $xClick, $yClick)
	  _MouseClickFast($xClick, $yClick)
	  Sleep(200)
   EndIf

   If _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox)=$BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED Then Return False

   ; Deploy Queen
   If $troopIndex[$eTroopQueen][4] > 0 Then
	  DebugWrite("Deploying Archer Queen.")
	  RandomWeightedClick($queenButton)
	  Sleep(200)

	  Local $xClick, $yClick
	  Local $box[4] = [$deployBoxes[0][0], $deployBoxes[0][1], $deployBoxes[0][2], $deployBoxes[0][3]]
	  RandomCoords($box, $xClick, $yClick)
	  _MouseClickFast($xClick, $yClick)
	  Sleep(200)
   EndIf

   If _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox)=$BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED Then Return False

   ; Deploy Warden
   If $troopIndex[$eTroopWarden][4] > 0 Then
	  DebugWrite("Deploying Grand Warden.")
	  RandomWeightedClick($wardenButton)
	  Sleep(200)

	  Local $xClick, $yClick
	  Local $box[4] = [$deployBoxes[0][0], $deployBoxes[0][1], $deployBoxes[0][2], $deployBoxes[0][3]]
	  RandomCoords($box, $xClick, $yClick)
	  _MouseClickFast($xClick, $yClick)
	  Sleep(200)
   EndIf

   If _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox)=$BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED Then Return False

   ; Power up heroes
   If $troopIndex[$eTroopKing][4] > 0 Then
	  DebugWrite("Powering up Barbarian King.")
	  RandomWeightedClick($kingButton)
	  Sleep(200)
   EndIf

   If $troopIndex[$eTroopQueen][4] > 0 Then
	  DebugWrite("Powering up Archer Queen.")
	  RandomWeightedClick($queenButton)
	  Sleep(200)
   EndIf

   If $troopIndex[$eTroopWarden][4] > 0 Then
	  DebugWrite("Powering up Grand Warden.")
	  RandomWeightedClick($wardenButton)
	  Sleep(200)
   EndIf

   If _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox)=$BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED Then Return False

   ; Wait for 15 seconds and see if heroes take care of the TH
   If $troopIndex[$eTroopKing][4]>0 Or $troopIndex[$eTroopQueen][4]>0 Or $troopIndex[$eTroopWarden][4]>0 Then
	  Local $t = TimerInit()
	  While IsColorPresent($rFirstStarColor)=False And TimerDiff($t)<15000
		 Sleep(200)
	  WEnd

	  If IsColorPresent($rFirstStarColor) = True Then
		 ; End Battle
		 For $i = 1 to 5
			If IsColorPresent($rFirstStarColor) Then
			   RandomWeightedClick($rLiveRaidScreenEndBattleButton)

			   Local $t=TimerInit()
			   While IsButtonPresent($rLiveRaidScreenEndBattleConfirmButton) = False And TimerDiff($t)<2000
				  Sleep(50)
			   WEnd

			   RandomWeightedClick($rLiveRaidScreenEndBattleConfirmButton)
			   ExitLoop
			EndIf

			Sleep(1000)
		 Next

		 WaitForBattleEnd(True, True, True)

		 Return True
	  EndIf
   EndIf

   If _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox)=$BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED Then Return False


   ; If heroes didn't take care of it, then send barchers in waves, check star color region for success
   Local $waveDelay = 17000
   Local $waveTroopsBarb = 20
   Local $waveTroopsArch = 10
   Local $waveCount = 0

   While IsColorPresent($rFirstStarColor) = False
	  Local $waveTimer = TimerInit()
	  $waveCount+=1
	  DebugWrite("Town hall snipe, wave " & $waveCount)

	  Local $availableBarbs = $troopIndex[$eTroopBarbarian][4]
	  Local $availableArchs = $troopIndex[$eTroopArcher][4]
	  DebugWrite("Troops available: Barbarians=" & $availableBarbs & " Archers=" & $availableArchs)

	  If _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox)=$BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED Then Return False

	  ; Deploy barbs to boxes
	  If $availableBarbs>0 Then
		 Local $c = $waveTroopsBarb + Random(1, 5, 1)
		 Local $deployAmount = ($availableBarbs<=$c ? $availableBarbs : $c)
		 DebugWrite("Deploying " & $deployAmount & " barbarians.")

		 RandomWeightedClick($barbButton)
		 Sleep(500)

		 Local $clickPoints[$deployAmount][2]
		 THSnipeGetClickPoints(Random(0,1,1), $deployBoxes, $clickPoints)

		 For $i = 0 To $deployAmount-1
			_MouseClickFast($clickPoints[$i][0], $clickPoints[$i][1])
			Sleep($gDeployTroopClickDelay)
		 Next
	  EndIf

	  If IsColorPresent($rFirstStarColor) = True Then ExitLoop

	  If _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox)=$BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED Then Return False

	  ; Deploy archers to boxes
	  If $availableArchs>0 Then
		 Local $c = $waveTroopsArch + Random(1, 5, 1)
		 Local $deployAmount = ($availableArchs<=$c ? $availableArchs : $c)
		 DebugWrite("Deploying " & $deployAmount & " archers.")

		 RandomWeightedClick($archButton)
		 Sleep(500)

		 Local $clickPoints[$deployAmount][2]
		 THSnipeGetClickPoints(Random(0,1,1), $deployBoxes, $clickPoints)

		 For $i = 0 To $deployAmount-1
			_MouseClickFast($clickPoints[$i][0], $clickPoints[$i][1])
			Sleep($gDeployTroopClickDelay)
		 Next
	  EndIf

	  If IsColorPresent($rFirstStarColor) = True Then ExitLoop

	  If _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox)=$BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED Then Return False

	  ; Get counts of available troops
	  FindRaidTroopSlotsAndCounts($gTroopSlotBMPs, $troopIndex)
	  If $availableBarbs=0 And $availableArchs=0 Then ExitLoop

	  ; Wait for timer
	  Local $rand = Random(1000, 3000, 1)
	  While TimerDiff($waveTimer) < $waveDelay+$rand
		 If _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox) = $BST_UNCHECKED Then Return False
		 If IsColorPresent($rFirstStarColor) = True Then ExitLoop 2
		 Sleep(200)
	  WEnd

   WEnd

   ; End battle
   For $i = 1 to 5

	  If IsColorPresent($rFirstStarColor) Then
		 RandomWeightedClick($rLiveRaidScreenEndBattleButton)
		 Sleep(1000)
		 RandomWeightedClick($rLiveRaidScreenEndBattleConfirmButton)
		 ExitLoop
	  EndIf

	  Sleep(1000)
   Next

   ; Wait for end battle
   WaitForBattleEnd(True, True, True)  ; always wait full time, or until all troops are dead

   Return True
EndFunc

Func THSnipeGetClickPoints(Const $order, Const ByRef $boxes, ByRef $points)
   ; First parameter is 0 = ascending, 1 = descending
   For $i = 0 To UBound($points)-1
	  Local $deployBox[4]
	  Local $boxIndex = Random(0, UBound($boxes)-1, 1)
	  For $j = 0 To 3
		 $deployBox[$j] = $boxes[$boxIndex][$j]
	  Next

	  RandomCoords($deployBox, $points[$i][0], $points[$i][1])
   Next

   _ArraySort($points, $order)
EndFunc

Func THSnipeFindClosestDeployBoxes(Const $loc, Const $left, Const $top, ByRef $selectedBoxes)
   ; Town Hall images are 22x24
   Local $x = $left+11
   Local $y = $top+12

   If $loc = "Top" Then
	  ; If on the North corner
	  If $y<160 And $x>=$gScreenCenterDraggedDown[0]-80 And $x<=$gScreenCenterDraggedDown[0]+80 Then
		 $selectedBoxes[0][0] = $rTHSnipeNorthDeployBox[0]
		 $selectedBoxes[0][1] = $rTHSnipeNorthDeployBox[1]
		 $selectedBoxes[0][2] = $rTHSnipeNorthDeployBox[2]
		 $selectedBoxes[0][3] = $rTHSnipeNorthDeployBox[3]
		 DebugWrite("Closest top box " & $selectedBoxes[0][0] & ", " & $selectedBoxes[0][1] & ", " & $selectedBoxes[0][2] & ", " & $selectedBoxes[0][3])

	  ; If on the East corner
	  ElseIf $x<189 And $y>=$gScreenCenterDraggedDown[1]-80 And $y<=$gScreenCenterDraggedDown[1]+80 Then
		 $selectedBoxes[0][0] = $rTHSnipeEastDeployBox[0]
		 $selectedBoxes[0][1] = $rTHSnipeEastDeployBox[1]
		 $selectedBoxes[0][2] = $rTHSnipeEastDeployBox[2]
		 $selectedBoxes[0][3] = $rTHSnipeEastDeployBox[3]
		 DebugWrite("Closest east box " & $selectedBoxes[0][0] & ", " & $selectedBoxes[0][1] & ", " & $selectedBoxes[0][2] & ", " & $selectedBoxes[0][3])

	  ; If on the West corner
	  ElseIf $x>669 And $y>=$gScreenCenterDraggedDown[1]-80 And $y<=$gScreenCenterDraggedDown[1]+80 Then
		 $selectedBoxes[0][0] = $rTHSnipeWestDeployBox[0]
		 $selectedBoxes[0][1] = $rTHSnipeWestDeployBox[1]
		 $selectedBoxes[0][2] = $rTHSnipeWestDeployBox[2]
		 $selectedBoxes[0][3] = $rTHSnipeWestDeployBox[3]
		 DebugWrite("Closest west box " & $selectedBoxes[0][0] & ", " & $selectedBoxes[0][1] & ", " & $selectedBoxes[0][2] & ", " & $selectedBoxes[0][3])

	  Else
		 Local $allBoxes[$gMaxDeployBoxes][5] ; 5th column will hold the calculated distance
		 For $i=0 To $gMaxDeployBoxes-1
			$allBoxes[$i][0] = ($x<=$gScreenCenterDraggedDown[0] ? $NWDeployBoxes[$i][0]    : $NEDeployBoxes[$i][2]-10)
			$allBoxes[$i][1] = ($x<=$gScreenCenterDraggedDown[0] ? $NWDeployBoxes[$i][1]    : $NEDeployBoxes[$i][1])
			$allBoxes[$i][2] = ($x<=$gScreenCenterDraggedDown[0] ? $NWDeployBoxes[$i][0]+10 : $NEDeployBoxes[$i][2])
			$allBoxes[$i][3] = ($x<=$gScreenCenterDraggedDown[0] ? $NWDeployBoxes[$i][1]+10 : $NEDeployBoxes[$i][1]+10)
		 Next

		 ; Get closest point on the edge
		 Local $edgeX, $edgeY
		 THSnipeGetClosestEdgePoint("Top", $left, $top, $edgeX, $edgeY)
		 DebugWrite("Closest edge point to " & $x & "," & $y & " is " & $edgeX & "," & $edgeY)

		 ; Get closest boxes
		 SortBoxesByDistance($edgeX, $edgeY, $allBoxes)

		 For $i = 0 To UBound($selectedBoxes)-1
			For $j = 0 To 3
			   $selectedBoxes[$i][$j] = $allBoxes[$i][$j]
			Next
			DebugWrite("Closest top half box " & $i & ": " & $selectedBoxes[$i][0] & ", " & $selectedBoxes[$i][1] & ", " & $selectedBoxes[$i][2] & ", " & $selectedBoxes[$i][3])
		 Next
	  EndIf

   ElseIf $loc = "Bot" Then
	  ; If on the South corner
	  If $y>406 And $x>=$gScreenCenterDraggedDown[0]-80 And $x<=$gScreenCenterDraggedDown[0]+80 Then
		 $selectedBoxes[0][0] = $rTHSnipeSouthDeployBox[0]
		 $selectedBoxes[0][1] = $rTHSnipeSouthDeployBox[1]
		 $selectedBoxes[0][2] = $rTHSnipeSouthDeployBox[2]
		 $selectedBoxes[0][3] = $rTHSnipeSouthDeployBox[3]
		 DebugWrite("Closest bottom box " & $selectedBoxes[0][0] & ", " & $selectedBoxes[0][1] & ", " & $selectedBoxes[0][2] & ", " & $selectedBoxes[0][3])

	  Else
		 Local $allBoxes[$gMaxDeployBoxes][5] ; 5th column will hold the calculated distance
		 For $i=0 To $gMaxDeployBoxes-1
			$allBoxes[$i][0] = ($x<=$gScreenCenterDraggedUp[0] ? $SWDeployBoxes[$i][0]    : $SEDeployBoxes[$i][2]-10)
			$allBoxes[$i][1] = ($x<=$gScreenCenterDraggedUp[0] ? $SWDeployBoxes[$i][3]-10 : $SEDeployBoxes[$i][3]-10)
			$allBoxes[$i][2] = ($x<=$gScreenCenterDraggedUp[0] ? $SWDeployBoxes[$i][0]+10 : $SEDeployBoxes[$i][2])
			$allBoxes[$i][3] = ($x<=$gScreenCenterDraggedUp[0] ? $SWDeployBoxes[$i][3]    : $SEDeployBoxes[$i][3])
		 Next

		 ; Get closest point on the edge
		 Local $edgeX, $edgeY
		 THSnipeGetClosestEdgePoint("Bot", $left, $top, $edgeX, $edgeY)
		 DebugWrite("Closest edge point to " & $x & "," & $y & " is " & $edgeX & "," & $edgeY)

		 ; Get closest boxes
		 SortBoxesByDistance($edgeX, $edgeY, $allBoxes)

		 For $i = 0 To UBound($selectedBoxes)-1
			For $j = 0 To 3
			   $selectedBoxes[$i][$j] = $allBoxes[$i][$j]
			Next
			DebugWrite("Closest bottom half box " & $i & ": " & $selectedBoxes[$i][0] & ", " & $selectedBoxes[$i][1] & ", " & $selectedBoxes[$i][2] & ", " & $selectedBoxes[$i][3])
		 Next
	  EndIf

   Else
	  DebugWrite("ERROR in THSnipeFindClosestDeployBoxes, location = " & $loc)

   EndIf
EndFunc

; WARNING: Algebra!
; https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
Func THSnipeGetClosestEdgePoint(Const $topOrBot, Const $left, Const $top, ByRef $edgeX, ByRef $edgeY)
   ; Town Hall images are 22x24
   Local $x = $left+11
   Local $y = $top+12

   If $topOrBot = "Top" Then
	  If $x <= $gScreenCenterDraggedDown[0] Then
		 ; NW edge end points are 72, 332 and 429, 66
		 ; slope ==> y2-y1/x2-x1 ==> 66-332/429-72 ==> -0.745
		 ; line eq ==> y-y1=m(x-x1) ==> y-332=-0.745(x-72) ==> y=-0.745x+385.64
		 ; closest x = ($x + m*$y - m*b) / (m*m + 1) ==> ($x + -0.745*$y + 287.302) / 1.555
		 ; closest y = m * ( ($x + m*$y - m*b) / (m*m + 1) ) + b ==> -0.745 * ( ($x + -0.745*$y + 287.302) / 1.555 ) + 385.64

		 $edgeX = Int( ($x + -0.745*$y + 287.302) / 1.555 )
		 $edgeY = Int( -0.745 * ( ($x + -0.745*$y + 287.302) / 1.555 ) + 385.64 )

	  Else
		 ; NE edge end points are 429, 66 and 786, 332
		 ; slope ==> y2-y1/x2-x1 ==> 332-66/786-429 ==> 0.745
		 ; line eq ==> y-y1=m(x-x1) ==> y-66=0.745(x-429) ==> y=0.745x-253.605
		 ; closest x = ($x + m*$y - m*b) / (m*m + 1) ==> ($x + 0.745*$y + 188.936) / 1.555
		 ; closest y = m * ( ($x + m*$y - m*b) / (m*m + 1) ) + b ==> 0.745 * ( ($x + 0.745*$y + 188.936) / 1.555 ) - 253.605

		 $edgeX = Int( ($x + 0.745*$y + 188.936) / 1.555 )
		 $edgeY = Int( 0.745 * ( ($x + 0.745*$y + 188.936) / 1.555 ) - 253.605 )

	  EndIf

   Else
	  If $x <= $gScreenCenterDraggedDown[0] Then
		 ; SW edge end points are 72, 234 and 429, 500
		 ; slope ==> y2-y1/x2-x1 ==> 500-234/429-72 ==> 0.745
		 ; line eq ==> y-y1=m(x-x1) ==> y-234=0.745(x-72) ==> y=0.745x+180.36
		 ; closest x = ($x + m*$y - m*b) / (m*m + 1) ==> ($x + 0.745*$y - 134.368) / 1.555
		 ; closest y = m * ( ($x + m*$y - m*b) / (m*m + 1) ) + b ==> 0.745 * ( ($x + 0.745*$y - 134.368) / 1.555 ) + 180.36

		 $edgeX = Int( ($x + 0.745*$y - 134.368) / 1.555 )
		 $edgeY = Int( 0.745 * ( ($x + 0.745*$y - 134.368) / 1.555 ) + 180.36 )

	  Else
		 ; SE edge end points are 429, 500 and 786, 234
		 ; slope ==> y2-y1/x2-x1 ==> 234-500/786-429 ==> -0.745
		 ; line eq ==> y-y1=m(x-x1) ==> y-500=-0.745(x-429) ==> y=-0.745x+819.605
		 ; closest x = ($x + m*$y - m*b) / (m*m + 1) ==> ($x + -0.745*$y + 610.606) / 1.555
		 ; closest y = m * ( ($x + m*$y - m*b) / (m*m + 1) ) + b ==> -0.745 * ( ($x + -0.745*$y + 610.606) / 1.555 ) + 819.605

		 $edgeX = Int( ($x + -0.745*$y + 610.606) / 1.555 )
		 $edgeY = Int( -0.745 * ( ($x + -0.745*$y + 610.606) / 1.555 ) + 819.605 )
	  EndIf

   EndIf
EndFunc

Func SortBoxesByDistance(Const $x, Const $y, ByRef $boxes)
   For $i = 0 To UBound($boxes)-1
	  Local $boxX = $boxes[$i][0] + Int( ($boxes[$i][2]-$boxes[$i][0])/2 )
	  Local $boxY = $boxes[$i][1] + Int( ($boxes[$i][3]-$boxes[$i][1])/2 )
	  $boxes[$i][4] = DistBetweenTwoPoints($x, $y, $boxX, $boxY)
   Next

   _ArraySort($boxes, 0, 0, UBound($boxes)-1, 4)
EndFunc



