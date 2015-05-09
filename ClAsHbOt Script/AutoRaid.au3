Func AutoRaid(ByRef $timer)
   ;DebugWrite("AutoRaid()")

   Switch $gAutoRaidStage

   ; Stage Queue Training
   Case $eAutoRaidQueueTraining
	  GUICtrlSetData($GUI_AutoRaid, "Auto Raid: Queue Training")

	  ResetToCoCMainScreen()

	  AutoRaidQueueTraining()
	  $timer = TimerInit()

   ; Stage Wait For Training To Complete
   Case $eAutoRaidWaitForTrainingToComplete

	  If TimerDiff($timer) >= $gTroopTrainingCheckInterval Then
		 ResetToCoCMainScreen()
		 AutoRaidCheckIfTrainingComplete()
		 $timer = TimerInit()
	  EndIf

   ; Stage Find Match
   Case $eAutoRaidFindMatch
	  Local $findMatchResults = FindAValidMatch()

	  If $findMatchResults = $eAutoRaidExecuteRaid Then
		 $gAutoRaidStage = $eAutoRaidExecuteRaid
		 GUICtrlSetData($GUI_AutoRaid, "Auto Raid: Execute Raid")

	  ElseIf $findMatchResults = $eAutoRaidExecuteDEZap Then
		 $gAutoRaidStage = $eAutoRaidExecuteDEZap
		 GUICtrlSetData($GUI_AutoRaid, "Auto Raid: Execute DE Zap")

	  EndIf

   ; Stage Execute DE Zap
   Case $eAutoRaidExecuteDEZap
	  If AutoRaidExecuteDEZap() = True Then
		 $gAutoRaidStage = $eAutoRaidQueueTraining
		 GUICtrlSetData($GUI_AutoRaid, "Auto Raid: DE Zap Complete")
		 AutoRaidUpdateProgress()

	  Else
		 ResetToCoCMainScreen()
		 $gAutoRaidStage = $eAutoRaidFindMatch
		 GUICtrlSetData($GUI_AutoRaid, "Auto Raid: Find Match")

	  EndIf

   ; Stage Execute Raid
   Case $eAutoRaidExecuteRaid
	  Switch _GUICtrlComboBox_GetCurSel($GUI_AutoRaidStrategyCombo)
	  Case 0
		 If AutoRaidExecuteRaidStrategy0() Then
			$gAutoRaidStage = $eAutoRaidQueueTraining
			GUICtrlSetData($GUI_AutoRaid, "Auto Raid: Raid Complete")
			AutoRaidUpdateProgress()
		 EndIf
	  Case 1
		 ContinueCase
	  Case 2
		 ContinueCase
	  Case 3
		 GUICtrlSetData($GUI_AutoRaid, "Auto Raid: Unimplemented strategy")
		 MsgBox($MB_OK, "Unimplemented strategy", "This strategy has not yet been implemented")
	  EndSwitch

   EndSwitch
EndFunc

Func AutoRaidUpdateProgress()
   GetMyLootNumbers()

   $gAutoRaidEndLoot[0] = GUICtrlRead($GUI_MyGold)
   $gAutoRaidEndLoot[1] = GUICtrlRead($GUI_MyElix)
   $gAutoRaidEndLoot[2] = GUICtrlRead($GUI_MyDark)
   $gAutoRaidEndLoot[3] = GUICtrlRead($GUI_MyCups)

   DebugWrite(" AutoRaid Change: " & _
	  " Gold:" & $gAutoRaidEndLoot[0] - $gAutoRaidBeginLoot[0] & _
	  " Elix:" & $gAutoRaidEndLoot[1] - $gAutoRaidBeginLoot[1] & _
	  " Dark:" & $gAutoRaidEndLoot[2] - $gAutoRaidBeginLoot[2] & _
	  " Cups:" & $gAutoRaidEndLoot[3] - $gAutoRaidBeginLoot[3] & @CRLF)
EndFunc

