Func InitScraper()
   _GDIPlus_Startup()

   ; ClAsHbOt DLL
   $gClAsHbOtDllHandle = DllOpen("ClAsHbOt.dll")

   If $gClAsHbOtDllHandle = -1 Then
	  DebugWrite("InitScraper() Error loading DLL")
	  MsgBox(BitOr($MB_OK, $MB_ICONERROR), "DLL Open Error", "Error opening ClAsHbOt.dll.  Exiting.")
	  Exit
   EndIf
   DebugWrite("InitScraper() ClAsHbOt.dll loaded")

   ; ClAsHbOt DLL Initialize
   Local $res = DllCall($gClAsHbOtDllHandle, "boolean", "Initialize", "str", @WorkingDir, "bool", $gDebug, "bool", $gScraperDebug)
   If @error Then
	  DebugWrite("DLLLoad() DllCall Initialize @error=" & @error)
	  MsgBox(BitOR($MB_ICONERROR, $MB_OK), "ClAsHbOt DLL Error", "Error initializing DLL." & @CRLF & _
		 "This is catastrophic, exiting.")
	  Exit
   EndIf

   If $res[0] = False Then
	  DebugWrite("DLLLoad() Error initializing DLL")
	  MsgBox(BitOr($MB_OK, $MB_ICONERROR), "DLL Open Error", "Error initializing ImageMatch.dll." & @CRLF & _
		 "This is catastrophic, exiting.")
	  Exit
   EndIf
   DebugWrite("InitScraper() ClAsHbOt.dll initialized: " & $res[0])

   ; user32.dll
   $gUser32DllHandle = DllOpen("user32.dll")
   If $gUser32DllHandle = -1 Then
	  DebugWrite("InitScraper() Error loading user32.dll")
	  MsgBox(BitOr($MB_OK, $MB_ICONERROR), "DLL Open Error", "Error opening user32.dll.  Exiting.")
	  Exit
   EndIf
   DebugWrite("InitScraper() user32.dll loaded")

   ; gdi32.dll
   $gGdi32DllHandle = DllOpen("gdi32.dll")
   If $gGdi32DllHandle = -1 Then
	  DebugWrite("InitScraper() Error loading gdi32.dll")
	  MsgBox(BitOr($MB_OK, $MB_ICONERROR), "DLL Open Error", "Error opening gdi32.dll.  Exiting.")
	  Exit
   EndIf
   DebugWrite("InitScraper() gdi32.dll loaded")

   ; win api handles that only need to be opened once
   $gHDC = _WinAPI_GetWindowDC($gBlueStacksControlHwnd)
   $gMemDC = _WinAPI_CreateCompatibleDC($gHDC)

EndFunc

Func ExitScraper()
   _WinAPI_DeleteDC($gMemDC)
   _WinAPI_ReleaseDC($gBlueStacksControlHwnd, $gHDC)

   DllClose($gUser32DllHandle)
   DebugWrite("ExitScraper() user32.dll unloaded")

   DllClose($gGdi32DllHandle)
   DebugWrite("ExitScraper() gdi32.dll unloaded")

   DllClose($gClAsHbOtDllHandle)
   DebugWrite("ExitScraper() ImageMatch.dll unloaded")

   _GDIPlus_Shutdown()

   DebugWrite("ExitScraper() Scraper shut down")
EndFunc

Func ScrapeFuzzyText(Const $hBMP, Const $type, Const $textBox)
   ; struct: left, top, right, bottom, color, radius
   Local $box = DllStructCreate("STRUCT; uint; uint; uint; uint; uint; uint; ENDSTRUCT")
   For $i=0 To 5
	  DllStructSetData($box, $i+1, $textBox[$i])
   Next

   Local $stringScraped = DllStructCreate("char[" & $gMAXSTRING & "]")
   Local $res = DllCall($gClAsHbOtDllHandle, "boolean", "ScrapeFuzzyText", _
	  "handle", $hBMP, "int", $type, "struct", $box, "bool", False, _
	  "ptr", DllStructGetPtr($stringScraped))

   If @error Then
	  DebugWrite("ScrapeFuzzyText() " & $gFontNames[$type] & " DllCall @error=" & @error)
	  MsgBox(BitOR($MB_ICONERROR, $MB_OK), "ImageMatch DLL Error", "Error with DLL, ScrapeFuzzyText" & @CRLF & _
		 "This is catastrophic, exiting.")
	  Exit
   EndIf

  Local $s = DllStructGetData($stringScraped, 1)
  $stringScraped = 0
   ;DebugWrite("My " & $type & ": " & $s)

   If $res[0] Then
	  Return $s
   Else
	  Return ""
   EndIf
