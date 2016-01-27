Func DLLLoad()
   ;$gDllHandle = DllOpen("ClAsHbOt.dll")
   $gDllHandle = DllOpen("ImageMatch.dll")

   If $gDllHandle = -1 Then
	  DebugWrite("DLLLoad() Error loading DLL")
	  MsgBox(BitOr($MB_OK, $MB_ICONERROR), "DLLLoad Error", "Error loading DLL.  Exiting.")
	  Exit
   EndIf
   DebugWrite("DLLLoad() ImageMatch.dll Loaded")

#cs
   Local $res = DllCall($gDllHandle, "str", "Initialize", "wstr", @ScriptDir)
   If $res[0] <> "Success" Then
	  DebugWrite("DLLLoad() Error initializing DLL")
	  MsgBox(BitOr($MB_OK, $MB_ICONERROR), "DLLLoad Error", "Error initializing DLL.  Exiting.")
	  Exit
   EndIf
   DebugWrite("DLLLoad() ImageMatch.dll Initialized: " & $res[0])
#ce

EndFunc

Func DLLUnload()
   DllClose($gDllHandle)
EndFunc

#cs
Func DLLStoreFrame(Const $f)
   Local $res = DllCall($gDllHandle, "str", "StoreFrame", "ptr", $f)
EndFunc
#ce