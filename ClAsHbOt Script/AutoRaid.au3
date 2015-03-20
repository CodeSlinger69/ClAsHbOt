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
   Local $troopSlotIndex[$countOfSlots]
   FindTroopSlots($troopSlotIndex)

   ; Get buttons and text boxes for troops
   Local $barbButton[8], $barbTextBox[10]
   GetTroopSlotButton($troopSlotIndex[$barbarianSlot], $barbButton)
   GetTroopSlotTextBox($troopSlotIndex[$barbarianSlot], $barbTextBox)
   Local $cPos = GetClientPos()
   Local $xClick, $yClick
   Local $availableBarbs = $troopSlotIndex[$barbarianSlot]<>-1 ? StringMid(ScrapeText($smallCharacterMaps, $barbTextBox, 172, 456, 851, 531), 2) : 0

   If $availableBarbs<1 Then
	  DebugWrite("Can't dump cups, no available barbarians.")

	  ; Click End Battle button
	  RandomWeightedCoords($LiveRaidScreenEndBattleButton, $xClick, $yClick)
	  MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)
	  Sleep(500)

	  Return False
   EndIf

   ; Deploy from top or bottom?
   Local $direction = (Random()>0.5) ? "Top" : "Bot"
   ;DebugWrite("Deploying one barb from " & $direction)

   If $direction = "Top" Then
	  MoveScreenDownToTop(False)
   Else
	  MoveScreenUpToBottom(False)
   EndIf

   If $ExitApp=True Or _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups)=$BST_UNCHECKED Then Return False

   ; Deploy one barb
   RandomWeightedCoords($barbButton, $xClick, $yClick)
   MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)
   Sleep(500)
   DeployTroopsToSides($barbTextBox, $deployOneTroop, $direction)
   Sleep(500)

   ; Click End Battle button
   ;DebugWrite("Ending battle")
   RandomWeightedCoords($LiveRaidScreenEndBattleButton, $xClick, $yClick)
   MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)

   ; Wait for confirmation button
   Local $failCount=20
   Do
	  Local $pixelColor = PixelGetColor($cPos[0]+$LiveRaidScreenEndBattleConfirmButton[4], $cPos[1]+$LiveRaidScreenEndBattleConfirmButton[5])
	  Local $pixMatch = InColorSphere($pixelColor, $LiveRaidScreenEndBattleConfirmButton[6], $LiveRaidScreenEndBattleConfirmButton[7])
	  Sleep(100)
	  $failCount-=1
   Until $pixMatch=True Or $failCount<=0 Or $ExitApp=True Or _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups)=$BST_UNCHECKED

   If $ExitApp=True Or _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups)=$BST_UNCHECKED Then Return False

   If $failCount>0 Then
	  ;DebugWrite("Clicking end battle confirmation button")
	  RandomWeightedCoords($LiveRaidScreenEndBattleConfirmButton, $xClick, $yClick)
	  MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)
	  Sleep(500)
   Else
	  DebugWrite("Error getting end battle confirmation button.")
	  Return False
   EndIf

   ; Wait for battle end screen
   ;DebugWrite("Waiting for battle end screen")

   $failCount=20
   While WhereAmI()<>$ScreenEndBattle And $failCount>0 And $ExitApp=False And _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups)=$BST_CHECKED
	  Sleep(200)
	  $failCount-=1
   WEnd

   If $ExitApp=True Or _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups)=$BST_UNCHECKED Then Return False

   If $failCount<=0 Then
	  DebugWrite("Error getting end battle screen.")
	  Return False
   EndIf

   ; Close battle end screen
   RandomWeightedCoords($BattleHasEndedScreenReturnHomeButton, $xClick, $yClick)
   MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)

   ; Wait for main screen to reappear
   $failCount=20
   While WhereAmI()<>$ScreenMain And $failCount>0 And $ExitApp=False And _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups)=$BST_CHECKED
	  Sleep(1000)
	  $failCount -= 1
   WEnd

   If $ExitApp=True Or _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups)=$BST_UNCHECKED Then Return False

   If $failCount<=0 Then
	  DebugWrite("Error waiting for main screen.")
	  Return False
   EndIf

   Return True
EndFunc