EndFunc

Func ScrapeExactText(Const $hBMP, Const $type, Const $textBox)
   ; struct: left, top, right, bottom, color, radius
   Local $box = DllStructCreate("STRUCT; uint; uint; uint; uint; uint; uint; ENDSTRUCT")
   For $i=0 To 5
	  DllStructSetData($box, $i+1, $textBox[$i])
   Next

   Local $stringScraped = DllStructCreate("char[" & $gMAXSTRING & "]")
   Local $res = DllCall($gClAsHbOtDllHandle, "boolean", "ScrapeExactText", _
	  "handle", $hBMP, "int", $type, "struct", $box, "bool", False, _
	  "ptr", DllStructGetPtr($stringScraped))

   If @error Then
	  DebugWrite("ScrapeExactText2() " & $gFontNames[$type] & " DllCall @error=" & @error)
	  MsgBox(BitOR($MB_ICONERROR, $MB_OK), "ImageMatch DLL Error", "Error with DLL, ScrapeExactText" & @CRLF & _
		 "This is catastrophic, exiting.")
	  Exit
   EndIf

   Local $s = DllStructGetData($stringScraped, 1)
   $stringScraped = 0
   ;DebugWrite("My " & $type & ": " & $s)

   If $res[0] Then
	  Return $s
   Else
	  Return ""
   EndIf
EndFunc

Func FindBestBMP(Const $searchType, ByRef $left, ByRef $top, ByRef $conf, ByRef $value)
   ; $value parameter returns town hall level in town hall search,
   ; matched bitmap file name for other searches

   ; Default
   $left = -1
   $top = -1
   $conf = 0
   $value = -1

   ; Get frame
   Local $box[4], $thresh
   If $searchType = $eSearchTypeTownHall Then
	  $box[0] = $gWestPoint[0]
	  $box[1] = $gNorthPoint[1]-10
	  $box[2] = $gEastPoint[0]
	  $box[3] = $gSouthPoint[1]
	  $thresh = $gConfidenceTownHall

   ElseIf $searchType = $eSearchTypeLootCart Then
	  $box[0] = $gWestPoint[0]
	  $box[1] = $gNorthPoint[1]-10
	  $box[2] = $gEastPoint[0]
	  $box[3] = $gSouthPoint[1]
	  $thresh = $gConfidenceLootCart

   ElseIf $searchType=$eSearchClashIcon Then
	  $box[0] = 0
	  $box[1] = 0
	  $box[2] = $gBlueStacksWidth
	  $box[3] = $gBlueStacksHeight
	  $thresh = $gConfidenceClashIcon

   ElseIf $searchType=$eSearchPlayStoreOpenButton Then
	  $box[0] = 0
	  $box[1] = 0
	  $box[2] = $gBlueStacksWidth
	  $box[3] = $gBlueStacksHeight
	  $thresh = $gConfidencePlayStoreOpenButton

   ElseIf $searchType=$eSearchTypeGoldStorage Or $searchType=$eSearchTypeElixStorage Then
	  $box[0] = $gScreenCenter[0]-150
	  $box[1] = $gScreenCenter[1]-150
	  $box[2] = $gScreenCenter[0]+150
	  $box[3] = $gScreenCenter[1]+150
	  $thresh = $gConfidenceStorages

   Else
	  DebugWrite("FindBestBMP() Error, searchType not recognized: " & $searchType)
	  Return False

   EndIf

   ; Grab frame
   Local $hHBITMAP = CaptureFrameHBITMAP("FindBestBMP" & $gSearchTypeNames[$searchType], $box[0], $box[1], $box[2], $box[3])
   If $gDebugSaveScreenCaptures Then _ScreenCapture_SaveImage("FindBestBMP" & $gSearchTypeNames[$searchType] & "Frame.bmp", $hHBITMAP, False)

   ; Call DLL
   Local $matchPoint = DllStructCreate("int; int; double")
   Local $matchedBMP = DllStructCreate("char[" & $gMAXSTRING & "]")

   Local $res = DllCall($gClAsHbOtDllHandle, "boolean", "FindBestBMP", _
	  "int", $searchType, "handle", $hHBITMAP, "double", $thresh, _
	  "ptr", DllStructGetPtr($matchPoint), "ptr", DllStructGetPtr($matchedBMP))

   ;For $i=0 To UBound($res)-1
	;  DebugWrite("$res[" & $i & "]: " & $res[$i])
   ;Next

   ; DLL error?
   If @error Then
	  DebugWrite("FindBestBMP() " & $gSearchTypeNames[$searchType] & " DllCall @error=" & @error)
	  MsgBox(BitOR($MB_ICONERROR, $MB_OK), "ImageMatch DLL Error", "Error with DLL, FindBestBMP" & @CRLF & _
		 "This is catastrophic, exiting.")
	  $matchPoint = 0
	  Exit
   EndIf

   ; Save storage frame?
   If ($searchType=$eSearchTypeGoldStorage Or $searchType=$eSearchTypeElixStorage) And _
	  $res[0] = False And _
	  $gDebugSaveUnknownStorageFrames Then

	  _ScreenCapture_SaveImage($gSearchTypeNames[$searchType] & "Unknown" & TimeStamp() & ".bmp", $hHBITMAP, False)
   EndIf

   _WinAPI_DeleteObject($hHBITMAP)

   ; Get result
   $left = DllStructGetData($matchPoint, 1) + $box[0]
   $top = DllStructGetData($matchPoint, 2) + $box[1]
   $conf = DllStructGetData($matchPoint, 3)
   $value = DllStructGetData($matchedBMP, 1)
   $matchPoint = 0
   $matchedBMP = 0

   If $searchType = $eSearchTypeTownHall And $res[0] = False Then
	  $value = -1
	  Return False
   ElseIf $searchType = $eSearchTypeTownHall And $res[0] = True Then
	  Local $a = StringInStr($value, "TH")
	  Local $b = StringInStr($value, ".bmp")
	  Local $c = StringMid($value, $a+2, $b-$a-2)
	  $value = Number($c)
	  Return True
   Else
	  Return $res[0]
   EndIf

   Return True
