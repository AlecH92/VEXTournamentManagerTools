#NoEnv
#SingleInstance force
#include BinArr.ahk
#include CreateFormData.ahk
SetBatchLines -1
ListLines Off
SendMode Input
SetWorkingDir %A_ScriptDir%

CoordMode, Mouse, Relative

WriteLog(text) {
	FileAppend, % A_NowUTC ": " text "`n", logfile.txt ; can provide a full path to write to another directory
}

Menu, TRAY, nostandard
Menu, TRAY, deleteall
Menu, TRAY, add, Manual Update Field 1, ManualFieldOne
Menu, TRAY, add, Manual Update Field 2, ManualFieldTwo
Menu, TRAY, add, Manual Update Field 3, ManualFieldThree
Menu, TRAY, add, Set Last Match, SetLastMatch
Menu, TRAY, add
Menu, TRAY, add, Exit, Exit

global fieldControlNameIs = "Match Field Set #1"

global fieldOneAddr = "http://192.168.1.181/post"
global fieldTwoAddr = "http://192.168.1.145/post"
global fieldThreeAddr = "http://192.168.1.59/post"
IniRead, fieldOneAddr, lda.ini, Setup, fieldOneAddr, "http://192.168.1.181/post"
IniRead, fieldTwoAddr, lda.ini, Setup, fieldTwoAddr, "http://192.168.1.145/post"
IniRead, fieldThreeAddr, lda.ini, Setup, fieldThreeAddr, "http://192.168.1.59/post"

WriteLog("Field1:" + fieldOneAddr)
WriteLog("Field2:" + fieldTwoAddr)
WriteLog("Field3:" + fieldThreeAddr)

global lastFieldOne = 0
global lastFieldTwo = 0
global lastFieldThree = 0
global actualLastMatch = 0

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
SendMessage, 0x0146, 0, 0, ComboBox1, %fieldControlNameIs%  ; 0x0146 is get count
NumFields = %ErrorLevel%

WriteLog("Detected Fields:" + NumFields)