Func AutoRaid()
   ;DebugWrite("AutoRaid()")

   Switch $autoRaidStage

   ; Stage Queue Training
   Case $AutoRaidQueueTraining
	  GUICtrlSetData($GUI_AutoRaid, "Auto Raid: Queue Training")

	  ResetToCoCMainScreen()
	  ZoomOut(True)

	  AutoRaidQueueTraining()
	  $lastTrainingCheck = TimerInit()

   ; Stage Wait For Training To Complete
   Case $AutoRaidWaitForTrainingToComplete

	  If TimerDiff($lastTrainingCheck) >= $troopTrainingCheckDelay Then
		 ResetToCoCMainScreen()
		 ZoomOut(True)
		 AutoRaidCheckIfTrainingComplete()
		 $lastTrainingCheck = TimerInit()
	  EndIf

   ; Stage Find Match
   Case $AutoRaidFindMatch
	  Local $findMatchResults = FindAValidMatch()

	  If $findMatchResults = $AutoRaidExecuteRaid Then
		 $autoRaidStage = $AutoRaidExecuteRaid
		 GUICtrlSetData($GUI_AutoRaid, "Auto Raid: Execute Raid")
	  ElseIf $findMatchResults = $AutoRaidExecuteDEZap Then
		 $autoRaidStage = $AutoRaidExecuteDEZap
		 GUICtrlSetData($GUI_AutoRaid, "Auto Raid: Execute DE Zap")
	  EndIf

   ; Stage Execute DE Zap
   Case $AutoRaidExecuteDEZap
	  If AutoRaidExecuteDEZap() = True Then
		 $autoRaidStage = $AutoRaidQueueTraining
		 GUICtrlSetData($GUI_AutoRaid, "Auto Raid: DE Zap Complete")
		 AutoRaidUpdateProgress()
	  Else
		 ResetToCoCMainScreen()
		 $autoRaidStage = $AutoRaidFindMatch
		 GUICtrlSetData($GUI_AutoRaid, "Auto Raid: Find Match")
	  EndIf

   ; Stage Execute Raid
   Case $AutoRaidExecuteRaid
	  Switch _GUICtrlComboBox_GetCurSel($GUI_AutoRaidStrategyCombo)
	  Case 0
		 If AutoRaidExecuteRaidStrategy0() Then
			$autoRaidStage = $AutoRaidQueueTraining
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

   $endGold = GUICtrlRead($GUI_MyGold)
   $endElix = GUICtrlRead($GUI_MyElix)
   $endDark = GUICtrlRead($GUI_MyDark)
   $endCups = GUICtrlRead($GUI_MyCups)
   ConsoleWrite(_NowTime() & " AutoRaid Change: " & _
	  " Gold:" & $endGold-$beginGold & _
	  " Elix:" & $endElix-$beginElix & _
	  " Dark:" & $endDark-$beginDark & _
	  " Cups:" & $endCups-$beginCups & @CRLF & @CRLF)
EndFunc

Func AutoRaidQueueTraining()
   DebugWrite("AutoRaidQueueTraining()")

   Local $xClick, $yClick
   Local $cPos = GetClientPos()
   Local $failCount, $pixMatch1, $pixMatch2, $pixelColor1, $pixelColor2

   OpenTrainTroopsWindow()
   If WhereAmI() <> $WindowTrainTroops Then
	  ResetToCoCMainScreen()
	  Return
   EndIf

   ; See if we have a red stripe on the bottom of the train troops window, and move to next stage
   $pixelColor1 = PixelGetColor($cPos[0]+$WindowTrainTroopsFullColor[0], $cPos[1]+$WindowTrainTroopsFullColor[1])
   $pixMatch1 = InColorSphere($pixelColor1, $WindowTrainTroopsFullColor[2], $WindowTrainTroopsFullColor[3])

   If FindSpellsQueueingWindow() = False Then
	 ConsoleWrite(_NowTime() & " Auto Raid, Queue Troops failed - can't find Spells or Dark window" & @CRLF)
	 ResetToCoCMainScreen()
	 Return
   EndIf

   FillBarracksQueues(Not($pixMatch1))
   CloseTrainTroopsWindow()

   If $pixMatch1 Then
	  $autoRaidStage = $AutoRaidFindMatch
	  GUICtrlSetData($GUI_AutoRaid, "Auto Raid: Find Match")
   Else
      $autoRaidStage = $AutoRaidWaitForTrainingToComplete
	  GUICtrlSetData($GUI_AutoRaid, "Auto Raid: Waiting For Training (0:00)")
   EndIf
EndFunc

