;
; Strategy 1 - GiBarch, top or bottom, 12 giants
; Deploy from either NW/NE or SW/SE sides
; 50% giants on each side from safe spots
; 50% breakers on each side from safe spots
; 60% barbs, then 60% archers
; Remaining barbs and archers
; Deploy and power up Heroes
;

Func FillBarracksStrategy1(Const $initialFillFlag, Const ByRef $availableTroopCounts, ByRef $armyCampsFull)
   DebugWrite("FillBarracksStrategy1(), " & ($initialFillFlag ? "initial fill." : "top up.") )
   Local $giantsNeededInStrategy = 8

   ; How many breakers are needed?
   Local $breakersToQueue = Number(GUICtrlRead($GUI_AutoRaidBreakerCountEdit)) - $availableTroopCounts[$eTroopWallBreaker]
   If _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED Then
	  DebugWrite("Wall Breakers needed: " & ($breakersToQueue>0 ? $breakersToQueue : 0))
   Else
	  $breakersToQueue = 0
   EndIf

   ; How many giants are needed?
   Local $giantsToQueue = $giantsNeededInStrategy - $availableTroopCounts[$eTroopGiant]
   DebugWrite("Giants needed: " & ($giantsToQueue>0 ? $giantsToQueue : 0))

   ; Loop through each standard barracks window and queue troops
   Local $barracksCount = 1

   While $barracksCount <= 4

	  ; Click proper tab on Army Manager Window
	  If $barracksCount=1 Then
		 RandomWeightedClick($rArmyManagerWindowStandard1Button)
	  ElseIf $barracksCount=2 Then
		 RandomWeightedClick($rArmyManagerWindowStandard2Button)
	  ElseIf $barracksCount=3 Then
		 RandomWeightedClick($rArmyManagerWindowStandard3Button)
	  Else  ; $barracksCount=4
		 RandomWeightedClick($rArmyManagerWindowStandard4Button)
	  EndIf

	  Sleep(500)

	  ; See if we are full up
	  If IsColorPresent($rArmyCampsFullColor) Then $armyCampsFull = True

	  ; Find the slots for the troops
	  Local $troopSlots[$eTroopCount][4]
	  FindBarracksTroopSlots($gBarracksTroopSlotBMPs, $troopSlots)

	  ; Giants and specified breakers in each barracks on initial fill
	  If $initialFillFlag And ($breakersToQueue>0 Or $giantsToQueue>0) Then
		 ; Dequeue troops
		 DequeueTroops()
		 FindBarracksTroopSlots($gBarracksTroopSlotBMPs, $troopSlots)

		 ; Giants
		 If $giantsToQueue>0 Then QueueTroopsEvenly($eTroopGiant, $troopSlots, $giantsToQueue)

		 ; If breakers are included then queue up breakers in each barracks
		 If $breakersToQueue>0 Then	QueueTroopsEvenly($eTroopWallBreaker, $troopSlots, $breakersToQueue)

	  EndIf

	  ; Fill up this barracks
	  Local $fillTries=1
	  Local $troopsToFill
	  Do
		 If $barracksCount=1 Or $barracksCount=3 Or $barracksCount=4 Then
			$troopsToFill = FillBarracksWithTroops($eTroopArcher, $troopSlots)
		 Else
			$troopsToFill = FillBarracksWithTroops($eTroopBarbarian, $troopSlots)
		 EndIf

		 $fillTries+=1
	  Until $troopsToFill=0 Or $fillTries>=6 Or _
		 (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox)=$BST_UNCHECKED)

	  $barracksCount+=1
   WEnd
EndFunc


