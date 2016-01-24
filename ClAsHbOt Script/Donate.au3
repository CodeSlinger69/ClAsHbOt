Func DonateTroops(ByRef $f)
   DebugWrite("DonateTroops()")

   ; Open chat window
   If OpenChatWindow($f) = False Then
	  ResetToCoCMainScreen($f)
	  Return False
   EndIf

   If $gDebugSaveScreenCaptures Then  _GDIPlus_ImageSaveToFile($f, "ChatFrame.bmp")

   ; Search for donate button
   Local $donateButton[8]
   If FindDonateButton($f, $donateButton) = False Then
	  ResetToCoCMainScreen($f)
	  Return False
   EndIf

   ; Get the request text
   Local $requestText = GetRequestText($f, $donateButton)

   ; Open donate troops window
   If OpenDonateTroopsWindow($f, $donateButton) = False Then
	  ResetToCoCMainScreen($f)
	  Return False
   EndIf

   ; Loop until donate troops window goes away, no match for request, or loop limit reached
   Local $loopLimit = 6
   While IsColorPresent($f, $rWindowChatDimmedColor) And $loopLimit>0
	  DebugWrite("DonateTroops() Donate loop " & 6-$loopLimit & " of " & 5)

	  ; Locate troops that are available to donate
	  Local $donateTroopIndex[$gTroopCountExcludingHeroes][4]
	  FindDonateTroopSlots($f, $donateTroopIndex)

	  For $i=0 To $gTroopCountExcludingHeroes-1
		 If $donateTroopIndex[$i][0]>0 Then DebugWrite("DonateTroops() " & $gTroopNames[$i] & " available to donate.")
	  Next

	  ; Locate spells that are available to donate
	  ;Local $donateSpellIndex[$eSpellCount][4]
	  ;FindDonateSpellSlots($f, $donateSpellIndex)

	  ;For $i=0 To $eSpellCount-1
		; If $donateSpellIndex[$i][0]>0 Then DebugWrite("DonateTroops() " & $gSpellNames[$i] & " available to donate.")
	  ;Next

	  ; Parse request text for troops, matching with available troops
	  Local $indexOfTroopToDonate
	  If ParseRequestTextTroops($requestText, $donateTroopIndex, $indexOfTroopToDonate) Then
		 If $donateTroopIndex[$indexOfTroopToDonate][0] <> -1 Then
			; Click the correct donate troops button
			ClickDonateTroops($f, $donateTroopIndex, $indexOfTroopToDonate)
		 Else
			$loopLimit=0
		 EndIf
	  Else
		 $loopLimit=0
	  EndIf

	  ; Parse request text for spells, matching with available spells
	  ;Local $indexOfSpellToDonate
	  ;If ParseRequestTextSpells($requestText, $donateSpellIndex, $indexOfSpellToDonate) Then
	;	 If $donateSpellIndex[$indexOfSpellToDonate][0] <> -1 Then
			; Click the correct donate spell button
	;		ClickDonateSpell($f, $donateSpellIndex, $indexOfSpellToDonate)
	;	 EndIf
	 ; EndIf

	  $loopLimit-=1
   WEnd

   ; Done!
   ResetToCoCMainScreen($f)
EndFunc

Func OpenChatWindow(ByRef $f)
   If IsButtonPresent($f, $rMainScreenClosedChatButton)=False And IsButtonPresent($f, $rMainScreenOpenChatButton)=False Then
	  Return False
   EndIf

   DebugWrite("OpenChatWindow() Clicking open chat window button")
   RandomWeightedClick($rMainScreenClosedChatButton)

   ; Wait for OpenChatButton button
   If WaitForButton($f, 10000, $rMainScreenOpenChatButton) = False Then
	  DebugWrite("OpenChatWindow() Failed - timeout waiting for open chat window")
	  Return False
   EndIf

   _GDIPlus_BitmapDispose($f)
   $f = CaptureFrame("OpenChatWindow")
   Return True
EndFunc