EndFunc

Func FindAllBMPs(Const $searchType, Const $maxMatch, ByRef $matchX, ByRef $matchY, ByRef $confs, ByRef $matchCount)
   Local $box[4], $thresh
   If $searchType=$eSearchTypeGoldStorage Or $searchType=$eSearchTypeElixStorage Then
	  $box[0] = $gScreenCenter[0]-150
	  $box[1] = $gScreenCenter[1]-150
	  $box[2] = $gScreenCenter[0]+150
	  $box[3] = $gScreenCenter[1]+150
	  $thresh = $gConfidenceStorages

   ElseIf $searchType = $eSearchTypeLootCollector Then
	  $box[0] = $gWestPoint[0]
	  $box[1] = $gNorthPoint[1]-10
	  $box[2] = $gEastPoint[0]
	  $box[3] = $gSouthPoint[1]
	  $thresh = $gConfidenceCollector

   ElseIf $searchType = $eSearchTypeLootBubble Then
	  $box[0] = $gWestPoint[0]
	  $box[1] = $gNorthPoint[1]
	  $box[2] = $gEastPoint[0]
	  $box[3] = $gSouthPoint[1]
	  $thresh = $gConfidenceCollectLoot

   ElseIf $searchType = $eSearchDonateButton Then
	  For $i=0 To 3
		 $box[$i] = $rChatBox[$i]
	  Next
	  $thresh = $gConfidenceDonateButton

   ElseIf $searchType = $eSearchTypeDropZone Then
	  $box[0] = $gWestPoint[0]
	  $box[1] = $gNorthPoint[1]
	  $box[2] = $gEastPoint[0]
	  $box[3] = $gSouthPoint[1]
	  $thresh = $gConfidenceDropZone

   Else
	  DebugWrite("FindAllBMPs() Error, searchType not recognized: " & $searchType)
	  Return

   EndIf

   ; Grab frame
   Local $hHBITMAP = CaptureFrameHBITMAP("FindAllBMPs" & $gSearchTypeNames[$searchType], $box[0], $box[1], $box[2], $box[3])
   If $gDebugSaveScreenCaptures Then _ScreenCapture_SaveImage("FindAllBMPs" & $gSearchTypeNames[$searchType] & "Frame.bmp", $hHBITMAP, False)

   ; Call DLL
   Local $matchPointStruct = "int;int;double"
   Local $matchPointAllStructs = ""
   For $i = 1 To $maxMatch
	  $matchPointAllStructs &= $matchPointStruct & ";"
   Next
   $matchPointAllStructs = StringLeft($matchPointAllStructs, StringLen($matchPointAllStructs)-1)
   Local $matchPoints = DllStructCreate($matchPointAllStructs)

   Local $count

   Local $res = DllCall($gClAsHbOtDllHandle, "boolean", "FindAllBMPs", _
	  "int", $searchType, "handle", $hHBITMAP, "double", $thresh, "int", $maxMatch, _
	  "ptr", DllStructGetPtr($matchPoints), "uint*", $count)

   _WinAPI_DeleteObject($hHBITMAP)

   ;For $i=0 To UBound($res)-1
	;  DebugWrite("$res[" & $i & "]: " & $res[$i])
   ;Next

   ; DLL error?
   If @error Then
	  DebugWrite("FindAllBMPs() DllCall @error=" & @error)
	  MsgBox(BitOR($MB_ICONERROR, $MB_OK), "ImageMatch DLL Error", "Error with DLL, FindAllBMPs" & @CRLF & _
		 "This is catastrophic, exiting.")
	  Exit
   EndIf

   ; Get result
   If $res[0] = False Then Return False

   $matchCount = $res[6]
   ;DebugWrite("Num matches " & $gSearchTypeNames[$searchType] & ": " & $matchCount)

   ReDim $matchX[$matchCount]
   ReDim $matchY[$matchCount]
   ReDim $confs[$matchCount]

   For $i = 0 To $matchCount-1
	  $matchX[$i] = DllStructGetData($matchPoints, $i*3+1) + $box[0]
	  $matchY[$i] = DllStructGetData($matchPoints, $i*3+2) + $box[1]
	  $confs[$i] = DllStructGetData($matchPoints, $i*3+3)
	  ;DebugWrite("Match " & $i & " " & $matchX[$i] & " " & $matchY[$i] & " " & $confs[$i])
   Next

   Return True
