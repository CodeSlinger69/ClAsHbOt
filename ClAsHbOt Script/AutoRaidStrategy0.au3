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
   Local $troopIndex[$eTroopCount][4]
   FindRaidTroopSlots($gTroopSlotBMPs, $troopIndex)

   ; Get counts of available troops
   Local $availableBarbs = GetAvailableTroops($eTroopBarbarian, $troopIndex)
   Local $availableArchs = GetAvailableTroops($eTroopArcher, $troopIndex)
   Local $availableBreakers = GetAvailableTroops($eTroopWallBreaker, $troopIndex)

   DebugWrite("Available Barbarians: " & $availableBarbs)
   DebugWrite("Avaliable Archers: " & $availableArchs)
   If $gDebug And _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED Then _
	  DebugWrite("Avaliable Breakers: " & $availableBreakers)

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
