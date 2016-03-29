;
; Strategy 1 - GiBarch, top or bottom, 8 giants
; Deploy from either NW/NE or SW/SE sides
; 50% giants on each side from safe spots
; 50% breakers on each side from safe spots
; 60% barbs, then 60% archers
; Remaining barbs and archers
; Deploy and power up Heroes
;

Func FillBarracksStrategy1(ByRef $hHMP, Const $initialFillFlag, Const ByRef $builtTroopCounts)
   DebugWrite("FillBarracksStrategy1() " & ($initialFillFlag ? "initial fill" : "top up") )
   Local $giantsNeededInStrategy = 8

   ; How many breakers are needed?
   Local $breakersToQueue = Number(GUICtrlRead($GUI_AutoRaidBreakerCountEdit)) - $builtTroopCounts[$eTroopWallBreaker][4]
   If _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED Then
	  DebugWrite("Wall Breakers needed: " & ($breakersToQueue>0 ? $breakersToQueue : 0))
   Else
	  $breakersToQueue = 0
   EndIf

   ; How many giants are needed?
   Local $giantsToQueue = $giantsNeededInStrategy - $builtTroopCounts[$eTroopGiant][4]
   DebugWrite("Giants needed: " & ($giantsToQueue>0 ? $giantsToQueue : 0))

   ; Loop through each standard barracks window and queue troops
   Local $barracksCount = 1

   While $barracksCount<=4 And (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_CHECKED Or _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox)=$BST_CHECKED)
	  ; Click nextstandard barracks button on Army Manager Window, if unsuccessful, then we are done
	  If OpenNextAvailableStandardBarracks($hHMP) = False Then
		 ExitLoop
	  EndIf

	  ; Find the slots for the troops
	  Local $troopSlots[$gTroopCountExcludingHeroes][4]
	  For $i = $eTroopBarbarian To $eTroopLavaHound
		 $troopSlots[$i][0] = -1
		 $troopSlots[$i][1] = -1
		 $troopSlots[$i][2] = -1
		 $troopSlots[$i][3] = -1
	  Next
	  LocateSlots($eActionTypeBarracks, $eSlotTypeTroop, $troopSlots)

	  ; Giants and specified breakers in each barracks on initial fill
	  If $initialFillFlag And ($breakersToQueue>0 Or $giantsToQueue>0) Then
		 ; Dequeue troops
		 DequeueTroops($hHMP)

		 For $i = $eTroopBarbarian To $eTroopLavaHound
			$troopSlots[$i][0] = -1
			$troopSlots[$i][1] = -1
			$troopSlots[$i][2] = -1
			$troopSlots[$i][3] = -1
		 Next
		 LocateSlots($eActionTypeBarracks, $eSlotTypeTroop, $troopSlots)

		 ; Giants
		 If $giantsToQueue>0 Then QueueTroopsEvenly($eTroopGiant, $troopSlots, $giantsToQueue)

		 ; If breakers are included then queue up breakers in each barracks
		 If $breakersToQueue>0 Then	QueueTroopsEvenly($eTroopWallBreaker, $troopSlots, $breakersToQueue)

	  EndIf

	  ; Fill up this barracks
	  Local $fillTries=1
	  Local $troopsToFill
	  Do
		 If $barracksCount=1 Or $barracksCount=3 Then
			$troopsToFill = FillBarracksWithTroops($hHMP, $eTroopArcher, $troopSlots)
		 Else
			$troopsToFill = FillBarracksWithTroops($hHMP, $eTroopBarbarian, $troopSlots)
		 EndIf

		 $fillTries+=1
		 If $troopsToFill>0 And $fillTries<6 Then
			_WinAPI_DeleteObject($hHMP)
			$hHMP = CaptureFrameHBITMAP("FillBarracksStrategy1")
		 EndIf

	  Until $troopsToFill=0 Or $fillTries>=6 Or _
		 (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox)=$BST_UNCHECKED)

	  $barracksCount+=1
   WEnd
EndFunc


