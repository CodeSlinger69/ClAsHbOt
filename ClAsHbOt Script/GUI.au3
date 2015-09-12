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
Global $GUI_Width=285, $GUI_Height=440
Global $GUIImages[12] = [ "troop-archer.png", "troop-balloon.png", "troop-barbarian.png", _
   "troop-dragon.png", "troop-giant.png", "troop-goblin.png", "troop-healer.png", _
   "troop-pekka.png", "troop-wallbreaker.png", "troop-wizard.png" , "troop-bk.png", "troop-aq.png"]
Global $GUI_KeepOnlineCheckBox, $GUI_CollectLootCheckBox, $GUI_DonateTroopsCheckBox, _
	  $GUI_FindMatchCheckBox, $GUI_AutoSnipeCheckBox, $GUI_AutoRaidCheckBox
Global $GUI_CloseButton
Global $GUI_GoldEdit, $GUI_ElixEdit, $GUI_DarkEdit, $GUI_TownHallEdit, $GUI_AutoRaidUseBreakers, $GUI_AutoRaidBreakerCountEdit, _
	  $GUI_AutoRaidDumpCups, $GUI_AutoRaidDeadBases, $GUI_AutoRaidIgnoreStorages, $GUI_AutoRaidDumpCupsThreshold, $GUI_AutoRaidStrategyCombo
Global $GUI_MyGold, $GUI_MyElix, $GUI_MyDark, $GUI_MyGems, $GUI_MyCups, $GUI_MyTownHall
Global $GUI_Winnings, $GUI_Results, $GUI_AutoStatus

