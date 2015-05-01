Func DumpCups()
   ;DebugWrite("DumpCups()")
   Local $myCups = GUICtrlRead($GUI_MyCups)
   Local $cupsThreshold = GUICtrlRead($GUI_AutoRaidDumpCupsThreshold)
   While _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_CHECKED And _
		 _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups) = $BST_CHECKED And _
		 $myCups > $cupsThreshold

	  DebugWrite("Dumping cups, current=" & $myCups & ", threshold=" & $cupsThreshold)
	  GUICtrlSetData($GUI_AutoRaid, "Auto Raid: Dumping Cups")
	  If DoCupsDump()=False Then Return

	  GetMyLootNumbers()
	  $myCups = GUICtrlRead($GUI_MyCups)
   WEnd
EndFunc

Func DoCupsDump()
   ; Get first available match
   FindAValidMatch(True)

   ; What troops are available?
   Local $troopIndex[UBound($gTroopSlotBMPs)][4]
   FindRaidTroopSlots($gTroopSlotBMPs, $troopIndex)

   If GetAvailableTroops($eTroopBarbarian, $troopIndex)<1 Then
	  DebugWrite("Can't dump cups, no available barbarians.")

	  ; Click End Battle button
	  RandomWeightedClick($LiveRaidScreenEndBattleButton)
	  Sleep(500)

	  Return False
   EndIf

   ; Deploy from top or bottom?
   Local $direction = (Random()>0.5) ? "Top" : "Bot"

   If $direction = "Top" Then
	  MoveScreenDownToTop(False)
   Else
	  MoveScreenUpToBottom(False)
   EndIf

   If _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups)=$BST_UNCHECKED Then Return False

   ; Deploy one barb
   Local $barbButton[8] = [$troopIndex[$eTroopBarbarian][0], $troopIndex[$eTroopBarbarian][1], $troopIndex[$eTroopBarbarian][2], _
						$troopIndex[$eTroopBarbarian][3], 0, 0, 0, 0]
   RandomWeightedClick($barbButton)
   Sleep(500)
   DeployTroopsToSides($eTroopBarbarian, $troopIndex, $eAutoRaidDeployOneTroop, $direction)
   Sleep(500)

   ; Click End Battle button
   ;DebugWrite("Ending battle")
   RandomWeightedClick($LiveRaidScreenEndBattleButton)

   ; Wait for confirmation button
   Local $failCount=20
   Do
	  Sleep(100)
	  $failCount-=1
   Until IsButtonPresent($LiveRaidScreenEndBattleConfirmButton) Or $failCount<=0 Or _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups)=$BST_UNCHECKED

   If _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups)=$BST_UNCHECKED Then Return False

   If $failCount>0 Then
	  ;DebugWrite("Clicking end battle confirmation button")
	  RandomWeightedClick($LiveRaidScreenEndBattleConfirmButton)
	  Sleep(500)
   Else
	  DebugWrite("Error getting end battle confirmation button.")
	  Return False
   EndIf

   ; Wait for battle end screen
   ;DebugWrite("Waiting for battle end screen")

   $failCount=20
   While WhereAmI()<>$eScreenEndBattle And $failCount>0 And _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups)=$BST_CHECKED
	  Sleep(200)
	  $failCount-=1
   WEnd

   If _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups)=$BST_UNCHECKED Then Return False

   If $failCount<=0 Then
	  DebugWrite("Error getting end battle screen.")
	  Return False
   EndIf

   ; Close battle end screen
   RandomWeightedClick($BattleHasEndedScreenReturnHomeButton)

   ; Wait for main screen to reappear
   $failCount=20
   While WhereAmI()<>$eScreenMain And $failCount>0 And _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups)=$BST_CHECKED
	  Sleep(1000)
	  $failCount -= 1
   WEnd

   If _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups)=$BST_UNCHECKED Then Return False

   If $failCount<=0 Then
	  DebugWrite("Error waiting for main screen.")
	  Return False
   EndIf

   Return True
