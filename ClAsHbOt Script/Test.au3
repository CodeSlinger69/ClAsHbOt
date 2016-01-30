Func TestMyStuff()
   Local $frame = CaptureFrame("TestMyStuff")
   Local $MyGold = Number(ScrapeFuzzyText($frame, $gSmallCharacterMaps, $rMyGoldTextBox, $gSmallCharMapsMaxWidth, $eScrapeDropSpaces))
   DebugWrite("My Gold: " & $MyGold)
   Local $MyElix = Number(ScrapeFuzzyText($frame, $gSmallCharacterMaps, $rMyElixTextBox, $gSmallCharMapsMaxWidth, $eScrapeDropSpaces))
   DebugWrite("My Elix: " & $MyElix)
   Local $MyDark = 0
   If IsTextBoxPresent($frame, $rMyGemsTextBoxWithDE) = True Then
      $MyDark = Number(ScrapeFuzzyText($frame, $gSmallCharacterMaps, $rMyDarkTextBox, $gSmallCharMapsMaxWidth, $eScrapeDropSpaces))
   EndIf
   DebugWrite("My Dark: " & $MyDark)
   Local $MyGems = 0
   If IsTextBoxPresent($frame, $rMyGemsTextBoxNoDE) = True Then
      $MyGems = Number(ScrapeFuzzyText($frame, $gSmallCharacterMaps, $rMyGemsTextBoxNoDE, $gSmallCharMapsMaxWidth, $eScrapeDropSpaces))
   Else
      $MyGems = Number(ScrapeFuzzyText($frame, $gSmallCharacterMaps, $rMyGemsTextBoxWithDE, $gSmallCharMapsMaxWidth, $eScrapeDropSpaces))
   EndIf
   DebugWrite("My Gems: " & $MyGems)
   Local $MyCups = Number(ScrapeFuzzyText($frame, $gSmallCharacterMaps, $rMyCupsTextBox, $gSmallCharMapsMaxWidth, $eScrapeDropSpaces))
   DebugWrite("My Cups: " & $MyCups)
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
   Local $goldWin = ScrapeFuzzyText($frame, $gBattleEndWinningsCharacterMaps, $rEndBattleGoldTextBox, $gBattleEndWinningsCharMapsMaxWidth, $eScrapeDropSpaces)
   Local $elixWin = ScrapeFuzzyText($frame, $gBattleEndWinningsCharacterMaps, $rEndBattleElixTextBox, $gBattleEndWinningsCharMapsMaxWidth, $eScrapeDropSpaces)
   Local $darkWin = IsTextBoxPresent($frame, $rEndBattleDarkTextBox) ? ScrapeFuzzyText($frame, $gBattleEndWinningsCharacterMaps, $rEndBattleDarkTextBox, $gBattleEndWinningsCharMapsMaxWidth, $eScrapeDropSpaces) : 0
   Local $cupsWin = IsTextBoxPresent($frame, $rEndBattleCupsWithDETextBox) ? _
					ScrapeFuzzyText($frame, $gBattleEndWinningsCharacterMaps, $rEndBattleCupsWithDETextBox, $gBattleEndWinningsCharMapsMaxWidth, $eScrapeDropSpaces) : _
					ScrapeFuzzyText($frame, $gBattleEndWinningsCharacterMaps, $rEndBattleCupsNoDETextBox, $gBattleEndWinningsCharMapsMaxWidth, $eScrapeDropSpaces)
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

	  $goldBonus = ScrapeFuzzyText($frame, $gBattleEndBonusCharacterMaps, $rEndBattleBonusGoldTextBox, $gBattleEndBonusCharMapsMaxWidth, $eScrapeDropSpaces)
	  $goldBonus = StringLeft($goldBonus, 1) = "+" ? StringMid($goldBonus, 2) : 0
	  $elixBonus = ScrapeFuzzyText($frame, $gBattleEndBonusCharacterMaps, $rEndBattleBonusElixTextBox, $gBattleEndBonusCharMapsMaxWidth, $eScrapeDropSpaces)
	  $elixBonus = StringLeft($elixBonus, 1) = "+" ? StringMid($elixBonus, 2) : 0
	  $darkBonus = ScrapeFuzzyText($frame, $gBattleEndBonusCharacterMaps, $rEndBattleBonusDarkTextBox, $gBattleEndBonusCharMapsMaxWidth, $eScrapeDropSpaces)
	  $darkBonus = StringLeft($darkBonus, 1) = "+" ? StringMid($darkBonus, 2) : 0
	  DebugWrite("Bonus this match: " & $goldBonus & " / " & $elixBonus & " / " & $darkBonus)
   EndIf
   _GDIPlus_BitmapDispose($frame)
