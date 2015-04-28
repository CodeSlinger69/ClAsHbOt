; BlueStacks
Global $gTitle = "BlueStacks App Player"
Global $gBlueStacksWidth = 1024
Global $gBlueStacksHeight = 600

; Settings
Global $gIniFile = "CoC Bot.ini"

; GUI
Global $gKeepOnlineClicked = False, $gCollectLootClicked = False, $gDonateTroopsClicked = False
Global $gFindMatchClicked = False, $gFindSnipableTHClicked = False, $gAutoRaidClicked = False

; Lists of troop and spell types
Global Enum $eTroopBarbarian, $eTroopArcher, $eTroopGoblin, $eTroopGiant, _
			$eTroopWallBreaker, $eTroopBalloon, $eTroopWizard, $eTroopHealer, _
			$eTroopDragon, $eTroopPekka, _
			$eTroopMinion, $eTroopHogRider, $eTroopValkyrie, $eTroopGolem, _
			$eTroopWitch, $eTroopLavaHound, _
			$eTroopKing, $eTroopQueen, $eTroopCount
Global $gTroopNames[$eTroopCount] = ["Barbarian", "Archer", "Goblin", "Giant", _
									 "Wall Breaker", "Balloon", "Wizard", "Healer", _
									 "Dragon", "Pekka", _
									 "Minion", "Hog Rider", "Valkyrie", "Golem", _
									 "Witch", "Lava Hound", _
									 "Barbarian King", "Archer Queen"]
Global Enum $eSpellLightning, $eSpellHeal, $eSpellRage, $eSpellJump, $eSpellFreeze, $eSpellCount
Global $gSpellNames[$eSpellCount] = ["Lightning", "Rage", "Heal", "Jump", "Freeze"]

; Known screen/window types
Global Enum $eScreenAndroidHome, $eScreenMain, $eScreenChatOpen, $eScreenFindMatch, _
   $eScreenWaitRaid, $eScreenLiveRaid, $eScreenEndBattle, $eScreenShieldIsActive, _
   $eScreenBarracksButtons, $eScreenTrainTroops, $eScreenTrainTroopsInfo, _
   $eScreenLiveReplayEndBattle, $eScreenVilliageWasAttacked, $eScreenChatDimmed, _
   $eScreenArmyCampButtons, $eScreenArmyCampInfo, $eScreenUnknown

; Auto Raid Stages
Global Enum $eAutoRaidNotStarted, $eAutoRaidQueueTraining, $eAutoRaidWaitForTrainingToComplete, _
   $eAutoRaidFindMatch, $eAutoRaidExecuteRaid, $eAutoRaidExecuteDEZap
Global $gAutoRaidStage = $eAutoRaidNotStarted

; Auto Raid troop deployment
Global Enum $eAutoRaidDeploySixtyPercent, $eAutoRaidDeployRemaining, $eAutoRaidDeployOneTroop
Global $gMyMaxSpells

; Auto Raid statistics
Global $gAutoRaidBeginLoot[4] = [-1, -1, -1, -1]  ; gold, elix, dark, cups
Global $gAutoRaidEndLoot[4] ; gold, elix, dark, cups
Global $gMyTroopCost[$eTroopCount]
$gMyTroopCost[$eTroopBarbarian] = 0
Global $gAutoRaidWinnings[4]  ; gold, elix, dark, cups
