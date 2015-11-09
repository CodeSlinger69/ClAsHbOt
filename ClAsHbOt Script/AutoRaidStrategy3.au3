;
; Strategy 3 - Loonian, top or bottom
; Deploy from either NW/NE or SW/SE sides
; 100% ballons, then 100% minions
; Deploy and power up Heroes
;
; Note: Train 20 balloons, rest minions

Func FillBarracksStrategy3(Const $initialFillFlag, Const ByRef $availableTroopCounts, ByRef $armyCampsFull)
   DebugWrite("FillBarracksStrategy3(), " & ($initialFillFlag ? "initial fill." : "top up.") )

   Local $numberOfBalloons = 20

   ; Loop through each standard barracks window and queue troops
   Local $barracksCount = ($initialFillFlag ? 1 : 5)

   While $barracksCount <= 5

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
	  If IsColorPresent($rArmyCampsFullColor) Then
		 $armyCampsFull = True
		 DebugWrite("Barracks " & $barracksCount & " is showing full.")
	  EndIf

	  ; Find the slots for the troops
	  Local $troopSlots[$eTroopCount][4]
	  FindBarracksTroopSlots($gBarracksTroopSlotBMPs, $troopSlots)

	  ; Specified balloons in each barracks on initial fill
	  If $initialFillFlag And $barracksCount>=1 And $barracksCount<=4 Then
		 ; Dequeue troops
		 DequeueTroops()
		 FindBarracksTroopSlots($gBarracksTroopSlotBMPs, $troopSlots)

		 QueueTroopsEvenly($eTroopBalloon, $troopSlots, $numberOfBalloons)
	  EndIf

	  ; Fill up this barracks
	  Local $fillTries=1
	  Local $troopsToFill
	  Do
		 If $barracksCount=5 Then
			; This is intentionally only filling one dark barracks with minions, so that the balloons have time to train
			$troopsToFill = FillBarracksWithTroops($eTroopMinion, $troopSlots)
		 EndIf

		 $fillTries+=1
	  Until $troopsToFill=0 Or $fillTries>=6 Or _
		 (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox)=$BST_UNCHECKED)

	  $barracksCount+=1
   WEnd
EndFunc

Func AutoRaidExecuteRaidStrategy3()
   DebugWrite("AutoRaidExecuteRaidStrategy3()")

   ; What troops are available?
   Local $troopIndex[$eTroopCount][4]
   FindRaidTroopSlots($gTroopSlotBMPs, $troopIndex)

   ; Get counts of available troops
   Local $availableBalloons = GetAvailableTroops($eTroopBalloon, $troopIndex)
   Local $availableMinions = GetAvailableTroops($eTroopMinion, $troopIndex)

   DebugWrite("Available Balloons: " & $availableBalloons)
   DebugWrite("Avaliable Minions: " & $availableMinions)

   ; Determine attack direction
   Local $direction = AutoRaidStrategy3GetDirection()
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

   ; Deploy all balloons
   If $troopIndex[$eTroopBalloon][0] <> -1 Then
	  DebugWrite("Deploying all balloons.")
	  DeployTroopsToSides($eTroopBalloon, $troopIndex, $eAutoRaidDeployRemaining, $direction, 20)
   EndIf

   ; Deploy all minions
   If $troopIndex[$eTroopMinion][0] <> -1 Then
	  DebugWrite("Deploying all minions.")
	  DeployTroopsToSides($eTroopMinion, $troopIndex, $eAutoRaidDeployRemaining, $direction, 20)
   EndIf

   ; Deploy and monitor heroes
   Local $kingDeployed = False, $queenDeployed = False
   DeployAndMonitorHeroes($troopIndex, $deployStart, $direction, 10, $kingDeployed, $queenDeployed)

   ; Wait for the end
   WaitForBattleEnd($kingDeployed, $queenDeployed)

   Return True
EndFunc

Func AutoRaidStrategy3GetDirection()
   DebugWrite("AutoRaidStrategy3GetDirection()")

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
