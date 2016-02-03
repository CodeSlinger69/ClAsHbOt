Func TestMyStuff()
   Local $frame = CaptureFrame("TestMyStuff")

   DebugWrite("My Gold: " & ScrapeFuzzyText2($fontMyStuff, $rMyGoldTextBox))
   DebugWrite("My Elix: " & ScrapeFuzzyText2($fontMyStuff, $rMyElixTextBox))
   If IsTextBoxPresent($frame, $rMyGemsTextBoxWithDE) = True Then
	  DebugWrite("My Dark: " & ScrapeFuzzyText2($fontMyStuff, $rMyDarkTextBox))
   EndIf
   If IsTextBoxPresent($frame, $rMyGemsTextBoxNoDE) = True Then
	  DebugWrite("My Gems: " & ScrapeFuzzyText2($fontMyStuff, $rMyGemsTextBoxNoDE))
   Else
	  DebugWrite("My Gems: " & ScrapeFuzzyText2($fontMyStuff, $rMyGemsTextBoxWithDE))
   EndIf
   DebugWrite("My Cups: " & ScrapeFuzzyText2($fontMyStuff, $rMyCupsTextBox))

   _GDIPlus_BitmapDispose($frame)
EndFunc

Func TestRaidLoot()
   Local $frame = CaptureFrame("TestRaidLoot")
   Local $thLevel, $thLeft, $thTop, $gold, $elix, $dark, $cups, $deadBase
   AutoRaidGetDisplayedLoot($frame, $thLevel, $thLeft, $thTop, $gold, $elix, $dark, $cups, $deadbase)
   DebugWrite("TestRaidLoot() " & $gold & " / " & $elix & " / " & $dark &  " / " & $cups & " / " & $thLevel & " / " & $deadBase)
   _GDIPlus_BitmapDispose($frame)
EndFunc

Func TestEndBattleLoot()
   Local $frame = CaptureFrame("TestEndBattleLoot")
   Local $goldWin = Number(ScrapeFuzzyText2($fontBattleEndWinnings, $rEndBattleGoldTextBox))
   Local $elixWin = Number(ScrapeFuzzyText2($fontBattleEndWinnings, $rEndBattleElixTextBox))
   Local $darkWin = IsTextBoxPresent($frame, $rEndBattleDarkTextBox) ? Number(ScrapeFuzzyText2($fontBattleEndWinnings, $rEndBattleDarkTextBox)) : 0
   Local $cupsWin = IsTextBoxPresent($frame, $rEndBattleCupsWithDETextBox) ? _
					Number(ScrapeFuzzyText2($fontBattleEndWinnings, $rEndBattleCupsWithDETextBox)) : _
					Number(ScrapeFuzzyText2($fontBattleEndWinnings, $rEndBattleCupsNoDETextBox))
   DebugWrite("Gold: " & $goldWin)
   DebugWrite("Elix: " & $elixWin)
   DebugWrite("Dark: " & $darkWin)
   DebugWrite("Cups: " & $cupsWin)
   _GDIPlus_BitmapDispose($frame)
EndFunc

Func TestEndBattleBonus()
   Local $frame = CaptureFrame("TestEndBattleLoot")
   Local $goldBonus = 0
   Local $elixBonus = 0
   Local $darkBonus = 0
   If IsTextBoxPresent($frame, $rEndBattleBonusGoldTextBox) Or _
	  IsTextBoxPresent($frame, $rEndBattleBonusElixTextBox) Or _
	  IsTextBoxPresent($frame, $rEndBattleBonusDarkTextBox) Then

	  $goldBonus = ScrapeFuzzyText2($fontBattleEndBonus, $rEndBattleBonusGoldTextBox)
	  $goldBonus = StringLeft($goldBonus, 1) = "+" ? Number(StringMid($goldBonus, 2)) : 0
	  $elixBonus = ScrapeFuzzyText2($fontBattleEndBonus, $rEndBattleBonusElixTextBox)
	  $elixBonus = StringLeft($elixBonus, 1) = "+" ? Number(StringMid($elixBonus, 2)) : 0
	  $darkBonus = ScrapeFuzzyText2($fontBattleEndBonus, $rEndBattleBonusDarkTextBox)
	  $darkBonus = StringLeft($darkBonus, 1) = "+" ? Number(StringMid($darkBonus, 2)) : 0
	  DebugWrite("Bonus this match: " & $goldBonus & " / " & $elixBonus & " / " & $darkBonus)
   EndIf
   _GDIPlus_BitmapDispose($frame)
EndFunc