Func FindDonateButton(Const $frame, ByRef $button)
   Local $bestMatch, $bestConfidence, $bestX, $bestY
   ScanFrameForBestBMP($frame, $DonateButtonBMPs, 0.95, $bestMatch, $bestConfidence, $bestX, $bestY)

   If $bestMatch = -1 Then
	  DebugWrite("FindDonateButton() Donate button not found.")
	  Return False
   EndIf

   $button[0] = $bestX
   $button[1] = $bestY
   $button[2] = $bestX+$rChatWindowDonateButton[2]
   $button[3] = $bestY+$rChatWindowDonateButton[3]
   $button[4] = $rChatWindowDonateButton[4]
   $button[5] = $rChatWindowDonateButton[5]
   $button[6] = $rChatWindowDonateButton[6]
   $button[7] = $rChatWindowDonateButton[7]

   DebugWrite("FindDonateButton() Donate button found at: " & $button[0] & ", " & $button[1] & ", " _
	  & $button[2] & ", " & $button[3])

   Return True
EndFunc

Func GetRequestText(Const $frame, Const ByRef $button)
   ; Grab text of donate request
   Local $donateTextBox[10] = [$button[0]+$rChatTextBoxAsOffset[0], _
							   $button[1]+$rChatTextBoxAsOffset[1], _
							   $button[0]+$rChatTextBoxAsOffset[2], _
							   $button[1]+$rChatTextBoxAsOffset[3], _
							   $rChatTextBoxAsOffset[4], $rChatTextBoxAsOffset[5], $rChatTextBoxAsOffset[6], _
							   $rChatTextBoxAsOffset[7], $rChatTextBoxAsOffset[8], $rChatTextBoxAsOffset[9]]

   Local $text = ScrapeExactText($frame, $gChatCharacterMaps, $donateTextBox, $gChatCharMapsMaxWidth, $eScrapeDropSpaces)
   DebugWrite("GetRequestText() Text: '" & $text & "'")

   Return $text
EndFunc

Func OpenDonateTroopsWindow(ByRef $f, Const ByRef $button)
   DebugWrite("OpenDonateTroopsWindow() Clicking Donate button")
   RandomWeightedClick($button)

   If WaitForColor($f, 5000, $rWindowChatDimmedColor) = False Then
	  DebugWrite("OpenDonateTroopsWindow() Failed - timeout waiting for donate troops window")
	  Return False
   EndIf

   DebugWrite("OpenDonateTroopsWindow() Donate troops window opened.")
   _GDIPlus_BitmapDispose($f)
   $f = CaptureFrame("OpenDonateTroopsWindow")
   Return True
EndFunc

