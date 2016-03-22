; Debug - these are overwritten in ReadSettings(), however $gDebug needs to be defined here, as there can
;   be a need to write debug statements prior to ReadSettings() being called.
Global $gDebug = True
; Debugging switches used during development/testing, not needed for general use
Global $gScraperDebug = False
Global $gDebugSaveScreenCaptures = False
Global $gDebugSaveUnknownStorageFrames = False
Global $gDebugLogCallsToCaptureFrame = False

; DLLs
Global $gClAsHbOtDllHandle = 0
Global $gUser32DllHandle = 0
Global $gGdi32DllHandle = 0

; Scraper Globals
; These enums need to be kept in sync with the DLL
Global Enum $eScrapeDropSpaces, $eScrapeKeepSpaces
Global Enum $eActionTypeRaid, $eActionTypeDonate, $eActionTypeBarracks, $eActionTypeCamp, $eActionTypeReloadButton
Global Enum $eSlotTypeTroop, $eSlotTypeSpell, $eSlotTypeHero
Global Enum $eBuiltTroopClassNormal, $eBuiltTroopClassHero
Global Enum $eSearchTypeTownHall, $eSearchTypeLootCart, $eSearchClashIcon, $eSearchPlayStoreOpenButton, $eSearchDonateButton, _
			$eSearchTypeGoldStorage, $eSearchTypeElixStorage, $eSearchTypeDarkStorage, $eSearchTypeLootCollector, $eSearchTypeLootBubble
Global Enum $fontMyStuff, $fontRaidTroopCountUnselected, $fontRaidTroopCountSelected, $fontRaidLoot, $fontBarracksStatus, _
			$fontBattleEndWinnings, $fontBattleEndBonus, $fontChat, $fontArmyOverviewStatus
Global $gMAXSTRING = 500
Global $gActionTypeNames[5] = [ "Raid", "Donate", "Barracks", "Camp", "ReloadButton" ]
Global $gSlotTypeNames[3] = [ "Troop", "Spell", "Hero" ]
Global $gBuiltTroopClassNames[2] = [ "Normal", "Heroes" ]
Global $gSearchTypeNames[10] = [ "TownHall", "LootCart", "ClashIcon", "PlayStoreOpenButton", "DonateButton", _
								 "GoldStorage", "ElixStorage", "DarkStorage", "LootCollector", "LootBubble" ]
Global $gFontNames[10] = [ "MyStuff", "RaidTroopCountUnselected", "RaidTroopCountSelected", "RaidLoot", "BarracksStatus", _
						   "BattleEndWinnings", "BattleEndBonus", "Chat", "ArmyOverviewStatus" ]
Global $gHDC = 0, $gMemDC = 0

; Raiding variables
Global $gMaxRaidDuration = 180000 ; 3 minutes (as measured in millseconds)

; For detecting rest period
Global $gPossibleKick = 0
Global $gLastPossibleKickTime = TimerInit()

; BlueStacks
Global $gTitle = "BlueStacks App Player"
Global $gAppClassInstance = "[CLASS:BlueStacksApp; INSTANCE:1]"
GLobal $gBlueStacksPID = 0
Global $gBlueStacksHwnd = 0
Global $gBlueStacksControlHwnd = 0
Global $gBlueStacksWidth = 860
Global $gBlueStacksHeight = 733
Global $gScreenCenter[2] = [429, 337] ; Color at this point = 0xF1BE5A
Global $gNorthPoint[2] = [429, 69] ; also update in the DLL if this changes
Global $gWestPoint[2] = [71, 337] ; also update in the DLL if this changes
Global $gEastPoint[2] = [787, 337] ; also update in the DLL if this changes
Global $gSouthPoint[2] = [429, 605] ; also update in the DLL if this changes
; Note to self: due to Jan 26, 2016 CoC release, the max y extent for buttons is 680,
;   to avoid clicking on Android system bar icons

; Settings
Global $gIniFile = "CoC Bot.ini"

; GUI
Global $gKeepOnlineClicked = False, $gCollectLootClicked = False, $gDonateTroopsClicked = False, $gDonateTroopsStartup = False
Global $gReloadDefensesClicked = False, $gFindMatchClicked = False, $gAutoPushClicked = False, $gAutoRaidClicked = False
Global $gDefenseFarmClicked = False, $gBackgroundModeClicked = False
Global $gAutoNeedToCollectStartingLoot = False, $gAutoNeedToCollectEndingLoot = False

; Lists of troop and spell types
Global Enum $eTroopBarbarian, $eTroopArcher, $eTroopGiant, $eTroopGoblin, $eTroopWallBreaker, _
			$eTroopBalloon, $eTroopWizard, $eTroopHealer, $eTroopDragon, $eTroopPekka, _
			$eTroopMinion, $eTroopHogRider, $eTroopValkyrie, $eTroopGolem, $eTroopWitch, _
			$eTroopLavaHound, _
			$eTroopKing, $eTroopQueen, $eTroopWarden, _
			$eTroopKingGrayed, $eTroopQueenGrayed, $eTroopWardenGrayed, $eTroopCount
Global $gTroopCountExcludingHeroes = $eTroopCount-6
Global $gTroopNames[$eTroopCount] = ["Barbarian", "Archer", "Giant", "Goblin", "Wall Breaker", _
									 "Balloon", "Wizard", "Healer", "Dragon", "Pekka", _
									 "Minion", "Hog Rider", "Valkyrie", "Golem", "Witch", _
									 "Lava Hound", _
									 "Barbarian King", "Archer Queen", "Grand Warden", _
									 "Barbarian King Grayed", "Archer Queen Grayed", "Grand Warden Grayed"]
