; Scraper Globals
Global $MaxCharWidth = 20

; Text boxes - left, top, right, bottom, Text Color - center, radius,
; Present indicator x, y, color, radius
Global $goldTextBox[10] = [42, 57, 120, 74, 0xfffbcc, 0, 30, 66, 0xe3c134, 6]
Global $elixTextBox[10] = [42, 81, 120, 98, 0xffe8fd, 0, 30, 93, 0xe054d0, 6]
Global $darkTextBox[10] = [42, 107, 120, 124, 0xf3f3f3, 0, 30, 117, 0x503c58, 6]
Global $cupsTextBox1[10] = [42, 107, 120, 124, 0xffffff, 0, 30, 117, 0xc09220, 6]
Global $cupsTextBox2[10] = [42, 135, 120, 146, 0xffffff, 0, 30, 141, 0xc89822, 6]

Global $myGoldTextBox[10] = [895, 20, 976, 31, 0xffffff, 9, 990, 24, 0xF3EC53, 6]
Global $myElixTextBox[10] = [895, 64, 976, 75, 0xffffff, 9, 0, 0, 0, 0]
Global $myDarkTextBox[10] = [895, 106, 976, 117, 0xffffff, 9, 0, 0, 0, 0]
Global $myGemsTextBox[10] = [917, 147, 976, 158, 0xffffff, 9, 0, 0, 0, 0]
Global $myCupsTextBox[10] = [50, 64, 104, 74, 0xffffff, 9, 0, 0, 0, 0]

Global $TrainTroopsWindowTextBox[10] = [425, 105, 600, 118, 0xffffff, 9, 0, 0, 0, 0]
Global $TrainTroopsWindowBarbarianCostTextBox[10] = [306, 287, 351, 299, 0xffffff, 9, 0, 0, 0, 0]
Global $TrainTroopsWindowArcherCostTextBox[10] = [398, 287, 443, 299, 0xffffff, 9, 0, 0, 0, 0]
Global $TrainTroopsWindowGiantCostTextBox[10] = [489, 287, 534, 299, 0xffffff, 9, 0, 0, 0, 0]
Global $TrainTroopsWindowGoblinCostTextBox[10] = [580, 287, 625, 299, 0xffffff, 9, 0, 0, 0, 0]
Global $TrainTroopsWindowWallBreakerCostTextBox[10] = [671, 287, 716, 299, 0xffffff, 9, 0, 0, 0, 0]
Global $TrainTroopsWindowBalloonCostTextBox[10] = [306, 378, 351, 390, 0xffffff, 9, 0, 0, 0, 0]
Global $TrainTroopsWindowWizardCostTextBox[10] =  [398, 378, 443, 390, 0xffffff, 9, 0, 0, 0, 0]
Global $TrainTroopsWindowHealerCostTextBox[10] =  [489, 378, 534, 390, 0xffffff, 9, 0, 0, 0, 0]
Global $TrainTroopsWindowDragonCostTextBox[10] =  [570, 378, 625, 390, 0xffffff, 9, 0, 0, 0, 0]
Global $TrainTroopsWindowPekkaCostTextBox[10] =   [661, 378, 716, 390, 0xffffff, 9, 0, 0, 0, 0]

Global $TroopSlotTextBoxes[11][10] = [ _
   [6, 5, 52, 17, 0xffffff, 9, 0, 0, 0, 0], _
   [68, 5, 114, 17, 0xffffff, 9, 0, 0, 0, 0], _
   [130, 5, 176, 17, 0xffffff, 9, 0, 0, 0, 0], _
   [192, 5, 238, 17, 0xffffff, 9, 0, 0, 0, 0], _
   [254, 5, 300, 17, 0xffffff, 9, 0, 0, 0, 0], _
   [316, 5, 362, 17, 0xffffff, 9, 0, 0, 0, 0], _
   [378, 5, 424, 17, 0xffffff, 9, 0, 0, 0, 0], _
   [440, 5, 486, 17, 0xffffff, 9, 0, 0, 0, 0], _
   [502, 5, 548, 17, 0xffffff, 9, 0, 0, 0, 0], _
   [564, 5, 610, 17, 0xffffff, 9, 0, 0, 0, 0], _
   [626, 5, 672, 17, 0xffffff, 9, 0, 0, 0, 0] _
] ; Note, these are offset from top left corner of troop box group 172,456; not from client 0,0

