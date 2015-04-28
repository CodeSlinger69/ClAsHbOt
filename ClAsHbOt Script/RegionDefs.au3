
; Text boxes - left, top, right, bottom, Text Color - center, radius,
; Present indicator x, y, color, radius
Global $rGoldTextBox[10] = [42, 57, 120, 74, 0xfffbcc, 0, 30, 66, 0xe3c134, 6]
Global $rElixTextBox[10] = [42, 81, 120, 98, 0xffe8fd, 0, 30, 93, 0xe054d0, 6]
Global $rDarkTextBox[10] = [42, 107, 120, 124, 0xf3f3f3, 0, 30, 117, 0x503c58, 6]
Global $rCupsTextBox1[10] = [42, 107, 120, 124, 0xffffff, 0, 30, 117, 0xc09220, 6]
Global $rCupsTextBox2[10] = [42, 135, 120, 146, 0xffffff, 0, 30, 141, 0xc89822, 6]

Global $rMyGoldTextBox[10] = [895, 20, 976, 31, 0xffffff, 9, 990, 24, 0xF3EC53, 6]
Global $rMyElixTextBox[10] = [895, 64, 976, 75, 0xffffff, 9, 0, 0, 0, 0]
Global $rMyDarkTextBox[10] = [895, 106, 976, 117, 0xffffff, 9, 0, 0, 0, 0]
Global $rMyGemsTextBox[10] = [917, 147, 976, 158, 0xffffff, 9, 0, 0, 0, 0]
Global $rMyCupsTextBox[10] = [50, 64, 104, 74, 0xffffff, 9, 0, 0, 0, 0]

Global $rTrainTroopsWindowTextBox[10] = [425, 105, 600, 118, 0xffffff, 9, 0, 0, 0, 0]
Global $rTrainTroopsWindowBarbarianCostTextBox[10] = [306, 287, 351, 299, 0xffffff, 9, 0, 0, 0, 0]
Global $rTrainTroopsWindowArcherCostTextBox[10] = [398, 287, 443, 299, 0xffffff, 9, 0, 0, 0, 0]
Global $rTrainTroopsWindowGiantCostTextBox[10] = [489, 287, 534, 299, 0xffffff, 9, 0, 0, 0, 0]
Global $rTrainTroopsWindowGoblinCostTextBox[10] = [580, 287, 625, 299, 0xffffff, 9, 0, 0, 0, 0]
Global $rTrainTroopsWindowWallBreakerCostTextBox[10] = [671, 287, 716, 299, 0xffffff, 9, 0, 0, 0, 0]
Global $rTrainTroopsWindowBalloonCostTextBox[10] = [306, 378, 351, 390, 0xffffff, 9, 0, 0, 0, 0]
Global $rTrainTroopsWindowWizardCostTextBox[10] =  [398, 378, 443, 390, 0xffffff, 9, 0, 0, 0, 0]
Global $rTrainTroopsWindowHealerCostTextBox[10] =  [489, 378, 534, 390, 0xffffff, 9, 0, 0, 0, 0]
Global $rTrainTroopsWindowDragonCostTextBox[10] =  [570, 378, 625, 390, 0xffffff, 9, 0, 0, 0, 0]
Global $rTrainTroopsWindowPekkaCostTextBox[10] =   [661, 378, 716, 390, 0xffffff, 9, 0, 0, 0, 0]
Global $rTroopSlotCountTextBox[10] = [0, 0, 0, 0, 0xffffff, 9, 0, 0, 0, 0]
Global $rBattleTimeRemainingTextBox[10] = [465, 24, 555, 41, 0xffffff, 9, 0, 0, 0, 0]
Global $rEndBattleGoldTextBox[10] = [410, 236, 523, 252, 0xffffff, 9, 0, 0, 0, 0]
Global $rEndBattleElixTextBox[10] = [410, 269, 523, 285, 0xffffff, 9, 0, 0, 0, 0]
Global $rEndBattleDarkTextBox[10] = [410, 302, 523, 318, 0xffffff, 9, 542, 311, 0xf4f4f8, 5]
Global $rEndBattleCups1TextBox[10] = [410, 302, 523, 318, 0xffffff, 9, 541, 304, 0xf0e77a, 0]
Global $rEndBattleCups2TextBox[10] = [410, 333, 523, 348, 0xffffff, 9, 541, 335, 0xf0e97b, 0]