EndFunc

Func TestStorage()
   Local $x, $y, $conf, $matchIndex
   Local $usageAdj = 10

   Local $t = TimerInit()
   Local $s = FindBestStorage($eLootTypeGold, $x, $y, $conf)
   DebugWrite("Gold: " & Round(TimerDiff($t)) & "ms")
   DebugWrite("Gold Match: " & $s)
   If $s <> "" Then
	  Local $level = Number(StringMid($s, StringInStr($s, "GoldStorageL")+12, 2))
	  Local $usage = Number(StringMid($s, StringInStr($s, "GoldStorageL")+15, 2))
	  $usage = ($usage+$usageAdj>100 ? 100 : $usage+$usageAdj)
	  DebugWrite("Level " & $level & ", average " & $usage & "% full, confidence " & Round($conf*100, 2) & "%")
   EndIf

   Local $t = TimerInit()
   Local $s = FindBestStorage($eLootTypeElix, $x, $y, $conf)
   DebugWrite("Elix: " & Round(TimerDiff($t)) & "ms")
   DebugWrite("Elix Match: " & $s)
   If $s <> "" Then
	  Local $level = Number(StringMid($s, StringInStr($s, "ElixStorageL")+12, 2))
	  Local $usage = Number(StringMid($s, StringInStr($s, "ElixStorageL")+15, 2))
	  $usage = ($usage+$usageAdj>100 ? 100 : $usage+$usageAdj)
	  DebugWrite("Level " & $level & ", average " & $usage & "% full, confidence " & Round($conf*100, 2) & "%")
   EndIf

   Local $t = TimerInit()
   Local $s = FindBestStorage($eLootTypeDark, $x, $y, $conf)
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
   Local $x[4], $y[4]

   Local $t = TimerInit()
   Local $count = FindAllStorages($eLootTypeGold, 4, $x, $y)
   DebugWrite("Gold: " & Round(TimerDiff($t)) & "ms")

   DebugWrite("Gold Match Count: " & $count)
   For $i = 0 To $count-1
	  DebugWrite("Gold Match " & $i & ": " & $x[$i] & "," & $y[$i])
   Next

   Local $t = TimerInit()
   Local $count = FindAllStorages($eLootTypeElix, 4, $x, $y)
   DebugWrite("Elix: " & Round(TimerDiff($t)) & "ms")

   DebugWrite("Elix Match Count: " & $count)
   For $i = 0 To $count-1
	  DebugWrite("Elix Match " & $i & ": " & $x[$i] & "," & $y[$i])
   Next

   Local $t = TimerInit()
   Local $count = FindAllStorages($eLootTypeDark, 1, $x, $y)
   DebugWrite("Dark: " & Round(TimerDiff($t)) & "ms")

   DebugWrite("Dark Match Count: " & $count)
   For $i = 0 To $count-1
	  DebugWrite("Dark Match " & $i & ": " & $x[$i] & "," & $y[$i])
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
   LocateRaidSlots($eRaidSlotTypeTroop, $troopIndex)

   RandomWeightedClick($rRaidSlotsButton2)
   Sleep(200)
   LocateRaidSlots($eRaidSlotTypeTroop, $troopIndex)

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
   LocateRaidSlots($eRaidSlotTypeSpell, $spellIndex)

   RandomWeightedClick($rRaidSlotsButton2)
   Sleep(200)
   LocateRaidSlots($eRaidSlotTypeSpell, $spellIndex)

   UpdateRaidSlotCounts($spellIndex)

   For $i=0 To $eSpellCount-1
	  If $spellIndex[$i][4]>0 Then DebugWrite("Available " & $gSpellNames[$i] & ": " & $spellIndex[$i][4])
   Next
