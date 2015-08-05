
; Text boxes - left, top, right, bottom, Text Color - center, radius,
; Present indicator x, y, color, radius
Global $rGoldTextBox[10] = [42, 57, 120, 74, 0xfffbcc, 9, 30, 66, 0xeace3f, 6]
Global $rElixTextBox[10] = [42, 81, 120, 98, 0xffe8fd, 9, 30, 93, 0xd958d0, 6]
Global $rDarkTextBox[10] = [42, 107, 120, 124, 0xf3f3f3, 9, 30, 117, 0x53435f, 6]
Global $rCupsTextBox1[10] = [42, 107, 120, 124, 0xffffff, 9, 30, 117, 0xe7d99b, 6]
Global $rCupsTextBox2[10] = [42, 140, 120, 157, 0xffffff, 9, 30, 141, 0xf0e883, 6]

Global $rMyGoldTextBox[10] = [895, 20, 976, 31, 0xffffff, 9, 990, 24, 0xF3EC54, 6]
Global $rMyElixTextBox[10] = [895, 64, 976, 75, 0xffffff, 9, 0, 0, 0, 0]
Global $rMyDarkTextBox[10] = [895, 106, 976, 117, 0xffffff, 9, 0, 0, 0, 0]
Global $rMyGemsTextBox[10] = [917, 147, 976, 158, 0xffffff, 9, 0, 0, 0, 0]
Global $rMyCupsTextBox[10] = [50, 64, 104, 74, 0xffffff, 9, 0, 0, 0, 0]

Global $rBarracksWindowTextBox[10] = [262, 113, 395, 127, 0xffffff, 9, 0, 0, 0, 0]
Global $rBarracksTroopCountTextBox[10] = [0, 0, 0, 0, 0xffffff, 9, 0, 0, 0, 0]
Global $rEndBattleGoldTextBox[10] = [410, 236, 523, 252, 0xffffff, 9, 0, 0, 0, 0]
Global $rEndBattleElixTextBox[10] = [410, 269, 523, 285, 0xffffff, 9, 0, 0, 0, 0]
Global $rEndBattleDarkTextBox[10] = [410, 302, 523, 318, 0xffffff, 9, 542, 311, 0xf8f7f8, 6]
Global $rEndBattleCups1TextBox[10] = [410, 302, 523, 318, 0xffffff, 9, 541, 304, 0xf0e779, 6]
Global $rEndBattleCups2TextBox[10] = [410, 333, 523, 348, 0xffffff, 9, 541, 335, 0xf0e97b, 6]
Global $rEndBattleBonusGoldTextBox[10] = [645, 279, 715, 290, 0xffffff, 9, 730, 284, 0xf5ea5e, 0]
Global $rEndBattleBonusElixTextBox[10] = [645, 306, 715, 318, 0xffffff, 9, 730, 315, 0xdd58d1, 0]
Global $rEndBattleBonusDarkTextBox[10] = [645, 333, 715, 345, 0xffffff, 9, 730, 341, 0x4a3c58, 0] ; test for 7/1/15 client update

Global $rChatTextBox[10] = [0, 0, 233, 9, 0xffffff, 120, 0, 0, 0, 0]