Global $ChatTextBox[10] = [0, 0, 233, 10, 0xffffff, 120, 0, 0, 0, 0]

; Buttons
; Left, Top, Right, Bottom,
; Button Present Pixel Loc - x, y,
; Button Present Color - center, radius
Global $ScreenAndroidHomeCoCIconButton[8] = [0, 0, 60, 60, 0, 0, 0, 0]
Global $AndroidMessageButton[8] = [195, 317, 827, 363, 230, 250, 0x33b5e5, 0]
Global $MainScreenAttackButton[8] = [13, 458, 93, 538, 49, 497, 0xD86460, 0]
Global $FindMatchScreenFindAMatchButton[8] = [99, 380, 265, 456, 108, 444, 0xD54400, 0]
Global $FindMatchScreenCloseWindowButton[8] = [977, 11, 1010, 42, 997, 39, 0xd80406, 0]
Global $WaitRaidScreenNextButton[8] = [871, 375, 1000, 434, 888, 429, 0xD54300, 0]
Global $LiveRaidScreenEndBattleButton[8] = [13, 406, 106, 435, 59, 430, 0xc00000, 0]
Global $LiveRaidScreenEndBattleConfirmButton[8] = [522, 305, 644, 355, 627, 341, 0x60ac10, 0]
Global $MainScreenOpenChatButton[8] = [274, 262, 296, 311, 282, 303, 0xD35018, 3]
Global $MainScreenClosedChatButton[8] = [5, 262, 27, 311, 13, 303, 0xD35018, 3]
Global $ChatWindowDonateButton[8] = [0, 0, 82, 25, 0, 0, 0, 0]
Global $BattleHasEndedScreenReturnHomeButton[8] = [450, 430, 572, 481, 514, 473, 0x60ac10, 0]
Global $LiveReplayEndScreenReturnHomeButton[8] = [13, 458, 93, 538, 55, 493, 0xf0b096, 3]
Global $WindowVilliageWasAttackedOkayButton[8] = [450, 385, 574, 434, 475, 422, 0x5dac10, 0]
Global $ShieldIsActivePopupButton[8] = [522, 305, 644, 355, 484, 348, 0xc83c10, 0]
Global $SafeAreaButton[8] = [990, 0, 1023, 35, 0, 0, 0, 0]
Global $CollectorButton[8] = [0, 0, 22, 42, 0, 0, 0, 0]
Global $BarracksButton[8] = [0, 0, 23, 19, 0, 0, 0, 0]
Global $BarracksPanelTrainTroops1Button[8] = [601, 455, 668, 522, 633, 486, 0x708bb0, 6]
Global $BarracksPanelTrainTroops2Button[8] = [641, 455, 708, 522, 673, 486, 0x708bb0, 6]
Global $BarracksPanelTrainTroops3Button[8] = [560, 455, 627, 522, 594, 486, 0x708bb0, 6]
Global $BarracksPanelUpgradingButton[8] = [560, 455, 627, 522, 569, 515, 0x6eb40a, 0]
Global $TrainTroopsWindowPrevButton[8] = [198, 263, 241, 296, 225, 290, 0xf08038, 0]
Global $TrainTroopsWindowNextButton[8] = [782, 263, 808, 296, 796, 290, 0xf08038, 0]
Global $TrainTroopsWindowCloseButton[8] = [752, 100, 783, 129, 0, 0, 0, 0]
Global $TrainTroopsWindowBarbarianButton[8] = [292, 253, 372, 305, 0, 0, 0, 0]
Global $TrainTroopsWindowArcherButton[8] = [383, 263, 463, 305, 0, 0, 0, 0]
Global $TrainTroopsWindowGoblinButton[8] = [565, 263, 645, 305, 0, 0, 0, 0]
Global $TrainTroopsWindowGiantButton[8] = [474, 263, 554, 305, 0, 0, 0, 0]
Global $TrainTroopsWindowBreakerButton[8] = [657, 263, 737, 305, 0, 0, 0, 0]
Global $TrainTroopsWindowBalloonButton[8] = [292, 355, 372, 398, 0, 0, 0, 0]
Global $TrainTroopsWindowWizardButton[8] = [383, 355, 463, 398, 0, 0, 0, 0]
Global $TrainTroopsWindowHealerButton[8] = [474, 355, 554, 398, 0, 0, 0, 0]
Global $TrainTroopsWindowDragonButton[8] = [565, 355, 645, 398, 0, 0, 0, 0]
Global $TrainTroopsWindowPekkaButton[8] = [657, 355, 737, 398, 0, 0, 0, 0]
Global $TrainTroopsWindowLightningButton[8] = [292, 263, 372, 305, 0, 0, 0, 0]
Global $TrainTroopsWindowHealButton[8] = [383, 263, 463, 305, 0, 0, 0, 0]
Global $TrainTroopsWindowRageButton[8] = [474, 263, 554, 305, 0, 0, 0, 0]
Global $TrainTroopsWindowJumpButton[8] = [565, 263, 645, 305, 0, 0, 0, 0]
Global $TrainTroopsWindowFreezeButton[8] = [657, 263, 737, 305, 0, 0, 0, 0]
Global $TrainTroopsWindowDequeueButton[8] = [526, 143, 576, 193, 574, 157, 0xd20301, 0]
Global $rArmyCampInfoButton[8] = [438, 455, 504, 522, 471, 498, 0x286da0, 0]
Global $rArmyCampInfoScreenCloseWindowButton[8] = [726, 98, 756, 127, 752, 123, 0xd80406, 0]