Func AutoRaidQueueTraining()
   DebugWrite("AutoRaidQueueTraining()")

   OpenBarracksWindow()
   If WhereAmI() <> $eScreenTrainTroops Then
	  ResetToCoCMainScreen()
	  Return
   EndIf

   ; See if we have a red stripe on the bottom of the train troops window, and move to next stage
   Local $redStripe = IsColorPresent($rWindowBarracksFullColor)
   If $redStripe Then DebugWrite("Barracks full, moving immediately to next auto raid stage.")

   ; Get spells window
   If FindSpellsQueueingWindow() = False Then
	 DebugWrite(" Auto Raid, Queue Troops failed - can't find Spells or Dark window")
	 ResetToCoCMainScreen()
	 Return
   EndIf

   ; Queue spells?
   QueueSpells()

   Switch _GUICtrlComboBox_GetCurSel($GUI_AutoRaidStrategyCombo)
   Case 0
	  FillBarracksAutoRaidStrategy0(Not($redStripe))
   Case 1
	  ContinueCase
   Case 2
	  ContinueCase
   Case 3
	  ContinueCase
   EndSwitch

   CloseBarracksWindow()

   If $redStripe Then
	  $gAutoRaidStage = $eAutoRaidFindMatch
	  GUICtrlSetData($GUI_AutoRaid, "Auto Raid: Find Match")

   Else
      $gAutoRaidStage = $eAutoRaidWaitForTrainingToComplete
	  GUICtrlSetData($GUI_AutoRaid, "Auto Raid: Waiting For Training (0:00)")

   EndIf
EndFunc

Func AutoRaidCheckIfTrainingComplete()
   DebugWrite("AutoRaidCheckIfTrainingComplete()")

   OpenBarracksWindow()

   If WhereAmI() <> $eScreenTrainTroops Then
	  ResetToCoCMainScreen()
	  Return
   EndIf

   ; See if we have a red stripe on the bottom of the train troops window, which means we are full up
   If IsColorPresent($rWindowBarracksFullColor) Then
	  ;DebugWrite("Troop training is complete!")
	  $gAutoRaidStage = $eAutoRaidFindMatch
  	  GUICtrlSetData($GUI_AutoRaid, "Auto Raid: Find Match")

   Else
	  ; Top off the barracks queues
	  If FindSpellsQueueingWindow() = False Then
		DebugWrite(" Auto Raid, Queue Troops failed - can't find Spells or Dark window")
		ResetToCoCMainScreen()
		Return
	  EndIf

	  QueueSpells()

	  Switch _GUICtrlComboBox_GetCurSel($GUI_AutoRaidStrategyCombo)
	  Case 0
		 FillBarracksAutoRaidStrategy0(False)
	  Case 1
		 ContinueCase
	  Case 2
		 ContinueCase
	  Case 3
		 ContinueCase
	  EndSwitch
   EndIf

   CloseBarracksWindow()
EndFunc

Func QueueSpells()
   ; If not spells queueing window, then return
   If IsColorPresent($rWindowBarracksSpellsColor1) <> True And IsColorPresent($rWindowBarracksSpellsColor2) <> True Then
	  Return
   EndIf

   ; maybe queue spells?
   If _GUICtrlButton_GetCheck($GUI_AutoRaidZapDE) = $BST_CHECKED Then

	  ; Get count
	  Local $spellSlots[$eSpellCount][4]
	  FindBarracksTroopSlots($gBarracksSpellSlotBMPs, $spellSlots)

	  ; How many are queued/created?
	  Local $queueStatus = ScrapeFuzzyText($gLargeCharacterMaps, $rBarracksWindowTextBox, $gLargeCharMapsMaxWidth, $eScrapeDropSpaces)
	  ;DebugWrite("$queueStatus: " & $queueStatus)

	  If (StringInStr($queueStatus, "CreateSpells")=1) Then
		 $queueStatus = StringMid($queueStatus, 13)

		 Local $queueStatSplit = StringSplit($queueStatus, "/")
		 If $queueStatSplit[0] = 2 Then
			Local $spellsToFill = Number($queueStatSplit[2]) - Number($queueStatSplit[1])
			DebugWrite("Spells queued / available = " & Number($queueStatSplit[1]) & " / " & Number($queueStatSplit[2]))

			$gMyMaxSpells = Number($queueStatSplit[2]) ; Used when deciding to DE Zap or not

			Local $lightningButton[4] = [$spellSlots[$eSpellLightning][0], $spellSlots[$eSpellLightning][1], _
									     $spellSlots[$eSpellLightning][2], $spellSlots[$eSpellLightning][3]]
			For $i = 1 To $spellsToFill
			   RandomWeightedClick($lightningButton)
			   Sleep($gDeployTroopClickDelay)
			Next
		 EndIf
	  EndIf
   EndIf
