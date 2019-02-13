#SingleInstance force
#Include Const_TreeView.ahk
#Include Const_Process.ahk
#Include Const_Memory.ahk
#Include RemoteTreeViewClass.ahk
SetBatchLines -1
ListLines Off
SendMode Input
SetWorkingDir %A_ScriptDir%

CoordMode, Mouse, Relative

global MyTV
global hItem
global TVId
global plusX = 0
global plusXmax = 0

WinId := WinExist("VEX Tournament Manager")
Sleep, 30
ControlGet TVId, Hwnd, , SysTreeView321, VEX Tournament Manager

WinGetPos,,,TMWidth,,VEX Tournament Manager
;ToolTip %TMWidth% ;DEBUG
if(TMWidth > 3000) {
	plusX := 63
	plusXMax := 23
} else {
	plusX := 43
	plusXMax := 14
}
SetTimer, RefScore, 1000
Loop {
	F3::Pause
}

RefScore:
	WinActivate VEX Tournament Manager
	ControlGetPos,cx,cy,w,h,,ahk_id%TVId%
	cx := cx+plusX
	w := cx+plusXMax
	Sleep, 30
	PixelSearch, Px, Py, cx, cy, w, cy+h, 0x787878, 0, Fast RGB
	if (ErrorLevel) {
		return
	} else {
		click %Px%, %Py%
		Sleep, 1000
		ControlClick, Save Scores, VEX Tournament Manager,,,,NA
		Sleep, 1000
		MouseMove, %Px%,%Py%
		Sleep, 30
		SendEvent {Click right}
		Sleep, 30
		SendEvent {Down 6}
		Sleep, 30
		SendEvent {Enter}
		Sleep, 1000
		SendEvent {Down 3}
		Sleep, 100
	}
return