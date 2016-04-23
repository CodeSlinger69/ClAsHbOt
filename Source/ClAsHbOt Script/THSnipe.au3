Func AutoPush(ByRef $hBMP, ByRef $timer, ByRef $THCorner)
   ;DebugWrite("AutoPush()")

   If $gAutoSnipeNotifyOnly Then
	  $gAutoStage = $eAutoFindMatch
	  DebugWrite("AutoPush() Notify mode")
   EndIf

   Switch $gAutoStage

   ; Stage Queue Training
   Case $eAutoQueueTraining
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Queue Training")

	  ResetToCoCMainScreen($hBMP)

	  Local $dummy
	  AutoQueueTroops(True, $dummy)
	  $timer = TimerInit()

   ; Stage Wait For Training To Complete
   Case $eAutoWaitForTrainingToComplete

	  If TimerDiff($timer) >= $gTroopTrainingCheckInterval Then
		 ResetToCoCMainScreen($hBMP)

		 Local $dummy
		 AutoQueueTroops(False, $dummy)
		 $timer = TimerInit()
	  EndIf

   ; Stage Find Match
   Case $eAutoFindMatch
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Find Snipable TH")

	  ResetToCoCMainScreen($hBMP)
	  ZoomOut($hBMP)

	  Local $findMatchResults = THSnipeFindMatch($hBMP, $THCorner)

	  ; Reset if there was an error
	  If $findMatchResults=False Then
		 DebugWrite("Auto: Error finding match, resetting.")
		 ResetToCoCMainScreen($hBMP)
		 $gAutoStage = $eAutoQueueTraining
		 Return
	  EndIf

	  ; Did we find a snipable base?
	  If $findMatchResults = $eAutoExecuteSnipe And $gAutoSnipeNotifyOnly Then
		 For $i = 1 To 5
			Beep(500, 200)
			Sleep(100)
		 Next

		 MsgBox(BitOR($MB_OK, $MB_ICONINFORMATION), "Snipable TH!", "")
		 $gAutoStage = $eAutoQueueTraining
		 Return
	  EndIf

	  If $findMatchResults = $eAutoExecuteSnipe Then $gAutoStage = $eAutoExecuteSnipe

   ; Stage Execute TH Snipe to Push
   Case $eAutoExecuteSnipe
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Execute Snipe")

	  If THSnipeExecute($hBMP, $THCorner) = False Then
		 ResetToCoCMainScreen($hBMP)
	  EndIf

	  $gAutoStage = $eAutoQueueTraining
	  UpdateWinnings($hBMP)

	  GUICtrlSetData($GUI_AutoStatus, "Auto: Snipe Complete")

   EndSwitch

EndFunc

