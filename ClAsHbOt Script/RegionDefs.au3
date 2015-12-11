
; Text boxes - left, top, right, bottom, Text Color - center, radius,
; Present indicator x, y, color, radius
Global $rMyGoldTextBox[10] = [793, 28, 956, 42, 0xffffff, 9, 990, 35, 0xF3D140, 6]
Global $rMyElixTextBox[10] = [793, 87, 956, 101, 0xffffff, 9, 990, 94, 0xFAB3F4, 6]
Global $rMyDarkTextBox[10] = [850, 144, 956, 158, 0xffffff, 9, 990, 151, 0xFFFFFF, 0]
Global $rMyGemsTextBoxNoDE[10] = [877, 144, 956, 158, 0xffffff, 9, 860, 151, 0xFFFFFF, 0]
Global $rMyGemsTextBoxWithDE[10] = [877, 201, 956, 215, 0xffffff, 9, 860, 209, 0xFFFFFF, 0]
Global $rMyCupsTextBox[10] = [82, 88, 134, 102, 0xffffff, 9, 0, 0, 0, 0]

Global $rGoldTextBox[10] = [57, 82, 148, 97, 0xfffbcc, 9, 40, 89, 0xF6EC56, 6]
Global $rElixTextBox[10] = [57, 115, 148, 130, 0xffe8fd, 9, 40, 122, 0xE046D0, 6]
Global $rDarkTextBox[10] = [57, 148, 148, 163, 0xf3f3f3, 9, 40, 155, 0x514160, 6]
Global $rCupsTextBox1[10] = [57, 162, 148, 177, 0xffffff, 9, 40, 169, 0xBD8C24, 6]
Global $rCupsTextBox2[10] = [57, 197, 148, 212, 0xffffff, 9, 40, 204, 0xC59425, 6]

Global $rBarracksTroopBox[10] = [211, 325, 822, 563]
Global $rBarracksButtonOffset[4] = [0, 0, 104, 76]
Global $rBarracksWindowTextBox[10] = [158, 157, 345, 172, 0xffffff, 9, 0, 0, 0, 0]
Global $rBarracksTroopCountTextBox[10] = [0, 0, 0, 0, 0xffffff, 9, 0, 0, 0, 0]
Global $rEndBattleGoldTextBox[10] = [388, 322, 524, 345, 0xffffff, 9, 0, 0, 0, 0]
Global $rEndBattleElixTextBox[10] = [388, 367, 524, 390, 0xffffff, 9, 0, 0, 0, 0]
Global $rEndBattleDarkTextBox[10] = [388, 411, 524, 434, 0xffffff, 9, 549, 424, 0x584563, 6]
Global $rEndBattleCups1TextBox[10] = [388, 410, 524, 433, 0xffffff, 9, 549, 424, 0xB88820, 6]
Global $rEndBattleCups2TextBox[10] = [388, 453, 524, 476, 0xffffff, 9, 549, 467, 0xB38620, 6]
Global $rEndBattleBonusGoldTextBox[10] = [703, 381, 790, 397, 0xffffff, 9, 808, 390, 0xE2C332, 0]
Global $rEndBattleBonusElixTextBox[10] = [703, 417, 790, 434, 0xffffff, 9, 808, 429, 0xD654CE, 0]
Global $rEndBattleBonusDarkTextBox[10] = [703, 1, 790, 1, 0xffffff, 9, 730, 341, 0x4a3c58, 0] ; Adjust for 12/10 update

Global $rChatTextBox[10] = [0, 0, 233, 9, 0xffffff, 120, 0, 0, 0, 0] ; Adjust for 12/10 update

