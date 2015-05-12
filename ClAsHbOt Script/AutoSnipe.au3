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

	  If $zappable Then
		 GUICtrlSetData($GUI_AutoStatus, "Auto: Execute DE Zap")
		 AutoDEZap()
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
   Local $failCount

   ; Get starting gold, to calculate cost of Next'ing
   Local $startGold = GUICtrlRead($GUI_MyGold)

   ; Click Attack
   RandomWeightedClick($rMainScreenAttackButton)

   ; Wait for Find a Match button
   $failCount = 10
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
   Local $nextCount = 1

   While 1
	  If _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox) = $BST_UNCHECKED Then Return False

	  Local $continue = True

	  ; Update my loot status on GUI
	  GetMyLootNumbers()

	  ; Get my settings
	  Local $GUIZapDE = (_GUICtrlButton_GetCheck($GUI_AutoRaidZapDE) = $BST_CHECKED)
	  Local $GUIZapDEMin = GUICtrlRead($GUI_AutoRaidZapDEMin)
	  Local $GUIDeadBasesOnly = (_GUICtrlButton_GetCheck($GUI_AutoRaidDeadBases) = $BST_CHECKED)

	  ; Check dead base settings
	  If $continue Then
		 If $GUIDeadBasesOnly And IsColorPresent($rDeadBaseIndicatorColor) Then $continue = False
	  EndIf

	  ; First see if this is a zappable base
	  If $continue Then
		 $zappable = CheckZappableBase()
	  EndIf

	  ; Next, see if we do not have a TH in the central box area
	  Local $townHall
	  If $continue Then
		 $townHall = GetTownHallLevel($location, $left, $top, $rCentralTownHall[0], $rCentralTownHall[1], $rCentralTownHall[2], $rCentralTownHall[3])
		 DebugWrite("Snipable TH check 1 of 3: " & ($townHall=-1 ? True : False))
		 If $townHall <> -1 Then $continue = False
	  EndIf

	  ; Check again, in case something was obscuring it the first time
	  If $continue Then
		 Sleep(2000)
		 $townHall = GetTownHallLevel($location, $left, $top, $rCentralTownHall[0], $rCentralTownHall[1], $rCentralTownHall[2], $rCentralTownHall[3])
		 DebugWrite("Snipable TH check 2 of 3: " & ($townHall=-1 ? True : False))
		 If $townHall <> -1 Then $continue = False
	  EndIf

	  ; And one more time, just to be sure
	  If $continue Then
		 Sleep(2000)
		 $townHall = GetTownHallLevel($location, $left, $top, $rCentralTownHall[0], $rCentralTownHall[1], $rCentralTownHall[2], $rCentralTownHall[3])
		 DebugWrite("Snipable TH check 3 of 3: " & ($townHall=-1 ? True : False))
		 If $townHall <> -1 Then $continue = False
	  EndIf


	  ; Now find the actual location of the Town Hall: top, middle or bottom
	  If $continue = True Then
		 $townHall = GetTownHallLevel($location, $left, $top)
		 If $location = $eTownHallCenter Then DebugWrite("Snipable TH found in: Center")
		 If $location = $eTownHallTop Then DebugWrite("Snipable TH found at: Top")
		 If $location = $eTownHallBottom Then DebugWrite("Snipable TH found at: Bottom")
		 If $townHall <> -1 Then ExitLoop
	  EndIf

	  ; Something didn't match - click Next
	  DebugWrite("No match:  Town Hall Level " & $townHall & " found in Center")
	  Sleep($gPauseBetweenNexts)
	  RandomWeightedClick($rWaitRaidScreenNextButton)
	  $nextCount+=1

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

   ; Get ending gold, to calculate cost of Next'ing
   GetMyLootNumbers()
   Local $endGold = GUICtrlRead($GUI_MyGold)

   DebugWrite("Gold cost this search: " & $startGold - $endGold & " (" & $nextCount & " nexts).")

   Return $eAutoExecute