Func THSnipeFindMatch(ByRef $hBMP, ByRef $THCorner)
   ; Get frame
   ZoomOut($hBMP)

   ; Make sure we are on the main screen
   If WhereAmI($hBMP) <> $eScreenMain Then
	  DebugWrite("THSnipeFindMatch() Find Snipable TH failed - not on main screen")
	  Return False
   EndIf

   ; Click Attack
   DebugWrite("THSnipeFindMatch() Click Attack button")
   If IsButtonPresent($hBMP, $rMainScreenAttackNoStarsButton) Then
	  RandomWeightedClick($rMainScreenAttackNoStarsButton)
   ElseIf IsButtonPresent($hBMP, $rMainScreenAttackWithStarsButton) Then
	  RandomWeightedClick($rMainScreenAttackWithStarsButton)
   Else
	  DebugWrite("THSnipeFindMatch() Find Match failed - could not find Attack! button")
   EndIf

   ; Wait for Find a Match button
   If WaitForButton($hBMP, 10000, $rFindMatchScreenFindAMatchNoShieldButton, $rFindMatchScreenFindAMatchWithShieldButton) = False Then
	  DebugWrite("THSnipeFindMatch() Find Match failed - timeout waiting for Find a Match button")
	  Return False
   EndIf

   ; Click Find a Match
   DebugWrite("THSnipeFindMatch() Click Find a Match button")
   If IsButtonPresent($hBMP, $rFindMatchScreenFindAMatchNoShieldButton) Then
	  RandomWeightedClick($rFindMatchScreenFindAMatchNoShieldButton)
   ElseIf IsButtonPresent($hBMP, $rFindMatchScreenFindAMatchWithShieldButton) Then
	  RandomWeightedClick($rFindMatchScreenFindAMatchWithShieldButton)
   EndIf


   ; Loop with Next until we find a snipable TH
   While 1
	  If _GUICtrlButton_GetCheck($GUI_FindMatchCheckBox) = $BST_UNCHECKED And _
		 _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_UNCHECKED Then
		 Return False
	  EndIf

	  ; Wait for Next button
	  If AutoWaitForNextButton($hBMP) = False Then
		 Return False
	  EndIf

	  ; Update my loot status on GUI
	  GetMyLootNumbers($hBMP)

	  ; If snipable, then go do it
	  Local $thLevel, $thLeft, $thTop, $gold, $elix, $dark, $cups, $deadBase
	  AutoRaidGetDisplayedLoot($thLevel, $thLeft, $thTop, $gold, $elix, $dark, $cups, $deadbase)

	  If CheckForSnipableTH($THCorner, $thLevel, $thLeft, $thTop, $gold, $elix, $dark, $cups, $deadbase) Then
		 Return $eAutoExecuteSnipe
	  EndIf

	  ; Not snipable - click Next
	  Sleep($gPauseBetweenNexts)

	  If IsButtonPresent($hBMP, $rWaitRaidScreenNextButton) Then
		 RandomWeightedClick($rWaitRaidScreenNextButton)
		 Sleep(500)

	  Else
		 DebugWrite("THSnipeFindMatch() Next Button disappeared, resetting.")

		 If IsButtonPresent($hBMP, $rLiveRaidScreenEndBattleButton) Then
			RandomWeightedClick($rLiveRaidScreenEndBattleButton)

			If WaitForButton($hBMP, 5000, $rLiveRaidScreenEndBattleConfirmButton) = True Then
			   RandomWeightedClick($rLiveRaidScreenEndBattleConfirmButton)
			   Sleep(1000)
			EndIf
		 EndIf

		 Return False
	  EndIf
   WEnd

EndFunc

Func CheckForSnipableTH(ByRef $THCorner, Const $thLevel, Const $thLeft, Const $thTop, _
						Const $gold, Const $elix, Const $dark, Const $cups, Const $deadbase)

   ; Town Hall images are 22x24
   Local $x = $thLeft+11
   Local $y = $thTop+12

   If $thLevel = -1 Then
	  DebugWrite("CheckForSnipableTH() Could not find Town Hall.  Obscured?")
	  Return False
   EndIf

   If DistBetweenTwoPoints($x, $y, $gNorthPoint[0], $gNorthPoint[1]) <= $gTHSnipeMaxDistFromCorner Then
	  DebugWrite("CheckForSnipableTH() Town Hall level " & $thLevel & " found on North corner at " & $x & ", " & $y & " Snipable!" & @CRLF)
	  $THCorner = "North"
	  Return $eAutoExecuteSnipe
   ElseIf DistBetweenTwoPoints($x, $y, $gEastPoint[0], $gEastPoint[1]) <= $gTHSnipeMaxDistFromCorner Then
	  DebugWrite("CheckForSnipableTH() Town Hall level " & $thLevel & " found on East corner at " & $x & ", " & $y & " Snipable!" & @CRLF)
	  $THCorner = "East"
	  Return $eAutoExecuteSnipe
   ElseIf DistBetweenTwoPoints($x, $y, $gWestPoint[0], $gWestPoint[1]) <= $gTHSnipeMaxDistFromCorner Then
	  DebugWrite("CheckForSnipableTH() Town Hall level " & $thLevel & " found on West corner at " & $x & ", " & $y & " Snipable!" & @CRLF)
	  $THCorner = "West"
	  Return $eAutoExecuteSnipe
   ElseIf DistBetweenTwoPoints($x, $y, $gSouthPoint[0], $gSouthPoint[1]) <= $gTHSnipeMaxDistFromCorner Then
	  DebugWrite("CheckForSnipableTH() Town Hall level " & $thLevel & " found on South corner at " & $x & ", " & $y & " Snipable!" & @CRLF)
	  $THCorner = "South"
	  Return $eAutoExecuteSnipe
   EndIf

   DebugWrite("CheckForSnipableTH() Town Hall level " & $thLevel & " found at " & $x & ", " & $y & ". Not snipable. Dist:" & _
	  " North=" & Int(DistBetweenTwoPoints($x, $y, $gNorthPoint[0], $gNorthPoint[1])) & _
	  ", East=" & Int(DistBetweenTwoPoints($x, $y, $gEastPoint[0], $gEastPoint[1])) & _
	  ", West=" & Int(DistBetweenTwoPoints($x, $y, $gWestPoint[0], $gWestPoint[1])) & _
	  ", South=" & Int(DistBetweenTwoPoints($x, $y, $gSouthPoint[0], $gSouthPoint[1])))

   Return False