EndFunc

; howMany: $eAutoRaidDeploySixtyPercent, $eAutoRaidDeployRemaining, $eAutoRaidDeployOneTroop
Func DeployTroopsToSides(Const $troop, Const ByRef $index, Const $howMany, Const $dir)
   DebugWrite("DeployTroopsToSides()")
   Local $xClick, $yClick

   ; Handle the deploy one troop situation first
   If $howMany=$eAutoRaidDeployOneTroop Then
	  RandomWeightedCoords( ($dir = "Top" ? $NWSafeDeployBox : $SWSafeDeployBox), $xClick, $yClick)
	  _MouseClickFast($xClick, $yClick)
	  Return
   EndIf

   ; Do initial deployment
   Local $troopsAvailable = GetAvailableTroops($troop, $index)
   If $howMany=$eAutoRaidDeploySixtyPercent Then $troopsAvailable = Int($troopsAvailable * 0.6)
   ;DebugWrite("DeployTroopsToSides: " & ($howMany=$deploySixtyPercent ? "60% " : "Remaining ") & $troopsAvailable)

   Local $clickPoints1[$troopsAvailable][2]
   ; Always deploy first set of troops left to right to avoid accidentally clicking the Next button
   GetRandomSortedClickPoints(0, $dir, $troopsAvailable, $clickPoints1)

   For $i = 0 To $troopsAvailable-1
	  _MouseClickFast($clickPoints1[$i][0], $clickPoints1[$i][1])
	  Sleep($gDeployTroopClickDelay)
   Next

   ; If we are only deploying 60% then we are done
   If $howMany=$eAutoRaidDeploySixtyPercent Then Return

   ; If we are deploying all, then check remaining and continue to deploy to make sure they all get out there
   $troopsAvailable = GetAvailableTroops($troop, $index)

   If $troopsAvailable>0 Then
	  ;DebugWrite("DeployTroopsToSides: Continuing " & $troopsAvailable & " remaining")
	  Local $clickPoints2[$troopsAvailable][2]
	  GetRandomSortedClickPoints(Random(0,1,1), $dir, $troopsAvailable, $clickPoints2)

	  For $i = 0 To $troopsAvailable-1
		 _MouseClickFast($clickPoints2[$i][0], $clickPoints2[$i][1])
		 Sleep($gDeployTroopClickDelay)
	  Next
   EndIf

   $troopsAvailable = GetAvailableTroops($troop, $index)

   If $troopsAvailable>0 Then DeployTroopsToSafeBoxes($troop, $index, $dir)
EndFunc

Func DeployTroopsToSafeBoxes(Const $troop, Const ByRef $index, Const $dir)
   DebugWrite("DeployTroopsToSafeBoxes()")
   Local $xClick, $yClick, $count

   ; Deploy half to left
   Local $troopsAvailable = Int(GetAvailableTroops($troop, $index) / 2)
   ;DebugWrite("DeployTroopsToSafeBoxes, to left: " & $troopsAvailable)
   $count=0
   For $i = 1 To $troopsAvailable
	  RandomWeightedCoords( ($dir = "Top" ? $NWSafeDeployBox : $SWSafeDeployBox), $xClick, $yClick)
	  _MouseClickFast($xClick, $yClick)
	  Sleep($gDeployTroopClickDelay)
	  $count+=1
   Next

   ; Deploy half to right
   $troopsAvailable = GetAvailableTroops($troop, $index)
   ;DebugWrite("DeployTroopsToSafeBoxes, to right: " & $troopsAvailable)
   $count=0
   For $i = 1 To $troopsAvailable
   	  RandomWeightedCoords( ($dir = "Top" ? $NESafeDeployBox : $SESafeDeployBox), $xClick, $yClick)
	  _MouseClickFast($xClick, $yClick)
	  Sleep($gDeployTroopClickDelay)
	  $count+=1
   Next
