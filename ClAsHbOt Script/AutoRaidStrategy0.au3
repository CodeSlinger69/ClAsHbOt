;
; Strategy 0 - Barcher, top or bottom
; Deploy from either NW/NE or SW/SE sides
; 60% barbs, then 60% archers
; Deploy breakers
; Remaining barbs and archers
; Deploy and power up Heroes
;

Func FillBarracksStrategy0(ByRef $f, Const $initialFillFlag, Const ByRef $builtTroopCounts, ByRef $armyCampsFull)
   DebugWrite("FillBarracksStrategy0(), " & ($initialFillFlag ? "initial fill." : "top up.") )

   ; How many breakers are needed?
   Local $breakersToQueue = Number(GUICtrlRead($GUI_AutoRaidBreakerCountEdit)) - $builtTroopCounts[$eTroopWallBreaker]
   If _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED Then
	  DebugWrite("Wall Breakers needed: " & ($breakersToQueue>0 ? $breakersToQueue : 0))
   Else
	  $breakersToQueue = 0
   EndIf

   ; Loop through each standard barracks window and queue troops
   Local $barracksCount = 1

   While $barracksCount<=4 And (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_CHECKED Or _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox)=$BST_CHECKED)
	  ; Click next standard barracks button on Army Manager Window, if unsuccessful, then we are done
	  If OpenNextAvailableStandardBarracks($f) = False Then
		 ExitLoop
	  EndIf

	  ; See if we are full up
	  If IsColorPresent($f, $rArmyCampsFullColor) Then
		 $armyCampsFull = True
		 DebugWrite("Barracks " & $barracksCount & " is showing full.")
	  EndIf

	  ; Find the slots for the troops
	  Local $troopSlots[$gTroopCountExcludingHeroes][4]
	  FindBarracksTroopSlots($gBarracksTroopSlotBMPs, $troopSlots)

	  ; Specified breakers in each barracks on initial fill
	  If $initialFillFlag And $breakersToQueue>0 Then
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
		 Else
			$troopsToFill = FillBarracksWithTroops($f, $eTroopBarbarian, $troopSlots)
		 EndIf

		 $fillTries+=1

		 If $troopsToFill>0 And $fillTries<6 Then
			_GDIPlus_BitmapDispose($f)
			$f = CaptureFrame("FillBarracksStrategy0")
		 EndIf
	  Until $troopsToFill=0 Or $fillTries>=6 Or _
		 (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox)=$BST_UNCHECKED)

	  $barracksCount+=1
   WEnd
EndFunc

Func AutoRaidExecuteRaidStrategy0(ByRef $f)
   DebugWrite("AutoRaidExecuteRaidStrategy0()")

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

   ; Deploy and monitor heroes
   Local $kingDeployed=False, $queenDeployed=False, $wardenDeployed=False
   DeployAndMonitorHeroes($troopIndex, $deployStart, $direction, 10, $kingDeployed, $queenDeployed, $wardenDeployed)

   ; Wait for the end
   WaitForBattleEnd($f, $kingDeployed, $queenDeployed, $wardenDeployed)

   Return True
EndFunc

Func AutoRaidStrategy0GetDirection(Const $f)
   ; Count the collectors, by top/bottom half
   Local $matchX[1], $matchY[1], $conf[1]

   Local $matchCount = ScanFrameForAllBMPs($f, $CollectorBMPs, $gConfidenceCollector, 14, $matchX, $matchY, $conf)
   Local $collectorsOnTop = 0, $collectorsOnBot = 0

   For $i = 0 To $matchCount-1
	  ;DebugWrite("Match " & $i & ": " & $matchX[$i] & "," & $matchY[$i] & " confidence " & Round($conf*100, 2) & "%")
	  If $matchY[$i]+21 < $gScreenCenter[1] Then
		 $collectorsOnTop += 1
	  Else
		 $collectorsOnBot += 1
	  EndIf
   Next

   DebugWrite("AutoRaidStrategy0GetDirection() Collectors found top: " & $collectorsOnTop & ", bottom: " & $collectorsOnBot)

   Local $dir = $collectorsOnTop/($collectorsOnTop+$collectorsOnBot) >= 0.5 ? "Top" : "Bot"

   DebugWrite("AutoRaidStrategy0GetDirection() Attacking from " & $dir)

   Return $dir
EndFunc
