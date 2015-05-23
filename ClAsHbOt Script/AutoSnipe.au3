Func AutoSnipe(ByRef $timer, ByRef $THLocation, ByRef $THLeft, ByRef $THTop)
   ;DebugWrite("AutoSnipe()")

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
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Find Snipable TH")

	  Local $zappable
	  Local $findMatchResults = AutoSnipeFindMatch($THLocation, $THLeft, $THTop, $zappable)

	  If $zappable And $findMatchResults = $eAutoExecute Then
		 GUICtrlSetData($GUI_AutoStatus, "Auto: Execute DE Zap")
		 AutoDEZap(False)
		 GUICtrlSetData($GUI_AutoStatus, "Auto: DE Zap Complete")
	  EndIf

	  If $findMatchResults = $eAutoExecute Then
		 $gAutoStage = $eAutoExecute
	  Else
		 ResetToCoCMainScreen()
		 $gAutoStage = $eAutoFindMatch
	 EndIf

   ; Stage Execute Snipe
   Case $eAutoExecute
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Execute Snipe")

	  If AutoSnipeExecuteSnipe($THLocation, $THLeft, $THTop) Then
		 $gAutoStage = $eAutoQueueTraining
	  EndIf

	  GUICtrlSetData($GUI_AutoStatus, "Auto: Snipe Complete")

   EndSwitch
EndFunc

Func AutoSnipeFindMatch(ByRef $location, ByRef $left, ByRef $top, ByRef $zappable)
   DebugWrite("AutoSnipeFindMatch()")

   ; Click Attack
   RandomWeightedClick($rMainScreenAttackButton)

   ; Wait for Find a Match button
   Local $failCount = 10
   While IsButtonPresent($rFindMatchScreenFindAMatchButton) = False And $failCount>0
	  Sleep(1000)
	  $failCount -= 1
   WEnd

   If $failCount = 0 Then
	  DebugWrite("Find Snipable TH failed - timeout waiting for Find a Match button")
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
	  DebugWrite("AutoSnipe failed - timeout waiting for Wait Raid screen")
	  ResetToCoCMainScreen()
	  Return False
   EndIf

   ; Loop with Next until we find a snipable TH
   While 1
	  If _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox) = $BST_UNCHECKED Then Return False

	  ; Update my loot status on GUI
	  GetMyLootNumbers()

	  ; Check dead base settings
	  Local $continue = True
	  Local $GUIDeadBasesOnly = (_GUICtrlButton_GetCheck($GUI_AutoRaidDeadBases) = $BST_CHECKED)
	  If $GUIDeadBasesOnly And IsColorPresent($rDeadBaseIndicatorColor)=False Then
		 DebugWrite("Not dead base, skipping.")
		 $continue = False
	  EndIf

	  ; First see if this is a zappable base
	  If $continue Then $zappable = CheckZappableBase()

	  ; Next, see if we have a snipable TH
	  Local $snipable = False
	  If $continue Then $snipable = CheckForSnipableTH($location, $left, $top)

	  ; If zappable and/or snipable, then go do it
	  If $continue And ($zappable=True Or $snipable<>False) Then
		 Return $snipable
	  EndIf

	  ; Something didn't match - click Next
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
		 DebugWrite("AutoSnipe failed - timeout waiting for Wait Raid screen")
		 ResetToCoCMainScreen()
		 Return False
	  EndIf
   WEnd
EndFunc

Func CheckForSnipableTH(ByRef $location, ByRef $left, ByRef $top)

   ; See if we can find the Town Hall on the whole screen: top, middle or bottom
   Local $townHall = GetTownHallLevel($location, $left, $top)

   If $townHall = -1 Then
	  DebugWrite("Could not find Town Hall.  Obscured?")
	  Return False
   EndIf

   ; middle
   If $location = $eTownHallMiddle Then
	  Local $dist = DistBetweenTwoPoints($left+17, $top+17, 511, 273)
	  If $dist <=200 Then
		 DebugWrite("Town Hall found in Middle at " & $left & ", " & $top & ".  Not snipable.")
		 Return False
	  Else
		 DebugWrite("Town Hall found in Middle at " & $left & ", " & $top & ".  Snipable!")
		 Return True
	  EndIf

   ; top
   ElseIf $location = $eTownHallTop Then
	  Local $dist = DistBetweenTwoPoints($left+17, $top+17, 511, 320)
	  If $dist < 150 Then
		 DebugWrite("Town Hall found at Top at " & $left & ", " & $top & ".  Not snipable.")
		 Return False
	  Else
		 DebugWrite("Town Hall found at Top at " & $left & ", " & $top & ".  Snipable!")
		 Return True
	  EndIf

   ; bottom
   ElseIf $location = $eTownHallBottom Then
	  Local $dist = DistBetweenTwoPoints($left+17, $top+17, 511, 140)
	  If $dist < 150 Then
		 DebugWrite("Town Hall found at Bottom at " & $left & ", " & $top & ".  Not snipable.")
		 Return False
	  Else
		 DebugWrite("Town Hall found at Bottom at " & $left & ", " & $top & ".  Snipable!")
		 Return True
	  EndIf

   EndIf

