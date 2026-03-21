;===================================================================================
; Color Trigger by Perseus
;===================================================================================

#NoEnv 
#persistent
#MaxThreadsPerHotkey 2
#KeyHistory 0
ListLines Off
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
SendMode Input
CoordMode, Pixel, Screen

; High Process For Better Performance
Process, Priority, , H 

; Sounds
SoundBeep, 400, 150
SoundBeep, 600, 150

;===================================================================================
; User Settings
;===================================================================================
color_1        :=     0xFFF200    ; 1. Color (Yellow - Example: Valorant/CS2)
color_2        :=     0x00F100    ; 2. Color (Violet/Pink)

pixel_box      :=     2.5         ; Scan Area (2-4 is fastest)
pixel_sens     :=     60          ; Color Sensibility
tap_time       :=     15          ; Delay Between Taps

; Pre-Fire Delay Settings
fire_delay     :=     0           ; Default delay before shooting (ms)
delay_step     :=     5           ; Increase/Decrease amount (Step)

; Startup Settings
active_color   :=     color_1
color_label    :=     "Color-1"

;===================================================================================
; Keybinds
;===================================================================================
key_stay_on    :=     "F1"        ; AutoScan
key_color_swap :=     "F2"        ; Color Change (1 <-> 2)
key_fastclick  :=     "F3"        ; Left Click Macro (ON/OFF)
key_off        :=     "F4"        ; Stop Loops
key_gui_hide   :=     "INSERT"    ; GUI HIDE/SHOW
key_exit       :=     "DELETE"    ; Close Script
key_hold       :=     "LALT"      ; Hold Button (LAlt)
key_hold_mode  :=     "8"         ; HoldModeON/OFF

key_delay_up   :=     "Right"     ; Increase Fire Delay
key_delay_down :=     "Left"      ; Decrease Fire Delay

;===================================================================================
; Gui 
;===================================================================================
Gui,2:Font, s9 Bold, Segoe UI
Gui,2:Color, 050505
Gui,2:Add, Progress, x0 y0 w150 h95 Background050505 c222222 vStatusBG, 100
Gui,2:Add, Text, x10 y10 w130 h20 cWhite BackgroundTrans vModeText, MODE : NONE
Gui,2:Add, Text, x10 y30 w130 h20 c00FF00 BackgroundTrans vColorText, Active: %color_label%
Gui,2:Add, Text, x10 y50 w130 h20 cGray BackgroundTrans, F4: Stop
Gui,2:Add, Text, x10 y70 w130 h20 cAqua BackgroundTrans vDelayText, Pre-Delay: %fire_delay% ms

Gui 2:+LastFound +ToolWindow +AlwaysOnTop -Caption
WinSet, TransColor, 050505 150 ; Transparency
Gui, 2:Show, x10 y10 w150 h95, ByPerseus

leftbound  := A_ScreenWidth/2 - pixel_box
rightbound := A_ScreenWidth/2 + pixel_box
topbound   := A_ScreenHeight/2 - pixel_box
bottombound:= A_ScreenHeight/2 + pixel_box 

; Hotkeys
Hotkey, %key_stay_on%, stayon
Hotkey, %key_color_swap%, colorswap
Hotkey, %key_hold_mode%, holdmode
Hotkey, %key_off%, offloop
Hotkey, %key_gui_hide%, guihide
Hotkey, %key_exit%, terminate
Hotkey, %key_fastclick%, fastclick
Hotkey, %key_delay_up%, delayup
Hotkey, %key_delay_down%, delaydown
return

;===================================================================================
; Loops & Controls
;===================================================================================

delayup:
fire_delay += delay_step
GuiControl, 2:, DelayText, Pre-Delay: %fire_delay% ms
SoundBeep, 600, 100
return

delaydown:
if (fire_delay > 0) {
    fire_delay -= delay_step
    if (fire_delay < 0) 
        fire_delay := 0
}
GuiControl, 2:, DelayText, Pre-Delay: %fire_delay% ms
SoundBeep, 400, 100
return

colorswap:
if (active_color == color_1) {
    active_color := color_2
    color_label  := "Color-2"
    GuiControl, 2: +cFF00FF, ColorText ; Changes Text Color (Exm: Violet)
    SoundBeep, 400, 100
} else {
    active_color := color_1
    color_label  := "Color-1"
    GuiControl, 2: +c00FF00, ColorText ; Changes Text Color (Exm: Green/Yellow)
    SoundBeep, 800, 100
}
GuiControl, 2:, ColorText, Active: %color_label%
return

stayon:
SoundBeep, 500, 200
SetTimer, loop2, off
SetTimer, loop1, 10
GuiControl, 2:, ModeText, MODE: AutoScan
return

holdmode:
SoundBeep, 500, 200
SetTimer, loop1, off
SetTimer, loop2, 10
GuiControl, 2:, ModeText, MODE : Hold Button (LAlt)
return

offloop:
SoundBeep, 300, 200
SetTimer, loop1, off
SetTimer, loop2, off
GuiControl, 2:, ModeText, MODE : Stopped
return

guihide:
toggle_gui := !toggle_gui
if (toggle_gui)
    Gui, 2: Hide
else
    Gui, 2: Show
return

terminate:
SoundBeep, 200, 500
ExitApp

loop1:
PixelSearchFunction()
return

loop2:
While GetKeyState(key_hold, "P"){
    PixelSearchFunction()
}
return

;===================================================================================
; Macros & Core
;===================================================================================

fastclick:
toggle_fc := !toggle_fc
if (toggle_fc) {
    SoundBeep, 700, 100
    GuiControl, 2: +cRed, ModeText
    GuiControl, 2:, ModeText, MODE : Rapid
} else {
    SoundBeep, 300, 100
    GuiControl, 2: +cWhite, ModeText
    GuiControl, 2:, ModeText, MODE: NONE
}
return

#if toggle_fc
*~$LButton::
While GetKeyState("LButton", "P"){
    DllCall("mouse_event", uint, 2, int, 0, int, 0, uint, 0, int, 0) ; Down
    DllCall("mouse_event", uint, 4, int, 0, int, 0, uint, 0, int, 0) ; Up
    DllCall("Sleep", "UInt", 15)
}
return
#if

PixelSearchFunction() {
    global
    ; search for color
    PixelSearch, FoundX, FoundY, leftbound, topbound, rightbound, bottombound, %active_color%, pixel_sens, Fast RGB
    If !(ErrorLevel)
    {
        ; debug
        If !GetKeyState("LButton")
        {
            if (fire_delay > 0)
                Sleep, %fire_delay% 

            DllCall("mouse_event", uint, 2, int, 0, int, 0, uint, 0, int, 0) ; Bas
            DllCall("mouse_event", uint, 4, int, 0, int, 0, uint, 0, int, 0) ; Bırak
            Sleep, %tap_time%
        }
    }
}
