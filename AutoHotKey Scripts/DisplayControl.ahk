#NoEnv
#SingleInstance force
SetBatchLines -1
ListLines Off
SendMode Input
SetWorkingDir %A_ScriptDir%

CoordMode, Mouse, Relative

global fieldControlNameIs = "Field Control"

ControlGetText, testForFieldControl, Button6, %fieldControlNameIs%
if(testForFieldControl == "Red") {
	Sleep, 10 ;we're EDR, and Field Control was detected
}
else if(testForFieldControl == "Team 1") {
	Sleep, 10 ;we're IQ, and Field Control was detected
}
else {
	InputBox, fieldControlNameIs, % "Is your Field Control named differently? Please input it (Field Sets > first entry)"
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

DisplayChange:
	ControlGet, currentlyInMatch, Checked , , Button22, %fieldControlNameIs%
	ControlGet, currentlyInIntro, Checked , , Button21, %fieldControlNameIs%
	;ToolTip %currentlyInMatch% ;DEBUG
	if(currentlyInMatch) { ;if In-Match is selected
		SendMessage, 0x147, 0, 0, ComboBox1, %fieldControlNameIs%  ; 0x147 is CB_GETCURSEL (for a DropDownList or ComboBox).
		ChoicePos = %ErrorLevel%  ; It will be -1 if there is no item selected.
		ChoicePos += 1  ; Convert from 0-based to 1-based, i.e. so that the first item is known as 1, not 0.
		;ToolTip %ChoicePos% ;DEBUG
		if(ChoicePos == "1") {
			ControlSend,,{F9}, ahk_class Qt5QWindowIcon ;field 1
		}
		else if(ChoicePos == "2") {
			ControlSend,,{F10}, ahk_class Qt5QWindowIcon ;field 2
		}
		else {
			ControlSend,,{F5}, ahk_class Qt5QWindowIcon ;field 3
		}
	}
	else if(currentlyInIntro) {
		if(inFinals == "true") {
				ControlSend,,{F8}, ahk_class Qt5QWindowIcon ;combined, between matches, in finals (bottom displays elim bracket + last scores)
		}
		else {
			ControlSend,,{F7}, ahk_class Qt5QWindowIcon ;combined, between matches
		}
	}
	else {
		ControlSend,,{F6}, ahk_class Qt5QWindowIcon ;not intro, not in-match, show full audience dis?
	}
return

RemoveToolTip:
	SetTimer, RemoveToolTip, Off
	ToolTip
return
