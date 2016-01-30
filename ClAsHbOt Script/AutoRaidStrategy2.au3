;
; Strategy 2 - Barcher & Minion, top or bottom
; Deploy from either NW/NE or SW/SE sides
; 60% barbs, then 60% archers
; Deploy breakers
; Remaining barbs and archers
; Minions
; Deploy and power up Heroes
;

Func FillBarracksStrategy2(ByRef $f, Const $initialFillFlag, Const ByRef $builtTroopCounts, ByRef $armyCampsFull)
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

   While $barracksCount<=6 And (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_CHECKED Or _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox)=$BST_CHECKED)
	  ; Click next standard barracks button on Army Manager Window, if unsuccessful, then try clicking dark
	  If $barracksCount<=4 Then
		 If OpenNextAvailableStandardBarracks($f) = False Then
			$barracksCount = 5
		 EndIf
	  EndIf

	  ; Click next standard barracks button on Army Manager Window, if unsuccessful, then we are done
	  If $barracksCount>=5 Then
		 If OpenNextAvailableDarkBarracks($f) = False Then
			ExitLoop
		 EndIf
	  EndIf

	  ; See if we are full up
	  If IsColorPresent($f, $rArmyCampsFullColor) Then
		 $armyCampsFull = True
		 DebugWrite("Barracks " & $barracksCount & " is showing full.")
	  EndIf

	  ; Find the slots for the troops
	  Local $troopSlots[$gTroopCountExcludingHeroes][4]
	  FindBarracksTroopSlots($gBarracksTroopSlotBMPs, $troopSlots)

	  ; Specified breakers in standard barracks on initial fill
	  If $initialFillFlag And $breakersToQueue>0 And $barracksCount<=4 Then
		 ; Dequeue troops
		 DequeueTroops($f)

		 FindBarracksTroopSlots($gBarracksTroopSlotBMPs, $troopSlots)

		 ; If breakers are included then queue up breakers in each barracks
		 If $breakersToQueue>0 Then QueueTroopsEvenly($eTroopWallBreaker, $troopSlots, $breakersToQueue)
	  EndIf

	  ; Fill up this barracks
	  Local $fillTries=1
	  Local $troopsToFill
	  Do
		 If $barracksCount=1 Or $barracksCount=3 Then
			$troopsToFill = FillBarracksWithTroops($f, $eTroopArcher, $troopSlots)
		 ElseIf $barracksCount=2 Or $barracksCount=4 Then
			$troopsToFill = FillBarracksWithTroops($f, $eTroopBarbarian, $troopSlots)
		 Else
			$troopsToFill = FillBarracksWithTroops($f, $eTroopMinion, $troopSlots)
		 EndIf

		 $fillTries+=1

		 If $troopsToFill>0 And $fillTries<6 Then
			_GDIPlus_BitmapDispose($f)
			$f = CaptureFrame("FillBarracksStrategy2")
		 EndIf
	  Until $troopsToFill=0 Or $fillTries>=6 Or _
		 (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox)=$BST_UNCHECKED)

	  $barracksCount+=1
   WEnd
EndFunc

Func AutoRaidExecuteRaidStrategy2(ByRef $f)
   DebugWrite("AutoRaidExecuteRaidStrategy2()")

   ; Get raid troop slots
   Local $troopIndex[$eTroopCount][5]
   For $i = 0 To UBound($troopIndex)-1
	  $troopIndex[$i][0] = -1
	  $troopIndex[$i][1] = -1
	  $troopIndex[$i][2] = -1
	  $troopIndex[$i][3] = -1
	  $troopIndex[$i][4] = 0
   Next

   RandomWeightedClick($rRaidSlotsButton1)
   Sleep(200)
   LocateRaidSlots($eRaidSlotTypeTroop, $troopIndex)

   RandomWeightedClick($rRaidSlotsButton2)
   Sleep(200)
   LocateRaidSlots($eRaidSlotTypeTroop, $troopIndex)

   ; Determine attack direction
   Local $direction = AutoRaidStrategy0GetDirection($f)

   ;
   ; Deploy troops
   ;
   Local $deployStart = TimerInit()

   ; 1st wave
   UpdateRaidSlotCounts($troopIndex)

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
   UpdateRaidSlotCounts($troopIndex)

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
   WaitForBattleEnd($f, $kingDeployed, $queenDeployed, $wardenDeployed)

   Return True
EndFunc