Func FindSpellsQueueingWindow()
   Local $cPos = GetClientPos()

   ; Click left arrow until the spells screen or a dark troops screen comes up
   Local $failCount = 6
   Local $pixMatch1 = False
   Local $pixMatch2 = False
   Local $pixMatch3 = False
   Local $pixMatch4 = False
   Do
	  Local $pixelColor1 = PixelGetColor($cPos[0]+$WindowTrainTroopsSpellsColor1[0], $cPos[1]+$WindowTrainTroopsSpellsColor1[1])
	  Local $pixMatch1 = InColorSphere($pixelColor1, $WindowTrainTroopsSpellsColor1[2], $WindowTrainTroopsSpellsColor1[3])
	  Local $pixelColor2 = PixelGetColor($cPos[0]+$WindowTrainTroopsSpellsColor2[0], $cPos[1]+$WindowTrainTroopsSpellsColor2[1])
	  Local $pixMatch2 = InColorSphere($pixelColor2, $WindowTrainTroopsSpellsColor2[2], $WindowTrainTroopsSpellsColor2[3])
	  Local $pixelColor3 = PixelGetColor($cPos[0]+$WindowTrainTroopsDarkColor1[0], $cPos[1]+$WindowTrainTroopsDarkColor1[1])
	  Local $pixMatch3 = InColorSphere($pixelColor3, $WindowTrainTroopsDarkColor1[2], $WindowTrainTroopsDarkColor1[3])
	  Local $pixelColor4 = PixelGetColor($cPos[0]+$WindowTrainTroopsDarkColor2[0], $cPos[1]+$WindowTrainTroopsDarkColor2[1])
	  Local $pixMatch4 = InColorSphere($pixelColor4, $WindowTrainTroopsDarkColor2[2], $WindowTrainTroopsDarkColor2[3])

	  If $pixMatch1 <> True And $pixMatch2 <> True And $pixMatch3 <> True And $pixMatch4 <> True Then
		 Local $xClick, $yClick
		 RandomWeightedCoords($TrainTroopsWindowPrevButton, $xClick, $yClick)
		 MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)
		 Sleep(500)
	  EndIf

	  $failCount -= 1
   Until $pixMatch1 = True Or $pixMatch2 = True Or $pixMatch3 = True Or $pixMatch4 = True Or $failCount<=0 Or $ExitApp

   If $ExitApp Then Return False

   ; If spells queueing window, then maybe queue spells?
   If $pixMatch1 = True Or $pixMatch2 = True And _GUICtrlButton_GetCheck($GUI_AutoRaidZapDE) = $BST_CHECKED Then
	  ; How many are queued/created?
	  Local $queueStatus = ScrapeText($largeCharacterMaps, $TrainTroopsWindowTextBox)

	  If (StringInStr($queueStatus, "CreateSpells")=1) Then
		 $queueStatus = StringMid($queueStatus, 13)

		 Local $queueStatSplit = StringSplit($queueStatus, "/")
		 If $queueStatSplit[0] = 2 Then
			Local $troopsToFill = Number($queueStatSplit[2]) - Number($queueStatSplit[1])

			$myMaxSpells = Number($queueStatSplit[2])

			For $i = 1 To $troopsToFill
			   RandomWeightedCoords($TrainTroopsWindowLightningButton, $xClick, $yClick)
			   MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)
			   Sleep($deployClickDelay)
			Next
		 EndIf
	  EndIf
   EndIf

   Return True
EndFunc

Func FillBarracksQueues(Const $initialFillFlag)
   ; Loop through barracks until we get to a dark or spells screen, or we've done 4
   Local $i, $xClick, $yClick
   Local $cPos = GetClientPos()

   ; Loop through each barracks and queue troops
   Local $barracksCount = 1
   Local $failCount = 5

   While $barracksCount <= 4 And $ExitApp <> True And $failCount>0

	  ; Click right arrow to get the next standard troops window
	  RandomWeightedCoords($TrainTroopsWindowNextButton, $xClick, $yClick)
	  MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)
	  Sleep(500)
	  $failCount-=1

	  ; Make sure we are on a standard troops window
	  Local $pixelColor1 = PixelGetColor($cPos[0]+$WindowTrainTroopsStandardColor1[0], $cPos[1]+$WindowTrainTroopsStandardColor1[1])
	  Local $pixMatch1 = InColorSphere($pixelColor1, $WindowTrainTroopsStandardColor1[2], $WindowTrainTroopsStandardColor1[3])
	  Local $pixelColor2 = PixelGetColor($cPos[0]+$WindowTrainTroopsStandardColor2[0], $cPos[1]+$WindowTrainTroopsStandardColor2[1])
	  Local $pixMatch2 = InColorSphere($pixelColor2, $WindowTrainTroopsStandardColor2[2], $WindowTrainTroopsStandardColor2[3])

	  If ($pixMatch1 = False And $pixMatch2 = False) Then
		 ;ConsoleWrite(_NowTime() & " Not on Standard Troops Window: " & Hex($pixelColor1) & "/" & Hex($WindowTrainTroopsStandardColor1[2])& _
			;"  " & Hex($pixelColor2) & "/" & Hex($WindowTrainTroopsStandardColor2[2]) & @CRLF)
		 ExitLoop
	  EndIf

	  ; If we have not yet figured out troop costs, then get them now
	  If $myTroopCost[$barbarianSlot] = 0 Then
		 $myTroopCost[$barbarianSlot] = ScrapeText($smallCharacterMaps, $TrainTroopsWindowBarbarianCostTextBox)
		 $myTroopCost[$archerSlot] = ScrapeText($smallCharacterMaps, $TrainTroopsWindowArcherCostTextBox)
		 $myTroopCost[$giantSlot] = ScrapeText($smallCharacterMaps, $TrainTroopsWindowGiantCostTextBox)
		 $myTroopCost[$goblinSlot]= ScrapeText($smallCharacterMaps, $TrainTroopsWindowGoblinCostTextBox)
		 $myTroopCost[$wallBreakerSlot] = ScrapeText($smallCharacterMaps, $TrainTroopsWindowWallBreakerCostTextBox)
		 $myTroopCost[$balloonSlot] = ScrapeText($smallCharacterMaps, $TrainTroopsWindowBalloonCostTextBox)
		 $myTroopCost[$wizardSlot] = ScrapeText($smallCharacterMaps, $TrainTroopsWindowWizardCostTextBox)
		 $myTroopCost[$healerSlot] = ScrapeText($smallCharacterMaps, $TrainTroopsWindowHealerCostTextBox)
		 $myTroopCost[$dragonSlot] = ScrapeText($smallCharacterMaps, $TrainTroopsWindowDragonCostTextBox)
		 $myTroopCost[$pekkaSlot] = ScrapeText($smallCharacterMaps, $TrainTroopsWindowPekkaCostTextBox)
	  EndIf

	  ; If this is an initial fill and we need to queue breakers, then clear all the queued troops in this barracks
	  If $initialFillFlag=True And _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED Then
		 Local $dequeueTries = 6
		 Do
			Local $pixelColorQueue = PixelGetColor($cPos[0]+$TrainTroopsWindowDequeueButton[4], $cPos[1]+$TrainTroopsWindowDequeueButton[5])
			Local $pixMatchQueue = InColorSphere($pixelColorQueue, $TrainTroopsWindowDequeueButton[6], $TrainTroopsWindowDequeueButton[7])
			;ConsoleWrite("Dequeue button: " & Hex($pixelColorQueue) & " / " & Hex($TrainTroopsWindowDequeueButton[6]) & @CRLF)
			;ConsoleWrite("Dequeueing barracks " & $barracksCount & " try " & 7-$dequeueTries & @CRLF)

			If $pixMatchQueue Then
			   RandomWeightedCoords($TrainTroopsWindowDequeueButton, $xClick, $yClick)
			   MouseMove($cPos[0]+$xClick, $cPos[1]+$yClick)
			   MouseDown("left")
			   Sleep(4000)
			   MouseUp("left")
			   $dequeueTries-=1
			   Sleep(500)
			EndIf
		 Until $pixMatchQueue=False Or $ExitApp=True Or $dequeueTries=0 Or _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED
	  EndIf

	  If $ExitApp Or _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED Then Return

	  ; If breakers are included and this is an initial fill then queue up breakercount/4 in each barracks
	  If _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers) = $BST_CHECKED And $initialFillFlag Then
		 For $i = 1 To Int(Number(GUICtrlRead($GUI_AutoRaidBreakerCountEdit))/4)
			RandomWeightedCoords($TrainTroopsWindowBreakerButton, $xClick, $yClick)
			MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)
			Sleep(500)
		 Next
	  EndIf

	  ; Fill up this barracks
	  Local $fillTries=1
	  Local $troopsToFill
	  Do
		 ; Get number of troops already queued in this barracks
		 Local $queueStatus = ScrapeText($largeCharacterMaps, $TrainTroopsWindowTextBox)

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
				  If $barracksCount/2 = Int($barracksCount/2) Then ; Alternate between archers and barbs
					 RandomWeightedCoords($TrainTroopsWindowBarbarianButton, $xClick, $yClick)
				  Else
					 RandomWeightedCoords($TrainTroopsWindowArcherButton, $xClick, $yClick)
				  EndIf

				  ;ConsoleWrite("Filling barracks " & $barracksCount & " try " & $fillTries & @CRLF)
				  MouseMove($cPos[0]+$xClick, $cPos[1]+$yClick)
				  MouseDown("left")
				  Sleep($fillTime)
				  MouseUp("left")
				  Sleep(500)
			   EndIf
			EndIf
		 EndIf

		 $fillTries+=1
	  Until $troopsToFill=0 Or $fillTries>=6 Or $ExitApp=True Or _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)=$BST_UNCHECKED

	  $barracksCount+=1
   WEnd
