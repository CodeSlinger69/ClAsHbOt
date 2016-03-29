Func TestMyStuff()
   Local $hHBITMAP = CaptureFrameHBITMAP("TestMyStuff")

   DebugWrite("My Gold: " & ScrapeFuzzyText($hHBITMAP, $fontMyStuff, $rMyGoldTextBox))
   DebugWrite("My Elix: " & ScrapeFuzzyText($hHBITMAP, $fontMyStuff, $rMyElixTextBox))
   If IsTextBoxPresent($hHBITMAP, $rMyGemsTextBoxWithDE) = True Then
	  DebugWrite("My Dark: " & ScrapeFuzzyText($hHBITMAP, $fontMyStuff, $rMyDarkTextBox))
   EndIf
   If IsTextBoxPresent($hHBITMAP, $rMyGemsTextBoxNoDE) = True Then
	  DebugWrite("My Gems: " & ScrapeFuzzyText($hHBITMAP, $fontMyStuff, $rMyGemsTextBoxNoDE))
   Else
	  DebugWrite("My Gems: " & ScrapeFuzzyText($hHBITMAP, $fontMyStuff, $rMyGemsTextBoxWithDE))
   EndIf
   DebugWrite("My Cups: " & ScrapeFuzzyText($hHBITMAP, $fontMyStuff, $rMyCupsTextBox))

   _WinAPI_DeleteObject($hHBITMAP)
EndFunc

Func TestRaidLoot()
   Local $thLevel, $thLeft, $thTop, $gold, $elix, $dark, $cups, $deadBase
   AutoRaidGetDisplayedLoot($thLevel, $thLeft, $thTop, $gold, $elix, $dark, $cups, $deadbase)
   DebugWrite("TestRaidLoot() " & $gold & " / " & $elix & " / " & $dark &  " / " & $cups & " / " & $thLevel & " / " & $deadBase)
EndFunc

Func TestEndBattleLoot()
   Local $hHBITMAP = CaptureFrameHBITMAP("TestEndBattleLoot")
   Local $goldWin = Number(ScrapeFuzzyText($hHBITMAP, $fontBattleEndWinnings, $rEndBattleGoldTextBox))
   Local $elixWin = Number(ScrapeFuzzyText($hHBITMAP, $fontBattleEndWinnings, $rEndBattleElixTextBox))
   Local $darkWin = IsTextBoxPresent($hHBITMAP, $rEndBattleDarkTextBox) ? _
				    Number(ScrapeFuzzyText($hHBITMAP, $fontBattleEndWinnings, $rEndBattleDarkTextBox)) : 0
   Local $cupsWin = IsTextBoxPresent($hHBITMAP, $rEndBattleCupsWithDETextBox) ? _
					Number(ScrapeFuzzyText($hHBITMAP, $fontBattleEndWinnings, $rEndBattleCupsWithDETextBox)) : _
					Number(ScrapeFuzzyText($hHBITMAP, $fontBattleEndWinnings, $rEndBattleCupsNoDETextBox))
   DebugWrite("Gold: " & $goldWin)
   DebugWrite("Elix: " & $elixWin)
   DebugWrite("Dark: " & $darkWin)
   DebugWrite("Cups: " & $cupsWin)

   _WinAPI_DeleteObject($hHBITMAP)
EndFunc

Func TestEndBattleBonus()
   Local $hHBITMAP = CaptureFrameHBITMAP("TestEndBattleLoot")
   Local $goldBonus = 0
   Local $elixBonus = 0
   Local $darkBonus = 0
   If IsTextBoxPresent($hHBITMAP, $rEndBattleBonusGoldTextBox) Or _
	  IsTextBoxPresent($hHBITMAP, $rEndBattleBonusElixTextBox) Or _
	  IsTextBoxPresent($hHBITMAP, $rEndBattleBonusDarkTextBox) Then

	  $goldBonus = ScrapeFuzzyText($hHBITMAP, $fontBattleEndBonus, $rEndBattleBonusGoldTextBox)
	  $goldBonus = StringLeft($goldBonus, 1) = "+" ? Number(StringMid($goldBonus, 2)) : 0
	  $elixBonus = ScrapeFuzzyText($hHBITMAP, $fontBattleEndBonus, $rEndBattleBonusElixTextBox)
	  $elixBonus = StringLeft($elixBonus, 1) = "+" ? Number(StringMid($elixBonus, 2)) : 0
	  $darkBonus = ScrapeFuzzyText($hHBITMAP, $fontBattleEndBonus, $rEndBattleBonusDarkTextBox)
	  $darkBonus = StringLeft($darkBonus, 1) = "+" ? Number(StringMid($darkBonus, 2)) : 0
	  DebugWrite("Bonus this match: " & $goldBonus & " / " & $elixBonus & " / " & $darkBonus)
   EndIf
   _WinAPI_DeleteObject($hHBITMAP)
