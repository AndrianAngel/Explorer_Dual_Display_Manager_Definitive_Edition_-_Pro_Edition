; Explorer Dual Display Manager - Complete Integration
; Requires AutoHotkey v1.1+
; Integrates: Dual Explorer + Minimize/Restore Stack + Window Positioning

#NoEnv
#SingleInstance Force
SetBatchLines, -1

; ===== GLOBAL VARIABLES =====
global SourceExplorer := ""
global DestExplorer := ""
global SourcePath := ""
global DestPath := ""
global DualLocked := false
global GuiHwnd := 0
global CurrentOrientation := ""
global MinimizedStack := []  ; Stack for Win+Z minimize/restore
global GuiVisible := false
global CtrlEnterDelay := 300  ; Default delay in milliseconds
global closedHistory := []
global MAX_HISTORY := 20
global previousWindows := {}
global EnableRobocopyLog := true
global RobocopyLogPath := A_ScriptDir "\Robocopy_Logs"


; ===== HOTKEY CONFIGURATION =====
global HK_DualV := "!v"
global HK_DualH := "!h"
global HK_VS := "!p"
global HK_HS := "!o"
global HK_CopyToD := "!d"
global HK_MoveToD := "!m"
global HK_CopyToS := "!z"
global HK_MoveToS := "!f"
global HK_Lock := "F6"
global HK_Swap := "F7"
global HK_RoboCopyToD := "^!a"
global HK_RoboMoveToD := "^!d"
global HK_RoboCopyToS := "^!e"
global HK_RoboMoveToS := "^!x"
global HK_ToggleGui := "^p"
global IniFile := A_ScriptDir "\SmartBarSettings.ini"

LoadSettings() {
    global IniFile, HK_DualV, HK_DualH, HK_VS, HK_HS
    global HK_CopyToD, HK_MoveToD, HK_CopyToS, HK_MoveToS, HK_Lock, HK_Swap
    
    ; Load hotkeys from INI
    IniRead, HK_DualV, %IniFile%, Hotkeys, DualV, !v
    IniRead, HK_DualH, %IniFile%, Hotkeys, DualH, !h
    IniRead, HK_VS, %IniFile%, Hotkeys, VS, !p
    IniRead, HK_HS, %IniFile%, Hotkeys, HS, !o
    IniRead, HK_CopyToD, %IniFile%, Hotkeys, CopyToD, !d
    IniRead, HK_MoveToD, %IniFile%, Hotkeys, MoveToD, !m
    IniRead, HK_CopyToS, %IniFile%, Hotkeys, CopyToS, !z
    IniRead, HK_MoveToS, %IniFile%, Hotkeys, MoveToS, !f
    IniRead, HK_Lock, %IniFile%, Hotkeys, Lock, F6
    IniRead, HK_Swap, %IniFile%, Hotkeys, Swap, F7
	IniRead, HK_RoboCopyToD, %IniFile%, Hotkeys, RoboCopyToD, ^!a
	IniRead, HK_RoboMoveToD, %IniFile%, Hotkeys, RoboMoveToD, ^!d
	IniRead, HK_RoboCopyToS, %IniFile%, Hotkeys, RoboCopyToS, ^!e
	IniRead, HK_RoboMoveToS, %IniFile%, Hotkeys, RoboMoveToS, ^!x
	IniRead, HK_ToggleGui, %IniFile%, Hotkeys, ToggleGui, ^p
	IniRead, CtrlEnterDelay, %IniFile%, Settings, CtrlEnterDelay, 300
	IniRead, EnableRobocopyLog, %IniFile%, Settings, EnableRobocopyLog, 1
}

SaveSettings() {
    global IniFile, HK_DualV, HK_DualH, HK_VS, HK_HS
    global HK_CopyToD, HK_MoveToD, HK_CopyToS, HK_MoveToS, HK_Lock, HK_Swap
    
    IniWrite, %HK_DualV%, %IniFile%, Hotkeys, DualV
    IniWrite, %HK_DualH%, %IniFile%, Hotkeys, DualH
    IniWrite, %HK_VS%, %IniFile%, Hotkeys, VS
    IniWrite, %HK_HS%, %IniFile%, Hotkeys, HS
    IniWrite, %HK_CopyToD%, %IniFile%, Hotkeys, CopyToD
    IniWrite, %HK_MoveToD%, %IniFile%, Hotkeys, MoveToD
    IniWrite, %HK_CopyToS%, %IniFile%, Hotkeys, CopyToS
    IniWrite, %HK_MoveToS%, %IniFile%, Hotkeys, MoveToS
    IniWrite, %HK_Lock%, %IniFile%, Hotkeys, Lock
    IniWrite, %HK_Swap%, %IniFile%, Hotkeys, Swap
	IniWrite, %HK_RoboCopyToD%, %IniFile%, Hotkeys, RoboCopyToD
	IniWrite, %HK_RoboMoveToD%, %IniFile%, Hotkeys, RoboMoveToD
	IniWrite, %HK_RoboCopyToS%, %IniFile%, Hotkeys, RoboCopyToS
	IniWrite, %HK_RoboMoveToS%, %IniFile%, Hotkeys, RoboMoveToS
	IniWrite, %HK_ToggleGui%, %IniFile%, Hotkeys, ToggleGui
	IniWrite, %CtrlEnterDelay%, %IniFile%, Settings, CtrlEnterDelay
	IniWrite, %EnableRobocopyLog%, %IniFile%, Settings, EnableRobocopyLog
}

RegisterHotkeys() {
    global HK_DualV, HK_DualH, HK_VS, HK_HS
    global HK_CopyToD, HK_MoveToD, HK_CopyToS, HK_MoveToS, HK_Lock, HK_Swap
    
    Hotkey, %HK_DualV%, HotkeyDualV
    Hotkey, %HK_DualH%, HotkeyDualH
    Hotkey, %HK_VS%, HotkeyVS
    Hotkey, %HK_HS%, HotkeyHS
    Hotkey, %HK_CopyToD%, HotkeyCopyToD
    Hotkey, %HK_MoveToD%, HotkeyMoveToD
    Hotkey, %HK_CopyToS%, HotkeyCopyToS
    Hotkey, %HK_MoveToS%, HotkeyMoveToS
    Hotkey, %HK_Lock%, HotkeyLock
    Hotkey, %HK_Swap%, HotkeySwap
	Hotkey, %HK_RoboCopyToD%, HotkeyRoboCopyToD
	Hotkey, %HK_RoboMoveToD%, HotkeyRoboMoveToD
	Hotkey, %HK_RoboCopyToS%, HotkeyRoboCopyToS
	Hotkey, %HK_RoboMoveToS%, HotkeyRoboMoveToS
	Hotkey, %HK_ToggleGui%, HotkeyToggleGui
}

; ===== GUI SETUP =====
Gui, +AlwaysOnTop -Caption +ToolWindow +HWNDhGuiID
GuiHwnd := hGuiID
Gui, Color, 1a1a1a
Gui, Font, s9 cWhite, Segoe UI

; Add buttons
Gui, Add, Button, x10 y10 w80 h30 gDualVertical HwndHBtn1, Dual V
Gui, Add, Button, x95 y10 w80 h30 gDualHorizontal HwndHBtn2, Dual H
Gui, Add, Button, x180 y10 w60 h30 gDualVerticalSelection HwndHBtn3, VS
Gui, Add, Button, x245 y10 w60 h30 gDualHorizontalSelection HwndHBtn4, HS
Gui, Add, Button, x310 y10 w85 h30 gCopyToDest HwndHBtn5, Copy to D
Gui, Add, Button, x400 y10 w85 h30 gMoveToDest HwndHBtn6, Move to D
Gui, Add, Button, x490 y10 w80 h30 gCopyToSource HwndHBtn9, Copy to S
Gui, Add, Button, x575 y10 w80 h30 gMoveToSource HwndHBtn10, Move to S
Gui, Add, Button, x660 y10 w80 h30 gToggleLock HwndHBtn7, Lock Dual
Gui, Add, Button, x745 y10 w80 h30 gSwapFolders HwndHBtn8, Swap S/D
Gui, Add, Button, x830 y10 w70 h30 gRoboCopyToDest HwndHBtn14, RCD
Gui, Add, Button, x905 y10 w70 h30 gRoboMoveToDest HwndHBtn15, RMD
Gui, Add, Button, x980 y10 w70 h30 gRoboCopyToSource HwndHBtn16, RCS
Gui, Add, Button, x1055 y10 w70 h30 gRoboMoveToSource HwndHBtn17, RMS
Gui, Add, Button, x1130 y10 w70 h30 gOpenSettings HwndHBtn11, Settings