; Buttons
; Left, Top, Right, Bottom,
; Button Present Pixel Loc - x, y,
; Button Present Color - center, radius
Global $rScreenAndroidHomeCoCIconButton[8] = [0, 0, 60, 60, 0, 0, 0, 0]
Global $rAndroidMessageButton[8] = [195, 317, 827, 363, 230, 250, 0x33b5e5, 0]
Global $rMainScreenAttackButton[8] = [13, 458, 93, 538, 49, 497, 0xD9645f, 6]
Global $rFindMatchScreenFindAMatchButton[8] = [99, 380, 265, 456, 108, 444, 0xD54400, 6]
Global $rFindMatchScreenCloseWindowButton[8] = [977, 11, 1010, 42, 997, 39, 0xd80407, 6]
Global $rWaitRaidScreenNextButton[8] = [871, 389, 1000, 448, 888, 429, 0xD84c00, 6]
Global $rLiveRaidScreenEndBattleButton[8] = [13, 418, 106, 448, 58, 443, 0xc00000, 0]
Global $rLiveRaidScreenEndBattleConfirmButton[8] = [522, 305, 644, 355, 627, 341, 0x60ac10, 0]
Global $rMainScreenOpenChatButton[8] = [274, 262, 296, 311, 282, 303, 0xD25018, 6]
Global $rMainScreenClosedChatButton[8] = [5, 262, 27, 311, 13, 303, 0xD35018, 6]
Global $rChatWindowDonateButton[8] = [0, 0, 82, 25, 0, 0, 0, 0]
Global $rBattleHasEndedScreenReturnHomeButton[8] = [450, 430, 572, 481, 514, 473, 0x60ac10, 6]
Global $rLiveReplayEndScreenReturnHomeButton[8] = [13, 458, 93, 538, 55, 493, 0xf8cbb6, 6] ; test for 7/1/15 client update
Global $rWindowVilliageWasAttackedOkayButton[8] = [450, 385, 574, 434, 475, 422, 0x5dac10, 6]
Global $rShieldIsActivePopupButton[8] = [522, 305, 644, 355, 484, 348, 0xc83c10, 6]
Global $rSafeAreaButton[8] = [990, 0, 1023, 35, 0, 0, 0, 0]
Global $rCollectorButton[8] = [0, 0, 22, 42, 0, 0, 0, 0]
Global $rTrainTroopsWindowDequeueButton[8] = [544, 149, 564, 171, 576, 146, 0xd40000, 0]
Global $rArmyManagerButton[8] = [14, 407, 52, 445, 0, 0, 0, 0]
Global $rArmyManagerWindowCloseButton[8] = [754, 71, 784, 101, 780, 91, 0xe00608, 0]
Global $rArmyManagerWindowStandard1Button[8] = [336, 438, 384, 478, 0, 0, 0, 0]
Global $rArmyManagerWindowStandard2Button[8] = [388, 438, 435, 478, 0, 0, 0, 0]
Global $rArmyManagerWindowStandard3Button[8] = [441, 438, 487, 478, 0, 0, 0, 0]
Global $rArmyManagerWindowStandard4Button[8] = [491, 438, 538, 478, 0, 0, 0, 0]
Global $rArmyManagerWindowDark1Button[8] = [564, 438, 611, 478, 0, 0, 0, 0]
Global $rArmyManagerWindowDark2Button[8] = [616, 438, 663, 478, 0, 0, 0, 0]
Global $rArmyManagerWindowSpells1Button[8] = [687, 438, 734, 478, 0, 0, 0, 0]
Global $rArmyManagerWindowSpells2Button[8] = [739, 438, 787, 478, 0, 0, 0, 0]
Global $rRaidSlotsButton1[4] = [173, 472, 228, 545]
Global $rRaidSlotsButton2[4] = [235, 472, 290, 545]

; Pixel color regions
; x, y, color, radius
Global $rScreenMainColor[4] = [196, 27, 0x2880C0, 0]
Global $rScreenLiveRaid1Color[4] = [1008, 441, 0xffffff, 0]
Global $rScreenLiveRaid2Color[4] = [101, 438, 0xc40000, 0]
Global $rArmyCampsFullColor[4] = [480, 120, 0xe84e50, 6]
Global $rRoyaltyHealthGreenColor[4] = [0, 0, 0x005BE10A, 90]
Global $rWindowDonateTroopsColor[4] = [6, 6, 0xffffff, 0]
Global $rWindowChatDimmedColor[4] = [235, 13, 0x383628, 6]
Global $rNewChatMessagesColor[4] = [28, 263, 0xe00000, 0]
Global $rDeadBaseIndicatorColor[4] = [23, 26, 0x5c5e60, 6]
Global $rFirstStarColor[4] = [899, 437, 0xc4c8c0, 6]
Global $rAttackingDisabledPoint1Color[4] = [331, 154, 0xff1919, 0]
Global $rAttackingDisabledPoint2Color[4] = [451, 159, 0xff1919, 0]
Global $rAttackingDisabledPoint3Color[4] = [613, 161, 0xff1919, 0]
