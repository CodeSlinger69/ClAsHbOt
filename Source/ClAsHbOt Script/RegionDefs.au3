; Text boxes - left, top, right, bottom, Text Color - center, radius,
; Present indicator x, y, color, radius
Global $rMyGoldTextBox[10] =       [690,  24, 802,  36, 0xffffff, 9, 825,  30, 0xE7C438, 6]
Global $rMyElixTextBox[10] =       [690,  75, 802,  87, 0xffffff, 9, 825,  81, 0xDC54D1, 6]
Global $rMyDarkTextBox[10] =       [720, 124, 802, 136, 0xffffff, 9, 825, 132, 0x594561, 6]
Global $rMyGemsTextBoxNoDE[10] =   [735, 123, 802, 135, 0xffffff, 9, 825, 129, 0xD8ED79, 6]
Global $rMyGemsTextBoxWithDE[10] = [735, 172, 802, 184, 0xffffff, 9, 825, 178, 0xD8Ed7D, 6]
Global $rMyCupsTextBox[10] =       [ 71,  75, 120,  87, 0xffffff, 9, 0, 0, 0, 0]

Global $rGoldTextBox[10] = [50,  70, 125,  82, 0xfffbcc, 9, 34,  76, 0xF1EA51, 25]
Global $rElixTextBox[10] = [50,  99, 125, 111, 0xffe8fd, 9, 34, 105, 0xE049D0, 25]
Global $rDarkTextBox[10] = [50, 127, 125, 139, 0xf3f3f3, 9, 34, 133, 0x504060, 25]
Global $rCupsTextBox[10] = [50, 169, 125, 181, 0xffffff, 9, 34, 175, 0xC69624, 25]

Global $rBarracksTroopBox[10] = [170, 321, 697, 529]
Global $rBarracksButtonOffset[4] = [0, 5, 87, 56]
Global $rBarracksWindowTextBox[10] = [126, 178, 290, 190, 0xffffff, 9, 0, 0, 0, 0]
Global $rArmyOverviewWindowTextBox[10] = [143, 175, 275, 190, 0x494949, 60, 0, 0, 0, 0]
Global $rRaidSlotTroopCountTextBox[10] = [0, 0, 0, 0, 0xffffff, 9, 0, 0, 0, 0]
Global $rCampSlotTroopCountTextBox[10] = [4, -17, 50, -5, 0xffffff, 9, 0, 0, 0, 0]
Global $rEndBattleGoldTextBox[10] = [320, 319, 440, 337, 0xffffff, 9, 0, 0, 0, 0]
Global $rEndBattleElixTextBox[10] = [320, 358, 440, 376, 0xffffff, 9, 0, 0, 0, 0]
Global $rEndBattleDarkTextBox[10] = [320, 397, 440, 415, 0xffffff, 9, 459, 406, 0x75647A, 6]
Global $rEndBattleCupsNoDETextBox[10] = [320, 395, 440, 413, 0xffffff, 9, 459, 404, 0xE8CC28, 6]
Global $rEndBattleCupsWithDETextBox[10] = [320, 432, 440, 450, 0xffffff, 9, 459, 441, 0xE8CB28, 6]
Global $rEndBattleBonusGoldTextBox[10] = [590, 370, 670, 383, 0xffffff, 9, 684, 376, 0xF4EE5C, 0]
Global $rEndBattleBonusElixTextBox[10] = [590, 401, 670, 414, 0xffffff, 9, 684, 407, 0xE656D2, 0]
Global $rEndBattleBonusDarkTextBox[10] = [590, 432, 670, 445, 0xffffff, 9, 684, 438, 0x5C4A66, 0]

Global $rChatTextBoxAsOffset[10] = [-80, -54, 185, -40, 0xffffff, 140, 0, 0, 0, 0]

