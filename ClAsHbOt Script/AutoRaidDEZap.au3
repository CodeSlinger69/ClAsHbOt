;
; Dark Elixir Storage Zap
;
Func AutoRaidExecuteDEZap()
   DebugWrite("AutoRaidExecuteDEZap()")

   Local $res = ZapDarkElixirStorage()

   If $res = True Then ; Zap executed
	  WaitForBattleEnd(False, False)

   Else
	  ; Not enuf lightning spells, or couldn't find DE storage
	  ; Click End Battle button
	  RandomWeightedClick($rLiveRaidScreenEndBattleButton)
	  Sleep(500)

   EndIf

   Return $res
EndFunc

Func ZapDarkElixirStorage()
   DebugWrite("ZapDarkElixirStorage()")

   Local $spellIndex[$eSpellCount][4]
   FindRaidTroopSlots($gSpellSlotBMPs, $spellIndex)

   Local $availableLightnings = GetAvailableTroops($eSpellLightning, $spellIndex)

   ; Only zap if there are the maximum number of lightning spells available
   If $availableLightnings<$gMyMaxSpells Then
	  DebugWrite("Not zapping DE, " & $availableLightnings & " of " & $gMyMaxSpells & " lightning spells available.")
	  Return False
   EndIf

   ; Find DE storage
   GrabFrameToFile("DEStorageFrame.bmp", 235, 100, 789, 450)
   Local $bestMatch = 99, $bestConfidence = 0, $bestX = 0, $bestY = 0
   ScanFrameForBestBMP("DEStorageFrame.bmp", $DarkStorageBMPs, $gConfidenceDEStorage, $bestMatch, $bestConfidence, $bestX, $bestY)
   DebugWrite("DE search: " & $bestMatch & " " & $bestConfidence & " " & $bestX & " " & $bestY)

   ; If < $gConfidenceDEStorageZap confidence, then not good enough to spend spells
   If $bestConfidence < $gConfidenceDEStorage Then
	  Local $datetimestamp = _
		 StringMid(_NowCalc(), 1,4) & _
		 StringMid(_NowCalc(), 6,2) & _
		 StringMid(_NowCalc(), 9,2) & _
		 StringMid(_NowCalc(), 12,2) & _
		 StringMid(_NowCalc(), 15,2) & _
		 StringMid(_NowCalc(), 18,2)
	  FileMove("DEStorageFrame.bmp", "ZapNoConfidence-" & $datetimestamp & ".bmp")

	  DebugWrite("Not zapping DE, could not find high enough confidence DE Storage to zap.")
	  Return False
   EndIf

   DebugWrite("Zapping DE, " & $availableLightnings & " of " & $gMyMaxSpells & " lightning spells available, confidence: " & $bestConfidence)

   ; Select lightning spell
   Local $lightningButton[8] = [$spellIndex[$eSpellLightning][0], $spellIndex[$eSpellLightning][1], $spellIndex[$eSpellLightning][2], _
							    $spellIndex[$eSpellLightning][3]]
   RandomWeightedClick($lightningButton)
   Sleep(500)

   ; Zap away
   DebugWrite("Zapping at client position: " & $bestX+235+10 & "," & $bestY+100+30)
   For $i = 1 To $availableLightnings
	  _MouseClickFast($bestX+235+10, $bestY+100+30)
	  Sleep(1000)
   Next

   Sleep(6000)

   Return True
EndFunc
