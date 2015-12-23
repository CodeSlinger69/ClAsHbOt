
Func StartBlueStacks()
   CheckIfBlueStacksIsRunning()

   Local $clientPos = GetClientPos()
   If $clientPos[2]-$clientPos[0]+1<>$gBlueStacksWidth Or $clientPos[3]-$clientPos[1]+1<>$gBlueStacksHeight Then
	  Local $res = MsgBox(BitOr($MB_OKCANCEL, $MB_ICONQUESTION), "BlueStacks Wrong Size", "BlueStacks window is the wrong size." & @CRLF & _
		 "Click OK to resize, or Cancel to Exit." & @CRLF & @CRLF & _
		 "Note: If you are on Windows 10, automatic resize will not work.  Please Cancel, then use the .reg file in the " & _
		 "BlueStacks folder to change to the correct resolution.  You will need to manually kill all BlueStacks processes " & _
		 "(beginning with 'HD-') prior to applying the .reg file.")

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
	  WinMove($gTitle, "", 4, 4)
   Else
	  MsgBox(BitOr($MB_OK, $MB_ICONERROR), "BlueStacks Not Running", "Cannot find or activate BlueStacks window." & @CRLF & @CRLF & "Exiting.")
	  Exit
   EndIf
EndFunc

Func FixBlueStacksSize()
   Local $res

   ; Stop service
   DebugWrite("Stopping BlueStacks process: BstHdAndroidSvc")
   RunWait(@ComSpec & " /c " & 'net stop BstHdAndroidSvc', "", @SW_HIDE)

   ; Kill processes
   Local $bsProcesses[7] = ["HD-Service.exe", "HD-FrontEnd.exe", "HD-Agent.exe", "HD-BlockDevice.exe", "HD-Network.exe", _
						    "HD-SharedFolder.exe", "HD-UpdaterService.exe"]

   For $i = 0 To UBound($bsProcesses)-1

	  If ProcessExists($bsProcesses[$i]) Then
		 $res = ProcessClose($bsProcesses[$i])
		 If $res<>1 Then
			DebugWrite("Error killing BlueStacks process: " & $bsProcesses[$i] & " Code: " & $res)
			MsgBox(BitOr($MB_OK, $MB_ICONERROR), "Error killing process", "Error killing BlueStacks process: " & $bsProcesses[$i] & @CRLF & _
			   "Please correct manually.")
			Exit
		 Else
			DebugWrite("Killed BlueStacks process: " & $bsProcesses[$i])
		 EndIf
	  EndIf
   Next

   ; Write correct registry entries
   Local $bsKeys[6] = ["Width", "Height", "WindowWidth", "WindowHeight", "GuestWidth", "GuestHeight"]
   Local $bsValues[6] = [$gBlueStacksWidth, $gBlueStacksHeight, $gBlueStacksWidth, $gBlueStacksHeight, $gBlueStacksWidth, $gBlueStacksHeight]
   Local $regError = False

   For $i = 0 To UBound($bsKeys)-1
	  $res = RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\BlueStacks\Guests\Android\FrameBuffer\0", $bsKeys[$i], "REG_DWORD", $bsValues[$i])
	  If $res=1 Then
		 DebugWrite("Wrote registry entry: HKEY_LOCAL_MACHINE\SOFTWARE\BlueStacks\Guests\Android\FrameBuffer\0\" & $bsKeys[$i] & " = " & $bsValues[$i])
	  Else
		 DebugWrite("ERROR writing registry entry: HKEY_LOCAL_MACHINE\SOFTWARE\BlueStacks\Guests\Android\FrameBuffer\0\" & $bsKeys[$i] & " = " & $bsValues[$i] & " Code: " & $res)
		 $regError = True
	  EndIf
   Next

   If $regError = True Then
	  DebugWrite("Error writing BlueStacks registry value(s)")
	  MsgBox(BitOr($MB_OK, $MB_ICONERROR), "Error writing registry", "Error writing BlueStacks registry value(s)" & @CRLF & _
		 "Please correct manually.")
	  Exit
   EndIf

   ; Locate BS Launcher
   DebugWrite("Restarting BlueStacks.")
   Local $blueStacksLauncherPath = _FileListToArrayRec(@ProgramFilesDir, "HD-StartLauncher.exe", $FLTAR_FILES, _
													   $FLTAR_RECUR, $FLTAR_NOSORT, $FLTAR_FULLPATH)

   If $blueStacksLauncherPath[0] = 0 Then
	  DebugWrite("Unable to locate BlueStacks launcher in " & @ProgramFilesDir)
	  MsgBox($MB_OK, "BlueStacks Launcher Not Found", "Restarting BlueStacks" & @CRLF & @CRLF & _
		 "Cannot locate BlueStacks launcher in " & @ProgramFilesDir & @CRLF & _
		 "Please manually start BlueStacks, then click OK.")
	  Return

   ElseIf $blueStacksLauncherPath[0] > 1 Then
	  DebugWrite("Found multiple BlueStacks launchers in " & @ProgramFilesDir)
	  MsgBox($MB_OK, "Multiple BlueStacks Launchers Found", "Restarting BlueStacks" & @CRLF & @CRLF & _
		 "Found multiple BlueStacks launchers in " & @ProgramFilesDir & @CRLF & _
		 "Please manually start BlueStacks, then click OK.")
	  Return
   EndIf

   ; Found a single BlueStacks launcher, start it up
   Local $sDrive = "", $sDir = "", $sFilename = "", $sExtension = ""
   Local $aPathSplit = _PathSplit($blueStacksLauncherPath[1], $sDrive, $sDir, $sFilename, $sExtension)

   Local $blueStacksPID = Run($blueStacksLauncherPath[1], $sDrive & $sDir)
   If $blueStacksPID = 0 Then
	  DebugWrite("Error launching BlueStacks, @error=" & @error)
	  MsgBox($MB_OK, "BlueStacks Launch Error", "Error starting BlueStacks" & @CRLF & _
		 "Please manually start BlueStacks, then click OK.")
	  Return
   Else
	  DebugWrite("Launched BlueStacks, pid=" & $blueStacksPID)
   EndIf

   ; Wait 10 seconds for BlueStacks window
   $res = WinWait($gTitle, "", 10)

   If $res = 0 Then
	  DebugWrite("Time out launching BlueStacks")
	  MsgBox($MB_OK, "BlueStacks Launch Error", "Time out starting BlueStacks" & @CRLF & @CRLF & _
		 "Please manually start BlueStacks, then click OK.")
	  Return
   EndIf

   DebugWrite("BlueStacks started successfully.")

   Sleep(1000)
EndFunc