EndFunc

Func FindTopOfDonateBox()
   Local $hHBITMAP = CaptureFrameHBITMAP("FindTopOfDonateBox")
   Local $topDonateBox = -1
   For $i = 0 To 300
	  Local $c[4] = [650, $i, 0xFFFFFF, 0]
	  If IsColorPresent($hHBITMAP, $c) Then
		 $topDonateBox = $i
		 ExitLoop
	  EndIf
   Next
   _WinAPI_DeleteObject($hHBITMAP)

   Return $topDonateBox
EndFunc

Func LocateSlots(Const $actionType, Const $slotType, ByRef $index)
   ; Get frame
   Local $box[4], $thresh
   If $actionType = $eActionTypeRaid Then
	  For $i=0 To 3
		 $box[$i] = $rRaidTroopBox[$i]
	  Next
	  $thresh = $gConfidenceRaidTroopSlot

   ElseIf $actionType = $eActionTypeDonate Then
	  Local $topDonateBox = FindTopOfDonateBox()
	  If $topDonateBox = -1 Then
		 DebugWrite("LocateSlots() for Donate failed - cound not find top of donate troops window")
		 Return
	  EndIf
	  $box[0] = ($slotType = $eSlotTypeTroop ? $rDonateTroopsBox[0] : $rDonateSpellsBox[0])
	  $box[1] = ($slotType = $eSlotTypeTroop ? $rDonateTroopsBox[1] : $rDonateSpellsBox[1]) + $topDonateBox
	  $box[2] = ($slotType = $eSlotTypeTroop ? $rDonateTroopsBox[2] : $rDonateSpellsBox[2])
	  $box[3] = ($slotType = $eSlotTypeTroop ? $rDonateTroopsBox[3] : $rDonateSpellsBox[3]) + $topDonateBox
	  $thresh = $gConfidenceDonateTroopSlot

   ElseIf $actionType = $eActionTypeBarracks Then
	  For $i=0 To 3
		  $box[$i] = $rBarracksTroopBox[$i]
	  Next
	  $thresh = $gConfidenceBarracksTroopSlot

   ElseIf $actionType = $eActionTypeCamp And $slotType = $eSlotTypeTroop Then
	  For $i=0 To 3
		  $box[$i] = $rCampTroopBox1[$i]
	  Next
	  $thresh = $gConfidenceArmyCamp

   ElseIf $actionType = $eActionTypeCamp And $slotType = $eSlotTypeHero Then
	  For $i=0 To 3
		  $box[$i] = $rCampTroopBox2[$i]
	  Next
	  $thresh = $gConfidenceArmyCamp

   ElseIf $actionType = $eActionTypeReloadButton Then
	  For $i=0 To 3
		 $box[$i] = $rReloadDefensesBox[$i]
	  Next
	  $thresh = $gConfidenceReloadButton

   Else
	  DebugWrite("FindAllBMPs() Error, actionType/slotType not recognized: " & $actionType)
	  Return

   EndIf

   ; Grab frame
   Local $hHBITMAP = CaptureFrameHBITMAP("LocateSlots" & $gActionTypeNames[$actionType] & $gSlotTypeNames[$slotType], _
	  $box[0], $box[1], $box[2], $box[3])
   If $gDebugSaveScreenCaptures Then _
	  _ScreenCapture_SaveImage("LocateSlots" & $gActionTypeNames[$actionType] & $gSlotTypeNames[$slotType] & "Frame.bmp", $hHBITMAP, False)

   ; Call DLL
   Local $matchPointStruct = "int;int;double"
   Local $matchPointAllStructs = ""
   For $i = 1 To UBound($index)
	  $matchPointAllStructs &= $matchPointStruct & ";"
   Next
   $matchPointAllStructs = StringLeft($matchPointAllStructs, StringLen($matchPointAllStructs)-1)
   Local $matchPoints = DllStructCreate($matchPointAllStructs)

   Local $res = DllCall($gClAsHbOtDllHandle, "boolean", "LocateSlots", _
	  "int", $actionType, "int", $slotType, "handle", $hHBITMAP, "double", $thresh, _
	  "ptr", DllStructGetPtr($matchPoints))

   _WinAPI_DeleteObject($hHBITMAP)

   ;For $i=0 To UBound($res)-1
	;  DebugWrite("$res[" & $i & "]: " & $res[$i])
   ;Next

   ; DLL error?
   If @error Then
	  DebugWrite("LocateSlots() DllCall @error=" & @error)
	  MsgBox(BitOR($MB_ICONERROR, $MB_OK), "ImageMatch DLL Error", "Error with DLL, LocateSlots" & @CRLF & _
		 "This is catastrophic, exiting.")
	  Exit
   EndIf

   ; Get result
   If $res[0] = False Then Return False

   For $i = 0 To UBound($index)-1
	  Local $x = DllStructGetData($matchPoints, $i*3+1)
	  Local $y = DllStructGetData($matchPoints, $i*3+2)
	  Local $conf = DllStructGetData($matchPoints, $i*3+3)

	  If $actionType = $eActionTypeRaid Then
		 If $index[$i][0]=-1 And $x<>-1 Then
			$index[$i][0] = $box[0] + $x + $rRaidButtonOffset[0]
			$index[$i][1] = $box[1] + $y + $rRaidButtonOffset[1]
			$index[$i][2] = $box[0] + $x + $rRaidButtonOffset[2]
			$index[$i][3] = $box[1] + $y + $rRaidButtonOffset[3]
			If $gDebug Then
			   DebugWrite("Raid slot " & $gSlotTypeNames[$slotType] & " " & (($slotType=$eSlotTypeTroop) ? $gTroopNames[$i] : $gSpellNames[$i]) & " found, confidence " & Round($conf*100, 2) & "%" & _
				  " box: " & $index[$i][0] & "," & $index[$i][1] & "," & $index[$i][2] & "," & $index[$i][3])
			EndIf
		 EndIf

	  ElseIf $actionType = $eActionTypeDonate Then
		 If $x<>-1 Then
			$index[$i][0] = $box[0] + $x + $rDonateButtonOffset[0]
			$index[$i][1] = $box[1] + $y + $rDonateButtonOffset[1]
			$index[$i][2] = $box[0] + $x + $rDonateButtonOffset[2]
			$index[$i][3] = $box[1] + $y + $rDonateButtonOffset[3]
			If $gDebug Then
			   DebugWrite("Donate slot " & $gSlotTypeNames[$slotType] & " " & (($slotType=$eSlotTypeTroop) ? $gTroopNames[$i] : $gSpellNames[$i]) & " found, confidence " & Round($conf*100, 2) & "%" & _
				  " box: " & $index[$i][0] & "," & $index[$i][1] & "," & $index[$i][2] & "," & $index[$i][3])
			EndIf
		 EndIf

	  ElseIf $actionType = $eActionTypeBarracks Then
		 If $x<>-1 Then
			$index[$i][0] = $box[0] + $x + $rBarracksButtonOffset[0]
			$index[$i][1] = $box[1] + $y + $rBarracksButtonOffset[1]
			$index[$i][2] = $box[0] + $x + $rBarracksButtonOffset[2]
			$index[$i][3] = $box[1] + $y + $rBarracksButtonOffset[3]
			If $gDebug Then
			   DebugWrite("Barracks slot " & $gSlotTypeNames[$slotType] & " " & (($slotType=$eSlotTypeTroop) ? $gTroopNames[$i] : $gSpellNames[$i]) & " found, confidence " & Round($conf*100, 2) & "%" & _
				  " box: " & $index[$i][0] & "," & $index[$i][1] & "," & $index[$i][2] & "," & $index[$i][3])
			EndIf
		 EndIf

	  ElseIf $actionType = $eActionTypeCamp Then
		 If $x<>-1 Then
			$index[$i][0] = $box[0] + $x
			$index[$i][1] = $box[1] + $y
			$index[$i][2] = $box[0] + $x
			$index[$i][3] = $box[1] + $y
			If $gDebug Then
			   Local $name = ( ($slotType=$eSlotTypeTroop Or $slotType=$eSlotTypeHero) ? $gTroopNames[$i] : _
							   ($slotType=$eSlotTypeSpell) ? $gSpellNames[$i] : "" )
			   DebugWrite("Camp slot " & $gSlotTypeNames[$slotType] & " " & $name & " found, confidence " & Round($conf*100, 2) & "%" & _
				  " box: " & $index[$i][0] & "," & $index[$i][1] & "," & $index[$i][2] & "," & $index[$i][3])
			EndIf
		 EndIf

	  ElseIf $actionType = $eActionTypeReloadButton Then
		 If $x<>-1 Then
			$index[$i][0] = $box[0] + $x + $rReloadDefensesButtonOffset[0]
			$index[$i][1] = $box[1] + $y + $rReloadDefensesButtonOffset[1]
			$index[$i][2] = $box[0] + $x + $rReloadDefensesButtonOffset[2]
			$index[$i][3] = $box[1] + $y + $rReloadDefensesButtonOffset[3]
			If $gDebug Then
			   DebugWrite("Reload button slot found, confidence " & Round($conf*100, 2) & "%" & _
				  " box: " & $index[$i][0] & "," & $index[$i][1] & "," & $index[$i][2] & "," & $index[$i][3])
			EndIf
		 EndIf

	  EndIf
   Next

   Return True