Global $BattleTimeRemainingTextBox[10] = [465, 24, 555, 41, 0xffffff, 9, 0, 0, 0, 0]

Global $EndBattleGoldTextBox[10] = [410, 236, 523, 252, 0xffffff, 9, 0, 0, 0, 0]
Global $EndBattleElixTextBox[10] = [410, 269, 523, 285, 0xffffff, 9, 0, 0, 0, 0]
Global $EndBattleDarkTextBox[10] = [410, 302, 523, 318, 0xffffff, 9, 542, 311, 0xf4f4f8, 5]
Global $EndBattleCups1TextBox[10] = [410, 302, 523, 318, 0xffffff, 9, 541, 304, 0xf0e77a, 0]
Global $EndBattleCups2TextBox[10] = [410, 333, 523, 348, 0xffffff, 9, 541, 335, 0xf0e97b, 0]

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
Global $MainScreenOpenChatButton[8] = [274, 262, 296, 311, 282, 303, 0xD25018, 0]
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
Global $TroopSlotButtons[11][8] = [ _
   [174, 458, 229, 529, 0, 0, 0, 0], _
   [236, 458, 291, 529, 0, 0, 0, 0], _
   [298, 458, 352, 529, 0, 0, 0, 0], _
   [360, 458, 414, 529, 0, 0, 0, 0], _
   [421, 458, 476, 529, 0, 0, 0, 0], _
   [483, 458, 538, 529, 0, 0, 0, 0], _
   [545, 458, 600, 529, 0, 0, 0, 0], _
   [607, 458, 661, 529, 0, 0, 0, 0], _
   [669, 458, 723, 529, 0, 0, 0, 0], _
   [731, 458, 785, 529, 0, 0, 0, 0], _
   [792, 458, 847, 529, 0, 0, 0, 0] _
]

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
Global $RoyaltyHealthGreenColor[4] = [0, 0, 0x005BE10A, 37] ; Health bar above king/queen in troop box

; AutoRaid deploy locations
Global $NWDeployBoxes[21][4], $NEDeployBoxes[21][4], $SWDeployBoxes[21][4], $SEDeployBoxes[21][4]
Global $NWSafeDeployBox[4] = [280, 170, 300, 190]
Global $NESafeDeployBox[4] = [735, 170, 755, 190]
Global $SWSafeDeployBox[4] = [280, 295, 300, 315]
Global $SESafeDeployBox[4] = [735, 295, 755, 315]


; Raid loot gold 13, elix 3, dark 3, cups 6
Global $raidLootCharMaps[25][$MaxCharWidth+2] = [ _
 ["0", 10, 254, 511, 511, 257, 257, 257, 259, 511, 510, 124], _
 ["1", 3, 128, 511, 384], _
 ["1", 2, 511, 384], _
 ["1", 1, 511], _
 ["2", 7, 14, 527, 543, 561, 545, 993, 960], _
 ["3", 8, 1, 513, 513, 545, 867, 1022, 398, 8], _
 ["4", 8, 24, 120, 248, 904, 512, 1023, 1023, 510], _
 ["5", 7, 96, 993, 993, 529, 534, 542, 542], _
 ["6", 8, 254, 510, 1023, 545, 545, 529, 535, 30], _
 ["6", 7, 8510, 1023, 545, 545, 529, 535, 30], _
 ["7", 6, 515, 527, 572, 1008, 960, 768], _
 ["8", 8, 926, 1023, 33, 33, 545, 1011, 926, 12], _
 ["9", 7, 992, 993, 529, 528, 562, 1022, 508], _
 ["1", 2, 6511, 384], _
 ["8", 9, 390, 991, 1023, 33, 33, 545, 1023, 926, 12], _
 ["9", 8, 596, 992, 993, 529, 528, 566, 1022, 508], _
 ["1", 2, 248, 511], _
 ["1", 2, 255, 511], _
 ["1", 2, 511, 510], _
 ["3", 6, 1, 257, 257, 503, 462, 4], _
 ["5", 6, 993, 993, 529, 530, 542, 542], _
 ["5", 7, 224, 497, 273, 273, 270, 270, 12], _
 ["6", 7, 510, 433, 273, 273, 19, 30, 8], _
 ["8", 7, 479, 305, 16, 16, 371, 462, 14], _
 ["9", 7, 240, 497, 273, 273, 272, 510, 510] ]

