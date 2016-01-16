Global $gVersion = "20151210 Update WIP"

; Debug - these are overwritten once ReadSettings() in Settings.au3 is called, however these need to be defined here, as there can
;   be a need to write debug statements prior to ReadSettings() being called.
Global $gScraperDebug = False
Global $gDebug = True

; Raiding variables
Global $gMaxRaidDuration = 210000 ; 3 minutes, 30 seconds (as measured in millseconds)

; For detecting rest period
Global $gPossibleKick = 0
Global $gLastPossibleKickTime = TimerInit()

; BlueStacks
Global $gTitle = "BlueStacks App Player"
Global $gBlueStacksWidth = 860
Global $gBlueStacksHeight = 672
Global $gScreenCenterDraggedDown[2] = [429, 334]
Global $gScreenCenterDraggedUp[2] = [429, 232]
Global $gNorthPointDraggedDown[2] = [429, 66]
Global $gEastPointDraggedDown[2] = [72, 334]
Global $gWestPointDraggedDown[2] = [786, 334]
Global $gSouthPointDraggedUp[2] = [429, 500]

; Settings
Global $gIniFile = "CoC Bot.ini"

; GUI
Global $gKeepOnlineClicked = False, $gCollectLootClicked = False, $gDonateTroopsClicked = False, $gDonateTroopsStartup = False
Global $gFindMatchClicked = False, $gAutoPushClicked = False, $gAutoRaidClicked = False, $gDefenseFarmClicked = False

; Lists of troop and spell types
Global Enum $eTroopBarbarian, $eTroopArcher, $eTroopGiant, $eTroopGoblin, $eTroopWallBreaker, _
			$eTroopBalloon, $eTroopWizard, $eTroopHealer, $eTroopDragon, $eTroopPekka, _
			$eTroopMinion, $eTroopHogRider, $eTroopValkyrie, $eTroopGolem, $eTroopWitch, _
			$eTroopLavaHound, _
			$eTroopKing, $eTroopQueen, $eTroopWarden, $eTroopCount
Global $gTroopCountExcludingHeroes = $eTroopCount-3
Global $gTroopNames[$eTroopCount] = ["Barbarian", "Archer", "Giant", "Goblin", "Wall Breaker", _
									 "Balloon", "Wizard", "Healer", "Dragon", "Pekka", _
									 "Minion", "Hog Rider", "Valkyrie", "Golem", "Witch", _
									 "Lava Hound", _
									 "Barbarian King", "Archer Queen", "Grand Warden"]
Global Enum $eSpellLightning, $eSpellHeal, $eSpellRage, $eSpellJump, $eSpellFreeze, $eSpellPoison, _
   $eSpellEarthquake, $eSpellHaste, $eSpellCount
Global $gSpellNames[$eSpellCount] = ["Lightning", "Heal", "Rage", "Jump", "Freeze", "Poison", _
   "Earthquake", "Haste"]

; Known screen/window types
Global Enum $eScreenAndroidHome, $eScreenMain, $eScreenChatOpen, $eScreenFindMatch, _
   $eScreenWaitRaid, $eScreenLiveRaid, $eScreenEndBattle, _
   $eScreenLiveReplayEndBattle, $eScreenVilliageWasAttacked, $eScreenChatDimmed, _
   $eWindowArmyManager, $eScreenPlayStore, $eScreenAndroidMessageBox, $eScreenUnknown

; Auto Raid/Push Stages
Global Enum $eAutoNotStarted, $eAutoQueueTraining, $eAutoWaitForTrainingToComplete, $eAutoFindMatch, $eAutoExecuteRaid, $eAutoExecuteSnipe
Global $gAutoStage = $eAutoNotStarted

; Auto Raid troop deployment
Global Enum $eAutoRaidDeployFiftyPercent, $eAutoRaidDeploySixtyPercent, $eAutoRaidDeployRemaining, $eAutoRaidDeployOneTroop
Global $gMyMaxSpells = 999

; Auto Raid statistics
Global $gAutoRaidBeginLoot[4] = [-1, -1, -1, -1]  ; gold, elix, dark, cups

; Confidence Levels
Global $gConfidenceTownHall = IniRead($gIniFile, "Confidence", "Town Hall", 0.95)
Global $gConfidenceCollectLoot = IniRead($gIniFile, "Confidence", "Collect Loot", 0.95)
Global $gConfidenceArmyCamp = IniRead($gIniFile, "Confidence", "Army Camp", 0.94)
Global $gConfidenceBarracks = IniRead($gIniFile, "Confidence", "Barracks", 0.95)
Global $gConfidenceCollector =IniRead($gIniFile, "Confidence", "Collector",  0.92)
Global $gConfidenceDEStorage = IniRead($gIniFile, "Confidence", "Dark Elixir Storage", 0.95)
Global $gConfidenceRaidTroopSlot = IniRead($gIniFile, "Confidence", "Raid Troop Slot", 0.98)
Global $gConfidenceDonateTroopSlot = IniRead($gIniFile, "Confidence", "Donate Troop Slot", 0.99)
Global $gConfidenceBarracksTroopSlot = IniRead($gIniFile, "Confidence", "Barracks Troop Slot", 0.99)
Global $gConfidenceCampTroopSlot = IniRead($gIniFile, "Confidence", "Camp Troop Slot", 0.99)
Global $gConfidenceTrainTroopsButton = IniRead($gIniFile, "Confidence", "Train Troops Button", 0.99)
Global $gConfidenceStorages = IniRead($gIniFile, "Confidence", "Storages", 0.94)

; Deploy locations
Global $gMaxDeployBoxes = 19

Global $NWDeployBoxes[$gMaxDeployBoxes][4]
Local $y = $gScreenCenterDraggedDown[1]-20
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
$y = $gScreenCenterDraggedDown[1]-20
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
$y = $gScreenCenterDraggedUp[1]-20
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
$y = $gScreenCenterDraggedUp[1]-20
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
