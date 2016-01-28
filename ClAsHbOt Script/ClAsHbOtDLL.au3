Func DLLLoad()

   ; Open
   $gDllHandle = DllOpen("ImageMatch.dll")

   If $gDllHandle = -1 Then
	  DebugWrite("DLLLoad() Error loading DLL")
	  MsgBox(BitOr($MB_OK, $MB_ICONERROR), "DLLLoad Error", "Error loading DLL.  Exiting.")
	  Exit
   EndIf
   DebugWrite("DLLLoad() ImageMatch.dll Loaded")

   ; Initialize
   Local $res = DllCall($gDllHandle, "str", "Initialize", "str", @ScriptDir)
   If @error Then
	  DebugWrite("DLLLoad() DllCall Initialize @error=" & @error)
	  MsgBox(BitOR($MB_ICONERROR, $MB_OK), "ClAsHbOt DLL Error", "Error initializing DLL." & @CRLF & _
		 "This is catastrophic, exiting.")
	  Exit
   EndIf

   If $res[0] <> "Success" Then
	  DebugWrite("DLLLoad() Error initializing DLL")
	  MsgBox(BitOr($MB_OK, $MB_ICONERROR), "DLLLoad Error", "Error initializing DLL. $res=" & $res[0] & @CRLF & _
		 "This is catastrophic, exiting.")
	  Exit
   EndIf
   DebugWrite("DLLLoad() ImageMatch.dll Initialized: " & $res[0])

EndFunc

Func DLLUnload()
   DllClose($gDllHandle)
EndFunc

#cs
Func DLLStoreFrame(Const $f)
   Local $res = DllCall($gDllHandle, "str", "StoreFrame", "ptr", $f)
EndFunc
#ce