EndFunc

Func IsTextBoxPresent(Const $hBMP, Const ByRef $textBox)
   Local $original  = _WinAPI_SelectObject($gMemDC, $hBMP)
   Local $res = DllCall($gGdi32DllHandle, "int", "GetPixel", "int", $gMemDC, "int" , $textBox[6], "int", $textBox[7])
   _WinAPI_SelectObject($gMemDC, $original)

   Return InColorSphere($res[0], $textBox[8], $textBox[9])
EndFunc

Func IsButtonPresent(Const $hBMP, Const ByRef $buttonBox)
   Local $original  = _WinAPI_SelectObject($gMemDC, $hBMP)
   Local $res = DllCall($gGdi32DllHandle, "int", "GetPixel", "int", $gMemDC, "int" , $buttonBox[4], "int", $buttonBox[5])
   _WinAPI_SelectObject($gMemDC, $original)

   Return InColorSphere($res[0], $buttonBox[6], $buttonBox[7])
EndFunc

Func IsColorPresent(Const $hBMP, Const ByRef $colorLocation)
   Local $original  = _WinAPI_SelectObject($gMemDC, $hBMP)
   Local $res = DllCall($gGdi32DllHandle, "int", "GetPixel", "int", $gMemDC, "int" , $colorLocation[0], "int", $colorLocation[1])
   _WinAPI_SelectObject($gMemDC, $original)

   Return InColorSphere($res[0], $colorLocation[2], $colorLocation[3])
