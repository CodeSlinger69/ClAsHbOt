Func StartEmulator()
   ; See if an emulator is running
   Local $bsHwnd = WinGetHandle($gEmulatorData[$eEmulatorBlueStacks1][1])
   Local $bsError = @error
   If $bsError=0 Then DebugWrite("StartEmulator() BlueStacks emulator detected")

   Local $meHwnd = WinGetHandle($gEmulatorData[$eEmulatorMEmu][1])
   Local $meError = @error
   If $meError=0 Then DebugWrite("StartEmulator() MEmu emulator detected")

   ; If no emulators are running, then prompt
   If $bsError<>0 And $meError<>0 Then
	  DebugWrite("StartEmulator() No emulator detected")
	  MsgBox(BitOr($MB_OK, $MB_ICONWARNING), "Emulator not found", _
		 "No Android emulator was found. Please start either BlueStacks 1.x or MEmu 2.6.2+, then restart ClAsHbOt.")
	  Exit
   EndIf

   ; If both emulators are running, then prompt
   If $bsError=0 And $meError=0 Then
	  Local $res = _MsgBox($MB_YESNO, "Select Emulator", "Both BlueStacks and MEmu are running." & @CRLF & "Choose BlueStacks or MEmu.", _
		 -1, 0, "BlueStacks|MEmu")

	  $gSelectedEmulator = $res=$IDYES ? $eEmulatorBlueStacks1 : $eEmulatorMEmu
	  $gEmulatorHwnd = $res=$IDYES ? $bsHwnd : $meHwnd
	  DebugWrite("StartEmulator() Selected " & $gEmulatorData[$gSelectedEmulator][0] & " as emulator")
   Else
	  $gSelectedEmulator = $bsError=0 ? $eEmulatorBlueStacks1 : $eEmulatorMEmu
	  $gEmulatorHwnd = $bsError=0 ? $bsHwnd : $meHwnd
   EndIf

   DebugWrite("StartEmulator() " & $gEmulatorData[$gSelectedEmulator][0] & " hWnd: " & Hex($gEmulatorHwnd))

   ; Warning
   If $gSelectedEmulator = $eEmulatorMEmu Then
	  MsgBox(BitOr($MB_OK, $MB_ICONWARNING), "Using MEmu", _
		 "To use MEmu, the Android system bar must be put on the bottom of the screen.  Go to" & _
		 "Settings/Nav Bar Position, and choose 'Bottom'.")
   EndIf

   ; Restore emulator if minimized/maximized
   If BitAnd(WinGetState($gEmulatorHwnd), 16) Or BitAnd(WinGetState($gEmulatorHwnd), 32) Then WinSetState($gEmulatorHwnd, "", @SW_RESTORE)

   ; Activate emulator
   WinActivate($gEmulatorHwnd)
   Local $isActive = WinWaitActive($gEmulatorHwnd, "", 2)
   If $isActive=0 Then Return False

   $gEmulatorPID = WinGetProcess($gEmulatorHwnd)
   DebugWrite("StartEmulator() " & $gEmulatorData[$gSelectedEmulator][0] & " pid=" & $gEmulatorPID)

   ; Check size
   Local $size = ControlGetPos($gEmulatorData[$gSelectedEmulator][1], "", $gEmulatorData[$gSelectedEmulator][2])
   While $size[2]<>$gEmulatorData[$gSelectedEmulator][3] Or $size[3]<>$gEmulatorData[$gSelectedEmulator][4]
	  DebugWrite("StartEmulator() " & $gEmulatorData[$gSelectedEmulator][0] & " size is wrong. Expected: " & _
		 $gEmulatorData[$gSelectedEmulator][3] & "x" & $gEmulatorData[$gSelectedEmulator][4] & " Actual: " & _
		 $size[2] & "x" & $size[3] )
	  Local $res = MsgBox(BitOr($MB_OKCANCEL, $MB_ICONQUESTION), "Emulator Wrong Size", "Emulator window is the wrong size." & @CRLF & _
		 "Click OK to resize, or Cancel to Exit.")

	  If $res = $IDCANCEL Then Exit

	  Local $resSize = $gSelectedEmulator = $eEmulatorBlueStacks1 ? BlueStacksFixSize() : MEmuFixSize()
	  If $resSize = False Then
		 DebugWrite("StartEmulator() Error resizing emulator")
	  Else
		 Local $resStart = $gSelectedEmulator = $eEmulatorBlueStacks1 ? BlueStacksStartProcess() : MEmuStartProcess()
		 If $resStart = False Then
			DebugWrite("StartEmulator() Error restarting emulator")
		 Else
			$size = ControlGetPos($gEmulatorData[$gSelectedEmulator][1], "", $gEmulatorData[$gSelectedEmulator][2])
		 EndIf
	  EndIf
   WEnd

   ; Arrange windows
   Local $pixOffset = _OsVersionTest($VER_GREATER_EQUAL, 10) ? 0 : 4
   WinMove($gEmulatorHwnd, "", $pixOffset, $pixOffset)

   ; Get control handle
   Local $t = TimerInit()
   Do
	  Sleep(10)
	  $gEmulatorControlHwnd = ControlGetHandle($gEmulatorHwnd, "", $gEmulatorData[$gSelectedEmulator][2])
   Until IsHWnd($gEmulatorControlHwnd) Or TimerDiff($t)>5000

   If Not IsHWnd($gEmulatorControlHwnd) Then
	  DebugWrite("StartEmulator() Error getting Control hWnd: ")
	  MsgBox(BitOr($MB_OK, $MB_ICONERROR), "Emulator Window Control Handle", "Error getting Emulator window control handle: " & @error & @CRLF & _
		 "Exiting.")
	  Exit
   EndIf
   DebugWrite("StartEmulator() Control hWnd: " & Hex($gEmulatorControlHwnd))

