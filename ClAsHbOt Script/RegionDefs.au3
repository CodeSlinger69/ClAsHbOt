
; Text boxes - left, top, right, bottom, Text Color - center, radius,
; Present indicator x, y, color, radius
Global $rGoldTextBox[10] = [42, 57, 120, 74, 0xfffbcc, 9, 30, 66, 0xe3c134, 6]
Global $rElixTextBox[10] = [42, 81, 120, 98, 0xffe8fd, 9, 30, 93, 0xe054d0, 6]
Global $rDarkTextBox[10] = [42, 107, 120, 124, 0xf3f3f3, 9, 30, 117, 0x503c58, 6]
Global $rCupsTextBox1[10] = [42, 107, 120, 124, 0xffffff, 9, 30, 117, 0xc09220, 6]
Global $rCupsTextBox2[10] = [42, 135, 120, 146, 0xffffff, 9, 30, 141, 0xc89822, 6]

Global $rMyGoldTextBox[10] = [895, 20, 976, 31, 0xffffff, 9, 990, 24, 0xF3EC53, 6]
Global $rMyElixTextBox[10] = [895, 64, 976, 75, 0xffffff, 9, 0, 0, 0, 0]
Global $rMyDarkTextBox[10] = [895, 106, 976, 117, 0xffffff, 9, 0, 0, 0, 0]
Global $rMyGemsTextBox[10] = [917, 147, 976, 158, 0xffffff, 9, 0, 0, 0, 0]
Global $rMyCupsTextBox[10] = [50, 64, 104, 74, 0xffffff, 9, 0, 0, 0, 0]

Global $rBarracksWindowTextBox[10] = [425, 105, 600, 118, 0xffffff, 9, 0, 0, 0, 0]
Global $rBarracksTroopCountTextBox[10] = [0, 0, 0, 0, 0xffffff, 9, 0, 0, 0, 0]
Global $rBarracksTroopCostTextBox[10] = [306, 287, 351, 299, 0xffffff, 9, 0, 0, 0, 0]
Global $rArmyCampTroopCountTextBox[10] = [0, 0, 0, 0, 0xffffff, 9, 0, 0, 0, 0]
Global $rBattleTimeRemainingTextBox[10] = [465, 24, 555, 41, 0xffffff, 9, 0, 0, 0, 0]
Global $rEndBattleGoldTextBox[10] = [410, 236, 523, 252, 0xffffff, 9, 0, 0, 0, 0]
Global $rEndBattleElixTextBox[10] = [410, 269, 523, 285, 0xffffff, 9, 0, 0, 0, 0]
Global $rEndBattleDarkTextBox[10] = [410, 302, 523, 318, 0xffffff, 9, 542, 311, 0xf4f4f8, 5]
Global $rEndBattleCups1TextBox[10] = [410, 302, 523, 318, 0xffffff, 9, 541, 304, 0xf0e77a, 0]
Global $rEndBattleCups2TextBox[10] = [410, 333, 523, 348, 0xffffff, 9, 541, 335, 0xf0e97b, 0]

Global $rChatTextBox[10] = [0, 0, 233, 9, 0xffffff, 120, 0, 0, 0, 0]

