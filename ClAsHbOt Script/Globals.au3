; General
Global $title = "BlueStacks App Player"
Global $ScraperDebug = False
Global $Debug = False

Global Enum $ScreenAndroidHome, $ScreenMain, $ScreenChatOpen, $ScreenFindMatch, _
   $ScreenWaitRaid, $ScreenLiveRaid, $ScreenEndBattle, $ScreenShieldIsActive, _
   $PanelBarracksButtons, $WindowTrainTroops, $WindowTrainTroopsInfo, $ScreenLiveReplayEndBattle, $WindowVilliageWasAttacked, $UnknownScreen

Global Enum $AutoRaidNotStarted, $AutoRaidQueueTraining, $AutoRaidWaitForTrainingToComplete, _
   $AutoRaidFindMatch, $AutoRaidExecuteRaid, $AutoRaidExecuteDEZap

Global Enum $TH7, $TH8, $TH9, $TH10, $UnknownTH
Global $ExitApp = False

; Scraper
Global Enum $barbarianSlot, $archerSlot, $goblinSlot, $giantSlot, _
			$wallBreakerSlot, $balloonSlot, $wizardSlot, $healerSlot, _
			$dragonSlot, $pekkaSlot, $barbarianKingSlot, $archerQueenSlot, _
			$lightningSpellSlot, $healSpellSlot, $rageSpellSlot, $jumpSpellSlot, $freezeSpellSlot, _
			$countOfSlots
Global $confidenceTownHallSearch = 0.95

; Online Check
Global $onlineCheckDelay = 15000 ; once every 15 seconds
Global $lastOnlineCheck = TimerInit()

; Collect Loot
Global $collectLootDelay = 180000 ; once every 3 mins
Global $lastCollectLoot = TimerInit()
Global $confidenceCollectorLootSearch = 0.90

; Auto Raid
Global $autoRaidStage = $AutoRaidNotStarted
Global $beginGold=-1, $beginElix=-1, $beginDark=-1, $beginCups=-1
Global $endGold, $endElix, $endDark, $endCups
Global $deployClickDelay = 60
Global Enum $deploySixtyPercent, $deployRemaining, $deployOneTroop
Global $myTroopCost[$countOfSlots]
$myTroopCost[$barbarianSlot] = 0
Global $myMaxSpells
Global $goldWinnings, $elixWinnings, $darkWinnings, $cupsWinnings
Global $troopTrainingCheckDelay = 180000   ; 3 minutes in between checks
Global $lastTrainingCheck = TimerInit()
Global $confidenceTroopSlotSearch = 0.98
Global $confidenceBarracksSearch = 0.95
Global $confidenceCollectorsSearch = 0.92
Global $confidenceDEStorageZap = 0.95