EndFunc

Func TestStorage()
   Local $x, $y, $conf, $value, $matchIndex

   Local $t = TimerInit()
   Local $res = FindBestBMP($eSearchTypeGoldStorage, $x, $y, $conf, $value)
   DebugWrite("Gold: " & Round(TimerDiff($t)) & "ms")
   DebugWrite("Gold Match: " & $value)
   If $res Then
	  Local $level = Number(StringMid($value, StringInStr($value, "GoldStorageL")+12, 2))
	  Local $usage = Number(StringMid($value, StringInStr($value, "GoldStorageL")+15, 2))
	  DebugWrite("Level " & $level & ", average " & $usage & "% full, confidence " & Round($conf*100, 2) & "%")
   EndIf

   Local $t = TimerInit()
   Local $res = FindBestBMP($eSearchTypeElixStorage, $x, $y, $conf, $value)
   DebugWrite("Elix: " & Round(TimerDiff($t)) & "ms")
   DebugWrite("Elix Match: " & $value)
   If $res Then
	  Local $level = Number(StringMid($value, StringInStr($value, "ElixStorageL")+12, 2))
	  Local $usage = Number(StringMid($value, StringInStr($value, "ElixStorageL")+15, 2))
	  DebugWrite("Level " & $level & ", average " & $usage & "% full, confidence " & Round($conf*100, 2) & "%")
   EndIf
EndFunc

Func TestFindAllStorages()
   Local $x[1], $y[1], $c[1], $matchCount

   Local $t = TimerInit()
   Local $res = FindAllBMPs($eSearchTypeGoldStorage, 4, $x, $y, $c, $matchCount)
   DebugWrite("Gold: " & Round(TimerDiff($t)) & "ms")

   DebugWrite("Gold Match $res=" & $res & " Count: " & $matchCount)
   For $i = 0 To $matchCount-1
	  DebugWrite("Gold Match " & $i & ": " & $x[$i] & "," & $y[$i] & ", confidence " & Round($c[$i]*100, 2) & "%")
   Next

   Local $t = TimerInit()
   Local $res = FindAllBMPs($eSearchTypeElixStorage, 4, $x, $y, $c, $matchCount)
   DebugWrite("Elix: " & Round(TimerDiff($t)) & "ms")

   DebugWrite("Elix Match $res=" & $res & " Count: " & $matchCount)
   For $i = 0 To $matchCount-1
	  DebugWrite("Elix Match " & $i & ": " & $x[$i] & "," & $y[$i] & ", confidence " & Round($c[$i]*100, 2) & "%")
   Next
EndFunc

