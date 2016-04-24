; #INDEX# =======================================================================================================================
; Title .........: _MsgBox.au3
; AutoIt Version.: 3.2.12++
; Language.......: English
; Description ...: Modified Autoit MsgBox. (Based on new EzSkin_PreProcessor.au3)
; Author ........: João Carlos (jscript)
; ===============================================================================================================================

; MsgBoxHookEx
Global $s_MSGBOX_STRUCT = DllStructCreate("long hWndOwner;long hHook")
Global $h_MSGBOX_CALLBACK = DllCallbackRegister("__MsgBoxHook", "long", "long;long;long")
Global $a_MSGBOXHOOK_WINSIZE
Global $a_MSGBOXHOOK_CTRLPOS

;_MsgBox(6,'Title','TEST',-1,0,"You|NEED|3BUTTONS")
;Exit

; #FUNCTION# ====================================================================================================================
; Name...........: _MsgBox
; Description ...: Displays a simple message box with optional timeout.
; Syntax.........: ;_MsgBox( flag, "title", "text" [, timeout [, hwnd [, ownButtons [, FileName [, ResName [, ResType _
;                           [, left [, top [, allwaysActive ]]]]]]]]] )
; Parameters ....: OwnButtons   - [optional] Personalized texts for the buttons. If it be used more than a button, separate the texts with "|".
;                  FileName     - Filename of the picture or resource to be loaded, supported types: BMP, JPG, PNG, GIF(animated).
;                  ResName      - [optional] The name of resource to be load from EXE, DLL, OCX, CPL and other formats.
;                  ResType      - [optional] The type of resource to be load. Default is 10: $RT_RCDATA.
;                  left         - [optional] The left side of the dialog box. By default (-1), the window is centered.
;                  top          - [optional] The top of the dialog box. Default (-1) is centered.
;                  allwaysActive- [optional] The dialog box will be placed above all Topmost windows and should stay above them.
;                                 The window is NOT DEACTIVATED.
;                  Other parameters, same as MsgBox function.
; Return values .: Success  - Returns the ID of the button pressed.
;                  Failure  - Returns -1 if the message box timed out.
;                             If error, returns an friendly message and exit script.
; Author ........: jscript
; Modified.......:
; Remarks .......: Same as MsgBox function.
;                  Version 2.6  - It shows the countdown if the variable timeout be specified.
;                  Based on the original XSkinMsgBox - Created by Valuater.
; Related .......:
; Link ..........;
; Example .......; _MsgBox(4096, "Test", "This box will time out in 10 seconds", 10)
; ===============================================================================================================================
Func _MsgBox($fFlag, $sTitle = "", $sText = "", $iTimeOut = -1, $hHwnd = 0, $sOwnButtons = "", $sFileName = "", $vResName = -1, _
        $vResType = -1, $iLeft = -1, $iTop = -1, $fAllwaysActive = False)
    ; Related GUI
    Local $aDllCall, $hInstance
    If $hHwnd = 0 Or $hHwnd = "" Then
        $aDllCall = DllCall("kernel32.dll", "hwnd", "GetModuleHandle", "ptr", 0)
        $hInstance = $aDllCall[0]
    Else
        $aDllCall = DllCall("User32.dll", "int", "GetWindowLong", "hwnd", $hHwnd, "int", 0xFFFFFFFA)
        $hInstance = $aDllCall[0]
    EndIf

    $aDllCall = DllCall("Kernel32.dll", "int", "GetCurrentThreadId")
    Local $hThreadId = $aDllCall[0]
    $aDllCall = DllCall("User32.dll", "hwnd", "GetDesktopWindow")
    Local $hWndOwner = $aDllCall[0]

    DllStructSetData($s_MSGBOX_STRUCT, "hWndOwner", $hWndOwner)
    $aDllCall = DllCall("user32.dll", "hwnd", "SetWindowsHookEx", "int", 5, "ptr", DllCallbackGetPtr($h_MSGBOX_CALLBACK), "hwnd", $hInstance, "dword", $hThreadId)
    DllStructSetData($s_MSGBOX_STRUCT, "hHook", $aDllCall[0])
    DllCall("user32.dll", "long", "MessageBox", "long", $hWndOwner, "str", $sText, "str", $sTitle, "long", $fFlag)

    Local $iWidth = -1, $iHeight = -1
    If IsArray($a_MSGBOXHOOK_WINSIZE) Then
        $iWidth = $a_MSGBOXHOOK_WINSIZE[0]
        $iHeight = $a_MSGBOXHOOK_WINSIZE[1]
        $a_MSGBOXHOOK_WINSIZE = 0
    EndIf
    Local $iStyleEx = -1, $iStyle = BitOR(0x80000000, 0x00C00000, 0x00080000), $hWinHandle, $iMsg, $sChoice

    ; Related Title and Text
    Local $bTextStyle = 0x0000, $iTextLeft, $iTextTop = 11
    Local $aTextWidth = 406, $iTextHeight = 432
    If IsArray($a_MSGBOXHOOK_CTRLPOS) Then
        $iTextLeft = $a_MSGBOXHOOK_CTRLPOS[0]
        $iTextTop = $a_MSGBOXHOOK_CTRLPOS[1]
        $aTextWidth = $a_MSGBOXHOOK_CTRLPOS[2]
        $iTextHeight = $a_MSGBOXHOOK_CTRLPOS[3]
        $a_MSGBOXHOOK_CTRLPOS = 0
    EndIf

    ; Related Icons
    Local $iIconIndex = 0, $fIconClose = False, $fIconClosePress = True, $fModalIcon = False

    ; Related buttons
    Local $iButton1, $iButton2 = -1, $iButton3 = -1, $iDefButton, $iBtnLeft, $iBtnTop, $sSplitOwnBtn
    Local $sOK, $sCancel, $sAbort, $sRetry, $sIgnore, $sYES, $sNO, $sTryAgain, $sContinue

    ; Miscelaneous
    Local $iTimer, $iOffset = 15, $fVeryFlag = 0, $lError = True, $iEnd
    If $iTimeOut < 1 Then $iTimeOut = 2147483647

    ;$fFlag = Dec($fFlag)
    ;-------- Get the $Flag numbers
    ; Search for = Icon Index
    If BitAND($fFlag, 48) == 48 Then
        $fVeryFlag = 48
        $iOffset = 64
        $iIconIndex = 101 ; Exclamation-point icon
    ElseIf BitAND($fFlag, 16) == 16 Then
        $fVeryFlag = 16
        $iOffset = 64
        $iIconIndex = 103 ; Stop-sign icon
    ElseIf BitAND($fFlag, 32) == 32 Then
        $fVeryFlag = 32
        $iOffset = 64
        $iIconIndex = 102 ; Question-mark icon
    ElseIf BitAND($fFlag, 64) == 64 Then
        $fVeryFlag = 64
        $iOffset = 64
        $iIconIndex = 104 ; Information-sign icon
    EndIf

    ; Get Default Buttons
    If BitAND($fFlag, 256) == 256 Then $fVeryFlag += 256
    If BitAND($fFlag, 512) == 512 Then $fVeryFlag += 512

    ; Search for = System Modal
    If BitAND($fFlag, 4096) == 4096 Then
        $fVeryFlag += 4096
        $fModalIcon = True
        $iStyleEx = 0x00000008
        ;$iStyle = BitOr(0x00C00000, 0x80000000, 0x00080000)
    EndIf
    ; Search for = Task Modal
    If BitAND($fFlag, 8192) == 8192 Then
        $fVeryFlag += 8192
        $fIconClosePress = False
        ;$iStyle = 0x00C00000
    EndIf
    ; Search for = Topmost flag
    If BitAND($fFlag, 262144) == 262144 Then
        $fVeryFlag += 262144
        $iStyleEx = 0x00000008
    EndIf
    ; Search for = Right-Justified
    If BitAND($fFlag, 524288) == 524288 Then
        $fVeryFlag += 524288
        $iStyle = BitOR($iStyle, 0x0002)
        $bTextStyle = BitOR($bTextStyle, 0x0002)
    EndIf

    ; Compare Buttons
    If $fFlag = $fVeryFlag Then $lError = False
    If $fFlag = $fVeryFlag + 1 Then $lError = False
    If $fFlag = $fVeryFlag + 2 Then $lError = False
    If $fFlag = $fVeryFlag + 3 Then $lError = False
    If $fFlag = $fVeryFlag + 4 Then $lError = False
    If $fFlag = $fVeryFlag + 5 Then $lError = False
    If $fFlag = $fVeryFlag + 6 Then $lError = False

    ; If error found in $Flag
    If $lError Then MsgBox(4096, "Error", "_MsgBox(" & $fFlag & " ^ ", 0)

    ;---- Creates the Gui
    If $hHwnd <> "" Then $iStyle = BitOR(0x40000000, 0x00C00000, 0x00080000)

    Local $iCoordMode = Opt("GUICoordMode", 1), $iEventMode = Opt("GUIOnEventMode", 0)
    $hWinHandle = GUICreate($sTitle, $iWidth, $iHeight, $iLeft, $iTop, $iStyle, $iStyleEx, $hHwnd)
    GUISwitch($hWinHandle)

    $iBtnLeft = Int($iWidth / 2)
    $iBtnTop = ($iHeight - 29)
    ; Cancel, Try Again, Continue
    If BitAND($fFlag, 6) == 6 Then
        If $sOwnButtons <> "" Then
            $sSplitOwnBtn = StringSplit($sOwnButtons, "|")
            ; If error found
            If $sSplitOwnBtn[0] <> 3 Then MsgBox(4096, "Error", "_MsgBox(" & $fFlag & " ... " & '"' & $sOwnButtons & '"' & " ^ ", 0)
            $sCancel = $sSplitOwnBtn[1]
            $sTryAgain = $sSplitOwnBtn[2]
            $sContinue = $sSplitOwnBtn[3]
        Else
            $sCancel = "Cancel"
            $sTryAgain = "Retry"
            $sContinue = "Continue"
        EndIf
        $iButton1 = GUICtrlCreateButton($sCancel, $iBtnLeft - 131.5, $iBtnTop, 86, 23, -1, 0x00080000)
        $iButton2 = GUICtrlCreateButton($sTryAgain, $iBtnLeft - 43, $iBtnTop, 86, 23, -1, 0x00080000)
        $iButton3 = GUICtrlCreateButton($sContinue, $iBtnLeft + 45.5, $iBtnTop, 86, 23, -1, 0x00080000)

        ; Retry, Cancel
    ElseIf BitAND($fFlag, 5) == 5 Then
        If $sOwnButtons <> "" Then
            $sSplitOwnBtn = StringSplit($sOwnButtons, "|")
            ; If error found
            If $sSplitOwnBtn[0] <> 2 Then MsgBox(4096, "Error", "_MsgBox(" & $fFlag & " ... " & '"' & $sOwnButtons & '"' & " ^ ", 0)
            $sRetry = $sSplitOwnBtn[1]
            $sCancel = $sSplitOwnBtn[2]
        Else
            $sRetry = "Retry"
            $sCancel = "Cancel"
        EndIf
        $iButton1 = GUICtrlCreateButton($sRetry, $iBtnLeft - 88.5, $iBtnTop, 86, 23, -1, 0x00080000)
        $iButton2 = GUICtrlCreateButton($sCancel, $iBtnLeft + 2.5, $iBtnTop, 86, 23, -1, 0x00080000)

        ; Yes, No
    ElseIf BitAND($fFlag, 4) == 4 Then
        If $sOwnButtons <> "" Then
            $sSplitOwnBtn = StringSplit($sOwnButtons, "|")
            ; If error found
            If $sSplitOwnBtn[0] <> 2 Then MsgBox(4096, "Error", "_MsgBox(" & $fFlag & " ... " & '"' & $sOwnButtons & '"' & " ^ ", 0)
            $sYES = $sSplitOwnBtn[1]
            $sNO = $sSplitOwnBtn[2]
        Else
            $sYES = "Yes"
            $sNO = "No"
        EndIf
        $iButton1 = GUICtrlCreateButton($sYES, $iBtnLeft - 88.5, $iBtnTop, 86, 23, -1, 0x00080000)
        $iButton2 = GUICtrlCreateButton($sNO, $iBtnLeft + 2.5, $iBtnTop, 86, 23, -1, 0x00080000)

        ; Yes, No, Cancel
    ElseIf BitAND($fFlag, 3) == 3 Then
        If $sOwnButtons <> "" Then
            $sSplitOwnBtn = StringSplit($sOwnButtons, "|")
            ; If error found
            If $sSplitOwnBtn[0] <> 2 Then MsgBox(4096, "Error", "_MsgBox(" & $fFlag & " ... " & '"' & $sOwnButtons & '"' & " ^ ", 0)
            $sYES = $sSplitOwnBtn[1]
            $sNO = $sSplitOwnBtn[2]
            $sCancel = $sSplitOwnBtn[3]
        Else
            $sYES = "Yes"
            $sNO = "No"
            $sCancel = "Cancel"
        EndIf
        $iButton1 = GUICtrlCreateButton($sYES, $iBtnLeft - 131.5, $iBtnTop, 86, 23, -1, 0x00080000)
        $iButton2 = GUICtrlCreateButton($sNO, $iBtnLeft - 43, $iBtnTop, 86, 23, -1, 0x00080000)
        $iButton3 = GUICtrlCreateButton($sCancel, $iBtnLeft + 45.5, $iBtnTop, 86, 23, -1, 0x00080000)

        ; Abort, Retry, Ignore
    ElseIf BitAND($fFlag, 2) == 2 Then
        If $sOwnButtons <> "" Then
            $sSplitOwnBtn = StringSplit($sOwnButtons, "|")
            ; If error found
            If $sSplitOwnBtn[0] <> 3 Then MsgBox(4096, "Error", "_MsgBox(" & $fFlag & " ... " & '"' & $sOwnButtons & '"' & " ^ ", 0)
            $sAbort = $sSplitOwnBtn[1]
            $sRetry = $sSplitOwnBtn[2]
            $sIgnore = $sSplitOwnBtn[3]
        Else
            $sAbort = "Abort"
            $sRetry = "Retry"
            $sIgnore = "Ignore"
        EndIf
        $iButton1 = GUICtrlCreateButton($sAbort, $iBtnLeft - 131.5, $iBtnTop, 86, 23, -1, 0x00080000)
        $iButton2 = GUICtrlCreateButton($sRetry, $iBtnLeft - 43, $iBtnTop, 86, 23, -1, 0x00080000)
        $iButton3 = GUICtrlCreateButton($sIgnore, $iBtnLeft + 45.5, $iBtnTop, 86, 23, -1, 0x00080000)

        ; OK, Cancel
    ElseIf BitAND($fFlag, 1) == 1 Then
        If $sOwnButtons <> "" Then
            $sSplitOwnBtn = StringSplit($sOwnButtons, "|")
            ; If error found
            If $sSplitOwnBtn[0] <> 2 Then MsgBox(4096, "Error", "_MsgBox(" & $fFlag & " ... " & '"' & $sOwnButtons & '"' & " ^ ", 0)
            $sOK = $sSplitOwnBtn[1]
            $sCancel = $sSplitOwnBtn[2]
        Else
            $sOK = "Ok"
            $sCancel = "Cancel"
        EndIf
        $iButton1 = GUICtrlCreateButton($sOK, $iBtnLeft - 88.5, $iBtnTop, 86, 23, -1, 0x00080000)
        $iButton2 = GUICtrlCreateButton($sCancel, $iBtnLeft + 2.5, $iBtnTop, 86, 23, -1, 0x00080000)

        ; OK
    ElseIf BitAND($fFlag, 0) == 0 Then
        $fIconClose = True
        If $sOwnButtons <> "" Then
            $sOK = $sOwnButtons
        Else
            $sOK = "Ok"
        EndIf
        $iButton1 = GUICtrlCreateButton($sOK, $iBtnLeft - 43, $iBtnTop, 86, 23, -1, 0x00080000)

        ; Error found
    Else
        MsgBox(4096, "Error", "_MsgBox(" & $fFlag & " ^ ", 0)
    EndIf
    #cs
    ; Set icon
    If $iIconIndex > 0 Then
        If $sFileName = "" Then
            GUICtrlCreateIcon(@SystemDir & "\user32.dll", $iIconIndex, 11, 11, 32, 32, 0x08000000)
        Else
            ;_GUICtrlPic_Create( FileName, [ ResName [, Left [, Top [, Width [, Height [, ResType [, SetBkColor [, Border ]]]]]]]] )
            Local $iCtrlID = _GUICtrlPic_Create($sFileName, $vResName, 11, 11, -1, -1, $vResType)
            Local $iCtrlPos = _GUICtrlPic_GetPos($iCtrlID)
            If Not @error Then
                If $iCtrlPos[2] > 64 Or $iCtrlPos[3] > 64 Then _GUICtrlPic_SetPos($iCtrlID, 0, 0, 60);, 48)
            EndIf
        EndIf
    EndIf
    #ce
    ; Get Default Buttons
    If BitAND($fFlag, 256) == 256 Then ; Second button is default button
        $iDefButton = $iButton2
        GUICtrlSetState($iButton2, 512)
    ElseIf BitAND($fFlag, 512) == 512 Then ; Third button is default button
        $iDefButton = $iButton3
        GUICtrlSetState($iButton3, 512)
    Else ; First button is default button
        $iDefButton = $iButton1
        GUICtrlSetState($iButton1, 512)
    EndIf

    ;---- Set Text
    GUICtrlCreateLabel($sText, $iTextLeft, $iTextTop, $aTextWidth, $iTextHeight, $bTextStyle)
    GUICtrlSetFont(-1, 8.5, 400, -1, "Tahoma")
    GUICtrlSetBkColor(-1, -2)
    ;--
    GUISetState(@SW_SHOW, $hWinHandle)
    ;DllCall("user32.dll", "int", "MessageBeep", "int", 0x44444444)

    $iTimer = TimerInit()
    Local $sOldLabel = GUICtrlRead($iDefButton), $nSecond = TimerInit(), $iCountDown = $iTimeOut
    If $iTimeOut <> 2147483647 Then GUICtrlSetData($iDefButton, $iTimeOut & " " & $sOldLabel)
    While 1
        If $iTimeOut <> 2147483647 And TimerDiff($nSecond) > 1000 Then
            $iCountDown -= 1
            GUICtrlSetData($iDefButton, $iCountDown & " " & $sOldLabel)
            $nSecond = TimerInit()
        EndIf

        $iMsg = GuiGetMsg()

        If $fIconClosePress = True And $iMsg = -3 Then ; $GUI_EVENT_CLOSE
            $sChoice = 0
            ExitLoop
        ElseIf TimerDiff($iTimer) > $iTimeOut * 1000 Then
            $sChoice = -1
            ExitLoop
        ElseIf (_IsPressed("0D") Or _IsPressed("20")) Or $iMsg = $iButton1 Or $iMsg = $iButton2 Or $iMsg = $iButton3 Then
            If $iTimeOut > -1 Then GUICtrlSetData($iDefButton, $sOldLabel)
            $sChoice = GUICtrlRead($iMsg)
            While (_IsPressed("0D") Or _IsPressed("20"))
                Sleep(100)
            WEnd
            ExitLoop
        EndIf
        ; maintain the window always active
        If $fAllwaysActive And Not WinActive($hWinHandle) Then WinActivate($hWinHandle)
    WEnd
    Opt("GUIOnEventMode", $iEventMode)
    Opt("GUICoordMode", $iCoordMode)
    GuiDelete($hWinHandle)

    If $iTimeOut <> 2147483647 Then GUICtrlSetData($iDefButton, $sOldLabel)

    If $sChoice = $sOK Then Return 1
    If $sChoice = $sCancel Then Return 2
    If $sChoice = $sAbort Then Return 3
    If $sChoice = $sRetry Then Return 4
    If $sChoice = $sIgnore Then Return 5
    If $sChoice = $sYES Then Return 6
    If $sChoice = $sNO Then Return 7
    If $sChoice = $sTryAgain Then Return 10
    If $sChoice = $sContinue Then Return 11

    If $sChoice = -1 Then Return -1 ; Timed out
    If $sChoice = 0 Then Return 0 ; GUI Close without options

    ; If unknown _MsgBox error then
    Return -2 ; and GUI Close without options