EndFunc

Func LocateCollectors(ByRef $matchX, ByRef $matchY)
   DebugWrite("LocateCollectors()")

   ; Move screen up 65 pixels
   MoveScreenUpToCenter(65)

   ; Grab frame
   GrabFrameToFile("AutoRaidCollectorFrame.bmp")

   ; Find all the collectors that need clicking in the frame
   Local $matchCount = 0

   For $i = 0 To UBound($CollectorBMPs)-1
	  ; Get matches for this resource
	  Local $res = DllCall("ImageMatch.dll", "str", "FindAllMatches", "str", "AutoRaidCollectorFrame.bmp", _
			   "str", "Images\"&$CollectorBMPs[$i], "int", 3, "int", 6, "double", $gConfidenceCollector)
	  Local $split = StringSplit($res[0], "|", 2)
	  ;DebugWrite("Num matches " & $CollectorBMPs[$i] & ": " & $split[0])

	  For $j = 0 To $split[0]-1
		 ; Loop through all captured points so far, if this one is within 8 pix of an existing one,
		 ; then skip it.
		 Local $k, $alreadyFound = False
		 For $k = 0 To $matchCount-1
			If DistBetweenTwoPoints($split[$j*3+1], $split[$j*3+2], $matchX[$k], $matchY[$k]) < 8 Then
			   $alreadyFound = True
			   ;DebugWrite("    Already found " & $j & ": " & $split[$j*3+1] & "," & $split[$j*3+2] & "  " & $split[$j*3+3])
			   ExitLoop
			EndIf
		 Next

		 ; Otherwise add it to the growing list of matches, if it is $gConfidenceCollectorsSearch % or greater confidence
		 If $alreadyFound = False Then
			If $split[$j*3+3] > $gConfidenceCollector Then
			   ;DebugWrite("    Adding " & $j & ": " & $split[$j*3+1] & "," & $split[$j*3+2] & "  " & $split[$j*3+3])
			   $matchCount += 1
			   ReDim $matchX[$matchCount]
			   ReDim $matchY[$matchCount]
			   $matchX[$matchCount-1] = $split[$j*3+1]
			   $matchY[$matchCount-1] = $split[$j*3+2]
			EndIf
		 EndIf
	  Next
   Next

   ; Move screen back down 65 pixels
   MoveScreenDownToCenter(65)
EndFunc

Func GetRandomDeployBox(Const $direction, ByRef $box)
   Local $side = Random()>0.5 ? "Left" : "Right"
   Local $boxIndex = Random(0, 20, 1)

   If $direction = "Top" Then
	  For $j = 0 To 3
		 $box[$j] = ($side = "Left") ? $NWDeployBoxes[$boxIndex][$j] : $NEDeployBoxes[$boxIndex][$j]
	  Next
   Else
	  For $j = 0 To 3
		 $box[$j] = ($side = "Left") ? $SWDeployBoxes[$boxIndex][$j] : $SEDeployBoxes[$boxIndex][$j]
	  Next
   EndIf

EndFunc

Func GetRandomSortedClickPoints(Const $order, Const $topBotDirection, Const $numberPoints, ByRef $points)
   ; First parameter is 0 = ascending, 1 = descending
   For $i = 0 To $numberPoints-1
	  Local $deployBox[4]
	  GetRandomDeployBox($topBotDirection, $deployBox)
	  RandomCoords($deployBox, $points[$i][0], $points[$i][1])
   Next

   _ArraySort($points, $order)
EndFunc

Func WaitForBattleEnd(Const $kingDeployed, Const $queenDeployed)
   DebugWrite("WaitForBattleEnd()")
   ; Wait for battle end screen

   Local $lastGold = 0, $lastElix = 0, $lastDark = 0
   Local $activeTimer = TimerInit()
   Local $darkStorageZapped = False

   For $i = 1 To 180  ; 3 minutes max until battle end screen appears
	  If WhereAmI() = $eScreenEndBattle Then ExitLoop

	  ; Get available loot remaining
	  Local $goldRemaining = Number(ScrapeFuzzyText($gRaidLootCharMaps, $rGoldTextBox, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))
	  Local $elixRemaining = Number(ScrapeFuzzyText($gRaidLootCharMaps, $rElixTextBox, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))
	  Local $darkRemaining = Number(ScrapeFuzzyText($gRaidLootCharMaps, $rDarkTextBox, $gRaidLootCharMapsMaxWidth, $eScrapeDropSpaces))

	  ; If < 1 min is left, then zap DE if the option is selected
	  If _GUICtrlButton_GetCheck($GUI_AutoRaidZapDE) = $BST_CHECKED And _
		 $darkRemaining >= GUICtrlRead($GUI_AutoRaidZapDEMin) And _
		 $darkStorageZapped = False Then

		 Local $time = ScrapeFuzzyText($gExtraLargeCharacterMaps, $rBattleTimeRemainingTextBox, $gExtraLargeCharMapsMaxWidth, $eScrapeDropSpaces)
		 If StringLen($time)>0 And StringInStr($time, "m")=0 Then  ; len>0 because red text will return null string
			ZapDarkElixirStorage()
			$darkStorageZapped = True
		 EndIf
	  EndIf

	  ; If loot has changed, then reset timer
	  If $goldRemaining<>$lastGold Or $elixRemaining<>$lastElix Or $darkRemaining<>$lastDark Then
		 $lastGold = $goldRemaining
		 $lastElix = $elixRemaining
		 $lastDark = $darkRemaining
		 $activeTimer = TimerInit()
	  EndIf

	  ; If 30 seconds have passed, with no change in available loot, then exit battle, but only if we have not
	  ; deployed a king or queen
	  If TimerDiff($activeTimer) > 30000 And $kingDeployed = False And $queenDeployed = False Then
		 $activeTimer = TimerInit()
		 DebugWrite("No change in available loot for 30 seconds, ending battle.")

		 ; See if we should zap DE first
		 If _GUICtrlButton_GetCheck($GUI_AutoRaidZapDE) = $BST_CHECKED And _
			$darkRemaining >= GUICtrlRead($GUI_AutoRaidZapDEMin) And _
			$darkStorageZapped = False Then

			ZapDarkElixirStorage()
			$darkStorageZapped = True
		 EndIf

		 ; Click End Battle button
		 RandomWeightedClick($rLiveRaidScreenEndBattleButton)

		 ; Wait for confirmation button
		 Local $failCount=20
		 While IsButtonPresent($rLiveRaidScreenEndBattleConfirmButton)=False And $failCount>0
			Sleep(100)
			$failCount-=1
		 WEnd

		 If $failCount>0 Then
			RandomWeightedClick($rLiveRaidScreenEndBattleConfirmButton)
			Sleep(500)
		 EndIf
	  EndIf

	  Sleep(1000)
   Next

   Sleep(2000)

   If WhereAmI() = $eScreenEndBattle Then
	  GrabFrameToFile("EndBattleFrame.bmp")
	  Local $goldWin = ScrapeFuzzyText($gExtraLargeCharacterMaps, $rEndBattleGoldTextBox, $gExtraLargeCharMapsMaxWidth, $eScrapeDropSpaces)
	  Local $elixWin = ScrapeFuzzyText($gExtraLargeCharacterMaps, $rEndBattleElixTextBox, $gExtraLargeCharMapsMaxWidth, $eScrapeDropSpaces)
	  Local $darkWin = IsTextBoxPresent($rEndBattleDarkTextBox) ? ScrapeFuzzyText($gExtraLargeCharacterMaps, $rEndBattleDarkTextBox, $gExtraLargeCharMapsMaxWidth, $eScrapeDropSpaces) : 0
	  Local $cupsWin = IsTextBoxPresent($rEndBattleCups1TextBox) ? _
					   ScrapeFuzzyText($gExtraLargeCharacterMaps, $rEndBattleCups1TextBox, $gExtraLargeCharMapsMaxWidth, $eScrapeDropSpaces) : _
					   ScrapeFuzzyText($gExtraLargeCharacterMaps, $rEndBattleCups2TextBox, $gExtraLargeCharMapsMaxWidth, $eScrapeDropSpaces)

	  DebugWrite("Winnings this match: " & $goldWin & " / " & $elixWin & " / " & $darkWin & " / " & $cupsWin)

	  $gAutoRaidWinnings[0] += $goldWin
	  $gAutoRaidWinnings[1] += $elixWin
	  $gAutoRaidWinnings[2] += $darkWin
	  $gAutoRaidWinnings[3] += $cupsWin
	  GUICtrlSetData($GUI_Winnings, "Winnings: " & $gAutoRaidWinnings[0] & " / " & $gAutoRaidWinnings[1] & " / " _
					 & $gAutoRaidWinnings[2] & " / " & $gAutoRaidWinnings[3])

	  ; Close battle end screen
	  RandomWeightedClick($rBattleHasEndedScreenReturnHomeButton)

	  ; Wait for main screen
	  Local $failCount=10
	  While WhereAmI()<>$eScreenMain And $failCount>0
		 Sleep(1000)
		 $failCount-=1
	  WEnd

	  If $failCount=0 Then
		 DebugWrite("Battle end - error waiting for main screen")
	  EndIf
   EndIf
EndFunc

Func FindRaidTroopSlots(Const ByRef $bitmaps, ByRef $index)
   ; Populates index with the client area coords of all available troop buttons
   Local $buttonOffset[4] = [0, -15, 52, 54]
   Local $raidTroopBox[4] = [0, 456, 1023, 531]

   GrabFrameToFile("AvailableRaidTroopsFrame.bmp", $raidTroopBox[0], $raidTroopBox[1], $raidTroopBox[2], $raidTroopBox[3])

   For $i = 0 To UBound($bitmaps)-1
	  Local $res = DllCall("ImageMatch.dll", "str", "FindMatch", "str", "AvailableRaidTroopsFrame.bmp", "str", "Images\"&$bitmaps[$i], "int", 3)
	  Local $split = StringSplit($res[0], "|", 2) ; x, y, conf

	  If $split[2] > $gConfidenceRaidTroopSlot Then
		 $index[$i][0] = $split[0]+$raidTroopBox[0]+$buttonOffset[0]
		 $index[$i][1] = $split[1]+$raidTroopBox[1]+$buttonOffset[1]
		 $index[$i][2] = $split[0]+$raidTroopBox[0]+$buttonOffset[2]
		 $index[$i][3] = $split[1]+$raidTroopBox[1]+$buttonOffset[3]
		 DebugWrite("Raid troop " & $bitmaps[$i] & " found at " & $index[$i][0] & ", " & $index[$i][1] & " conf: " & $split[2])
	  Else
		 $index[$i][0] = -1
		 $index[$i][1] = -1
		 $index[$i][2] = -1
		 $index[$i][3] = -1
	  EndIf
   Next
EndFunc

Func GetAvailableTroops(Const $troop, Const ByRef $index)
   If $index[$troop][0] = -1 Then Return 0

   Local $textBox[10] = [$index[$troop][0]+5, $index[$troop][1], $index[$troop][2]-5, $index[$troop][1]+10, _
						 $rBarracksTroopCountTextBox[4], $rBarracksTroopCountTextBox[5], _
						 0, 0, 0, 0]
   Local $t = ScrapeFuzzyText($gSmallCharacterMaps, $textBox, $gSmallCharMapsMaxWidth, $eScrapeDropSpaces)
   Return StringMid($t, 2)
EndFunc