; Apply dark theme to buttons
DllCall("UxTheme\SetWindowTheme", "Ptr", hBtn1, "Str", "DarkMode_Explorer", "Ptr", 0)
DllCall("UxTheme\SetWindowTheme", "Ptr", hBtn2, "Str", "DarkMode_Explorer", "Ptr", 0)
DllCall("UxTheme\SetWindowTheme", "Ptr", hBtn3, "Str", "DarkMode_Explorer", "Ptr", 0)
DllCall("UxTheme\SetWindowTheme", "Ptr", hBtn4, "Str", "DarkMode_Explorer", "Ptr", 0)
DllCall("UxTheme\SetWindowTheme", "Ptr", hBtn5, "Str", "DarkMode_Explorer", "Ptr", 0)
DllCall("UxTheme\SetWindowTheme", "Ptr", hBtn6, "Str", "DarkMode_Explorer", "Ptr", 0)
DllCall("UxTheme\SetWindowTheme", "Ptr", hBtn7, "Str", "DarkMode_Explorer", "Ptr", 0)
DllCall("UxTheme\SetWindowTheme", "Ptr", hBtn8, "Str", "DarkMode_Explorer", "Ptr", 0)
DllCall("UxTheme\SetWindowTheme", "Ptr", hBtn9, "Str", "DarkMode_Explorer", "Ptr", 0)
DllCall("UxTheme\SetWindowTheme", "Ptr", hBtn10, "Str", "DarkMode_Explorer", "Ptr", 0)
DllCall("UxTheme\SetWindowTheme", "Ptr", hBtn11, "Str", "DarkMode_Explorer", "Ptr", 0)
DllCall("UxTheme\SetWindowTheme", "Ptr", hBtn14, "Str", "DarkMode_Explorer", "Ptr", 0)
DllCall("UxTheme\SetWindowTheme", "Ptr", hBtn15, "Str", "DarkMode_Explorer", "Ptr", 0)
DllCall("UxTheme\SetWindowTheme", "Ptr", hBtn16, "Str", "DarkMode_Explorer", "Ptr", 0)
DllCall("UxTheme\SetWindowTheme", "Ptr", hBtn17, "Str", "DarkMode_Explorer", "Ptr", 0)


; Position GUI above taskbar (centered)
SysGet, WorkArea, MonitorWorkArea
GuiWidth := 1210
GuiHeight := 50
GuiX := (WorkAreaRight - WorkAreaLeft - GuiWidth) // 2
GuiY := WorkAreaBottom - GuiHeight - 10

LoadSettings()
RegisterHotkeys()
SetTimer, TrackWindows, 2000

Gui, Show, x%GuiX% y%GuiY% w%GuiWidth% h%GuiHeight% Hide, Explorer Dual Display Manager

;Timer label:
TrackWindows:
    TrackWindows()
return

OnMessage(0x201, "WM_LBUTTONDOWN")

; ===== INTERNAL MINIMIZE/RESTORE FUNCTIONS (No hotkeys) =====
MinimizeToStack(hwnd) {
    global MinimizedStack, GuiHwnd
    
    if (!hwnd || hwnd = GuiHwnd)
        return false
    
    if (!WinExist("ahk_id " hwnd))
        return false
    
    WinGet, MinMax, MinMax, ahk_id %hwnd%
    if (MinMax != -1) {
        MinimizedStack.Push(hwnd)
        WinMinimize, ahk_id %hwnd%
        return true
    }
    return false
}

RestoreFromStack() {
    global MinimizedStack
    
    if (MinimizedStack.Length() = 0)
        return 0
    
    hwnd := MinimizedStack.Pop()
    if (!WinExist("ahk_id " hwnd))
        return 0
    
    WinGet, MinMax, MinMax, ahk_id %hwnd%
    if (MinMax = -1) {
        WinRestore, ahk_id %hwnd%
        return hwnd
    }
    return 0
}

; Window positioning with Alt+Numpad
!Numpad8::PositionActiveWindow("up")
!Numpad2::PositionActiveWindow("down")
!Numpad4::PositionActiveWindow("left")
!Numpad6::PositionActiveWindow("right")
!Numpad7::PositionActiveWindow("up-left")
!Numpad9::PositionActiveWindow("up-right")
!Numpad1::PositionActiveWindow("down-left")
!Numpad3::PositionActiveWindow("down-right")
!Numpad5::PositionActiveWindow("center")

return

; ===== GUI FUNCTIONS =====
WM_LBUTTONDOWN() {
    global GuiHwnd
    if (A_Gui = 1)
        PostMessage, 0xA1, 2,,, ahk_id %GuiHwnd%
}

DualVertical:
    OpenDualExplorers("vertical")
return

DualHorizontal:
    OpenDualExplorers("horizontal")
return


DualVerticalSelection:
    ; Find an Explorer window (any Explorer)
    WinGet, explorerID, ID, ahk_class CabinetWClass
    if (explorerID) {
        ; Reactivate the Explorer (like clicking title bar)
        WinActivate, ahk_id %explorerID%
        Sleep, 100
        
        ; Now send Ctrl+Enter while selection is preserved
        Send {Ctrl down}
        Sleep, 50
        Send {Enter}
        Sleep, 100
        Send {Ctrl up}
        Sleep, %CtrlEnterDelay%
        HandleDualAfterCtrlEnter("vertical")
    } else {
        ; No Explorer exists - open at default
        OpenDualExplorersSelection("vertical")
    }
return


DualHorizontalSelection:
    ; Find an Explorer window (any Explorer)
    WinGet, explorerID, ID, ahk_class CabinetWClass
    if (explorerID) {
        ; Reactivate the Explorer (like clicking title bar)
        WinActivate, ahk_id %explorerID%
        Sleep, 100
        
        ; Now send Ctrl+Enter while selection is preserved
        Send {Ctrl down}
        Sleep, 50
        Send {Enter}
        Sleep, 100
        Send {Ctrl up}
        Sleep, %CtrlEnterDelay%
        HandleDualAfterCtrlEnter("horizontal")
    } else {
        ; No Explorer exists - open at default
        OpenDualExplorersSelection("horizontal")
    }


CopyToDest:
    WinGet, explorerID, ID, ahk_class CabinetWClass
    if (explorerID) {
        WinActivate, ahk_id %explorerID%
        Sleep, 100
        Send ^c
        Sleep, 200
        if (DestExplorer && WinExist("ahk_id " DestExplorer)) {
            WinActivate, ahk_id %DestExplorer%
            Sleep, 200
            Send ^v
            ToolTip, Copying to Destination...
            SetTimer, RemoveToolTip, 2000
        } else {
            ToolTip, Destination Explorer not available
            SetTimer, RemoveToolTip, 2000
        }
    }
return

MoveToDest:
    WinGet, explorerID, ID, ahk_class CabinetWClass
    if (explorerID) {
        WinActivate, ahk_id %explorerID%
        Sleep, 100
        Send ^x
        Sleep, 200
        if (DestExplorer && WinExist("ahk_id " DestExplorer)) {
            WinActivate, ahk_id %DestExplorer%
            Sleep, 200
            Send ^v
            ToolTip, Moving to Destination...
            SetTimer, RemoveToolTip, 2000
        } else {
            ToolTip, Destination Explorer not available
            SetTimer, RemoveToolTip, 2000
        }
    }
return

