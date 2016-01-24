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
   Local $frame = CaptureFrame("TestEndBattleLoot")
   Local $x, $y, $conf, $matchIndex
   Local $usageAdj = 10

   ScanFrameForBestBMP($frame, $GoldStorageBMPs, $gConfidenceStorages, $matchIndex, $conf, $x, $y)
   DebugWrite("Gold Match Index: " & $matchIndex)
   If $matchIndex <> -1 Then
	  Local $s = $GoldStorageBMPs[$matchIndex]
	  Local $level = Number(StringMid($s, StringInStr($s, "GoldStorageL")+12, 2))
	  Local $usage = Number(StringMid($s, StringInStr($s, "GoldStorageL")+15, 2))
	  $usage = ($usage+$usageAdj>100 ? 100 : $usage+$usageAdj)
	  DebugWrite("Level " & $level & ", average " & $usage & "% full, confidence " & Round($conf*100, 2) & "%")
   EndIf

   ScanFrameForBestBMP($frame, $ElixStorageBMPs, $gConfidenceStorages, $matchIndex, $conf, $x, $y)
   DebugWrite("Elix Match Index: " & $matchIndex)
   If $matchIndex <> -1 Then
	  Local $s = $ElixStorageBMPs[$matchIndex]
	  Local $level = Number(StringMid($s, StringInStr($s, "ElixStorageL")+12, 2))
	  Local $usage = Number(StringMid($s, StringInStr($s, "ElixStorageL")+15, 2))
	  $usage = ($usage+$usageAdj>100 ? 100 : $usage+$usageAdj)
	  DebugWrite("Level " & $level & ", average " & $usage & "% full, confidence " & Round($conf*100, 2) & "%")
   EndIf

   ScanFrameForBestBMP($frame, $DarkStorageBMPs, $gConfidenceStorages, $matchIndex, $conf, $x, $y)
   DebugWrite("Dark Match Index: " & $matchIndex)
   If $matchIndex <> -1 Then
	  Local $s = $DarkStorageBMPs[$matchIndex]
	  Local $level = Number(StringMid($s, StringInStr($s, "DarkStorageL")+12, 1))
	  Local $usage = Number(StringMid($s, StringInStr($s, "DarkStorageL")+14, 2))
	  $usage = ($usage+$usageAdj>100 ? 100 : $usage+$usageAdj)
	  DebugWrite("Level " & $level & ", average " & $usage & "% full, confidence " & Round($conf*100, 2) & "%")
   EndIf
EndFunc

Func TestRaidTroopsCount()
   Local $frame = CaptureFrame("TestRaidTroopsCount")

   Local $troopIndex[$eTroopCount][5]
   FindRaidTroopSlots($gTroopSlotBMPs, $troopIndex)
   UpdateRaidTroopCounts($frame, $troopIndex)

   For $i=0 To $eTroopCount-1
	  If $troopIndex[$i][4]>0 Then DebugWrite("Available " & $gTroopNames[$i] & ": " & $troopIndex[$i][4])
   Next

   Local $spellIndex[$eSpellCount][5]
   FindRaidTroopSlots($gSpellSlotBMPs, $spellIndex)
   UpdateRaidTroopCounts($frame, $spellIndex)

   For $i=0 To $eSpellCount-1
	  If $spellIndex[$i][4]>0 Then DebugWrite("Available " & $gSpellNames[$i] & ": " & $spellIndex[$i][4])
   Next

   _GDIPlus_BitmapDispose($frame)
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

   Local $donateButton[8]
   FindDonateButton($frame, $donateButton)

   Local $requestText = GetRequestText($frame, $donateButton)

   OpenDonateTroopsWindow($frame, $donateButton)

   Local $donateIndex[$gTroopCountExcludingHeroes][4]
   FindDonateTroopSlots($frame, $donateIndex)

   Local $indexOfTroopToDonate
   ParseRequestTextTroops($requestText, $donateIndex, $indexOfTroopToDonate)

   DebugWrite("Donate index: " & $indexOfTroopToDonate)

   _GDIPlus_BitmapDispose($frame)
EndFunc

Func TestTownHall()
   Local $frame = CaptureFrame("TestTownHall")
   SaveDebugImage($frame, "TestTownHall.bmp")

   Local $bestMatch, $bestConfidence, $left, $top

   ScanFrameForBestBMP($frame, $TownHallBMPs, 0, $bestMatch, $bestConfidence, $left, $top)

   DebugWrite("Likely TH Level " & ($bestMatch=-1 ? -1 : $bestMatch+6) & " conf: " & $bestConfidence)

   _WinAPI_DeleteObject($frame)
EndFunc

Func TestCollectors()
   Local $matchX[1], $matchY[1], $matchCount

   ; Grab frame
   Local $frame = CaptureFrame("TestCollectors")

   $matchCount = LocateBuildings("All collectors", $frame, $CollectorBMPs, $gConfidenceCollector, $matchX, $matchY)

   For $i = 0 To $matchCount-1
	  DebugWrite("Match " & $i & ": " & $matchX[$i] & "," & $matchY[$i])
   Next

   _GDIPlus_BitmapDispose($frame)
EndFunc