EndFunc


Func THSnipeExecute(ByRef $hBMP, Const $THCorner)
   ;DebugWrite("THSnipeExecute()")

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

   Local $barbButton[4] = [$troopIndex[$eTroopBarbarian][0], $troopIndex[$eTroopBarbarian][1], $troopIndex[$eTroopBarbarian][2], $troopIndex[$eTroopBarbarian][3]]
   Local $archButton[4] = [$troopIndex[$eTroopArcher][0], $troopIndex[$eTroopArcher][1], $troopIndex[$eTroopArcher][2], $troopIndex[$eTroopArcher][3]]
   Local $kingButton[4] = [$troopIndex[$eTroopKing][0], $troopIndex[$eTroopKing][1], $troopIndex[$eTroopKing][2], $troopIndex[$eTroopKing][3]]
   Local $queenButton[4] = [$troopIndex[$eTroopQueen][0], $troopIndex[$eTroopQueen][1], $troopIndex[$eTroopQueen][2], $troopIndex[$eTroopQueen][3]]
   Local $wardenButton[4] = [$troopIndex[$eTroopWarden][0], $troopIndex[$eTroopWarden][1], $troopIndex[$eTroopWarden][2], $troopIndex[$eTroopWarden][3]]

   ; Make sure something bad hasn't happened
   _WinAPI_DeleteObject($hBMP)
   $hBMP = CaptureFrameHBITMAP("THSnipeExecute1")
   If WhereAmI($hBMP)<>$eScreenWaitRaid And WhereAmI($hBMP)<>$eScreenLiveRaid Then
	  DebugWrite("THSnipeExecute() Not on wait raid or live raid screen, resetting.")
	  Return False
   EndIf

   ; Try deploying heroes first, immediately power them up
   Local $kingDeployed=False, $queenDeployed=False, $wardenDeployed=False
   ; Deploy King
   If $troopIndex[$eTroopKing][4]>0 Then
	  DebugWrite("THSnipeExecute() Deploying Barbarian King.")
	  RandomWeightedClick($kingButton)
	  Sleep(200)

	  THSnipeClickCorner($THCorner)
	  Sleep(200)
	  $kingDeployed = True
   EndIf

   ; Was the Auto check box unticked?
   If _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED Then Return False

   ; Deploy Queen
   If $troopIndex[$eTroopQueen][4] > 0 Then
	  DebugWrite("THSnipeExecute() Deploying Archer Queen.")
	  RandomWeightedClick($queenButton)
	  Sleep(200)

	  THSnipeClickCorner($THCorner)
	  Sleep(200)
	  $queenDeployed = True
   EndIf

   ; Was the Auto check box unticked?
   If _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED Then Return False

   ; Deploy Warden
   If $troopIndex[$eTroopWarden][4] > 0 And ($kingDeployed Or $queenDeployed) Then
	  DebugWrite("THSnipeExecute() Deploying Grand Warden.")
	  RandomWeightedClick($wardenButton)
	  Sleep(200)

	  THSnipeClickCorner($THCorner)
	  Sleep(200)
	  $wardenDeployed = True
   EndIf

   ; Was the Auto check box unticked?
   If _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED Then Return False

   ; Make sure something bad hasn't happened
   _WinAPI_DeleteObject($hBMP)
   $hBMP = CaptureFrameHBITMAP("THSnipeExecute2")
   If WhereAmI($hBMP)<>$eScreenWaitRaid And WhereAmI($hBMP)<>$eScreenLiveRaid Then
	  DebugWrite("THSnipeExecute() Not on wait raid or live raid screen, resetting.")
	  Return False
   EndIf

   ; Power up heroes
   If $troopIndex[$eTroopKing][4]>0 And $kingDeployed Then
	  DebugWrite("THSnipeExecute() Powering up Barbarian King.")
	  RandomWeightedClick($kingButton)
	  Sleep(200)
   EndIf

   If $troopIndex[$eTroopQueen][4]>0 And $queenDeployed Then
	  DebugWrite("THSnipeExecute() Powering up Archer Queen.")
	  RandomWeightedClick($queenButton)
	  Sleep(200)
   EndIf

   If $troopIndex[$eTroopWarden][4]>0 And $wardenDeployed Then
	  DebugWrite("THSnipeExecute() Powering up Grand Warden.")
	  RandomWeightedClick($wardenButton)
	  Sleep(200)
   EndIf

   ; Was the Auto check box unticked?
   If _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED Then Return False

   ; Wait for 21 seconds and see if heroes take care of the TH
   If $kingDeployed Or $queenDeployed Or $wardenDeployed Then
	  If WaitForColor($hBMP, 21000, $rFirstStarColor) = True Then
		 DebugWrite("THSnipeExecute() Star detected, ending battle")

		 AutoRaidEndBattle($hBMP)
		 WaitForBattleEnd($hBMP, True, True, True)

		 Return True
	  EndIf
   EndIf

   ; Was the Auto check box unticked?
   If _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED Then Return False


   ; If heroes didn't take care of it, then send barchers in waves, check star color region for success
   Local $waveDelay = 17000
   Local $waveTroopsBarb = 20
   Local $waveTroopsArch = 10
   Local $waveCount = 0

   ; Loop until we get a star
   While IsColorPresent($hBMP, $rFirstStarColor) = False
	  $waveCount+=1
	  DebugWrite("THSnipeExecute() Town hall snipe, wave " & $waveCount)

	  Local $availableBarbs = $troopIndex[$eTroopBarbarian][4]
	  Local $availableArchs = $troopIndex[$eTroopArcher][4]
	  DebugWrite("THSnipeExecute() Troops available: Barbarians=" & $availableBarbs & " Archers=" & $availableArchs)

	  ; Was the Auto check box unticked?
	  If _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED Then Return False

	  ; Make sure something bad hasn't happened
	  If WhereAmI($hBMP)<>$eScreenWaitRaid And WhereAmI($hBMP)<>$eScreenLiveRaid Then
		 DebugWrite("THSnipeExecute() Not on wait raid or live raid screen, resetting.")
		 Return False
	  EndIf

	  ; Deploy barbs to boxes
	  If $availableBarbs>0 Then
		 Local $c = $waveTroopsBarb + Random(1, 5, 1)
		 Local $deployAmount = ($availableBarbs<=$c ? $availableBarbs : $c)
		 DebugWrite("THSnipeExecute() Deploying " & $deployAmount & " barbarians.")

		 RandomWeightedClick($barbButton)
		 Sleep(500)

		 For $i = 0 To $deployAmount-1
			THSnipeClickCorner($THCorner)
		 Next
	  EndIf
	  Sleep(500)

	  ; Get new frame and check for star
	  _WinAPI_DeleteObject($hBMP)
	  $hBMP = CaptureFrameHBITMAP("THSnipeExecute1")
	  If IsColorPresent($hBMP, $rFirstStarColor) = True Then ExitLoop

	  ; Was the Auto check box unticked?
	  If _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED Then Return False

	  ; Deploy archers to boxes
	  If $availableArchs>0 Then
		 Local $c = $waveTroopsArch + Random(1, 5, 1)
		 Local $deployAmount = ($availableArchs<=$c ? $availableArchs : $c)
		 DebugWrite("THSnipeExecute() Deploying " & $deployAmount & " archers.")

		 RandomWeightedClick($archButton)
		 Sleep(500)

		 For $i = 0 To $deployAmount-1
			THSnipeClickCorner($THCorner)
		 Next
	  EndIf
	  Sleep(500)

	  ; Get new frame and check for star
	  _WinAPI_DeleteObject($hBMP)
	  $hBMP = CaptureFrameHBITMAP("THSnipeExecute2")
	  If IsColorPresent($hBMP, $rFirstStarColor) = True Then ExitLoop

	  ; Was the Auto check box unticked?
	  If _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED Then Return False

	  ; Get counts of available troops
	  UpdateRaidSlotCounts($troopIndex)

	  If $availableBarbs=0 And $availableArchs=0 Then ExitLoop

	  ; Wait for timer
	  Local $rand = Random(1000, 3000, 1)
	  If WaitForColor($hBMP, $waveDelay+$rand, $rFirstStarColor) = True Then ExitLoop
   WEnd

   ; End battle
   If $kingDeployed=True Or $queenDeployed=True Then
	  AutoRaidEndBattle($hBMP)
   EndIf

   WaitForBattleEnd($hBMP, False, False, False)
   Return True