Func TestStorage()
   Local $x, $y, $conf, $matchIndex
   Local $usageAdj = 10

   Local $t = TimerInit()
   Local $s = FindBestBMP($eSearchTypeGoldStorage, $x, $y, $conf)
   DebugWrite("Gold: " & Round(TimerDiff($t)) & "ms")
   DebugWrite("Gold Match: " & $s)
   If $s <> "" Then
	  Local $level = Number(StringMid($s, StringInStr($s, "GoldStorageL")+12, 2))
	  Local $usage = Number(StringMid($s, StringInStr($s, "GoldStorageL")+15, 2))
	  $usage = ($usage+$usageAdj>100 ? 100 : $usage+$usageAdj)
	  DebugWrite("Level " & $level & ", average " & $usage & "% full, confidence " & Round($conf*100, 2) & "%")
   EndIf

   Local $t = TimerInit()
   Local $s = FindBestBMP($eSearchTypeElixStorage, $x, $y, $conf)
   DebugWrite("Elix: " & Round(TimerDiff($t)) & "ms")
   DebugWrite("Elix Match: " & $s)
   If $s <> "" Then
	  Local $level = Number(StringMid($s, StringInStr($s, "ElixStorageL")+12, 2))
	  Local $usage = Number(StringMid($s, StringInStr($s, "ElixStorageL")+15, 2))
	  $usage = ($usage+$usageAdj>100 ? 100 : $usage+$usageAdj)
	  DebugWrite("Level " & $level & ", average " & $usage & "% full, confidence " & Round($conf*100, 2) & "%")
   EndIf

   Local $t = TimerInit()
   Local $s = FindBestBMP($eSearchTypeDarkStorage, $x, $y, $conf)
   DebugWrite("Dark: " & Round(TimerDiff($t)) & "ms")
   DebugWrite("Dark Match: " & $s)
   If $s <> "" Then
	  Local $level = Number(StringMid($s, StringInStr($s, "DarkStorageL")+12, 1))
	  Local $usage = Number(StringMid($s, StringInStr($s, "DarkStorageL")+14, 2))
	  $usage = ($usage+$usageAdj>100 ? 100 : $usage+$usageAdj)
	  DebugWrite("Level " & $level & ", average " & $usage & "% full, confidence " & Round($conf*100, 2) & "%")
   EndIf
EndFunc

Func TestFindAllStorages()
   Local $x[1], $y[1], $c[1]

   Local $t = TimerInit()
   Local $count = FindAllBMPs($eSearchTypeGoldStorage, 4, $x, $y, $c)
   DebugWrite("Gold: " & Round(TimerDiff($t)) & "ms")

   DebugWrite("Gold Match Count: " & $count)
   For $i = 0 To $count-1
	  DebugWrite("Gold Match " & $i & ": " & $x[$i] & "," & $y[$i] & ", confidence " & Round($c[$i]*100, 2) & "%")
   Next

   Local $t = TimerInit()
   Local $count = FindAllBMPs($eSearchTypeElixStorage, 4, $x, $y, $c)
   DebugWrite("Elix: " & Round(TimerDiff($t)) & "ms")

   DebugWrite("Elix Match Count: " & $count)
   For $i = 0 To $count-1
	  DebugWrite("Elix Match " & $i & ": " & $x[$i] & "," & $y[$i] & ", confidence " & Round($c[$i]*100, 2) & "%")
   Next

   Local $t = TimerInit()
   Local $count = FindAllBMPs($eSearchTypeDarkStorage, 1, $x, $y, $c)
   DebugWrite("Dark: " & Round(TimerDiff($t)) & "ms")

   DebugWrite("Dark Match Count: " & $count)
   For $i = 0 To $count-1
	  DebugWrite("Dark Match " & $i & ": " & $x[$i] & "," & $y[$i] & ", confidence " & Round($c[$i]*100, 2) & "%")
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
   Local $queueStatus = ScrapeFuzzyText2($fontBarracksStatus, $rBarracksWindowTextBox)
   DebugWrite("Barracks queue status: " & $queueStatus)
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
   For $i = 0 To $eTroopCount-1
	  $builtTroopCounts[$i][0] = -1
	  $builtTroopCounts[$i][1] = -1
	  $builtTroopCounts[$i][2] = -1
	  $builtTroopCounts[$i][3] = -1
	  $builtTroopCounts[$i][4] = 0
   Next

   LocateSlots($eActionTypeCamp, $eSlotTypeTroop, $builtTroopCounts)
   LocateSlots($eActionTypeCamp, $eSlotTypeHero, $builtTroopCounts)
   UpdateArmyCampSlotCounts($builtTroopCounts)

   For $i = $eTroopBarbarian To $eTroopWarden
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
   Local $frame = CaptureFrame("TestDonate")
   If IsButtonPresent($frame, $rMainScreenOpenChatButton)=False Then OpenChatWindow($frame)

   Local $donateButtons[1][4]
   FindDonateButtons($donateButtons)

   For $i = 0 To UBound($donateButtons)-1
	  Local $requestText = GetRequestText($frame, $donateButtons, $i)

	  OpenDonateTroopsWindow($frame, $donateButtons, $i)

	  Local $donateTroopIndex[$gTroopCountExcludingHeroes][4]
	  For $j = 0 To $gTroopCountExcludingHeroes-1
		 $donateTroopIndex[$j][0] = -1
		 $donateTroopIndex[$j][1] = -1
		 $donateTroopIndex[$j][2] = -1
		 $donateTroopIndex[$j][3] = -1
	  Next
	  LocateSlots($eActionTypeDonate, $eSlotTypeTroop, $donateTroopIndex)

	  Local $donateSpellIndex[$eSpellCount][4]
	  For $j = 0 To $eSpellCount-1
		 $donateSpellIndex[$j][0] = -1
		 $donateSpellIndex[$j][1] = -1
		 $donateSpellIndex[$j][2] = -1
		 $donateSpellIndex[$j][3] = -1
	  Next
	  LocateSlots($eActionTypeDonate, $eSlotTypeSpell, $donateSpellIndex)

	  Local $indexOfTroopToDonate
	  ParseRequestTextTroops($requestText, $donateTroopIndex, $indexOfTroopToDonate)
	  DebugWrite("Troop Donate index: " & $indexOfTroopToDonate)
	  If $indexOfTroopToDonate<> -1 Then
		 DebugWrite("Troop Donate Box: " & $donateTroopIndex[$indexOfTroopToDonate][0] _
			& " " & $donateTroopIndex[$indexOfTroopToDonate][1] _
			& " " & $donateTroopIndex[$indexOfTroopToDonate][2] _
			& " " & $donateTroopIndex[$indexOfTroopToDonate][3] )
	  EndIf

	  Local $indexOfSpellToDonate
	  ParseRequestTextSpells($requestText, $donateSpellIndex, $indexOfSpellToDonate)
	  DebugWrite("Spell Donate index: " & $indexOfSpellToDonate)

	  ; If donate troops window is still open, then close it
	  If IsColorPresent($frame, $rWindowChatDimmedColor) Then
		 DebugWrite("TestDonate() Clicking Safe Area button")
		 RandomWeightedClick($rSafeAreaButton)

		 If WaitForScreen($frame, 5000, $eScreenChatOpen) = False Then
			DebugWrite("DonateTroops() Error waiting for open chat screen")
		 EndIf
	  EndIf

   Next

   ; If chat window is open, then close it
   If WhereAmI($frame) = $eScreenChatOpen Then
	  DebugWrite("TestDonate() Clicking Open Chat Window button " & $rMainScreenOpenChatButton[0] & $rMainScreenOpenChatButton[1] & $rMainScreenOpenChatButton[2] & $rMainScreenOpenChatButton[3])
	  RandomWeightedClick($rMainScreenOpenChatButton)

	  If WaitForScreen($frame, 5000, $eScreenMain) = False Then
		 DebugWrite("DonateTroops() Error waiting for main screen")
	  EndIf
   EndIf

   _GDIPlus_BitmapDispose($frame)