Func InitGUI()
   Local $p = WinGetPos($gTitle)
   $GUI = GUICreate("ClAsHbOt v" & $gVersion, $GUI_Width, $GUI_Height, $p[0]+$p[2]+8, $p[1])

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

   ; Left side, things todo group
   $y+=31
   $h=145
   GUICtrlCreateGroup("Things Todo", $x, $y, $w, $h)

   $y += 15
   $GUI_KeepOnlineCheckBox = GUICtrlCreateCheckbox("F5 Keep Online 0:00", $x+5, $y, $w-6, 25)
   GUICtrlSetOnEvent($GUI_KeepOnlineCheckBox, "GUIKeepOnlineCheckBox")

   $y += 19
   $GUI_CollectLootCheckBox = GUICtrlCreateCheckbox("F6 Collect Loot 0:00", $x+5, $y, $w-6, 25)
   GUICtrlSetOnEvent($GUI_CollectLootCheckBox, "GUICollectLootCheckBox")

   $y += 19
   $GUI_DonateTroopsCheckBox = GUICtrlCreateCheckbox("F7 Donate Troops", $x+5, $y, $w-6, 25)
   GUICtrlSetOnEvent($GUI_DonateTroopsCheckBox, "GUIDonateTroopsCheckBox")

   $y += 19
   $GUI_FindMatchCheckBox = GUICtrlCreateCheckbox("F8 Find Match", $x+5, $y, $w-6, 25)
   GUICtrlSetOnEvent($GUI_FindMatchCheckBox, "GUIFindMatchCheckBox")

   $y += 19
   $GUI_AutoSnipeCheckBox = GUICtrlCreateCheckbox("F9 Auto Snipe", $x+5, $y, $w-6, 25)
   GUICtrlSetOnEvent($GUI_AutoSnipeCheckBox, "GUIAutoSnipeCheckBox")

   $y += 19
   $GUI_AutoRaidCheckBox = GUICtrlCreateCheckbox("F10 Auto Raid", $x+5, $y, $w-6, 25)
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
   $h=138
   GUICtrlCreateGroup("Auto Raid/Snipe", $x, $y, $w, $h)

   $y += 14
   $GUI_AutoRaidUseBreakers = GUICtrlCreateCheckbox("Use Breakers", $x+5, $y, 80, 25)
   _GUICtrlButton_SetCheck($GUI_AutoRaidUseBreakers, IniRead($gIniFile, "General", "Use Breakers", $BST_UNCHECKED))
   $GUI_AutoRaidBreakerCountEdit = GUICtrlCreateEdit(IniRead($gIniFile, "General", "Breaker Count", 4), $x+93, $y+4, 26, 17, $ES_NUMBER)

   $y += 19
   $GUI_AutoRaidDumpCups = GUICtrlCreateCheckbox("Dump Cups>", $x+5, $y, 80, 25)
   _GUICtrlButton_SetCheck($GUI_AutoRaidDumpCups, IniRead($gIniFile, "General", "Dump Cups", $BST_UNCHECKED))
   $GUI_AutoRaidDumpCupsThreshold = GUICtrlCreateEdit(IniRead($gIniFile, "General", "Dump Cups Threshold", 1700), $x+83, $y+4, 36, 17, $ES_NUMBER)

   $y += 19
   $GUI_AutoRaidDeadBases = GUICtrlCreateCheckbox("Dead Bases Only", $x+5, $y, 110, 25)
   _GUICtrlButton_SetCheck($GUI_AutoRaidDeadBases, IniRead($gIniFile, "General", "Dead Bases Only", $BST_UNCHECKED))

   $y += 19
   $GUI_AutoRaidIgnoreStorages = GUICtrlCreateCheckbox("Ignore Storages", $x+5, $y, 110, 25)
   _GUICtrlButton_SetCheck($GUI_AutoRaidIgnoreStorages, IniRead($gIniFile, "General", "Ignore Storages", $BST_UNCHECKED))

   $y += 24
   GUICtrlCreateLabel("Strategy:", $x+5, $y, 116, 17)

   $y += 17
   $GUI_AutoRaidStrategyCombo = GUICtrlCreateCombo("", $x+5, $y, 116, 17, $CBS_DROPDOWNLIST)
   _GUICtrlComboBox_AddString($GUI_AutoRaidStrategyCombo, "Barcher")
   _GUICtrlComboBox_AddString($GUI_AutoRaidStrategyCombo, "GiBarch")
   _GUICtrlComboBox_AddString($GUI_AutoRaidStrategyCombo, "BAM")
   _GUICtrlComboBox_AddString($GUI_AutoRaidStrategyCombo, "Loonian")
   _GUICtrlComboBox_SetCurSel($GUI_AutoRaidStrategyCombo, IniRead($gIniFile, "General", "Raid Strategy", 0))

   ; Bottom
   $x = 10
   $y = 272
   $w = 265
   $GUI_Winnings = GUICtrlCreateLabel("Net winnings: - / - / - / -", $x, $y, $w, 17)

   $y += 19
   $GUI_Results = GUICtrlCreateLabel("Last scan: - / - / - / - / - / -", $x, $y, $w, 17)

   $y += 19
   $GUI_AutoStatus = GUICtrlCreateLabel("Auto: Idle", $x, $y, $w, 17)

   $y += 70
   $GUI_CloseButton = GUICtrlCreateButton("F11 Close", $x+10, $y, 70, 25)
   GUICtrlSetOnEvent($GUI_CloseButton, "GUICloseButton")
   GUISetOnEvent($GUI_EVENT_CLOSE, "GUICloseButton")

   ; Image
   RandomImage()

   $GUIGraphic = _GDIPlus_GraphicsCreateFromHWND($GUI)
   GUIRegisterMsg($WM_PAINT, "PNG")
   GUISetState(@SW_SHOW)

   ; Grab hotkeys
   HotKeySet("{F5}", HotKeyPressed)
   HotKeySet("{F6}", HotKeyPressed)
   HotKeySet("{F7}", HotKeyPressed)
   HotKeySet("{F8}", HotKeyPressed)
   HotKeySet("{F9}", HotKeyPressed)
   HotKeySet("{F10}", HotKeyPressed)
   HotKeySet("{F11}", HotKeyPressed)
EndFunc