; Buttons
; Left, Top, Right, Bottom,
; Button Present Pixel Loc - x, y,
; Button Present Color - center, radius
Global $rScreenAndroidHomeCoCIconButton[8] = [0, 0, 60, 60, 0, 0, 0, 0]
Global $rAndroidMessageButton[8] = [195, 317, 827, 363, 230, 250, 0x33b5e5, 0]
Global $rMainScreenAttackButton[8] = [13, 458, 93, 538, 49, 497, 0xD86460, 0]
Global $rFindMatchScreenFindAMatchButton[8] = [99, 380, 265, 456, 108, 444, 0xD54400, 0]
Global $rFindMatchScreenCloseWindowButton[8] = [977, 11, 1010, 42, 997, 39, 0xd80406, 0]
Global $rWaitRaidScreenNextButton[8] = [871, 375, 1000, 434, 888, 429, 0xD54300, 0]
Global $rLiveRaidScreenEndBattleButton[8] = [13, 406, 106, 435, 59, 430, 0xc00000, 0]
Global $rLiveRaidScreenEndBattleConfirmButton[8] = [522, 305, 644, 355, 627, 341, 0x60ac10, 0]
Global $rMainScreenOpenChatButton[8] = [274, 262, 296, 311, 282, 303, 0xD35018, 3]
Global $rMainScreenClosedChatButton[8] = [5, 262, 27, 311, 13, 303, 0xD35018, 3]
Global $rChatWindowDonateButton[8] = [0, 0, 82, 25, 0, 0, 0, 0]
Global $rBattleHasEndedScreenReturnHomeButton[8] = [450, 430, 572, 481, 514, 473, 0x60ac10, 0]
Global $rLiveReplayEndScreenReturnHomeButton[8] = [13, 458, 93, 538, 55, 493, 0xf0b096, 3]
Global $rWindowVilliageWasAttackedOkayButton[8] = [450, 385, 574, 434, 475, 422, 0x5dac10, 0]
Global $rShieldIsActivePopupButton[8] = [522, 305, 644, 355, 484, 348, 0xc83c10, 0]
Global $rSafeAreaButton[8] = [990, 0, 1023, 35, 0, 0, 0, 0]
Global $rCollectorButton[8] = [0, 0, 22, 42, 0, 0, 0, 0]
Global $rBarracksButton[8] = [0, 0, 23, 19, 0, 0, 0, 0]
Global $rBarracksPanelTrainTroops1Button[8] = [600, 455, 666, 522, 632, 483, 0x708cb0, 6]
Global $rBarracksPanelTrainTroops2Button[8] = [641, 455, 708, 522, 673, 486, 0x708cb0, 6]  ; x1, x2 might need to be adjusted after 2015-04-30 update
Global $rBarracksPanelTrainTroops3Button[8] = [560, 455, 627, 522, 594, 486, 0x708cb0, 6]  ; x1, x2 might need to be adjusted after 2015-04-30 update
Global $rBarracksPanelUpgradingButton[8] = [560, 455, 627, 522, 569, 515, 0x6eb40a, 0]
Global $rBarracksWindowPrevButton[8] = [198, 263, 241, 296, 225, 290, 0xf08038, 0]
Global $rBarracksWindowNextButton[8] = [782, 263, 808, 296, 796, 290, 0xf08038, 0]
Global $rBarracksWindowCloseButton[8] = [752, 100, 783, 129, 0, 0, 0, 0]
Global $rTrainTroopsWindowDequeueButton[8] = [526, 143, 576, 193, 574, 157, 0xd20301, 0]
Global $rArmyCampInfoButton[8] = [438, 454, 506, 522, 464, 481, 0x387cb0, 0]
Global $rArmyCampInfoScreenCloseWindowButton[8] = [726, 98, 756, 127, 752, 123, 0xd80406, 0]

; Pixel color regions
; x, y, color, radius
Global $rScreenMainColor[4] = [196, 27, 0x2880C0, 0]
Global $rScreenLiveRaid1Color[4] = [949, 439, 0x000000, 0]
Global $rScreenLiveRaid2Color[4] = [99, 429, 0xC00000, 0]
Global $rWindowBarracksStandardColor1[4] = [334, 249, 0xf8ed4b, 2] ; colored
Global $rWindowBarracksStandardColor2[4] = [334, 249, 0xdedede, 2] ; grayed-out
Global $rWindowBarracksDarkColor1[4] = [317, 250, 0x285c90, 2] ; colored
Global $rWindowBarracksDarkColor2[4] = [317, 250, 0x525252, 2] ; grayed-out
Global $rWindowBarracksSpellsColor1[4] = [339, 271, 0x084ff1, 2] ; colored
Global $rWindowBarracksSpellsColor2[4] = [339, 271, 0x4b4b4b, 2] ; grayed-out
Global $rWindowBarracksFullColor[4] = [267, 422, 0xd04048, 2]
Global $rWindowBarracksInfoColor[4] = [250, 124, 0x48c208, 2]
Global $rRoyaltyHealthGreenColor[4] = [0, 0, 0x005BE10A, 90] ; Health bar above king/queen in troop box
Global $rWindowDonateTroopsColor[4] = [6, 6, 0xf8fcff, 0]
Global $rWindowChatDimmedColor[4] = [235, 13, 0x3a3729, 0] ; Likely due to Donate Troops Window being open
Global $rNewChatMessagesColor[4] = [21, 262, 0xe00200, 0]
Global $rDeadBaseIndicatorColor[4] = [23, 26, 0x5b5e60, 0]

; AutoRaid deploy locations
Global $NWDeployBoxes[21][4], $NEDeployBoxes[21][4], $SWDeployBoxes[21][4], $SEDeployBoxes[21][4]
Global $NWSafeDeployBox[4] = [280, 170, 300, 190]
Global $NESafeDeployBox[4] = [735, 170, 755, 190]
Global $SWSafeDeployBox[4] = [280, 295, 300, 315]
Global $SESafeDeployBox[4] = [735, 295, 755, 315]
