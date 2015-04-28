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
Global $GUI_Width=285, $GUI_Height=417
Global $GUIImages[12] = [ "troop-archer.png", "troop-balloon.png", "troop-barbarian.png", _
   "troop-dragon.png", "troop-giant.png", "troop-goblin.png", "troop-healer.png", _
   "troop-pekka.png", "troop-wallbreaker.png", "troop-wizard.png" , "troop-bk.png", "troop-aq.png"]
Global $GUI_KeepOnlineCheckBox, $GUI_CollectLootCheckBox, $GUI_DonateTroopsCheckBox, _
	  $GUI_FindMatchCheckBox, $GUI_FindSnipableTHCheckBox, $GUI_AutoRaidCheckBox
Global $GUI_CloseButton
Global $GUI_GoldEdit, $GUI_ElixEdit, $GUI_DarkEdit, $GUI_TownHallEdit, $GUI_AutoRaidUseBreakers, $GUI_AutoRaidBreakerCountEdit, _
	  $GUI_AutoRaidZapDE, $GUI_AutoRaidZapDEMin, $GUI_AutoRaidDumpCups, $GUI_AutoRaidDumpCupsThreshold, $GUI_AutoRaidStrategyCombo
Global $GUI_MyGold, $GUI_MyElix, $GUI_MyDark, $GUI_MyGems, $GUI_MyCups
Global $GUI_Winnings, $GUI_Results, $GUI_AutoRaid

Func InitGUI()
   Local $p = WinGetPos($gTitle)
   $GUI = GUICreate("ClAsHbOt v" & $version, $GUI_Width, $GUI_Height, $p[0]+$p[2]+8, $p[1])

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
   $h=137
   GUICtrlCreateGroup("Things Todo", $x, $y, $w, $h)

   $y += 15
   $GUI_KeepOnlineCheckBox = GUICtrlCreateCheckbox("F5 Keep Online 0:00", $x+5, $y, $w-6, 25)
   GUICtrlSetOnEvent($GUI_KeepOnlineCheckBox, "GUIKeepOnlineCheckBox")

   $y += 19
   $GUI_CollectLootCheckBox = GUICtrlCreateCheckbox("F6 Collect Loot 0:00", $x+5, $y, $w-6, 25)
   GUICtrlSetOnEvent($GUI_CollectLootCheckBox, "GUICollectLootCheckBox")

   $y += 19
   $GUI_DonateTroopsCheckBox = GUICtrlCreateCheckbox("F7 Donate Troops 0:00", $x+5, $y, $w-6, 25)
   GUICtrlSetOnEvent($GUI_DonateTroopsCheckBox, "GUIDonateTroopsCheckBox")

   $y += 19
   $GUI_FindMatchCheckBox = GUICtrlCreateCheckbox("F8 Find Match", $x+5, $y, $w-6, 25)
   GUICtrlSetOnEvent($GUI_FindMatchCheckBox, "GUIFindMatchCheckBox")

   $y += 19
   $GUI_FindSnipableTHCheckBox = GUICtrlCreateCheckbox("F9 Find Snipable TH", $x+5, $y, $w-6, 25)
   GUICtrlSetOnEvent($GUI_FindSnipableTHCheckBox, "GUIFindSnipableTHCheckBox")

   $y += 19
   $GUI_AutoRaidCheckBox = GUICtrlCreateCheckbox("F10 Auto Raid", $x+5, $y, $w-6, 25)
   GUICtrlSetOnEvent($GUI_AutoRaidCheckBox, "GUIAutoRaidCheckBox")

   ; Right side, my stuff group
   $x=153
   $y=10
   $w=125
   $h=97

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

   ; Right side, auto raid options group
   $y += 29
   $h=130
   GUICtrlCreateGroup("Auto Raid Options", $x, $y, $w, $h)

   $y += 15
   $GUI_AutoRaidUseBreakers = GUICtrlCreateCheckbox("Use Breakers", $x+5, $y, 80, 25)
   _GUICtrlButton_SetCheck($GUI_AutoRaidUseBreakers, IniRead($gIniFile, "General", "Use Breakers", $BST_UNCHECKED))
   $GUI_AutoRaidBreakerCountEdit = GUICtrlCreateEdit(IniRead($gIniFile, "General", "Breaker Count", 4), $x+93, $y+4, 26, 17, $ES_NUMBER)

   $y += 19
   $GUI_AutoRaidZapDE = GUICtrlCreateCheckbox("Zap DE >=", $x+5, $y, 70, 25)
   _GUICtrlButton_SetCheck($GUI_AutoRaidZapDE, IniRead($gIniFile, "General", "Zap DE", $BST_UNCHECKED))
   $GUI_AutoRaidZapDEMin = GUICtrlCreateEdit(IniRead($gIniFile, "General", "Zap DE Min", 1200), $x+83, $y+4, 36, 17, $ES_NUMBER)

   $y += 19
   $GUI_AutoRaidDumpCups = GUICtrlCreateCheckbox("Dump Cups >", $x+5, $y, 80, 25)
   _GUICtrlButton_SetCheck($GUI_AutoRaidDumpCups, IniRead($gIniFile, "General", "Dump Cups", $BST_UNCHECKED))
   $GUI_AutoRaidDumpCupsThreshold = GUICtrlCreateEdit(IniRead($gIniFile, "General", "Dump Cups Threshold", 1700), $x+83, $y+4, 36, 17, $ES_NUMBER)

   $y += 27
   GUICtrlCreateLabel("Strategy:", $x+5, $y, 116, 17)

   $y += 17
   $GUI_AutoRaidStrategyCombo = GUICtrlCreateCombo("", $x+5, $y, 116, 17, $CBS_DROPDOWNLIST)
   _GUICtrlComboBox_AddString($GUI_AutoRaidStrategyCombo, "Barcher, top or bottom")
   _GUICtrlComboBox_AddString($GUI_AutoRaidStrategyCombo, "TBD1")
   _GUICtrlComboBox_AddString($GUI_AutoRaidStrategyCombo, "TBD2")
   _GUICtrlComboBox_AddString($GUI_AutoRaidStrategyCombo, "TBD3")
   _GUICtrlComboBox_SetCurSel($GUI_AutoRaidStrategyCombo, IniRead($gIniFile, "General", "Raid Strategy", 0))

   ; Bottom
   $x = 10
   $y = 249
   $w = 265
   $GUI_Winnings = GUICtrlCreateLabel("Winnings: 0 / 0 / 0 / 0", $x, $y, $w, 17)

   $y += 19
   $GUI_Results = GUICtrlCreateLabel("Last scan: 0 / 0 / 0 / 0 / 0", $x, $y, $w, 17)

   $y += 19
   $GUI_AutoRaid = GUICtrlCreateLabel("Auto Raid: Not Auto Raiding", $x, $y, $w, 17)

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
   $gKeepOnlineClicked = (_GUICtrlButton_GetCheck($GUI_KeepOnlineCheckBox) = $BST_CHECKED) ? True : False
