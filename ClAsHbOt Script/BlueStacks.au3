
Func StartBlueStacks()
   CheckIfBlueStacksIsRunning()

   Local $clientPos = GetClientPos()
   If $clientPos[2]-$clientPos[0]+1<>$gBlueStacksWidth Or $clientPos[3]-$clientPos[1]+1<>$gBlueStacksHeight Then
	  Local $res = MsgBox(BitOr($MB_OKCANCEL, $MB_ICONQUESTION), "BlueStacks Wrong Size", "BlueStacks window is the wrong size." & @CRLF & _
		 "Click OK to resize, or Cancel to Exit.")

	  If $res = $IDCANCEL Then
		 Exit
	  EndIf

	  FixBlueStacksSize()

	  CheckIfBlueStacksIsRunning()

	  $clientPos = GetClientPos()
	  If $clientPos[2]-$clientPos[0]+1<>$gBlueStacksWidth Or $clientPos[3]-$clientPos[1]+1<>$gBlueStacksHeight Then
		 MsgBox(BitOr($MB_OK, $MB_ICONERROR), "BlueStacks Wrong Size", "BlueStacks window is still the wrong size." & @CRLF & _
			"Please correct manually.")
		 Exit
	  EndIf
   EndIf

EndFunc

Func CheckIfBlueStacksIsRunning()
   ; Restore if minimized/maximized
   If BitAnd(WinGetState($gTitle), 16) Or BitAnd(WinGetState($gTitle), 32) Then
	  WinSetState($gTitle, "", @SW_RESTORE)
   EndIf

   ; Activate
   WinActivate($gTitle)
   Local $isActive = WinWaitActive($gTitle, "", 2)

   If $isActive Then
	  BlueStacksMoveWindow()
   Else
	  Local $res = MsgBox(BitOr($MB_YESNO, $MB_ICONQUESTION), "BlueStacks Not Running", _
	  "Cannot find or activate BlueStacks window." & @CRLF & @CRLF & _
	  "Should ClAsHbOt try to start BlueStacks?")

	  If $res = $IDNO Then
		 Exit
	  EndIf

	  BlueStacksStartLauncher()
   EndIf
EndFunc

Func FixBlueStacksSize()
   Local $res

   Local $hdQuit = """" & RegRead("HKLM\SOFTWARE\BlueStacks", "InstallDir") & "HD-Quit.exe" & """"
   DebugWrite("FixBlueStacksSize() BlueStacks HD Quit Path: " & $hdQuit)

   RunWait($hdQuit)

   If @error Then
	  MsgBox(BitOr($MB_OK, $MB_ICONERROR), "Error killing process", "Error killing BlueStacks processes." & @CRLF & _
	  "Please correct manually.")
	  DebugWrite("FixBlueStacksSize() Error killing BlueStacks processes: " & @error)
	  Exit
   EndIf

   ; Write correct registry entries
   Local $bsKeys[6] = ["Width", "Height", "WindowWidth", "WindowHeight", "GuestWidth", "GuestHeight"]
   Local $bsValues[6] = [$gBlueStacksWidth, $gBlueStacksHeight, $gBlueStacksWidth, $gBlueStacksHeight, $gBlueStacksWidth, $gBlueStacksHeight]
   Local $regError = False

   For $i = 0 To UBound($bsKeys)-1
	  $res = RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\BlueStacks\Guests\Android\FrameBuffer\0", $bsKeys[$i], "REG_DWORD", $bsValues[$i])
	  If $res=1 Then
		 DebugWrite("FixBlueStacksSize(), Wrote registry entry: HKEY_LOCAL_MACHINE\SOFTWARE\BlueStacks\Guests\Android\FrameBuffer\0\" & $bsKeys[$i] & " = " & $bsValues[$i])
	  Else
		 DebugWrite("FixBlueStacksSize(), ERROR writing registry entry: HKEY_LOCAL_MACHINE\SOFTWARE\BlueStacks\Guests\Android\FrameBuffer\0\" & $bsKeys[$i] & " = " & $bsValues[$i] & " Code: " & $res)
		 $regError = True
	  EndIf
   Next

   If $regError = True Then
	  DebugWrite("FixBlueStacksSize(), Error writing BlueStacks registry value(s)")
	  MsgBox(BitOr($MB_OK, $MB_ICONERROR), "Error writing registry", "Error writing BlueStacks registry value(s)" & @CRLF & _
		 "Please correct manually.")
	  Exit
   EndIf

   BlueStacksStartLauncher()
EndFunc

Func BlueStacksStartLauncher()
   ; Locate BS Launcher
   Local $hdLaunch = """" & RegRead("HKLM\SOFTWARE\BlueStacks", "InstallDir") & "HD-StartLauncher.exe" & """"
   DebugWrite("BlueStacksStartLauncher(), BlueStacks HD Launch Path: " & $hdLaunch)

   ; Start it up
   Local $blueStacksPID = Run($hdLaunch)
   If $blueStacksPID = 0 Then
	  DebugWrite("BlueStacksStartLauncher(), Error launching BlueStacks, @error=" & @error)
	  MsgBox($MB_OK, "BlueStacks Launch Error", "Error starting BlueStacks" & @CRLF & _
		 "Please manually start BlueStacks, then click OK.")
	  Return
   Else
	  DebugWrite("BlueStacksStartLauncher(), Launched BlueStacks, pid=" & $blueStacksPID)
   EndIf

   ; Wait 10 seconds for BlueStacks window
   Local $res = WinWait($gTitle, "", 10)

   If $res = 0 Then
	  DebugWrite("Time out launching BlueStacks")
	  MsgBox($MB_OK, "BlueStacks Launch Error", "Time out starting BlueStacks" & @CRLF & @CRLF & _
		 "Please manually start BlueStacks, then click OK.")
	  Return
   EndIf

   DebugWrite("BlueStacksStartLauncher(), BlueStacks started successfully.")

   BlueStacksMoveWindow()
EndFunc

Func BlueStacksMoveWindow()
   If _OsVersionTest($VER_GREATER_EQUAL, 10) Then
	  WinMove($gTitle, "", 0, 0)
   Else
	  WinMove($gTitle, "", 4, 4)
   EndIf
EndFunc