CopyToSource:
    WinGet, explorerID, ID, ahk_class CabinetWClass
    if (explorerID) {
        WinActivate, ahk_id %explorerID%
        Sleep, 100
        Send ^c
        Sleep, 200
        if (SourceExplorer && WinExist("ahk_id " SourceExplorer)) {
            WinActivate, ahk_id %SourceExplorer%
            Sleep, 200
            Send ^v
            ToolTip, Copying to Source...
            SetTimer, RemoveToolTip, 2000
        } else {
            ToolTip, Source Explorer not available
            SetTimer, RemoveToolTip, 2000
        }
    }
return

MoveToSource:
    WinGet, explorerID, ID, ahk_class CabinetWClass
    if (explorerID) {
        WinActivate, ahk_id %explorerID%
        Sleep, 100
        Send ^x
        Sleep, 200
        if (SourceExplorer && WinExist("ahk_id " SourceExplorer)) {
            WinActivate, ahk_id %SourceExplorer%
            Sleep, 200
            Send ^v
            ToolTip, Moving to Source...
            SetTimer, RemoveToolTip, 2000
        } else {
            ToolTip, Source Explorer not available
            SetTimer, RemoveToolTip, 2000
        }
    }
return

RoboCopyToDest:
    global SourceExplorer, DestExplorer
    ; Get the currently active Explorer window, not just any active window
    WinGet, activeHwnd, ID, ahk_class CabinetWClass
    if (activeHwnd)
        RobocopyOperation(activeHwnd, DestExplorer, false)
    else
        MsgBox, No Explorer window is active
return

RoboMoveToDest:
    global SourceExplorer, DestExplorer
    WinGet, activeHwnd, ID, ahk_class CabinetWClass
    if (activeHwnd)
        RobocopyOperation(activeHwnd, DestExplorer, true)
    else
        MsgBox, No Explorer window is active
return

RoboCopyToSource:
    global SourceExplorer, DestExplorer
    WinGet, activeHwnd, ID, ahk_class CabinetWClass
    if (activeHwnd)
        RobocopyOperation(activeHwnd, SourceExplorer, false)
    else
        MsgBox, No Explorer window is active
return

RoboMoveToSource:
    global SourceExplorer, DestExplorer
    WinGet, activeHwnd, ID, ahk_class CabinetWClass
    if (activeHwnd)
        RobocopyOperation(activeHwnd, SourceExplorer, true)
    else
        MsgBox, No Explorer window is active
return

ToggleLock:
    ToggleDualLock()
return

SwapFolders:
    SwapSourceDest()
return

; ===== HOTKEY HANDLERS =====
HotkeyDualV:
    OpenDualExplorers("vertical")
return

HotkeyDualH:
    OpenDualExplorers("horizontal")
return

HotkeyVS:
    WinGet, explorerID, ID, ahk_class CabinetWClass
    if (explorerID) {
        WinActivate, ahk_id %explorerID%
        Sleep, 100
        Send {Ctrl down}
        Sleep, 50
        Send {Enter}
        Sleep, 100
        Send {Ctrl up}
        Sleep, %CtrlEnterDelay%
        HandleDualAfterCtrlEnter("vertical")
    } else {
        OpenDualExplorersSelection("vertical")
    }
return

HotkeyHS:
    WinGet, explorerID, ID, ahk_class CabinetWClass
    if (explorerID) {
        WinActivate, ahk_id %explorerID%
        Sleep, 100
        Send {Ctrl down}
        Sleep, 50
        Send {Enter}
        Sleep, 100
        Send {Ctrl up}
        Sleep, %CtrlEnterDelay%
        HandleDualAfterCtrlEnter("horizontal")
    } else {
        OpenDualExplorersSelection("horizontal")
    }


HotkeyCopyToD:
    WinGet, explorerID, ID, ahk_class CabinetWClass
    if (explorerID) {
        WinActivate, ahk_id %explorerID%
        Sleep, 100
        Send ^c
        Sleep, 200
        if (DestExplorer && WinExist("ahk_id " DestExplorer)) {
            WinActivate, ahk_id %DestExplorer%
            Sleep, 200
            Send ^v
            ToolTip, Copying to Destination...
            SetTimer, RemoveToolTip, 2000
        }
    }
return

HotkeyMoveToD:
    WinGet, explorerID, ID, ahk_class CabinetWClass
    if (explorerID) {
        WinActivate, ahk_id %explorerID%
        Sleep, 100
        Send ^x
        Sleep, 200
        if (DestExplorer && WinExist("ahk_id " DestExplorer)) {
            WinActivate, ahk_id %DestExplorer%
            Sleep, 200
            Send ^v
            ToolTip, Moving to Destination...
            SetTimer, RemoveToolTip, 2000
        }
    }
return

HotkeyCopyToS:
    WinGet, explorerID, ID, ahk_class CabinetWClass
    if (explorerID) {
        WinActivate, ahk_id %explorerID%
        Sleep, 100
        Send ^c
        Sleep, 200
        if (SourceExplorer && WinExist("ahk_id " SourceExplorer)) {
            WinActivate, ahk_id %SourceExplorer%
            Sleep, 200
            Send ^v
            ToolTip, Copying to Source...
            SetTimer, RemoveToolTip, 2000
        }
    }
return

HotkeyMoveToS:
    WinGet, explorerID, ID, ahk_class CabinetWClass
    if (explorerID) {
        WinActivate, ahk_id %explorerID%
        Sleep, 100
        Send ^x
        Sleep, 200
        if (SourceExplorer && WinExist("ahk_id " SourceExplorer)) {
            WinActivate, ahk_id %SourceExplorer%
            Sleep, 200
            Send ^v
            ToolTip, Moving to Source...
            SetTimer, RemoveToolTip, 2000
        }
    }
return

HotkeyLock:
    ToggleDualLock()
return

HotkeySwap:
    SwapSourceDest()
return

HotkeyRoboCopyToD:
    global SourceExplorer, DestExplorer
    ; Get the currently ACTIVE Explorer window
    WinGet, activeHwnd, ID, A
    WinGetClass, activeClass, A
    
    if (activeClass != "CabinetWClass") {
        ToolTip, No Explorer window is active
        SetTimer, RemoveToolTip, 2000
        return
    }
    
    ; Determine which is source and which is dest
    if (activeHwnd = SourceExplorer) {
        RobocopyOperation(SourceExplorer, DestExplorer, false)
    } else if (activeHwnd = DestExplorer) {
        RobocopyOperation(DestExplorer, SourceExplorer, false)
    } else {
        ; Active window is neither - use it as source, DestExplorer as dest
        if (DestExplorer && WinExist("ahk_id " DestExplorer))
            RobocopyOperation(activeHwnd, DestExplorer, false)
        else
            MsgBox, No destination explorer available
    }
return

HotkeyRoboMoveToD:
    global SourceExplorer, DestExplorer
    WinGet, activeHwnd, ID, A
    WinGetClass, activeClass, A
    
    if (activeClass != "CabinetWClass") {
        ToolTip, No Explorer window is active
        SetTimer, RemoveToolTip, 2000
        return
    }
    
    if (activeHwnd = SourceExplorer) {
        RobocopyOperation(SourceExplorer, DestExplorer, true)
    } else if (activeHwnd = DestExplorer) {
        RobocopyOperation(DestExplorer, SourceExplorer, true)
    } else {
        if (DestExplorer && WinExist("ahk_id " DestExplorer))
            RobocopyOperation(activeHwnd, DestExplorer, true)
        else
            MsgBox, No destination explorer available
    }
return

HotkeyRoboCopyToS:
    global SourceExplorer, DestExplorer
    WinGet, activeHwnd, ID, A
    WinGetClass, activeClass, A
    
    if (activeClass != "CabinetWClass") {
        ToolTip, No Explorer window is active
        SetTimer, RemoveToolTip, 2000
        return
    }
    
    if (activeHwnd = DestExplorer) {
        RobocopyOperation(DestExplorer, SourceExplorer, false)
    } else if (activeHwnd = SourceExplorer) {
        RobocopyOperation(SourceExplorer, DestExplorer, false)
    } else {
        if (SourceExplorer && WinExist("ahk_id " SourceExplorer))
            RobocopyOperation(activeHwnd, SourceExplorer, false)
        else
            MsgBox, No source explorer available
    }
