; Many thanks to mybot.run
; Much of the code in this file is influenced by their work
Func GetVmInfo()
   Local $MEmuManage_Path = EnvGet("MEmuHyperv_Path") & "\MEmuManage.exe"
   Local $cmd = $MEmuManage_Path & " showvminfo MEmu"

   Local $pid = Run($cmd, "", @SW_HIDE, $STDERR_MERGED)

   If $pid = 0 Then
	  DebugWrite("GetVmInfo() Error 1 showvminfo, @error=" & @error)
	  Return ""
   EndIf

   Local $res = ProcessWaitClose($pid, 5000)
   Local $output = StdoutRead($pid)
   $output &= StderrRead($pid)

   Return $output
EndFunc

Func VirtualBoxQueryAdbShellProcesses()
   #cs
   ; Find UUID
   Local $vminfo = GetVmInfo()
   Local $regEx = StringRegExp($vminfo, "UUID:\s+(.+)", $STR_REGEXPARRAYMATCH)
   Local $uuid = Not @error ? $regEx[0] : ""
   If StringLen($uuid) < 32 Then
	  DebugWrite("VirtualBoxGetPid() Error UUID, @error=" & @error & " UUID=" & $uuid)
	  Return 0
   EndIf

   DebugWrite("VirtualBoxGetPid() UUID=" & $uuid)
   #ce

   ; Query extended process information for UUID
   Local $oWMI = ObjGet("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
   If @error<>0 Then
	  DebugWrite("VirtualBoxGetAdbPid() Cannot create object, @error=" & @error)
	  Return 0
   EndIf

   Local $query = "Select * From Win32_Process Where ExecutablePath Like ""%MEmu%adb.exe%"" And CommandLine Like ""%shell%"" "
   Local $oProcessColl = $oWMI.ExecQuery($query)

   If $oProcessColl.Count() > 0 Then
	  DebugWrite("VirtualBoxGetAdbPid() Query: " & $query)
   EndIf

   Return $oProcessColl
EndFunc

Func VirtualBoxGetAdbShellPid()
   Local $oProcessColl = VirtualBoxQueryAdbShellProcesses()
   Local $Process, $adbShellPid = 0

   For $Process In $oProcessColl
	  DebugWrite("VirtualBoxGetAdbShellPid() Record: " & $Process.Handle & " = " & $Process.ExecutablePath & " (" & $Process.CommandLine & ")")
	  $adbShellPid = Number($Process.Handle)
   Next

   ;DebugWrite("VirtualBoxGetAdbShellPid() pid=" & $adbShellPid)
   Return $adbShellPid
EndFunc

Func VirtualBoxCloseAdbShellProcesses()
   Local $oProcessColl = VirtualBoxQueryAdbShellProcesses()
   Local $allKilled = True

   For $Process In $oProcessColl
	  DebugWrite("VirtualBoxCloseAdbShellProcesses() Record: " & $Process.Handle & " = " & $Process.ExecutablePath & " (" & $Process.CommandLine & ")")
	  ProcessWaitClose(Number($Process.Handle), 2)
	  If ProcessExists(Number($Process.Handle)) Then
		 DebugWrite("VirtualBoxCloseAdbShellProcesses() Close failed, using taskkill on " & $Process.Handle)
		 ShellExecute(@WindowsDir & "\System32\taskkill.exe", "-f -t -pid " & Number($Process.Handle), "", Default, @SW_HIDE)
		 Sleep(3000)
		 If ProcessExists(Number($Process.Handle)) Then
			DebugWrite("VirtualBoxCloseAdbShellProcesses() Close failed again, process likely hung")
			$allKilled = False
		 EndIf
	  EndIf
   Next

   $gAdbShellPid = 0
   $gAdbMouseDevice = ""
   $gAdbScreenCapPathHost = ""
   $gAdbScreenCapPathAndroid = ""

   Return $allKilled
EndFunc

Func AdbGetMouseDevice()
   ; Get mouse device
   Local $res = AdbSendShellCommand("getevent -p")
   ;DebugWrite("AdbStartShell() getevent -p: " & $res)

   Local $mouseDevice = ""
   Local $regEx = StringRegExp($res, "(\/dev\/input\/event\d+)[\r\n]+.+""Microvirt Virtual Input""", $STR_REGEXPARRAYMATCH)
   If @error = 0 Then
	  $mouseDevice = $regEx[0]
	  DebugWrite("AdbStartShell() Using " & $mouseDevice & " for mouse events")
   Else
	  DebugWrite("AdbStartShell() Can't use MEmu's 'Microvirt Virtual Input' for mouse events")
   EndIf

   Return $mouseDevice
EndFunc

Func AdbStartShell()
   ; Have we already started a shell, or determined the currently running shell?
   If $gAdbShellPid <> 0 And ProcessExists($gAdbShellPid) = $gAdbShellPid Then
	  Return True
   EndIf

   ; Get screencap path?
   If $gAdbScreenCapPathHost = "" Then
	  Local $vminfo = GetVmInfo()
	  Local $regEx = StringRegExp($vminfo, "Name: 'picture', Host path: '(.*)'.*", $STR_REGEXPARRAYMATCH)
	  $gAdbScreenCapPathHost = ""
	  $gAdbScreenCapPathAndroid = ""
	  If Not @error Then
		 $gAdbScreenCapPathHost = $regEx[0] & "\ClAsHbOt"
		 $gAdbScreenCapPathAndroid = "/mnt/shell/emulated/0/Pictures/ClAsHbOt"
		 DebugWrite("AdbStartShell() ScreenCap Path=" & $gAdbScreenCapPathHost)
		 If Not FileExists($gAdbScreenCapPathHost) Then DirCreate($gAdbScreenCapPathHost)
	  Else
		 DebugWrite("AdbStartShell() ScreenCap Path not found")
	  EndIf
   EndIf

   ; Is there a current shell running for this device?
   Local $existingAdbShellPid = VirtualBoxGetAdbShellPid()
   If $existingAdbShellPid <> 0 Then
	  DebugWrite("AdbStartShell() Found existing ADB Shell, pid=" & $existingAdbShellPid)
	  $gAdbShellPid = $existingAdbShellPid

	  If $gAdbMouseDevice = "" Then $gAdbMouseDevice = AdbGetMouseDevice()
	  Return True
   EndIf

   ;
   ; Start ADB Shell
   ;
   Local $launchPath = EnvGet("MEmu_Path") & "\MEmu"
   Local $launchCmd = $launchPath & "\adb.exe"
   DebugWrite("AdbStartShell() Command path: " & $launchCmd)

   ; Find adb device host IP
   Local $vminfo = GetVmInfo()
   ;DebugWrite("AdbStartShell() vminfo" & @CRLF & $vminfo)
   Local $regEx = StringRegExp($vminfo, "name = ADB.*host ip = ([^,]+),", $STR_REGEXPARRAYMATCH)
   Local $adbDeviceHostIP = ""
   If Not @error Then
	  $adbDeviceHostIP = $regEx[0]
	  ;DebugWrite("AdbStartShell() Device Host IP=" & $adbDeviceHostIP)
   Else
	  DebugWrite("AdbStartShell() Device Host IP not found")
	  Return False
   EndIf

   ; Find adb device host port
   Local $regEx = StringRegExp($vminfo, "name = ADB.*host port = (\d{3,5}),", $STR_REGEXPARRAYMATCH)
   Local $adbDeviceHostPort = ""
   If Not @error Then
	  $adbDeviceHostPort = $regEx[0]
	  ;DebugWrite("AdbStartShell() Device Host Port=" & $adbDeviceHostPort)
   Else
	  DebugWrite("AdbStartShell() Device Host Port not found")
	  Return False
   EndIf

   Local $adbDevice = $adbDeviceHostIP & ":" & $adbDeviceHostPort
   DebugWrite("AdbStartShell() Device=" & $adbDevice)

   ; Start an adb shell; try for 15 seconds, in case MEmu is booting up from a restart
   Local $t = TimerInit()
   While TimerDiff($t) < 15000 And $gAdbShellPid = 0
	  Local $output = RunCmdShell($launchCmd & " -s " & $adbDevice & " shell", $gAdbShellPid, 3000)
	  DebugWrite("AdbStartShell() " & 15000-Round(TimerDiff($t)) & " pid: " & $gAdbShellPid & " Output: " & $output)
	  Sleep(1000)
   WEnd

   ; Did we get a shell?
   DebugWrite("AdbStartShell() pid compare: " & $gAdbShellPid & " = " & ProcessExists($gAdbShellPid))
   If $gAdbShellPid = 0 Or ProcessExists($gAdbShellPid) <> $gAdbShellPid Then
	  _GUICtrlButton_SetCheck($GUI_BackgroundModeCheckBox, False)

	  DebugWrite("AdbStartShell() Background mode disabled")
	  Local $res = MsgBox(BitOR($MB_OK, $MB_ICONINFORMATION), "Background mode disabled", _
		 "Background mode has been disabled, as it appears to not be working." & @CRLF & @CRLF & _
		 "This is a problem with MEmu and its ADB shell." & @CRLF & _
		 "Since ClAsHbOt is now operating in the foreground, the MEmu window must be visible " & _
		 "and not obscured at any time.")
	  Return False
   EndIf

   DebugWrite("AdbStartShell() Shell started & background mode enabled, pid=" & $gAdbShellPid)

   ; Set prompt for detection in command output
   AdbSendShellCommand("PS1=" & $gAdbPrompt)

   ; Increase ADB shell priority
   Local $res = AdbSendShellCommand("/system/xbin/renice -20 $$")
   If StringInStr($res, "not found") > 0 Then AdbSendShellCommand("renice -- -20 $$")
   DebugWrite("AdbStartShell() Shell renice'd")

   ; Stop media service ; commented out due to causing sound problems
   ;AdbSendShellCommand("stop media")
   ;DebugWrite("AdbStartShell() Media service stopped")

   ; Set mouse device
   If $gAdbMouseDevice = "" Then $gAdbMouseDevice = AdbGetMouseDevice()

   Return True
EndFunc

Func RunCmdShell(Const $cmd, ByRef $pid, Const $timeout=10000, Const $killWhenDone = False)
   Local $output = ""
   $pid = 0

   Local $cmdPid = Run($cmd, "", @SW_HIDE, BitOR($STDIN_CHILD, $STDERR_MERGED))
   If $cmdPid = 0 Then
	  $output = "error " & @error
	  Return $output
   EndIf

   ProcessWaitClose($cmdPid, Round($timeout/1000))
   $output &= StdoutRead($cmdPid)
   $output &= StderrRead($cmdPid)

   ; Clean output
   $output = StringReplace($output, @CR & @CR, "")
   $output = StringReplace($output, @CRLF & @CRLF, "")
   If StringRight($output, 1) = @LF Then $output = StringLeft($output, StringLen($output) - 1)
   If StringRight($output, 1) = @CR Then $output = StringLeft($output, StringLen($output) - 1)

   If $killWhenDone Then
	  If ProcessExists($cmdPid) Then ProcessClose($cmdPid)
	  StdioClose($cmdPid)
   Else
	  If ProcessExists($cmdPid) Then $pid = $cmdPid
   EndIf

   Return $output
EndFunc

Func AdbSendShellCommand(Const $cmd, Const $timeout=3000)
   Local $timer = TimerInit()
   Local $sentBytes = 0

   StdoutRead($gAdbShellPid) ; Purge output
   Local $sentBytes = StdinWrite($gAdbShellPid, $cmd & @LF)

   Local $output = ""
   While TimerDiff($timer) < $timeout And @error = 0 And StringRight($output, StringLen($gAdbPrompt) + 1) <> @LF & $gAdbPrompt
	  Sleep(25)
	  $output &= StdoutRead($gAdbShellPid)
   WEnd

   If TimerDiff($timer) >= $timeout Then $output &= "timeout"

   ; Clean up the output
   Local $i = StringInStr($output, @LF)
   If $i > 0 Then $output = StringMid($output, $i) ; remove echo'd command
   If StringRight($output, StringLen($gAdbPrompt) + 1) = @LF & $gAdbPrompt Then $output = StringLeft($output, StringLen($output) - StringLen($gAdbPrompt) - 1) ; remove tailing prompt
   $output = StringReplace($output,  @CR & @CR, "")
   $output = StringReplace($output,  @CRLF & @CRLF, "")
   If StringRight($output, 1) = @LF Then $output = StringLeft($output, StringLen($output) - 1)
   If StringRight($output, 1) = @CR Then $output = StringLeft($output, StringLen($output) - 1)
   If StringLeft($output, 1) = @LF Then $output = StringMid($output, 2) ; remove starting @LF

   Return $output
EndFunc

