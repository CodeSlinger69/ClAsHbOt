Func DonateTroops()
   DebugWrite("DonateTroops()")

   ; Open chat window
   If OpenChatWindow() = False Then Return False

   ; Search for donate button
   Local $donateButton[4]
   If FindDonateButton($donateButton) = False Then Return False

   ; Get the request text
   Local $requestText
   GetRequestText($donateButton, $requestText)

   ; Open donate droops window
   If OpenDonateTroopsWindow($donateButton) = False Then Return False

   ; Loop until donate troops window goes away, no match for request, or loop limit reached
   Local $loopLimit = 6
   While IsColorPresent($rWindowChatDimmedColor) And $loopLimit>0
	  DebugWrite("Donate loop " & 6-$loopLimit & " of " & 5)

	  ; Locate troops that are available to donate
	  Local $donateIndex[$eTroopCount][4] ; x1, y1, x2, y2
	  FindDonateTroopSlots($donateIndex)

	  ; Parse request text, matching with available troops
	  Local $indexOfTroopToDonate
	  If ParseRequestText($requestText, $donateIndex, $indexOfTroopToDonate) = False Then ExitLoop
	  If $donateIndex[$indexOfTroopToDonate][0] = -1 Then ExitLoop

	  ; Click the correct donate troops button
	  ClickDonateTroops($donateIndex, $indexOfTroopToDonate)

	  $loopLimit-=1
   WEnd

   ; Done!
   ResetToCoCMainScreen()
EndFunc

Func OpenChatWindow()
   If IsButtonPresent($rMainScreenClosedChatButton) = False And _
	  IsButtonPresent($rMainScreenOpenChatButton) = False Then Return False

   RandomWeightedClick($rMainScreenClosedChatButton)

   ; Wait for OpenChatButton button
   Local $failCount = 10
   While IsButtonPresent($rMainScreenOpenChatButton) = False And $failCount>0
	  Sleep(1000)
	  $failCount -= 1
   WEnd

   If $failCount = 0 Then
	  DebugWrite("Donate Troops failed - timeout waiting for open chat window")
	  ResetToCoCMainScreen()
	  Return False
   EndIf

   Return True
EndFunc

Func FindDonateButton(ByRef $button)
   GrabFrameToFile("ChatFrame.bmp", $rChatBox[0], $rChatBox[1], $rChatBox[2], $rChatBox[3])

   Local $bestMatch, $bestConfidence, $bestX, $bestY
   ScanFrameForBestBMP("ChatFrame.bmp", $DonateButtonBMPs, 0.95, $bestMatch, $bestConfidence, $bestX, $bestY)

   If $bestMatch = -1 Then
	  DebugWrite("Donate button not found.")
	  ResetToCoCMainScreen()
	  Return False
   EndIf

   $button[0] = $bestX
   $button[1] = $bestY
   $button[2] = $bestX+$rChatWindowDonateButton[2]
   $button[3] = $bestY+$rChatWindowDonateButton[3]

   DebugWrite("Donate button found at: " & $button[0] & ", " & $button[1] & ", " _
	  & $button[2] & ", " & $button[3])

   Return True
EndFunc

Func GetRequestText(Const ByRef $button, ByRef $text)
   ; Grab text of donate request
   Local $textOffset[2] = [-68, -25] ; relative to donate button
   Local $donateTextBox[10] = [$button[0]+$rChatTextBoxAsOffset[0], $button[1]+$rChatTextBoxAsOffset[1], _
							   $button[0]+$rChatTextBoxAsOffset[2], $button[1]+$rChatTextBoxAsOffset[3], _
							   $rChatTextBoxAsOffset[4], $rChatTextBoxAsOffset[5], $rChatTextBoxAsOffset[6], _
							   $rChatTextBoxAsOffset[7], $rChatTextBoxAsOffset[8], $rChatTextBoxAsOffset[9]]

   $text = ScrapeExactText($gChatCharacterMaps, $donateTextBox, $gChatCharMapsMaxWidth, $eScrapeDropSpaces)
   DebugWrite("Donate text: '" & $text & "'")
EndFunc

Func OpenDonateTroopsWindow(Const ByRef $button)
   RandomWeightedClick($button)

   Local $failCount = 10
   While IsColorPresent($rWindowChatDimmedColor) = False And $failCount>0
	  Sleep(200)
	  $failCount -= 1
   WEnd

   If $failCount = 0 Then
	  DebugWrite("Donate Troops failed - timeout waiting for donate troops window")
	  ResetToCoCMainScreen()
	  Return False
   EndIf

   DebugWrite("Donate troops window opened.")
   Return True
EndFunc

