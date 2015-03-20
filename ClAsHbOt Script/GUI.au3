#include <GuiButton.au3>
#include <GuiComboBox.au3>
#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <EditConstants.au3>
#include <ComboConstants.au3>
#include <ButtonConstants.au3>

; GUI Globals
Global $GUI, $GUIImage, $GUIGraphic
Global $GUIImages[12] = [ "troop-archer.png", "troop-balloon.png", "troop-barbarian.png", _
   "troop-dragon.png", "troop-giant.png", "troop-goblin.png", "troop-healer.png", _
   "troop-pekka.png", "troop-wallbreaker.png", "troop-wizard.png" , "troop-bk.png", "troop-aq.png"]
Global $GUI_FindMatchCheckBox, $GUI_FindSnipableTHCheckBox, $GUI_AutoRaidCheckBox, $GUI_KeepOnlineCheckBox, $GUI_CollectLootCheckBox
Global $GUI_CloseButton
Global $GUI_GoldEdit, $GUI_ElixEdit, $GUI_DarkEdit, $GUI_TownHallEdit, $GUI_AutoRaidUseBreakers, $GUI_AutoRaidBreakerCountEdit, _
	  $GUI_AutoRaidZapDE, $GUI_AutoRaidZapDEMin, $GUI_AutoRaidDumpCups, $GUI_AutoRaidDumpCupsThreshold, $GUI_AutoRaidStrategyCombo
Global $GUI_MyGold, $GUI_MyElix, $GUI_MyDark, $GUI_MyGems, $GUI_MyCups
Global $GUI_Winnings, $GUI_Results, $GUI_AutoRaid
Global $defaultGold, $defaultElix, $defaultDark, $defaultTownHall, $defaultAutoRaidUseBreakers, $defaultBreakerCount, _
	  $defaultAutoRaidZapDE, $defaultAutoRaidZapDEMin, $defaultAutoRaidDumpCups, $defaultAutoRaidDumpCupsThreshold, $defaultAutoRaidStrategy
Global $findMatchClicked = False, $findSnipableTHClicked = False, $autoRaidClicked = False
Global $keepOnlineClicked = False, $collectLootClicked = False