EndFunc

Func WaitForButton(ByRef $hBMP, Const $wait, Const $b1, Const $b2=0, Const $b3=0)
   Local $t = TimerInit()
   Local $p1 = IsButtonPresent($hBMP, $b1)
   Local $p2 = $b2=0 ? False : IsButtonPresent($hBMP, $b2)
   Local $p3 = $b3=0 ? False : IsButtonPresent($hBMP, $b3)
   Local $lastTimeRem = Round($wait/1000)
   _WinAPI_DeleteObject($hBMP)
   $hBMP = CaptureFrameHBITMAP("WaitForButton " & $lastTimeRem)

   While TimerDiff($t)<$wait And $p1=False And $p2=False And $p3=False
	  If IsButtonPresent($hBMP, $rAndroidMessageButton1) Or IsButtonPresent($hBMP, $rAndroidMessageButton2) Then
		 Return SetError($eErrorAndroidMessageBox, 0, False)
	  EndIf

	  If IsColorPresent($hBMP, $rWaitForPersonalBreakPoint1Color) And _
		 IsColorPresent($hBMP, $rWaitForPersonalBreakPoint2Color) And _
		 IsColorPresent($hBMP, $rWaitForPersonalBreakPoint3Color) Then

		 Return SetError($eErrorAttackingDisabled, 0, False)
	  EndIf

	  Local $timeRem = Round(($wait-TimerDiff($t))/1000)
	  If $timeRem<>$lastTimeRem Then
		 $lastTimeRem = $timeRem
		 _WinAPI_DeleteObject($hBMP)
		 $hBMP = CaptureFrameHBITMAP("WaitForButton " & $lastTimeRem)

		 $p1 = IsButtonPresent($hBMP, $b1)
		 $p2 = $b2=0 ? False : IsButtonPresent($hBMP, $b2)
		 $p3 = $b3=0 ? False : IsButtonPresent($hBMP, $b3)
	  EndIf

	  Sleep(100)
   WEnd

   If $p1=False And $p2=False And $p3=False Then
	  Return False
   Else
	  Return True
   EndIf