; Buttons
; Left, Top, Right, Bottom,
; Button Present Pixel Loc - x, y,
; Button Present Color - center, radius
Global $rScreenAndroidHomeCoCIconButton[8] = [0, 0, 67, 67, 0, 0, 0, 0]
Global $rScreenPlayStoreOpenButton[8] = [0, 0, 150, 40, 0, 0, 0, 0]
Global $rAndroidMessageButton1[8] = [196, 414, 826, 466, 213, 348, 0x33b5e5, 0]
Global $rAndroidMessageButton2[8] = [196, 424, 826, 476, 213, 339, 0x33b5e5, 0]
Global $rMainScreenAttackButton[8] = [18, 625, 127, 731, 86, 670, 0xD86440, 6]
Global $rFindMatchScreenFindAMatchButton[8] = [141, 546, 363, 645, 180, 620, 0xD84800, 6]
Global $rFindMatchScreenCloseWindowButton[8] = [963, 17, 1004, 56, 984, 53, 0xC00F16, 6]
Global $rWaitRaidScreenNextButton[8] = [817, 532, 990, 609, 840, 600, 0xD24300, 6]
Global $rLiveRaidScreenEndBattleButton[8] = [17, 570, 145, 611, 29, 603, 0xc00000, 0]
Global $rLiveRaidScreenEndBattleConfirmButton[8] = [526, 413, 692, 484, 594, 464, 0x60AD10, 0]
Global $rMainScreenOpenChatButton[8] = [373, 357, 404, 425, 390, 420, 0xD34C14, 6]
Global $rMainScreenClosedChatButton[8] = [6, 357, 38, 425, 20, 420, 0xD34C13, 6]
Global $rChatWindowDonateButton[8] = [0, 0, 82, 25, 0, 0, 0, 0] ; Adjust for 12/10 update
Global $rBattleHasEndedScreenReturnHomeButton[8] = [428, 588, 594, 653, 561, 645, 0x60AC10, 6]
Global $rLiveReplayEndScreenReturnHomeButton[8] = [13, 460, 93, 537, 66, 487, 0xf9eedc, 6] ; Adjust for 12/10 update
Global $rWindowVilliageWasAttackedOkayButton[8] = [450, 385, 574, 434, 475, 422, 0x5dac10, 6] ; Adjust for 12/10 update
Global $rShieldIsActivePopupButton[8] = [522, 305, 644, 355, 484, 348, 0xc83c10, 6] ; Adjust for 12/10 update
Global $rSafeAreaButton[8] = [990, 0, 1023, 35, 0, 0, 0, 0]
Global $rCollectorButton[8] = [0, 0, 19, 35, 0, 0, 0, 0]
Global $rTrainTroopsWindowDequeueButton[8] = [662, 183, 684, 201, 679, 197, 0xD50104, 0]
Global $rArmyManagerButton[8] = [18, 554, 71, 606, 0, 0, 0, 0]
Global $rArmyManagerWindowCloseButton[8] = [841, 98, 883, 138, 860, 135, 0xBF151A, 0]
Global $rArmyManagerWindowStandard1Button[8] = [272, 596, 337, 654, 281, 605, 0x888070, 0]
Global $rArmyManagerWindowStandard2Button[8] = [342, 596, 407, 654, 351, 605, 0x888070, 0]
Global $rArmyManagerWindowStandard3Button[8] = [413, 596, 477, 654, 422, 605, 0x888070, 0]
Global $rArmyManagerWindowStandard4Button[8] = [483, 596, 548, 654, 492, 605, 0x888070, 0]
Global $rArmyManagerWindowDark1Button[8] = [582, 596, 647, 654, 591, 605, 0x888070, 0]
Global $rArmyManagerWindowDark2Button[8] = [653, 596, 718, 654, 662, 605, 0x888070, 0]
Global $rArmyManagerWindowSpells1Button[8] = [750, 596, 814, 654, 759, 605, 0x888070, 0]
Global $rArmyManagerWindowSpells2Button[8] = [821, 596, 886, 654, 830, 605, 0x888070, 0]
Global $rRaidSlotsButton1[4] = [52, 643, 127, 743]
Global $rRaidSlotsButton2[4] = [136, 643, 212, 743]

; Pixel color regions
; x, y, color, radius
Global $rScreenMainColor[4] = [250, 37, 0x2880C0, 0]
Global $rScreenLiveRaid1Color[4] = [934, 568, 0xFFFFFF, 0]
Global $rScreenLiveRaid2Color[4] = [30, 604, 0xC00000, 0]
Global $rArmyCampsFullColor[4] = [481, 167, 0xE84C50, 6]
Global $rRoyaltyHealthGreenColor[4] = [0, 0, 0x005BE10A, 90] ; Adjust for 12/10 update
Global $rWindowDonateTroopsColor[4] = [6, 6, 0xffffff, 0]
Global $rWindowChatDimmedColor[4] = [319, 27, 0x383628, 6]
Global $rNewChatMessagesColor[4] = [34, 349, 0xE80810, 6]
Global $rDeadBaseIndicatorColor[4] = [31, 25, 0x585A58, 6]
Global $rFirstStarColor[4] = [854, 595, 0xC0C8C0, 6]
Global $rAttackingDisabledPoint1Color[4] = [258, 218, 0xff1919, 0]
Global $rAttackingDisabledPoint2Color[4] = [472, 215, 0xff1919, 0]
Global $rAttackingDisabledPoint3Color[4] = [704, 221, 0xff1919, 0]
Global $rArmyManagerSelectedColor[4] = [0, 0, 0xE8E8E0, 0]