; MyGold, MyElixir, MyDark, MyGems, TroopCounts
 Global $smallCharacterMaps[14][$MaxCharWidth+2] = [ _
 ["0", 8, 126, 255, 129, 129, 129, 255, 255, 126], _
 ["1", 2, 127, 255], _
 ["2", 6, 15, 271, 283, 305, 481, 224], _
 ["3", 6, 257, 273, 273, 499, 222, 14], _
 ["4", 7, 28, 124, 204, 388, 255, 255, 12], _
 ["5", 6, 241, 241, 401, 282, 286, 270], _
 ["6", 7, 254, 254, 403, 273, 275, 286, 12], _
 ["7", 6, 256, 263, 286, 504, 480, 384], _
 ["7", 4, 263, 286, 504, 480], _
 ["8", 7, 206, 511, 273, 273, 305, 511, 142], _
 ["9", 7, 240, 241, 401, 402, 414, 254, 24], _
 ["1", 3, 256, 511, 511], _
 ["74", 12, 263, 286, 504, 448, 256, 28, 124, 204, 388, 255, 255, 12], _
 ["x", 7, 1, 231, 126, 60, 60, 103, 193] ]

; MyCups, TrainTroops Window
Global $largeCharacterMaps[25][$MaxCharWidth+2] = [ _
 ["0", 10, 508, 1023, 2047, 1795, 1539, 1539, 1539, 2047, 2047, 1022], _
 ["1", 4, 512, 1023, 1023, 1023], _
 ["1", 4, 256, 511, 511, 384], _
 ["2", 8, 1055, 1087, 1087, 3187, 3171, 4067, 4034, 1922], _
 ["3", 8, 1025, 3075, 3139, 3171, 3687, 2047, 1982, 798], _
 ["4", 10, 56, 248, 1016, 1944, 1560, 1560, 2047, 2047, 2046, 24], _
 ["5", 8, 2016, 2019, 2019, 1123, 1062, 1086, 1086, 1084], _
 ["6", 9, 510, 2046, 2047, 1635, 3171, 3171, 3175, 3198, 62], _
 ["7", 7, 1024, 1031, 1055, 1150, 2040, 2016, 1920], _
 ["7", 7, 512, 519, 543, 636, 1008, 960, 768], _
 ["8", 10, 798, 1950, 2047, 1123, 3169, 3171, 4087, 2047, 1854, 28], _
 ["9", 9, 992, 2017, 2019, 1123, 1059, 1126, 2046, 2046, 508], _
 ["/", 8, 1, 7, 31, 124, 496, 1984, 1792, 3072], _
 ["C", 8, 510, 1022, 2046, 1998, 1538, 1539, 1027, 1027], _
 ["S", 9, 482, 2019, 2019, 2019, 1639, 1086, 3134, 3134, 56], _
 ["T", 10, 1536, 1536, 1536, 2047, 2047, 2047, 1984, 1536, 1536, 1024], _
 ["a", 9, 14, 287, 287, 275, 257, 419, 511, 511, 126], _
 ["e", 9, 126, 254, 254, 402, 275, 273, 497, 497, 496], _
 ["i", 3, 639, 1663, 1663], _
 ["l", 3, 1984, 2047, 2047], _
 ["n", 10, 255, 511, 496, 480, 504, 126, 31, 30, 510, 510], _
 ["p", 9, 1023, 1023, 1023, 524, 520, 520, 1016, 1016, 496], _
 ["r", 9, 511, 511, 511, 264, 264, 284, 511, 511, 227], _
 ["s", 8, 241, 241, 497, 403, 286, 286, 286, 12], _
 ["t", 8, 128, 128, 510, 2047, 2047, 384, 128, 128] ]

 ; Battle end window
 Global $extraLargeCharacterMaps[13][$MaxCharWidth+2] = [ _
["0", 13, 2044, 4094, 8191, 8191, 7951, 6147, 6147, 6147, 6151, 8191, 8191, 8191, 4092], _
["1", 5, 2048, 4064, 4095, 4095, 4095], _
["2", 10, 4158, 4223, 4223, 4351, 4327, 4551, 7111, 8071, 8070, 7942], _
["3", 11, 2, 4099, 4099, 4227, 4231, 4551, 8191, 8190, 7806, 7294, 48], _
["4", 13, 112, 496, 2040, 4080, 7984, 7216, 6192, 8191, 8191, 8191, 8190, 48, 48], _
["5", 10, 8064, 16323, 16323, 16323, 12743, 12487, 12542, 12542, 12414, 12412], _
["6", 12, 1020, 16382, 16382, 16383, 14791, 12739, 12483, 12487, 12543, 8446, 254, 240], _
["7", 10, 12288, 12290, 12319, 12415, 12798, 16376, 16352, 16256, 15872, 14336], _
["8", 13, 1052, 15934, 16383, 16383, 12739, 8643, 8643, 12739, 16383, 16383, 15998, 6268, 48], _
["9", 11, 1984, 16320, 16323, 16323, 12483, 12487, 12486, 14830, 16382, 16380, 4092], _
["-", 4, 7, 7, 6, 6], _
["m", 16, 1023, 2047, 2047, 2016, 2016, 2040, 254, 127, 252, 1008, 1984, 4064, 4095, 4095, 4095, 1], _
["s", 10, 480, 995, 2019, 2019, 1635, 1590, 1598, 1086, 1086, 60] ]