; Buttons
; Left, Top, Right, Bottom,
; Button Present Pixel Loc - x, y,
; Button Present Color - center, radius
Global $rScreenAndroidHomeCoCIconButton[8] = [0, 0, 68, 68, 0, 0, 0, 0]
Global $rScreenPlayStoreOpenButton[8] = [0, 0, 304, 35, 0, 0, 0, 0]
Global $rAndroidMessageButton1[8] = [156, 384, 703, 430, 157, 318, 0x33b5e5, 0]
Global $rAndroidMessageButton2[8] = [156, 393, 703, 439, 175, 308, 0x33b5e5, 0]
Global $rAndroidBackButton[8] = [29, 702, 62, 718, 0, 0, 0, 0] ; button is semi-transparent, can't use color effectively
Global $rConfirmExitButton[8] = [444, 400, 582, 456, 505, 447, 0x5FAC10, 0]
Global $rMainScreenAttackNoStarsButton[8] = [16, 625, 108, 680, 73, 664, 0xD56440, 6]
Global $rMainScreenAttackWithStarsButton[8] = [16, 625, 108, 680, 72, 670, 0xD46440, 6]
Global $rFindMatchScreenFindAMatchNoShieldButton[8] = [137, 519, 354, 617, 278, 610, 0xEFC628, 6]
Global $rFindMatchScreenFindAMatchWithShieldButton[8] = [138, 476, 354, 572, 279, 566, 0xEFC82F, 6]
Global $rFindMatchScreenCloseWindowButton[8] = [784, 17, 825, 55, 804, 32, 0xFFFFFF, 6]
Global $rWaitRaidScreenNextButton[8] = [710, 554, 838, 600, 730, 593, 0xD84800, 6]
Global $rLiveRaidScreenEndBattleButton[8] = [16, 578, 123, 609, 64, 605, 0xC00000, 0]
Global $rLiveRaidScreenEndBattleConfirmButton[8] = [444, 402, 582, 455, 491, 447, 0x5FAC10, 0]
Global $rMainScreenOpenChatButton[8] = [322, 353, 345, 408, 329, 382, 0xFFFFFF, 6]
Global $rMainScreenClosedChatButton[8] = [7, 353, 31, 408, 19, 381, 0xFFFFFF, 6]
Global $rChatWindowDonateButton[8] = [5, 5, 100, 35, 0, 0, 0, 0]
Global $rBattleHasEndedScreenReturnHomeButton[8] = [360, 549, 498, 604, 428, 599, 0x60B010, 6]
Global $rLiveReplayEndScreenReturnHomeButton[8] = [14, 624, 110, 680, 71, 654, 0x0971C0, 6]
Global $rWindowVillageWasAttackedOkayButton[8] = [360, 494, 500, 549, 429, 539, 0x5FAC10, 6]
Global $rSafeAreaButton[8] = [819, 0, 859, 20, 0, 0, 0, 0]
Global $rCollectorButton[8] = [0, 0, 14, 28, 0, 0, 0, 0]
Global $rTrainTroopsWindowDequeueButton[8] = [559, 201, 577, 216, 568, 213, 0xD00000, 0]
Global $rArmyManagerButton[8] = [15, 561, 62, 609, 31, 577, 0xF8F0E0, 0]
Global $rArmyManagerWindowCloseButton[8] = [712, 128, 748, 161, 728, 143, 0xFDFEFD, 6]
Global $rArmyManagerWindowStandard1Button[8] = [224, 555, 280, 605, 231, 563, 0x888070, 0]
Global $rArmyManagerWindowStandard2Button[8] = [284, 555, 340, 605, 291, 563, 0x888070, 0]
Global $rArmyManagerWindowStandard3Button[8] = [345, 555, 400, 605, 352, 563, 0x888070, 0]
Global $rArmyManagerWindowStandard4Button[8] = [405, 555, 460, 605, 412, 563, 0x888070, 0]
Global $rArmyManagerWindowDark1Button[8] =     [490, 555, 545, 605, 497, 563, 0x888070, 0]
Global $rArmyManagerWindowDark2Button[8] =     [551, 555, 606, 605, 558, 563, 0x888070, 0]
Global $rArmyManagerWindowSpells1Button[8] =   [634, 555, 689, 605, 641, 563, 0x888070, 0]
Global $rArmyManagerWindowSpells2Button[8] =   [695, 555, 751, 605, 702, 563, 0x888070, 0]
Global $rRaidSlotsButton1[4] = [35, 639, 93, 680]
Global $rRaidSlotsButton2[4] = [109, 639, 164, 680]
Global $rVillageGuardActiveInfoButton[8] = [459, 7, 475, 23, 460, 30, 0xE6EDF0, 6]
Global $rVillageGuardRemoveButton[8] = [476, 251, 583, 284, 526, 279, 0xC00000, 0]
Global $rVillageGuardRemoveConfirmationButton[8] = [444, 400, 582, 456, 512, 450, 0x60AE10, 0]
Global $rShopOrLayoutWindowsCloseButton[8] = [797, 22, 838, 59, 817, 37, 0xFFFFFF, 6]
Global $rProfileWindowCloseButton[8] = [809, 55, 848, 92, 828, 69, 0xFFFFFF, 6]
Global $rAchievementsWindowCloseButton[8] = [663, 159, 698, 193, 680, 171, 0xFFFFFF, 6]
Global $rSettingsWindowCloseButton[8] = [744, 101, 779, 134, 762, 115, 0xFFFFFF, 6]
Global $rLootCartCollectButton[8] = [392, 620, 469, 680, 435, 645, 0x9F3BB0, 6]
Global $rStarBonusWindowOkayButton[8] = [355, 469, 498, 526, 427, 513, 0x5FAC10, 6]
Global $rReloadDefensesOkayButton[8] = [442, 400, 584, 458, 513, 445, 0x5CAC10, 0]