Func TestRaidTroopsCount()
   ; Troops
   Local $troopIndex[$eTroopCount][5]
   For $i = 0 To UBound($troopIndex)-1
	  $troopIndex[$i][0] = -1
	  $troopIndex[$i][1] = -1
	  $troopIndex[$i][2] = -1
	  $troopIndex[$i][3] = -1
	  $troopIndex[$i][4] = 0
   Next

   RandomWeightedClick($rRaidSlotsButton1)
   Sleep(200)
   LocateSlots($eActionTypeRaid, $eSlotTypeTroop, $troopIndex)

   RandomWeightedClick($rRaidSlotsButton2)
   Sleep(200)
   LocateSlots($eActionTypeRaid, $eSlotTypeTroop, $troopIndex)

   For $i=0 To $eTroopCount-1
	  If $troopIndex[$i][0]<>-1 Then DebugWrite("Slots " & $gTroopNames[$i] & ": " & $troopIndex[$i][0] & " " & $troopIndex[$i][1] & " " & $troopIndex[$i][2] & " " & $troopIndex[$i][3])
   Next

   UpdateRaidSlotCounts($troopIndex)

   For $i=0 To $eTroopCount-1
	  If $troopIndex[$i][4]>0 Then DebugWrite("Available " & $gTroopNames[$i] & ": " & $troopIndex[$i][4])
   Next

   ; Spells
   Local $spellIndex[$eSpellCount][5]
   For $i = 0 To UBound($spellIndex)-1
	  $spellIndex[$i][0] = -1
	  $spellIndex[$i][1] = -1
	  $spellIndex[$i][2] = -1
	  $spellIndex[$i][3] = -1
	  $spellIndex[$i][4] = 0
   Next

   RandomWeightedClick($rRaidSlotsButton1)
   Sleep(200)
   LocateSlots($eActionTypeRaid, $eSlotTypeSpell, $spellIndex)

   RandomWeightedClick($rRaidSlotsButton2)
   Sleep(200)
   LocateSlots($eActionTypeRaid, $eSlotTypeSpell, $spellIndex)

   UpdateRaidSlotCounts($spellIndex)

   For $i=0 To $eSpellCount-1
	  If $spellIndex[$i][4]>0 Then DebugWrite("Available " & $gSpellNames[$i] & ": " & $spellIndex[$i][4])
   Next
EndFunc

Func TestBarracksStatus()
   Local $hHBITMAP = CaptureFrameHBITMAP("TestBarracksStatus")
   Local $queueStatus = ScrapeFuzzyText($hHBITMAP, $fontBarracksStatus, $rBarracksWindowTextBox)
   DebugWrite("Barracks queue status: " & $queueStatus)
   _WinAPI_DeleteObject($hHBITMAP)
EndFunc

Func TestBarracksTroopSlots()
   Local $troopSlots[$gTroopCountExcludingHeroes][4]
   For $i = $eTroopBarbarian To $eTroopLavaHound
	  $troopSlots[$i][0] = -1
	  $troopSlots[$i][1] = -1
	  $troopSlots[$i][2] = -1
	  $troopSlots[$i][3] = -1
   Next
   LocateSlots($eActionTypeBarracks, $eSlotTypeTroop, $troopSlots)

   For $i = $eTroopBarbarian To $eTroopLavaHound
	  If $troopSlots[$i][0]<>-1 Then DebugWrite("Barracks slot " & $gTroopNames[$i] & " @ " & $troopSlots[$i][0] & "," & $troopSlots[$i][1] & "," & $troopSlots[$i][2] & "," & $troopSlots[$i][3])
   Next
EndFunc

Func TestBuiltTroops()
   Local $builtTroopCounts[$eTroopCount][5]
   For $i = 0 To UBound($builtTroopCounts)-1
	  $builtTroopCounts[$i][0] = -1
	  $builtTroopCounts[$i][1] = -1
	  $builtTroopCounts[$i][2] = -1
	  $builtTroopCounts[$i][3] = -1
	  $builtTroopCounts[$i][4] = 0
   Next

   LocateSlots($eActionTypeCamp, $eSlotTypeTroop, $builtTroopCounts)
   LocateSlots($eActionTypeCamp, $eSlotTypeHero, $builtTroopCounts)
   UpdateArmyCampSlotCounts($builtTroopCounts)

   For $i = 0 To $eTroopCount-1
	  If $builtTroopCounts[$i][4]>0 Then DebugWrite("Built troops count " & $gTroopNames[$i] & "=" & $builtTroopCounts[$i][4])
   Next
EndFunc

