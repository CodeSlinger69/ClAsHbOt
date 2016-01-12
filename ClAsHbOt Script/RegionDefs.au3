
; Text boxes - left, top, right, bottom, Text Color - center, radius,
; Present indicator x, y, color, radius
Global $rMyGoldTextBox[10] = [669, 23, 803, 35, 0xffffff, 9, 825, 29, 0xE1C434, 6]
Global $rMyElixTextBox[10] = [669, 72, 803, 84, 0xffffff, 9, 825, 78, 0xDB54D0, 6]
Global $rMyDarkTextBox[10] = [716, 120, 803, 132, 0xffffff, 9, 825, 126, 0x584660, 6]
Global $rMyGemsTextBoxNoDE[10] = [740, 118, 803, 130, 0xffffff, 9, 825, 124, 0xD0EC78, 6]
Global $rMyGemsTextBoxWithDE[10] = [740, 166, 803, 178, 0xffffff, 9, 825, 172, 0xD1EC78, 6]
Global $rMyCupsTextBox[10] = [64, 73, 105, 85, 0xffffff, 9, 0, 0, 0, 0]

Global $rGoldTextBox[10] = [47, 68, 120, 79, 0xfffbcc, 9, 34, 73, 0xF6ED5A, 6]
Global $rElixTextBox[10] = [47, 95, 120, 106, 0xffe8fd, 9, 34, 100, 0xE73EE3, 6]
Global $rDarkTextBox[10] = [47, 123, 120, 134, 0xf3f3f3, 9, 34, 128, 0x5C4969, 6]
Global $rCupsTextBoxNoDE[10] = [47, 135, 120, 146, 0xffffff, 9, 34, 140, 0xD5A528, 6]
Global $rCupsTextBoxWithDE[10] = [47, 165, 120, 176, 0xffffff, 9, 34, 170, 0xC59522, 6]

Global $rBarracksTroopBox[10] = [180, 269, 688, 468]
Global $rBarracksButtonOffset[4] = [0, 5, 84, 56]
Global $rBarracksWindowTextBox[10] = [134, 130, 295, 142, 0xffffff, 9, 0, 0, 0, 0]
Global $rRaidSlotTroopCountTextBox[10] = [0, 0, 0, 0, 0xffffff, 9, 0, 0, 0, 0]
Global $rCampSlotTroopCountTextBox[10] = [4, -17, 50, -5, 0xffffff, 9, 0, 0, 0, 0]
Global $rEndBattleGoldTextBox[10] = [340, 268, 440, 285, 0xffffff, 9, 0, 0, 0, 0]
Global $rEndBattleElixTextBox[10] = [340, 305, 440, 322, 0xffffff, 9, 0, 0, 0, 0]
Global $rEndBattleDarkTextBox[10] = [340, 342, 440, 359, 0xffffff, 9, 459, 355, 0x483855, 6]
Global $rEndBattleCupsNoDETextBox[10] = [340, 341, 440, 358, 0xffffff, 9, 460, 351, 0xBA8921, 6]
Global $rEndBattleCupsWithDETextBox[10] = [340, 376, 440, 393, 0xffffff, 9, 460, 387, 0xB18120, 6]
Global $rEndBattleBonusGoldTextBox[10] = [575, 317, 662, 328, 0xffffff, 9, 677, 322, 0xE8C431, 0]
Global $rEndBattleBonusElixTextBox[10] = [575, 347, 662, 358, 0xffffff, 9, 677, 352, 0xE555D8, 0]
Global $rEndBattleBonusDarkTextBox[10] = [575, 377, 662, 388, 0xffffff, 9, 677, 382, 0x584460, 0]

Global $rChatTextBoxAsOffset[10] = [-73, -46, 193, -35, 0xffffff, 140, 0, 0, 0, 0]