Global $gTroopSpace[$eTroopCount] = [ 1, 1, 5, 1, 2, _
									  5, 4, 14, 20, 25, _
									  2, 5, 8, 30, 12, _
									  30, _
									  0, 0, 0, _
									  0, 0, 0 ]
Global Enum $eSpellLightning, $eSpellHeal, $eSpellRage, $eSpellJump, $eSpellFreeze, $eSpellPoison, _
   $eSpellEarthquake, $eSpellHaste, $eSpellCount
Global $gSpellNames[$eSpellCount] = ["Lightning", "Heal", "Rage", "Jump", "Freeze", "Poison", _
   "Earthquake", "Haste"]

; Reload button names
Global $gReloadButtonNames[5] = ["Info", "Gold", "Elixir", "Elixir w/ Eagle", "Dark Elixir"]

; Known screen/window types
Global Enum $eScreenAndroidHome, $eScreenMain, $eScreenChatOpen, $eScreenFindMatch, _
   $eScreenWaitRaid, $eScreenLiveRaid, $eScreenEndBattle, _
   $eScreenLiveReplayEndBattle, $eScreenVillageWasAttacked, $eScreenChatDimmed, _
   $eWindowArmyManager, $eScreenPlayStore, $eScreenAndroidMessageBox, _
   $eShopOrLayout, $eProfile, $eAchievements, $eSettings, $eStarBonus, _
   $eScreenUnknown

; Error conditions
Global Enum $eErrorAndroidMessageBox=1, $eErrorAttackingDisabled

; Auto Raid/Push Stages
Global Enum $eAutoNotStarted, $eAutoQueueTraining, $eAutoWaitForTrainingToComplete, $eAutoFindMatch, $eAutoManualRaid, $eAutoExecuteRaid, $eAutoExecuteSnipe
Global $gAutoStage = $eAutoNotStarted

; Auto Raid troop deployment
Global Enum $eAutoRaidDeployFiftyPercent, $eAutoRaidDeploySixtyPercent, $eAutoRaidDeployRemaining, $eAutoRaidDeployOneTroop
Global $gMyMaxSpells = 999

; Auto Raid statistics
Global $gAutoRaidBeginLoot[4] = [-1, -1, -1, -1]  ; gold, elix, dark, cups

; Confidence Levels
Global $gConfidenceTownHall = 0.94
Global $gConfidenceCollectLoot = 0.935
Global $gConfidenceArmyCamp = 0.985
Global $gConfidenceBarracks = 0.95
Global $gConfidenceCollector = 0.92
Global $gConfidenceRaidTroopSlot = 0.98
Global $gConfidenceDonateTroopSlot = 0.9875
Global $gConfidenceBarracksTroopSlot = 0.99
Global $gConfidenceTrainTroopsButton = 0.99
Global $gConfidenceDonateButton = 0.98
Global $gConfidenceStorages = 0.93
Global $gConfidenceLootCart = 0.93
Global $gConfidenceReloadButton = 0.99
Global $gConfidenceClashIcon = 0.99
Global $gConfidencePlayStoreOpenButton = 0.99

; Deploy locations
Global $gMaxDeployBoxes = 19

Global $NWDeployBoxes[$gMaxDeployBoxes][4]
Local $y = $gScreenCenter[1]-20
Local $i = 0
For $x = 45 To 405 Step 20
   $NWDeployBoxes[$i][0] = $x
   $NWDeployBoxes[$i][1] = $y
   $NWDeployBoxes[$i][2] = $x+60
   $NWDeployBoxes[$i][3] = $y+40
   $i+=1
   $y-=15
Next

Global $NEDeployBoxes[$gMaxDeployBoxes][4]
$y = $gScreenCenter[1]-20
$i=0
For $x = 820 To 460 Step -20
   $NEDeployBoxes[$i][0] = $x-60
   $NEDeployBoxes[$i][1] = $y
   $NEDeployBoxes[$i][2] = $x
   $NEDeployBoxes[$i][3] = $y+40
   $i+=1
   $y-=15
Next

Global $SWDeployBoxes[$gMaxDeployBoxes][4]
$y = $gScreenCenter[1]-20
$i=0
For $x = 45 To 405 Step 20
   $SWDeployBoxes[$i][0] = $x
   $SWDeployBoxes[$i][1] = $y
   $SWDeployBoxes[$i][2] = $x+60
   $SWDeployBoxes[$i][3] = $y+40
   $i+=1
   $y+=15
Next

Global $SEDeployBoxes[$gMaxDeployBoxes][4]
$y = $gScreenCenter[1]-20
$i=0
For $x = 820 To 460 Step -20
   $SEDeployBoxes[$i][0] = $x-60
   $SEDeployBoxes[$i][1] = $y
   $SEDeployBoxes[$i][2] = $x
   $SEDeployBoxes[$i][3] = $y+40
   $i+=1
   $y+=15
Next

Global $NWSafeDeployBox[4] = [$NWDeployBoxes[10][0], $NWDeployBoxes[10][1], $NWDeployBoxes[10][2]-40, $NWDeployBoxes[10][3]-20]
Global $NESafeDeployBox[4] = [$NEDeployBoxes[10][0]+40, $NEDeployBoxes[10][1], $NEDeployBoxes[10][2], $NEDeployBoxes[10][3]-20]
Global $SWSafeDeployBox[4] = [$SWDeployBoxes[10][0], $SWDeployBoxes[10][1], $SWDeployBoxes[10][2]-40, $SWDeployBoxes[10][3]-20]
Global $SESafeDeployBox[4] = [$SEDeployBoxes[10][0]+40, $SEDeployBoxes[10][1], $SEDeployBoxes[10][2], $SEDeployBoxes[10][3]-20]
