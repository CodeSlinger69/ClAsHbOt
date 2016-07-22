; GUI specific AutoIt includes
#include <GuiButton.au3>
#include <GuiComboBox.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <EditConstants.au3>
#include <ComboConstants.au3>
#include <ButtonConstants.au3>

; GUI Globals
Global $GUI, $GUIImage, $GUIGraphic
Global $GUI_Width=285, $GUI_Height=478
Global $GUI_KeepOnlineCheckBox, $GUI_CollectLootCheckBox, $GUI_DonateTroopsCheckBox, $GUI_ReloadDefensesCheckBox, _
	  $GUI_FindMatchCheckBox, $GUI_AutoRaidCheckBox, $GUI_BackgroundModeCheckBox
Global $GUI_CloseButton
Global $GUI_GoldEdit, $GUI_ElixEdit, $GUI_DarkEdit, $GUI_TownHallEdit, $GUI_AutoRaidUseBreakers, $GUI_AutoRaidBreakerCountEdit, _
	  $GUI_AutoRaidDumpCups, $GUI_AutoRaidDeadBases, $GUI_AutoRaidIgnoreStorages, $GUI_AutoRaidSnipeExposedTH, $GUI_AutoRaidDumpCupsThreshold, _
	  $GUI_AutoRaidStrategyCombo, $GUI_AutoRaidWaitForHeroesCombo
Global $GUI_MyGold, $GUI_MyElix, $GUI_MyDark, $GUI_MyGems, $GUI_MyCups, $GUI_MyTownHall
Global $GUI_Winnings, $GUI_Results, $GUI_AutoStatus
Global $GUIImages[12] = [ _
  "GUISplash\troop-archer.png", "GUISplash\troop-balloon.png", "GUISplash\troop-barbarian.png", _
  "GUISplash\troop-dragon.png", "GUISplash\troop-giant.png", "GUISplash\troop-goblin.png", _
  "GUISplash\troop-healer.png", "GUISplash\troop-pekka.png", "GUISplash\troop-wallbreaker.png", _
  "GUISplash\troop-wizard.png" , "GUISplash\troop-bk.png", "GUISplash\troop-aq.png"]


