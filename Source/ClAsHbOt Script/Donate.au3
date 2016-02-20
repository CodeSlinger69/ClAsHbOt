Func DonateTroops(ByRef $hBMP)
   DebugWrite("DonateTroops()")

   ; Open chat window
   If OpenChatWindow($hBMP) = False Then
	  ResetToCoCMainScreen($hBMP)
	  Return False
   EndIf

   ; Search for donate button
   Local $donateButtons[1][4]
   If FindDonateButtons($donateButtons) = False Then
	  ResetToCoCMainScreen($hBMP)
	  Return False
   EndIf

   ; Work through each Donate button that was found
   For $buttonLoop = 0 To UBound($donateButtons)-1
	  DebugWrite("DonateTroops() Processing donate request number " & $buttonLoop+1)

	  ; Get the request text
	  Local $requestText = GetRequestText($hBMP, $donateButtons, $buttonLoop)

	  ; Open donate troops window
	  If OpenDonateTroopsWindow($hBMP, $donateButtons, $buttonLoop) = False Then
		 ResetToCoCMainScreen($hBMP)
		 Return False
	  EndIf

	  ; Loop until donate troops window goes away, no match for request, or loop limit reached
	  Local $loopLimit = 6
	  While IsColorPresent($hBMP, $rWindowChatDimmedColor) And $loopLimit>0
		 DebugWrite("DonateTroops() Donate loop " & 6-$loopLimit & " of " & 5)

		 ; Locate troops that are available to donate
		 Local $donateTroopIndex[$gTroopCountExcludingHeroes][4]
		 For $j = 0 To $gTroopCountExcludingHeroes-1
			$donateTroopIndex[$j][0] = -1
			$donateTroopIndex[$j][1] = -1
			$donateTroopIndex[$j][2] = -1
			$donateTroopIndex[$j][3] = -1
		 Next
		 LocateSlots($eActionTypeDonate, $eSlotTypeTroop, $donateTroopIndex)

		 For $i=0 To $gTroopCountExcludingHeroes-1
			If $donateTroopIndex[$i][0]>0 Then DebugWrite("DonateTroops() " & $gTroopNames[$i] & " available to donate")
		 Next

		 ; Locate spells that are available to donate
		 Local $donateSpellIndex[$eSpellCount][4]
		 For $j = 0 To $eSpellCount-1
			$donateSpellIndex[$j][0] = -1
			$donateSpellIndex[$j][1] = -1
			$donateSpellIndex[$j][2] = -1
			$donateSpellIndex[$j][3] = -1
		 Next
		 LocateSlots($eActionTypeDonate, $eSlotTypeSpell, $donateSpellIndex)

		 For $i=0 To $eSpellCount-1
		    If $donateSpellIndex[$i][0]>0 Then DebugWrite("DonateTroops() " & $gSpellNames[$i] & " available to donate.")
		 Next

		 ; Parse request text for troops, matching with available troops
		 Local $indexOfTroopToDonate
		 If ParseRequestTextTroops($requestText, $donateTroopIndex, $indexOfTroopToDonate) Then
			If $donateTroopIndex[$indexOfTroopToDonate][0] <> -1 Then
			   ; Click the correct donate troops button
			   ClickDonateTroops($hBMP, $donateTroopIndex, $indexOfTroopToDonate)
			Else
			   $loopLimit=0
			EndIf
		 Else
			$loopLimit=0
		 EndIf

		 ; Parse request text for spells, matching with available spells
		 Local $indexOfSpellToDonate
		 If ParseRequestTextSpells($requestText, $donateSpellIndex, $indexOfSpellToDonate) Then
			If $donateSpellIndex[$indexOfSpellToDonate][0] <> -1 Then
			   ; Click the correct donate spell button
			   ClickDonateSpell($hBMP, $donateSpellIndex, $indexOfSpellToDonate)
			EndIf
		 EndIf

		 $loopLimit-=1
	  WEnd

	  ; If donate troops window is still open, then close it
	  If IsColorPresent($hBMP, $rWindowChatDimmedColor) Then
		 RandomWeightedClick($rSafeAreaButton)

		 If WaitForScreen($hBMP, 5000, $eScreenChatOpen) = False Then
			DebugWrite("DonateTroops() Error waiting for open chat screen")
		 EndIf
	  Else
		 ; Grab new frame
		 _WinAPI_DeleteObject($hBMP)
		 $hBMP = CaptureFrameHBITMAP("DonateTroops")
	  EndIf

   Next

   ; Grab new frame
   _WinAPI_DeleteObject($hBMP)
   $hBMP = CaptureFrameHBITMAP("DonateTroops")

   ; If chat window is open, then close it
   If WhereAmI($hBMP) = $eScreenChatOpen Then
	  RandomWeightedClick($rMainScreenOpenChatButton)

	  If WaitForScreen($hBMP, 5000, $eScreenMain) = False Then
		 DebugWrite("DonateTroops() Error waiting for main screen")
	  EndIf
   EndIf

   ; Done!
   ResetToCoCMainScreen($hBMP)
