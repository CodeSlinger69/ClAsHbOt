Func AutoPush(ByRef $timer, ByRef $THCorner)
   ;DebugWrite("AutoPush()")

   If $gAutoSnipeNotifyOnly Then
	  $gAutoStage = $eAutoFindMatch
	  DebugWrite("Auto Push, notify mode")
   EndIf

   Switch $gAutoStage

   ; Stage Queue Training
   Case $eAutoQueueTraining
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Queue Training")

	  ResetToCoCMainScreen()

	  AutoQueueTroops(True)
	  $timer = TimerInit()

   ; Stage Wait For Training To Complete
   Case $eAutoWaitForTrainingToComplete

	  If TimerDiff($timer) >= $gTroopTrainingCheckInterval Then
		 ResetToCoCMainScreen()
		 AutoQueueTroops(False)
		 $timer = TimerInit()
	  EndIf

   ; Stage Find Match
   Case $eAutoFindMatch
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Find Snipable TH")

	  Local $findMatchResults = THSnipeFindMatch($THCorner)

	  ; Reset if there was an error
	  If $findMatchResults=False Then
		 DebugWrite("Auto: Error finding match, resetting.")
		 ResetToCoCMainScreen()
		 $gAutoStage = $eAutoQueueTraining
		 Return
	  EndIf

	  ; Did we find a snipable base?
	  If $findMatchResults = $eAutoExecuteSnipe And $gAutoSnipeNotifyOnly Then
		 For $i = 1 To 5
			Beep(500, 200)
			Sleep(100)
		 Next

		 MsgBox($MB_OK, "Snipable TH!", "")
		 Return
	  EndIf

	  If $findMatchResults = $eAutoExecuteSnipe Then $gAutoStage = $eAutoExecuteSnipe

   ; Stage Execute TH Snipe to Push
   Case $eAutoExecuteSnipe
	  GUICtrlSetData($GUI_AutoStatus, "Auto: Execute Snipe")
	  THSnipeExecute($THCorner)
	  $gAutoStage = $eAutoQueueTraining
	  UpdateWinnings()

	  GUICtrlSetData($GUI_AutoStatus, "Auto: Snipe Complete")

   EndSwitch

EndFunc

Func THSnipeFindMatch(ByRef $THCorner)
   DebugWrite("AutoPushFindMatch()")

   ; Make sure we are on the main screen
   If WhereAmI() <> $eScreenMain Then
	  DebugWrite("Find Snipable TH failed - not on main screen")
	  Return False
   EndIf

   ; Click Attack
   RandomWeightedClick($rMainScreenAttackButton)

   ; Wait for Find a Match button
   Local $failCount = 10
   While IsButtonPresent($rFindMatchScreenFindAMatchNoShieldButton)=False And _
	  IsButtonPresent($rFindMatchScreenFindAMatchWithShieldButton)=False And _
	  $failCount>0

	  Sleep(1000)
	  $failCount -= 1
   WEnd

   If $failCount = 0 Then
	  DebugWrite("Find Snipable TH failed - timeout waiting for Find a Match button")
	  ResetToCoCMainScreen()
	  Return False
   EndIf

   ; Click Find a Match
   If IsButtonPresent($rFindMatchScreenFindAMatchNoShieldButton) Then
	  RandomWeightedClick($rFindMatchScreenFindAMatchNoShieldButton)
   Else
	  RandomWeightedClick($rFindMatchScreenFindAMatchWithShieldButton)
   EndIf

   ; Wait for Next button
   $failCount = 30
   While IsButtonPresent($rWaitRaidScreenNextButton) = False And _
	  IsButtonPresent($rAndroidMessageButton1) = False And _
	  IsButtonPresent($rAndroidMessageButton2) = False And _
	  AttackingIsDisabled() = False And _
	  $failCount>0

	  Sleep(1000)
	  $failCount -= 1
   WEnd

    If AttackingIsDisabled() Then
	  DebugWrite("Find Match failed (AS1) - Attacking is Disabled")
	  ResetToCoCMainScreen()

	  $gPossibleKick = 2
	  $gLastPossibleKickTime = TimerInit()

	  Return False
   EndIf

   If $failCount = 0 Then
	  DebugWrite("Find Match failed (AS1) - timeout waiting for Wait Raid screen")
	  ResetToCoCMainScreen()

	  If $gPossibleKick < 2 Then
		 $gPossibleKick+=1
		 DebugWrite("Possible kick detected, count = " & $gPossibleKick)
	  EndIf

	  If $gPossibleKick = 2 Then
		 $gLastPossibleKickTime = TimerInit()
	  EndIf

	  Return False
   EndIf

   ; Loop with Next until we find a snipable TH
   While 1
	  If _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox) = $BST_UNCHECKED Then Return False

	  ; Update my loot status on GUI
	  GetMyLootNumbers()

	  ; If snipable, then go do it
	  Local $thLevel, $thLeft, $thTop, $gold, $elix, $dark, $cups, $deadBase
	  AutoRaidGetDisplayedLoot($thLevel, $thLeft, $thTop, $gold, $elix, $dark, $cups, $deadbase)

	  If CheckForSnipableTH($THCorner, $thLevel, $thLeft, $thTop, $gold, $elix, $dark, $cups, $deadbase) Then
		 Return True
	  EndIf

	  ; Not snipable - click Next
	  Sleep($gPauseBetweenNexts)
	  RandomWeightedClick($rWaitRaidScreenNextButton)
	  Sleep(500)

	  ; Sleep and wait for Next button to reappear
	  $failCount = 30
	  While IsButtonPresent($rWaitRaidScreenNextButton) = False And _
		    IsButtonPresent($rAndroidMessageButton1) = False And _
		    IsButtonPresent($rAndroidMessageButton2) = False And _
			AttackingIsDisabled() = False And _
			$failCount>0

		 Sleep(1000)
		 $failCount -= 1
	  WEnd

	  If AttackingIsDisabled() Then
		 DebugWrite("Find Match failed (AS2) - Attacking is Disabled")
		 If WhereAmI() = $eScreenWaitRaid Then
			RandomWeightedClick($rLiveRaidScreenEndBattleButton)
			Sleep(500)
		 Else
			ResetToCoCMainScreen()
		 EndIf

		 $gPossibleKick = 2
		 $gLastPossibleKickTime = TimerInit()

		 Return False
	  EndIf

	  If $failCount = 0 Or IsButtonPresent($rAndroidMessageButton1) Or IsButtonPresent($rAndroidMessageButton2) Then
		 If $failCount = 0 Then
			DebugWrite("Find Match failed (AS2) - timeout waiting for Wait Raid screen")
		 Else
			DebugWrite("Find Match failed (AS2) - Android message box popup")
		 EndIf

		 If $gPossibleKick < 2 Then
			$gPossibleKick+=1
			DebugWrite("Possible kick detected, count = " & $gPossibleKick)
		 EndIf

		 If $gPossibleKick > 0 Then
			$gLastPossibleKickTime = TimerInit()
		 EndIf

		 ResetToCoCMainScreen()

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