Func InitGUI()
   Local $p = WinGetPos($gTitle)
   If _OsVersionTest($VER_GREATER_EQUAL, 10) Then
	  $GUI = GUICreate("ClAsHbOt v" & $gVersion, $GUI_Width, $GUI_Height, $p[0]+$p[2]-5, $p[1])
   Else
	  $GUI = GUICreate("ClAsHbOt v" & $gVersion, $GUI_Width, $GUI_Height, $p[0]+$p[2]+9, $p[1])
   EndIf

   ; Left side, match filters group
   Local $x=5, $y=10, $w=136, $h=90
   GUICtrlCreateGroup("Match Filters", $x, $y, $w, $h)

   $y += 15
   GUICtrlCreateLabel("Gold >=", $x+5, $y+2, 40, 17)
   $GUI_GoldEdit = GUICtrlCreateEdit(IniRead($gIniFile, "General", "Gold", 150000), $x+50, $y, $x+70, 17, $ES_NUMBER)

   $y += 17
   GUICtrlCreateLabel("Elixir >=", $x+5, $y+2, 40, 17)
   $GUI_ElixEdit = GUICtrlCreateEdit(IniRead($gIniFile, "General", "Elixir", 150000), $x+50, $y, $x+70, 17, $ES_NUMBER)

   $y += 17
   GUICtrlCreateLabel("Dark >=", $x+5, $y+2, 40, 17)
   $GUI_DarkEdit = GUICtrlCreateEdit(IniRead($gIniFile, "General", "Dark Elixir", 1500), $x+50, $y, $x+70, 17, $ES_NUMBER)

   $y += 17
   GUICtrlCreateLabel("TH <=", $x+5, $y+2, 40, 17)
   $GUI_TownHallEdit = GUICtrlCreateEdit(IniRead($gIniFile, "General", "Town Hall", 8), $x+50, $y, $x+70, 17, $ES_NUMBER)

   $y += 23
   $GUI_BackgroundModeCheckBox = GUICtrlCreateCheckbox("Background Mode", $x+5, $y, $w-6, 25)
   _GUICtrlButton_SetCheck($GUI_BackgroundModeCheckBox, IniRead($gIniFile, "General", "Background Mode", $BST_UNCHECKED))
   GUICtrlSetOnEvent($GUI_BackgroundModeCheckBox, "GUIBackgroundModeCheckBox")
   If _GUICtrlButton_GetCheck($GUI_BackgroundModeCheckBox) = True Then TestBackgroundScrape()

   ; Left side, things todo group
   $y+=30
   $h=180
   GUICtrlCreateGroup("Things Todo", $x, $y, $w, $h)

   $y += 15
   $GUI_KeepOnlineCheckBox = GUICtrlCreateCheckbox("Keep Online 0:00", $x+5, $y, $w-6, 25)
   GUICtrlSetOnEvent($GUI_KeepOnlineCheckBox, "GUIKeepOnlineCheckBox")

   $y += 19
   $GUI_CollectLootCheckBox = GUICtrlCreateCheckbox("Collect Loot 0:00", $x+5, $y, $w-6, 25)
   GUICtrlSetOnEvent($GUI_CollectLootCheckBox, "GUICollectLootCheckBox")

   $y += 19
   $GUI_DonateTroopsCheckBox = GUICtrlCreateCheckbox("Donate Troops", $x+5, $y, $w-6, 25)
   GUICtrlSetOnEvent($GUI_DonateTroopsCheckBox, "GUIDonateTroopsCheckBox")
   GUICtrlSetState($GUI_DonateTroopsCheckBox, $GUI_DISABLE)

   $y += 19
   $GUI_ReloadDefensesCheckBox = GUICtrlCreateCheckbox("Reload Defenses 00:00", $x+5, $y, $w-6, 25)
   GUICtrlSetOnEvent($GUI_ReloadDefensesCheckBox, "GUIReloadDefensesCheckBox")

   $y += 19
   $GUI_FindMatchCheckBox = GUICtrlCreateCheckbox("Find Match (F8)", $x+5, $y, $w-6, 25)
   GUICtrlSetOnEvent($GUI_FindMatchCheckBox, "GUIFindMatchCheckBox")

   $y += 19
   $GUI_AutoRaidCheckBox = GUICtrlCreateCheckbox("Auto Raid (F10)", $x+5, $y, $w-6, 25)
   GUICtrlSetOnEvent($GUI_AutoRaidCheckBox, "GUIAutoRaidCheckBox")

   ; Right side, my stuff group
   $x=153
   $y=10
   $w=125
   $h=112

   GUICtrlCreateGroup("My Stuff", $x, $y, $w, $h)

   $y += 15
   $GUI_MyGold = GUICtrlCreateLabel("-", $x+5, $y, 75, 17, $SS_RIGHT)
   GUICtrlCreateLabel("Gold", $x+93, $y, 30, 17)

   $y += 15
   $GUI_MyElix = GUICtrlCreateLabel("-", $x+5, $y, 75, 17, $SS_RIGHT)
   GUICtrlCreateLabel("Elixir", $x+93, $y, 30, 17)

   $y += 15
   $GUI_MyDark = GUICtrlCreateLabel("-", $x+5, $y, 75, 17, $SS_RIGHT)
   GUICtrlCreateLabel("Dark", $x+93, $y, 30, 17)

   $y += 15
   $GUI_MyGems = GUICtrlCreateLabel("-", $x+5, $y, 75, 17, $SS_RIGHT)
   GUICtrlCreateLabel("Gems", $x+93, $y, 30, 17)

   $y += 15
   $GUI_MyCups = GUICtrlCreateLabel("-", $x+5, $y, 75, 17, $SS_RIGHT)
   GUICtrlCreateLabel("Cups", $x+93, $y, 30, 17)

   $y += 15
   $GUI_MyTownHall = GUICtrlCreateLabel("0", $x+5, $y, 75, 17, $SS_RIGHT)
   GUICtrlCreateLabel("TH", $x+93, $y, 30, 17)

   ; Right side, auto raid options group
   $y += 29
   $h=181
   GUICtrlCreateGroup("Auto Raid", $x, $y, $w, $h)

   $y += 14
   $GUI_AutoRaidUseBreakers = GUICtrlCreateCheckbox("Use Breakers", $x+5, $y, 80, 25)
   _GUICtrlButton_SetCheck($GUI_AutoRaidUseBreakers, IniRead($gIniFile, "General", "Use Breakers", $BST_UNCHECKED))
   $GUI_AutoRaidBreakerCountEdit = GUICtrlCreateEdit(IniRead($gIniFile, "General", "Breaker Count", 4), $x+93, $y+4, 26, 17, $ES_NUMBER)

   $y += 19
   $GUI_AutoRaidDumpCups = GUICtrlCreateCheckbox("Dump Cups>", $x+5, $y, 80, 25)
   _GUICtrlButton_SetCheck($GUI_AutoRaidDumpCups, IniRead($gIniFile, "General", "Dump Cups", $BST_UNCHECKED))
   $GUI_AutoRaidDumpCupsThreshold = GUICtrlCreateEdit(IniRead($gIniFile, "General", "Dump Cups Threshold", 1700), $x+83, $y+4, 36, 17, $ES_NUMBER)

   $y += 21
   $GUI_AutoRaidDeadBases = GUICtrlCreateCheckbox("Dead Bases Only", $x+5, $y, 110, 25)
   _GUICtrlButton_SetCheck($GUI_AutoRaidDeadBases, IniRead($gIniFile, "General", "Dead Bases Only", $BST_UNCHECKED))

   $y += 19
   $GUI_AutoRaidIgnoreStorages = GUICtrlCreateCheckbox("Ignore Storages", $x+5, $y, 110, 25)
   _GUICtrlButton_SetCheck($GUI_AutoRaidIgnoreStorages, IniRead($gIniFile, "General", "Ignore Storages", $BST_UNCHECKED))

   $y += 19
   $GUI_AutoRaidSnipeExposedTH = GUICtrlCreateCheckbox("Snipe Exposed TH", $x+5, $y, 110, 25)
   _GUICtrlButton_SetCheck($GUI_AutoRaidSnipeExposedTH, IniRead($gIniFile, "General", "Snipe Exposed TH", $BST_UNCHECKED))

   $y += 23
   GUICtrlCreateLabel("Wait for Heroes", $x+5, $y+5, 80, 17)
   $GUI_AutoRaidWaitForHeroesCombo = GUICtrlCreateCombo("", $x+85, $y+2, 35, 17, $CBS_DROPDOWNLIST)
   _GUICtrlComboBox_AddString($GUI_AutoRaidWaitForHeroesCombo, "0")
   _GUICtrlComboBox_AddString($GUI_AutoRaidWaitForHeroesCombo, "1")
   _GUICtrlComboBox_AddString($GUI_AutoRaidWaitForHeroesCombo, "2")
   _GUICtrlComboBox_AddString($GUI_AutoRaidWaitForHeroesCombo, "3")
   _GUICtrlComboBox_SetCurSel($GUI_AutoRaidWaitForHeroesCombo, IniRead($gIniFile, "General", "Wait For Heroes", 0))

   $y += 23
   GUICtrlCreateLabel("Strategy:", $x+5, $y, 116, 17)

   $y += 17
   $GUI_AutoRaidStrategyCombo = GUICtrlCreateCombo("", $x+5, $y, 116, 17, $CBS_DROPDOWNLIST)
   _GUICtrlComboBox_AddString($GUI_AutoRaidStrategyCombo, "Barcher")
   _GUICtrlComboBox_AddString($GUI_AutoRaidStrategyCombo, "GiBarch")
   _GUICtrlComboBox_AddString($GUI_AutoRaidStrategyCombo, "BAM")
   _GUICtrlComboBox_AddString($GUI_AutoRaidStrategyCombo, "Loonian")
   _GUICtrlComboBox_AddString($GUI_AutoRaidStrategyCombo, "HoBarch")
   _GUICtrlComboBox_SetCurSel($GUI_AutoRaidStrategyCombo, IniRead($gIniFile, "General", "Raid Strategy", 0))

   ; Bottom
   $x = 10
   $y = 310
   $w = 265
   $GUI_Winnings = GUICtrlCreateLabel("Net winnings: - / - / - / -", $x, $y, $w, 17)

   $y += 19
   $GUI_Results = GUICtrlCreateLabel("Last scan: - / - / - / - / - / -", $x, $y, $w, 17)

   $y += 19
   $GUI_AutoStatus = GUICtrlCreateLabel("Auto: Idle", $x, $y, $w, 17)

   $y += 70
   $GUI_CloseButton = GUICtrlCreateButton("Close (F11)", $x+10, $y, 70, 25)
   GUICtrlSetOnEvent($GUI_CloseButton, "GUICloseButton")
   GUISetOnEvent($GUI_EVENT_CLOSE, "GUICloseButton")

   ; Image
   RandomImage()

   $GUIGraphic = _GDIPlus_GraphicsCreateFromHWND($GUI)
   GUIRegisterMsg($WM_PAINT, "PNG")
   GUISetState(@SW_SHOW)

   ; Grab hotkeys
   HotKeySet("{F8}", HotKeyPressed)
   HotKeySet("{F10}", HotKeyPressed)
   HotKeySet("{F11}", HotKeyPressed)
