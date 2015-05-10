;
; Strategy 0 - Barcher, top or bottom
; Deploy from either NW/NE or SW/SE sides
; 50% barbs, then 50% archers
; Deploy King
; Remaining barbs and archers
; If Breakers are set as an option, then deploy evenly in safe spots
; Power up King
; Deploy Queen
; Power up Queen
;
Func AutoRaidExecuteRaidStrategy0()
   DebugWrite("AutoRaidExecuteRaidStrategy0()")

   ; What troops are available?
   Local $troopIndex[UBound($gTroopSlotBMPs)][4]
   FindRaidTroopSlots($gTroopSlotBMPs, $troopIndex)

   ; Get counts of available troops
   Local $availableBarbs = GetAvailableTroops($eTroopBarbarian, $troopIndex)
   Local $availableArchs = GetAvailableTroops($eTroopArcher, $troopIndex)
   Local $availableBreakers = GetAvailableTroops($eTroopWallBreaker, $troopIndex)

   DebugWrite("Available Barbarians: " & $availableBarbs & " @" & $gMyTroopCost[$eTroopBarbarian])
   DebugWrite("Avaliable Archers: " & $availableArchs & " @" & $gMyTroopCost[$eTroopArcher])
   If $gDebug And _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED Then _
	  DebugWrite("Avaliable Breakers: " & $availableBreakers & " @" & $gMyTroopCost[$eTroopWallBreaker])

   Local $elixirCost = $availableBarbs*$gMyTroopCost[$eTroopBarbarian] + _
					   $availableArchs*$gMyTroopCost[$eTroopArcher] + _
					   $availableBreakers*$gMyTroopCost[$eTroopWallBreaker]*(_GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED)
   DebugWrite("Elix cost this match: " & $elixirCost)

   ; Count the collectors, by top/bottom half
   DebugWrite("Counting Collectors...")
   Local $matchX[1], $matchY[1]
   LocateCollectors($matchX, $matchY)
   Local $collectorsOnTop = 0, $collectorsOnBot = 0

   For $i = 0 To UBound($matchX)-1
	  ;DebugWrite("Match " & $i & ": " & $matchX[$i] & "," & $matchY[$i])
	  If $matchY[$i] < 250 Then
		 $collectorsOnTop += 1
	  Else
		 $collectorsOnBot += 1
	  EndIf
   Next

   ; Attack from top or bottom?
   Local $direction = $collectorsOnTop/($collectorsOnTop+$collectorsOnBot) > 0.65 ? "Top" : "Bot"
   DebugWrite("Collectors: Top=" & $collectorsOnTop & " Bot=" & $collectorsOnBot & ", thus Direction=" & $direction)

   If $direction = "Top" Then
	  MoveScreenDownToTop(False)
   Else
	  MoveScreenUpToBottom(False)
   EndIf

   ; Get buttons
   Local $barbButton[4] = [$troopIndex[$eTroopBarbarian][0], $troopIndex[$eTroopBarbarian][1], $troopIndex[$eTroopBarbarian][2], _
						   $troopIndex[$eTroopBarbarian][3]]
   Local $archButton[4] = [$troopIndex[$eTroopArcher][0], $troopIndex[$eTroopArcher][1], $troopIndex[$eTroopArcher][2], _
						   $troopIndex[$eTroopArcher][3]]
   Local $breakerButton[4] = [$troopIndex[$eTroopWallBreaker][0], $troopIndex[$eTroopWallBreaker][1], $troopIndex[$eTroopWallBreaker][2], _
						   $troopIndex[$eTroopWallBreaker][3]]
   Local $kingButton[4] = [$troopIndex[$eTroopKing][0], $troopIndex[$eTroopKing][1], $troopIndex[$eTroopKing][2], _
						   $troopIndex[$eTroopKing][3]]
   Local $queenButton[4] = [$troopIndex[$eTroopQueen][0], $troopIndex[$eTroopQueen][1], $troopIndex[$eTroopQueen][2], _
						   $troopIndex[$eTroopQueen][3]]

   ;
   ; Deploy troops
   ;
   Local $deployStart = TimerInit()

   ; Deploy 60% of barbs
   If $barbButton[0] <> -1 Then
	  DebugWrite("Deploying 60% of Barbarians (" & Int($availableBarbs*0.6) & ")")
	  RandomWeightedClick($barbButton)
	  Sleep(500)
	  DeployTroopsToSides($eTroopBarbarian, $troopIndex, $eAutoRaidDeploySixtyPercent, $direction)
   EndIf

   ; Deploy 60% of archers
   If $archButton[0] <> -1 Then
	  DebugWrite("Deploying 60% of Archers (" & Int($availableArchs*0.6) & ")")
	  RandomWeightedClick($archButton)
	  Sleep(500)
	  DeployTroopsToSides($eTroopArcher, $troopIndex, $eAutoRaidDeploySixtyPercent, $direction)
   EndIf

   ; Deploy King
   Local $kingDeployTime = TimerInit()
   Local $kingDeployed = False
   Local $royaltyDeploySide = Random()

   If $kingButton[0] <> -1 Then
	  DebugWrite("Deploying Barbarian King")
	  RandomWeightedClick($kingButton)
	  Sleep(500)

	  RandomWeightedClick( ($direction = "Top") ? _
		 (($royaltyDeploySide>0.5) ? $NWSafeDeployBox : $NESafeDeployBox) : _
		 (($royaltyDeploySide>0.5) ? $SWSafeDeployBox : $SESafeDeployBox))
	  Sleep(500)

	  $kingDeployTime = TimerInit()
	  $kingDeployed = True
   EndIf

   ; Deploy rest of barbs
   If $barbButton[0] <> -1 Then
	  DebugWrite("Deploying remaining Barbarians")
	  RandomWeightedClick($barbButton)
	  Sleep(500)
	  DeployTroopsToSides($eTroopBarbarian, $troopIndex, $eAutoRaidDeployRemaining, $direction)
   EndIf

   ; Deploy rest of archers
   If $archButton[0] <> -1 Then
	  DebugWrite("Deploying remaining Archers")
	  RandomWeightedClick($archButton)
	  Sleep(500)
	  DeployTroopsToSides($eTroopArcher, $troopIndex, $eAutoRaidDeployRemaining, $direction)
   EndIf

   ; Deploy breakers
   If $breakerButton[0] <> -1 And _
	  _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED Then

	  DebugWrite("Deploying Breakers")
	  RandomWeightedClick($breakerButton)
	  Sleep(500)
	  DeployTroopsToSafeBoxes($eTroopWallBreaker, $troopIndex, $direction)
   EndIf

   ; Loop, while monitoring King / Queen health bars, power up king/queen when health falls below green (50%)
   ; Also, deploy queen after specified amount of time after king deploys
   Local $kingPoweredUp = False
   Local $queenPoweredUp = False
   Local $queenDeployDelay = 20000 ; 20 seconds
   Local $queenDeployed = False

   If $queenButton[0]<>-1 Then
	  DebugWrite("Deploying Archer Queen in " & _
		 Int(($queenDeployDelay-TimerDiff($kingDeployTime))/1000) & " seconds")
   EndIf

   While (($kingPoweredUp=False And $troopIndex[$eTroopKing][0]<>-1) Or _
	      ($queenPoweredUp=False And $troopIndex[$eTroopQueen][0]<>-1)) And _
		 TimerDiff($deployStart) < 180000 ; 3 minutes

	  ; Get King's health color, and power up if needed
	  If $kingDeployed And $kingPoweredUp = False Then
		 Local $kingColor[4] = [$troopIndex[$eTroopKing][0]+6, $troopIndex[$eTroopKing][1]-8, _
						    $rRoyaltyHealthGreenColor[2], $rRoyaltyHealthGreenColor[3]]

	  If IsColorPresent($kingColor) = False Then
			;GrabFrameToFile("PreKingPowerUpFrame" & _Date_Time_GetTickCount() & ".bmp")
			DebugWrite("Powering up King")
			RandomWeightedClick($kingButton)
			$kingPoweredUp = True
		 EndIf
	  EndIf

	  ; Get Queen's health color, and power up if needed
	  If $queenDeployed And $queenPoweredUp = False Then
		 Local $queenColor[4] = [$troopIndex[$eTroopQueen][0]+6, $troopIndex[$eTroopQueen][1]-8, _
						    $rRoyaltyHealthGreenColor[2], $rRoyaltyHealthGreenColor[3]]

		 If IsColorPresent($queenColor) = False Then
			;GrabFrameToFile("PreQueenPowerUpFrame" & _Date_Time_GetTickCount() & ".bmp")
			DebugWrite("Powering up Queen")
			RandomWeightedClick($queenButton)
			$queenPoweredUp = True
		 EndIf
	  EndIf

	  ; Deploy Queen after specified amount of time after king deploy
	  If $queenButton[0]<>-1 And TimerDiff($kingDeployTime)>$queenDeployDelay And $queenDeployed=False Then
		 DebugWrite("Deploying Archer Queen")
		 RandomWeightedClick($queenButton)
		 Sleep(500)

		 RandomWeightedClick( ($direction = "Top") ? _
			(($royaltyDeploySide>0.5) ? $NWSafeDeployBox : $NESafeDeployBox) : _
			(($royaltyDeploySide>0.5) ? $SWSafeDeployBox : $SESafeDeployBox) )
		 Sleep(500)

		 $queenDeployed = True
	  EndIf

	  Sleep(1000)
   WEnd

   ; Put screen back to middle
   ;If $direction = "Top" Then
	;  MoveScreenUpToCenter()
   ;Else
	;  MoveScreenDownToCenter()
   ;EndIf

   WaitForBattleEnd($kingDeployed, $queenDeployed)

   Return True