; Pixel color regions
; x, y, color, radius
Global $ScreenMainColor[4] = [196, 27, 0x2880C0, 0]
Global $ScreenLiveRaid1Color[4] = [949, 439, 0x000000, 0]
Global $ScreenLiveRaid2Color[4] = [99, 429, 0xC00000, 0]
Global $WindowTrainTroopsStandardColor1[4] = [334, 249, 0xf8ed4b, 2] ; colored
Global $WindowTrainTroopsStandardColor2[4] = [334, 249, 0xdedede, 2] ; grayed-out
Global $WindowTrainTroopsDarkColor1[4] = [317, 250, 0x285c90, 2] ; colored
Global $WindowTrainTroopsDarkColor2[4] = [317, 250, 0x525252, 2] ; grayed-out
Global $WindowTrainTroopsSpellsColor1[4] = [339, 271, 0x084ff1, 2] ; colored
Global $WindowTrainTroopsSpellsColor2[4] = [339, 271, 0x4b4b4b, 2] ; grayed-out
Global $WindowTrainTroopsFullColor[4] = [267, 422, 0xd04048, 2]
Global $WindowTrainTroopsInfoColor[4] = [250, 124, 0x48c208, 2]
Global $RoyaltyHealthGreenColor[4] = [0, 0, 0x005BE10A, 90] ; Health bar above king/queen in troop box
Global $WindowDonateTroopsColor[4] = [6, 6, 0xf8fcff, 0]
Global $WindowChatDimmedColor[4] = [235, 13, 0x3a3729, 0] ; Likely due to Donate Troops Window being open
Global $NewChatMessagesColor[4] = [21, 262, 0xe00200, 0]

; AutoRaid deploy locations
Global $NWDeployBoxes[21][4], $NEDeployBoxes[21][4], $SWDeployBoxes[21][4], $SEDeployBoxes[21][4]
Global $NWSafeDeployBox[4] = [280, 170, 300, 190]
Global $NESafeDeployBox[4] = [735, 170, 755, 190]
Global $SWSafeDeployBox[4] = [280, 295, 300, 315]
Global $SESafeDeployBox[4] = [735, 295, 755, 315]