EndFunc

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

   OpenTrainTroopsWindow()
   If WhereAmI() <> $eScreenTrainTroops Then
	  ResetToCoCMainScreen()
	  Return
   EndIf

   ; See if we have a red stripe on the bottom of the train troops window, and move to next stage
   Local $redStripe = IsColorPresent($rWindowTrainTroopsFullColor)

   If FindSpellsQueueingWindow() = False Then
	 DebugWrite(" Auto Raid, Queue Troops failed - can't find Spells or Dark window")
	 ResetToCoCMainScreen()
	 Return
   EndIf

   FillBarracksQueues(Not($redStripe))
   CloseTrainTroopsWindow()

   If $redStripe Then
	  $gAutoRaidStage = $eAutoRaidFindMatch
	  GUICtrlSetData($GUI_AutoRaid, "Auto Raid: Find Match")

   Else
      $gAutoRaidStage = $eAutoRaidWaitForTrainingToComplete
	  GUICtrlSetData($GUI_AutoRaid, "Auto Raid: Waiting For Training (0:00)")

   EndIf
EndFunc

Func FindSpellsQueueingWindow()
   DebugWrite("FindSpellsQueueingWindow()")

   ; Click left arrow until the spells screen or a dark troops screen comes up
   Local $failCount = 6

   While IsColorPresent($rWindowTrainTroopsSpellsColor1) = False And _
		 IsColorPresent($rWindowTrainTroopsSpellsColor2) = False And _
		 IsColorPresent($rWindowTrainTroopsDarkColor1) = False And _
		 IsColorPresent($rWindowTrainTroopsDarkColor2) = False And _
		 $failCount > 0

	  RandomWeightedClick($TrainTroopsWindowPrevButton)
	  Sleep(500)
	  $failCount -= 1
   WEnd

   ; If spells queueing window, then maybe queue spells?
   If IsColorPresent($rWindowTrainTroopsSpellsColor1) = True Or IsColorPresent($rWindowTrainTroopsSpellsColor2) = True And _
	  _GUICtrlButton_GetCheck($GUI_AutoRaidZapDE) = $BST_CHECKED Then

	  ; How many are queued/created?
	  Local $queueStatus = ScrapeFuzzyText($largeCharacterMaps, $rTrainTroopsWindowTextBox)

	  If (StringInStr($queueStatus, "CreateSpells")=1) Then
		 $queueStatus = StringMid($queueStatus, 13)

		 Local $queueStatSplit = StringSplit($queueStatus, "/")
		 If $queueStatSplit[0] = 2 Then
			Local $spellsToFill = Number($queueStatSplit[2]) - Number($queueStatSplit[1])

			$gMyMaxSpells = Number($queueStatSplit[2]) ; Used when deciding to DE Zap or not

			For $i = 1 To $spellsToFill
			   RandomWeightedClick($TrainTroopsWindowLightningButton)
			   Sleep($gDeployTroopClickDelay)
			Next
		 EndIf
	  EndIf
   EndIf

   Return True
EndFunc