EndFunc

Func OpenTrainTroopsWindow()
   Local $i
   Local $xClick, $yClick
   Local $cPos = GetClientPos()
   Local $failCount, $pixMatch1, $pixMatch2, $pixMatch3, $pixMatch4, $pixelColor1, $pixelColor2, $pixelColor3, $pixelColor4

   ; Grab a frame
   GrabFrameToFile("BarracksFrame.bmp")

   ; Find all the barracks on the screen
   Local $barracksIndex = 0
   Local $barracksPoints[1][3]
   Local $i
   For $i = 0 To UBound($BarracksBMPs)-1
	  ; Get matches for this resource
	  Local $res = DllCall("ImageMatch.dll", "str", "FindAllMatches", "str", "BarracksFrame.bmp", _
			   "str", "Images\"&$BarracksBMPs[$i], "int", 3, "int", 6, "double", $confidenceBarracksSearch)
	  Local $split = StringSplit($res[0], "|", 2)
	  Local $j
	  For $j = 0 To $split[0]-1
		 If $split[$j*3+3] > $confidenceBarracksSearch Then
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
   For $i = 0 To $barracksIndex - 1
	  ;ConsoleWrite("Barracks " & $i & ": " & $barracksPoints[$i][0] & " " & $barracksPoints[$i][1] & " " & $barracksPoints[$i][2] & @CRLF)

	  ; Click on barracks
	  RandomWeightedCoords($BarracksButton, $xClick, $yClick, .5, 3, 0, $BarracksButton[3]/2)
	  MouseClick("left", $cPos[0]+$barracksPoints[$i][1]+$xClick, $cPos[1]+$barracksPoints[$i][2]+$yClick)

	  ; Wait for barracks button panel to show up (Train Troops button)
	  $failCount = 10 ; 2 seconds, should be instant
	  $pixMatch1 = False
	  $pixMatch2 = False
	  $pixMatch3 = False
	  While $pixMatch1=False And $pixMatch2=False And $pixMatch3=False And $pixMatch4=False And $failCount>0 And $ExitApp=False
		 Sleep(200)
		 $pixelColor1 = PixelGetColor($cPos[0]+$BarracksPanelTrainTroops1Button[4], $cPos[1]+$BarracksPanelTrainTroops1Button[5])
		 $pixMatch1 = InColorSphere($pixelColor1, $BarracksPanelTrainTroops1Button[6], $BarracksPanelTrainTroops1Button[7])

		 $pixelColor2 = PixelGetColor($cPos[0]+$BarracksPanelTrainTroops2Button[4], $cPos[1]+$BarracksPanelTrainTroops2Button[5])
		 $pixMatch2 = InColorSphere($pixelColor2, $BarracksPanelTrainTroops2Button[6], $BarracksPanelTrainTroops2Button[7])

		 $pixelColor3 = PixelGetColor($cPos[0]+$BarracksPanelTrainTroops3Button[4], $cPos[1]+$BarracksPanelTrainTroops3Button[5])
		 $pixMatch3 = InColorSphere($pixelColor3, $BarracksPanelTrainTroops3Button[6], $BarracksPanelTrainTroops3Button[7])

		 $pixelColor4 = PixelGetColor($cPos[0]+$BarracksPanelUpgradingButton[4], $cPos[1]+$BarracksPanelUpgradingButton[5])
		 $pixMatch4 = InColorSphere($pixelColor4, $BarracksPanelUpgradingButton[6], $BarracksPanelUpgradingButton[7])

		 $failCount -= 1
	  WEnd

	  If $pixMatch1=True Or $pixMatch2=True Or $pixMatch3=True Then ExitLoop

	  If $ExitApp Then Return
   Next

   If $pixMatch1=False And $pixMatch2=False And $pixMatch3=False Then
	  ConsoleWrite(_NowTime() & " Auto Raid, Queue Troops failed - error finding available Barracks Button panel." & @CRLF)
	  ResetToCoCMainScreen()
	  Return
   EndIf

   ; Click on Train Troops button
   If $pixMatch1 Then
	  RandomWeightedCoords($BarracksPanelTrainTroops1Button, $xClick, $yClick)
   ElseIf $pixMatch2 Then
	  RandomWeightedCoords($BarracksPanelTrainTroops2Button, $xClick, $yClick)
   Else ; $pixmatch3
	  RandomWeightedCoords($BarracksPanelTrainTroops3Button, $xClick, $yClick)
   EndIf

   MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)

   ; Wait for Train Troops window to show up
   $failCount = 10 ; 2 seconds, should be instant
   $pixMatch1 = False
   While $pixMatch1 = False And $failCount>0 And $ExitApp = False
	  Sleep(200)
	  $failCount -= 1
	  $pixelColor1 = PixelGetColor($cPos[0]+$TrainTroopsWindowNextButton[4], $cPos[1]+$TrainTroopsWindowNextButton[5])
	  $pixMatch1 = InColorSphere($pixelColor1, $TrainTroopsWindowNextButton[6], $TrainTroopsWindowNextButton[7])
   WEnd

   If $ExitApp Then Return
   If $failCount = 0 Then
	  ConsoleWrite(_NowTime() & " Auto Raid, Queue Troops failed - timeout waiting for Train Troops window" & @CRLF)
	  ResetToCoCMainScreen()
	  Return
   EndIf