EndFunc

Func TestBarracksStatus()
   Local $frame = CaptureFrame("TestEndBattleLoot")
   Local $queueStatus = ScrapeFuzzyText($frame, $gBarracksCharacterMaps, $rBarracksWindowTextBox, $gBarracksCharMapsMaxWidth, $eScrapeDropSpaces)
   DebugWrite("Barracks queue status: " & $queueStatus)
   _GDIPlus_BitmapDispose($frame)
EndFunc

Func TestBuiltTroops()
   Local $builtTroopCounts[$eTroopCount]
   For $i = $eTroopBarbarian To $eTroopWarden
	  $builtTroopCounts[$i] = 0
   Next

   GetBuiltTroops($gArmyCampTroopsBMPs, $builtTroopCounts)
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

	  Local $donateIndex[$gTroopCountExcludingHeroes][4]
	  FindDonateTroopSlots($frame, $donateIndex)

	  Local $donateSpellIndex[$eSpellCount][4]
	  FindDonateSpellSlots($frame, $donateSpellIndex)

	  Local $indexOfTroopToDonate
	  ParseRequestTextTroops($requestText, $donateIndex, $indexOfTroopToDonate)
	  DebugWrite("Troop Donate index: " & $indexOfTroopToDonate)

	  Local $indexOfSpellToDonate
	  ParseRequestTextSpells($requestText, $donateSpellIndex, $indexOfSpellToDonate)
	  DebugWrite("Spell Donate index: " & $indexOfSpellToDonate)

	  ; If donate troops window is still open, then close it
	  If IsColorPresent($frame, $rWindowChatDimmedColor) Then
		 RandomWeightedClick($rSafeAreaButton)

		 If WaitForScreen($frame, 5000, $eScreenChatOpen) = False Then
			DebugWrite("DonateTroops() Error waiting for open chat screen")
		 EndIf
	  EndIf

   Next

   ; If chat window is open, then close it
   If WhereAmI($frame) = $eScreenChatOpen Then
	  RandomWeightedClick($rMainScreenOpenChatButton)

	  If WaitForScreen($frame, 5000, $eScreenMain) = False Then
		 DebugWrite("DonateTroops() Error waiting for main screen")
	  EndIf
   EndIf

   _GDIPlus_BitmapDispose($frame)
EndFunc

Func TestTownHall()
   Local $th, $left, $top, $conf
   Local $t = TimerInit()
   FindTownHall($th, $left, $top, $conf)
   DebugWrite("TownHall: " & Round(TimerDiff($t)) & "ms")

   DebugWrite("Likely TH Level " & $th & " @ " & $left & "," & $top & " confidence " & Round($conf*100, 2) & "%")
EndFunc

Func TestCollectors()
   Local $matchX[1], $matchY[1], $c[1]

   ; Grab frame
   Local $frame = CaptureFrame("TestCollectors")

   Local $matchCount = ScanFrameForAllBMPs($frame, $CollectorBMPs, $gConfidenceCollector, 14, $matchX, $matchY, $c)

   For $i = 0 To $matchCount-1
	  DebugWrite("Match " & $i & ": " & $matchX[$i] & "," & $matchY[$i] & " confidence " & Round($c[$i]*100, 2) & "%")
   Next

   _GDIPlus_BitmapDispose($frame)
EndFunc

Func TestCollectMyLoot()
   Local $frame = CaptureFrame("TestCollectMyLoot")

   Local $mX[1], $mY[1], $c[1]
   Local $matchCount = ScanFrameForAllBMPs($frame, $CollectLootBMPs, $gConfidenceCollectLoot, 17, $mX, $mY, $c)
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
   FindLootCart($x, $y, $conf)

   If $x <> -1 Then
	  DebugWrite("Found loot cart: " & $x & "," & $y & " confidence " & Round($conf*100, 2) & "%")
   EndIf
EndFunc