Func FillBarracksQueues(Const $initialFillFlag)
   DebugWrite("FillBarracksQueues()")

   ; Loop through barracks and queue troops, until we get to a dark or spells screen, or we've done 4
   Local $barracksCount = 1
   Local $failCount = 5

   While $barracksCount <= 4 And $failCount>0

	  ; Click right arrow to get the next standard troops window
	  RandomWeightedClick($TrainTroopsWindowNextButton)
	  Sleep(500)
	  $failCount-=1

	  ; Make sure we are on a standard troops window
	  If IsColorPresent($rWindowTrainTroopsStandardColor1) = False And IsColorPresent($rWindowTrainTroopsStandardColor2) = False Then
		 ;DebugWrite(" Not on Standard Troops Window: " & Hex($pixelColor1) & "/" & Hex($WindowTrainTroopsStandardColor1[2])& _
			;"  " & Hex($pixelColor2) & "/" & Hex($WindowTrainTroopsStandardColor2[2]))
		 ExitLoop
	  EndIf

	  ; If we have not yet figured out troop costs, then get them now
	  If $gMyTroopCost[$eTroopBarbarian] = 0 Then
		 $gMyTroopCost[$eTroopBarbarian] = ScrapeFuzzyText($smallCharacterMaps, $rTrainTroopsWindowBarbarianCostTextBox)
		 $gMyTroopCost[$eTroopArcher] = ScrapeFuzzyText($smallCharacterMaps, $rTrainTroopsWindowArcherCostTextBox)
		 $gMyTroopCost[$eTroopGoblin]= ScrapeFuzzyText($smallCharacterMaps, $rTrainTroopsWindowGoblinCostTextBox)
		 $gMyTroopCost[$eTroopGiant] = ScrapeFuzzyText($smallCharacterMaps, $rTrainTroopsWindowGiantCostTextBox)
		 $gMyTroopCost[$eTroopWallBreaker] = ScrapeFuzzyText($smallCharacterMaps, $rTrainTroopsWindowWallBreakerCostTextBox)
		 $gMyTroopCost[$eTroopBalloon] = ScrapeFuzzyText($smallCharacterMaps, $rTrainTroopsWindowBalloonCostTextBox)
		 $gMyTroopCost[$eTroopWizard] = ScrapeFuzzyText($smallCharacterMaps, $rTrainTroopsWindowWizardCostTextBox)
		 $gMyTroopCost[$eTroopHealer] = ScrapeFuzzyText($smallCharacterMaps, $rTrainTroopsWindowHealerCostTextBox)
		 $gMyTroopCost[$eTroopDragon] = ScrapeFuzzyText($smallCharacterMaps, $rTrainTroopsWindowDragonCostTextBox)
		 $gMyTroopCost[$eTroopPekka] = ScrapeFuzzyText($smallCharacterMaps, $rTrainTroopsWindowPekkaCostTextBox)
	  EndIf

	  ; If this is an initial fill and we need to queue breakers, then clear all the queued troops in this barracks
	  If $initialFillFlag=True And _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED Then
		 Local $dequeueTries = 6
		 While IsButtonPresent($TrainTroopsWindowDequeueButton) And $dequeueTries>0 And _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_CHECKED
			Local $xClick, $yClick
			RandomWeightedCoords($TrainTroopsWindowDequeueButton, $xClick, $yClick)
			_ClickHold($xClick, $yClick, 4000)
			$dequeueTries-=1
			Sleep(500)
		 WEnd
	  EndIf

	  If _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED Then Return

	  ; If breakers are included and this is an initial fill then queue up breakercount/4 in each barracks
	  If _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED And $initialFillFlag Then
		 For $i = 1 To Int(Number(GUICtrlRead($GUI_AutoRaidBreakerCountEdit))/4)
			RandomWeightedClick($TrainTroopsWindowBreakerButton)
			Sleep(500)
		 Next
	  EndIf

	  ; Fill up this barracks
	  Local $fillTries=1
	  Local $troopsToFill
	  Do
		 ; Get number of troops already queued in this barracks
		 Local $queueStatus = ScrapeFuzzyText($largeCharacterMaps, $rTrainTroopsWindowTextBox)

		 If (StringInStr($queueStatus, "Train")=1) Then
			$queueStatus = StringMid($queueStatus, 6)

			Local $queueStatSplit = StringSplit($queueStatus, "/")
			If $queueStatSplit[0] = 2 Then
			   $troopsToFill = Number($queueStatSplit[2]) - Number($queueStatSplit[1])

			   ; How long to click and hold?
			   Local $fillTime
			   If $troopsToFill>60 Then
				  $fillTime = 3500 + Random(-250, 250, 1)
			   ElseIf $troopsToFill>25 Then
				  $fillTime = 2700 + Random(-250, 250, 1)
			   ElseIf $troopsToFill>10 Then
				  $fillTime = 2300 + Random(-250, 250, 1)
			   Else
				  $fillTime = 1800 + Random(-250, 250, 1)
			   EndIf

			   ; Click and hold to fill up queue
			   If $troopsToFill>0 Then
				  Local $xClick, $yClick
				  If $barracksCount/2 = Int($barracksCount/2) Then ; Alternate between archers and barbs
					 RandomWeightedCoords($TrainTroopsWindowBarbarianButton, $xClick, $yClick)
				  Else
					 RandomWeightedCoords($TrainTroopsWindowArcherButton, $xClick, $yClick)
				  EndIf

				  ;DebugWrite("Filling barracks " & $barracksCount & " try " & $fillTries)
				  _ClickHold($xClick, $yClick, $fillTime)
				  Sleep(500)
			   EndIf
			EndIf
		 EndIf

		 $fillTries+=1
	  Until $troopsToFill=0 Or $fillTries>=6 Or _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED

	  $barracksCount+=1
   WEnd