EndFunc

Func WaitForColor(ByRef $hBMP, Const $wait, Const $c1, Const $c2=0, Const $c3=0)
   Local $t = TimerInit()
   Local $p1 = IsColorPresent($hBMP, $c1)
   Local $p2 = $c2=0 ? False : IsColorPresent($hBMP, $c2)
   Local $p3 = $c3=0 ? False : IsColorPresent($hBMP, $c3)
   Local $lastTimeRem = Round($wait/1000)
   _WinAPI_DeleteObject($hBMP)
   $hBMP = CaptureFrameHBITMAP("WaitForColor " & $lastTimeRem)

   While TimerDiff($t)<$wait And $p1=False And $p2=False And $p3=False
	  If IsButtonPresent($hBMP, $rAndroidMessageButton1) Or IsButtonPresent($hBMP, $rAndroidMessageButton2) Then
		 Return SetError($eErrorAndroidMessageBox, 0, False)
	  EndIf

	  If IsColorPresent($hBMP, $rWaitForPersonalBreakPoint1Color) And _
		 IsColorPresent($hBMP, $rWaitForPersonalBreakPoint2Color) And _
		 IsColorPresent($hBMP, $rWaitForPersonalBreakPoint3Color) Then

		 Return SetError($eErrorAttackingDisabled, 0, False)
	  EndIf

	  Local $timeRem = Round(($wait-TimerDiff($t))/1000)
	  If $timeRem<>$lastTimeRem Then
		 $lastTimeRem = $timeRem
		 _WinAPI_DeleteObject($hBMP)
		 $hBMP = CaptureFrameHBITMAP("WaitForColor " & $timeRem)
		 $p1 = IsColorPresent($hBMP, $c1)
		 $p2 = $c2=0 ? False : IsColorPresent($hBMP, $c2)
		 $p3 = $c3=0 ? False : IsColorPresent($hBMP, $c3)
	  EndIf

	  Sleep(100)
   WEnd

   If $p1=False And $p2=False And $p3=False Then
	  Return False
   Else
	  Return True
   EndIf
EndFunc

Func InColorSphere(Const $color, Const $center, Const $radius)
   ; Colors from $gMemDC using gdi32.dll PixelColor are in BGR format
   Local $b = BitShift(BitAND($color, 0x00FF0000), 16)
   Local $g = BitShift(BitAND($color, 0x0000FF00), 8)
   Local $r = BitAND($color, 0x000000FF)

   Local $rC = BitShift(BitAND($center, 0x00FF0000), 16)
   Local $gC = BitShift(BitAND($center, 0x0000FF00), 8)
   Local $bC = BitAND($center, 0x000000FF)

   Local $d = Sqrt( ($rC-$r)^2 + ($gC-$g)^2 + ($bC-$b)^2 )

   If $d <= $radius Then Return True

   Return False
EndFunc

Func DistBetweenTwoPoints(Const $x1, Const $y1, Const $x2, Const $y2)
  Return Sqrt( ($x1-$x2)^2 + ($y1-$y2)^2 )
EndFunc

