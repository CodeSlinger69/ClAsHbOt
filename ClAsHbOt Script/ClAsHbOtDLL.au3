Func DLLLoad()
   $gDllHandle = DllOpen("ClAsHbOt.dll")
   If $gDllHandle = -1 Then
	  DebugWrite("DLLLoad() Error loading DLL")
	  MsgBox(BitOr($MB_OK, $MB_ICONERROR), "DLLLoad Error", "Error loading DLL.  Exiting.")
	  Exit
   EndIf
   DebugWrite("DLLLoad() ClAsHbOt.dll Loaded")

   Local $res = DllCall($gDllHandle, "str", "Initialize", "wstr", @ScriptDir)
   If $res[0] <> "Success" Then
	  DebugWrite("DLLLoad() Error initializing DLL")
	  MsgBox(BitOr($MB_OK, $MB_ICONERROR), "DLLLoad Error", "Error initializing DLL.  Exiting.")
	  Exit
   EndIf
   DebugWrite("DLLLoad() ClAsHbOt.dll Initialized: " & $res[0])
EndFunc

Func DLLUnload()
   DllClose($gDllHandle)
EndFunc

Func DLLStoreFrame(Const $f)
   Local $res = DllCall($gDllHandle, "str", "StoreFrame", "ptr", $f)
EndFunc