EndFunc

Func OpenTrainTroopsWindow()
   DebugWrite("OpenTrainTroopsWindow()")

   ; Grab a frame
   GrabFrameToFile("BarracksFrame.bmp")

   ; Find all the barracks on the screen
   Local $barracksIndex = 0
   Local $barracksPoints[1][3]
   For $i = 0 To UBound($BarracksBMPs)-1
	  ; Get matches for this resource
	  Local $res = DllCall("ImageMatch.dll", "str", "FindAllMatches", "str", "BarracksFrame.bmp", _
			   "str", "Images\"&$BarracksBMPs[$i], "int", 3, "int", 6, "double", $gConfidenceBarracks)
	  Local $split = StringSplit($res[0], "|", 2)
	  Local $j
	  For $j = 0 To $split[0]-1
		 If $split[$j*3+3] > $gConfidenceBarracks Then
			$barracksIndex += 1
			ReDim $barracksPoints[$barracksIndex][3]
			$barracksPoints[$barracksIndex-1][0] = $split[$j*3+3] ; confidence
			$barracksPoints[$barracksIndex-1][1] = $split[$j*3+1] ; X
			$barracksPoints[$barracksIndex-1][2] = $split[$j*3+2] ; Y
		 EndIf
	  Next
   Next
   _ArraySort($barracksPoints, 1)

   ; Look through list of barracks for an available training screen
   Local $failCount, $pixMatch1, $pixMatch2, $pixMatch3, $pixMatch4

   For $i = 0 To $barracksIndex - 1
	  ;DebugWrite("Barracks " & $i & ": " & $barracksPoints[$i][0] & " " & $barracksPoints[$i][1] & " " & $barracksPoints[$i][2])

	  ; Click on barracks
	  Local $xClick, $yClick
	  RandomWeightedCoords($BarracksButton, $xClick, $yClick, .5, 3, 0, $BarracksButton[3]/2)
	  _ControlClick($barracksPoints[$i][1]+$xClick, $barracksPoints[$i][2]+$yClick)

	  ; Wait for barracks button panel to show up (Train Troops button)
	  $failCount = 10 ; 2 seconds, should be instant
	  While IsButtonPresent($BarracksPanelTrainTroops1Button) = False And _
			IsButtonPresent($BarracksPanelTrainTroops2Button) = False And _
			IsButtonPresent($BarracksPanelTrainTroops3Button) = False And _
			IsButtonPresent($BarracksPanelUpgradingButton) = False And _
			$failCount>0

		 Sleep(200)
		 $failCount -= 1
	  WEnd

	  If IsButtonPresent($BarracksPanelTrainTroops1Button) = True Or _
		 IsButtonPresent($BarracksPanelTrainTroops2Button) = True Or _
		 IsButtonPresent($BarracksPanelTrainTroops3Button) = True Then ExitLoop
   Next

   If IsButtonPresent($BarracksPanelTrainTroops1Button) = False And _
	  IsButtonPresent($BarracksPanelTrainTroops2Button) = False And _
	  IsButtonPresent($BarracksPanelTrainTroops3Button) = False Then

	  DebugWrite("Auto Raid, Queue Troops failed - error finding available Barracks Button panel.")
	  ResetToCoCMainScreen()
	  Return
   EndIf

   ; Click on Train Troops button
   If IsButtonPresent($BarracksPanelTrainTroops1Button) = True Then
	  RandomWeightedClick($BarracksPanelTrainTroops1Button)

   ElseIf IsButtonPresent($BarracksPanelTrainTroops2Button) = True Then
	  RandomWeightedClick($BarracksPanelTrainTroops2Button)

   Else ; Button type 3
	  RandomWeightedClick($BarracksPanelTrainTroops3Button)

   EndIf

   ; Wait for Train Troops window to show up
   $failCount = 10 ; 2 seconds, should be instant
   While IsColorPresent($TrainTroopsWindowNextButton) = False And $failCount>0
	  Sleep(200)
	  $failCount -= 1
   WEnd

   If $failCount = 0 Then
	  DebugWrite("Auto Raid, Queue Troops failed - timeout waiting for Train Troops window")
	  ResetToCoCMainScreen()
	  Return
   EndIf
EndFunc

Func CloseTrainTroopsWindow()
   DebugWrite("CloseTrainTroopsWindow()")
   ; Close Train Troops window
   RandomWeightedClick($TrainTroopsWindowCloseButton)
   Sleep(500)

   ; Click on safe area to close Barracks Toolbar
   RandomWeightedClick($SafeAreaButton)
   Sleep(500)
EndFunc

Func AutoRaidCheckIfTrainingComplete()
   DebugWrite("AutoRaidCheckIfTrainingComplete()")

   OpenTrainTroopsWindow()

   If WhereAmI() <> $eScreenTrainTroops Then
	  ResetToCoCMainScreen()
	  Return
   EndIf

   ; See if we have a red stripe on the bottom of the train troops window, which means we are full up
   If IsColorPresent($rWindowTrainTroopsFullColor) Then
	  ;DebugWrite("Troop training is complete!")
	  $gAutoRaidStage = $eAutoRaidFindMatch
  	  GUICtrlSetData($GUI_AutoRaid, "Auto Raid: Find Match")

   Else
  	  FindSpellsQueueingWindow()
	  FillBarracksQueues(False) ; Top off the barracks queues

   EndIf

   CloseTrainTroopsWindow()
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
	  Local $goldRemaining = Number(ScrapeFuzzyText($raidLootCharMaps, $rGoldTextBox))
	  Local $elixRemaining = Number(ScrapeFuzzyText($raidLootCharMaps, $rElixTextBox))
	  Local $darkRemaining = Number(ScrapeFuzzyText($raidLootCharMaps, $rDarkTextBox))

	  ; If < 1 min is left, then zap DE if the option is selected
	  If _GUICtrlButton_GetCheck($GUI_AutoRaidZapDE) = $BST_CHECKED And _
		 $darkRemaining >= GUICtrlRead($GUI_AutoRaidZapDEMin) And _
		 $darkStorageZapped = False Then

		 Local $time = ScrapeFuzzyText($extraLargeCharacterMaps, $rBattleTimeRemainingTextBox)
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
		 RandomWeightedClick($LiveRaidScreenEndBattleButton)

		 ; Wait for confirmation button
		 Local $failCount=20
		 While IsButtonPresent($LiveRaidScreenEndBattleConfirmButton)=False And $failCount>0
			Sleep(100)
			$failCount-=1
		 WEnd

		 If $failCount>0 Then
			RandomWeightedClick($LiveRaidScreenEndBattleConfirmButton)
			Sleep(500)
		 EndIf
	  EndIf

	  Sleep(1000)
   Next

   Sleep(2000)

   If WhereAmI() = $eScreenEndBattle Then
	  GrabFrameToFile("EndBattleFrame.bmp")
	  Local $goldWin = ScrapeFuzzyText($extraLargeCharacterMaps, $rEndBattleGoldTextBox)
	  Local $elixWin = ScrapeFuzzyText($extraLargeCharacterMaps, $rEndBattleElixTextBox)
	  Local $darkWin = IsTextBoxPresent($rEndBattleDarkTextBox) ? ScrapeFuzzyText($extraLargeCharacterMaps, $rEndBattleDarkTextBox) : 0
	  Local $cupsWin = IsTextBoxPresent($rEndBattleCups1TextBox) ? _
					   ScrapeFuzzyText($extraLargeCharacterMaps, $rEndBattleCups1TextBox) : _
					   ScrapeFuzzyText($extraLargeCharacterMaps, $rEndBattleCups2TextBox)

	  DebugWrite("Winnings this match: " & $goldWin & " / " & $elixWin & " / " & $darkWin & " / " & $cupsWin)

	  $gAutoRaidWinnings[0] += $goldWin
	  $gAutoRaidWinnings[1] += $elixWin
	  $gAutoRaidWinnings[2] += $darkWin
	  $gAutoRaidWinnings[3] += $cupsWin
	  GUICtrlSetData($GUI_Winnings, "Winnings: " & $gAutoRaidWinnings[0] & " / " & $gAutoRaidWinnings[1] & " / " _
					 & $gAutoRaidWinnings[2] & " / " & $gAutoRaidWinnings[3])

	  ; Close battle end screen
	  RandomWeightedClick($BattleHasEndedScreenReturnHomeButton)

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
		 DebugWrite("Troop " & $bitmaps[$i] & " found at " & $index[$i][0] & ", " & $index[$i][1] & " conf: " & $split[2])
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
						 $rTroopSlotCountTextBox[4], $rTroopSlotCountTextBox[5], _
						 0, 0, 0, 0]

   Local $t = ScrapeFuzzyText($smallCharacterMaps, $textBox)
   Return StringMid($t, 2)