Func InitGUI()
   ReadSettings()

   Local $p = WinGetPos($title)
   $GUI = GUICreate("ClAsHbOt v" & $version, 275, 424, $p[0]+$p[2]+4, $p[1])

   ; Left side, match filters group
   Local $y = 24
   GUICtrlCreateGroup("Match Filters", 5, 7, 126, 88)
   GUICtrlCreateLabel("Gold >=", 10, $y, 40, 17)
   $GUI_GoldEdit = GUICtrlCreateEdit($defaultGold, 50, $y-2, 60, 17, $ES_NUMBER)

   $y += 17
   GUICtrlCreateLabel("Elixir >=", 10, 41, 40, 17)
   $GUI_ElixEdit = GUICtrlCreateEdit($defaultElix, 50, $y-2, 60, 17, $ES_NUMBER)

   $y += 17
   GUICtrlCreateLabel("Dark >=", 10, 58, 40, 17)
   $GUI_DarkEdit = GUICtrlCreateEdit($defaultDark, 50, $y-2, 60, 17, $ES_NUMBER)

   $y += 17
   GUICtrlCreateLabel("TH <=", 10, 75, 40, 17)
   $GUI_TownHallEdit = GUICtrlCreateEdit($defaultTownHall, 50, $y-2, 60, 17, $ES_NUMBER)

   ; Left side, things todo group
   $y = 120
   GUICtrlCreateGroup("Things Todo", 5, 107, 126, 118)
   $GUI_KeepOnlineCheckBox = GUICtrlCreateCheckbox("F6 Keep Online 0:00", 10, $y, 120, 25)
   GUICtrlSetOnEvent($GUI_KeepOnlineCheckBox, "GUIKeepOnlineCheckBox")

   $y += 19
   $GUI_CollectLootCheckBox = GUICtrlCreateCheckbox("F7 Collect Loot 0:00", 10, $y, 120, 25)
   GUICtrlSetOnEvent($GUI_CollectLootCheckBox, "GUICollectLootCheckBox")

   $y += 19
   $GUI_FindMatchCheckBox = GUICtrlCreateCheckbox("F8 Find Match", 10, $y, 120, 25)
   GUICtrlSetOnEvent($GUI_FindMatchCheckBox, "GUIFindMatchCheckBox")

   $y += 19
   $GUI_FindSnipableTHCheckBox = GUICtrlCreateCheckbox("F9 Find Snipable TH", 10, $y, 120, 25)
   GUICtrlSetOnEvent($GUI_FindSnipableTHCheckBox, "GUIFindSnipableTHCheckBox")

   $y += 19
   $GUI_AutoRaidCheckBox = GUICtrlCreateCheckbox("F10 Auto Raid", 10, $y, 120, 25)
   GUICtrlSetOnEvent($GUI_AutoRaidCheckBox, "GUIAutoRaidCheckBox")

   ; Right side
   GUICtrlCreateGroup("My Stuff", 145, 7, 105, 94)
   $GUI_MyGold = GUICtrlCreateLabel("-", 150, 22, 60, 17, $SS_RIGHT)
   $GUI_MyElix = GUICtrlCreateLabel("-", 150, 37, 60, 17, $SS_RIGHT)
   $GUI_MyDark = GUICtrlCreateLabel("-", 150, 52, 60, 17, $SS_RIGHT)
   $GUI_MyGems = GUICtrlCreateLabel("-", 150, 67, 60, 17, $SS_RIGHT)
   $GUI_MyCups = GUICtrlCreateLabel("-", 150, 82, 60, 17, $SS_RIGHT)
   GUICtrlCreateLabel("Gold", 215, 22, 30, 17)
   GUICtrlCreateLabel("Elixir", 215, 37, 30, 17)
   GUICtrlCreateLabel("Dark", 215, 52, 30, 17)
   GUICtrlCreateLabel("Gems", 215, 67, 30, 17)
   GUICtrlCreateLabel("Cups", 215, 82, 30, 17)

   ; Right side, auto raid options group
   $y = 120
   GUICtrlCreateGroup("Auto Raid Options", 145, 105, 126, 124)
   $GUI_AutoRaidUseBreakers = GUICtrlCreateCheckbox("Use Breakers", 150, $y, 80, 25)
   _GUICtrlButton_SetCheck($GUI_AutoRaidUseBreakers, $defaultAutoRaidUseBreakers)
   $GUI_AutoRaidBreakerCountEdit = GUICtrlCreateEdit($defaultBreakerCount, 240, $y+4, 26, 17, $ES_NUMBER)
   $y += 19
   $GUI_AutoRaidZapDE = GUICtrlCreateCheckbox("Zap DE >=", 150, $y, 70, 25)
   _GUICtrlButton_SetCheck($GUI_AutoRaidZapDE, $defaultAutoRaidZapDE)
   $GUI_AutoRaidZapDEMin = GUICtrlCreateEdit($defaultAutoRaidZapDEMin, 230, $y+4, 36, 17, $ES_NUMBER)
   $y += 19
   $GUI_AutoRaidDumpCups = GUICtrlCreateCheckbox("Dump Cups >", 150, $y, 80, 25)
   _GUICtrlButton_SetCheck($GUI_AutoRaidDumpCups, $defaultAutoRaidDumpCups)
   $GUI_AutoRaidDumpCupsThreshold = GUICtrlCreateEdit($defaultAutoRaidDumpCupsThreshold, 230, $y+4, 36, 17, $ES_NUMBER)
   $y += 25
   GUICtrlCreateLabel("Strategy:", 150, $y, 116, 17)
   $y += 15
   $GUI_AutoRaidStrategyCombo = _GUICtrlComboBox_Create($GUI, "", 150, $y, 116, 17, $CBS_DROPDOWNLIST)
   _GUICtrlComboBox_AddString($GUI_AutoRaidStrategyCombo, "Barcher, top or bottom")
   _GUICtrlComboBox_AddString($GUI_AutoRaidStrategyCombo, "TBD1")
   _GUICtrlComboBox_AddString($GUI_AutoRaidStrategyCombo, "TBD2")
   _GUICtrlComboBox_AddString($GUI_AutoRaidStrategyCombo, "TBD3")
   _GUICtrlComboBox_SetCurSel($GUI_AutoRaidStrategyCombo, $defaultAutoRaidStrategy)

   ; Bottom
   $y = 230
   $GUI_Winnings = GUICtrlCreateLabel("Winnings: 0 / 0 / 0 / 0", 10, $y, 260, 17)
   $y += 19
   $GUI_Results = GUICtrlCreateLabel("Last scan: 0 / 0 / 0 / 0 / 0", 10, $y, 260, 17)
   $y += 19
   $GUI_AutoRaid = GUICtrlCreateLabel("Auto Raid: Not Auto Raiding", 10, $y, 260, 17)


   $GUI_CloseButton = GUICtrlCreateButton("F11 Close", 20, 389, 70, 25)
   GUICtrlSetOnEvent($GUI_CloseButton, "GUICloseButton")
   GUISetOnEvent($GUI_EVENT_CLOSE, "GUICloseButton")

   ; Image
   RandomImage()

   $GUIGraphic = _GDIPlus_GraphicsCreateFromHWND($GUI)
   GUIRegisterMsg($WM_PAINT, "PNG")
   GUISetState(@SW_SHOW)