Func AutoRaidExecuteRaidStrategy1(ByRef $hBMP)
   DebugWrite("AutoRaidExecuteRaidStrategy1()")

   ; What troops are available?
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
   LocateSlots($eActionTypeRaid, $eSlotTypeTroop, $troopIndex)

   RandomWeightedClick($rRaidSlotsButton2)
   Sleep(200)
   LocateSlots($eActionTypeRaid, $eSlotTypeTroop, $troopIndex)

   UpdateRaidSlotCounts($troopIndex)

   DebugWrite("Available Barbarians: " & $troopIndex[$eTroopBarbarian][4])
   DebugWrite("Avaliable Archers: " & $troopIndex[$eTroopArcher][4])
   DebugWrite("Avaliable Giants: " & $troopIndex[$eTroopGiant][4])
   If $gDebug And _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED Then _
	  DebugWrite("Avaliable Breakers: " & $troopIndex[$eTroopWallBreaker][4])

   ; Determine attack direction
   Local $direction = AutoRaidStrategy1GetDirection()

   ; Get button
   Local $breakerButton[4] = [ _
	  $troopIndex[$eTroopWallBreaker][0], _
	  $troopIndex[$eTroopWallBreaker][1], _
	  $troopIndex[$eTroopWallBreaker][2], _
	  $troopIndex[$eTroopWallBreaker][3]]

   ;
   ; Deploy troops
   ;
   Local $deployStart = TimerInit()

   ; Deploy giants
   If $troopIndex[$eTroopGiant][0] <> -1 Then
	  Local $numGiantBoxesPerSide = 5
	  DeployTroopsToSides($eTroopGiant, $troopIndex, $eAutoRaidDeployRemaining, $direction, $numGiantBoxesPerSide)
   EndIf

   Sleep(3000)

   ; 50% breakers on each side
   If $breakerButton[0] <> -1 Then
	  DebugWrite("Deploying Breakers.")

	  ; Get 3rd box from corner on each side
	  Local $eastDeployBox[4], $westDeployBox[4]
	  Local $breakerBox = $gMaxDeployBoxes-4
	  If $direction = "Top" Then
		 $westDeployBox[0] = $NWDeployBoxes[$breakerBox][0]
		 $westDeployBox[1] = $NWDeployBoxes[$breakerBox][1]
		 $westDeployBox[2] = $NWDeployBoxes[$breakerBox][0]+10
		 $westDeployBox[3] = $NWDeployBoxes[$breakerBox][1]+10
		 $eastDeployBox[0] = $NEDeployBoxes[$breakerBox][2]-10
		 $eastDeployBox[1] = $NEDeployBoxes[$breakerBox][1]
		 $eastDeployBox[2] = $NEDeployBoxes[$breakerBox][2]
		 $eastDeployBox[3] = $NEDeployBoxes[$breakerBox][1]+10

	  ElseIf $direction = "Bot" Then
		 $westDeployBox[0] = $SWDeployBoxes[$breakerBox][0]
		 $westDeployBox[1] = $SWDeployBoxes[$breakerBox][3]-10
		 $westDeployBox[2] = $SWDeployBoxes[$breakerBox][0]+10
		 $westDeployBox[3] = $SWDeployBoxes[$breakerBox][3]
		 $eastDeployBox[0] = $SEDeployBoxes[$breakerBox][2]-10
		 $eastDeployBox[1] = $SEDeployBoxes[$breakerBox][3]-10
		 $eastDeployBox[2] = $SEDeployBoxes[$breakerBox][2]
		 $eastDeployBox[3] = $SEDeployBoxes[$breakerBox][3]
	  EndIf

	  RandomWeightedClick($breakerButton)
	  Sleep(500)

	  For $i = 1 To $troopIndex[$eTroopWallBreaker][4]
		 Local $xClick, $yClick
		 RandomWeightedCoords( (($i/2=Int($i/2)) ? $westDeployBox : $eastDeployBox), $xClick, $yClick)

		 _ControlClick($xClick, $yClick)
		 Sleep($gDeployTroopClickDelay)
	  Next
   EndIf

   ; 1st wave
   UpdateRaidSlotCounts($troopIndex)

   ; Deploy 50% of barbs
   Local $archBarbNumDeployBoxesPerSide = 10 ; focus on the top or bottom corner to follow the giants
   If $troopIndex[$eTroopBarbarian][4] > 0 Then
	  DebugWrite("Deploying 50% of Barbarians (" & Int($troopIndex[$eTroopBarbarian][4]*0.5) & ")")
	  DeployTroopsToSides($eTroopBarbarian, $troopIndex, $eAutoRaidDeployFiftyPercent, $direction, $archBarbNumDeployBoxesPerSide)
   EndIf

   ; Deploy 50% of archers
   If $troopIndex[$eTroopArcher][4] > 0 Then
	  DebugWrite("Deploying 50% of Archers (" & Int($troopIndex[$eTroopArcher][4]*0.5) & ")")
	  DeployTroopsToSides($eTroopArcher, $troopIndex, $eAutoRaidDeployFiftyPercent, $direction, $archBarbNumDeployBoxesPerSide)
   EndIf

   Sleep(3000)

   ; 2nd wave
   UpdateRaidSlotCounts($troopIndex)

   ; Deploy rest of barbs
   If $troopIndex[$eTroopBarbarian][4] > 0 Then
	  DebugWrite("Deploying remaining Barbarians (" & $troopIndex[$eTroopBarbarian][4] & ")")
	  DeployTroopsToSides($eTroopBarbarian, $troopIndex, $eAutoRaidDeployRemaining, $direction, $archBarbNumDeployBoxesPerSide)
   EndIf

   ; Deploy rest of archers
   If $troopIndex[$eTroopArcher][4] > 0 Then
	  DebugWrite("Deploying remaining Archers (" & $troopIndex[$eTroopArcher][4] & ")")
	  DeployTroopsToSides($eTroopArcher, $troopIndex, $eAutoRaidDeployRemaining, $direction, $archBarbNumDeployBoxesPerSide)
   EndIf

   ; Deploy and monitor heroes
   Local $kingDeployed=False, $queenDeployed=False, $wardenDeployed=False
   DeployAndMonitorHeroes($troopIndex, $deployStart, $direction, 18, $kingDeployed, $queenDeployed, $wardenDeployed)

   ; Wait for the end
   WaitForBattleEnd($hBMP, $kingDeployed, $queenDeployed, $wardenDeployed)

   Return True