EndFunc

Func ZapDarkElixirStorage()
   DebugWrite("ZapDarkElixirStorage()")

   Local $spellIndex[UBound($gSpellSlotBMPs)][4]
   FindRaidTroopSlots($gSpellSlotBMPs, $spellIndex)

   Local $availableLightnings = GetAvailableTroops($eSpellLightning, $spellIndex)

   ; Only zap if there are the maximum number of lightning spells available
   If $availableLightnings<$gMyMaxSpells Then
	  DebugWrite("Not zapping DE, " & $availableLightnings & " of " & $gMyMaxSpells & " lightning spells available.")
	  Return False
   EndIf

   ; Find DE storage
   GrabFrameToFile("DEStorageFrame.bmp", 235, 100, 789, 450)
   Local $bestMatch = 99, $bestConfidence = 0, $bestX = 0, $bestY = 0
   ScanFrameForBestBMP("DEStorageFrame.bmp", $DarkStorageBMPs, $gConfidenceDEStorage, $bestMatch, $bestConfidence, $bestX, $bestY)
   DebugWrite("DE search: " & $bestMatch & " " & $bestConfidence & " " & $bestX & " " & $bestY)

   ; If < $gConfidenceDEStorageZap confidence, then not good enough to spend spells
   If $bestConfidence < $gConfidenceDEStorage Then
	  Local $datetimestamp = _
		 StringMid(_NowCalc(), 1,4) & _
		 StringMid(_NowCalc(), 6,2) & _
		 StringMid(_NowCalc(), 9,2) & _
		 StringMid(_NowCalc(), 12,2) & _
		 StringMid(_NowCalc(), 15,2) & _
		 StringMid(_NowCalc(), 18,2)
	  FileMove("DEStorageFrame.bmp", "ZapNoConfidence-" & $datetimestamp & ".bmp")

	  DebugWrite("Not zapping DE, could not find high enough confidence DE Storage to zap.")
	  Return False
   EndIf

   DebugWrite("Zapping DE, " & $availableLightnings & " of " & $gMyMaxSpells & " lightning spells available, confidence: " & $bestConfidence)

   ; Select lightning spell
   Local $lightningButton[8] = [$spellIndex[$eSpellLightning][0], $spellIndex[$eSpellLightning][1], $spellIndex[$eSpellLightning][2], _
							    $spellIndex[$eSpellLightning][3], 0, 0, 0, 0]
   RandomWeightedClick($lightningButton)
   Sleep(500)

   ; Zap away
   DebugWrite("Zapping at client position: " & $bestX+235+10 & "," & $bestY+100+30)
   For $i = 1 To $availableLightnings
	  _MouseClickFast($bestX+235+10, $bestY+100+30)
	  Sleep(1000)
   Next

   Sleep(6000)

   Return True
EndFunc


