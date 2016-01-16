;
; Strategy 2 - Barcher & Minion, top or bottom
; Deploy from either NW/NE or SW/SE sides
; 60% barbs, then 60% archers
; Deploy breakers
; Remaining barbs and archers
; Minions
; Deploy and power up Heroes
;

Func FillBarracksStrategy2(Const $initialFillFlag, Const ByRef $builtTroopCounts, ByRef $armyCampsFull)
   DebugWrite("FillBarracksStrategy2(), " & ($initialFillFlag ? "initial fill." : "top up.") )

   ; How many breakers are needed?
   Local $breakersToQueue = Number(GUICtrlRead($GUI_AutoRaidBreakerCountEdit)) - $builtTroopCounts[$eTroopWallBreaker]
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
		 (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox)=$BST_UNCHECKED)

	  $barracksCount+=1
   WEnd
EndFunc

Func AutoRaidExecuteRaidStrategy2()
   DebugWrite("AutoRaidExecuteRaidStrategy2()")

   Local $troopIndex[$eTroopCount][5]

   ; Determine attack direction
   Local $direction = AutoRaidStrategy0GetDirection()
   If $direction = "Bot" Then DragScreenUp()

   ;
   ; Deploy troops
   ;
   Local $deployStart = TimerInit()

   ; 1st wave
   FindRaidTroopSlots($gTroopSlotBMPs, $troopIndex)
   UpdateRaidTroopCounts($troopIndex)

   DebugWrite("Available Barbarians: " & $troopIndex[$eTroopBarbarian][4])
   DebugWrite("Avaliable Archers: " & $troopIndex[$eTroopArcher][4])
   DebugWrite("Avaliable Minions: " & $troopIndex[$eTroopMinion][4])
   If $gDebug And _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED Then _
	  DebugWrite("Avaliable Breakers: " & $troopIndex[$eTroopWallBreaker][4])

   ; Deploy 60% of barbs
   If $troopIndex[$eTroopBarbarian][4] > 0 Then
	  DebugWrite("Deploying 60% of Barbarians (" & Int($troopIndex[$eTroopBarbarian][4]*0.6) & ")")
	  DeployTroopsToSides($eTroopBarbarian, $troopIndex, $eAutoRaidDeploySixtyPercent, $direction, $gMaxDeployBoxes)
   EndIf

   ; Deploy 60% of archers
   If $troopIndex[$eTroopArcher][4] > 0 Then
	  DebugWrite("Deploying 60% of Archers (" & Int($troopIndex[$eTroopArcher][4]*0.6) & ")")
	  DeployTroopsToSides($eTroopArcher, $troopIndex, $eAutoRaidDeploySixtyPercent, $direction, $gMaxDeployBoxes)
   EndIf

   ; Deploy breakers
   If $troopIndex[$eTroopWallBreaker][4] > 0 And _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED Then
	  DebugWrite("Deploying Breakers")
	  DeployTroopsToSafeBoxes($eTroopWallBreaker, $troopIndex, $direction)
   EndIf

   ; 2nd wave
   UpdateRaidTroopCounts($troopIndex)

   ; Deploy rest of barbs
   If $troopIndex[$eTroopBarbarian][4] > 0 Then
	  DebugWrite("Deploying remaining Barbarians (" & $troopIndex[$eTroopBarbarian][4] & ")")
	  DeployTroopsToSides($eTroopBarbarian, $troopIndex, $eAutoRaidDeployRemaining, $direction, $gMaxDeployBoxes)
   EndIf

   ; Deploy rest of archers
   If $troopIndex[$eTroopArcher][4] > 0 Then
	  DebugWrite("Deploying remaining Archers (" & $troopIndex[$eTroopArcher][4] & ")")
	  DeployTroopsToSides($eTroopArcher, $troopIndex, $eAutoRaidDeployRemaining, $direction, $gMaxDeployBoxes)
   EndIf

   Sleep(5000)

   ; Deploy minions
   If $troopIndex[$eTroopMinion][4] > 0 Then
	  DebugWrite("Deploying Minions (" & $troopIndex[$eTroopMinion][4] & ")")
	  DeployTroopsToSides($eTroopMinion, $troopIndex, $eAutoRaidDeployRemaining, $direction, $gMaxDeployBoxes)
   EndIf

   ; Deploy and monitor heroes
   Local $kingDeployed=False, $queenDeployed=False, $wardenDeployed=False
   DeployAndMonitorHeroes($troopIndex, $deployStart, $direction, 10, $kingDeployed, $queenDeployed, $wardenDeployed)

   ; Wait for the end
   WaitForBattleEnd($kingDeployed, $queenDeployed, $wardenDeployed)

   Return True
EndFunc