Func FindDonateTroopSlots(Const $frame, ByRef $index)
   If $gDebugSaveScreenCaptures Then _GDIPlus_ImageSaveToFile($frame, "AvailableDonateTroopFrame.bmp")

   For $i = $eTroopBarbarian To $eTroopLavaHound
	  Local $res = DllCall("ImageMatch.dll", "str", "FindMatch", "str", "AvailableDonateTroopFrame.bmp", "str", "Images\"&$gDonateTroopSlotBMPs[$i], "int", 3)
	  Local $split = StringSplit($res[0], "|", 2) ; x, y, conf
	  ;DebugWrite("Troop " & $gTroopNames[$i] & " found at " & $split[0] & ", " & $split[1] & " conf: " & $split[2])

	  If $split[2] > $gConfidenceDonateTroopSlot Then
		 $index[$i][0] = $split[0]+$rDonateButtonOffset[0]
		 $index[$i][1] = $split[1]+$rDonateButtonOffset[1]
		 $index[$i][2] = $split[0]+$rDonateButtonOffset[2]
		 $index[$i][3] = $split[1]+$rDonateButtonOffset[3]
		 DebugWrite("Troop " & $gTroopNames[$i] & " found at " & $index[$i][0] & ", " & $index[$i][1] & " conf: " & Round($split[2]*100, 2) & "%")
	  Else
		 $index[$i][0] = -1
		 $index[$i][1] = -1
		 $index[$i][2] = -1
		 $index[$i][3] = -1
	  EndIf
   Next
EndFunc

Func FindDonateSpellSlots(Const $frame, ByRef $index)
   If $gDebugSaveScreenCaptures Then _GDIPlus_ImageSaveToFile($frame, "AvailableDonateSpellFrame.bmp")

   For $i = $eSpellPoison To $eSpellHaste
	  Local $res = DllCall("ImageMatch.dll", "str", "FindMatch", "str", "AvailableDonateSpellFrame.bmp", "str", "Images\"&$gDonateSpellSlotBMPs[$i], "int", 3)
	  Local $split = StringSplit($res[0], "|", 2) ; x, y, conf
	  ;DebugWrite("Spell " & $gSpellNames[$i] & " found at " & $split[0] & ", " & $split[1] & " conf: " & $split[2])

	  If $split[2] > $gConfidenceDonateTroopSlot Then
		 $index[$i][0] = $split[0]+$rDonateButtonOffset[0]
		 $index[$i][1] = $split[1]+$rDonateButtonOffset[1]
		 $index[$i][2] = $split[0]+$rDonateButtonOffset[2]
		 $index[$i][3] = $split[1]+$rDonateButtonOffset[3]
		 DebugWrite("Spell " & $gSpellNames[$i] & " found at " & $index[$i][0] & ", " & $index[$i][1] & " conf: " & Round($split[2]*100, 2) & "%")
	  Else
		 $index[$i][0] = -1
		 $index[$i][1] = -1
		 $index[$i][2] = -1
		 $index[$i][3] = -1
	  EndIf
   Next
EndFunc

Func ParseRequestTextTroops(Const ByRef $text, Const ByRef $avail, ByRef $index)
   $index = -1

   ; Is a negative string present, exit now
   For $i = 1 To $gDonateMatchNegativeStrings[0]
	  If StringInStr($text, $gDonateMatchNegativeStrings[$i]) Then
		 DebugWrite("ParseRequestTextTroops() Negative string match, cannot parse negative requests.")
		 Return False
	  EndIf
   Next

   ; Check the specific troop search strings first
   For $i = $eTroopLavaHound To $eTroopBarbarian Step -1 ; Reverse search to fill more costly troops first
	  Local $searchTerms = StringSplit($gDonateMatchTroopStrings[$i], "|")

	  For $j = 1 To $searchTerms[0]
		 If StringInStr($text, $searchTerms[$j]) Then
			If $avail[$i][0]<>-1 Then
			   DebugWrite("ParseRequestTextTroops() String match for: " & $gTroopNames[$i] & ", troop available.")
			   $index = $i
			   ExitLoop 2
			Else
			   DebugWrite("ParseRequestTextTroops() String match for: " & $gTroopNames[$i] & ", troop NOT available, exiting.")
			   Return False
			EndIf
		 EndIf
	  Next
   Next

   ; Check other match terms
   If $index = -1 Then $index = FindMatchingTroop($text, $gDonateMatchDarkStrings, $gDonateMatchDarkTroops, $avail, "Dark")
   If $index = -1 Then $index = FindMatchingTroop($text, $gDonateMatchAirStrings, $gDonateMatchAirTroops, $avail, "Air")
   If $index = -1 Then $index = FindMatchingTroop($text, $gDonateMatchGroundStrings, $gDonateMatchGroundTroops, $avail, "Ground")
   If $index = -1 Then $index = FindMatchingTroop($text, $gDonateMatchFarmStrings, $gDonateMatchFarmTroops, $avail, "Farm")
   If $index = -1 Then $index = FindMatchingTroop($text, $gDonateMatchAnyStrings, $gDonateMatchAnyTroops, $avail, "Any")

   If $index < 0 Then
	  DebugWrite("ParseRequestTextTroops() Could not find a fill for request, exiting.")
	  Return False
   EndIf

   DebugWrite("ParseRequestTextTroops() Filling request with " & $gTroopNames[$index] & ".")
   Return True
EndFunc

Func ParseRequestTextSpells(Const ByRef $text, Const ByRef $avail, ByRef $index)
   $index = -1

   ; Is a negative string present, exit now
   For $i = 1 To $gDonateMatchNegativeStrings[0]
	  If StringInStr($text, $gDonateMatchNegativeStrings[$i]) Then
		 DebugWrite("ParseRequestTextSpells() Negative string match, cannot parse negative requests.")
		 Return False
	  EndIf
   Next

   ; Check the specific spell search strings
   For $i = $eSpellPoison To $eSpellHaste
	  Local $searchTerms = StringSplit($gDonateMatchSpellStrings[$i], "|")

	  For $j = 1 To $searchTerms[0]
		 If StringInStr($text, $searchTerms[$j]) Then
			If $avail[$i][0]<>-1 Then
			   DebugWrite("ParseRequestTextSpells() String match for: " & $gSpellNames[$i] & ", spell available.")
			   $index = $i
			   ExitLoop 2
			Else
			   DebugWrite("ParseRequestTextSpells() String match for: " & $gSpellNames[$i] & ", spell NOT available, exiting.")
			   Return False
			EndIf
		 EndIf
	  Next
   Next

   If $index < 0 Then
	  DebugWrite("ParseRequestTextSpells() Could not find a fill for request, exiting.")
	  Return False
   EndIf

   DebugWrite("ParseRequestTextSpells() Filling request with " & $gSpellNames[$index] & ".")
   Return True
EndFunc

Func FindMatchingTroop(Const $text, Const ByRef $strings, Const ByRef $troops, Const ByRef $avail, Const $type)
   Local $stringMatch = False
   For $i = 1 To $strings[0]
	  If StringInStr($text, $strings[$i]) Then
		 $stringMatch = True
		 ExitLoop
	  EndIf
   Next

   If $stringMatch = False Then Return -1

   DebugWrite("FindMatchingTroop() String match for '" & $type & "'")

   For $i = 1 To $troops[0]
	  Local $troopNum = _ArraySearch($gTroopNames, $troops[$i])
	  If $troopNum <> -1 Then
		 If $avail[$troopNum][0]<>-1 Then Return $troopNum
	  EndIf
   Next

   Return -2
EndFunc

Func ClickDonateTroops(ByRef $f, Const ByRef $donateIndex, Const $indexOfTroopToDonate)

   Local $DonateMaxClicks[16] = [6, 6, 6, 6,   6, 6, 6, 2,   1, 1, 6, 6,   4, 1, 2, 1]

   Local $button[4] = [$donateIndex[$indexOfTroopToDonate][0], _
					   $donateIndex[$indexOfTroopToDonate][1], _
					   $donateIndex[$indexOfTroopToDonate][2], _
					   $donateIndex[$indexOfTroopToDonate][3]]

   Local $donateCount=0

   For $i = 1 To $DonateMaxClicks[$indexOfTroopToDonate]
	  If IsColorPresent($f, $rWindowChatDimmedColor) Then
		 RandomWeightedClick($button)
		 $donateCount+=1
		 Sleep($gDonateTroopClickDelay)

		 _GDIPlus_BitmapDispose($f)
		 $f = CaptureFrame("ClickDonateTroops")
	  EndIf
   Next

   If $donateCount>0 Then
	  DebugWrite("ClickDonateTroops() Donated " & $donateCount & " " & $gTroopNames[$indexOfTroopToDonate])
   EndIf
EndFunc

Func ClickDonateSpell(ByRef $f, Const ByRef $donateIndex, Const $indexOfSpellToDonate)
   Local $button[4] = [$donateIndex[$indexOfSpellToDonate][0], _
					   $donateIndex[$indexOfSpellToDonate][1], _
					   $donateIndex[$indexOfSpellToDonate][2], _
					   $donateIndex[$indexOfSpellToDonate][3]]

   If IsColorPresent($f, $rWindowChatDimmedColor) Then
	  RandomWeightedClick($button)
	  Sleep($gDonateTroopClickDelay)

	  _GDIPlus_BitmapDispose($f)
	  $f = CaptureFrame("ClickDonateSpell")

	  DebugWrite("ClickDonateSpell() Donated 1 " & $gSpellNames[$indexOfSpellToDonate])
   EndIf
EndFunc