Func FindDonateTroopSlots(ByRef $index)
   ; Grab a frame
   GrabFrameToFile("AvailableDonateFrame.bmp", $rDonateWindow[0], $rDonateWindow[1], $rDonateWindow[2], $rDonateWindow[3])

   For $i = $eTroopBarbarian To $eTroopLavaHound
	  Local $res = DllCall("ImageMatch.dll", "str", "FindMatch", "str", "AvailableDonateFrame.bmp", "str", "Images\"&$gDonateSlotBMPs[$i], "int", 3)
	  Local $split = StringSplit($res[0], "|", 2) ; x, y, conf
	  ;DebugWrite("Troop " & $gDonateSlotBMPs[$i] & " found at " & $split[0] & ", " & $split[1] & " conf: " & $split[2])

	  If $split[2] > $gConfidenceDonateTroopSlot Then
		 $index[$i][0] = $split[0]+$rDonateButtonOffset[0]
		 $index[$i][1] = $split[1]+$rDonateButtonOffset[1]
		 $index[$i][2] = $split[0]+$rDonateButtonOffset[2]
		 $index[$i][3] = $split[1]+$rDonateButtonOffset[3]
		 DebugWrite("Troop " & $gDonateSlotBMPs[$i] & " found at " & $index[$i][0] & ", " & $index[$i][1] & " conf: " & Round($split[2]*100, 2) & "%")
	  Else
		 $index[$i][0] = -1
		 $index[$i][1] = -1
		 $index[$i][2] = -1
		 $index[$i][3] = -1
	  EndIf
   Next
EndFunc

Func ParseRequestText(Const ByRef $text, Const ByRef $avail, ByRef $index)
   $index = -1

   ; Is a negative string present, exit now
   For $i = 1 To $gDonateMatchNegativeStrings[0]
	  If StringInStr($text, $gDonateMatchNegativeStrings[$i]) Then
		 DebugWrite("Negative string match, cannot parse negative requests.")
		 Return False
	  EndIf
   Next

   ; Check the specific troop search strings first
   For $i = $eTroopLavaHound To $eTroopBarbarian Step -1 ; Reverse search to fill more costly troops first
	  Local $searchTerms = StringSplit($gDonateMatchTroopStrings[$i], "|")

	  For $j = 1 To $searchTerms[0]
		 If StringInStr($text, $searchTerms[$j]) Then
			If $avail[$i][0]<>-1 Then
			   DebugWrite("String match for: " & $gTroopNames[$i] & ", troop available.")
			   $index = $i
			   ExitLoop 2
			Else
			   DebugWrite("String match for: " & $gTroopNames[$i] & ", troop NOT available, exiting.")
			   ResetToCoCMainScreen()
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
	  DebugWrite("Could not find a fill for request, exiting.")
	  ResetToCoCMainScreen()
	  Return False
   EndIf

   DebugWrite("Filling request with " & $gTroopNames[$index] & ".")

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

   DebugWrite("String match for '" & $type & "'")

   For $i = 1 To $troops[0]
	  Local $troopNum = _ArraySearch($gTroopNames, $troops[$i])
	  If $troopNum <> -1 Then
		 If $avail[$troopNum][0]<>-1 Then Return $troopNum
	  EndIf
   Next

   Return -2
EndFunc

Func ClickDonateTroops(Const ByRef $donateIndex, Const $indexOfTroopToDonate)

   Local $DonateMaxClicks[16] = [6, 6, 6, 6,   6, 6, 6, 2,   1, 1, 6, 6,   4, 1, 2, 1]

   Local $button[4] = [$donateIndex[$indexOfTroopToDonate][0] + $rDonateWindow[0], _
					   $donateIndex[$indexOfTroopToDonate][1] + $rDonateWindow[1], _
					   $donateIndex[$indexOfTroopToDonate][2] + $rDonateWindow[0], _
					   $donateIndex[$indexOfTroopToDonate][3] + $rDonateWindow[1]]

   Local $donateCount=0
   For $i = 1 To $DonateMaxClicks[$indexOfTroopToDonate]
	  If IsColorPresent($rWindowChatDimmedColor) Then
		 RandomWeightedClick($button)
		 $donateCount+=1
		 Sleep($gDonateTroopClickDelay)
	  EndIf
   Next

   If $donateCount>0 Then
	  DebugWrite("Donated " & $donateCount & " " & $gTroopNames[$indexOfTroopToDonate])
   EndIf
EndFunc

Func QueueDonatableTroops()
   DebugWrite("QueueDonatableTroops()")
   #cs


   ; TODO: This is not complete yet...inventory of built/queued troops is complete
   ; Need to figure out good logic for how to "stock" troops for donation.
   ; For now, the donate function just donates troops already in stock that have
   ; been queued manually, or are there due to auto-raid queueing.

   ; Count how many troops are in the Army Camps
   Local $availableTroopCounts[$gTroopCountExcludingHeroes]

   If OpenArmyCampWindow() = False Then
	  DebugWrite("Donate: Unable to locate Army Camp.")
	  Return
   EndIf

   GetArmyCampTroopCounts($availableTroopCounts)

   CloseArmyCampWindow()

   ; Open train troops window and find spell/dark window
   OpenBarracksWindow()
   If WhereAmI() <> $eScreenTrainTroops Then
	  ResetToCoCMainScreen()
	  Return
   EndIf

   If FindSpellsQueueingWindow() = False Then
	 DebugWrite("Donate, Queue Troops failed - can't find Spells or Dark window")
	 ResetToCoCMainScreen()
	 Return
   EndIf

   ; Count queued troops
   Local $queuedTroopCounts[$gTroopCountExcludingHeroes]
   CountQueuedTroops($queuedTroopCounts)

   ; See if standard and/or dark are needed
   Local $standardNeeded = False
   Local $darkNeeded = False

   For $i = $eTroopBarbarian To $eTroopPekka
	  If $gDonateTroopStock[$i] > 0 And $availableTroopCounts[$i]+$queuedTroopCounts[$i] < $gDonateTroopStock[$i] Then
		 $standardNeeded = True
		 DebugWrite($gTroopNames[$i] & " stock LOW - queued / needed: " & _
			$availableTroopCounts[$i]+$queuedTroopCounts[$i] & " / " & $gDonateTroopStock[$i])
	  EndIf
   Next

   For $i = $eTroopMinion To $eTroopLavaHound
	  If $gDonateTroopStock[$i] > 0 And $availableTroopCounts[$i]+$queuedTroopCounts[$i] < $gDonateTroopStock[$i] Then
		 $darkNeeded = True
		 DebugWrite($gTroopNames[$i] & " stock LOW - queued / needed: " & _
			$availableTroopCounts[$i]+$queuedTroopCounts[$i] & " / " & $gDonateTroopStock[$i])
	  EndIf
   Next

   ; TODO: This is where the "queue to stock" logic needs to be figured out

   ; Queue up standard
   If $standardNeeded = True Then
	  ; Find spell/dark window
	  If FindSpellsQueueingWindow() = False Then
		DebugWrite("Donate, Queue Troops failed - can't find Spells or Dark window")
		ResetToCoCMainScreen()
		Return
	  EndIf

	  ; Loop through number of barracks allocated to donations
	  For $barrackNum = 1 To $gDonateBarracksStandardMaximum

		 ; Next troop window
		 RandomWeightedClick($rBarracksWindowNextButton)
		 Sleep(250)

		 ; Make sure we are on a standard troops window
		 If IsColorPresent($rWindowBarracksStandardColor1) = False And IsColorPresent($rWindowBarracksStandardColor2) = False Then
			ExitLoop
		 EndIf

		 ; Find buttons
		 Local $barracksTroopBox[4] = [289, 224, 739, 400]
		 GrabFrameToFile("BarracksQueuedTroopsFrame.bmp", $barracksTroopBox[0], $barracksTroopBox[1], _
			$barracksTroopBox[2], $barracksTroopBox[3])



		 ;
		 For $i = $eTroopBarbarian To $eTroopPekka
			If $gDonateTroopStock[$i] > 0 And $availableTroopCounts[$i]+$queuedTroopCounts[$i] < $gDonateTroopStock[$i] Then
			   ; queue troops


			   ; Add to queue - standard or dark?
			   If $i >= $eTroopBarbarian And $i <= $eTroopPekka Then
				  ;$gDonateBarracksStandardMaximum
				  ;$gDonateBarracksDarkMaximum
			   Else
			   EndIf

			EndIf
		 Next
	  Next
   EndIf

   ; Queue up dark

   CloseBarracksWindow()

   #ce

EndFunc

#cs
Func CountQueuedTroops(ByRef $troopCounts)
   DebugWrite("CountQueuedTroops()")

   For $i = $eTroopBarbarian To $eTroopLavaHound
	  $troopCounts[$i] = 0
   Next

   ; Loop through barracks and count specified troops, until we get back to the spells screen
   ; Or we've looked at 6 screens
   Local $screenCount = 0
   Do
	  RandomWeightedClick($rBarracksWindowNextButton)
	  Sleep(250)
	  $screenCount += 1

	  Local $counts[$gTroopCountExcludingHeroes]
	  GetBarracksTroopCounts($gBarracksTroopSlotBMPs, $counts)
	  For $i = $eTroopBarbarian To $eTroopLavaHound
		 $troopCounts[$i] += $counts[$i]
	  Next

   Until OnTrainTroopsSpellWindow() Or $screenCount >= 6
EndFunc

#ce
