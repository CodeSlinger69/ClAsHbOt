Func AutoSnipe(ByRef $timer, ByRef $THLevel, ByRef $THLocation, ByRef $THLeft, ByRef $THTop)
   ;DebugWrite("AutoSnipe()")

   If $gAutoSnipeNotifyOnly Then
	  $gAutoStage = $eAutoFindMatch
	  DebugWrite("Auto Snipe, notify mode")
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

	  Local $findMatchResults = AutoSnipeFindMatch($THLevel, $THLocation, $THLeft, $THTop)

	  ; Reset if there was an error
	  If $findMatchResults=False Then
		 DebugWrite("Auto: Error finding match, resetting.")
		 ResetToCoCMainScreen()
		 $gAutoStage = $eAutoQueueTraining
		 Return
	  EndIf

	  ; Did we find a snipable base?
	  If $findMatchResults = $eAutoExecute And $gAutoSnipeNotifyOnly Then
		 For $i = 1 To 5
			Beep(500, 200)
			Sleep(100)
		 Next

		 MsgBox($MB_OK, "Snipable TH!", "")
		 Return
	  EndIf

	  If $findMatchResults = $eAutoExecute Then $gAutoStage = $eAutoExecute

   ; Stage Execute Snipe
   Case $eAutoExecute
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Execute Snipe")
	  If AutoSnipeExecuteSnipe($THLevel, $THLocation, $THLeft, $THTop) Then
		 $gAutoStage = $eAutoQueueTraining
		 UpdateWinnings()
	  EndIf

	  GUICtrlSetData($GUI_AutoStatus, "Auto: Snipe Complete")

   EndSwitch

EndFunc

Func AutoSnipeFindMatch(ByRef $level, ByRef $location, ByRef $left, ByRef $top)
   DebugWrite("AutoSnipeFindMatch()")

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

	  ; See if Shield Is Active screen pops up
	  If WhereAmI() = $eScreenShieldIsActive Then
		 RandomWeightedClick($rShieldIsActivePopupButton)
		 Sleep(500)
	  EndIf

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
	  If _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox) = $BST_UNCHECKED Then Return False

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
	  If $snipable=True Then
		 Return $snipable
	  EndIf

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

   ; See if we can find the Town Hall on the whole screen: top, middle or bottom
   $level = GetTownHallLevel($location, $left, $top)

   If $level = -1 Then
	  DebugWrite("Could not find Town Hall.  Obscured?")
	  Return False
   EndIf
#cs
   ; middle
   If $location = $eTownHallMiddle Then
	  Local $dist = DistBetweenTwoPoints($left+17, $top+17, 511, 273)
	  If $dist <=200 Then
		 DebugWrite("Town Hall level " & $level & " found in Middle at " & $left & ", " & $top & ".  Not snipable.")
		 Return False
	  Else
		 DebugWrite("Town Hall level " & $level & " found in Middle at " & $left & ", " & $top & ".  Snipable!")
		 Return True
	  EndIf

   ; top
   ElseIf $location = $eTownHallTop Then
	  Local $dist = DistBetweenTwoPoints($left+17, $top+17, 511, 320)
	  If $dist < 150 Then
		 DebugWrite("Town Hall level " & $level & " found at Top at " & $left & ", " & $top & ".  Not snipable.")
		 Return False
	  Else
		 DebugWrite("Town Hall level " & $level & " found at Top at " & $left & ", " & $top & ".  Snipable!")
		 Return True
	  EndIf

   ; bottom
   ElseIf $location = $eTownHallBottom Then
	  Local $dist = DistBetweenTwoPoints($left+17, $top+17, 511, 140)
	  If $dist < 150 Then
		 DebugWrite("Town Hall level " & $level & " found at Bottom at " & $left & ", " & $top & ".  Not snipable.")
		 Return False
	  Else
		 DebugWrite("Town Hall level " & $level & " found at Bottom at " & $left & ", " & $top & ".  Snipable!")
		 Return True
	  EndIf

   EndIf
#ce
EndFunc