Func AutoRaidExecuteRaidStrategy1()
   DebugWrite("AutoRaidExecuteRaidStrategy1()")

   ; What troops are available?
   Local $troopIndex[$eTroopCount][4]
   FindRaidTroopSlots($gTroopSlotBMPs, $troopIndex)

   ; Get counts of available troops
   Local $availableBarbs = GetAvailableTroops($eTroopBarbarian, $troopIndex)
   Local $availableArchs = GetAvailableTroops($eTroopArcher, $troopIndex)
   Local $availableGiants = GetAvailableTroops($eTroopGiant, $troopIndex)
   Local $availableBreakers = GetAvailableTroops($eTroopWallBreaker, $troopIndex)

   DebugWrite("Available Barbarians: " & $availableBarbs)
   DebugWrite("Avaliable Archers: " & $availableArchs)
   DebugWrite("Avaliable Giants: " & $availableGiants)
   If $gDebug And _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED Then _
	  DebugWrite("Avaliable Breakers: " & $availableBreakers)

   ; Determine attack direction
   Local $direction = AutoRaidStrategy1GetDirection()
   If $direction = "Top" Then
	  DebugWrite("Attacking from top.")
	  MoveScreenDownToTop(False)
   Else
	  DebugWrite("Attacking from bottom.")
	  MoveScreenUpToBottom(False)
   EndIf

   ; Get buttons
   Local $giantButton[4] = [$troopIndex[$eTroopGiant][0], $troopIndex[$eTroopGiant][1], $troopIndex[$eTroopGiant][2], $troopIndex[$eTroopGiant][3]]
   Local $breakerButton[4] = [$troopIndex[$eTroopWallBreaker][0], $troopIndex[$eTroopWallBreaker][1], $troopIndex[$eTroopWallBreaker][2], $troopIndex[$eTroopWallBreaker][3]]

   ;
   ; Deploy troops
   ;
   Local $deployStart = TimerInit()

   ; Deploy giants
   If $giantButton[0] <> -1 Then

	  ; Get deploy boxes
	  Local $deployBoxes[10][4]
	  AutoRaidStrategy1DeployBoxes($direction, $deployBoxes)

	  Local $failCount = 5
	  While $availableGiants>0 And $failCount>0
		 DebugWrite("Deploying Giants " & $availableGiants & " remaining.")

		 RandomWeightedClick($giantButton)
		 Sleep(500)

		 Local $clickPoints[$availableGiants][2]
		 GetAutoSnipeClickPoints(Random(0,1,1), $deployBoxes, $clickPoints)

		 For $i = 0 To $availableGiants-1
			_MouseClickFast($clickPoints[$i][0], $clickPoints[$i][1])
			Sleep($gDeployTroopClickDelay)
		 Next

		 $availableGiants = GetAvailableTroops($eTroopGiant, $troopIndex)>0
		 $failCount-=1
	  WEnd
   EndIf

   Sleep(3000)

   ; 50% breakers on each side
   If $breakerButton[0] <> -1 Then
	  DebugWrite("Deploying Breakers.")

	  ; Get 3rd box from corner on each side
	  Local $eastDeployBox[4], $westDeployBox[4]
	  Local $breakerBox = 14
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

	  For $i = 1 To $availableBreakers
		 Local $xClick, $yClick
		 RandomWeightedCoords( (($i/2=Int($i/2)) ? $westDeployBox : $eastDeployBox), $xClick, $yClick)

		 _MouseClickFast($xClick, $yClick)
		 Sleep($gDeployTroopClickDelay)
	  Next
   EndIf

   Local $slotsToUseForArchBarb = 20

   ; Deploy 50% of barbs
   If $troopIndex[$eTroopBarbarian][0] <> -1 Then
	  DebugWrite("Deploying 50% of Barbarians (" & Int($availableBarbs*0.5) & ")")
	  DeployTroopsToSides($eTroopBarbarian, $troopIndex, $eAutoRaidDeployFiftyPercent, $direction, $slotsToUseForArchBarb)
   EndIf

   ; Deploy 50% of archers
   If $troopIndex[$eTroopArcher][0] <> -1 Then
	  DebugWrite("Deploying 50% of Archers (" & Int($availableArchs*0.5) & ")")
	  DeployTroopsToSides($eTroopArcher, $troopIndex, $eAutoRaidDeployFiftyPercent, $direction, $slotsToUseForArchBarb)
   EndIf

   Sleep(3000)

   ; Deploy rest of barbs
   If $troopIndex[$eTroopBarbarian][0] <> -1 Then
	  DebugWrite("Deploying remaining Barbarians")
	  DeployTroopsToSides($eTroopBarbarian, $troopIndex, $eAutoRaidDeployRemaining, $direction, $slotsToUseForArchBarb)
   EndIf

   ; Deploy rest of archers
   If $troopIndex[$eTroopArcher][0] <> -1 Then
	  DebugWrite("Deploying remaining Archers")
	  DeployTroopsToSides($eTroopArcher, $troopIndex, $eAutoRaidDeployRemaining, $direction, $slotsToUseForArchBarb)
   EndIf

   ; Deploy and monitor heroes
   Local $kingDeployed=False, $queenDeployed=False
   DeployAndMonitorHeroes($troopIndex, $deployStart, $direction, 18, $kingDeployed, $queenDeployed)

   ; Wait for the end
   WaitForBattleEnd($kingDeployed, $queenDeployed)

   Return True
EndFunc