EndFunc

Func GUICollectLootCheckBox()
   DebugWrite("Collect Loot clicked")
   $gCollectLootClicked = (_GUICtrlButton_GetCheck($GUI_CollectLootCheckBox) = $BST_CHECKED) ? True : False

   If $gCollectLootClicked Then
	  ZoomOut(True)
   EndIf
EndFunc

Func GUIDonateTroopsCheckBox()
   DebugWrite("Donate Troops clicked")
   $gDonateTroopsClicked = (_GUICtrlButton_GetCheck($GUI_DonateTroopsCheckBox) = $BST_CHECKED) ? True : False
EndFunc

Func GUIFindMatchCheckBox()
   DebugWrite("Find Match clicked")
   $gFindMatchClicked = (_GUICtrlButton_GetCheck($GUI_FindMatchCheckBox) = $BST_CHECKED) ? True : False
   _GUICtrlButton_Enable($GUI_FindSnipableTHCheckBox, Not($gFindMatchClicked))
   _GUICtrlButton_Enable($GUI_AutoRaidCheckBox, Not($gFindMatchClicked))

   If $gFindMatchClicked Then
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
   $gFindSnipableTHClicked = (_GUICtrlButton_GetCheck($GUI_FindSnipableTHCheckBox) = $BST_CHECKED) ? True : False
   _GUICtrlButton_Enable($GUI_FindMatchCheckBox, Not($gFindSnipableTHClicked))
   _GUICtrlButton_Enable($GUI_AutoRaidCheckBox, Not($gFindSnipableTHClicked))

   If $gFindSnipableTHClicked Then
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
   $gAutoRaidClicked = (_GUICtrlButton_GetCheck($GUI_AutoRaidCheckBox) = $BST_CHECKED) ? True : False
   _GUICtrlButton_Enable($GUI_FindMatchCheckBox, Not($gAutoRaidClicked))
   _GUICtrlButton_Enable($GUI_FindSnipableTHCheckBox, Not($gAutoRaidClicked))

   If $gAutoRaidClicked Then
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

   $gAutoRaidStage = ($gAutoRaidClicked ? $eAutoRaidQueueTraining : $eAutoRaidNotStarted)

   If $gAutoRaidStage = $eAutoRaidNotStarted Then GUICtrlSetData($GUI_AutoRaid, "Auto Raid: Not Auto Raiding")
EndFunc

Func GUICloseButton()
   DebugWrite("Close clicked")
   SaveSettings()
   ExitGUI()
   ExitScraper()
   Exit
EndFunc

Func CaptureAutoRaidBegin()
   GetMyLootNumbers()

   ; Capture starting stuff
   Local $n = GUICtrlRead($GUI_MyGold)
   If $n <> "-" Then $gAutoRaidBeginLoot[0] = $n
   $n = GUICtrlRead($GUI_MyElix)
   If $n <> "-" Then $gAutoRaidBeginLoot[1] = $n
   $n = GUICtrlRead($GUI_MyDark)
   If $n <> "-" Then $gAutoRaidBeginLoot[2] = $n
   $n = GUICtrlRead($GUI_MyCups)
   If $n <> "-" Then $gAutoRaidBeginLoot[3] = $n

   If $gAutoRaidBeginLoot[0]<>-1 And $gAutoRaidBeginLoot[1]<>-1 And $gAutoRaidBeginLoot[2]<>-1 And $gAutoRaidBeginLoot[3]<>-1 Then
	  DebugWrite("AutoRaid Begin: " & _
		 " Gold:" & $gAutoRaidBeginLoot[0] & _
		 " Elix:" & $gAutoRaidBeginLoot[1] & _
		 " Dark:" & $gAutoRaidBeginLoot[2] & _
		 " Cups:" & $gAutoRaidBeginLoot[3])

	  ResetAutoRaidCounts()
   EndIf
EndFunc

Func ResetAutoRaidCounts()
   For $i = 0 To 3
	  $gAutoRaidWinnings[$i] = 0
   Next

   GUICtrlSetData($GUI_Winnings, "Winnings: 0 / 0 / 0 / 0")
EndFunc