inFinals := "false"
SetTimer, DisplayChange, 3000

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
	;We need to see what match is currently "on field" and then send data to the 'other' field on match+1
	ControlGetText, StaticOneText, Static1, %fieldControlNameIs%
	;StaticOneText == "Q1"; "Q44" etc.
	;MsgBox %StaticOneText%
	ControlGetText, MatchMode, Static4, %fieldControlNameIs% ;IQ=4, EDR=4, changed in a previous ver?
	if(SubStr(StaticOneText, 1, 1) == "P")
	{
		WriteLog("Found Practice - setting 1,2,3 " + StaticOneText)
		data:={"number":"1"} ; key-val data to be posted
		UpdateFieldOne(data, "Practice")
		
		data:={"number":"2"} ; key-val data to be posted
		UpdateFieldTwo(data, "Practice")
		
		SendMessage, 0x147, 0, 0, ComboBox1, %fieldControlNameIs%  ; 0x147 is CB_GETCURSEL (for a DropDownList or ComboBox).
		ChoicePos = %ErrorLevel%  ; It will be -1 if there is no item selected.
		ChoicePos += 1  ; Convert from 0-based to 1-based, i.e. so that the first item is known as 1, not 0.
		if(NumFields == 3) ;only update field 3 if we have 3 fields
		{
			data:={"number":"3"} ; key-val data to be posted
			UpdateFieldThree(data, "Practice")
		}
		else
		{
			data:={"number":"1"} ; key-val data to be posted
			UpdateFieldThree(data, "Practice")
		}
		return
	}
	if(SubStr(StaticOneText, 1, 1) != "Q")
	{
		;MsgBox % "Uhh this isn't a qualifier??"
		WriteLog("Not a qual? " + StaticOneText)
		return
	}
	currentMatchStr := SubStr(StaticOneText, 2)
	currentMatchStrOrig := SubStr(StaticOneText, 2)
	;MsgBox %currentMatchStr%
	currentMatch := (currentMatchStr * 1) + 1

	SendMessage, 0x147, 0, 0, ComboBox1, %fieldControlNameIs%  ; 0x147 is CB_GETCURSEL (for a DropDownList or ComboBox).
	ChoicePos = %ErrorLevel%  ; It will be -1 if there is no item selected.
	ChoicePos += 1  ; Convert from 0-based to 1-based, i.e. so that the first item is known as 1, not 0.
	if(NumFields == 2)
	{
		;WriteLog("Two fields...")
		;MsgBox % "We've got two fields!"
		if(ChoicePos == "1")
		{
			if(MatchMode != "")
			{
				;match mode is not blank, the match has started. update field 1 to the "next-next" match.
				;FIELD 1
				currentMatch := (currentMatchStrOrig * 1) + 2
				currentMatchStr := "" + currentMatch
				data:={"number":currentMatchStr} ; key-val data to be posted
				UpdateFieldOne(data, "L127")
			}
			else
			{
				;FIELD 1
				currentMatchStr := "" + currentMatchStrOrig
				data:={"number":currentMatchStr} ; key-val data to be posted
				UpdateFieldOne(data, "CP3-3")
			}
			;FIELD 2
			currentMatch := (currentMatchStrOrig * 1) + 1
			lastFieldTwo := currentMatch
			currentMatchStr := "" + currentMatch
			data:={"number":currentMatchStr} ; key-val data to be posted
			UpdateFieldTwo(data, "L134")
			
		}
		else if(ChoicePos == "2")
		{
			if(MatchMode != "")
			{
				;match mode is not blank, the match has started. update field 2 to the "next-next" match.
				;FIELD 2
				currentMatch := (currentMatchStrOrig * 1) + 2
				currentMatchStr := "" + currentMatch
				data:={"number":currentMatchStr} ; key-val data to be posted
				UpdateFieldTwo(data, "L147")
			}
			else
			{
				;FIELD 2
				currentMatchStr := "" + currentMatchStrOrig
				data:={"number":currentMatchStr} ; key-val data to be posted
				UpdateFieldTwo(data, "L179")
			}
			;FIELD 1
			currentMatch := (currentMatchStrOrig * 1) + 1
			currentMatchStr := "" + currentMatch
			data:={"number":currentMatchStr} ; key-val data to be posted
			UpdateFieldOne(data, "L154")
			UpdateFieldThree(data, "L155") ;if we only have two fields, use field three as a pseudo-field-one. we are possibly using this for events where pits may be in another room.
		}
	}
	else if(NumFields == 3)
	{
		;WriteLog("Three fields...")
		;MsgBox % "We've got three fields!"
		if(ChoicePos == "1")
		{
			;WriteLog("From field 1")
			;we're on field 1 - we should send data to field 2 and field 3

			if(MatchMode != "")
			{
				;match mode is not blank, the match has started. update field 1 to the "next-next-next" match.
				;FIELD 1
				currentMatch := (currentMatchStrOrig * 1) + 3
				currentMatchStr := "" + currentMatch
				data:={"number":currentMatchStr} ; key-val data to be posted
				UpdateFieldOne(data, "L173")
			}
			else
			{
				;FIELD 1
				currentMatchStr := "" + currentMatchStrOrig
				data:={"number":currentMatchStr} ; key-val data to be posted
				UpdateFieldOne(data, "CP3-3")
			}
			;FIELD 2
			currentMatchStr := "" + currentMatchStrOrig
			data:={"number":currentMatchStr} ; key-val data to be posted
			UpdateFieldTwo(data, "L179")
			
			;FIELD 3
			currentMatch := (currentMatchStrOrig * 1) + 1
			currentMatchStr := "" + currentMatch
			data:={"number":currentMatchStr} ; key-val data to be posted
			UpdateFieldThree(data, "L186")
		}
		else if(ChoicePos == "2")
		{
			;we're on field 2 - we should send data to field 3 and field 1
			;WriteLog("From field 2")
			if(MatchMode != "")
			{
				;match mode is not blank, the match has started. update field 2 to the "next-next-next" match.
				;FIELD 2
				currentMatch := (currentMatchStrOrig * 1) + 3
				currentMatchStr := "" + currentMatch
				data:={"number":currentMatchStr} ; key-val data to be posted
				UpdateFieldTwo(data, "L198")
			}
			else
			{
				;FIELD 2
				currentMatchStr := "" + currentMatchStrOrig
				data:={"number":currentMatchStr} ; key-val data to be posted
				UpdateFieldTwo(data, "L179")
			}
			;FIELD 3
			currentMatchStr := "" + currentMatchStrOrig
			data:={"number":currentMatchStr} ; key-val data to be posted
			UpdateFieldThree(data, "L204")
			
			;FIELD 1
			currentMatch := (currentMatchStrOrig * 1) + 1
			currentMatchStr := "" + currentMatch
			data:={"number":currentMatchStr} ; key-val data to be posted
			UpdateFieldOne(data, "L210")
		}
		else
		{
			;we're on field 3 - we should send data to field 1 and field 2
			;WriteLog("From field 3")
			if(MatchMode != "")
			{
				;match mode is not blank, the match has started. update field 3 to the "next-next" match.
				;FIELD 3
				currentMatch := (currentMatchStrOrig * 1) + 3
				currentMatchStr := "" + currentMatch
				data:={"number":currentMatchStr} ; key-val data to be posted
				UpdateFieldTwo(data, "L222")
			}
			else
			{
				;FIELD 3
				currentMatchStr := "" + currentMatchStrOrig
				data:={"number":currentMatchStr} ; key-val data to be posted
				UpdateFieldThree(data, "L204")
			}
			;FIELD 1
			currentMatchStr := "" + currentMatchStrOrig
			data:={"number":currentMatchStr} ; key-val data to be posted
			UpdateFieldOne(data, "CP3-3")
			
			;FIELD 2
			currentMatch := (currentMatchStrOrig * 1) + 1
			currentMatchStr := "" + currentMatch
			data:={"number":currentMatchStr} ; key-val data to be posted
			UpdateFieldTwo(data, "CP3-3")
		}
	}

