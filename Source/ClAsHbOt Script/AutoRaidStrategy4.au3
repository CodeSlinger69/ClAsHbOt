;
; Strategy 4 - HoBarch
; Deploy from either NW/NE or SW/SE sides
; 60% barbs, then 60% archers
; Deploy hogs
; Deploy breakers
; Remaining barbs and archers
; Deploy and power up Heroes
;

Func FillBarracksStrategy4(ByRef $hHMP, Const $initialFillFlag, Const ByRef $builtTroopCounts)
   DebugWrite("FillBarracksStrategy4() " & ($initialFillFlag ? "initial fill" : "top up") )

   ; How many breakers are needed?
   Local $breakersToQueue = Number(GUICtrlRead($GUI_AutoRaidBreakerCountEdit)) - $builtTroopCounts[$eTroopWallBreaker][4]
   If _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED Then
	  DebugWrite("Wall Breakers needed: " & ($breakersToQueue>0 ? $breakersToQueue : 0))
   Else
	  $breakersToQueue = 0
   EndIf

   ; Loop through each standard barracks window and queue troops
   Local $barracksCount = 1

   While $barracksCount<=6 And (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_CHECKED Or _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox)=$BST_CHECKED)

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

	  ; Specified breakers in each barracks on initial fill
	  If $initialFillFlag And $breakersToQueue>0 Then
		 ; Dequeue troops
		 DequeueTroops($hHMP)

		 For $i = $eTroopBarbarian To $eTroopLavaHound
			$troopSlots[$i][0] = -1
			$troopSlots[$i][1] = -1
			$troopSlots[$i][2] = -1
			$troopSlots[$i][3] = -1
		 Next
		 LocateSlots($eActionTypeBarracks, $eSlotTypeTroop, $troopSlots)

		 QueueTroopsEvenly($eTroopWallBreaker, $troopSlots, $breakersToQueue)
	  EndIf

	  ; Fill up this barracks
	  Local $fillTries=1
	  Local $troopsToFill
	  Do
		 If $barracksCount=1 Or $barracksCount=3 Then
			$troopsToFill = FillBarracksWithTroops($hHMP, $eTroopArcher, $troopSlots)
		 ElseIf $barracksCount=2 Or $barracksCount=4 Then
			$troopsToFill = FillBarracksWithTroops($hHMP, $eTroopBarbarian, $troopSlots)
		 ElseIf $barracksCount>=5 Then
			$troopsToFill = FillBarracksWithTroops($hHMP, $eTroopHogRider, $troopSlots)
		 EndIf

		 $fillTries+=1

		 If $troopsToFill>0 And $fillTries<6 Then
			_WinAPI_DeleteObject($hHMP)
			$hHMP = CaptureFrameHBITMAP("FillBarracksStrategy4")
		 EndIf
	  Until $troopsToFill=0 Or $fillTries>=6 Or _
		 (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox)=$BST_UNCHECKED)

	  $barracksCount+=1
   WEnd
EndFunc

Func AutoRaidExecuteRaidStrategy4(ByRef $hBMP)
   DebugWrite("AutoRaidExecuteRaidStrategy4()")

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
   Local $direction = AutoRaidStrategy1GetDirection()

    ;
   ; Deploy troops
   ;
   Local $deployStart = TimerInit()

   ; 1st wave
   UpdateRaidSlotCounts($troopIndex)

   DebugWrite("Available Barbarians: " & $troopIndex[$eTroopBarbarian][4])
   DebugWrite("Avaliable Archers: " & $troopIndex[$eTroopArcher][4])
   DebugWrite("Avaliable HogRiders: " & $troopIndex[$eTroopHogRider][4])
   If $gDebug And _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED Then _
	  DebugWrite("Avaliable Breakers: " & $troopIndex[$eTroopWallBreaker][4])

   ; Deploy 60% of barbs
   If $troopIndex[$eTroopBarbarian][4] > 0 Then
	  DebugWrite("Deploying 60% of Barbarians (" & Int($troopIndex[$eTroopBarbarian][4]*0.6) & ")")
	  DeployTroopsToSides($eTroopBarbarian, $troopIndex, $eAutoRaidDeploySixtyPercent, $direction, $gMaxDeployBoxes-4)
   EndIf

   ; Deploy 60% of archers
   If $troopIndex[$eTroopArcher][4] > 0 Then
	  DebugWrite("Deploying 60% of Archers (" & Int($troopIndex[$eTroopArcher][4]*0.6) & ")")
	  DeployTroopsToSides($eTroopArcher, $troopIndex, $eAutoRaidDeploySixtyPercent, $direction, $gMaxDeployBoxes-4)
   EndIf

   ; Deploy hogs
   If $troopIndex[$eTroopHogRider][0] <> -1 Then
	  DebugWrite("Deploying Hog Riders")
	  Local $numHogRiderBoxesPerSide = 5
	  DeployTroopsToSides($eTroopHogRider, $troopIndex, $eAutoRaidDeployRemaining, $direction, $numHogRiderBoxesPerSide)
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
	  DeployTroopsToSides($eTroopBarbarian, $troopIndex, $eAutoRaidDeployRemaining, $direction, $gMaxDeployBoxes-4)
   EndIf

   ; Deploy rest of archers
   If $troopIndex[$eTroopArcher][4] > 0 Then
	  DebugWrite("Deploying remaining Archers (" & $troopIndex[$eTroopArcher][4] & ")")
	  DeployTroopsToSides($eTroopArcher, $troopIndex, $eAutoRaidDeployRemaining, $direction, $gMaxDeployBoxes-4)
   EndIf

   ; Deploy and monitor heroes
   Local $kingDeployed=False, $queenDeployed=False, $wardenDeployed=False
   DeployAndMonitorHeroes($troopIndex, $deployStart, $direction, 10, $kingDeployed, $queenDeployed, $wardenDeployed)

   ; Wait for the end
   WaitForBattleEnd($hBMP, $kingDeployed, $queenDeployed, $wardenDeployed)

   Return True
EndFunc