Global $CoCIconBMPs[1] = ["CoCIcon.bmp"]
Global $TownHallBMPs[4] = ["TH7.bmp", "TH8.bmp", "TH9.bmp", "TH10.bmp"]
Global $CollectorFullBMPs[3] = ["FullGoldCollector.bmp", "FullElixCollector.bmp", "FullDarkCollector.bmp"]
Global $BarracksBMPs[2] = ["BarracksL10.bmp", "BarracksL9.bmp"]
; TODO: L12 collectors for non-XMas
Global $CollectorBMPs[8] = ["GoldCollectorL12.bmp", "GoldCollectorL11.bmp", "GoldCollectorL10.bmp", "GoldCollectorL9.bmp", _
						    "ElixCollectorL12.bmp", "ElixCollectorL11.bmp", "ElixCollectorL10.bmp", "ElixCollectorL9.bmp"]
Global $DarkStorageBMPs[10] = ["DarkStorageL6.25.bmp", "DarkStorageL6.00.bmp", "DarkStorageL5.25.bmp", "DarkStorageL4.50.bmp", _
							   "DarkStorageL4.00.bmp", "DarkStorageL3.00.bmp", "DarkStorageL2.25.bmp", "DarkStorageL2.00.bmp", _
							   "DarkStorageL1.25.bmp", "DarkStorageL1.00.bmp"]

; TODO: get bmps for jump and freeze
Global $TroopSlotBMPs[17] = ["SlotBarbarian.bmp", "SlotArcher.bmp", "SlotGoblin.bmp", "SlotGiant.bmp", _
						     "SlotWallBreaker.bmp", "SlotBalloon.bmp", "SlotWizard.bmp", "SlotHealer.bmp", _
							 "SlotDragon.bmp", "SlotPekka.bmp", "SlotKing.bmp", "SlotQueen.bmp", _
							 "SlotLightningSpell.bmp", "SlotHealSpell.bmp", "SlotRageSpell.bmp", "SlotDummy.bmp", "SlotDummy.bmp"]