Func TestDeployBoxCalcs()
   Local $box[19][4]
   Local $y = $gScreenCenter[1]-20
   Local $i = 0
   For $x = 45 To 405 Step 20
	  $box[$i][0] = $x
	  $box[$i][1] = $y
	  $box[$i][2] = $x+60
	  $box[$i][3] = $y+40
	  DebugWrite("NW Box: " & $i & " " & $box[$i][0] & "  " & $box[$i][1] & "  " & $box[$i][2] & "  " & $box[$i][3])
	  $i+=1
	  $y-=15
   Next

   $y = $gScreenCenter[1]-20
   $i=0
   For $x = 820 To 460 Step -20
	  $box[$i][0] = $x-60
	  $box[$i][1] = $y
	  $box[$i][2] = $x
	  $box[$i][3] = $y+40
	  DebugWrite("NE Box: " & $i & " " & $box[$i][0] & "  " & $box[$i][1] & "  " & $box[$i][2] & "  " & $box[$i][3])
	  $i+=1
	  $y-=15
   Next

   $y = $gScreenCenter[1]-20
   $i=0
   For $x = 45 To 405 Step 20
	  $box[$i][0] = $x
	  $box[$i][1] = $y
	  $box[$i][2] = $x+60
	  $box[$i][3] = $y+40
	  DebugWrite("SW Box: " & $i & " " & $box[$i][0] & "  " & $box[$i][1] & "  " & $box[$i][2] & "  " & $box[$i][3])
	  $i+=1
	  $y+=15
   Next

   $y = $gScreenCenter[1]-20
   $i=0
   For $x = 820 To 460 Step -20
	  $box[$i][0] = $x-60
	  $box[$i][1] = $y
	  $box[$i][2] = $x
	  $box[$i][3] = $y+40
	  DebugWrite("SE Box: " & $i & " " & $box[$i][0] & "  " & $box[$i][1] & "  " & $box[$i][2] & "  " & $box[$i][3])
	  $i+=1
	  $y+=15
   Next
EndFunc

Func TestDonate()
   Local $hBITMAP = CaptureFrameHBITMAP("TestDonate")
   If IsButtonPresent($hBITMAP, $rMainScreenOpenChatButton)=False Then OpenChatWindow($hBITMAP)

   Local $donateButtons[1][4]
   FindDonateButtons($donateButtons)

   For $i = 0 To UBound($donateButtons)-1
	  Local $requestText = GetRequestText($hBITMAP, $donateButtons, $i)

	  OpenDonateTroopsWindow($hBITMAP, $donateButtons, $i)

	  Local $donateTroopIndex[$gTroopCountExcludingHeroes][4]
	  For $j = 0 To $gTroopCountExcludingHeroes-1
		 $donateTroopIndex[$j][0] = -1
		 $donateTroopIndex[$j][1] = -1
		 $donateTroopIndex[$j][2] = -1
		 $donateTroopIndex[$j][3] = -1
	  Next
	  LocateSlots($eActionTypeDonate, $eSlotTypeTroop, $donateTroopIndex)

	  Local $indexOfTroopToDonate
	  If ParseRequestTextTroops($requestText, $donateTroopIndex, $indexOfTroopToDonate) Then
		 DebugWrite("Troop Donate index: " & $indexOfTroopToDonate)
		 If $indexOfTroopToDonate<> -1 Then
			DebugWrite("Troop Donate Box: " & $donateTroopIndex[$indexOfTroopToDonate][0] _
			   & " " & $donateTroopIndex[$indexOfTroopToDonate][1] _
			   & " " & $donateTroopIndex[$indexOfTroopToDonate][2] _
			   & " " & $donateTroopIndex[$indexOfTroopToDonate][3] )
		 EndIf
	  EndIf

	  Local $donateSpellIndex[$eSpellCount][4]
	  For $j = 0 To UBound($donateSpellIndex)-1
		 $donateSpellIndex[$j][0] = -1
		 $donateSpellIndex[$j][1] = -1
		 $donateSpellIndex[$j][2] = -1
		 $donateSpellIndex[$j][3] = -1
	  Next
	  LocateSlots($eActionTypeDonate, $eSlotTypeSpell, $donateSpellIndex)

	  Local $indexOfSpellToDonate
	  If ParseRequestTextSpells($requestText, $donateSpellIndex, $indexOfSpellToDonate) Then
		 DebugWrite("Spell Donate index: " & $indexOfSpellToDonate)
	  EndIf

	  ; If donate troops window is still open, then close it
	  If IsColorPresent($hBITMAP, $rWindowChatDimmedColor) Then
		 DebugWrite("TestDonate() Clicking Safe Area button")
		 RandomWeightedClick($rSafeAreaButton)

		 If WaitForScreen($hBITMAP, 5000, $eScreenChatOpen) = False Then
			DebugWrite("DonateTroops() Error waiting for open chat screen")
		 EndIf
	  EndIf

   Next

   ; If chat window is open, then close it
   If WhereAmI($hBITMAP) = $eScreenChatOpen Then
	  DebugWrite("TestDonate() Clicking Open Chat Window button " & $rMainScreenOpenChatButton[0] & " " & $rMainScreenOpenChatButton[1] & " " & $rMainScreenOpenChatButton[2] & " " & $rMainScreenOpenChatButton[3])
	  RandomWeightedClick($rMainScreenOpenChatButton)

	  If WaitForScreen($hBITMAP, 5000, $eScreenMain) = False Then
		 DebugWrite("DonateTroops() Error waiting for main screen")
	  EndIf
   EndIf

   _WinAPI_DeleteObject($hBITMAP)