return

HotkeyRoboMoveToS:
    global SourceExplorer, DestExplorer
    WinGet, activeHwnd, ID, A
    WinGetClass, activeClass, A
    
    if (activeClass != "CabinetWClass") {
        ToolTip, No Explorer window is active
        SetTimer, RemoveToolTip, 2000
        return
    }
    
    if (activeHwnd = DestExplorer) {
        RobocopyOperation(DestExplorer, SourceExplorer, true)
    } else if (activeHwnd = SourceExplorer) {
        RobocopyOperation(SourceExplorer, DestExplorer, true)
    } else {
        if (SourceExplorer && WinExist("ahk_id " SourceExplorer))
            RobocopyOperation(activeHwnd, SourceExplorer, true)
        else
            MsgBox, No source explorer available
    }
return

HotkeyToggleGui:
    global GuiVisible, GuiHwnd
    
    if (GuiVisible) {
        Gui, Hide
        GuiVisible := false
    } else {
        Gui, Show
        GuiVisible := true
    }
return

GuiClose:
    ExitApp

; ===== WINDOW POSITIONING FUNCTION =====
PositionActiveWindow(position) {
    global GuiHwnd
    hwnd := WinExist("A")
    if (!hwnd || hwnd = GuiHwnd)
        return
    
    SysGet, WorkArea, MonitorWorkArea
    left := WorkAreaLeft
    top := WorkAreaTop
    right := WorkAreaRight
    bottom := WorkAreaBottom
    
    screenWidth := right - left
    screenHeight := bottom - top
    
    WinGetPos, , , winWidth, winHeight, ahk_id %hwnd%
    
    ; Calculate position
    if (position = "up") {
        x := left + (screenWidth - winWidth) / 2
        y := top
    } else if (position = "down") {
        x := left + (screenWidth - winWidth) / 2
        y := bottom - winHeight
    } else if (position = "left") {
        x := left
        y := top + (screenHeight - winHeight) / 2
    } else if (position = "right") {
        x := right - winWidth
        y := top + (screenHeight - winHeight) / 2
    } else if (position = "up-left") {
        x := left
        y := top
    } else if (position = "up-right") {
        x := right - winWidth
        y := top
    } else if (position = "down-left") {
        x := left
        y := bottom - winHeight
    } else if (position = "down-right") {
        x := right - winWidth
        y := bottom - winHeight
    } else if (position = "center") {
        x := left + (screenWidth - winWidth) / 2
        y := top + (screenHeight - winHeight) / 2
    }
    
    WinMove, ahk_id %hwnd%,, %x%, %y%
}

; ===== POSITION SPECIFIC WINDOW =====
PositionWindow(hwnd, position) {
    if (!hwnd || !WinExist("ahk_id " hwnd))
        return false
    
    SysGet, WorkArea, MonitorWorkArea
    left := WorkAreaLeft
    top := WorkAreaTop
    right := WorkAreaRight
    bottom := WorkAreaBottom
    
    screenWidth := right - left
    screenHeight := bottom - top
    
    if (position = "left-half") {
        halfWidth := screenWidth // 2
        WinMove, ahk_id %hwnd%,, %left%, %top%, %halfWidth%, % screenHeight - 50
    } else if (position = "right-half") {
        halfWidth := screenWidth // 2
        x := left + halfWidth
        WinMove, ahk_id %hwnd%,, %x%, %top%, %halfWidth%, % screenHeight - 50
    } else if (position = "top-half") {
        halfHeight := screenHeight // 2
        WinMove, ahk_id %hwnd%,, %left%, %top%, %screenWidth%, %halfHeight%
    } else if (position = "bottom-half") {
        halfHeight := screenHeight // 2
        y := top + halfHeight
        WinMove, ahk_id %hwnd%,, %left%, %y%, %screenWidth%, %halfHeight%
    }
    
    return true
}

; ===== DUAL EXPLORER CORE (RESTORE & REPOSITION) =====
OpenDualExplorers(orientation) {
    global SourceExplorer, DestExplorer, SourcePath, DestPath, CurrentOrientation, MinimizedStack
    
    ; Check for selected items in active explorer
    selectedPaths := GetSelectedExplorerPaths()
    
    ; If we have existing windows, minimize them to stack
    if (SourceExplorer != "" && WinExist("ahk_id " SourceExplorer)) {
        MinimizeToStack(SourceExplorer)
        Sleep, 100
    }
    if (DestExplorer != "" && WinExist("ahk_id " DestExplorer)) {
        MinimizeToStack(DestExplorer)
        Sleep, 100
    }
    
    ; Try to restore TWO windows from stack
    restoredSource := RestoreFromStack()
    Sleep, 100
    restoredDest := RestoreFromStack()
    Sleep, 100
    
    ; Determine paths to open
    if (selectedPaths.Length() >= 2) {
        ; Two or more items selected - use first two
        SourcePath := selectedPaths[1]
        DestPath := selectedPaths[2]
    } else if (selectedPaths.Length() = 1) {
        ; One item selected - use it for source, current path for dest
        SourcePath := selectedPaths[1]
        currentPath := GetActiveExplorerPath()
        if (currentPath != "")
            DestPath := currentPath
        else
            DestPath := SourcePath
    } else {
        ; No selection - use current path or saved paths
        currentPath := GetActiveExplorerPath()
        if (currentPath != "") {
            if (SourcePath = "")
                SourcePath := currentPath
            if (DestPath = "")
                DestPath := currentPath
        } else {
            if (SourcePath = "")
                SourcePath := "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
            if (DestPath = "")
                DestPath := SourcePath
        }
    }
    
    ; Use restored windows or create new ones
    if (restoredSource && WinExist("ahk_id " restoredSource)) {
        SourceExplorer := restoredSource
        ; DON'T navigate - it's already at the correct path!
    } else {
        existingWindows := GetAllExplorerHwnds()
        Run, explorer.exe "%SourcePath%"
        SourceExplorer := WaitForNewExplorer(existingWindows, 3000)
        if (!SourceExplorer) {
            ToolTip, Failed to create source explorer
            SetTimer, RemoveToolTip, 2000
            return
        }
    }
    
    Sleep, 200
    
    if (restoredDest && WinExist("ahk_id " restoredDest)) {
        DestExplorer := restoredDest
        ; DON'T navigate - it's already at the correct path!
    } else {
        existingWindows := GetAllExplorerHwnds()
        Run, explorer.exe "%DestPath%"
        DestExplorer := WaitForNewExplorer(existingWindows, 3000)
        if (!DestExplorer) {
            ToolTip, Failed to create destination explorer
            SetTimer, RemoveToolTip, 2000
            return
        }
    }
    
    Sleep, 300
    
    ; Position windows based on orientation
    if (orientation = "vertical") {
        PositionWindow(SourceExplorer, "left-half")
        PositionWindow(DestExplorer, "right-half")
    } else {
        PositionWindow(SourceExplorer, "top-half")
        PositionWindow(DestExplorer, "bottom-half")
    }
    
    CurrentOrientation := orientation
    WinActivate, ahk_id %SourceExplorer%
    
    ToolTip, Dual explorers: %orientation%
    SetTimer, RemoveToolTip, 2000
}

; Robocopy Function