EndFunc   ;==>_MsgBox

; To get MsgBox dimensions...
Func __MsgBoxHook($iMsgID, $WParam, $LParam)
    If $iMsgID = 5 Then
        DllCall("user32.dll", "long", "UnhookWindowsHookEx", "long", DllStructGetData($s_MSGBOX_STRUCT, "hHook"))
        Local $hwnd = HWnd($WParam)
        Local $WinGetSize = WinGetClientSize($hwnd)
        Local $CtrlGetPos = ControlGetPos($hwnd, "", "Static2")
        If @error Then $CtrlGetPos = ControlGetPos($hwnd, "", "Static1")

        If IsArray($WinGetSize) And IsArray($CtrlGetPos) Then
            $a_MSGBOXHOOK_WINSIZE = $WinGetSize
            $a_MSGBOXHOOK_CTRLPOS = $CtrlGetPos
        EndIf
        ;WinMove($hwnd, "", @DesktopWidth + 10, @DesktopHeight + 10)
        Send("{ENTER}")
    EndIf
EndFunc   ;==>__MsgBoxHook

; #FUNCTION# ====================================================================================================================
; Author ........: ezzetabi and Jon
; Modified.......:
; ===============================================================================================================================
Func _IsPressed($sHexKey, $vDLL = 'user32.dll')
    ; $hexKey must be the value of one of the keys.
    ; _Is_Key_Pressed will return 0 if the key is not pressed, 1 if it is.
    Local $a_R = DllCall($vDLL, "short", "GetAsyncKeyState", "int", '0x' & $sHexKey)
    If @error Then Return SetError(@error, @extended, False)
    Return BitAND($a_R[0], 0x8000) <> 0
 EndFunc