Func InitScraper()
   _GDIPlus_Startup()

   ; Auto Raid deploy locations
   Local $x, $y, $i

   $y = 325
   $i=0
   For $x = 70 To 470 Step 20
	  $NWDeployBoxes[$i][0] = $x
	  $NWDeployBoxes[$i][1] = $y
	  $NWDeployBoxes[$i][2] = $x+60
	  $NWDeployBoxes[$i][3] = $y+40
	  ;DebugWrite("NW Box: " & $i & " " & $NWDeployBoxes[$i][0] & "  " & $NWDeployBoxes[$i][1] & "  " & $NWDeployBoxes[$i][2] & "  " & $NWDeployBoxes[$i][3] & @CRLF)
	  $i+=1
	  $y-=14
   Next

   $y = 325
   $i=0
   For $x = 950 To 550 Step -20
	  $NEDeployBoxes[$i][0] = $x-60
	  $NEDeployBoxes[$i][1] = $y
	  $NEDeployBoxes[$i][2] = $x
	  $NEDeployBoxes[$i][3] = $y+40
	  ;DebugWrite("NE Box: " & $i & " " & $NEDeployBoxes[$i][0] & "  " & $NEDeployBoxes[$i][1] & "  " & $NEDeployBoxes[$i][2] & "  " & $NEDeployBoxes[$i][3] & @CRLF)
	  $i+=1
	  $y-=14
   Next

   $y = 125
   $i=0
   For $x = 70 To 470 Step 20
	  $SWDeployBoxes[$i][0] = $x
	  $SWDeployBoxes[$i][1] = $y
	  $SWDeployBoxes[$i][2] = $x+60
	  $SWDeployBoxes[$i][3] = $y+40
	  ;DebugWrite("SW Box: " & $i & " " & $SWDeployBoxes[$i][0] & "  " & $SWDeployBoxes[$i][1] & "  " & $SWDeployBoxes[$i][2] & "  " & $SWDeployBoxes[$i][3] & @CRLF)
	  $i+=1
	  $y+=14
   Next

   $y = 125
   $i=0
   For $x = 950 To 550 Step -20
	  $SEDeployBoxes[$i][0] = $x-60
	  $SEDeployBoxes[$i][1] = $y
	  $SEDeployBoxes[$i][2] = $x
	  $SEDeployBoxes[$i][3] = $y+40
	  ;DebugWrite("SE Box: " & $i & " " & $SEDeployBoxes[$i][0] & "  " & $SEDeployBoxes[$i][1] & "  " & $SEDeployBoxes[$i][2] & "  " & $SEDeployBoxes[$i][3] & @CRLF)
	  $i+=1
	  $y+=14
   Next

EndFunc

Func ExitScraper()
   _GDIPlus_Shutdown()
EndFunc