EndFunc

Func AutoSnipeExecuteSnipe(Const $THLocation, Const $THLeft, Const $THTop)
   Local $deployBoxes
   Local Enum $deployTop, $deployBottom

   ; move to top of screen
   If $THLocation = $eTownHallTop Then
	  DebugWrite("TownHall found at top, moving screen down")
	  MoveScreenDownToTop(False)
	  $deployBoxes = $deployTop

   ; move to bottom of screen
   ElseIf $THLocation = $eTownHallBottom Then
	  DebugWrite("TownHall found at bottom, moving screen up")
	  MoveScreenUpToBottom(False)
	  $deployBoxes = $deployBottom

   ; if found in center, still shift up or down based on location
   ElseIf $THLocation = $eTownHallCenter Then
	  If $THTop+17 < 275 Then
		 DebugWrite("TownHall found in center, moving screen down")
		 MoveScreenDownToTop(False)
		 $deployBoxes = $deployTop
	  Else
		 DebugWrite("TownHall found in center, moving screen up")
		 MoveScreenUpToBottom(False)
		 $deployBoxes = $deployBottom
	  EndIf

   Else
	  DebugWrite("TownHall location: " & $THLocation & " ERROR, exiting.")
	  Exit

   EndIf

   ; Find closest deploy box
   Local $bestBox[4]
   If $deployBoxes = $deployTop Then
	  Local $bestDistWest, $bestDistEast
	  Local $bestWestBox = FindClosestDeployBox($THLeft+17, $THTop+17, $NWDeployBoxes, $bestDistWest)
	  Local $bestEastBox = FindClosestDeployBox($THLeft+17, $THTop+17, $NEDeployBoxes, $bestDistEast)

	  If $bestDistWest < $bestDistEast Then
		 $bestBox[0] = $bestWestBox[0]
		 $bestBox[1] = $bestWestBox[1]
		 $bestBox[2] = $bestWestBox[2]
		 $bestBox[3] = $bestWestBox[3]
	  Else
		 $bestBox[0] = $bestEastBox[0]
		 $bestBox[1] = $bestEastBox[1]
		 $bestBox[2] = $bestEastBox[2]
		 $bestBox[3] = $bestEastBox[3]
	  EndIf
   Else
	  Local $bestDistWest, $bestDistEast
	  Local $bestWestBox = FindClosestDeployBox($THLeft+17, $THTop+17, $SWDeployBoxes, $bestDistWest)
	  Local $bestEastBox = FindClosestDeployBox($THLeft+17, $THTop+17, $SEDeployBoxes, $bestDistEast)

	  If $bestDistWest < $bestDistEast Then
		 $bestBox[0] = $bestWestBox[0]
		 $bestBox[1] = $bestWestBox[1]
		 $bestBox[2] = $bestWestBox[2]
		 $bestBox[3] = $bestWestBox[3]
	  Else
		 $bestBox[0] = $bestEastBox[0]
		 $bestBox[1] = $bestEastBox[1]
		 $bestBox[2] = $bestEastBox[2]
		 $bestBox[3] = $bestEastBox[3]
	  EndIf
   EndIf

   ; What troops are available?
   Local $troopIndex[$eTroopCount][4]
   FindRaidTroopSlots($gTroopSlotBMPs, $troopIndex)
   Local $barbButton[4] = [$troopIndex[$eTroopBarbarian][0], $troopIndex[$eTroopBarbarian][1], $troopIndex[$eTroopBarbarian][2], $troopIndex[$eTroopBarbarian][3]]
   Local $archButton[4] = [$troopIndex[$eTroopArcher][0], $troopIndex[$eTroopArcher][1], $troopIndex[$eTroopArcher][2], $troopIndex[$eTroopArcher][3]]
   Local $kingButton[4] = [$troopIndex[$eTroopKing][0], $troopIndex[$eTroopKing][1], $troopIndex[$eTroopKing][2], $troopIndex[$eTroopKing][3]]
   Local $queenButton[4] = [$troopIndex[$eTroopQueen][0], $troopIndex[$eTroopQueen][1], $troopIndex[$eTroopQueen][2], $troopIndex[$eTroopQueen][3]]

   ; send troops in waves every 15 secs, check star color region
   While IsColorPresent($rFirstStarColor) = False
	  Local $waveTimer = TimerInit()

	  ; Get counts of available troops
	  Local $availableBarbs = GetAvailableTroops($eTroopBarbarian, $troopIndex)
	  Local $availableArchs = GetAvailableTroops($eTroopArcher, $troopIndex)

	  If _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox) = $BST_UNCHECKED Then Return False

	  ; Deploy 15 barbs to box
	  If $barbButton[0] <> -1 Then
		 RandomWeightedClick($barbButton)
		 Sleep(500)
		 For $i = 1 To ($availableBarbs<15 ? $availableBarbs : 15)
			Local $xClick, $yClick
			RandomWeightedCoords($bestBox, $xClick, $yClick)
			_MouseClickFast($xClick, $yClick)
			Sleep($gDeployTroopClickDelay)
		 Next
	  EndIf

	  If _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox) = $BST_UNCHECKED Then Return False

	  ; Deploy 15 archers to box
	  If $archButton[0] <> -1 Then
		 RandomWeightedClick($archButton)
		 Sleep(500)
		 For $i = 1 To ($availableArchs<15 ? $availableArchs : 15)
			Local $xClick, $yClick
			RandomWeightedCoords($bestBox, $xClick, $yClick)
			_MouseClickFast($xClick, $yClick)
			Sleep($gDeployTroopClickDelay)
		 Next
	  EndIf

	  If _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox) = $BST_UNCHECKED Then Return False

	  ; Deploy King if we ran out of Barbs and power up after 2 seconds
	  If $kingButton[0] <> -1 Then
		 RandomWeightedClick($kingButton)
		 Sleep(500)

		 Local $xClick, $yClick
		 RandomWeightedCoords($bestBox, $xClick, $yClick)
		 _MouseClickFast($xClick, $yClick)
		 Sleep(2000)

		 RandomWeightedClick($kingButton)
		 Sleep(500)
	  EndIf

	  If _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox) = $BST_UNCHECKED Then Return False

	  ; Deploy Queen if we ran out of Archs and power up after 2 seconds
	  If $queenButton[0] <> -1 Then
		 RandomWeightedClick($queenButton)
		 Sleep(500)

		 Local $xClick, $yClick
		 RandomWeightedCoords($bestBox, $xClick, $yClick)
		 _MouseClickFast($xClick, $yClick)
		 Sleep(2000)

		 RandomWeightedClick($queenButton)
		 Sleep(500)
	  EndIf

	  If $availableBarbs=0 And $availableArchs=0 Then ExitLoop

	  ; Wait for 15 second timer
	  While TimerDiff($waveTimer) < 15000
		 If _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox) = $BST_UNCHECKED Then Return False
		 Sleep(200)
	  WEnd

   WEnd

   ; Wait for end battle
   WaitForBattleEnd(True, True)  ; always wait full 3 minutes, or until all troops are dead

EndFunc

Func FindClosestDeployBox(Const $x, Const $y, Const ByRef $boxes, ByRef $bestDist)
   $bestDist = 9999
   Local $bestBox = -1
   For $i = 0 To 20
	  Local $boxCenterX = $boxes[$i][0] + Int(($boxes[$i][2] - $boxes[$i][0]) / 2)
	  Local $boxCenterY = $boxes[$i][1] + Int(($boxes[$i][3] - $boxes[$i][1]) / 2)
	  Local $dist = DistBetweenTwoPoints($x, $y, $boxCenterX, $boxCenterY)

	  If $dist<=$bestDist Then
		 $bestDist = $dist
		 $bestBox = $i
	  EndIf
   Next

   Return $bestBox
EndFunc