Func AutoSnipeExecuteSnipe(Const $THLevel, Const $THLocation, Const $THLeft, Const $THTop)
   DebugWrite("AutoSnipeExecuteSnipe()")

   Local $deployTopOrBot = "TODO"
   Local $actualTHTop = 0

   ; Find best deploy spot, based on deployment boxes
   Local $boxCount
   If $deployTopOrBot = "Center" Then
	  $boxCount = 6
   ElseIf $deployTopOrBot = "Top" And $actualTHTop+17 < 200 Then
	  $boxCount = 6
   ElseIf $deployTopOrBot = "Bottom" And $actualTHTop+17 > 315 Then
	  $boxCount = 6
   Else
	  $boxCount = 3
   EndIf

   Local $deployBoxes[$boxCount][4]
   AutoSnipeFindClosestDeployBoxes($deployTopOrBot, $THLeft, $actualTHTop, $deployBoxes)

   ; What troops are available?
   Local $troopIndex[$eTroopCount][4]
   FindRaidTroopSlots($gTroopSlotBMPs, $troopIndex)
   Local $breakerButton[4] = [$troopIndex[$eTroopWallBreaker][0], $troopIndex[$eTroopWallBreaker][1], $troopIndex[$eTroopWallBreaker][2], $troopIndex[$eTroopWallBreaker][3]]
   Local $barbButton[4] = [$troopIndex[$eTroopBarbarian][0], $troopIndex[$eTroopBarbarian][1], $troopIndex[$eTroopBarbarian][2], $troopIndex[$eTroopBarbarian][3]]
   Local $archButton[4] = [$troopIndex[$eTroopArcher][0], $troopIndex[$eTroopArcher][1], $troopIndex[$eTroopArcher][2], $troopIndex[$eTroopArcher][3]]
   Local $kingButton[4] = [$troopIndex[$eTroopKing][0], $troopIndex[$eTroopKing][1], $troopIndex[$eTroopKing][2], $troopIndex[$eTroopKing][3]]
   Local $queenButton[4] = [$troopIndex[$eTroopQueen][0], $troopIndex[$eTroopQueen][1], $troopIndex[$eTroopQueen][2], $troopIndex[$eTroopQueen][3]]

   ; send troops in waves, check star color region for success
   Local $breakersDeployed = False, $kingDeployed = False, $queenDeployed = False
   Local $waveDelay = 13000
   Local $waveTroopsBarb = 30
   Local $waveTroopsArch = 20
   Local $waveCount = 0

   While IsColorPresent($rFirstStarColor) = False
	  Local $waveTimer = TimerInit()
	  $waveCount+=1
	  DebugWrite("Auto snipe, wave " & $waveCount)

	  ; Get counts of available troops
	  Local $availableBarbs = GetAvailableTroops($eTroopBarbarian, $troopIndex)
	  Local $availableArchs = GetAvailableTroops($eTroopArcher, $troopIndex)
	  Local $availableBreakers = GetAvailableTroops($eTroopWallBreaker, $troopIndex)
	  DebugWrite("Troops available: Barbarians=" & $availableBarbs & " Archers=" & $availableArchs & _
		 (_GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED ? " Breakers=" & $availableBreakers : "") )

	  If _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox) = $BST_UNCHECKED Then Return False

	  ; Deploy barbs to boxes
	  If $barbButton[0]<>-1 And $availableBarbs>0 Then
		 Local $c = $waveTroopsBarb + Random(1, 5, 1)
		 ;If $THLevel = 10 Then $c*=2 ; If this is TH10, then double up - these seem to be trapped more often than not
		 Local $deploy = ($availableBarbs<=$c ? $availableBarbs : $c)
		 DebugWrite("Deploying " & $deploy & " barbarians.")

		 RandomWeightedClick($barbButton)
		 Sleep(500)

		 Local $startingBarbs = $availableBarbs
		 Local $currentBarbs = $availableBarbs
		 Local $failCount = 10
		 While $startingBarbs-$currentBarbs<$deploy And $failCount>0
			Local $remaining = $deploy - ($startingBarbs-$currentBarbs)
			Local $clickPoints[$remaining][2]
			GetAutoSnipeClickPoints(Random(0,1,1), $deployBoxes, $clickPoints)

			For $i = 0 To $remaining-1
			   _MouseClickFast($clickPoints[$i][0], $clickPoints[$i][1])
			   Sleep($gDeployTroopClickDelay)
			Next

			$currentBarbs = GetAvailableTroops($eTroopBarbarian, $troopIndex)
			$failCount-=1
		 WEnd
	  EndIf

	  If IsColorPresent($rFirstStarColor) = True Then ExitLoop

	  If _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox) = $BST_UNCHECKED Then Return False

	  ; Deploy breakers
	  If $breakerButton[0]<>-1 And $availableBreakers>0 And $breakersDeployed = False And _
		 _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED Then

		 DebugWrite("Deploying " & $availableBreakers & " wall breakers.")
		 RandomWeightedClick($breakerButton)
		 Sleep(500)

		 Local $clickPoints[$availableBreakers][2]
		 GetAutoSnipeClickPoints(Random(0,1,1), $deployBoxes, $clickPoints)

		 For $i = 0 To $availableBreakers-1
			_MouseClickFast($clickPoints[$i][0], $clickPoints[$i][1])
			Sleep($gDeployTroopClickDelay)
		 Next

		 $breakersDeployed = True
	  EndIf

	  ; Deploy archers to boxes
	  If $archButton[0]<>-1 And $availableArchs>0 Then
		 Local $c = $waveTroopsArch + Random(1, 5, 1)
		 ;If $THLevel = 10 Then $c*=2 ; If this is TH10, then double up - these seem to be trapped more often than not
		 Local $deploy = ($availableArchs<=$c ? $availableArchs : $c)
		 DebugWrite("Deploying " & $deploy & " archers.")

		 RandomWeightedClick($archButton)
		 Sleep(500)

		 Local $startingArchs = $availableArchs
		 Local $currentArchs = $availableArchs
		 Local $failCount = 10
		 While $startingArchs-$currentArchs<$deploy And $failCount>0
			Local $remaining = $deploy - ($startingArchs-$currentArchs)
			Local $clickPoints[$remaining][2]
			GetAutoSnipeClickPoints(Random(0,1,1), $deployBoxes, $clickPoints)

			For $i = 0 To $remaining-1
			   _MouseClickFast($clickPoints[$i][0], $clickPoints[$i][1])
			   Sleep($gDeployTroopClickDelay)
			Next
			$currentArchs = GetAvailableTroops($eTroopArcher, $troopIndex)
			$failCount-=1
		 WEnd

	  EndIf

	  If IsColorPresent($rFirstStarColor) = True Then ExitLoop

	  If _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox) = $BST_UNCHECKED Then Return False

	  ; Deploy King if we ran out of Barbs and power up after 2 seconds
	  If $kingButton[0] <> -1 And $availableBarbs=0 And $kingDeployed=False Then
		 DebugWrite("Deploying Barbarian King.")
		 RandomWeightedClick($kingButton)
		 Sleep(500)

		 Local $xClick, $yClick
		 Local $box[4] = [$deployBoxes[0][0], $deployBoxes[0][1], $deployBoxes[0][2], $deployBoxes[0][3]]
		 RandomCoords($box, $xClick, $yClick)
		 _MouseClickFast($xClick, $yClick)
		 Sleep(2000)

		 DebugWrite("Powering up Barbarian King.")
		 RandomWeightedClick($kingButton)
		 Sleep(500)

		 $kingDeployed = True
	  EndIf

	  If _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox) = $BST_UNCHECKED Then Return False

	  ; Deploy Queen if we ran out of Archs and power up after 2 seconds
	  If $queenButton[0] <> -1 And $availableArchs=0 And $queenDeployed=False Then
		 DebugWrite("Deploying Archer Queen.")
		 RandomWeightedClick($queenButton)
		 Sleep(500)

		 Local $xClick, $yClick
		 Local $box[4] = [$deployBoxes[0][0], $deployBoxes[0][1], $deployBoxes[0][2], $deployBoxes[0][3]]
		 RandomCoords($box, $xClick, $yClick)
		 _MouseClickFast($xClick, $yClick)
		 Sleep(2000)

		 DebugWrite("Powering up Archer Queen.")
		 RandomWeightedClick($queenButton)
		 Sleep(500)

		 $queenDeployed = True
	  EndIf

	  If $availableBarbs=0 And $availableArchs=0 Then ExitLoop

	  ; Wait for timer
	  Local $rand = Random(1000, 3000, 1)
	  While TimerDiff($waveTimer) < $waveDelay+$rand
		 If _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox) = $BST_UNCHECKED Then Return False
		 If IsColorPresent($rFirstStarColor) = True Then ExitLoop 2
		 Sleep(200)
	  WEnd

   WEnd

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
   WaitForBattleEnd(True, True)  ; always wait full 3 minutes, or until all troops are dead

   Return True