Func ScrapeText(Const ByRef $charMapArray, Const ByRef $textBox, Const $x1 = 0, Const $y1 = 0, Const $x2 = 0, Const $y2 = 0)
   ; Grab frame
   Local $cPos = GetClientPos()
   Local $hBitmap = _ScreenCapture_Capture("", $cPos[0]+$x1, $cPos[1]+$y1, $cPos[2]+$x2, $cPos[3]+$y2, False)
   Local $frame = _GDIPlus_BitmapCreateFromHBITMAP($hBitmap)

   ; Figure out dimensions of text box
   Local $w = $textBox[2] - $textBox[0] + 1
   Local $h = $textBox[3] - $textBox[1] + 1
   Local $x, $y
   Local $pix[$textBox[2]-$textBox[0]+1][$textBox[3]-$textBox[1]+1]
   Local $pY = 0

   ; Scan text box left to right and create a map of foreground pixels
   For $y = $textBox[1] To $textBox[3]

	  ; See if this line contains valid pixels
	  Local $BlankLine = True
	  For $x = $textBox[0] To $textBox[2]
		 Local $pixelColor = _GDIPlus_BitmapGetPixel($frame, $x, $y)

		 If InColorSphere($pixelColor, $textBox[4], $textBox[5]) = True Then
			$BlankLine = False
			ExitLoop
		 EndIf
	  Next

	  If $BlankLine = False Then
		 For $x = $textBox[0] To $textBox[2]
			Local $pixelColor = _GDIPlus_BitmapGetPixel($frame, $x, $y)

			If InColorSphere($pixelColor, $textBox[4], $textBox[5]) = True Then
			   $pix[$x-$textBox[0]][$pY] = 1
			Else
			   $pix[$x-$textBox[0]][$pY] = 0
			EndIf
		 Next
		 $pY+=1
	  EndIf
   Next

   ; Clean up GDI and WinAPI objects
   _GDIPlus_BitmapDispose($frame)
   _WinAPI_DeleteObject($hBitmap)

   ; Scan left to right through foreground pixel map to identify individual numbers
   Local $charStart = -1, $charEnd = -1, $blankCol, $textString = ""
   For $x = 0 To $w-1

	  ; See if this column is blank
	  $blankCol = True
	  Local $by
	  For $by = 0 To $pY-1
		 If $pix[$x][$by] = 1 Then
			$blankCol = False
			ExitLoop
		 EndIf
	  Next

	  If $blankCol = True Or $charEnd-$charStart+1 = $MaxCharWidth Then
		 ; If we have already found the start of a char, then we have a new char to process
		 If $charStart <> -1 Then
			; Find the first non blank row, starting from the bottom
			Local $cX, $cY, $bottomOfChar = -1
			For $cY = $pY-1 To 0 Step -1
			   For $cX = $charStart To $charEnd
				  If $pix[$cX][$cY] = 1 Then
					 $bottomOfChar = $cY
					 ExitLoop
				  EndIf
			   Next
			   If $bottomOfChar <> -1 Then
				  ExitLoop
			   EndIf
			Next

			; Calculate colValues for this character
			Local $colValues[$charEnd-$charStart+1]
			For $cX = $charStart To $charEnd
			   Local $factor = 1
			   $colValues[$cX-$charStart] = 0
			   For $cY = $bottomOfChar To 0 Step -1
				  $colValues[$cX-$charStart] += ($pix[$cX][$cY] * $factor)
				  $factor*=2
			   Next
			Next

			; Find a match
			Local $bestMatchIndex = FindCharInArray($charMapArray, $colValues, $charEnd-$charStart+1)


			; Debug
			If $ScraperDebug Then
			   DebugWrite($charStart & " to " & $charEnd & ": ")
			   If $bestMatchIndex <> -1 Then
				  DebugWrite($charMapArray[$bestMatchIndex][0] & ": ")
			   Else
				  DebugWrite("?" & ": ")
			   EndIf
			   For $cX = $charStart To $charEnd
				  DebugWrite($colValues[$cX-$charStart] & ", ")
			   Next
			   DebugWrite(@CRLF)
			EndIf

			; Add char to growing String
			If $bestMatchIndex <> -1 Then
			   $textString &= $charMapArray[$bestMatchIndex][0]
			Else
			   $textString &= "?"
			EndIf

			; Reset char flags
			$charStart = -1
			$charEnd = -1
		 EndIf

	  Else
		 ; This is not a blank column, so mark the char start/end as appropriate
		 If $charStart = -1 Then
			$charStart = $x
		 EndIf

		 $charEnd = $x
	  EndIf
   Next

   ; Debug
   If $ScraperDebug Then
	  DebugWrite($textString & @CRLF)
	  DebugWrite("-------------------------------------------------------------------------" & @CRLF)
	  For $y = 0 To $pY-1
		DebugWrite("|")
		 For $x = 0 To $w-1
			If $pix[$x][$y] = 1 Then
			   DebugWrite("x")
			Else
			   DebugWrite(" ")
			EndIf
		 Next
		 DebugWrite("|" & @CRLF)
	  Next
	  DebugWrite("-------------------------------------------------------------------------" & @CRLF)
   EndIf

   Return $textString
EndFunc