EndFunc

Func AutoSnipeExecuteSnipe(Const $THLocation, Const $THLeft, Const $THTop)
   DebugWrite("AutoSnipeExecuteSnipe()")

   ; Move screen
   Local $deployTopOrBot, $actualTHTop
   $deployTopOrBot = AutoSnipeMoveScreen($THLocation, $THTop, $actualTHTop)
   DebugWrite("Town Hall location: " & $THLeft & ", " & $actualTHTop)

   ; Find best deploy spot, based on deployment boxes
   Local $boxCount = 3
   Local $deployBoxes[$boxCount][4]
   AutoSnipeFindClosestDeployBoxes($deployTopOrBot, $THLeft, $actualTHTop, $deployBoxes)

   ; What troops are available?
   Local $troopIndex[$eTroopCount][4]
   FindRaidTroopSlots($gTroopSlotBMPs, $troopIndex)
   Local $barbButton[4] = [$troopIndex[$eTroopBarbarian][0], $troopIndex[$eTroopBarbarian][1], $troopIndex[$eTroopBarbarian][2], $troopIndex[$eTroopBarbarian][3]]
   Local $archButton[4] = [$troopIndex[$eTroopArcher][0], $troopIndex[$eTroopArcher][1], $troopIndex[$eTroopArcher][2], $troopIndex[$eTroopArcher][3]]
   Local $kingButton[4] = [$troopIndex[$eTroopKing][0], $troopIndex[$eTroopKing][1], $troopIndex[$eTroopKing][2], $troopIndex[$eTroopKing][3]]
   Local $queenButton[4] = [$troopIndex[$eTroopQueen][0], $troopIndex[$eTroopQueen][1], $troopIndex[$eTroopQueen][2], $troopIndex[$eTroopQueen][3]]

   ; send troops in waves, check star color region for success
   Local $kingDeployed = False, $queenDeployed = False
   Local $waveDelay = 12000
   Local $waveTroopsBarb = 30
   Local $waveTroopsArch = 20

   While IsColorPresent($rFirstStarColor) = False
	  Local $waveTimer = TimerInit()

	  ; Get counts of available troops
	  Local $availableBarbs = GetAvailableTroops($eTroopBarbarian, $troopIndex)
	  Local $availableArchs = GetAvailableTroops($eTroopArcher, $troopIndex)
	  DebugWrite("Troops available: Barbarians=" & $availableBarbs & " Archers=" & $availableArchs)

	  If _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox) = $BST_UNCHECKED Then Return False

	  ; If this is TH10, then dump everything - these seem to be trapped more often than not
	  ;If TH10 Then ...
	;	 TODO

	  ; Deploy barbs to boxes
	  If $barbButton[0] <> -1 Then
		 Local $c = $waveTroopsBarb + Random(1, 5, 1)
		 Local $deploy = ($availableBarbs<=$c ? $availableBarbs : $c)
		 DebugWrite("Deploying " & $deploy & " barbarians.")

		 Local $clickPoints[$deploy][2]
		 GetAutoSnipeClickPoints(Random(0,1,1), $deployBoxes, $clickPoints)

		 RandomWeightedClick($barbButton)
		 Sleep(500)

		 For $i = 0 To $deploy-1
			_MouseClickFast($clickPoints[$i][0], $clickPoints[$i][1])
			Sleep($gDeployTroopClickDelay)
		 Next
	  EndIf

	  If IsColorPresent($rFirstStarColor) = True Then ExitLoop

	  If _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox) = $BST_UNCHECKED Then Return False

	  ; Deploy archers to boxes
	  If $archButton[0] <> -1 Then
		 Local $c = $waveTroopsArch + Random(1, 5, 1)
		 Local $deploy = ($availableArchs<=$c ? $availableArchs : $c)
		 DebugWrite("Deploying " & $deploy & " archers.")

		 Local $clickPoints[$deploy][2]
		 GetAutoSnipeClickPoints(Random(0,1,1), $deployBoxes, $clickPoints)

		 RandomWeightedClick($archButton)
		 Sleep(500)

		 For $i = 0 To $deploy-1
			_MouseClickFast($clickPoints[$i][0], $clickPoints[$i][1])
			Sleep($gDeployTroopClickDelay)
		 Next
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