EndFunc

Func CloseTrainTroopsWindow()
   Local $cPos = GetClientPos()
   Local $xClick, $yClick

   ; Close Train Troops window
   RandomWeightedCoords($TrainTroopsWindowCloseButton, $xClick, $yClick)
   MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)
   Sleep(500)

   ; Click on safe area to close Barracks Toolbar
   RandomWeightedCoords($SafeAreaButton, $xClick, $yClick)
   MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick, 1)
   Sleep(500)
EndFunc

Func AutoRaidCheckIfTrainingComplete()
   DebugWrite("AutoRaidCheckIfTrainingComplete()")

   Local $cPos = GetClientPos()

   OpenTrainTroopsWindow()

   If WhereAmI() <> $WindowTrainTroops Then
	  ResetToCoCMainScreen()
	  Return
   EndIf

   ; See if we have a red stripe on the bottom of the train troops window, which means we are full up
   Local $pixelColor = PixelGetColor($cPos[0]+$WindowTrainTroopsFullColor[0], $cPos[1]+$WindowTrainTroopsFullColor[1])
   Local $pixMatch = InColorSphere($pixelColor, $WindowTrainTroopsFullColor[2], $WindowTrainTroopsFullColor[3])

   If $pixMatch Then
	  ;ConsoleWrite("Troop training is complete!" & @CRLF)
	  $autoRaidStage = $AutoRaidFindMatch
  	  GUICtrlSetData($GUI_AutoRaid, "Auto Raid: Find Match")
   Else
  	  FindSpellsQueueingWindow()
	  FillBarracksQueues(False) ; Top off the barracks queues
   EndIf

   CloseTrainTroopsWindow()
EndFunc