Func ExitGUI()
   ; Release hotkeys
   HotKeySet("{F5}")
   HotKeySet("{F6}")
   HotKeySet("{F7}")
   HotKeySet("{F8}")
   HotKeySet("{F9}")
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
   Case "{F5}" ; Keep Online
	  Local $chk = (_GUICtrlButton_GetCheck($GUI_KeepOnlineCheckBox) = $BST_CHECKED) ? True : False
	  _GUICtrlButton_SetCheck($GUI_KeepOnlineCheckBox, $chk ? $BST_UNCHECKED : $BST_CHECKED)
	  GUIKeepOnlineCheckBox()

   Case "{F6}" ; Collect Resources
	  Local $chk = (_GUICtrlButton_GetCheck($GUI_CollectLootCheckBox) = $BST_CHECKED) ? True : False
	  _GUICtrlButton_SetCheck($GUI_CollectLootCheckBox, $chk ? $BST_UNCHECKED : $BST_CHECKED)
	  GUICollectLootCheckBox()

   Case "{F7}" ; Donate Troops
	  Local $chk = (_GUICtrlButton_GetCheck($GUI_DonateTroopsCheckBox) = $BST_CHECKED) ? True : False
	  _GUICtrlButton_SetCheck($GUI_DonateTroopsCheckBox, $chk ? $BST_UNCHECKED : $BST_CHECKED)
	  GUIDonateTroopsCheckBox()

   Case "{F8}" ; Find Match
	  Local $chk = (_GUICtrlButton_GetCheck($GUI_FindMatchCheckBox) = $BST_CHECKED) ? True : False
	  _GUICtrlButton_SetCheck($GUI_FindMatchCheckBox, $chk ? $BST_UNCHECKED : $BST_CHECKED)
	  GUIFindMatchCheckBox()

   Case "{F9}" ; Auto Snipe
	  Local $chk = (_GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox) = $BST_CHECKED) ? True : False
	  _GUICtrlButton_SetCheck($GUI_AutoSnipeCheckBox, $chk ? $BST_UNCHECKED : $BST_CHECKED)
	  GUIAutoSnipeCheckBox()

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

Func GUIFindMatchCheckBox()
   DebugWrite("Find Match clicked")
   $gFindMatchClicked = (_GUICtrlButton_GetCheck($GUI_FindMatchCheckBox) = $BST_CHECKED) ? True : False
   _GUICtrlButton_Enable($GUI_AutoSnipeCheckBox, Not($gFindMatchClicked))
   _GUICtrlButton_Enable($GUI_AutoRaidCheckBox, Not($gFindMatchClicked))

   If $gFindMatchClicked Then
	  HotKeySet("{F9}") ; Find Snipable TH
	  HotKeySet("{F10}") ; Auto Raid
	  _GUICtrlButton_SetCheck($GUI_AutoSnipeCheckBox, $BST_UNCHECKED)
	  _GUICtrlButton_SetCheck($GUI_AutoRaidCheckBox, $BST_UNCHECKED)
	  $gPossibleKick = 0
   Else
	  HotKeySet("{F9}", HotKeyPressed) ; Find Snipable TH
	  HotKeySet("{F10}", HotKeyPressed) ; Auto Raid
   EndIf

EndFunc

Func GUIAutoSnipeCheckBox()
   DebugWrite("Auto Snipe clicked")
   $gAutoSnipeClicked = (_GUICtrlButton_GetCheck($GUI_AutoSnipeCheckBox) = $BST_CHECKED) ? True : False
   _GUICtrlButton_Enable($GUI_FindMatchCheckBox, Not($gAutoSnipeClicked))
   _GUICtrlButton_Enable($GUI_AutoRaidCheckBox, Not($gAutoSnipeClicked))

   ; Disable check boxes
   If $gAutoSnipeClicked Then
	  HotKeySet("{F8}") ; Find Match
	  HotKeySet("{F10}") ; Auto Raid
	  _GUICtrlButton_SetCheck($GUI_FindMatchCheckBox, $BST_UNCHECKED)
	  _GUICtrlButton_SetCheck($GUI_AutoRaidCheckBox, $BST_UNCHECKED)
	  $gPossibleKick = 0
   Else
	  HotKeySet("{F8}", HotKeyPressed) ; Find Match
	  HotKeySet("{F10}", HotKeyPressed) ; Auto Raid
   EndIf

   ; Collect starting loot or report ending loot
   If $gAutoSnipeClicked Then
	  CaptureAutoBeginLoot()
   Else
	  CaptureAutoEndLoot()
   EndIf

   ; Set stage
   $gAutoStage = ($gAutoSnipeClicked ? $eAutoQueueTraining : $eAutoNotStarted)
   If $gAutoStage = $eAutoNotStarted Then GUICtrlSetData($GUI_AutoStatus, "Auto: Idle")
EndFunc