; Buttons
; Left, Top, Right, Bottom,
; Button Present Pixel Loc - x, y,
; Button Present Color - center, radius
Global $rScreenAndroidHomeCoCIconButton[8] = [0, 0, 60, 60, 0, 0, 0, 0]
Global $rScreenPlayStoreOpenButton[8] = [0, 0, 306, 37, 0, 0, 0, 0]
Global $rAndroidMessageButton1[8] = [156, 353, 703, 399, 175, 287, 0x33b5e5, 0]
Global $rAndroidMessageButton2[8] = [156, 363, 703, 409, 175, 278, 0x33b5e5, 0]
Global $rAndroidBackButton[8] = [29, 641, 62, 657, 32, 647, 0xA0A0A0, 0]
Global $rConfirmExitButton[8] = [441, 343, 579, 401, 509, 388, 0x5EAC10, 0]
Global $rMainScreenAttackButton[8] = [15, 519, 105, 606, 70, 556, 0xD46440, 6]
Global $rFindMatchScreenFindAMatchNoShieldButton[8] = [117, 453, 301, 535, 154, 517, 0xD84800, 6]
Global $rFindMatchScreenFindAMatchWithShieldButton[8] = [117, 430, 301, 511, 154, 494, 0xD84800, 6]
Global $rFindMatchScreenCloseWindowButton[8] = [809, 14, 844, 46, 827, 44, 0xC01018, 6]
Global $rWaitRaidScreenNextButton[8] = [688, 441, 832, 505, 709, 491, 0xD84600, 6]
Global $rLiveRaidScreenEndBattleButton[8] = [15, 475, 120, 507, 63, 502, 0xC00000, 0]
Global $rLiveRaidScreenEndBattleConfirmButton[8] = [441, 345, 579, 401, 513, 390, 0x5FAC10, 0]
Global $rMainScreenOpenChatButton[8] = [311, 296, 333, 352, 323, 349, 0xD04A18, 6]
Global $rMainScreenClosedChatButton[8] = [7, 296, 29, 352, 18, 349, 0xD04A18, 6]
Global $rChatWindowDonateButton[8] = [0, 0, 101, 38, 0, 0, 0, 0]
Global $rBattleHasEndedScreenReturnHomeButton[8] = [360, 486, 498, 544, 429, 537, 0x60B010, 6]
Global $rLiveReplayEndScreenReturnHomeButton[8] = [14, 519, 106, 608, 69, 547, 0x00660AD, 6]
Global $rWindowVilliageWasAttackedOkayButton[8] = [360, 433, 500, 491, 428, 477, 0x5FAC10, 6]
Global $rSafeAreaButton[8] = [780, 0, 859, 35, 0, 0, 0, 0]
Global $rCollectorButton[8] = [0, 0, 14, 28, 0, 0, 0, 0]
Global $rTrainTroopsWindowDequeueButton[8] = [555, 152, 573, 167, 563, 164, 0xD70101, 0]
Global $rArmyManagerButton[8] = [15, 459, 59, 503, 0, 0, 0, 0]
Global $rArmyManagerWindowCloseButton[8] = [704, 82, 738, 114, 722, 109, 0xC80408, 0]
Global $rArmyManagerWindowStandard1Button[8] = [231, 495, 285, 541, 236, 502, 0x888070, 0]
Global $rArmyManagerWindowStandard2Button[8] = [290, 495, 342, 541, 295, 502, 0x888070, 0]
Global $rArmyManagerWindowStandard3Button[8] = [348, 495, 402, 541, 353, 502, 0x888070, 0]
Global $rArmyManagerWindowStandard4Button[8] = [407, 495, 460, 541, 412, 502, 0x888070, 0]
Global $rArmyManagerWindowDark1Button[8] = [489, 495, 542, 541, 494, 502, 0x888070, 0]
Global $rArmyManagerWindowDark2Button[8] = [548, 495, 601, 541, 553, 502, 0x888070, 0]
Global $rArmyManagerWindowSpells1Button[8] = [628, 495, 681, 541, 633, 502, 0x888070, 0]
Global $rArmyManagerWindowSpells2Button[8] = [687, 495, 741, 541, 692, 502, 0x888070, 0]
Global $rRaidSlotsButton1[4] = [47, 534, 109, 614]
Global $rRaidSlotsButton2[4] = [117, 534, 179, 614]
Global $rVilliageGuardActiveInfoButton[8] = [457, 7, 474, 22, 445, 34, 0x6838A8, 6]
Global $rVilliageGuardRemoveButton[8] = [475, 201, 577, 233, 527, 227, 0xC00000, 0]
Global $rVilliageGuardRemoveConfirmationButton[8] = [441, 346, 579, 401, 510, 393, 0x60AE10, 0]

; Pixel color regions
; x, y, color, radius
Global $rScreenMainColor[4] = [209, 30, 0x2880C0, 0]
Global $rScreenLiveRaid1Color[4] = [779, 472, 0xFFFFFF, 0]
Global $rScreenLiveRaid2Color[4] = [73, 502, 0xC00000, 0]
Global $rArmyCampsFullColor[4] = [394, 136, 0xE84E50, 6]
Global $rRoyaltyHealthGreenColor[4] = [0, 0, 0x005BE10A, 90]
Global $rWindowChatDimmedColor[4] = [177, 22, 0x383628, 6]
Global $rNewChatMessagesColor[4] = [39, 289, 0xE80810, 6]
Global $rDeadBaseIndicatorColor[4] = [26, 28, 0x606460, 6]
Global $rFirstStarColor[4] = [719, 494, 0xC8C8C0, 6]
Global $rAttackingDisabledPoint1Color[4] = [218, 179, 0xff1919, 0]
Global $rAttackingDisabledPoint2Color[4] = [437, 180, 0xff1919, 0]
Global $rAttackingDisabledPoint3Color[4] = [613, 179, 0xff1919, 0]
Global $rWaitForPersonalBreakPoint1Color[4] = [164, 162, 0xff1919, 0]
Global $rWaitForPersonalBreakPoint2Color[4] = [434, 181, 0xff1919, 0]
Global $rWaitForPersonalBreakPoint3Color[4] = [698, 167, 0xff1919, 0]
Global $rArmyManagerSelectedColor[4] = [0, 0, 0xE8E8E0, 0]

; Bounding Boxes
; Left, Top, Right, Bottom
Global $rRaidTroopBox1[4] = [46, 514, 110, 599] ; first button only
Global $rRaidTroopBox2[4] = [116, 514, 810, 599] ; buttons 2-11
Global $rRaidButtonOffset[4] = [0, -17, 60, 61]
Global $rCampTroopBox1[4] = [134, 148, 728, 223] ; main troops
Global $rCampTroopBox2[4] = [421, 386, 600, 462] ; heroes
Global $rChatBox[4] = [0, 0, 302, 623]
Global $rDonateWindow[4] = [317, 1, 809, 623]
Global $rDonateButtonOffset[4] = [0, -19, 58, 58]
Global $rTHSnipeNorthDeployBox[4] = [$gScreenCenterDraggedDown[0]-20, 40, $gScreenCenterDraggedDown[0]+20, 70]
Global $rTHSnipeSouthDeployBox[4] = [$gScreenCenterDraggedUp[0]-20, 500, $gScreenCenterDraggedUp[0]+20, 520]
Global $rTHSnipeEastDeployBox[4] = [40, $gScreenCenterDraggedDown[1]-15, 70, $gScreenCenterDraggedDown[1]+15]
Global $rTHSnipeWestDeployBox[4] = [788, $gScreenCenterDraggedDown[1]-15, 818, $gScreenCenterDraggedDown[1]+15]