; howMany: $deploySixtyPercent, $deployRemaining, $deployOneTroop
Func DeployTroopsToSides(Const ByRef $textBox, Const $howMany, Const $dir)
   Local $cPos = GetClientPos()
   Local $xClick, $yClick

   ; Handle the deploy one troop situation first
   If $howMany=$deployOneTroop Then
	  RandomWeightedCoords( ($dir = "Top" ? $NWSafeDeployBox : $SWSafeDeployBox), $xClick, $yClick)
	  _MouseClickFast($cPos[0]+$xClick, $cPos[1]+$yClick)
	  Return
   EndIf

   ; Do initial deployment
   Local $troopsAvailable = StringMid(ScrapeText($smallCharacterMaps, $textBox, 172, 456, 851, 531), 2)
   If $howMany=$deploySixtyPercent Then $troopsAvailable = Int($troopsAvailable * 0.6)
   ;ConsoleWrite("DeployTroopsToSides: " & ($howMany=$deploySixtyPercent ? "60% " : "Remaining ") & $troopsAvailable & @CRLF)

   Local $clickPoints1[$troopsAvailable][2]
   ; Always deploy first set of troops left to right to avoid accidentally clicking the Next button
   GetRandomSortedClickPoints(0, $dir, $troopsAvailable, $clickPoints1)

   Local $i
   For $i = 0 To $troopsAvailable-1
	  _MouseClickFast($cPos[0]+$clickPoints1[$i][0], $cPos[1]+$clickPoints1[$i][1])
	  Sleep($deployClickDelay)
	  If $ExitApp Then ExitLoop
   Next

   ; If we are only deploying 60% then we are done
   If $howMany=$deploySixtyPercent Then Return

   ; If we are deploying all, then check remaining and continue to deploy to make sure they all get out there
   $troopsAvailable = StringMid(ScrapeText($smallCharacterMaps, $textBox, 172, 456, 851, 531), 2)

   If $troopsAvailable>0 Then
	  ;ConsoleWrite("DeployTroopsToSides: Continuing " & $troopsAvailable & " remaining" & @CRLF)
	  Local $clickPoints2[$troopsAvailable][2]
	  GetRandomSortedClickPoints(Random(0,1,1), $dir, $troopsAvailable, $clickPoints2)

	  Local $i
	  For $i = 0 To $troopsAvailable-1
		 _MouseClickFast($cPos[0]+$clickPoints2[$i][0], $cPos[1]+$clickPoints2[$i][1])
		 Sleep($deployClickDelay)
		 If $ExitApp Then ExitLoop
	  Next
   EndIf

   $troopsAvailable = StringMid(ScrapeText($smallCharacterMaps, $textBox, 172, 456, 851, 531), 2)

   If $troopsAvailable>0 Then DeployTroopsToSafeBoxes($textBox, $dir)
EndFunc

Func DeployTroopsToSafeBoxes(Const ByRef $textBox, Const $dir)
   Local $cPos = GetClientPos()
   Local $i, $xClick, $yClick, $count


   ; Deploy half to left
   Local $troopsAvailable = Int(StringMid(ScrapeText($smallCharacterMaps, $textBox, 172, 456, 851, 531), 2) / 2)
   ;ConsoleWrite("DeployTroopsToSafeBoxes, to left: " & $troopsAvailable & @CRLF)
   $count=0
   For $i = 1 To $troopsAvailable
	  RandomWeightedCoords( ($dir = "Top" ? $NWSafeDeployBox : $SWSafeDeployBox), $xClick, $yClick)
	  _MouseClickFast($cPos[0]+$xClick, $cPos[1]+$yClick)
	  Sleep($deployClickDelay)
	  $count+=1
	  If $ExitApp Then ExitLoop
   Next

   ; Deploy half to right
   $troopsAvailable = StringMid(ScrapeText($smallCharacterMaps, $textBox, 172, 456, 851, 531), 2)
   ;ConsoleWrite("DeployTroopsToSafeBoxes, to right: " & $troopsAvailable & @CRLF)
   $count=0
   For $i = 1 To $troopsAvailable
   	  RandomWeightedCoords( ($dir = "Top" ? $NESafeDeployBox : $SESafeDeployBox), $xClick, $yClick)
	  _MouseClickFast($cPos[0]+$xClick, $cPos[1]+$yClick)
	  Sleep($deployClickDelay)
	  $count+=1
	  If $ExitApp Then ExitLoop
   Next
EndFunc