RobocopyOperation(sourceHwnd, destHwnd, moveMode := false) {
    global EnableRobocopyLog, RobocopyLogPath
    
    if (!sourceHwnd || !destHwnd) {
        MsgBox, Please open dual explorers first
        return
    }
    
    if (!WinExist("ahk_id " sourceHwnd) || !WinExist("ahk_id " destHwnd)) {
        MsgBox, Explorer windows no longer exist
        return
    }
    
    ; FIRST: Activate and wait for source window
    WinActivate, ahk_id %sourceHwnd%
    Sleep, 300
    
    ; SECOND: Get source path
    sourcePath := GetExplorerPath(sourceHwnd)
    if (sourcePath = "") {
        MsgBox, Cannot get source path
        return
    }
    
    ; THIRD: Get selected items (try COM first, then clipboard fallback)
    selectedItems := GetSelectedItems(sourceHwnd)
    
    if (selectedItems.Length() = 0) {
        ToolTip, Trying clipboard method...
        SetTimer, RemoveToolTip, 1000
        Sleep, 500
        selectedItems := GetSelectedItemsFallbackFromClipboard()
    }
    
    if (selectedItems.Length() = 0) {
        MsgBox, 16, Error, No items selected in source explorer!`n`nPlease select files or folders first.
        return
    }
    
    ; FOURTH: Get destination path
    destPath := GetExplorerPath(destHwnd)
    if (destPath = "") {
        MsgBox, Cannot get destination path
        return
    }
    
    ; Create log directory if needed
    if (EnableRobocopyLog && !FileExist(RobocopyLogPath))
        FileCreateDir, %RobocopyLogPath%
    
    ; Prepare operation description
    operation := moveMode ? "MOVE" : "COPY"
    actionVerb := moveMode ? "MOVE and DELETE" : "COPY and KEEP"
    
    ; Build confirmation message
    confirmMsg := operation " files with Robocopy?`n`n"
    confirmMsg .= "Action: " actionVerb " the original`n"
    confirmMsg .= "From: " sourcePath "`n"
    confirmMsg .= "To: " destPath "`n"
    confirmMsg .= "Items: " selectedItems.Length() "`n`n"
    
    ; Show first few items
    Loop % Min(selectedItems.Length(), 3) {
        confirmMsg .= "Item " A_Index ": " selectedItems[A_Index] "`n"
    }
    if (selectedItems.Length() > 3)
        confirmMsg .= "... and " (selectedItems.Length() - 3) " more"
    
    MsgBox, 1, Confirmation!, %confirmMsg%
    IfMsgBox, Cancel
        return
    
    ; Process each selected item
    successCount := 0
    for index, itemPath in selectedItems {
        if (!FileExist(itemPath)) {
            MsgBox, Item not found: %itemPath%
            continue
        }
        
        SplitPath, itemPath, itemName, sourceDir
        
        ; Check if folder or file
        FileGetAttrib, attrs, %itemPath%
        isFolder := InStr(attrs, "D")
        
        ; Build robocopy command
        if (isFolder) {
            destFullPath := destPath "\" itemName
            if (moveMode)
                command := "robocopy """ itemPath """ """ destFullPath """ /E /R:3 /W:5 /MT:8 /MOVE"
            else
                command := "robocopy """ itemPath """ """ destFullPath """ /E /R:3 /W:5 /MT:8"
        } else {
            if (moveMode)
                command := "robocopy """ sourceDir """ """ destPath """ """ itemName """ /R:3 /W:5 /MT:8 /MOV"
            else
                command := "robocopy """ sourceDir """ """ destPath """ """ itemName """ /R:3 /W:5 /MT:8"
        }
        
        ; Add log if enabled - use /TEE to show progress AND write log
        if (EnableRobocopyLog) {
            FormatTime, timestamp, , yyyyMMdd_HHmmss
            logFile := RobocopyLogPath "\Log_" operation "_" timestamp "_" index ".txt"
            command .= " /TEE /LOG:""" logFile """"
        }
        
        ; Execute robocopy WITH VISIBLE CMD WINDOW
        RunWait, %ComSpec% /c %command% `& pause, , 
        
        ; Check if robocopy succeeded (exit codes 0-7 are success)
        if (ErrorLevel <= 7)
            successCount++
    }
    
    ; Refresh both explorers
    WinActivate, ahk_id %sourceHwnd%
    Sleep, 300
    Send {F5}
    Sleep, 300
    WinActivate, ahk_id %destHwnd%
    Sleep, 300
    Send {F5}
    
    ; Show completion message
    resultMsg := "Operation completed!`n`n"
    resultMsg .= "Processed: " successCount " of " selectedItems.Length() " items"
    
    if (EnableRobocopyLog) {
        MsgBox, 1, %resultMsg%, Open Logs folder?
        IfMsgBox, Ok
            Run, %RobocopyLogPath%
    } else {
        MsgBox, 0, Process Completed!, %resultMsg%
    }
}

; Helper function for Min()
Min(a, b) {
    return (a < b) ? a : b
}

; ===== DUAL EXPLORER WITH SELECTION (VS/HS) =====
OpenDualExplorersSelection(orientation) {
    global SourceExplorer, DestExplorer, SourcePath, DestPath, CurrentOrientation, MinimizedStack

    ; Try to get last two closed paths from history
    historyPaths := GetLastTwoClosedPaths()
    
    ; If we have 2+ paths in history, use them
    if (historyPaths.Length() >= 2) {
        currentPath := historyPaths[1]
        secondPath := historyPaths[2]
    } 
    ; Otherwise fallback to current path
    else {
        currentPath := GetActiveExplorerPath()
        if (currentPath = "")
            currentPath := "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
        secondPath := currentPath
    }

    ; Minimize any existing dual explorers
    if (SourceExplorer != "" && WinExist("ahk_id " SourceExplorer)) {
        MinimizeToStack(SourceExplorer)
        Sleep, 100
    }
    if (DestExplorer != "" && WinExist("ahk_id " DestExplorer)) {
        MinimizeToStack(DestExplorer)
        Sleep, 100
    }

    ; Try to restore TWO windows from stack
    restoredSource := RestoreFromStack()
    Sleep, 100
    restoredDest := RestoreFromStack()
    Sleep, 100

    ; Use restored windows or create new ones
    if (restoredSource && WinExist("ahk_id " restoredSource)) {
        SourceExplorer := restoredSource
        NavigateExplorer(SourceExplorer, currentPath)  ; <-- Navigate to history path
    } else {
        existingWindows := GetAllExplorerHwnds()
        Run, explorer.exe "%currentPath%"
        SourceExplorer := WaitForNewExplorer(existingWindows, 3000)
    }

    Sleep, 200

    if (restoredDest && WinExist("ahk_id " restoredDest)) {
        DestExplorer := restoredDest
        NavigateExplorer(DestExplorer, secondPath)  ; <-- Navigate to history path
    } else {
        existingWindows := GetAllExplorerHwnds()
        Run, explorer.exe "%secondPath%"
        DestExplorer := WaitForNewExplorer(existingWindows, 3000)
    }

    Sleep, 300

    ; Position windows
    if (orientation = "vertical") {
        PositionWindow(SourceExplorer, "left-half")
        PositionWindow(DestExplorer, "right-half")
    } else {
        PositionWindow(SourceExplorer, "top-half")
        PositionWindow(DestExplorer, "bottom-half")
    }

    CurrentOrientation := orientation
    SourcePath := currentPath
    DestPath := secondPath

    ; Bring source to front
    if (SourceExplorer)
        WinActivate, ahk_id %SourceExplorer%

    ToolTip, Dual explorers opened (%orientation%)
    SetTimer, RemoveToolTip, 2000
}

HandleDualAfterCtrlEnter(orientation) {
    global SourceExplorer, DestExplorer, CurrentOrientation

    ; Wait for the two new Explorer windows to appear after Ctrl+Enter
    Sleep, 500
    
    ; Get all current Explorer windows BEFORE minimizing anything
    allExplorers := GetAllExplorerHwnds()
    
    ; Minimize ALL Explorer windows to stack
    for index, hwnd in allExplorers {
        MinimizeToStack(hwnd)
        Sleep, 50
    }
    
    Sleep, 200

    ; Now restore in BACKWARD order but SKIP the very last one (parent)
    ; Restore second-to-last as Dest
    if (MinimizedStack.Length() >= 2) {
        MinimizedStack.Pop()  ; Remove and discard the last one (parent)
        DestExplorer := RestoreFromStack()  ; Get second-to-last
        Sleep, 200
    }
    
    ; Restore third-to-last as Source
    if (MinimizedStack.Length() >= 1) {
        SourceExplorer := RestoreFromStack()  ; Get third-to-last
        Sleep, 200
    }
    
    ; Position them
    if (SourceExplorer && WinExist("ahk_id " SourceExplorer)) {
        if (orientation = "vertical")
            PositionWindow(SourceExplorer, "left-half")
        else
            PositionWindow(SourceExplorer, "top-half")
    }
    
    if (DestExplorer && WinExist("ahk_id " DestExplorer)) {
        if (orientation = "vertical")
            PositionWindow(DestExplorer, "right-half")
        else
            PositionWindow(DestExplorer, "bottom-half")
    }

    CurrentOrientation := orientation
    
    if (SourceExplorer)
        WinActivate, ahk_id %SourceExplorer%

    ToolTip, Dual explorers arranged (%orientation%)
    SetTimer, RemoveToolTip, 2000
}

; ===== SELECTION DETECTION =====
GetSelectedExplorerPaths() {
    paths := []
    
    WinGetClass, activeClass, A
    if (activeClass != "CabinetWClass" && activeClass != "ExploreWClass")
        return paths
    
    WinGet, activeHwnd, ID, A
    
    try {
        for window in ComObjCreate("Shell.Application").Windows {
            if (window.HWND = activeHwnd) {
                items := window.Document.SelectedItems()
                if (items) {
                    for item in items {
                        if (item.IsFolder)
                            paths.Push(item.Path)
                    }
                }
                break
            }
        }
    }
    
    return paths
}

; ===== EXPLORER HELPER FUNCTIONS =====
GetAllExplorerHwnds() {
    global GuiHwnd
    hwnds := []
    WinGet, id, List, ahk_class CabinetWClass
    Loop, %id%
    {
        hwnd := id%A_Index%
        if (hwnd != GuiHwnd)
            hwnds.Push(hwnd)
    }
    return hwnds
}

WaitForNewExplorer(existingHwnds, timeout := 3000) {
    global GuiHwnd
    startTime := A_TickCount
    
    Loop {
        if (A_TickCount - startTime > timeout)
            return 0
        
        WinGet, id, List, ahk_class CabinetWClass
        Loop, %id%
        {
            hwnd := id%A_Index%
            
            if (hwnd = GuiHwnd)
                continue
            
            isNew := true
            for index, existingHwnd in existingHwnds {
                if (hwnd = existingHwnd) {
                    isNew := false
                    break
                }
            }
            
            if (isNew && WinExist("ahk_id " hwnd)) {
                WinGetTitle, title, ahk_id %hwnd%
                if (title != "")
                    return hwnd
            }
        }
        Sleep, 50
    }
    return 0
}

GetActiveExplorerPath() {
    WinGetClass, activeClass, A
    if (activeClass != "CabinetWClass" && activeClass != "ExploreWClass")
        return ""
    
    WinGet, activeHwnd, ID, A
    
    try {
        for window in ComObjCreate("Shell.Application").Windows {
            if (window.HWND = activeHwnd && window.Document) {
                return window.Document.Folder.Self.Path
            }
        }
    }
    return ""
}

GetExplorerPath(hwnd) {
    for window in ComObjCreate("Shell.Application").Windows {
        try {
            if (window.HWND = hwnd) {
                path := window.Document.Folder.Self.Path
                ; Normalize GUID-based paths
                if (SubStr(path, 1, 2) = "::") {
                    ; fallback: Desktop
                    return A_Desktop
                }
                return path
            }
        }
    }
    return ""
}

NavigateExplorer(hwnd, path) {
    if (!hwnd || !WinExist("ahk_id " hwnd) || path = "")
        return false
    
    try {
        for window in ComObjCreate("Shell.Application").Windows {
            if (window.HWND = hwnd) {
                window.Navigate(path)
                return true
            }
        }
    }
    return false
}


CopyToDestination() {
    global SourceExplorer, DestExplorer
    
    if (!SourceExplorer || !DestExplorer) {
        ToolTip, Please open dual explorers first
        SetTimer, RemoveToolTip, 2000
        return
    }
    
    if (!WinExist("ahk_id " SourceExplorer) || !WinExist("ahk_id " DestExplorer)) {
        ToolTip, Explorer windows no longer exist
        SetTimer, RemoveToolTip, 2000
        return
    }
    
    WinActivate, ahk_id %SourceExplorer%
    Sleep, 200
    Send, ^c
    Sleep, 200
    
    WinActivate, ahk_id %DestExplorer%
    Sleep, 200
    Send, ^v
    Sleep, 100
    
    ; Keep destination active
    WinActivate, ahk_id %DestExplorer%
    
    ToolTip, Copying to destination...
    SetTimer, RemoveToolTip, 2000
}

MoveToDestination() {
    global SourceExplorer, DestExplorer
    
    if (!SourceExplorer || !DestExplorer) {
        ToolTip, Please open dual explorers first
        SetTimer, RemoveToolTip, 2000
        return
    }
    
    if (!WinExist("ahk_id " SourceExplorer) || !WinExist("ahk_id " DestExplorer)) {
        ToolTip, Explorer windows no longer exist
        SetTimer, RemoveToolTip, 2000
        return
    }
    
    WinActivate, ahk_id %SourceExplorer%
    Sleep, 200
    Send, ^x
    Sleep, 200
    
    WinActivate, ahk_id %DestExplorer%
    Sleep, 200
    Send, ^v
    Sleep, 100
    
    ; Keep destination active
    WinActivate, ahk_id %DestExplorer%
    
    ToolTip, Moving to destination...
    SetTimer, RemoveToolTip, 2000
}

CopyToSource() {
    global SourceExplorer, DestExplorer
    
    if (!SourceExplorer || !DestExplorer) {
        ToolTip, Please open dual explorers first
        SetTimer, RemoveToolTip, 2000
        return
    }
    
    if (!WinExist("ahk_id " SourceExplorer) || !WinExist("ahk_id " DestExplorer)) {
        ToolTip, Explorer windows no longer exist
        SetTimer, RemoveToolTip, 2000
        return
    }
    
    WinActivate, ahk_id %DestExplorer%
    Sleep, 200
    Send, ^c
    Sleep, 200
    
    WinActivate, ahk_id %SourceExplorer%
    Sleep, 200
    Send, ^v
    Sleep, 100
    
    ; Keep source active
    WinActivate, ahk_id %SourceExplorer%
    
    ToolTip, Copying to source...
    SetTimer, RemoveToolTip, 2000
}

MoveToSource() {
    global SourceExplorer, DestExplorer
    
    if (!SourceExplorer || !DestExplorer) {
        ToolTip, Please open dual explorers first
        SetTimer, RemoveToolTip, 2000
        return
    }
    
    if (!WinExist("ahk_id " SourceExplorer) || !WinExist("ahk_id " DestExplorer)) {
        ToolTip, Explorer windows no longer exist
        SetTimer, RemoveToolTip, 2000
        return
    }
    
    WinActivate, ahk_id %DestExplorer%
    Sleep, 200
    Send, ^x
    Sleep, 200
    
    WinActivate, ahk_id %SourceExplorer%
    Sleep, 200
    Send, ^v
    Sleep, 100
    
    ; Keep source active
    WinActivate, ahk_id %SourceExplorer%
    
    ToolTip, Moving to source...
    SetTimer, RemoveToolTip, 2000
}

GetSelectedItems(hwnd) {
    items := []
    
    if (!hwnd || !WinExist("ahk_id " hwnd))
        return items
    
    ; Make sure the window is active first
    WinActivate, ahk_id %hwnd%
    Sleep, 200
    
    try {
        for window in ComObjCreate("Shell.Application").Windows {
            if (window.HWND = hwnd) {
                selectedItems := window.Document.SelectedItems()
                if (selectedItems && selectedItems.Count > 0) {
                    Loop % selectedItems.Count {
                        item := selectedItems.Item(A_Index - 1)
                        items.Push(item.Path)
                    }
                }
                break
            }
        }
    } catch e {
        ; COM failed, items will remain empty
    }
    
    return items
}

GetSelectedItemsFallbackFromClipboard() {
    items := []
    
    ; Save current clipboard
    ClipSaved := ClipboardAll
    Clipboard := ""
    
    ; Copy selected items
    Send ^c
    ClipWait, 1  ; Wait up to 1 second
    
    if (ErrorLevel) {
        Clipboard := ClipSaved
        return items
    }
    
    ; Check if clipboard contains files (CF_HDROP format)
    ; In Explorer, Ctrl+C on files puts their paths in clipboard
    clipContent := Clipboard
    
    ; Split by newlines and filter empty lines
    Loop, Parse, clipContent, `n, `r
    {
        if (A_LoopField != "" && FileExist(A_LoopField))
            items.Push(A_LoopField)
    }
    
    ; Restore clipboard
    Clipboard := ClipSaved
    ClipSaved := ""
    
    return items
}

; ===== LOCK DUAL FUNCTION =====
ToggleDualLock() {
    global SourceExplorer, DestExplorer, DualLocked
    
    if (!SourceExplorer || !DestExplorer) {
        ToolTip, Please open dual explorers first
        SetTimer, RemoveToolTip, 2000
        return
    }
    
    if (!WinExist("ahk_id " SourceExplorer) || !WinExist("ahk_id " DestExplorer)) {
        ToolTip, Explorer windows no longer exist
        SetTimer, RemoveToolTip, 2000
        return
    }
    
    DualLocked := !DualLocked
    
    if (DualLocked) {
        ; Disable close, minimize, maximize buttons
        WinSet, Style, -0x80000, ahk_id %SourceExplorer%     ; Remove WS_SYSMENU (close button)
        WinSet, Style, -0x20000, ahk_id %SourceExplorer%     ; Remove WS_MINIMIZEBOX
        WinSet, Style, -0x10000, ahk_id %SourceExplorer%     ; Remove WS_MAXIMIZEBOX
        
        WinSet, Style, -0x80000, ahk_id %DestExplorer%
        WinSet, Style, -0x20000, ahk_id %DestExplorer%
        WinSet, Style, -0x10000, ahk_id %DestExplorer%
        
        GuiControl,, Button9, Unlock
        ToolTip, Dual display locked (Alt+F4 still works)
    } else {
        ; Re-enable buttons
        WinSet, Style, +0x80000, ahk_id %SourceExplorer%
        WinSet, Style, +0x20000, ahk_id %SourceExplorer%
        WinSet, Style, +0x10000, ahk_id %SourceExplorer%
        
        WinSet, Style, +0x80000, ahk_id %DestExplorer%
        WinSet, Style, +0x20000, ahk_id %DestExplorer%
        WinSet, Style, +0x10000, ahk_id %DestExplorer%
        
        GuiControl,, Button9, Lock Dual
        ToolTip, Dual display unlocked
    }
    
    SetTimer, RemoveToolTip, 1500
}

; ===== SWAP FUNCTION (PHYSICALLY SWAP POSITIONS) =====
SwapSourceDest() {
    global SourceExplorer, DestExplorer, SourcePath, DestPath, CurrentOrientation
    
    if (!SourceExplorer || !DestExplorer) {
        ToolTip, Please open dual explorers first
        SetTimer, RemoveToolTip, 2000
        return
    }
    
    if (!WinExist("ahk_id " SourceExplorer) || !WinExist("ahk_id " DestExplorer)) {
        ToolTip, Explorer windows no longer exist
        SetTimer, RemoveToolTip, 2000
        return
    }
    
    ; Just swap the references and paths
    tempExplorer := SourceExplorer
    SourceExplorer := DestExplorer
    DestExplorer := tempExplorer
    
    tempPath := SourcePath
    SourcePath := DestPath
    DestPath := tempPath
    
    ; Reposition - source goes to source position, dest goes to dest position
    if (CurrentOrientation = "vertical") {
        PositionWindow(SourceExplorer, "left-half")
        PositionWindow(DestExplorer, "right-half")
    } else {
        PositionWindow(SourceExplorer, "top-half")
        PositionWindow(DestExplorer, "bottom-half")
    }
    
    WinActivate, ahk_id %SourceExplorer%
    
    ToolTip, Windows swapped!
    SetTimer, RemoveToolTip, 1500
}


; ===== SETTINGS GUI =====
OpenSettings:
    global HK_DualV, HK_DualH, HK_VS, HK_HS
    global HK_CopyToD, HK_MoveToD, HK_CopyToS, HK_MoveToS, HK_Lock, HK_Swap
    
    Gui, 2:New
	OnMessage(0x133, "WM_CTLCOLOREDIT")
    Gui, 2:+AlwaysOnTop -MinimizeBox
    Gui, 2:Color, 1a1a1a
    Gui, 2:Font, s10 cWhite, Segoe UI
    
    Gui, 2:Add, Text, x20 y20 w200, Hotkey Settings:
    Gui, 2:Add, Text, x20 y50, Dual V:
	Gui, 2:Add, Edit, x150 y47 w100 vEditDualV Background2a2a2a HwndHList1 cWhite, %HK_DualV% 
	DllCall("UxTheme\SetWindowTheme", "Ptr", hList1, "Str", "DarkMode_Explorer", "Ptr", 0)
    
    Gui, 2:Add, Text, x20 y80, Dual H:
	Gui, 2:Add, Edit, x150 y77 w100 vEditDualH Background2a2a2a HwndHList2 cWhite, %HK_DualH%
	DllCall("UxTheme\SetWindowTheme", "Ptr", hList2, "Str", "DarkMode_Explorer", "Ptr", 0)
	
    Gui, 2:Add, Text, x20 y110, VS:
	Gui, 2:Add, Edit, x150 y107 w100 vEditVS Background2a2a2a HwndHList3 cWhite, %HK_VS%
	DllCall("UxTheme\SetWindowTheme", "Ptr", hList3, "Str", "DarkMode_Explorer", "Ptr", 0)
    
    Gui, 2:Add, Text, x20 y140, HS:
	Gui, 2:Add, Edit, x150 y137 w100 vEditHS Background2a2a2a HwndHList4 cWhite, %HK_HS%
	DllCall("UxTheme\SetWindowTheme", "Ptr", hList4, "Str", "DarkMode_Explorer", "Ptr", 0)
	
    Gui, 2:Add, Text, x20 y170, Copy to D:
	Gui, 2:Add, Edit, x150 y167 w100 vEditCopyToD Background2a2a2a HwndHList5 cWhite, %HK_CopyToD%
	DllCall("UxTheme\SetWindowTheme", "Ptr", hList5, "Str", "DarkMode_Explorer", "Ptr", 0)
	
    Gui, 2:Add, Text, x20 y200, Move to D:
	Gui, 2:Add, Edit, x150 y197 w100 vEditMoveToD Background2a2a2a HwndHList6 cWhite, %HK_MoveToD%
	DllCall("UxTheme\SetWindowTheme", "Ptr", hList6, "Str", "DarkMode_Explorer", "Ptr", 0)
	
    Gui, 2:Add, Text, x20 y230, Copy to S:
	Gui, 2:Add, Edit, x150 y227 w100 vEditCopyToS Background2a2a2a HwndHList7 cWhite, %HK_CopyToS%
	DllCall("UxTheme\SetWindowTheme", "Ptr", hList7, "Str", "DarkMode_Explorer", "Ptr", 0)
	
    Gui, 2:Add, Text, x20 y260, Move to S:
	Gui, 2:Add, Edit, x150 y257 w100 vEditMoveToS Background2a2a2a HwndHList8 cWhite, %HK_MoveToS%
	DllCall("UxTheme\SetWindowTheme", "Ptr", hList8, "Str", "DarkMode_Explorer", "Ptr", 0)
	
    Gui, 2:Add, Text, x20 y290, Lock:
	Gui, 2:Add, Edit, x150 y287 w100 vEditLock Background2a2a2a HwndHList9 cWhite, %HK_Lock%
	DllCall("UxTheme\SetWindowTheme", "Ptr", hList9, "Str", "DarkMode_Explorer", "Ptr", 0)
	
    Gui, 2:Add, Text, x20 y320, Swap:
	Gui, 2:Add, Edit, x150 y317 w100 vEditSwap Background2a2a2a HwndHList10 cWhite, %HK_Swap%
	DllCall("UxTheme\SetWindowTheme", "Ptr", hList10, "Str", "DarkMode_Explorer", "Ptr", 0)
	
	Gui, 2:Add, Text, x20 y350, Toggle GUI:
	Gui, 2:Add, Edit, x150 y347 w100 vEditToggleGui Background2a2a2a HwndHList11 cWhite, %HK_ToggleGui%
	DllCall("UxTheme\SetWindowTheme", "Ptr", hList11, "Str", "DarkMode_Explorer", "Ptr", 0)
	
	Gui, 2:Add, Text, x20 y380, RoboCopy to D:
	Gui, 2:Add, Edit, x150 y377 w100 vEditRoboCopyToD Background2a2a2a HwndHList12 cWhite, %HK_RoboCopyToD%
	DllCall("UxTheme\SetWindowTheme", "Ptr", hList12, "Str", "DarkMode_Explorer", "Ptr", 0)

	Gui, 2:Add, Text, x20 y410, RoboMove to D:
	Gui, 2:Add, Edit, x150 y407 w100 vEditRoboMoveToD Background2a2a2a HwndHList13 cWhite, %HK_RoboMoveToD%
	DllCall("UxTheme\SetWindowTheme", "Ptr", hList13, "Str", "DarkMode_Explorer", "Ptr", 0)

	Gui, 2:Add, Text, x20 y440, RoboCopy to S:
	Gui, 2:Add, Edit, x150 y437 w100 vEditRoboCopyToS Background2a2a2a HwndHList14 cWhite, %HK_RoboCopyToS%
	DllCall("UxTheme\SetWindowTheme", "Ptr", hList14, "Str", "DarkMode_Explorer", "Ptr", 0)

	Gui, 2:Add, Text, x20 y470, RoboMove to S:
	Gui, 2:Add, Edit, x150 y467 w100 vEditRoboMoveToS Background2a2a2a HwndHList15 cWhite, %HK_RoboMoveToS%
	DllCall("UxTheme\SetWindowTheme", "Ptr", hList15, "Str", "DarkMode_Explorer", "Ptr", 0)

	Gui, 2:Add, Text, x20 y500, HS VS Delay (ms):
	Gui, 2:Add, Edit, x150 y497 w100 vEditDelay Background2a2a2a HwndHList16 cWhite Number, %CtrlEnterDelay%
	DllCall("UxTheme\SetWindowTheme", "Ptr", hList16, "Str", "DarkMode_Explorer", "Ptr", 0)
	
	Gui, 2:Add, Text, x20 y550 w200 cWhite, Robocopy Options:
	Gui, 2:Add, Checkbox, x20 y585 vCheckEnableLog Checked%EnableRobocopyLog% cWhite, Enable operation logs
		
	Gui, 2:Add, Button, x60 y630 w80 h30 gSaveHotkeys HwndHBtn12, Save
	Gui, 2:Add, Button, x150 y630 w80 h30 g2GuiClose HwndHBtn13, Cancel
	
	DllCall("UxTheme\SetWindowTheme", "Ptr", hBtn12, "Str", "DarkMode_Explorer", "Ptr", 0)
	DllCall("UxTheme\SetWindowTheme", "Ptr", hBtn13, "Str", "DarkMode_Explorer", "Ptr", 0)
    
    Gui, 2:Show, w280 h680, Hotkey Settings
return

SaveHotkeys:
    global HK_DualV, HK_DualH, HK_VS, HK_HS
    global HK_CopyToD, HK_MoveToD, HK_CopyToS, HK_MoveToS, HK_Lock, HK_Swap, HK_ToggleGui
    
    Gui, 2:Submit, NoHide
    
    ; Unregister old hotkeys
    Hotkey, %HK_DualV%, Off
    Hotkey, %HK_DualH%, Off
    Hotkey, %HK_VS%, Off
    Hotkey, %HK_HS%, Off
    Hotkey, %HK_CopyToD%, Off
    Hotkey, %HK_MoveToD%, Off
    Hotkey, %HK_CopyToS%, Off
    Hotkey, %HK_MoveToS%, Off
    Hotkey, %HK_Lock%, Off
    Hotkey, %HK_Swap%, Off
	Hotkey, %HK_RoboCopyToD%, Off
	Hotkey, %HK_RoboMoveToD%, Off
	Hotkey, %HK_RoboCopyToS%, Off
	Hotkey, %HK_RoboMoveToS%, Off
	Hotkey, %HK_ToggleGui%, Off
    
    ; Update variables
    HK_DualV := EditDualV
    HK_DualH := EditDualH
    HK_VS := EditVS
    HK_HS := EditHS
    HK_CopyToD := EditCopyToD
    HK_MoveToD := EditMoveToD
    HK_CopyToS := EditCopyToS
    HK_MoveToS := EditMoveToS
    HK_Lock := EditLock
    HK_Swap := EditSwap
	HK_RoboCopyToD := EditRoboCopyToD
	HK_RoboMoveToD := EditRoboMoveToD
	HK_RoboCopyToS := EditRoboCopyToS
	HK_RoboMoveToS := EditRoboMoveToS
	HK_ToggleGui := EditToggleGui
	CtrlEnterDelay := EditDelay
	
	; Save log
	EnableRobocopyLog := CheckEnableLog
    
    ; Save to INI
    SaveSettings()
    
    ; Register new hotkeys
    RegisterHotkeys()
    
    Gui, 2:Destroy
    ToolTip, Hotkeys saved!
    SetTimer, RemoveToolTip, 2000
return

WM_CTLCOLOREDIT(wParam, lParam) {
    ; Set text color to white
    DllCall("SetTextColor", "Ptr", wParam, "UInt", 0xFFFFFF)
    ; Set background color to dark gray (2d2d2d)
    DllCall("SetBkColor", "Ptr", wParam, "UInt", 0x2d2d2d)
    ; Return brush for background
    Return DllCall("CreateSolidBrush", "UInt", 0x2d2d2d, "Ptr")
}

2GuiClose:
	OnMessage(0x133, "")  ; <-- Unregister the message
    Gui, 2:Destroy
return


; ===== HISTORY TRACKING =====
TrackWindows() {
    global previousWindows, closedHistory, MAX_HISTORY
    
    windows := ComObjCreate("Shell.Application").Windows
    current := {}

    Loop % windows.Count
    {
        try {
            window := windows.Item(A_Index - 1)
            if (window.Document && window.Document.Folder) {
                hwnd := window.HWND
                path := window.Document.Folder.Self.Path
                current[hwnd] := path
            }
        }
    }

    ; Check for closed windows
    for hwnd, path in previousWindows {
        if !current.HasKey(hwnd) {
            AddToHistory(path)
        }
    }

    previousWindows := current
}

AddToHistory(path) {
    global closedHistory, MAX_HISTORY
    
    if (path = "" || !FileExist(path))
        return
    
    ; Remove duplicates
    Loop % closedHistory.Length() {
        if (closedHistory[A_Index] = path) {
            closedHistory.RemoveAt(A_Index)
            break
        }
    }
    
    ; Add to beginning
    closedHistory.InsertAt(1, path)
    
    ; Keep only last 20
    if (closedHistory.Length() > MAX_HISTORY) {
        closedHistory.RemoveAt(MAX_HISTORY + 1)
    }
}

GetLastTwoClosedPaths() {
    global closedHistory
    
    paths := []
    if (closedHistory.Length() >= 1)
        paths.Push(closedHistory[1])
    if (closedHistory.Length() >= 2)
        paths.Push(closedHistory[2])
    
    return paths
}


; ===== UTILITY =====
RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
return