return

RemoveToolTip:
	SetTimer, RemoveToolTip, Off
	ToolTip
return

SendDataToBoard(data, endpoint)
{
	WriteLog("Sending " data["number"] " to " endpoint)
	createFormData(rData,rHeader,data) ; formats the data, stores in rData, header info in rHeader
	;hObject:=comObjCreate("WinHttp.WinHttpRequest.5.1")
	;hObject:=comObjCreate("MSXML2.ServerXMLHTTP.6.0")
	hObject:=comObjCreate("MSXML2.XMLHTTP")
	hObject.open("POST", endpoint, true)
	hObject.setRequestHeader("Content-Type",rHeader) ; set content header
	hObject.send(rData) ; send request with data
}

UpdateFieldOne(data, fromStr)
{
	endpoint:=fieldOneAddr ; url pointing to the API endpoint
	if(data["number"] > actualLastMatch)
	{
		data["number"] := (0 * 1) + 0
		SendDataToBoard(data, endpoint)
		WriteLog("Not updating F1 from " fromStr " to " data["number"] " because it is past the final match number " actualLastMatch)
		return
	}
	try
	{
		SendDataToBoard(data, endpoint)
		WriteLog("Updated F1 from " fromStr " to " data["number"])
	}
	catch e
	{
		;return e.message
		;MsgBox % e.message
		WriteLog("Error sending to F1 from " fromStr " " + e.message)
		lastFieldOne := "" + "err"
	}
}

UpdateFieldTwo(data, fromStr)
{
	endpoint:=fieldTwoAddr ; url pointing to the API endpoint
	if(data["number"] > actualLastMatch)
	{
		data["number"] := (0 * 1) + 0
		SendDataToBoard(data, endpoint)
		WriteLog("Not updating F2 from " fromStr " to " data["number"] " because it is past the final match number " actualLastMatch)
		return
	}
	try
	{
		SendDataToBoard(data, endpoint)
		WriteLog("Updated F2 from " fromStr " to " data["number"])
	}
	catch e
	{
		;return e.message
		;MsgBox % e.message
		WriteLog("Error sending to F2 from " fromStr " " + e.message)
		lastFieldTwo := "" + "err"
	}
}

UpdateFieldThree(data, fromStr)
{
	endpoint:=fieldThreeAddr ; url pointing to the API endpoint
	if(data["number"] > actualLastMatch)
	{
		data["number"] := (0 * 1) + 0
		SendDataToBoard(data, endpoint)
		WriteLog("Not updating F3 from " fromStr " to " data["number"] " because it is past the final match number " actualLastMatch)
		return
	}
	try
	{
		SendDataToBoard(data, endpoint)
		WriteLog("Updated F3 from " fromStr " to " data["number"])
	}
	catch e
	{
		;return e.message
		;MsgBox % e.message
		WriteLog("Error sending to F3 from " fromStr " " + e.message)
		lastFieldThree := "" + "err"
	}
}

ManualFieldOne:
	InputBox, userInput, Enter number to send to field one
	data:={"number":userInput}
	UpdateFieldOne(data, "Manual-F1")
return

ManualFieldTwo:
	InputBox, userInput, Enter number to send to field two
	data:={"number":userInput}
	UpdateFieldTwo(data, "Manual-F2")
return

ManualFieldThree:
	InputBox, userInput, Enter number to send to field three
	data:={"number":userInput}
	UpdateFieldThree(data, "Manual-F3")
return

SetLastMatch:
	InputBox, userInput, Enter the Q## of the last match
	actualLastMatch := (userInput * 1) + 0
return

Exit:
	ExitApp
return