EndFunc

Func ExitGUI()
   _GDIPlus_GraphicsDispose($GUIGraphic)
   _GDIPlus_ImageDispose($GUIImage)
   SaveSettings()
   GUIDelete($GUI)
EndFunc

;Draw PNG image
Func PNG($hWnd, $Msg, $wParam, $lParam)
   _WinAPI_RedrawWindow($GUI, 0, 0, $RDW_UPDATENOW)
   Local $Width = _GDIPlus_ImageGetWidth($GUIImage)
   ;_GDIPlus_GraphicsClear($GUIGraphic)
   _GDIPlus_GraphicsDrawImage($GUIGraphic, $GUIImage, 200-($Width/2), 285)
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

Func ReadSettings()
   $defaultGold = IniRead("CoC Bot.ini", "General", "Gold", 150000)
   $defaultElix = IniRead("CoC Bot.ini", "General", "Elixir", 150000)
   $defaultDark = IniRead("CoC Bot.ini", "General", "Dark Elixir", 1500)
   $defaultTownHall = IniRead("CoC Bot.ini", "General", "Town Hall", 8)
   $defaultAutoRaidUseBreakers = IniRead("CoC Bot.ini", "General", "Use Breakers", $BST_UNCHECKED)
   $defaultBreakerCount = IniRead("CoC Bot.ini", "General", "Breaker Count", 4)
   $defaultAutoRaidZapDE = IniRead("CoC Bot.ini", "General", "Zap DE", $BST_UNCHECKED)
   $defaultAutoRaidZapDEMin = IniRead("CoC Bot.ini", "General", "Zap DE Min", 1200)
   $defaultAutoRaidDumpCups = IniRead("CoC Bot.ini", "General", "Dump Cups", $BST_UNCHECKED)
   $defaultAutoRaidDumpCupsThreshold = IniRead("CoC Bot.ini", "General", "Dump Cups Threshold", 1700)
   $defaultAutoRaidStrategy = IniRead("CoC Bot.ini", "General", "Raid Strategy", 0)
EndFunc