Func AutoSnipeMoveScreen(Const $THLocation, Const $THTop, ByRef $actualTop)
   Local $topBot

   ; move to top of screen
   If $THLocation = $eTownHallTop Then
	  If $THTop >= 368 Then
		 DebugWrite("TownHall found at top, moving screen up")
		 MoveScreenUpToBottom(False)
		 $topBot = "Bot"
	  Else
		 DebugWrite("TownHall found at top, moving screen down")
		 MoveScreenDownToTop(False)
		 $topBot = "Top"
	  EndIf

   ; move to bottom of screen
   ElseIf $THLocation = $eTownHallBottom Then
	  If $THTop >= 130 Then
		 DebugWrite("TownHall found at bottom, moving screen up")
		 MoveScreenUpToBottom(False)
		 $topBot = "Bot"
	  Else
		 DebugWrite("TownHall found at bottom, moving screen down")
		 MoveScreenDownToTop(False)
		 $topBot = "Top"
	  EndIf

   ; if found in center, still shift up or down based on location
   ElseIf $THLocation = $eTownHallMiddle Then
	  If $THTop+17 < 275 Then
		 DebugWrite("TownHall found in middle, moving screen down")
		 MoveScreenDownToTop(False)
		 $topBot = "Top"
	  Else
		 DebugWrite("TownHall found in middle, moving screen up")
		 MoveScreenUpToBottom(False)
		 $topBot = "Bot"
	  EndIf

   Else
	  DebugWrite("TownHall location: " & $THLocation & " ERROR, exiting.")
	  Exit

   EndIf

   ; Get the new TH location, now that screen has been moved
   Local $loc, $L, $T
   Local $th = GetTownHallLevel($loc, $L, $actualTop)

   Return $topBot
EndFunc

Func AutoSnipeFindClosestDeployBoxes(Const $topOrBot, Const $left, Const $top, ByRef $selectedBoxes)
   If $topOrBot = "Top" Then
	  Local $allBoxes[42][5] ; 5th column will hold the calculated distance
	  For $i=0 To 20
		 $allBoxes[$i][0] = $NWDeployBoxes[$i][0]
		 $allBoxes[$i][1] = $NWDeployBoxes[$i][1]
		 $allBoxes[$i][2] = $NWDeployBoxes[$i][0]+10
		 $allBoxes[$i][3] = $NWDeployBoxes[$i][1]+10
	  Next
	  For $i=0 To 20
		 $allBoxes[21+$i][0] = $NEDeployBoxes[$i][2]-10
		 $allBoxes[21+$i][1] = $NEDeployBoxes[$i][1]
		 $allBoxes[21+$i][2] = $NEDeployBoxes[$i][2]
		 $allBoxes[21+$i][3] = $NEDeployBoxes[$i][1]+10
	  Next

	  SortBoxesByDistance($left+17, $top+17, $allBoxes)

	  For $i = 0 To UBound($selectedBoxes)-1
		 For $j = 0 To 3
			$selectedBoxes[$i][$j] = $allBoxes[$i][$j]
		 Next
		 DebugWrite("Closest top box " & $i & ": " & $selectedBoxes[$i][0] & ", " & $selectedBoxes[$i][1] & ", " & $selectedBoxes[$i][2] & ", " & $selectedBoxes[$i][3])
	  Next

   Else
	  Local $allBoxes[42][5] ; 5th column will hold the calculated distance
	  For $i=0 To 20
		 $allBoxes[$i][0] = $SWDeployBoxes[$i][0]
		 $allBoxes[$i][1] = $SWDeployBoxes[$i][3]-10
		 $allBoxes[$i][2] = $SWDeployBoxes[$i][0]+10
		 $allBoxes[$i][3] = $SWDeployBoxes[$i][3]
	  Next
	  For $i=0 To 20
		 $allBoxes[21+$i][0] = $SEDeployBoxes[$i][2]-10
		 $allBoxes[21+$i][1] = $SEDeployBoxes[$i][3]-10
		 $allBoxes[21+$i][2] = $SEDeployBoxes[$i][2]
		 $allBoxes[21+$i][3] = $SEDeployBoxes[$i][3]
	  Next

	  SortBoxesByDistance($left+17, $top+17, $allBoxes)

	  For $i = 0 To UBound($selectedBoxes)-1
		 For $j = 0 To 3
			$selectedBoxes[$i][$j] = $allBoxes[$i][$j]
		 Next
		 DebugWrite("Closest bottom box " & $i & ": " & $selectedBoxes[$i][0] & ", " & $selectedBoxes[$i][1] & ", " & $selectedBoxes[$i][2] & ", " & $selectedBoxes[$i][3])
	  Next

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