; Pixel color regions
; x, y, color, radius
Global $rKingQueenHealthGreenColor[4] = [10, -8, 0x66EA09, 90]
Global $rWardenHealthGreenColor[4] = [10, -11, 0x4ED505, 90]
Global $rWindowChatDimmedColor[4] = [177, 22, 0x383628, 6]
Global $rNewChatMessagesColor[4] = [37, 356, 0xFFFFFF, 6]
Global $rDeadBaseIndicatorColor[4] = [26, 28, 0x606260, 6]
Global $rFirstStarColor[4] = [715, 599, 0xC8C9C1, 6]
Global $rWaitForPersonalBreakPoint1Color[4] = [164, 194, 0xff1919, 0] ; "You must wait until after your personal break..."
Global $rWaitForPersonalBreakPoint2Color[4] = [459, 211, 0xff1919, 0]
Global $rWaitForPersonalBreakPoint3Color[4] = [697, 195, 0xff1919, 0]
Global $rArmyManagerSelectedColor[4] = [0, 0, 0xE8E8E0, 0]
Global $rRaidTroopSelectedColor[4] = [5, -7, 0xffffff, 24]
Global $rZoomedOutFullColor[4] = [$gScreenCenter[0], 1, 0x000000, 0]

; Bounding Boxes
; Left, Top, Right, Bottom
Global $rBarracksButtonOffset[4] = [0, 6, 87, 60]
Global $rRaidTroopBox[4] = [10, 621, 849, 726]
Global $rRaidButtonOffset[4] = [0, -17, 62, 21]
Global $rCampTroopBox1[4] = [126, 197, 740, 275] ; main troops
Global $rCampTroopBox2[4] = [420, 442, 615, 525] ; heroes
Global $rChatBox[4] = [0, 0, 309, 680]
Global $rDonateButtonOffset[4] = [0, -19, 58, 58]
Global $rDonateTroopsBox[4] = [337, +32, 828, +211] ; y coords are offsets from first white pixel found, scanning top to bottom
Global $rDonateSpellsBox[4] = [343, +239, 548, +319] ; y coords are offsets from first white pixel found, scanning top to bottom
Global $rReloadDefensesBox[4] = [195, 617, 665, 702]
Global $rReloadDefensesButtonOffset[4] = [0, -18, 78, 42]
Global $rTHSnipeNorthDeployBox[4] = [$gScreenCenter[0]-20, $gNorthPoint[1]-20, $gScreenCenter[0]+20, $gNorthPoint[1]-10]
Global $rTHSnipeSouthDeployBox[4] = [$gScreenCenter[0]-20, $gSouthPoint[1]+10, $gScreenCenter[0]+20, $gSouthPoint[1]+20]
Global $rTHSnipeEastDeployBox[4] = [$gEastPoint[0]+20, $gScreenCenter[1]-15, $gEastPoint[0]+50, $gScreenCenter[1]+15]
Global $rTHSnipeWestDeployBox[4] = [$gWestPoint[0]-50, $gScreenCenter[1]-15, $gWestPoint[0]-20, $gScreenCenter[1]+15]
