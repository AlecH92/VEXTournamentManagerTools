#NoEnv
#SingleInstance force
SetBatchLines -1
ListLines Off
SendMode Input
SetWorkingDir %A_ScriptDir%

CoordMode, Mouse, Relative

#Include Acc.ahk
#Include VEX_Shared.ahk

global fieldControlNameIs = "Match Field Set #1"

ControlGetText, testForFieldControl, Button7, %fieldControlNameIs%
if (InStr(testForFieldControl, "Red") or InStr(testForFieldControl, "Blue")) {
	Sleep, 10 ;we're EDR, and Field Control was detected
}
else if InStr(testForFieldControl, "Team") {
	Sleep, 10 ;we're IQ, and Field Control was detected
}
else {
	InputBox, fieldControlNameIs, % "Is your Field Control named differently? Please input it (Field Sets > first entry)"
}

global ObsClass = "Qt5152QWindowIcon"
IniRead, ObsClass, dc.ini, Setup, ObsClass, "Qt5152QWindowIcon"

UpdateButtonDefinitions()

;look for OBS and prompt if it is not located?
if !WinExist("ahk_class " ObsClass)
{
	;code from https://www.autohotkey.com/boards/viewtopic.php?t=72982
	MsgBox "OBS not located, please select it from the next popup window"
	#Persistent        ; Window open/close detection
	Gui +LastFound        ; Window open/close detection
	hWnd := WinExist()        ; Window open/close detection
	DllCall( "RegisterShellHookWindow", UInt,hWnd )
	MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
	OnMessage( MsgNum, "ShellMessage" )

	; To prevent Menu command errors from stopping script.
	Menu, MenuName, UseErrorLevel
	WinGet, OpenWindow, List
	Menu, WindowMenu, Delete
	Menu, WindowMenu, Add, Rescan Windows, GuiReset
	Menu, WindowMenu, Icon, Rescan Windows, C:\Windows\System32\imageres.dll, 140

	Loop, %OpenWindow%
	{
		WinGetTitle, Title, % "ahk_id " OpenWindow%A_Index%
		WinGetClass, Class, % "ahk_id " OpenWindow%A_Index%
		WinGet, AppName, ProcessPath, %Title%

		If (Title != "" and Class != "BasicWindow" and Title != "Start"
			and Title != "Program Manager")
		{
			Title := StrSplit(Title,"|")
			Menu, WindowMenu, Insert,, % Title[1] . " |" . Class, MenuChoice
			Menu, WindowMenu, Icon, % Title[1] . " |" . Class, %AppName%
			If ErrorLevel
				Menu, WindowMenu, Icon, % Title[1] . " |" . Class
			, C:\WINDOWS\System32\SHELL32.dll,36
		}
	}
	Menu, WindowMenu, Show
}

inFinals := "false"
SetTimer, DisplayChange, 1000

Loop {
	F3::
		if(inFinals == "true") {
			inFinals := "false"
		}
		else {
			inFinals := "true"
		}
		ToolTip %inFinals%
		SetTimer, RemoveToolTip, 1500
	return
}

MenuChoice:
	ProcessID := StrSplit(A_ThisMenuItem,"|")
	;WinActivate, % "ahk_id " ProcessID[2]
	ObsClass := ProcessID[2]
	IniWrite, %ObsClass%, dc.ini, Setup, ObsClass
	;ToolTip %ObsClass%
	;SetTimer, RemoveToolTip, 1500
	;MsgBox "ObsClass set to %ObsClass%"
return

DisplayChange:
	ControlGet, currentlyInMatch, Checked , , %InMatchButton%, %fieldControlNameIs%
	if ErrorLevel
	{
		return ;we had an issue finding Field Control?? Don't do anything...
	}
	ControlGet, currentlyInIntro, Checked , , %IntroButton%, %fieldControlNameIs%
	ControlGet, playSoundsEnabled, Checked , , %PlaySoundsCheckbox%, %fieldControlNameIs%
	;ToolTip %currentlyInMatch% ;DEBUG
	if(currentlyInMatch || playSoundsEnabled) { ;if In-Match is selected
		SendMessage, 0x147, 0, 0, ComboBox1, %fieldControlNameIs%  ; 0x147 is CB_GETCURSEL (for a DropDownList or ComboBox).
		ChoicePos = %ErrorLevel%  ; It will be -1 if there is no item selected.
		ChoicePos += 1  ; Convert from 0-based to 1-based, i.e. so that the first item is known as 1, not 0.
		;ToolTip %ChoicePos% ;DEBUG
		if(ChoicePos == "1") {
			ControlSend,,{F9}, % "ahk_class " ObsClass ;field 1
		}
		else if(ChoicePos == "2") {
			ControlSend,,{F10}, % "ahk_class " ObsClass ;field 2
		}
		else {
			ControlSend,,{F5}, % "ahk_class " ObsClass ;field 3
		}
	}
	else if(currentlyInIntro) {
		if(inFinals == "true") {
				ControlSend,,{F8}, % "ahk_class " ObsClass ;combined, between matches, in finals (bottom displays elim bracket + last scores)
		}
		else {
			ControlSend,,{F7}, % "ahk_class " ObsClass ;combined, between matches
		}
	}
	else {
		ControlSend,,{F6}, % "ahk_class " ObsClass ;not intro, not in-match, show full audience dis?
	}
return

RemoveToolTip:
	SetTimer, RemoveToolTip, Off
	ToolTip
return
