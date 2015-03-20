;
; Dak Elixir Storage Zap Strategy
;
Func AutoRaidExecuteDEZap()
   DebugWrite("AutoRaidExecuteDEZap()")

   Local $res = ZapDarkElixirStorage()

   If $res = True Then ; Zap executed
	  Local $troopSlotIndex[$countOfSlots]
	  FindTroopSlots($troopSlotIndex)
	  WaitForBattleEnd(False, False)
   Else ; Not enuf lightning spells, or couldn't find DE storage
	  ; Click End Battle button
	  Local $xClick, $yClick
	  Local $cPos = GetClientPos()
	  RandomWeightedCoords($LiveRaidScreenEndBattleButton, $xClick, $yClick)
	  MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)
	  Sleep(500)
   EndIf

   Return $res
EndFunc

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

   Local $i

   ; What troops are available?
   Local $troopSlotIndex[$countOfSlots]
   FindTroopSlots($troopSlotIndex)

   ; Get buttons and text boxes for troops
   Local $barbButton[8], $archButton[8], $breakerButton[8], $kingButton[8], $queenButton[8]
   GetTroopSlotButton($troopSlotIndex[$barbarianSlot], $barbButton)
   GetTroopSlotButton($troopSlotIndex[$archerSlot], $archButton)
   GetTroopSlotButton($troopSlotIndex[$wallBreakerSlot], $breakerButton)
   GetTroopSlotButton($troopSlotIndex[$barbarianKingSlot], $kingButton)
   GetTroopSlotButton($troopSlotIndex[$archerQueenSlot], $queenButton)

   Local $barbTextBox[10], $archTextBox[10], $breakerTextBox[10]
   GetTroopSlotTextBox($troopSlotIndex[$barbarianSlot], $barbTextBox)
   GetTroopSlotTextBox($troopSlotIndex[$archerSlot], $archTextBox)
   GetTroopSlotTextBox($troopSlotIndex[$wallBreakerSlot], $breakerTextBox)

   ; Get counts of available troops
   Local $availableBarbs = $troopSlotIndex[$barbarianSlot]<>-1 ? StringMid(ScrapeText($smallCharacterMaps, $barbTextBox, 172, 456, 851, 531), 2) : 0
   Local $availableArchs = $troopSlotIndex[$archerSlot]<>-1 ? StringMid(ScrapeText($smallCharacterMaps, $archTextBox, 172, 456, 851, 531), 2) : 0
   Local $availableBreakers = $troopSlotIndex[$wallBreakerSlot]<>-1 ? StringMid(ScrapeText($smallCharacterMaps, $breakerTextBox, 172, 456, 851, 531), 2) : 0

   DebugWrite("Available Barbarians: " & $availableBarbs & " @" & $myTroopCost[$barbarianSlot])
   DebugWrite("Avaliable Archers: " & $availableArchs & " @" & $myTroopCost[$archerSlot])
   If $Debug And _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED Then _
	  DebugWrite("Avaliable Breakers: " & $availableBreakers & " @" & $myTroopCost[$wallBreakerSlot])

   Local $elixirCost = $availableBarbs*$myTroopCost[$barbarianSlot] + _
					   $availableArchs*$myTroopCost[$archerSlot] + _
					   $availableBreakers*$myTroopCost[$wallBreakerSlot]*(_GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED)
   ConsoleWrite(_NowTime() & " Elix cost this match: " & $elixirCost & @CRLF)

   ; Count the collectors, by top/bottom half
   DebugWrite("Counting Collectors...")
   Local $matchX[1], $matchY[1]
   LocateCollectors($matchX, $matchY)
   Local $collectorsOnTop = 0, $collectorsOnBot = 0

   For $i = 0 To UBound($matchX)-1
	  ;ConsoleWrite("Match " & $i & ": " & $matchX[$i] & "," & $matchY[$i] & @CRLF)
	  If $matchY[$i] < 250 Then
		 $collectorsOnTop += 1
	  Else
		 $collectorsOnBot += 1
	  EndIf
   Next

   ; Attack from top or bottom?
   Local $direction = $collectorsOnTop/($collectorsOnTop+$collectorsOnBot) > 0.65 ? "Top" : "Bot"  ;(Random()>0.5) ? "Top" : "Bot"
   DebugWrite("Collectors: Top=" & $collectorsOnTop & " Bot=" & $collectorsOnBot & ", thus Direction=" & $direction)

   If $direction = "Top" Then
	  MoveScreenDownToTop(False)
   Else
	  MoveScreenUpToBottom(False)
   EndIf

   ;
   ; Deploy troops
   ;
   Local $cPos = GetClientPos()
   Local $xClick, $yClick
   Local $deployStart = TimerInit()

   ; Deploy 60% of barbs
   If $troopSlotIndex[$barbarianSlot] <> -1 Then
	  DebugWrite("Deploying 60% of Barbarians (" & Int($availableBarbs/2) & ")")
	  RandomWeightedCoords($barbButton, $xClick, $yClick)
	  MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)
	  Sleep(500)
	  DeployTroopsToSides($barbTextBox, $deploySixtyPercent, $direction)
   EndIf

   ; Deploy 60% of archers
   If $troopSlotIndex[$archerSlot] <> -1 Then
	  DebugWrite("Deploying 60% of Archers (" & Int($availableArchs/2) & ")")
	  RandomWeightedCoords($archButton, $xClick, $yClick)
	  MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)
	  Sleep(500)
	  DeployTroopsToSides($archTextBox, $deploySixtyPercent, $direction)
   EndIf

   ; Deploy King
   Local $kingDeployTime = TimerInit()
   Local $kingDeployed = False
   Local $royaltyDeploySide = Random()

   If $troopSlotIndex[$barbarianKingSlot] <> -1 Then
	  DebugWrite("Deploying Barbarian King")
	  RandomWeightedCoords($kingButton, $xClick, $yClick)
	  MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)
	  Sleep(500)

	  RandomWeightedCoords( ($direction = "Top") ? _
		 (($royaltyDeploySide>0.5) ? $NWSafeDeployBox : $NESafeDeployBox) : _
		 (($royaltyDeploySide>0.5) ? $SWSafeDeployBox : $SESafeDeployBox), $xClick, $yClick)
	  MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)
	  Sleep(500)

	  $kingDeployTime = TimerInit()
	  $kingDeployed = True
   EndIf

   ; Deploy rest of barbs
   If $troopSlotIndex[$barbarianSlot] <> -1 Then
	  DebugWrite("Deploying remaining Barbarians")
	  RandomWeightedCoords($barbButton, $xClick, $yClick)
	  MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)
	  Sleep(500)
	  DeployTroopsToSides($barbTextBox, $deployRemaining, $direction)
   EndIf

   ; Deploy rest of archers
   If $troopSlotIndex[$archerSlot] <> -1 Then
	  DebugWrite("Deploying remaining Archers")
	  RandomWeightedCoords($archButton, $xClick, $yClick)
	  MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)
	  Sleep(500)
	  DeployTroopsToSides($archTextBox, $deployRemaining, $direction)
   EndIf

   ; Deploy breakers
   If $troopSlotIndex[$wallBreakerSlot] <> -1 And _
	  _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED Then

	  DebugWrite("Deploying Breakers")
	  RandomWeightedCoords($breakerButton, $xClick, $yClick)
	  MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)
	  Sleep(500)
	  DeployTroopsToSafeBoxes($breakerTextBox, $direction)
   EndIf

   ; Loop, while monitoring King / Queen health bars, power up king/queen when health falls below green (50%)
   ; Also, deploy queen after specified amount of time after king deploys
   Local $kingPoweredUp = False
   Local $queenPoweredUp = False
   Local $queenDeployDelay = 20000 ; 20 seconds
   Local $queenDeployed = False

   While (($kingPoweredUp=False And $troopSlotIndex[$barbarianKingSlot]<>-1) Or _
	      ($queenPoweredUp=False And $troopSlotIndex[$archerQueenSlot]<>-1)) And _
		 $ExitApp = False And _
		 TimerDiff($deployStart) < 180000 ; 3 minutes

	  ; Get King's health color, and power up if needed
	  If $kingDeployed And $kingPoweredUp = False Then
		 Local $kingColor = PixelGetColor($cPos[0]+$kingButton[0]+10, $cPos[1]+$kingButton[1]-7); health bar starts 6 pix in from left edge of button
		 Local $kingPixMatch = InColorSphere($kingColor, $RoyaltyHealthGreenColor[2], $RoyaltyHealthGreenColor[3])
		 ;DebugWrite("King health " & $kingButton[0]+10 & "," & $kingButton[1]-7 & ": " & Hex($kingColor) & " " & $kingPixMatch)
		 If $kingPixMatch = False Then
			DebugWrite("Powering up King")
			;MsgBox($MB_OK, "", "")
			RandomWeightedCoords($kingButton, $xClick, $yClick)
			MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)
			$kingPoweredUp = True
		 EndIf
	  EndIf

	  ; Get Queen's health color, and power up if needed
	  If $queenDeployed And $queenPoweredUp = False Then
		 Local $queenColor = PixelGetColor($cPos[0]+$queenButton[0]+10, $cPos[1]+$queenButton[1]-7); health bar starts 6 pix in from left edge of button
		 Local $queenPixMatch = InColorSphere($queenColor, $RoyaltyHealthGreenColor[2], $RoyaltyHealthGreenColor[3])
		 ;DebugWrite("Queen health " & $queenButton[0]+10 & "," & $queenButton[1]-7 & ": " & Hex($queenColor) & " " & $queenPixMatch)
		 If $queenPixMatch = False Then
			DebugWrite("Powering up Queen")
			RandomWeightedCoords($queenButton, $xClick, $yClick)
			MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)
			$queenPoweredUp = True
		 EndIf
	  EndIf

	  ; Deploy Queen after specified amount of time after king deploy
	  If $troopSlotIndex[$archerQueenSlot]<>-1 And TimerDiff($kingDeployTime)>$queenDeployDelay And $queenDeployed=False Then
		 DebugWrite("Deploying Archer Queen")
		 RandomWeightedCoords($queenButton, $xClick, $yClick)
		 MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)
		 Sleep(500)

		 RandomWeightedCoords( ($direction = "Top") ? _
			(($royaltyDeploySide>0.5) ? $NWSafeDeployBox : $NESafeDeployBox) : _
			(($royaltyDeploySide>0.5) ? $SWSafeDeployBox : $SESafeDeployBox), $xClick, $yClick)
		 MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)
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