EndFunc

Func THSnipeClickCorner(Const $THCorner)
   If $THCorner = "North" Then
	  ;DebugWrite("THSnipeClickCorner north box: " & $rTHSnipeNorthDeployBox[0] & " " & $rTHSnipeNorthDeployBox[1] & " " & $rTHSnipeNorthDeployBox[2] & " " & $rTHSnipeNorthDeployBox[3])
	  RandomWeightedClick($rTHSnipeNorthDeployBox)
   ElseIf $THCorner = "East" Then
	  ;DebugWrite("THSnipeClickCorner east box: " & $rTHSnipeEastDeployBox[0] & " " & $rTHSnipeEastDeployBox[1] & " " & $rTHSnipeEastDeployBox[2] & " " & $rTHSnipeEastDeployBox[3])
	  RandomWeightedClick($rTHSnipeEastDeployBox)
   ElseIf $THCorner = "West" Then
	  ;DebugWrite("THSnipeClickCorner west box: " & $rTHSnipeWestDeployBox[0] & " " & $rTHSnipeWestDeployBox[1] & " " & $rTHSnipeWestDeployBox[2] & " " & $rTHSnipeWestDeployBox[3])
	  RandomWeightedClick($rTHSnipeWestDeployBox)
   ElseIf $THCorner = "South" Then
	  ;DebugWrite("THSnipeClickCorner south box: " & $rTHSnipeSouthDeployBox[0] & " " & $rTHSnipeSouthDeployBox[1] & " " & $rTHSnipeSouthDeployBox[2] & " " & $rTHSnipeSouthDeployBox[3])
	  RandomWeightedClick($rTHSnipeSouthDeployBox)
   EndIf

   Sleep($gDeployTroopClickDelay)
EndFunc

