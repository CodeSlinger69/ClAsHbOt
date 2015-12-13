;
; Strategy 2 - Barcher & Minion, top or bottom
; Deploy from either NW/NE or SW/SE sides
; 60% barbs, then 60% archers
; Deploy breakers
; Remaining barbs and archers
; Minions
; Deploy and power up Heroes
;

Func FillBarracksStrategy2(Const $initialFillFlag, Const ByRef $availableTroopCounts, ByRef $armyCampsFull)
   DebugWrite("FillBarracksStrategy2(), " & ($initialFillFlag ? "initial fill." : "top up.") )

   ; How many breakers are needed?
   Local $breakersToQueue = Number(GUICtrlRead($GUI_AutoRaidBreakerCountEdit)) - $availableTroopCounts[$eTroopWallBreaker]
   If _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED Then
	  DebugWrite("Wall Breakers needed: " & ($breakersToQueue>0 ? $breakersToQueue : 0))
   Else
	  $breakersToQueue = 0
   EndIf

   ; Loop through each standard and dark barracks window and queue troops
   Local $barracksCount = 1

   While $barracksCount <= 6

	  ; Click next standard barracks button on Army Manager Window, if unsuccessful, then try clicking dark
	  If $barracksCount<=4 Then
		 If OpenNextAvailableStandardBarracks() = False Then
			$barracksCount = 5
		 EndIf
	  EndIf

	  ; Click next standard barracks button on Army Manager Window, if unsuccessful, then we are done
	  If $barracksCount>=5 Then
		 If OpenNextAvailableDarkBarracks() = False Then
			ExitLoop
		 EndIf
	  EndIf

	  ; See if we are full up
	  If IsColorPresent($rArmyCampsFullColor) Then $armyCampsFull = True

	  ; Find the slots for the troops
	  Local $troopSlots[$eTroopCount][4]
	  FindBarracksTroopSlots($gBarracksTroopSlotBMPs, $troopSlots)

	  ; Specified breakers in standard barracks on initial fill
	  If $initialFillFlag And $breakersToQueue>0 And $barracksCount<=4 Then
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
		 If $barracksCount=1 Or $barracksCount=3 Then
			$troopsToFill = FillBarracksWithTroops($eTroopArcher, $troopSlots)
		 ElseIf $barracksCount=2 Or $barracksCount=4 Then
			$troopsToFill = FillBarracksWithTroops($eTroopBarbarian, $troopSlots)
		 Else
			$troopsToFill = FillBarracksWithTroops($eTroopMinion, $troopSlots)
		 EndIf

		 $fillTries+=1
	  Until $troopsToFill=0 Or $fillTries>=6 Or _
		 (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox)=$BST_UNCHECKED)

	  $barracksCount+=1
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
   If $direction = "Bot" Then DragScreenUp()

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
   If $troopIndex[$eTroopBarbarian][0] <> -1 Then
	  DebugWrite("Deploying 60% of Barbarians (" & Int($availableBarbs*0.6) & ")")
	  DeployTroopsToSides($eTroopBarbarian, $troopIndex, $eAutoRaidDeploySixtyPercent, $direction, $gMaxDeployBoxes)
   EndIf

   ; Deploy 60% of archers
   If $troopIndex[$eTroopArcher][0] <> -1 Then
	  DebugWrite("Deploying 60% of Archers (" & Int($availableArchs*0.6) & ")")
	  DeployTroopsToSides($eTroopArcher, $troopIndex, $eAutoRaidDeploySixtyPercent, $direction, $gMaxDeployBoxes)
   EndIf

   ; Deploy breakers
   If $troopIndex[$eTroopWallBreaker][0] <> -1 And _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED Then
	  DebugWrite("Deploying Breakers")
	  DeployTroopsToSafeBoxes($eTroopWallBreaker, $troopIndex, $direction)
   EndIf

   ; Deploy rest of barbs
   If $troopIndex[$eTroopBarbarian][0] <> -1 Then
	  DebugWrite("Deploying remaining Barbarians")
	  DeployTroopsToSides($eTroopBarbarian, $troopIndex, $eAutoRaidDeployRemaining, $direction, $gMaxDeployBoxes)
   EndIf

   ; Deploy rest of archers
   If $troopIndex[$eTroopArcher][0] <> -1 Then
	  DebugWrite("Deploying remaining Archers")
	  DeployTroopsToSides($eTroopArcher, $troopIndex, $eAutoRaidDeployRemaining, $direction, $gMaxDeployBoxes)
   EndIf

   Sleep(5000)

   ; Deploy minions
   If $troopIndex[$eTroopMinion][0] <> -1 Then
	  DebugWrite("Deploying Minions")
	  DeployTroopsToSides($eTroopMinion, $troopIndex, $eAutoRaidDeployRemaining, $direction, 20)
   EndIf

   ; Deploy and monitor heroes
   Local $kingDeployed = False, $queenDeployed = False
   DeployAndMonitorHeroes($troopIndex, $deployStart, $direction, 10, $kingDeployed, $queenDeployed)

   ; Wait for the end
   WaitForBattleEnd($kingDeployed, $queenDeployed)

   Return True
EndFunc