Func AutoRaidStrategy1GetDirection()
   DebugWrite("AutoRaidStrategy1GetDirection()")

   ; Count the storages, by top/bottom half
   Local $allMatchY[1], $totalMatches=0
   Local $matchX[1], $matchY[1], $matchCount

   ; Move screen up 65 pixels
   MoveScreenUpToCenter(65)

   ; Grab frame
   GrabFrameToFile("LocateStoragesFrame.bmp")

   $matchCount = LocateBuildings("LocateStoragesFrame.bmp", $GoldStorageBMPs, $gConfidenceStorages, $matchX, $matchY)
   $totalMatches+=$matchCount
   DebugWrite("Found " & $matchCount & " gold storages, total = " & $totalMatches)
   ReDim $allMatchY[$totalMatches]
   For $i = 0 To $matchCount-1
	  $allMatchY[$totalMatches-$matchCount+$i] = $matchY[$i]
   Next

   $matchCount = LocateBuildings("LocateStoragesFrame.bmp", $ElixStorageBMPs, $gConfidenceStorages, $matchX, $matchY)
   $totalMatches+=$matchCount
   DebugWrite("Found " & $matchCount & " elix storages, total = " & $totalMatches)
   ReDim $allMatchY[$totalMatches]
   For $i = 0 To $matchCount-1
	  $allMatchY[$totalMatches-$matchCount+$i] = $matchY[$i]
   Next

   $matchCount = LocateBuildings("LocateStoragesFrame.bmp", $DarkStorageBMPs, $gConfidenceStorages, $matchX, $matchY)
   $totalMatches+=$matchCount
   DebugWrite("Found " & $matchCount & " dark storages, total = " & $totalMatches)
   ReDim $allMatchY[$totalMatches]
   For $i = 0 To $matchCount-1
	  $allMatchY[$totalMatches-$matchCount+$i] = $matchY[$i]
   Next

   ; Move screen back down 65 pixels
   MoveScreenDownToCenter(65)

   ; Count em
   Local $storagesTopBot = 0
   For $i = 0 To UBound($allMatchY)-1
	  $storagesTopBot += ($allMatchY[$i]+16 < 235 ? -1 : 1)
   Next

   ; Attack from top or bottom?
   ;DebugWrite("$storagesTopBot: " & $storagesTopBot)
   Return ($storagesTopBot<0 ? "Top" : "Bot")
EndFunc

Func AutoRaidStrategy1DeployBoxes(Const $topOrBot, ByRef $selectedBoxes)
   If $topOrBot = "Top" Then
	  ; Top 10 corner boxes
	  For $i = 16 To 20
		 $selectedBoxes[$i-16][0] = $NWDeployBoxes[$i][0]
		 $selectedBoxes[$i-16][1] = $NWDeployBoxes[$i][1]
		 $selectedBoxes[$i-16][2] = $NWDeployBoxes[$i][0]+10
		 $selectedBoxes[$i-16][3] = $NWDeployBoxes[$i][1]+10
	  Next
	  For $i = 16 To 20
		 $selectedBoxes[$i-16+5][0] = $NEDeployBoxes[$i][2]-10
		 $selectedBoxes[$i-16+5][1] = $NEDeployBoxes[$i][1]
		 $selectedBoxes[$i-16+5][2] = $NEDeployBoxes[$i][2]
		 $selectedBoxes[$i-16+5][3] = $NEDeployBoxes[$i][1]+10
	  Next

   ElseIf $topOrBot = "Bot" Then
	  ; Bottom 10 corner boxes
	  For $i = 16 To 20
		 $selectedBoxes[$i-16][0] = $SWDeployBoxes[$i][0]
		 $selectedBoxes[$i-16][1] = $SWDeployBoxes[$i][3]-10
		 $selectedBoxes[$i-16][2] = $SWDeployBoxes[$i][0]+10
		 $selectedBoxes[$i-16][3] = $SWDeployBoxes[$i][3]
	  Next
	  For $i = 16 To 20
		 $selectedBoxes[$i-16+5][0] = $SEDeployBoxes[$i][2]-10
		 $selectedBoxes[$i-16+5][1] = $SEDeployBoxes[$i][3]-10
		 $selectedBoxes[$i-16+5][2] = $SEDeployBoxes[$i][2]
		 $selectedBoxes[$i-16+5][3] = $SEDeployBoxes[$i][3]
	  Next
   Else
	  DebugWrite("ERROR in AutoRaidStrategy1DeployBoxes, $topOrBot = " & $topOrBot)

   EndIf
EndFunc