EndFunc

Func ExitGUI()
   ; Release hotkeys
   HotKeySet("{F8}")
   HotKeySet("{F10}")
   HotKeySet("{F11}")

   _GDIPlus_GraphicsDispose($GUIGraphic)
   _GDIPlus_ImageDispose($GUIImage)
   GUIDelete($GUI)
EndFunc

;Draw PNG image
Func PNG($hWnd, $Msg, $wParam, $lParam)
   _WinAPI_RedrawWindow($GUI, 0, 0, $RDW_UPDATENOW)
   Local $iWidth = _GDIPlus_ImageGetWidth($GUIImage)
   Local $iHeight = _GDIPlus_ImageGetHeight($GUIImage)

   _GDIPlus_GraphicsDrawImage($GUIGraphic, $GUIImage, $GUI_Width-$iWidth-20, $GUI_Height-125)
   _WinAPI_RedrawWindow($GUI, 0, 0, $RDW_VALIDATE)

   Return $GUI_RUNDEFMSG
EndFunc

Func RandomImage()
   Local $r = Random(0, UBound($GUIImages)-1, 1)
   Local $UnresizedImage = _GDIPlus_ImageLoadFromFile("Images\" & $GUIImages[$r])
   Local $UnresizedWidth = _GDIPlus_ImageGetWidth($UnresizedImage)
   Local $UnresizedHeight = _GDIPlus_ImageGetHeight($UnresizedImage)

   Local $newDimension = 125
   If ($UnresizedWidth > $UnresizedHeight) Then
	  Local $newHieght = $newDimension/$UnresizedWidth * $UnresizedHeight
	  Local $newWidth = $newDimension
   Else
	  Local $newHieght = $newDimension
	  Local $newWidth = $newDimension/$UnresizedHeight * $UnresizedWidth
   EndIf

   $GUIImage = _GDIPlus_ImageResize($UnresizedImage, $newWidth, $newHieght)
   _GDIPlus_ImageDispose($UnresizedImage)
EndFunc

Func HotKeyPressed()
   Switch @HotKeyPressed
   Case "{F8}" ; Find Match
	  Local $chk = (_GUICtrlButton_GetCheck($GUI_FindMatchCheckBox) = $BST_CHECKED) ? True : False
	  _GUICtrlButton_SetCheck($GUI_FindMatchCheckBox, $chk ? $BST_UNCHECKED : $BST_CHECKED)
	  GUIFindMatchCheckBox()

   Case "{F10}" ; Auto Raid
	  Local $chk = (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_CHECKED) ? True : False
	  _GUICtrlButton_SetCheck($GUI_AutoRaidCheckBox, $chk ? $BST_UNCHECKED : $BST_CHECKED)
	  GUIAutoRaidCheckBox()

   Case "{F11}" ; Close
	  GUICloseButton()

   EndSwitch
EndFunc

Func GUIKeepOnlineCheckBox()
   DebugWrite("Keep Online clicked")
   $gKeepOnlineClicked = (_GUICtrlButton_GetCheck($GUI_KeepOnlineCheckBox) = $BST_CHECKED) ? True : False
EndFunc

Func GUICollectLootCheckBox()
   DebugWrite("Collect Loot clicked")
   $gCollectLootClicked = (_GUICtrlButton_GetCheck($GUI_CollectLootCheckBox) = $BST_CHECKED) ? True : False
EndFunc

Func GUIDonateTroopsCheckBox()
   DebugWrite("Donate Troops clicked")
   $gDonateTroopsClicked = (_GUICtrlButton_GetCheck($GUI_DonateTroopsCheckBox) = $BST_CHECKED) ? True : False
   $gDonateTroopsStartup = $gDonateTroopsClicked
EndFunc

Func GUIReloadDefensesCheckBox()
   DebugWrite("Reload Defenses clicked")
   $gReloadDefensesClicked = (_GUICtrlButton_GetCheck($GUI_ReloadDefensesCheckBox) = $BST_CHECKED) ? True : False
EndFunc

Func GUIBackgroundModeCheckBox()
   DebugWrite("Background Mode clicked")
   $gBackgroundModeClicked = (_GUICtrlButton_GetCheck($GUI_BackgroundModeCheckBox) = $BST_CHECKED) ? True : False
EndFunc

Func GUIFindMatchCheckBox()
   DebugWrite("Find Match clicked")
   $gFindMatchClicked = (_GUICtrlButton_GetCheck($GUI_FindMatchCheckBox) = $BST_CHECKED) ? True : False
   _GUICtrlButton_Enable($GUI_AutoRaidCheckBox, Not($gFindMatchClicked))

   If $gFindMatchClicked Then
	  HotKeySet("{F10}") ; Auto Raid
	  _GUICtrlButton_SetCheck($GUI_AutoRaidCheckBox, $BST_UNCHECKED)
	  $gPossibleKick = 0
   Else
	  HotKeySet("{F10}", HotKeyPressed) ; Auto Raid
   EndIf

EndFunc

Func GUIAutoRaidCheckBox()
   DebugWrite("Auto Raid clicked")
   $gAutoRaidClicked = (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_CHECKED) ? True : False
   _GUICtrlButton_Enable($GUI_FindMatchCheckBox, Not($gAutoRaidClicked))

   ; Disable check boxes
   If $gAutoRaidClicked Then
	  HotKeySet("{F8}") ; Find Match
	  _GUICtrlButton_SetCheck($GUI_FindMatchCheckBox, $BST_UNCHECKED)
	  $gPossibleKick = 0
   Else
	  HotKeySet("{F8}", HotKeyPressed) ; Find Match
   EndIf

   ; Flag to collect starting loot or report ending loot
   If $gAutoRaidClicked Then
	  $gAutoNeedToCollectStartingLoot = True
   Else
	  $gAutoNeedToCollectEndingLoot = True
   EndIf

   ; Set stage
   $gAutoStage = ($gAutoRaidClicked ? $eAutoQueueTraining : $eAutoNotStarted)
   If $gAutoStage = $eAutoNotStarted Then GUICtrlSetData($GUI_AutoStatus, "Auto: Idle")
EndFunc

Func GUICloseButton()
   DebugWrite("Close clicked")
   SaveSettings()
   ExitGUI()
   ExitScraper()

   Exit
EndFunc

Func UpdateWinnings(ByRef $f)
   GetMyLootNumbers($f)

   Local $changeGold = GUICtrlRead($GUI_MyGold) - $gAutoRaidBeginLoot[0]
   Local $changeElix = GUICtrlRead($GUI_MyElix) - $gAutoRaidBeginLoot[1]
   Local $changeDark = GUICtrlRead($GUI_MyDark) - $gAutoRaidBeginLoot[2]
   Local $changeCups = GUICtrlRead($GUI_MyCups) - $gAutoRaidBeginLoot[3]

   DebugWrite("Winnings total net change: " & _
	  " Gold:" & $changeGold & " Elix:" & $changeElix & _
	  " Dark:" & $changeDark & " Cups:" & $changeCups & @CRLF)

   GUICtrlSetData($GUI_Winnings, "Net winnings: " & $changeGold & " / " & $changeElix & " / " & $changeDark & " / " & $changeCups)
EndFunc