Func LocateCollectors(ByRef $matchX, ByRef $matchY)
   Local $i
   Local $cPos = GetClientPos()

   ; Move screen up 65 pixels
   MoveScreenUpToCenter(65)

   ; Grab frame
   GrabFrameToFile("AutoRaidCollectorFrame.bmp")

   ; Find all the collectors that need clicking in the frame
   Local $matchCount = 0

   For $i = 0 To UBound($CollectorBMPs)-1
	  ; Get matches for this resource
	  Local $res = DllCall("ImageMatch.dll", "str", "FindAllMatches", "str", "AutoRaidCollectorFrame.bmp", _
			   "str", "Images\"&$CollectorBMPs[$i], "int", 3, "int", 6, "double", $confidenceCollectorsSearch)
	  Local $split = StringSplit($res[0], "|", 2)
	  ;ConsoleWrite("Num matches " & $CollectorBMPs[$i] & ": " & $split[0] & @CRLF)

	  Local $j
	  For $j = 0 To $split[0]-1
		 ; Loop through all captured points so far, if this one is within 8 pix of an existing one,
		 ; then skip it.
		 Local $k, $alreadyFound = False
		 For $k = 0 To $matchCount-1
			If DistBetweenTwoPoints($split[$j*3+1], $split[$j*3+2], $matchX[$k], $matchY[$k]) < 8 Then
			   $alreadyFound = True
			   ;ConsoleWrite("    Already found " & $j & ": " & $split[$j*3+1] & "," & $split[$j*3+2] & "  " & $split[$j*3+3] & @CRLF)
			   ExitLoop
			EndIf
		 Next

		 ; Otherwise add it to the growing list of matches, if it is $confidenceCollectorsSearch % or greater confidence
		 If $alreadyFound = False Then
			If $split[$j*3+3] > $confidenceCollectorsSearch Then
			   ;ConsoleWrite("    Adding " & $j & ": " & $split[$j*3+1] & "," & $split[$j*3+2] & "  " & $split[$j*3+3] & @CRLF)
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
   Local $j

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
   Local $i

   For $i = 0 To $numberPoints-1
	  Local $deployBox[4]
	  GetRandomDeployBox($topBotDirection, $deployBox)
	  RandomCoords($deployBox, $points[$i][0], $points[$i][1])
   Next

   _ArraySort($points, $order)
EndFunc

Func WaitForBattleEnd(Const $kingDeployed, Const $queenDeployed)
   Local $i
   Local $cPos = GetClientPos()
   Local $xClick, $yClick

   ; Wait for battle end screen
   DebugWrite("Waiting for Battle End screen")
   Local $lastGold = 0, $lastElix = 0, $lastDark = 0
   Local $activeTimer = TimerInit()
   Local $darkStorageZapped = False
   For $i = 1 To 180  ; 3 minutes max until battle end screen appears
	  If WhereAmI() = $ScreenEndBattle Then ExitLoop
	  If $ExitApp Then Return

	  ; Get available loot remaining
	  Local $goldRemaining = Number(ScrapeText($raidLootCharMaps, $goldTextBox))
	  Local $elixRemaining = Number(ScrapeText($raidLootCharMaps, $elixTextBox))
	  Local $darkRemaining = Number(ScrapeText($raidLootCharMaps, $darkTextBox))

	  ; If < 1 min is left, then zap DE if the option is selected
	  If _GUICtrlButton_GetCheck($GUI_AutoRaidZapDE) = $BST_CHECKED And _
		 $darkRemaining >= GUICtrlRead($GUI_AutoRaidZapDEMin) And _
		 $darkStorageZapped = False Then

		 Local $time = ScrapeText($extraLargeCharacterMaps, $BattleTimeRemainingTextBox)
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
		 RandomWeightedCoords($LiveRaidScreenEndBattleButton, $xClick, $yClick)
		 MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)

		 ; Wait for confirmation button
		 Local $failCount=20
		 Do
			Local $pixelColor = PixelGetColor($cPos[0]+$LiveRaidScreenEndBattleConfirmButton[4], $cPos[1]+$LiveRaidScreenEndBattleConfirmButton[5])
			Local $pixMatch = InColorSphere($pixelColor, $LiveRaidScreenEndBattleConfirmButton[6], $LiveRaidScreenEndBattleConfirmButton[7])
			Sleep(100)
			$failCount-=1
		 Until $pixMatch=True Or $failCount<=0

		 If $failCount>0 Then
			RandomWeightedCoords($LiveRaidScreenEndBattleConfirmButton, $xClick, $yClick)
			MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)
			Sleep(500)
		 EndIf
	  EndIf

	  Sleep(1000)
   Next

   Sleep(2000)

   If WhereAmI() = $ScreenEndBattle Then
	  GrabFrameToFile("EndBattleFrame.bmp")
	  Local $goldWin = ScrapeText($extraLargeCharacterMaps, $EndBattleGoldTextBox)
	  Local $elixWin = ScrapeText($extraLargeCharacterMaps, $EndBattleElixTextBox)

	  Local $pixelColor = PixelGetColor($cPos[0]+$EndBattleDarkTextBox[6], $cPos[1]+$EndBattleDarkTextBox[7])
	  Local $pixMatch = InColorSphere($pixelColor, $EndBattleDarkTextBox[8], $EndBattleDarkTextBox[9])
	  Local $darkWin = $pixMatch ? ScrapeText($extraLargeCharacterMaps, $EndBattleDarkTextBox) : 0

	  $pixelColor = PixelGetColor($cPos[0]+$EndBattleCups1TextBox[6], $cPos[1]+$EndBattleCups1TextBox[7])
	  $pixMatch = InColorSphere($pixelColor, $EndBattleCups1TextBox[8], $EndBattleCups1TextBox[9])
	  Local $cupsWin = $pixMatch ? ScrapeText($extraLargeCharacterMaps, $EndBattleCups1TextBox) _
								 : ScrapeText($extraLargeCharacterMaps, $EndBattleCups2TextBox)

	  ConsoleWrite(_NowTime() & " Winnings this match: " & $goldWin & " / " & $elixWin & " / " & $darkWin & " / " & $cupsWin & @CRLF)

	  $goldWinnings += $goldWin
	  $elixWinnings += $elixWin
	  $darkWinnings += $darkWin
	  $cupsWinnings += $cupsWin
	  GUICtrlSetData($GUI_Winnings, "Winnings: " & $goldWinnings & " / " & $elixWinnings & " / " & $darkWinnings & " / " & $cupsWinnings)

	  ; Close battle end screen
	  RandomWeightedCoords($BattleHasEndedScreenReturnHomeButton, $xClick, $yClick)
	  MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)

	  ; Wait for main screen
	  Local $failCount=10
	  While WhereAmI()<>$ScreenMain And $ExitApp=False
		 Sleep(1000)
		 $failCount-=1
	  WEnd

	  If $failCount=0 Then
		 DebugWrite("Battle end - error waiting for main screen")
	  EndIf
   EndIf