EndFunc

Func BlueStacksKillProcess()
   DebugWrite("BlueStacksKillProcess() Killing BlueStacks processes")

   Local $hdQuit = """" & RegRead("HKLM\SOFTWARE\BlueStacks", "InstallDir") & "HD-Quit.exe" & """"
   DebugWrite("BlueStacksKillProcess() BlueStacks HD Quit Path: " & $hdQuit)

   Local $pid = Run($hdQuit, "", @SW_HIDE, $STDERR_MERGED)

   If $pid = 0 Then
	  DebugWrite("BlueStacksKillProcess() Error1 killing BlueStacks processes, @error=" & @error)
	  Return False
   EndIf

   Local $res = ProcessWaitClose($pid, 15000)
   Local $output = StdoutRead($pid)
   $output &= StderrRead($pid)

   If $res = 0 Then
	  ProcessClose($pid)
	  DebugWrite("BlueStacksKillProcess() Error2 killing BlueStacks processes, @error=" & @error)
	  Return False
   EndIf

   Return True
EndFunc

Func BlueStacksStartProcess()
   DebugWrite("BlueStacksStartProcess() Starting BlueStacks")

   ; Locate BS Launcher
   Local $hdLaunch = """" & RegRead("HKLM\SOFTWARE\BlueStacks", "InstallDir") & "HD-StartLauncher.exe" & """"
   DebugWrite("BlueStacksStartProcess() BlueStacks HD Launch Path: " & $hdLaunch)

   ; Start it up
   Local $pid = Run($hdLaunch)
   If $pid = 0 Then
	  DebugWrite("BlueStacksStartProcess() Error launching BlueStacks, @error=" & @error)
	  Local $res = MsgBox(BitOr($MB_OK, $MB_ICONERROR), "BlueStacks Launch Error", "Error starting BlueStacks" & @CRLF & _
		 "Please manually start BlueStacks, then restart ClAsHbOt.")
	  Exit
   EndIf

   DebugWrite("BlueStacksStartProcess(), Launched BlueStacks, pid=" & $pid)
   $gEmulatorPID = $pid

   ; Wait 10 seconds for BlueStacks window
   Local $hwnd = WinWait($gEmulatorData[$eEmulatorBlueStacks1][1], "", 10)

   If $hwnd = 0 Then
	  DebugWrite("BlueStacksStartProcess() Time out launching BlueStacks, hWnd")
	  MsgBox(BitOr($MB_OK, $MB_ICONERROR), "BlueStacks Launch Error", "Time out starting BlueStacks" & @CRLF & @CRLF & _
		 "Please manually start BlueStacks, then restart ClAsHbOt.")
	  Exit
   EndIf

   DebugWrite("BlueStacksStartProcess(), Launched BlueStacks, hwnd=" & Hex($hwnd))
   $gEmulatorHwnd = $hwnd

   DebugWrite("BlueStacksStartProcess(), BlueStacks started successfully.")

   Return True
EndFunc

Func BlueStacksFixSize()
   DebugWrite("BlueStacksFixSize() Resizing BlueStacks")

   If BlueStacksKillProcess() = False Then
	  DebugWrite("BlueStacksFixSize() Error killing BlueStacks process")
	  Return False
   EndIf

   ; Write correct registry entries
   Local $bsKeys[6] = ["Width", "Height", "WindowWidth", "WindowHeight", "GuestWidth", "GuestHeight"]
   Local $bsValues[6] = [$gEmulatorData[$gSelectedEmulator][3], $gEmulatorData[$gSelectedEmulator][4], _
						 $gEmulatorData[$gSelectedEmulator][3], $gEmulatorData[$gSelectedEmulator][4], _
						 $gEmulatorData[$gSelectedEmulator][3], $gEmulatorData[$gSelectedEmulator][4]]
   Local $regError = False

   For $i = 0 To UBound($bsKeys)-1
	  Local $res = RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\BlueStacks\Guests\Android\FrameBuffer\0", $bsKeys[$i], "REG_DWORD", $bsValues[$i])
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
		 "Please correct manually, then restart ClAsHbOt.")
	  Exit
   EndIf