; Returns the absolute position of the client window
Func GetClientPos()
   Local $cPos[4]

   ; Get absolute coordinates of client area
   Local $hWnd = WinGetHandle($gTitle)
   Local $cSize = WinGetClientSize($gTitle)

   Local $tPoint = DllStructCreate("int X;int Y")
   DllStructSetData($tPoint, "X", 0)
   DllStructSetData($tPoint, "Y", 0)

   _WinAPI_ClientToScreen($hWnd, $tPoint)
   $cPos[0] = DllStructGetData($tPoint, "X")
   $cPos[1] = DllStructGetData($tPoint, "Y")
   $cPos[2] = $cPos[0]+$cSize[0]-1
   $cPos[3] = $cPos[1]+$cSize[1]-1

   Return $cPos
EndFunc

Func CaptureFrameHBITMAP(Const $fromFunc, $x1=0, $y1=0, $x2=$gBlueStacksWidth, $y2=$gBlueStacksHeight)
   Local $backgroundMode = _GUICtrlButton_GetCheck($GUI_BackgroundModeCheckBox)

   If $gDebugLogCallsToCaptureFrame = True Then
	  DebugWrite("CaptureFrameHBITMAP() from " & $fromFunc & ($backgroundMode ? " (background)" : " (foreground)"))
   EndIf

   Local $hHBITMAP

   If $backgroundMode Then
	  $hHBITMAP = _WinAPI_CreateCompatibleBitmap($gHDC, $x2-$x1, $y2-$y1)
	  Local $bmpOriginal  = _WinAPI_SelectObject($gMemDC, $hHBITMAP)

	  DllCall($gUser32DllHandle, "int", "PrintWindow", "hwnd", $gBlueStacksControlHwnd, "handle", $gMemDC, "int", 0)
	  _WinAPI_BitBlt($gMemDC, 0, 0, $x2-$x1+1, $y2-$y1+1, $gHDC, $x1, $y1, $SRCCOPY)

	  _WinAPI_SelectObject($gMemDC, $bmpOriginal)

   Else
	  Local $cPos = GetClientPos()
	  Local $hHBITMAP = _ScreenCapture_Capture("", $cPos[0]+$x1, $cPos[1]+$y1, $cPos[0]+$x2, $cPos[1]+$y2)

   EndIf

   Return $hHBITMAP
EndFunc

Func TestBackgroundScrape()
   Local $hHBITMAP = CaptureFrameHBITMAP("TestBackGroundScrape")

   Local $tBitmap = DllStructCreate("int bmType; int bmWidth; int bmHeight; int bmWidthBytes; ushort bmPlanes; ushort bmBitsPixel; ptr bmBits")
   _WinAPI_GetObject($hHBITMAP, DllStructGetSize($tBitmap), DllStructGetPtr($tBitmap))
   Local $w = DllStructGetData($tBitmap, "bmWidth")
   Local $h = DllStructGetData($tBitmap, "bmHeight")

   Local $original  = _WinAPI_SelectObject($gMemDC, $hHBITMAP)

   Local $notBlackPixel = False
   For $i = 1 To 100
	  Local $res = DllCall($gGdi32DllHandle, "int", "GetPixel", "int", $gMemDC, "int" , Random(0, $w-1, 1), "int", Random(0, $h-1, 1))
	  ;DebugWrite($i & " 0x" & Hex(BitAND($res[0], 0xffffff)))
	  If  BitAND($res[0], 0xffffff) <> 0x000000 Then
		 $notBlackPixel = True
		 ExitLoop
	  EndIf
   Next

   _WinAPI_SelectObject($gMemDC, $original)
   $tBitmap = 0
   _WinAPI_DeleteObject($hHBITMAP)

   If $notBlackPixel = False Then
	  _GUICtrlButton_SetCheck($GUI_BackgroundModeCheckBox, False)

	  DebugWrite("TestBackgroundScrape() Background mode disabled")
	  Local $res = MsgBox(BitOR($MB_OK, $MB_ICONINFORMATION), "Background mode disabled", _
		 "Background mode has been disabled, as it appears to not be working." & @CRLF & @CRLF & _
		 "If you are running BlueStacks inside of another virtual machine, this may be the cause. " & _
		 "Since ClAsHbOt is now operating in the foreground, the BlueStacks window must be visible " & _
		 "and not obscured at any time.")

   Else
	  DebugWrite("TestBackgroundScrape() Background mode confirmed")

   EndIf
EndFunc

