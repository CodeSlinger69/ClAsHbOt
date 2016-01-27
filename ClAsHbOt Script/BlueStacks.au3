Func StartBlueStacks()
   ; Start Process
   While BlueStacksIsRunning() = False
	  Local $res = MsgBox(BitOr($MB_OKCANCEL, $MB_ICONQUESTION), "BlueStacks Not Running", _
	  "Click OK to start BlueStacks, Cancel to quit.")

	  If $res = $IDCANCEL Then Exit

	  BlueStacksStartLauncher()
   WEnd

   ; Check size
   Local $size = ControlGetPos($gTitle, "", $gAppClassInstance)

   While $size[2]<>$gBlueStacksWidth Or $size[3]<>$gBlueStacksHeight
	  Local $res = MsgBox(BitOr($MB_OKCANCEL, $MB_ICONQUESTION), "BlueStacks Wrong Size", "BlueStacks window is the wrong size." & @CRLF & _
		 "Click OK to resize, or Cancel to Exit.")

	  If $res = $IDCANCEL Then Exit

	  BlueStacksFixSize()

	  If BlueStacksStartLauncher() Then BlueStacksMoveWindow()

	  $size = ControlGetPos($gTitle, "", $gAppClassInstance)
   WEnd

   ; Arrange windows
   BlueStacksMoveWindow()

   ; Get window handle and control handle and save them
   $gBlueStacksHwnd = WinGetHandle($gTitle, "")

   If Not IsHWnd($gBlueStacksHwnd) Then
	  MsgBox(BitOr($MB_OK, $MB_ICONERROR), "BlueStacks Window Control Handle", "Error getting BlueStacks window Handle: " & @error & @CRLF & _
		 "Exiting.")
	  Exit
   EndIf
   DebugWrite("StartBlueStacks() hWnd: " & Hex($gBlueStacksHwnd))

   Local $t = TimerInit()
   Do
	  Sleep(10)
	  $gBlueStacksControlHwnd = ControlGetHandle($gBlueStacksHwnd, "", $gAppClassInstance)
   Until IsHWnd($gBlueStacksControlHwnd) Or TimerDiff($t)>5000

   If Not IsHWnd($gBlueStacksControlHwnd) Then
	  MsgBox(BitOr($MB_OK, $MB_ICONERROR), "BlueStacks Window Control Handle", "Error getting BlueStacks window control Handle: " & @error & @CRLF & _
		 "Exiting.")
	  Exit
   EndIf
   DebugWrite("StartBlueStacks() Control hWnd: " & Hex($gBlueStacksControlHwnd))

EndFunc

Func BlueStacksIsRunning()
   Local $hwnd = WinGetHandle($gTitle)
   If @error Then Return False

   ; Restore if minimized/maximized
   If BitAnd(WinGetState($hwnd), 16) Or BitAnd(WinGetState($hwnd), 32) Then WinSetState($hwnd, "", @SW_RESTORE)

   ; Activate
   WinActivate($hwnd)
   Local $isActive = WinWaitActive($hwnd, "", 2)

   If $isActive=0 Then Return False

   $gBlueStacksPID = WinGetProcess($gTitle)
   DebugWrite("StartBlueStacks() pid=" & $gBlueStacksPID)

   Return True
EndFunc

Func BlueStacksStartLauncher()
   ; Locate BS Launcher
   Local $hdLaunch = """" & RegRead("HKLM\SOFTWARE\BlueStacks", "InstallDir") & "HD-StartLauncher.exe" & """"
   DebugWrite("BlueStacksStartLauncher() BlueStacks HD Launch Path: " & $hdLaunch)

   ; Start it up
   If Run($hdLaunch) = 0 Then
	  DebugWrite("BlueStacksStartLauncher() Error launching BlueStacks, @error=" & @error)
	  Local $res = MsgBox(BitOr($MB_OK, $MB_ICONERROR), "BlueStacks Launch Error", "Error starting BlueStacks" & @CRLF & _
		 "Please manually start BlueStacks, then restart ClAsHbOt.")
	  Exit
   EndIf

   DebugWrite("BlueStacksStartLauncher(), Launched BlueStacks")

   ; Wait 10 seconds for BlueStacks window
   Local $hwnd = WinWait($gTitle, "", 10)

   If $hwnd = 0 Then
	  DebugWrite("BlueStacksStartLauncher() Time out launching BlueStacks, hWnd")
	  MsgBox(BitOr($MB_OK, $MB_ICONERROR), "BlueStacks Launch Error", "Time out starting BlueStacks" & @CRLF & @CRLF & _
		 "Please manually start BlueStacks, then restart ClAsHbOt.")
	  Exit
   EndIf

   ; Wait for Control
   Local $c
   Local $t = TimerInit()
   Do
	  Sleep(10)
	  $c = ControlGetHandle($hwnd, "", $gAppClassInstance)
   Until IsHWnd($c) Or TimerDiff($t)>5000

   If Not IsHWnd($c) Then
	  DebugWrite("BlueStacksStartLauncher() Time out launching BlueStacks, control hWnd")
	  MsgBox(BitOr($MB_OK, $MB_ICONERROR), "BlueStacks Launch Error", "Time out starting BlueStacks, waiting for Window control." & @CRLF & @CRLF & _
		 "Please manually start BlueStacks, then restart ClAsHbOt.")
	  Exit
   EndIf

   DebugWrite("BlueStacksStartLauncher(), BlueStacks started successfully.")

   Return True
EndFunc

Func BlueStacksFixSize()
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
EndFunc

Func BlueStacksMoveWindow()
   If _OsVersionTest($VER_GREATER_EQUAL, 10) Then
	  WinMove($gTitle, "", 0, 0)
   Else
	  WinMove($gTitle, "", 4, 4)
   EndIf
EndFunc