EndFunc

Func AutoRaidStrategy1GetDirection()
   DebugWrite("AutoRaidStrategy1GetDirection()")

   ; Count the storages, by top/bottom half
   Local $allMatchY[1], $totalMatches=0
   Local $matchX[1], $matchY[1], $conf[1], $matchCount

   Local $res = FindAllBMPs($eSearchTypeGoldStorage, 4, $matchX, $matchY, $conf, $matchCount)
   If $res Then
	  $totalMatches += $matchCount
	  DebugWrite("Found " & $matchCount & " gold storages, total = " & $totalMatches)
	  ReDim $allMatchY[$totalMatches]
	  For $i = 0 To $matchCount-1
		 $allMatchY[$totalMatches-$matchCount+$i] = $matchY[$i]
	  Next
   Else
	  DebugWrite("Error searching for gold storages")
   EndIf

   Local $res = FindAllBMPs($eSearchTypeElixStorage, 4, $matchX, $matchY, $conf, $matchCount)
   If $res Then
	  $totalMatches += $matchCount
	  DebugWrite("Found " & $matchCount & " elix storages, total = " & $totalMatches)
	  ReDim $allMatchY[$totalMatches]
	  For $i = 0 To $matchCount-1
		 $allMatchY[$totalMatches-$matchCount+$i] = $matchY[$i]
	  Next
   Else
	  DebugWrite("Error searching for elix storages")
   EndIf

   ; Count em
   Local $storagesTopBot = 0
   For $i = 0 To UBound($allMatchY)-1
	  $storagesTopBot += ($allMatchY[$i]+16 < $gScreenCenter[1] ? -1 : 1)
   Next

   ; Attack from top or bottom?
   Local $dir = $storagesTopBot<0 ? "Top" : "Bot"
   DebugWrite("More storages found on " & $dir & ".  Attacking from " & $dir)

   Return $dir
EndFunc