Func SaveSettings()
   IniWrite("CoC Bot.ini", "General", "Gold", GUICtrlRead($GUI_GoldEdit))
   IniWrite("CoC Bot.ini", "General", "Elixir", GUICtrlRead($GUI_ElixEdit))
   IniWrite("CoC Bot.ini", "General", "Dark Elixir", GUICtrlRead($GUI_DarkEdit))
   IniWrite("CoC Bot.ini", "General", "Town Hall", GUICtrlRead($GUI_TownHallEdit))
   IniWrite("CoC Bot.ini", "General", "Use Breakers", _GUICtrlButton_GetCheck($GUI_AutoRaidUseBreakers))
   IniWrite("CoC Bot.ini", "General", "Breaker Count", GUICtrlRead($GUI_AutoRaidBreakerCountEdit))
   IniWrite("CoC Bot.ini", "General", "Zap DE", _GUICtrlButton_GetCheck($GUI_AutoRaidZapDE))
   IniWrite("CoC Bot.ini", "General", "Zap DE Min", GUICtrlRead($GUI_AutoRaidZapDEMin))
   IniWrite("CoC Bot.ini", "General", "Dump Cups", _GUICtrlButton_GetCheck($GUI_AutoRaidDumpCups))
   IniWrite("CoC Bot.ini", "General", "Dump Cups Threshold", GUICtrlRead($GUI_AutoRaidDumpCupsThreshold))
   IniWrite("CoC Bot.ini", "General", "Raid Strategy", _GUICtrlComboBox_GetCurSel($GUI_AutoRaidStrategyCombo))
EndFunc


Func HotKeyPressed()
   Switch @HotKeyPressed
   Case "{F6}" ; Keep Online
	  Local $chk = (_GUICtrlButton_GetCheck($GUI_KeepOnlineCheckBox) = $BST_CHECKED) ? True : False
	  _GUICtrlButton_SetCheck($GUI_KeepOnlineCheckBox, $chk ? $BST_UNCHECKED : $BST_CHECKED)
	  GUIKeepOnlineCheckBox()

   Case "{F7}" ; Collect Resources
	  Local $chk = (_GUICtrlButton_GetCheck($GUI_CollectLootCheckBox) = $BST_CHECKED) ? True : False
	  _GUICtrlButton_SetCheck($GUI_CollectLootCheckBox, $chk ? $BST_UNCHECKED : $BST_CHECKED)
	  GUICollectLootCheckBox()

   Case "{F8}" ; Find Match
	  Local $chk = (_GUICtrlButton_GetCheck($GUI_FindMatchCheckBox) = $BST_CHECKED) ? True : False
	  _GUICtrlButton_SetCheck($GUI_FindMatchCheckBox, $chk ? $BST_UNCHECKED : $BST_CHECKED)
	  GUIFindMatchCheckBox()

   Case "{F9}" ; Find Snipable TH
	  Local $chk = (_GUICtrlButton_GetCheck($GUI_FindSnipableTHCheckBox) = $BST_CHECKED) ? True : False
	  _GUICtrlButton_SetCheck($GUI_FindSnipableTHCheckBox, $chk ? $BST_UNCHECKED : $BST_CHECKED)
	  GUIFindSnipableTHCheckBox()

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
   $keepOnlineClicked = (_GUICtrlButton_GetCheck($GUI_KeepOnlineCheckBox) = $BST_CHECKED) ? True : False
EndFunc

Func GUICollectLootCheckBox()
   DebugWrite("Collect Loot clicked")
   $collectLootClicked = (_GUICtrlButton_GetCheck($GUI_CollectLootCheckBox) = $BST_CHECKED) ? True : False

   If $collectLootClicked Then
	  ZoomOut(True)
   EndIf
EndFunc

Func GUIFindMatchCheckBox()
   DebugWrite("Find Match clicked")
   $findMatchClicked = (_GUICtrlButton_GetCheck($GUI_FindMatchCheckBox) = $BST_CHECKED) ? True : False
   _GUICtrlButton_Enable($GUI_FindSnipableTHCheckBox, Not($findMatchClicked))
   _GUICtrlButton_Enable($GUI_AutoRaidCheckBox, Not($findMatchClicked))

   If $findMatchClicked Then
	  HotKeySet("{F9}") ; Find Snipable TH
	  HotKeySet("{F10}") ; Auto Raid
	  _GUICtrlButton_SetCheck($GUI_FindSnipableTHCheckBox, $BST_UNCHECKED)
	  _GUICtrlButton_SetCheck($GUI_AutoRaidCheckBox, $BST_UNCHECKED)
	  ZoomOut(True)
   Else
	  HotKeySet("{F9}", HotKeyPressed) ; Find Snipable TH
	  HotKeySet("{F10}", HotKeyPressed) ; Auto Raid
   EndIf