EndFunc

Func TestTownHall()
   Local $left, $top, $conf, $value
   Local $t = TimerInit()
   Local $res = FindBestBMP($eSearchTypeTownHall, $left, $top, $conf, $value)
   DebugWrite("TownHall: " & Round(TimerDiff($t)) & "ms")

   If $res Then
	  DebugWrite("Town Hall found, likely level " & $value & " @ " & $left & "," & $top & " confidence " & Round($conf*100, 2) & "%")
   Else
	  DebugWrite("Town Hall not found")
   EndIf
EndFunc

Func TestCollectors()
   Local $matchX[1], $matchY[1], $conf[1], $matchCount
   Local $res = FindAllBMPs($eSearchTypeLootCollector, 17, $matchX, $matchY, $conf, $matchCount)

   For $i = 0 To $matchCount-1
	  DebugWrite("Match " & $i & ": " & $matchX[$i] & "," & $matchY[$i] & " confidence " & Round($conf[$i]*100, 2) & "%")
   Next
EndFunc

Func TestCollectMyLoot()
   Local $mX[1], $mY[1], $conf[1], $matchCount
   Local $res = FindAllBMPs($eSearchTypeLootBubble, 17, $mX, $mY, $conf, $matchCount)
   For $i = 0 To $matchCount-1
	  DebugWrite("Found collectors " & $i & " " & $mX[$i] & "," & $mY[$i] & " confidence " & Round($conf[$i]*100, 2) & "%")
   Next

   ; Check for loot cart
   Local $x, $y, $conf, $value
   If FindBestBMP($eSearchTypeLootCart, $x, $y, $conf, $value) Then
	  DebugWrite("Found loot cart: " & $x & "," & $y & " confidence " & Round($conf*100, 2) & "%")
   EndIf
EndFunc

Func TestReloadDefenses()
   ; Find town hall
   RandomWeightedClick($rSafeAreaButton)
   Sleep(500)
   Local $conf, $x, $y, $value
   If FindBestBMP($eSearchTypeTownHall, $x, $y, $conf, $value) = False Then
	  DebugWrite("ReloadDefenses() Could not find Town Hall, exiting")
	  Return
   EndIf

   ; Click on town hall
   Local $button[4] = [ $x + 6, $y + 15, $x + 16, $y + 25 ]
   DebugWrite("ReloadDefenses() Clicking Town Hall " & $button[0] & ", " & $button[1] & ", " & $button[2] & ", " & $button[3])
   RandomWeightedClick($button)
   Sleep(500)

   ; Wait for reload bar
   Local $buttonIndex[5][4]

   If WaitForReloadBar($buttonIndex) = False Then
	  DebugWrite("ReloadDefenses() Could not find Reload button bar, exiting")
	  Return
   EndIf

   For $i = 0 To 3
	  If $buttonIndex[$i][0] <> -1 Then DebugWrite("ReloadDefenses() Found " & $gReloadButtonNames[$i] & " button")
   Next

   ; Deselect Town Hall
   RandomWeightedClick($rSafeAreaButton)
   Sleep(500)

EndFunc