Func THSnipeExecute(Const $THCorner)
   ;DebugWrite("THSnipeExecute()")

   ; What troops are available?
   Local $troopIndex[$eTroopCount][5]
   FindRaidTroopSlots($gTroopSlotBMPs, $troopIndex)
   UpdateRaidTroopCounts($troopIndex)

   Local $barbButton[4] = [$troopIndex[$eTroopBarbarian][0], $troopIndex[$eTroopBarbarian][1], $troopIndex[$eTroopBarbarian][2], $troopIndex[$eTroopBarbarian][3]]
   Local $archButton[4] = [$troopIndex[$eTroopArcher][0], $troopIndex[$eTroopArcher][1], $troopIndex[$eTroopArcher][2], $troopIndex[$eTroopArcher][3]]
   Local $kingButton[4] = [$troopIndex[$eTroopKing][0], $troopIndex[$eTroopKing][1], $troopIndex[$eTroopKing][2], $troopIndex[$eTroopKing][3]]
   Local $queenButton[4] = [$troopIndex[$eTroopQueen][0], $troopIndex[$eTroopQueen][1], $troopIndex[$eTroopQueen][2], $troopIndex[$eTroopQueen][3]]
   Local $wardenButton[4] = [$troopIndex[$eTroopWarden][0], $troopIndex[$eTroopWarden][1], $troopIndex[$eTroopWarden][2], $troopIndex[$eTroopWarden][3]]

   If WhereAmI()<>$eScreenWaitRaid And WhereAmI()<>$eScreenLiveRaid Then
	  DebugWrite("THSnipeExecute() Not on wait raid or live raid screen, resetting.")
	  ResetToCoCMainScreen()
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

   If _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox)=$BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED Then Return False

   ; Deploy Queen
   If $troopIndex[$eTroopQueen][4] > 0 Then
	  DebugWrite("THSnipeExecute() Deploying Archer Queen.")
	  RandomWeightedClick($queenButton)
	  Sleep(200)

	  THSnipeClickCorner($THCorner)
	  Sleep(200)
	  $queenDeployed = True
   EndIf

   If _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox)=$BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED Then Return False

   ; Deploy Warden
   If $troopIndex[$eTroopWarden][4] > 0 And ($kingDeployed Or $queenDeployed) Then
	  DebugWrite("THSnipeExecute() Deploying Grand Warden.")
	  RandomWeightedClick($wardenButton)
	  Sleep(200)

	  THSnipeClickCorner($THCorner)
	  Sleep(200)
	  $wardenDeployed = True
   EndIf

   If _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox)=$BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED Then Return False

   If WhereAmI()<>$eScreenWaitRaid And WhereAmI()<>$eScreenLiveRaid Then
	  DebugWrite("THSnipeExecute() Not on wait raid or live raid screen, resetting.")
	  ResetToCoCMainScreen()
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

   If _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox)=$BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED Then Return False

   ; Wait for 15 seconds and see if heroes take care of the TH
   If $troopIndex[$eTroopKing][4]>0 Or $troopIndex[$eTroopQueen][4]>0 Or $troopIndex[$eTroopWarden][4]>0 Then
	  Local $t = TimerInit()
	  Local $ctdn = 0
	  While 1
		 If IsColorPresent($rFirstStarColor) = True Then
			DebugWrite("THSnipeExecute() Exiting hero wait loop: star present")
			ExitLoop
		 EndIf

		 If TimerDiff($t)>21000 Then
			DebugWrite("THSnipeExecute() Exiting hero wait loop: 21 secs expired")
			ExitLoop
		 EndIf

		 ;Local $n = Int(TimerDiff($t)/1000)
		 ;If $n <> $ctdn Then
			;$ctdn=$n
			;DebugWrite(21-$ctdn)
		 ;EndIf
		 Sleep(200)
	  WEnd

	  If WhereAmI()<>$eScreenWaitRaid And WhereAmI()<>$eScreenLiveRaid Then
		 DebugWrite("THSnipeExecute() Not on wait raid or live raid screen, resetting.")
		 ResetToCoCMainScreen()
		 Return False
	  EndIf

	  If IsColorPresent($rFirstStarColor) = True Then
		 ; End Battle
		 RandomWeightedClick($rLiveRaidScreenEndBattleButton)

		 Local $t=TimerInit()
		 While IsButtonPresent($rLiveRaidScreenEndBattleConfirmButton) = False And TimerDiff($t)<2000
			Sleep(50)
		 WEnd

		 If IsButtonPresent($rLiveRaidScreenEndBattleConfirmButton) Then
			RandomWeightedClick($rLiveRaidScreenEndBattleConfirmButton)
			Sleep(1000)
		 EndIf

		 WaitForBattleEnd(True, True, True)

		 Return True
	  EndIf
   EndIf

   If _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox)=$BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED Then Return False


   ; If heroes didn't take care of it, then send barchers in waves, check star color region for success
   Local $waveDelay = 17000
   Local $waveTroopsBarb = 20
   Local $waveTroopsArch = 10
   Local $waveCount = 0

   While IsColorPresent($rFirstStarColor) = False
	  Local $waveTimer = TimerInit()
	  $waveCount+=1
	  DebugWrite("THSnipeExecute() Town hall snipe, wave " & $waveCount)

	  Local $availableBarbs = $troopIndex[$eTroopBarbarian][4]
	  Local $availableArchs = $troopIndex[$eTroopArcher][4]
	  DebugWrite("THSnipeExecute() Troops available: Barbarians=" & $availableBarbs & " Archers=" & $availableArchs)

	  If _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox)=$BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED Then Return False

	  If WhereAmI()<>$eScreenWaitRaid And WhereAmI()<>$eScreenLiveRaid Then
		 DebugWrite("THSnipeExecute() Not on wait raid or live raid screen, resetting.")
		 ResetToCoCMainScreen()
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

	  If IsColorPresent($rFirstStarColor) = True Then ExitLoop

	  If _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox)=$BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED Then Return False

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

	  If IsColorPresent($rFirstStarColor) = True Then ExitLoop

	  If _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox)=$BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED Then Return False

	  ; Get counts of available troops
	  UpdateRaidTroopCounts($troopIndex)

	  If $availableBarbs=0 And $availableArchs=0 Then ExitLoop

	  ; Wait for timer
	  Local $rand = Random(1000, 3000, 1)
	  While TimerDiff($waveTimer) < $waveDelay+$rand
		 If _GUICtrlButton_GetCheck($GUI_AutoPushCheckBox) = $BST_UNCHECKED And _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED Then Return False
		 If IsColorPresent($rFirstStarColor) = True Then ExitLoop 2
		 Sleep(200)
	  WEnd

   WEnd

   If WhereAmI()<>$eScreenWaitRaid And WhereAmI()<>$eScreenLiveRaid Then
	  DebugWrite("THSnipeExecute() Not on wait raid or live raid screen, resetting.")
	  ResetToCoCMainScreen()
	  Return False
   EndIf

   ; End battle
   If $kingDeployed=True Or $queenDeployed=True Then
	  ; End battle
	  RandomWeightedClick($rLiveRaidScreenEndBattleButton)

	  Local $t=TimerInit()
	  While IsButtonPresent($rLiveRaidScreenEndBattleConfirmButton) = False And TimerDiff($t)<2000
		 Sleep(50)
	  WEnd

	  If IsButtonPresent($rLiveRaidScreenEndBattleConfirmButton) Then
		 RandomWeightedClick($rLiveRaidScreenEndBattleConfirmButton)
		 Sleep(1000)
	  EndIf
   EndIf

   ; Wait for end battle
   WaitForBattleEnd(False, False, False)

   Return True
EndFunc

Func THSnipeClickCorner(Const $THCorner)
   If $THCorner = "North" Then
	  RandomWeightedClick($rTHSnipeNorthDeployBox)
   ElseIf $THCorner = "East" Then
	  RandomWeightedClick($rTHSnipeEastDeployBox)
   ElseIf $THCorner = "West" Then
	  RandomWeightedClick($rTHSnipeWestDeployBox)
   ElseIf $THCorner = "South" Then
	  RandomWeightedClick($rTHSnipeSouthDeployBox)
   EndIf

   Sleep($gDeployTroopClickDelay)
EndFunc