Func GetTownHallLevel(Const $x1 = -1, Const $y1 = -1, Const $x2 = -1, Const $y2 = -1)
   DebugWrite("GetTownHallLevel() start")

   ; Method = 0: CV_TM_SQDIFF, 1: CV_TM_SQDIFF_NORMED, 2: CV_TM_CCORR, 3: CV_TM_CCORR_NORMED
   ;          4: CV_TM_CCOEFF, 5: CV_TM_CCOEFF_NORMED

   ; Returns best TH level match, 0 if no good match
   Local $bestMatch = 99, $bestConfidence = 0, $bestX = 0, $bestY = 0

   ; Grab and scan frame
   If $x1 = -1 Then
	   ; full frame
	  GrabFrameToFile("TownHallCenterFrame.bmp")
   Else
	  ; Partial frame for Snipable TH search
	  GrabFrameToFile("TownHallCenterFrame.bmp", $x1, $y1, $x2, $y2)
   EndIf

   ScanFrameForBMP("TownHallCenterFrame.bmp", $TownHallBMPs, $confidenceTownHallSearch, $bestMatch, $bestConfidence, $bestX, $bestY)

   If $x1 = -1 Then
	  ; No good match, scan top of screen
	  If $bestMatch = 99 Then
		 ZoomOut(False)
		 If $ExitApp Then Return 0
		 MoveScreenDownToTop(False)
		 If $ExitApp Then Return 0
		 GrabFrameToFile("TownHallTopFrame.bmp")
		 MoveScreenUpToCenter()
		 If $ExitApp Then Return 0
		 ScanFrameForBMP("TownHallTopFrame.bmp", $TownHallBMPs, $confidenceTownHallSearch, $bestMatch, $bestConfidence, $bestX, $bestY)
	  EndIf

	  ; No good match, scan bottom of screen
	  If $bestMatch = 99 Then
		 MoveScreenUpToBottom(False)
		 If $ExitApp Then Return 0
		 GrabFrameToFile("TownHallBotFrame.bmp")
		 MoveScreenDownToCenter()
		 If $ExitApp Then Return 0
		 ScanFrameForBMP("TownHallBotFrame.bmp", $TownHallBMPs, $confidenceTownHallSearch, $bestMatch, $bestConfidence, $bestX, $bestY)
	  EndIf
   EndIf

   If $bestMatch = 99 Then
	  ;DebugWrite("Unknown TH Level" & @CRLF)
	  Return 0
   Else
	  ;DebugWrite("Likely TH Level " & $bestMatch+7 & @CRLF)
	  Return $bestMatch+7
   EndIf
EndFunc

