;
; Strategy 2 - Barcher & Minion, top or bottom
; Deploy from either NW/NE or SW/SE sides
; 60% barbs, then 60% archers
; Deploy breakers
; Remaining barbs and archers
; Minions
; Deploy and power up Heroes
;

Func FillBarracksStrategy2(Const $initialFillFlag, Const ByRef $availableTroopCounts, ByRef $redStripe)
   DebugWrite("FillBarracksStrategy2(), " & ($initialFillFlag ? "initial fill." : "top up.") )

   ; How many breakers are needed?
   Local $breakersToQueue = Number(GUICtrlRead($GUI_AutoRaidBreakerCountEdit)) - $availableTroopCounts[$eTroopWallBreaker]
   If _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED Then
	  DebugWrite("Wall Breakers needed: " & ($breakersToQueue>0 ? $breakersToQueue : 0))
   Else
	  $breakersToQueue = 0
   EndIf

   ; Loop through barracks and queue troops, until we get to a dark or spells screen, or we've done 4
   ; This function assumes that we are already on a spells window, or the last dark troops window (i.e. the starting point)
   Local $barracksCountStandard=0, $barracksCountDark=0
   Local $failCount = 8

   While $barracksCountStandard <= 6 And $barracksCountDark<=2 And $failCount>0

	  ; Click right arrow to get the next troops window
	  RandomWeightedClick($rBarracksWindowNextButton)
	  Sleep(400)
	  $failCount-=1

	  ; Increment standard or dark counter
	  Local $isStandardTroopsWindow
	  If OnTrainTroopsStandardWindow() Then
		 $barracksCountStandard+=1
		 $isStandardTroopsWindow = True
	  ElseIf OnTrainTroopsDarkWindow() Then
		 $barracksCountDark+=1
		 $isStandardTroopsWindow = False
	  Else
		 DebugWrite("Not on Standard Or Dark Troops window, exiting.")
		 ExitLoop
	  EndIf

	  If _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED And _
		 _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox)=$BST_UNCHECKED Then Return

	  ; See if we are full up
	  If IsColorPresent($rWindowBarracksFullColor) Then $redStripe = True

	  ; Find the slots for the troops
	  Local $troopSlots[$eTroopCount][4]
	  FindBarracksTroopSlots($gBarracksTroopSlotBMPs, $troopSlots)

	  ; Specified breakers in each barracks on initial fill
	  If $initialFillFlag And $breakersToQueue>0 Then
		 ; Dequeue troops
		 DequeueTroops()
		 FindBarracksTroopSlots($gBarracksTroopSlotBMPs, $troopSlots)

		 ; If breakers are included then queue up breakers in each barracks
		 If $breakersToQueue>0 Then QueueTroopsEvenly($eTroopWallBreaker, $troopSlots, $breakersToQueue)
	  EndIf

	  ; Fill up this barracks
	  Local $fillTries=1
	  Local $troopsToFill
	  Do
		 If $isStandardTroopsWindow Then
			If $barracksCountStandard=1 Or $barracksCountStandard=3 Then
			   $troopsToFill = FillBarracksWithTroops($eTroopArcher, $troopSlots)
			Else
			   $troopsToFill = FillBarracksWithTroops($eTroopBarbarian, $troopSlots)
			EndIf
		 Else
			$troopsToFill = FillBarracksWithTroops($eTroopMinion, $troopSlots)
		 EndIf

		 $fillTries+=1
	  Until $troopsToFill=0 Or $fillTries>=6 Or _
		 (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox)=$BST_UNCHECKED)

   WEnd
EndFunc