Func GUIAutoRaidCheckBox()
   DebugWrite("Auto Raid clicked")
   Local $test = _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)
   $gAutoRaidClicked = (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_CHECKED) ? True : False
   _GUICtrlButton_Enable($GUI_FindMatchCheckBox, Not($gAutoRaidClicked))
   _GUICtrlButton_Enable($GUI_AutoSnipeCheckBox, Not($gAutoRaidClicked))

   ; Disable check boxes
   If $gAutoRaidClicked Then
	  HotKeySet("{F8}") ; Find Match
	  HotKeySet("{F9}") ; Find Snipable TH
	  _GUICtrlButton_SetCheck($GUI_FindMatchCheckBox, $BST_UNCHECKED)
	  _GUICtrlButton_SetCheck($GUI_AutoSnipeCheckBox, $BST_UNCHECKED)
	  ZoomOut(True)
	  $gPossibleKick = 0
   Else
	  HotKeySet("{F8}", HotKeyPressed) ; Find Match
	  HotKeySet("{F9}", HotKeyPressed) ; Find Snipable TH
   EndIf

   ; Collect starting loot or report ending loot
   If $gAutoRaidClicked Then
	  CaptureAutoBeginLoot()
   Else
	  CaptureAutoEndLoot()
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

Func CaptureAutoBeginLoot()
   GetMyLootNumbers()

   Local $n = GUICtrlRead($GUI_MyGold)
   If $n <> "-" Then $gAutoRaidBeginLoot[0] = $n
   $n = GUICtrlRead($GUI_MyElix)
   If $n <> "-" Then $gAutoRaidBeginLoot[1] = $n
   $n = GUICtrlRead($GUI_MyDark)
   If $n <> "-" Then $gAutoRaidBeginLoot[2] = $n
   $n = GUICtrlRead($GUI_MyCups)
   If $n <> "-" Then $gAutoRaidBeginLoot[3] = $n

   DebugWrite("Auto Begin: " & _
	  " Gold:" & $gAutoRaidBeginLoot[0] & _
	  " Elix:" & $gAutoRaidBeginLoot[1] & _
	  " Dark:" & $gAutoRaidBeginLoot[2] & _
	  " Cups:" & $gAutoRaidBeginLoot[3])

   GUICtrlSetData($GUI_Winnings, "Net winnings: 0 / 0 / 0 / 0")
EndFunc

Func CaptureAutoEndLoot()
   Local $netGold = GUICtrlRead($GUI_MyGold) - $gAutoRaidBeginLoot[0]
   Local $netElix = GUICtrlRead($GUI_MyElix) - $gAutoRaidBeginLoot[1]
   Local $netDark = GUICtrlRead($GUI_MyDark) - $gAutoRaidBeginLoot[2]
   Local $netCups = GUICtrlRead($GUI_MyCups) - $gAutoRaidBeginLoot[3]
   DebugWrite("Auto Profit: " & _
	  " Gold:" & $netGold & _
	  " Elix:" & $netElix & _
	  " Dark:" & $netDark & _
	  " Cups:" & $netCups)
EndFunc

Func SetAutoRaidResults(Const $gold, Const $elix, Const $dark, Const $cups, Const $townHall, Const $deadBase)
   Local $townHallIndiator = $townHall<>-1 ? $townHall : "-"
   Local $deadBaseIndicator = _GUICtrlButton_GetCheck($GUI_AutoRaidDeadBases) = $BST_CHECKED ? ($deadBase=True ? "T" : "F") : "-"

   GUICtrlSetData($GUI_Results, "Last scan: " & $gold & " / " & $elix & " / " & $dark & " / " & _
				  $cups & " / " & $townHallIndiator & " / " & $deadBaseIndicator )
EndFunc


Func UpdateWinnings()
   GetMyLootNumbers()

   Local $changeGold = GUICtrlRead($GUI_MyGold) - $gAutoRaidBeginLoot[0]
   Local $changeElix = GUICtrlRead($GUI_MyElix) - $gAutoRaidBeginLoot[1]
   Local $changeDark = GUICtrlRead($GUI_MyDark) - $gAutoRaidBeginLoot[2]
   Local $changeCups = GUICtrlRead($GUI_MyCups) - $gAutoRaidBeginLoot[3]

   DebugWrite("Winnings total net change: " & _
	  " Gold:" & $changeGold & " Elix:" & $changeElix & _
	  " Dark:" & $changeDark & " Cups:" & $changeCups & @CRLF)

   GUICtrlSetData($GUI_Winnings, "Net winnings: " & $changeGold & " / " & $changeElix & " / " & $changeDark & " / " & $changeCups)
EndFunc