EndFunc

Func FillBarracksAutoRaidStrategy0(Const $initialFillFlag)
   DebugWrite("FillBarracksQueues()")

   ; Loop through barracks and queue troops, until we get to a dark or spells screen, or we've done 4
   Local $barracksCount = 1
   Local $failCount = 5

   While $barracksCount <= 4 And $failCount>0

	  ; Click right arrow to get the next standard troops window
	  RandomWeightedClick($rBarracksWindowNextButton)
	  Sleep(250)
	  $failCount-=1

	  ; Make sure we are on a standard troops window
	  If IsColorPresent($rWindowBarracksStandardColor1) = False And IsColorPresent($rWindowBarracksStandardColor2) = False Then
		 ;DebugWrite(" Not on Standard Troops Window: " & Hex($pixelColor1) & "/" & Hex($WindowTrainTroopsStandardColor1[2])& _
			;"  " & Hex($pixelColor2) & "/" & Hex($WindowTrainTroopsStandardColor2[2]))
		 ExitLoop
	  EndIf

	  ; If we have not yet figured out troop costs, then get them now
	  If $gMyTroopCost[$eTroopBarbarian] = 0 Then
		 GetBarracksTroopCosts($gMyTroopCost)
	  EndIf

	  ; If this is an initial fill and we need to queue breakers, then clear all the queued troops in this barracks
	  If $initialFillFlag=True And _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED Then
		 Local $dequeueTries = 6
		 While IsButtonPresent($rTrainTroopsWindowDequeueButton) And $dequeueTries>0 And _
			   _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_CHECKED

			Local $xClick, $yClick
			RandomWeightedCoords($rTrainTroopsWindowDequeueButton, $xClick, $yClick)
			_ClickHold($xClick, $yClick, 4000)
			$dequeueTries-=1
			Sleep(500)
		 WEnd
	  EndIf

	  If _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED Then Return

	  ; Find the slots for the troops
	  Local $troopSlots[$eTroopCount][4]
	  FindBarracksTroopSlots($gBarracksTroopSlotBMPs, $troopSlots)

	  ; If breakers are included and this is an initial fill then queue up breakercount/4 in each barracks
	  If _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED And $initialFillFlag Then
		 For $i = 1 To Int(Number(GUICtrlRead($GUI_AutoRaidBreakerCountEdit))/4)
			RandomWeightedClick($troopSlots[$eTroopWallBreaker])
			Sleep(500)
		 Next
	  EndIf

	  ; Fill up this barracks
	  Local $fillTries=1
	  Local $troopsToFill
	  Do
		 ; Get number of troops already queued in this barracks
		 Local $queueStatus = ScrapeFuzzyText($gLargeCharacterMaps, $rBarracksWindowTextBox, $gLargeCharMapsMaxWidth, $eScrapeDropSpaces)
		 ;DebugWrite("Barracks " & $barracksCount & " queue status: " & $queueStatus)

		 If (StringInStr($queueStatus, "Train")=1) Then
			$queueStatus = StringMid($queueStatus, 6)

			Local $queueStatSplit = StringSplit($queueStatus, "/")
			If $queueStatSplit[0] = 2 Then
			   $troopsToFill = Number($queueStatSplit[2]) - Number($queueStatSplit[1])

			   ; How long to click and hold?
			   Local $fillTime
			   If $troopsToFill>60 Then
				  $fillTime = 3500 + Random(-250, 250, 1)
			   ElseIf $troopsToFill>25 Then
				  $fillTime = 2700 + Random(-250, 250, 1)
			   ElseIf $troopsToFill>10 Then
				  $fillTime = 2300 + Random(-250, 250, 1)
			   Else
				  $fillTime = 1800 + Random(-250, 250, 1)
			   EndIf

			   ; Click and hold to fill up queue
			   If $troopsToFill>0 Then
				  DebugWrite("Barracks " & $barracksCount & ": Adding " & $troopsToFill & " troops.")

				  Local $xClick, $yClick
				  If $barracksCount/2 = Int($barracksCount/2) Then ; Alternate between archers and barbs
					 Local $button[4] = [$troopSlots[$eTroopBarbarian][0], $troopSlots[$eTroopBarbarian][1], _
										 $troopSlots[$eTroopBarbarian][2], $troopSlots[$eTroopBarbarian][3]]
					 RandomWeightedCoords($button, $xClick, $yClick)
				  Else
					 Local $button[4] = [$troopSlots[$eTroopArcher][0], $troopSlots[$eTroopArcher][1], _
										 $troopSlots[$eTroopArcher][2], $troopSlots[$eTroopArcher][3]]
					 RandomWeightedCoords($button, $xClick, $yClick)
				  EndIf

				  ;DebugWrite("Filling barracks " & $barracksCount & " try " & $fillTries)
				  _ClickHold($xClick, $yClick, $fillTime)
				  Sleep(500)
			   EndIf
			EndIf
		 EndIf

		 $fillTries+=1
	  Until $troopsToFill=0 Or $fillTries>=6 Or _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED

	  $barracksCount+=1
   WEnd
EndFunc
