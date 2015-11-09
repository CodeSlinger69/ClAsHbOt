;
; Strategy 0 - Barcher, top or bottom
; Deploy from either NW/NE or SW/SE sides
; 60% barbs, then 60% archers
; Deploy breakers
; Remaining barbs and archers
; Deploy and power up Heroes
;

Func FillBarracksStrategy0(Const $initialFillFlag, Const ByRef $availableTroopCounts, ByRef $armyCampsFull)
   DebugWrite("FillBarracksStrategy0(), " & ($initialFillFlag ? "initial fill." : "top up.") )

   ; How many breakers are needed?
   Local $breakersToQueue = Number(GUICtrlRead($GUI_AutoRaidBreakerCountEdit)) - $availableTroopCounts[$eTroopWallBreaker]
   If _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED Then
	  DebugWrite("Wall Breakers needed: " & ($breakersToQueue>0 ? $breakersToQueue : 0))
   Else
	  $breakersToQueue = 0
   EndIf

   ; Loop through each standard barracks window and queue troops
   Local $barracksCount = 1

   While $barracksCount <= 4

	  ; Click next standard barracks button on Army Manager Window, if unsuccessful, then we are done
	  If OpenNextAvailableStandardBarracks() = False Then
		 ExitLoop
	  EndIf

	  ; See if we are full up
	  If IsColorPresent($rArmyCampsFullColor) Then
		 $armyCampsFull = True
		 DebugWrite("Barracks " & $barracksCount & " is showing full.")
	  EndIf

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
		 If $barracksCount=1 Or $barracksCount=3 Then
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

   ; Determine attack direction
   Local $direction = AutoRaidStrategy0GetDirection()
   If $direction = "Top" Then
	  DebugWrite("Attacking from top.")
	  MoveScreenDownToTop(False)
   Else
	  DebugWrite("Attacking from bottom.")
	  MoveScreenUpToBottom(False)
   EndIf

   ;
   ; Deploy troops
   ;
   Local $deployStart = TimerInit()

   ; Deploy 60% of barbs
   If $troopIndex[$eTroopBarbarian][0] <> -1 Then
	  DebugWrite("Deploying 60% of Barbarians (" & Int($availableBarbs*0.6) & ")")
	  DeployTroopsToSides($eTroopBarbarian, $troopIndex, $eAutoRaidDeploySixtyPercent, $direction, 20)
   EndIf

   ; Deploy 60% of archers
   If $troopIndex[$eTroopArcher][0] <> -1 Then
	  DebugWrite("Deploying 60% of Archers (" & Int($availableArchs*0.6) & ")")
	  DeployTroopsToSides($eTroopArcher, $troopIndex, $eAutoRaidDeploySixtyPercent, $direction, 20)
   EndIf

   ; Deploy breakers
   If $troopIndex[$eTroopWallBreaker][0] <> -1 And _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED Then
	  DebugWrite("Deploying Breakers")
	  DeployTroopsToSafeBoxes($eTroopWallBreaker, $troopIndex, $direction)
   EndIf

   ; Deploy rest of barbs
   If $troopIndex[$eTroopBarbarian][0] <> -1 Then
	  DebugWrite("Deploying remaining Barbarians")
	  DeployTroopsToSides($eTroopBarbarian, $troopIndex, $eAutoRaidDeployRemaining, $direction, 20)
   EndIf

   ; Deploy rest of archers
   If $troopIndex[$eTroopArcher][0] <> -1 Then
	  DebugWrite("Deploying remaining Archers")
	  DeployTroopsToSides($eTroopArcher, $troopIndex, $eAutoRaidDeployRemaining, $direction, 20)
   EndIf

   ; Deploy and monitor heroes
   Local $kingDeployed = False, $queenDeployed = False
   DeployAndMonitorHeroes($troopIndex, $deployStart, $direction, 10, $kingDeployed, $queenDeployed)

   ; Wait for the end
   WaitForBattleEnd($kingDeployed, $queenDeployed)

   Return True
EndFunc

Func AutoRaidStrategy0GetDirection()
   DebugWrite("AutoRaidStrategy0GetDirection()")

   ; Count the collectors, by top/bottom half
   Local $matchX[1], $matchY[1], $matchCount

   ; Move screen up 65 pixels
   MoveScreenUpToCenter(65)

   ; Grab frame
   GrabFrameToFile("LocateCollectorsFrame.bmp")

   $matchCount = LocateBuildings("LocateCollectorsFrame.bmp", $CollectorBMPs, $gConfidenceCollector, $matchX, $matchY)
   Local $collectorsOnTop = 0, $collectorsOnBot = 0

   ; Move screen back down 65 pixels
   MoveScreenDownToCenter(65)

   For $i = 0 To $matchCount-1
	  ;DebugWrite("Match " & $i & ": " & $matchX[$i] & "," & $matchY[$i])
	  If $matchY[$i] < 250 Then
		 $collectorsOnTop += 1
	  Else
		 $collectorsOnBot += 1
	  EndIf
   Next

   ; Attack from top or bottom?
   Return ($collectorsOnTop/($collectorsOnTop+$collectorsOnBot) > 0.65 ? "Top" : "Bot")
EndFunc