Func ScanFrameForBMP(Const $filename, Const ByRef $bmpArray, Const $threshold, ByRef $bestMatch, ByRef $bestConfidence, ByRef $bestX, ByRef $bestY)
   Local $i

   For $i = 0 to UBound($bmpArray)-1
	  Local $res = DllCall("ImageMatch.dll", "str", "FindMatch", "str", $filename, _
		 "str", "Images\"&$bmpArray[$i], "int", 3)

	  ;DebugWrite($bmpArray[$i] & ": " & $res[0] & @CRLF)

	  Local $split = StringSplit($res[0], "|", 2)
	  If $split[2] > $threshold And $split[2] > $bestConfidence Then
		 $bestX = $split[0]
		 $bestY = $split[1]
		 $bestConfidence = $split[2]
		 $bestMatch = $i
	  EndIf
   Next
EndFunc

Func GetMyLootNumbers()
   ;DebugWrite("GetMyLootNumbers()")

   ; My loot is only scrapable on main screen
   If WhereAmI()<>$ScreenMain Then Return

   ; My loot info can't be seen for some reason
   Local $cPos = GetClientPos()
   Local $pixelColor = PixelGetColor($cPos[0]+$myGoldTextBox[6], $cPos[1]+$myGoldTextBox[7])
   If InColorSphere($pixelColor, $myGoldTextBox[8], $myGoldTextBox[9]) = False Then Return

   ; Scrape text fields
   Local $MyGold = Number(ScrapeText($smallCharacterMaps, $myGoldTextBox))
   Local $MyElix = Number(ScrapeText($smallCharacterMaps, $myElixTextBox))
   Local $MyDark = Number(ScrapeText($smallCharacterMaps, $myDarkTextBox))
   Local $MyGems = Number(ScrapeText($smallCharacterMaps, $myGemsTextBox))
   GUICtrlSetData($GUI_MyGold, $MyGold)
   GUICtrlSetData($GUI_MyElix, $MyElix)
   GUICtrlSetData($GUI_MyDark, $MyDark)
   GUICtrlSetData($GUI_MyGems, $MyGems)

   Local $MyCups = Number(ScrapeText($largeCharacterMaps, $myCupsTextBox))
   GUICtrlSetData($GUI_MyCups, $MyCups)
EndFunc

Func InColorSphere(Const $color, Const $center, Const $radius)
   Local $r = BitShift(BitAND($color, 0x00FF0000), 16) ; 0x00FF0000
   Local $g = BitShift(BitAND($color, 0x0000FF00), 8) ; 0x0000FF00
   Local $b = BitAND($color, 0x000000FF) ; 0x000000FF

   Local $rC = BitShift(BitAND($center, 0x00FF0000), 16) ; 0x00FF0000
   Local $gC = BitShift(BitAND($center, 0x0000FF00), 8) ; 0x0000FF00
   Local $bC = BitAND($center, 0x000000FF) ; 0x000000FF

   Local $d = Sqrt( ($rC-$r)^2 + ($gC-$g)^2 + ($bC-$b)^2 )
   ;DebugWrite("InColorSphere: " & Hex($color) & " " & Hex($center) & " " & $d)

   If $d <= $radius Then Return True

   Return False
EndFunc

Func DistBetweenTwoPoints(Const $x1, Const $y1, Const $x2, Const $y2)
  Return Sqrt( ($x1-$x2)^2 + ($y1-$y2)^2 )
EndFunc

Func FindCharInArray(Const ByRef $charMapArray, Const ByRef $nums, Const $count)
   ; Loop through each row in the $charMapArray array
   Local $i, $bestWeightedHD = 9999, $bestMatch = -1
   For $i = 0 To UBound($charMapArray)-1

	  ; Loop through each column in the passed in array of numbers
	  Local $c, $totalHD = 0, $pixels = 0
	  For $c = 0 To $count-1
		 $totalHD += CalcHammingDistance($nums[$c], $charMapArray[$i][$c+2])
		 $pixels += BitCount($nums[$c])
	  Next

	  Local $weightedHD = $totalHD / $pixels

	  If $weightedHD < $bestWeightedHD Then
		 $bestWeightedHD = $weightedHD
		 $bestMatch = $i
	  EndIf
   Next

   ; Debug
   ;DebugWrite("Best " & $bestMatch & " " & $bestWeightedHD & @CRLF)

   Return $bestMatch
EndFunc

Func CalcHammingDistance(Const $x, Const $y)
   Local $dist = 0, $val = BitXOR($x, $y)

   While $val <> 0
	  $dist += 1
	  $val = BitAND($val, $val-1)
   WEnd

   Return $dist;
EndFunc

Func BitCount($n)
   Local $c = 0

   While $n <> 0
	  $c += 1
	  $n = BitAND($n, $n-1)
   WEnd

   Return $c
EndFunc

; Returns the absolute position of the client window
Func GetClientPos()
   Local $cPos[4]

   ; Get absolute coordinates of client area
   Local $hWnd = WinGetHandle($title)
   Local $cSize = WinGetClientSize($title)

   Local $tPoint = DllStructCreate("int X;int Y")
   DllStructSetData($tPoint, "X", 0)
   DllStructSetData($tPoint, "Y", 0)

   _WinAPI_ClientToScreen($hWnd, $tPoint)
   $cPos[0] = DllStructGetData($tPoint, "X")
   $cPos[1] = DllStructGetData($tPoint, "Y")
   $cPos[2] = $cPos[0]+$cSize[0]-1
   $cPos[3] = $cPos[1]+$cSize[1]-1

   Return $cPos
EndFunc

Func GrabFrameToFile(Const $filename, $x1=-1, $y1=-1, $x2=-1, $y2=-1)
   Local $cPos = GetClientPos()
   Local $hBitmap

   If $x1 = -1 Then
	  $hBitmap = _ScreenCapture_Capture("", $cPos[0], $cPos[1], $cPos[2], $cPos[3], False)
   Else
	  $hBitmap = _ScreenCapture_Capture("", $cPos[0]+$x1, $cPos[1]+$y1, $cPos[0]+$x2, $cPos[1]+$y2, False)
   EndIf

   Local $frame = _GDIPlus_BitmapCreateFromHBITMAP($hBitmap)
   _GDIPlus_ImageSaveToFile($frame, $filename)
   _GDIPlus_BitmapDispose($frame)
   _WinAPI_DeleteObject($hBitmap)
EndFunc