Func AutoRaidExecuteRaidStrategy2()
   DebugWrite("AutoRaidExecuteRaidStrategy2()")

   ; What troops are available?
   Local $troopIndex[$eTroopCount][4]
   FindRaidTroopSlots($gTroopSlotBMPs, $troopIndex)

   ; Get counts of available troops
   Local $availableBarbs = GetAvailableTroops($eTroopBarbarian, $troopIndex)
   Local $availableArchs = GetAvailableTroops($eTroopArcher, $troopIndex)
   Local $availableMinions = GetAvailableTroops($eTroopMinion, $troopIndex)
   Local $availableBreakers = GetAvailableTroops($eTroopWallBreaker, $troopIndex)

   DebugWrite("Available Barbarians: " & $availableBarbs)
   DebugWrite("Avaliable Archers: " & $availableArchs)
   DebugWrite("Avaliable Minions: " & $availableMinions)
   If $gDebug And _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED Then _
	  DebugWrite("Avaliable Breakers: " & $availableBreakers)

   ; Determine attack direction
   Local $direction = AutoRaidStrategy0GetDirection()
   If $direction = "Top" Then
	  DebugWrite("Attacking from top.")
	  MoveScreenDownToTop(False)
   Else
	  DebugWrite("Attacking from bottom.")
	  MoveScreenUpToBottom(False)
   EndIf

    ; Get buttons
   Local $barbButton[4] = [$troopIndex[$eTroopBarbarian][0], $troopIndex[$eTroopBarbarian][1], $troopIndex[$eTroopBarbarian][2], $troopIndex[$eTroopBarbarian][3]]
   Local $archButton[4] = [$troopIndex[$eTroopArcher][0], $troopIndex[$eTroopArcher][1], $troopIndex[$eTroopArcher][2], $troopIndex[$eTroopArcher][3]]
   Local $minionButton[4] = [$troopIndex[$eTroopMinion][0], $troopIndex[$eTroopMinion][1], $troopIndex[$eTroopMinion][2], $troopIndex[$eTroopMinion][3]]
   Local $breakerButton[4] = [$troopIndex[$eTroopWallBreaker][0], $troopIndex[$eTroopWallBreaker][1], $troopIndex[$eTroopWallBreaker][2], $troopIndex[$eTroopWallBreaker][3]]
   Local $kingButton[4] = [$troopIndex[$eTroopKing][0], $troopIndex[$eTroopKing][1], $troopIndex[$eTroopKing][2], $troopIndex[$eTroopKing][3]]
   Local $queenButton[4] = [$troopIndex[$eTroopQueen][0], $troopIndex[$eTroopQueen][1], $troopIndex[$eTroopQueen][2], $troopIndex[$eTroopQueen][3]]

   ;
   ; Deploy troops
   ;
   Local $deployStart = TimerInit()

   ; Deploy 60% of barbs
   If $barbButton[0] <> -1 Then
	  DebugWrite("Deploying 60% of Barbarians (" & Int($availableBarbs*0.6) & ")")
	  RandomWeightedClick($barbButton)
	  Sleep(500)
	  DeployTroopsToSides($eTroopBarbarian, $troopIndex, $eAutoRaidDeploySixtyPercent, $direction, 20)
   EndIf

   ; Deploy 60% of archers
   If $archButton[0] <> -1 Then
	  DebugWrite("Deploying 60% of Archers (" & Int($availableArchs*0.6) & ")")
	  RandomWeightedClick($archButton)
	  Sleep(500)
	  DeployTroopsToSides($eTroopArcher, $troopIndex, $eAutoRaidDeploySixtyPercent, $direction, 20)
   EndIf

   ; Deploy breakers
   If $breakerButton[0] <> -1 And _
	  _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED Then

	  DebugWrite("Deploying Breakers")
	  RandomWeightedClick($breakerButton)
	  Sleep(500)
	  DeployTroopsToSafeBoxes($eTroopWallBreaker, $troopIndex, $direction)
   EndIf

   ; Deploy rest of barbs
   If $barbButton[0] <> -1 Then
	  DebugWrite("Deploying remaining Barbarians")
	  RandomWeightedClick($barbButton)
	  Sleep(500)
	  DeployTroopsToSides($eTroopBarbarian, $troopIndex, $eAutoRaidDeployRemaining, $direction, 20)
   EndIf

   ; Deploy rest of archers
   If $archButton[0] <> -1 Then
	  DebugWrite("Deploying remaining Archers")
	  RandomWeightedClick($archButton)
	  Sleep(500)
	  DeployTroopsToSides($eTroopArcher, $troopIndex, $eAutoRaidDeployRemaining, $direction, 20)
   EndIf

   Sleep(5000)

   ; Deploy minions
   If $minionButton[0] <> -1 Then
	  DebugWrite("Deploying Minions")
	  RandomWeightedClick($minionButton)
	  Sleep(500)
	  DeployTroopsToSides($eTroopMinion, $troopIndex, $eAutoRaidDeployRemaining, $direction, 20)
   EndIf

   ; Deploy and monitor heroes
   Local $kingDeployed = False, $queenDeployed = False
   DeployAndMonitorHeroes($troopIndex, $deployStart, $kingButton, $queenButton, $direction, 10, $kingDeployed, $queenDeployed)

   ; Wait for the end
   WaitForBattleEnd($kingDeployed, $queenDeployed)

   Return True
EndFunc