EndFunc

Func TestTownHall()
   Local $left, $top, $conf
   Local $t = TimerInit()
   Local $th = FindBestBMP($eSearchTypeTownHall, $left, $top, $conf)
   DebugWrite("TownHall: " & Round(TimerDiff($t)) & "ms")

   DebugWrite("Likely TH Level " & $th & " @ " & $left & "," & $top & " confidence " & Round($conf*100, 2) & "%")
EndFunc

Func TestCollectors()
   Local $matchX[1], $matchY[1], $c[1]
   Local $matchCount = FindAllBMPs($eSearchTypeLootCollector, 17, $matchX, $matchY, $c)

   For $i = 0 To $matchCount-1
	  DebugWrite("Match " & $i & ": " & $matchX[$i] & "," & $matchY[$i] & " confidence " & Round($c[$i]*100, 2) & "%")
   Next
EndFunc

Func TestCollectMyLoot()
   Local $frame = CaptureFrame("TestCollectMyLoot")

   Local $mX[1], $mY[1], $c[1]
   Local $matchCount = FindAllBMPs($eSearchTypeLootBubble, 17, $mX, $mY, $c)
   For $i = 0 To $matchCount-1
	  DebugWrite("Found collectors " & $i & " " & $mX[$i] & "," & $mY[$i] & " confidence " & Round($c[$i]*100, 2) & "%")
   Next

   ; Do the collecting
   If $matchCount > 0 Then
	  ; Sort the matches
	  Local $sortedX[$matchCount], $sortedY[$matchCount]
	  SortArrayByClosestNeighbor($matchCount, $mX, $mY, $sortedX, $sortedY)

	  DebugWrite("CollectLoot() Found " & $matchCount & " collectors")

	  Sleep(1000)
   EndIf

   _GDIPlus_BitmapDispose($frame)

   ; Check for loot cart
   Local $x, $y, $conf
   FindBestBMP($eSearchTypeLootCart, $x, $y, $conf)

   If $x <> -1 Then
	  DebugWrite("Found loot cart: " & $x & "," & $y & " confidence " & Round($conf*100, 2) & "%")
   EndIf
EndFunc