EndFunc

Func GetAutoSnipeClickPoints(Const $order, Const ByRef $boxes, ByRef $points)
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

Func AutoSnipeFindClosestDeployBoxes(Const $topOrBot, Const $left, Const $top, ByRef $selectedBoxes)
   If $topOrBot = "Center" Then
	  For $i = 0 To 2
		 $selectedBoxes[$i][0] = ($left+17<=511 ? $NWDeployBoxes[$i][0]       : $NEDeployBoxes[$i][2]-10)
		 $selectedBoxes[$i][1] = ($left+17<=511 ? $NWDeployBoxes[$i][1]-83    : $NEDeployBoxes[$i][1]-83)
		 $selectedBoxes[$i][2] = ($left+17<=511 ? $NWDeployBoxes[$i][0]+10    : $NEDeployBoxes[$i][2])
		 $selectedBoxes[$i][3] = ($left+17<=511 ? $NWDeployBoxes[$i][1]-83+10 : $NEDeployBoxes[$i][1]-83+10)
		 DebugWrite("Closest side box " & $i & ": " & $selectedBoxes[$i][0] & ", " & $selectedBoxes[$i][1] & ", " & $selectedBoxes[$i][2] & ", " & $selectedBoxes[$i][3])
	  Next
	  For $i = 0 To 2
		 $selectedBoxes[3+$i][0] = ($left+17<=511 ? $SWDeployBoxes[$i][0]        : $SEDeployBoxes[$i][2]-10)
		 $selectedBoxes[3+$i][1] = ($left+17<=511 ? $SWDeployBoxes[$i][3]+155-10 : $SEDeployBoxes[$i][3]+155-10)
		 $selectedBoxes[3+$i][2] = ($left+17<=511 ? $SWDeployBoxes[$i][0]+10     : $SEDeployBoxes[$i][2])
		 $selectedBoxes[3+$i][3] = ($left+17<=511 ? $SWDeployBoxes[$i][3]+155    : $SEDeployBoxes[$i][3]+155)
		 DebugWrite("Closest side box " & 3+$i & ": " & $selectedBoxes[3+$i][0] & ", " & $selectedBoxes[3+$i][1] & ", " & $selectedBoxes[3+$i][2] & ", " & $selectedBoxes[3+$i][3])
	  Next

   ElseIf $topOrBot = "Top" Then
	  ; If on the top corner
	  If $top+17<160 And $left+17>=411 And $left+17<=611 Then
		 For $i = 18 To 20
			$selectedBoxes[$i-18][0] = $NWDeployBoxes[$i][0]
			$selectedBoxes[$i-18][1] = $NWDeployBoxes[$i][1]
			$selectedBoxes[$i-18][2] = $NWDeployBoxes[$i][0]+10
			$selectedBoxes[$i-18][3] = $NWDeployBoxes[$i][1]+10
			DebugWrite("Closest top box " & $i-18 & ": " & $selectedBoxes[$i-18][0] & ", " & $selectedBoxes[$i-18][1] & ", " & $selectedBoxes[$i-18][2] & ", " & $selectedBoxes[$i-18][3])
		 Next
		 For $i = 18 To 20
			$selectedBoxes[$i-18+3][0] = $NEDeployBoxes[$i][2]-10
			$selectedBoxes[$i-18+3][1] = $NEDeployBoxes[$i][1]
			$selectedBoxes[$i-18+3][2] = $NEDeployBoxes[$i][2]
			$selectedBoxes[$i-18+3][3] = $NEDeployBoxes[$i][1]+10
			DebugWrite("Closest top box " & $i-18+3 & ": " & $selectedBoxes[$i-18+3][0] & ", " & $selectedBoxes[$i-18+3][1] & ", " & $selectedBoxes[$i-18+3][2] & ", " & $selectedBoxes[$i-18+3][3])
		 Next

	  Else
		 Local $allBoxes[21][5] ; 5th column will hold the calculated distance
		 For $i=0 To 20
			$allBoxes[$i][0] = ($left+17<=511 ? $NWDeployBoxes[$i][0]    : $NEDeployBoxes[$i][2]-10)
			$allBoxes[$i][1] = ($left+17<=511 ? $NWDeployBoxes[$i][1]    : $NEDeployBoxes[$i][1])
			$allBoxes[$i][2] = ($left+17<=511 ? $NWDeployBoxes[$i][0]+10 : $NEDeployBoxes[$i][2])
			$allBoxes[$i][3] = ($left+17<=511 ? $NWDeployBoxes[$i][1]+10 : $NEDeployBoxes[$i][1]+10)
		 Next

		 ; Get closest point on the edge
		 Local $edgeX, $edgeY
		 AutoSnipeGetClosestEdgePoint("Top", $left, $top, $edgeX, $edgeY)
		 DebugWrite("Closest edge point to " & $left+17 & "," & $top+17 & " is " & $edgeX & "," & $edgeY)

		 ; Get closest boxes
		 SortBoxesByDistance($edgeX, $edgeY, $allBoxes)

		 For $i = 0 To UBound($selectedBoxes)-1
			For $j = 0 To 3
			   $selectedBoxes[$i][$j] = $allBoxes[$i][$j]
			Next
			DebugWrite("Closest top box " & $i & ": " & $selectedBoxes[$i][0] & ", " & $selectedBoxes[$i][1] & ", " & $selectedBoxes[$i][2] & ", " & $selectedBoxes[$i][3])
		 Next
	  EndIf

   ElseIf $topOrBot = "Bottom" Then
	  ; If on the bottom corner
	  If $top+17>315 And $left+17>=411 And $left+17<=611 Then
		 For $i = 18 To 20
			$selectedBoxes[$i-18][0] = $SWDeployBoxes[$i][0]
			$selectedBoxes[$i-18][1] = $SWDeployBoxes[$i][3]-10
			$selectedBoxes[$i-18][2] = $SWDeployBoxes[$i][0]+10
			$selectedBoxes[$i-18][3] = $SWDeployBoxes[$i][3]
			DebugWrite("Closest bottom box " & $i-18 & ": " & $selectedBoxes[$i-18][0] & ", " & $selectedBoxes[$i-18][1] & ", " & $selectedBoxes[$i-18][2] & ", " & $selectedBoxes[$i-18][3])
		 Next
		 For $i = 18 To 20
			$selectedBoxes[$i-18+3][0] = $SEDeployBoxes[$i][2]-10
			$selectedBoxes[$i-18+3][1] = $SEDeployBoxes[$i][3]-10
			$selectedBoxes[$i-18+3][2] = $SEDeployBoxes[$i][2]
			$selectedBoxes[$i-18+3][3] = $SEDeployBoxes[$i][3]
			DebugWrite("Closest bottom box " & $i-18+3 & ": " & $selectedBoxes[$i-18+3][0] & ", " & $selectedBoxes[$i-18+3][1] & ", " & $selectedBoxes[$i-18+3][2] & ", " & $selectedBoxes[$i-18+3][3])
		 Next

	  Else
		 Local $allBoxes[21][5] ; 5th column will hold the calculated distance
		 For $i=0 To 20
			$allBoxes[$i][0] = ($left+17<=511 ? $SWDeployBoxes[$i][0]    : $SEDeployBoxes[$i][2]-10)
			$allBoxes[$i][1] = ($left+17<=511 ? $SWDeployBoxes[$i][3]-10 : $SEDeployBoxes[$i][3]-10)
			$allBoxes[$i][2] = ($left+17<=511 ? $SWDeployBoxes[$i][0]+10 : $SEDeployBoxes[$i][2])
			$allBoxes[$i][3] = ($left+17<=511 ? $SWDeployBoxes[$i][3]    : $SEDeployBoxes[$i][3])
		 Next

		 ; Get closest point on the edge
		 Local $edgeX, $edgeY
		 AutoSnipeGetClosestEdgePoint("Bottom", $left, $top, $edgeX, $edgeY)
		 DebugWrite("Closest edge point to " & $left+17 & "," & $top+17 & " is " & $edgeX & "," & $edgeY)

		 ; Get closest boxes
		 SortBoxesByDistance($edgeX, $edgeY, $allBoxes)

		 For $i = 0 To UBound($selectedBoxes)-1
			For $j = 0 To 3
			   $selectedBoxes[$i][$j] = $allBoxes[$i][$j]
			Next
			DebugWrite("Closest bottom box " & $i & ": " & $selectedBoxes[$i][0] & ", " & $selectedBoxes[$i][1] & ", " & $selectedBoxes[$i][2] & ", " & $selectedBoxes[$i][3])
		 Next
	  EndIf

   Else
	  DebugWrite("ERROR in AutoSnipeFindClosestDeployBoxes, $topOrBot = " & $topOrBot)

   EndIf
EndFunc

Func AutoSnipeGetClosestEdgePoint(Const $topOrBot, Const $left, Const $top, ByRef $edgeX, ByRef $edgeY)
   If $topOrBot = "Top" Then
	  If $left+17<=511 Then
		 ; NW
		 $edgeX = Int(267.14 + .5*($left+17) - ($top+17)/1.4)
		 $edgeY = Int(-.7*$edgeX + 374)
	  Else
		 ; NE
		 $edgeX = Int(242.86 + .5*($left+17) + ($top+17)/1.4)
		 $edgeY = Int(.7*$edgeX - 340)
	  EndIf
   Else
	  If $left+17<=511 Then
		 ; SW
		 $edgeX = Int(-54.29 + .5*($left+17) + ($top+17)/1.4)
		 $edgeY = Int(.7*$edgeX + 76)
	  Else
		 ; SE
		 $edgeX = Int(564.29 + .5*($left+17) - ($top+17)/1.4)
		 $edgeY = Int(-.7*$edgeX + 790)
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



