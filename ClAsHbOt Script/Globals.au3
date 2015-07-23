Global $gVersion = "20150723"

; Debug - these are overwritten once ReadSettings() in Settings.au3 is called, however these need to be defined here, as there can
;   be a need to write debug statements prior to ReadSettings() being called.
Global $gScraperDebug = False
Global $gDebug = True

; For detecting rest period
Global $gPossibleKick = 0
Global $gLastPossibleKickTime = TimerInit()

; BlueStacks
Global $gTitle = "BlueStacks App Player"
Global $gBlueStacksWidth = 1024
Global $gBlueStacksHeight = 600

; Settings
Global $gIniFile = "CoC Bot.ini"

; GUI
Global $gKeepOnlineClicked = False, $gCollectLootClicked = False, $gDonateTroopsClicked = False, $gDonateTroopsStartup = False
Global $gFindMatchClicked = False, $gAutoSnipeClicked = False, $gAutoRaidClicked = False

; Lists of troop and spell types
Global Enum $eTroopBarbarian, $eTroopArcher, $eTroopGiant, $eTroopGoblin, $eTroopWallBreaker, _
			$eTroopBalloon, $eTroopWizard, $eTroopHealer, $eTroopDragon, $eTroopPekka, _
			$eTroopMinion, $eTroopHogRider, $eTroopValkyrie, $eTroopGolem, $eTroopWitch, _
			$eTroopLavaHound, _
			$eTroopKing, $eTroopQueen, $eTroopCount
Global $gTroopNames[$eTroopCount] = ["Barbarian", "Archer", "Giant", "Goblin", "Wall Breaker", _
									 "Balloon", "Wizard", "Healer", "Dragon", "Pekka", _
									 "Minion", "Hog Rider", "Valkyrie", "Golem", "Witch", _
									 "Lava Hound", _
									 "Barbarian King", "Archer Queen"]
; Todo, add earthquake and haste, when I get them
Global Enum $eSpellLightning, $eSpellHeal, $eSpellRage, $eSpellJump, $eSpellFreeze, $eSpellPoison, $eSpellCount
Global $gSpellNames[$eSpellCount] = ["Lightning", "Rage", "Heal", "Jump", "Freeze", "Poison"]

; Known screen/window types
Global Enum $eScreenAndroidHome, $eScreenMain, $eScreenChatOpen, $eScreenFindMatch, _
   $eScreenWaitRaid, $eScreenLiveRaid, $eScreenEndBattle, $eScreenShieldIsActive, _
   $eScreenLiveReplayEndBattle, $eScreenVilliageWasAttacked, $eScreenChatDimmed, _
   $eWindowArmyManager, $eScreenUnknown

; Auto Raid/Snipe Stages
Global Enum $eAutoNotStarted, $eAutoQueueTraining, $eAutoWaitForTrainingToComplete, $eAutoFindMatch, $eAutoExecute
Global $gAutoStage = $eAutoNotStarted

; Auto Raid troop deployment
Global Enum $eAutoRaidDeployFiftyPercent, $eAutoRaidDeploySixtyPercent, $eAutoRaidDeployRemaining, $eAutoRaidDeployOneTroop
Global $gMyMaxSpells = 999

; TownHall location on screen
Global Enum $eTownHallMiddle, $eTownHallTop, $eTownHallBottom

; Auto Raid statistics
Global $gAutoRaidBeginLoot[4] = [-1, -1, -1, -1]  ; gold, elix, dark, cups

; Deploy locations
Global $NWSafeDeployBox[4] = [280, 170, 300, 190]
Global $NESafeDeployBox[4] = [735, 170, 755, 190]
Global $SWSafeDeployBox[4] = [280, 295, 300, 315]
Global $SESafeDeployBox[4] = [735, 295, 755, 315]

; Formula: y = -.7/x + 374
Global $NWDeployBoxes[21][4]
Local $y = 325
Local $i = 0
For $x = 70 To 470 Step 20
   $NWDeployBoxes[$i][0] = $x
   $NWDeployBoxes[$i][1] = $y
   $NWDeployBoxes[$i][2] = $x+60
   $NWDeployBoxes[$i][3] = $y+40
   ;ConsoleWrite("NW Box: " & $i & " " & $NWDeployBoxes[$i][0] & "  " & $NWDeployBoxes[$i][1] & "  " & $NWDeployBoxes[$i][2] & "  " & $NWDeployBoxes[$i][3] & @CRLF)
   $i+=1
   $y-=14
Next

; Formula: y = .7/x - 340
Global $NEDeployBoxes[21][4]
$y = 325
$i=0
For $x = 950 To 550 Step -20
   $NEDeployBoxes[$i][0] = $x-60
   $NEDeployBoxes[$i][1] = $y
   $NEDeployBoxes[$i][2] = $x
   $NEDeployBoxes[$i][3] = $y+40
   ;ConsoleWrite("NE Box: " & $i & " " & $NEDeployBoxes[$i][0] & "  " & $NEDeployBoxes[$i][1] & "  " & $NEDeployBoxes[$i][2] & "  " & $NEDeployBoxes[$i][3] & @CRLF)
   $i+=1
   $y-=14
Next

; Formula: y = .7/x + 276
Global $SWDeployBoxes[21][4]
$y = 125
$i=0
For $x = 70 To 470 Step 20
   $SWDeployBoxes[$i][0] = $x
   $SWDeployBoxes[$i][1] = $y
   $SWDeployBoxes[$i][2] = $x+60
   $SWDeployBoxes[$i][3] = $y+40
   ;ConsoleWrite("SW Box: " & $i & " " & $SWDeployBoxes[$i][0] & "  " & $SWDeployBoxes[$i][1] & "  " & $SWDeployBoxes[$i][2] & "  " & $SWDeployBoxes[$i][3] & @CRLF)
   $i+=1
   $y+=14
Next

; Formula: y = -.7/x + 790
Global $SEDeployBoxes[21][4]
$y = 125
$i=0
For $x = 950 To 550 Step -20
   $SEDeployBoxes[$i][0] = $x-60
   $SEDeployBoxes[$i][1] = $y
   $SEDeployBoxes[$i][2] = $x
   $SEDeployBoxes[$i][3] = $y+40
   ;ConsoleWrite("SE Box: " & $i & " " & $SEDeployBoxes[$i][0] & "  " & $SEDeployBoxes[$i][1] & "  " & $SEDeployBoxes[$i][2] & "  " & $SEDeployBoxes[$i][3] & @CRLF)
   $i+=1
   $y+=14
Next