EndFunc

Func GUIFindSnipableTHCheckBox()
   DebugWrite("Find Snipable TH clicked")
   $findSnipableTHClicked = (_GUICtrlButton_GetCheck($GUI_FindSnipableTHCheckBox) = $BST_CHECKED) ? True : False
   _GUICtrlButton_Enable($GUI_FindMatchCheckBox, Not($findSnipableTHClicked))
   _GUICtrlButton_Enable($GUI_AutoRaidCheckBox, Not($findSnipableTHClicked))

   If $findSnipableTHClicked Then
	  HotKeySet("{F8}") ; Find Match
	  HotKeySet("{F10}") ; Auto Raid
	  _GUICtrlButton_SetCheck($GUI_FindMatchCheckBox, $BST_UNCHECKED)
	  _GUICtrlButton_SetCheck($GUI_AutoRaidCheckBox, $BST_UNCHECKED)
	  ZoomOut(True)
   Else
	  HotKeySet("{F8}", HotKeyPressed) ; Find Match
	  HotKeySet("{F10}", HotKeyPressed) ; Auto Raid
   EndIf
EndFunc

Func GUIAutoRaidCheckBox()
   DebugWrite("Auto Raid clicked")
   Local $test = _GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox)
   $autoRaidClicked = (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_CHECKED) ? True : False
   _GUICtrlButton_Enable($GUI_FindMatchCheckBox, Not($autoRaidClicked))
   _GUICtrlButton_Enable($GUI_FindSnipableTHCheckBox, Not($autoRaidClicked))

   If $autoRaidClicked Then
	  HotKeySet("{F8}") ; Find Match
	  HotKeySet("{F9}") ; Find Snipable TH
	  _GUICtrlButton_SetCheck($GUI_FindMatchCheckBox, $BST_UNCHECKED)
	  _GUICtrlButton_SetCheck($GUI_FindSnipableTHCheckBox, $BST_UNCHECKED)
	  ZoomOut(True)
	  ResetAutoRaidCounts()
   Else
	  HotKeySet("{F8}", HotKeyPressed) ; Find Match
	  HotKeySet("{F9}", HotKeyPressed) ; Find Snipable TH
   EndIf

   $autoRaidStage = ($autoRaidClicked ? $AutoRaidQueueTraining : $AutoRaidNotStarted)

   If $autoRaidStage = $AutoRaidNotStarted Then GUICtrlSetData($GUI_AutoRaid, "Auto Raid: Not Auto Raiding")
EndFunc

Func GUICloseButton()
   DebugWrite("Close clicked")
   $ExitApp = True
EndFunc

Func CaptureAutoRaidBegin()
   GetMyLootNumbers()

   ; Capture starting stuff
   Local $n = GUICtrlRead($GUI_MyGold)
   If $n <> "-" Then $beginGold = $n
   $n = GUICtrlRead($GUI_MyElix)
   If $n <> "-" Then $beginElix = $n
   $n = GUICtrlRead($GUI_MyDark)
   If $n <> "-" Then $beginDark = $n
   $n = GUICtrlRead($GUI_MyCups)
   If $n <> "-" Then $beginCups = $n

   If $beginGold<>-1 And $beginElix<>-1 And $beginDark<>-1 And $beginCups<>-1 Then
	  DebugWrite("AutoRaid Begin: " & _
		 " Gold:" & $beginGold & _
		 " Elix:" & $beginElix & _
		 " Dark:" & $beginDark & _
		 " Cups:" & $beginCups)

	  ResetAutoRaidCounts()
   EndIf
EndFunc

Func ResetAutoRaidCounts()
   $goldWinnings = 0
   $elixWinnings = 0
   $darkWinnings = 0
   $cupsWinnings = 0
   GUICtrlSetData($GUI_Winnings, "Winnings: 0 / 0 / 0 / 0")
EndFunc