EndFunc

Func OpenChatWindow(ByRef $hBMP)
   If IsButtonPresent($hBMP, $rMainScreenClosedChatButton)=False And IsButtonPresent($hBMP, $rMainScreenOpenChatButton)=False Then
	  Return False
   EndIf

   DebugWrite("OpenChatWindow() Clicking open chat window button")
   RandomWeightedClick($rMainScreenClosedChatButton)

   ; Wait for OpenChatButton button
   If WaitForButton($hBMP, 10000, $rMainScreenOpenChatButton) = False Then
	  DebugWrite("OpenChatWindow() Failed - timeout waiting for open chat window")
	  Return False
   EndIf

   _WinAPI_DeleteObject($hBMP)
   $hBMP = CaptureFrameHBITMAP("OpenChatWindow")
   Return True
EndFunc

Func FindDonateButtons(ByRef $buttons)
   Local $mX[1], $mY[1], $conf[1], $matchCount
   Local $res = FindAllBMPs($eSearchDonateButton, 4, $mX, $mY, $conf, $matchCount)

   If $matchCount <= 0 Or $res = False Then
	  DebugWrite("FindDonateButton() Donate button not found.")
	  Return False

   Else
	  ReDim $buttons[$matchCount][4]

	  For $i=0 To $matchCount-1
		 $buttons[$i][0] = $mX[$i] + $rChatWindowDonateButton[0]
		 $buttons[$i][1] = $mY[$i] + $rChatWindowDonateButton[1]
		 $buttons[$i][2] = $mX[$i] + $rChatWindowDonateButton[2]
		 $buttons[$i][3] = $mY[$i] + $rChatWindowDonateButton[3]

		 DebugWrite("FindDonateButtons() Donate button " & $i & " found at: " & $buttons[$i][0] & ", " & $buttons[$i][1] & ", " & _
			$buttons[$i][2] & ", " & $buttons[$i][3] & " confidence " & Round($conf[$i]*100, 2) & "%")
	  Next

	  Return True
   EndIf
EndFunc

Func GetRequestText(Const $hBMP, Const ByRef $buttons, Const $index)
   ; Grab text of donate request
   Local $box[10] = [$buttons[$index][0]+$rChatTextBoxAsOffset[0], _
				     $buttons[$index][1]+$rChatTextBoxAsOffset[1], _
				     $buttons[$index][0]+$rChatTextBoxAsOffset[2], _
				     $buttons[$index][1]+$rChatTextBoxAsOffset[3], _
				     $rChatTextBoxAsOffset[4], $rChatTextBoxAsOffset[5], $rChatTextBoxAsOffset[6], _
				     $rChatTextBoxAsOffset[7], $rChatTextBoxAsOffset[8], $rChatTextBoxAsOffset[9]]

   Local $t = ScrapeExactText($hBMP, $fontChat, $box)
   DebugWrite("GetRequestText() Text: '" & $t & "'" & " box: " & $box[0] & " " & $box[1] & " " & $box[2] & " " & $box[3])

   Return $t
EndFunc

Func OpenDonateTroopsWindow(ByRef $hBMP, Const ByRef $buttons, Const $index)
   DebugWrite("OpenDonateTroopsWindow() Clicking Donate button")

   Local $button[4]
   For $i = 0 To 3
	  $button[$i] = $buttons[$index][$i]
   Next
   RandomWeightedClick($button)

   If WaitForColor($hBMP, 5000, $rWindowChatDimmedColor) = False Then
	  DebugWrite("OpenDonateTroopsWindow() Failed - timeout waiting for donate troops window")
	  Return False
   EndIf

   DebugWrite("OpenDonateTroopsWindow() Donate troops window opened")
   _WinAPI_DeleteObject($hBMP)
   $hBMP = CaptureFrameHBITMAP("OpenDonateTroopsWindow")
   Return True
EndFunc

Func ParseRequestTextTroops(Const ByRef $text, Const ByRef $avail, ByRef $index)
   $index = -1

   ; Is a negative string present, exit now
   For $i = 1 To $gDonateMatchNegativeStrings[0]
	  If StringInStr($text, $gDonateMatchNegativeStrings[$i]) Then
		 DebugWrite("ParseRequestTextTroops() Negative string match, cannot parse negative requests")
		 Return False
	  EndIf
   Next

   ; Check the specific troop search strings first
   For $i = $eTroopLavaHound To $eTroopBarbarian Step -1 ; Reverse search to fill more costly troops first
	  Local $searchTerms = StringSplit($gDonateMatchTroopStrings[$i], "|")

	  For $j = 1 To $searchTerms[0]
		 If StringInStr($text, $searchTerms[$j]) Then
			If $avail[$i][0]<>-1 Then
			   DebugWrite("ParseRequestTextTroops() String match for: " & $gTroopNames[$i] & ", troop available")
			   $index = $i
			   ExitLoop 2
			Else
			   DebugWrite("ParseRequestTextTroops() String match for: " & $gTroopNames[$i] & ", troop NOT available")
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
	  DebugWrite("ParseRequestTextTroops() Could not find a fill for request")
	  Return False
   Else
	  DebugWrite("ParseRequestTextTroops() Filling request with " & $gTroopNames[$index])
	  Return True
   EndIf