EndFunc

Func MEmuKillProcess()
   DebugWrite("MEmuKillProcess() Killing MEmu process")

   ShellExecute(@WindowsDir & "\System32\taskkill.exe", "-f -t -pid " & $gEmulatorPID, "", Default, @SW_HIDE)
   Sleep(5000)

   If ProcessExists($gEmulatorPID) Then
	  DebugWrite("MEmuKillProcess() Error killing MEmu, @error=" & @error)
	  Return False
   EndIf

   Return True
EndFunc

Func MEmuStartProcess()
   DebugWrite("MEmuStartProcess() Starting MEmu")

   Local $launchPath = EnvGet("MEmu_Path") & "\MEmu"
   Local $launchCmd = $launchPath & "\MEmu.exe"
   DebugWrite("MEmuStartProcess() Command path: " & $launchCmd)

   Local $pid = ShellExecute($launchCmd, "MEmu", $launchPath)
   Sleep(1000)

   If $pid = 0 Then
	  DebugWrite("MEmuStartProcess() Error launching MEmu, @error=" & @error)
	  Local $res = MsgBox(BitOr($MB_OK, $MB_ICONERROR), "MEmu Launch Error", "Error starting MEmu" & @CRLF & _
		 "Please manually start MEmu, then restart ClAsHbOt.")
	  Exit
   EndIf

   DebugWrite("MEmuStartProcess() Launched MEmu, pid=" & $pid)
   $gEmulatorPID = $pid

   ; Wait 10 seconds for MEmu window
   Local $hwnd = WinWait($gEmulatorData[$eEmulatorMEmu][1], "", 10)

   If $hwnd = 0 Then
	  DebugWrite("MEmuStartProcess() Time out launching MEmu, hWnd")
	  MsgBox(BitOr($MB_OK, $MB_ICONERROR), "MEmu Launch Error", "Time out starting MEmu" & @CRLF & @CRLF & _
		 "Please manually start MEmu, then restart ClAsHbOt.")
	  Exit
   EndIf

   DebugWrite("MEmuStartProcess() Launched MEmu, hwnd=" & Hex($hwnd))
   $gEmulatorHwnd = $hwnd

   DebugWrite("MEmuStartProcess() MEmu started successfully.")

   Return True
EndFunc

Func MEmuFixSize()
   DebugWrite("MEmuFixSize() Resizing MEmu")

   If MEmuKillProcess() = False Then
	  DebugWrite("MEmuFixSize() Error killing MEmu process")
	  Return False
   EndIf

   Local $MEmuManage_Path = EnvGet("MEmuHyperv_Path") & "\MEmuManage.exe"
   ;DebugWrite("MEmuFixSize() MEmuManage path " & $MEmuManage_Path)

   Local $settings[4][2] = [ _
	  ["resolution_width", $gEmulatorData[$gSelectedEmulator][3]], _
	  ["resolution_height", $gEmulatorData[$gSelectedEmulator][4]], _
	  ["is_customed_resolution", 1], _
	  ["vbox_dpi", 160 ] ]

   For $i = 0 To UBound($settings)-1
	  Local $cmd = $MEmuManage_Path & " guestproperty set MEmu " & $settings[$i][0] & " " & $settings[$i][1]
	  DebugWrite("MEmuFixSize() " & $cmd)
	  Local $pid = Run($cmd, "", @SW_HIDE, $STDERR_MERGED)

	  If $pid = 0 Then
		 DebugWrite("MEmuFixSize() Error 1 setting " & $settings[$i][0] & ", @error=" & @error)
		 MsgBox(BitOr($MB_OK, $MB_ICONERROR), "Error 1 setting " & $settings[$i][0], _
			"Error setting MEmu " & $settings[$i][0] & @CRLF & _
			"Please correct manually, then restart ClAsHbOt.")
		 Exit
	  EndIf

	  Local $res = ProcessWaitClose($pid, 5000)
	  Local $output = StdoutRead($pid)
	  $output &= StderrRead($pid)

	  If $res = 0 Then
		 ProcessClose($pid)
		 DebugWrite("MEmuFixSize() Error 2 setting " & $settings[$i][0] & ", @error=" & @error & " output: " & $output)
		 MsgBox(BitOr($MB_OK, $MB_ICONERROR), "Error 2 setting " & $settings[$i][0], _
			"Error setting MEmu " & $settings[$i][0] & @CRLF & _
			"Please correct manually, then restart ClAsHbOt.")
		 Exit
	  EndIf

	  ;DebugWrite("MEmuFixSize() " & $settings[$i][0] & " adjusted")
   Next

   Return True
EndFunc