EndFunc

Func FindTroopSlots(ByRef $slotIndex)
   Local $i, $j
   Local $slotLocs[11][2] = [ [0,59], [62,121], [124,183], [186,245], [248,307], [310,369], [372,431], [434,493], [496,555], [558,617], [620,679] ]

   ; Grab a frame
   GrabFrameToFile("AvailableTroopsFrame.bmp", 172, 456, 851, 531)

   For $i = 0 To $countOfSlots-1
	  Local $res = DllCall("ImageMatch.dll", "str", "FindMatch", "str", "AvailableTroopsFrame.bmp", _
		 "str", "Images\"&$TroopSlotBMPs[$i], "int", 3)
	  Local $split = StringSplit($res[0], "|", 2)

	  If $split[2] > $confidenceTroopSlotSearch Then
		 For $j = 0 To UBound($slotLocs)-1
			If $split[0]>=$slotLocs[$j][0] And $split[0]<=$slotLocs[$j][1] Then
			   $slotIndex[$i] = $j
			   ExitLoop
			EndIf
		 Next
	  Else
		 $slotIndex[$i] = -1
	  EndIf
   Next
EndFunc

Func GetTroopSlotTextBox(Const $slot, ByRef $box)
   Local $i
   For $i = 0 To 9
	  $box[$i] = $slot<>-1 ? $TroopSlotTextBoxes[$slot][$i] : 0
   Next
EndFunc

Func GetTroopSlotButton(Const $slot, ByRef $button)
   Local $i
   For $i = 0 To 7
	  $button[$i] = $slot<>-1 ? $TroopSlotButtons[$slot][$i] : 0
   Next
EndFunc

Func ZapDarkElixirStorage()
   Local $cPos = GetClientPos()
   Local $troopSlotIndex[$countOfSlots]
   FindTroopSlots($troopSlotIndex)

   Local $ltng = $troopSlotIndex[$lightningSpellSlot]

   If $ltng = -1 Then Return False

   Local $lightningButton[8]
   GetTroopSlotButton($ltng, $lightningButton)

   Local $availableLightnings = CountLightningSpells()

   ; Only zap if there are the maximum number of lightning spells available
   If $availableLightnings<$myMaxSpells Then
	  DebugWrite("Not zapping DE, " & $availableLightnings & " of " & $myMaxSpells & " lightning spells available.")
	  Return False
   EndIf


   ; Find DE storage
   GrabFrameToFile("DEStorageFrame.bmp", 235, 100, 789, 450)
   Local $bestMatch = 99, $bestConfidence = 0, $bestX = 0, $bestY = 0
   ScanFrameForBMP("DEStorageFrame.bmp", $DarkStorageBMPs, $confidenceDEStorageZap, $bestMatch, $bestConfidence, $bestX, $bestY)
   DebugWrite("DE search: " & $bestMatch & " " & $bestConfidence & " " & $bestX & " " & $bestY)

   ; If < $confidenceDEStorageZap confidence, then not good enough to spend spells
   If $bestConfidence < $confidenceDEStorageZap Then
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

   DebugWrite("Zapping DE, " & $availableLightnings & " of " & $myMaxSpells & " lightning spells available, confidence: " & $bestConfidence)

   ; Select lightning spell
   Local $xClick, $yClick
   RandomWeightedCoords($lightningButton, $xClick, $yClick)
   MouseClick("left", $cPos[0]+$xClick, $cPos[1]+$yClick)
   Sleep(500)

   ; Zap away
   DebugWrite("Zapping at " & $cPos[0]+$bestX+235+10 & "," & $cPos[1]+$bestY+100+30)
   Local $i
   For $i = 1 To $availableLightnings
	  _MouseClickFast($cPos[0]+$bestX+235+10, $cPos[1]+$bestY+100+30)
	  Sleep(1000)
   Next

   Sleep(6000)

   Return True
EndFunc

Func CountLightningSpells()
   Local $lightningTextBox[10]

   Local $troopSlotIndex[$countOfSlots]
   FindTroopSlots($troopSlotIndex)

   Local $ltng = $troopSlotIndex[$lightningSpellSlot]

   Local $count = 0
   If $ltng <> -1 Then
	  GetTroopSlotTextBox($ltng, $lightningTextBox)
	  $count = StringMid(ScrapeText($smallCharacterMaps, $lightningTextBox, 172, 456, 851, 531), 2)
   EndIf

   Return $count
EndFunc