EndFunc

Func ParseRequestTextSpells(Const ByRef $text, Const ByRef $avail, ByRef $index)
   $index = -1

   ; Is a negative string present, exit now
   For $i = 1 To $gDonateMatchNegativeStrings[0]
	  If StringInStr($text, $gDonateMatchNegativeStrings[$i]) Then
		 DebugWrite("ParseRequestTextSpells() Negative string match, cannot parse negative requests")
		 Return False
	  EndIf
   Next

   ; Check the specific spell search strings
   For $i = $eSpellPoison To $eSpellHaste
	  Local $searchTerms = StringSplit($gDonateMatchSpellStrings[$i], "|")

	  For $j = 1 To $searchTerms[0]
		 If StringInStr($text, $searchTerms[$j]) Then
			If $avail[$i][0]<>-1 Then
			   DebugWrite("ParseRequestTextSpells() String match for: " & $gSpellNames[$i] & ", spell available")
			   $index = $i
			   ExitLoop 2
			Else
			   DebugWrite("ParseRequestTextSpells() String match for: " & $gSpellNames[$i] & ", spell NOT available")
			   Return False
			EndIf
		 EndIf
	  Next
   Next

   ; If there is no specific request match, then return default as specified in .ini file
   If $index < 0 Then
	  For $i = $eSpellPoison To $eSpellHaste
		 If StringInStr($gSpellNames[$i], $gSpellDefaultDonate) And $avail[$i][0]<>-1 Then
			DebugWrite("ParseRequestTextSpells() Default spell match for " & $gSpellNames[$i] & ", available")
			$index = $i
			ExitLoop
		 EndIf
	  Next
   EndIf

   If $index < 0 Then
	  DebugWrite("ParseRequestTextSpells() Could not find a fill for request")
	  Return False
   Else
	  DebugWrite("ParseRequestTextSpells() Filling with " & $gSpellNames[$index])
	  Return True
   EndIf
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

Func ClickDonateTroops(ByRef $hBMP, Const ByRef $donateIndex, Const $indexOfTroopToDonate)

   Local $DonateMaxClicks[16] = [6, 6, 6, 6,   6, 6, 6, 2,   1, 1, 6, 6,   4, 1, 2, 1]

   Local $button[4] = [$donateIndex[$indexOfTroopToDonate][0], _
					   $donateIndex[$indexOfTroopToDonate][1], _
					   $donateIndex[$indexOfTroopToDonate][2], _
					   $donateIndex[$indexOfTroopToDonate][3]]

   Local $donateCount=0

   For $i = 1 To $DonateMaxClicks[$indexOfTroopToDonate]
	  If IsColorPresent($hBMP, $rWindowChatDimmedColor) Then
		 RandomWeightedClick($button)
		 $donateCount+=1
		 Sleep($gDonateTroopClickDelay)

		 _WinAPI_DeleteObject($hBMP)
		 $hBMP = CaptureFrameHBITMAP("ClickDonateTroops")
	  EndIf
   Next

   If $donateCount>0 Then
	  DebugWrite("ClickDonateTroops() Donated " & $donateCount & " " & $gTroopNames[$indexOfTroopToDonate])
   EndIf

   Sleep(1000)
EndFunc

Func ClickDonateSpell(ByRef $hBMP, Const ByRef $donateIndex, Const $indexOfSpellToDonate)
   Local $button[4] = [$donateIndex[$indexOfSpellToDonate][0], _
					   $donateIndex[$indexOfSpellToDonate][1], _
					   $donateIndex[$indexOfSpellToDonate][2], _
					   $donateIndex[$indexOfSpellToDonate][3]]

   If IsColorPresent($hBMP, $rWindowChatDimmedColor) Then
	  RandomWeightedClick($button)
	  Sleep($gDonateTroopClickDelay)

	  _WinAPI_DeleteObject($hBMP)
	  $hBMP = CaptureFrameHBITMAP("ClickDonateSpell")

	  DebugWrite("ClickDonateSpell() Donated 1 " & $gSpellNames[$indexOfSpellToDonate])
   EndIf

   Sleep(1000)
EndFunc
