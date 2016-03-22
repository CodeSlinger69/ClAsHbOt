;
; Strategy 3 - Loonian, top or bottom
; Deploy from either NW/NE or SW/SE sides
; 100% ballons, then 100% minions
; Deploy and power up Heroes
;
; Note: Train 20 balloons, rest minions

Func FillBarracksStrategy3(ByRef $hHMP, Const $initialFillFlag, Const ByRef $builtTroopCounts)
   DebugWrite("FillBarracksStrategy3() " & ($initialFillFlag ? "initial fill" : "top up") )

   Local $numberOfBalloons = 20

   ; Loop through each standard barracks window and queue troops
   Local $barracksCount = ($initialFillFlag ? 1 : 5)

   While $barracksCount<=5 And (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_CHECKED Or _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox)=$BST_CHECKED)

	  ; Click next standard barracks button on Army Manager Window, if unsuccessful, then try clicking dark
	  If $barracksCount<=4 Then
		 If OpenNextAvailableStandardBarracks($hHMP) = False Then
			$barracksCount = 5
			ContinueLoop
		 EndIf
	  EndIf

	  ; Click next dark barracks button on Army Manager Window, if unsuccessful, then we are done
	  If $barracksCount>=5 Then
		 If OpenNextAvailableDarkBarracks($hHMP) = False Then
			ExitLoop
		 EndIf
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

	  ; Specified balloons in each barracks on initial fill
	  If $initialFillFlag And $barracksCount>=1 And $barracksCount<=4 Then
		 ; Dequeue troops
		 DequeueTroops($hHMP)

		 For $i = $eTroopBarbarian To $eTroopLavaHound
			$troopSlots[$i][0] = -1
			$troopSlots[$i][1] = -1
			$troopSlots[$i][2] = -1
			$troopSlots[$i][3] = -1
		 Next
		 LocateSlots($eActionTypeBarracks, $eSlotTypeTroop, $troopSlots)

		 QueueTroopsEvenly($eTroopBalloon, $troopSlots, $numberOfBalloons)
	  EndIf

	  ; Fill up this barracks
	  Local $fillTries=1
	  Local $troopsToFill
	  Do
		 If $barracksCount=5 Then
			; This is intentionally only filling one dark barracks with minions, so that the balloons have time to train
			$troopsToFill = FillBarracksWithTroops($hHMP, $eTroopMinion, $troopSlots)
		 EndIf

		 $fillTries+=1

		 If $troopsToFill>0 And $fillTries<6 Then
			_WinAPI_DeleteObject($hHMP)
			$hHMP = CaptureFrameHBITMAP("FillBarracksStrategy3")
		 EndIf
	  Until $troopsToFill=0 Or $fillTries>=6 Or _
		 (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox)=$BST_UNCHECKED)

	  $barracksCount+=1
   WEnd
EndFunc

Func AutoRaidExecuteRaidStrategy3(ByRef $hBMP)
   DebugWrite("AutoRaidExecuteRaidStrategy3()")

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
   LocateSlots($eActionTypeRaid, $eSlotTypeTroop, $troopIndex)

   RandomWeightedClick($rRaidSlotsButton2)
   Sleep(200)
   LocateSlots($eActionTypeRaid, $eSlotTypeTroop, $troopIndex)

   ; Determine attack direction
   Local $direction = AutoRaidStrategy3GetDirection()

   ;
   ; Deploy troops
   ;
   Local $deployStart = TimerInit()

   ; 1st wave (only one wave in this strategy)
   UpdateRaidSlotCounts($troopIndex)

   DebugWrite("Available Balloons: " & $troopIndex[$eTroopBalloon][4])
   DebugWrite("Avaliable Minions: " & $troopIndex[$eTroopMinion][4])

   ; Deploy all balloons
   If $troopIndex[$eTroopBalloon][4] > 0 Then
	  DebugWrite("Deploying all balloons (" & $troopIndex[$eTroopBalloon][4] & ")")
	  DeployTroopsToSides($eTroopBalloon, $troopIndex, $eAutoRaidDeployRemaining, $direction, $gMaxDeployBoxes)
   EndIf

   ; Deploy all minions
   If $troopIndex[$eTroopMinion][4] > 0 Then
	  DebugWrite("Deploying all minions (" & $troopIndex[$eTroopMinion][4] & ")")
	  DeployTroopsToSides($eTroopMinion, $troopIndex, $eAutoRaidDeployRemaining, $direction, $gMaxDeployBoxes)
   EndIf

   ; Deploy and monitor heroes
   Local $kingDeployed=False, $queenDeployed=False, $wardenDeployed=False
   DeployAndMonitorHeroes($troopIndex, $deployStart, $direction, 10, $kingDeployed, $queenDeployed, $wardenDeployed)

   ; Wait for the end
   WaitForBattleEnd($hBMP, $kingDeployed, $queenDeployed, $wardenDeployed)

   Return True
EndFunc

Func AutoRaidStrategy3GetDirection()
   DebugWrite("AutoRaidStrategy3GetDirection()")

   ; Count the collectors, by top/bottom half
   Local $matchX[1], $matchY[1], $conf[1], $matchCount

   Local $res = FindAllBMPs($eSearchTypeLootCollector, 17, $matchX, $matchY, $conf, $matchCount)
   Local $collectorsOnTop = 0, $collectorsOnBot = 0

   If $res Then
	  For $i = 0 To $matchCount-1
		 ;DebugWrite("Match " & $i & ": " & $matchX[$i] & "," & $matchY[$i] & " confidence " & Round($conf*100, 2) & "%")
		 If $matchY[$i]+21 < $gScreenCenter[1] Then
			$collectorsOnTop += 1
		 Else
			$collectorsOnBot += 1
		 EndIf
	  Next
   EndIf

   ; Attack from top or bottom?
   DebugWrite("Collectors found top: " & $collectorsOnTop & ", bottom: " & $collectorsOnBot)

   Local $dir = $collectorsOnTop/($collectorsOnTop+$collectorsOnBot) >= 0.5 ? "Top" : "Bot"

   DebugWrite("Attacking from " & $dir)

   Return $dir
EndFunc
