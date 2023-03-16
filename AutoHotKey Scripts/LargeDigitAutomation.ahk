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

global fieldControlNameIs = "Match Field Set #1"

global fieldOneAddr = "http://192.168.1.181/post"
global fieldTwoAddr = "http://192.168.1.46/post"
global fieldThreeAddr = "http://192.168.1.145/post"

WriteLog("Field1:" + fieldOneAddr)
WriteLog("Field2:" + fieldTwoAddr)
WriteLog("Field3:" + fieldThreeAddr)

global lastFieldOne = 0
global lastFieldTwo = 0
global lastFieldThree = 0

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
	if(SubStr(StaticOneText, 1, 1) == "P")
	{
		WriteLog("Found Practice - setting 1,2,3 " + StaticOneText)
		data:={"number":"1"} ; key-val data to be posted
		UpdateFieldOne(data, "Practice")
		
		data:={"number":"2"} ; key-val data to be posted
		UpdateFieldTwo(data, "Practice")
		
		data:={"number":"3"} ; key-val data to be posted
		UpdateFieldThree(data, "Practice")
		return
	}
	if(SubStr(StaticOneText, 1, 1) != "Q")
	{
		;MsgBox % "Uhh this isn't a qualifier??"
		WriteLog("Not a qual? " + StaticOneText)
		return
	}
	currentMatchStr := SubStr(StaticOneText, 2)
	;MsgBox %currentMatchStr%
	currentMatch := (currentMatchStr * 1) + 1

	SendMessage, 0x147, 0, 0, ComboBox1, %fieldControlNameIs%  ; 0x147 is CB_GETCURSEL (for a DropDownList or ComboBox).
	ChoicePos = %ErrorLevel%  ; It will be -1 if there is no item selected.
	ChoicePos += 1  ; Convert from 0-based to 1-based, i.e. so that the first item is known as 1, not 0.
	if(NumFields == 2)
	{
		;WriteLog("Two fields...")
		;MsgBox % "We've got two fields!"
		if(ChoicePos == "1") {

			;FIELD 2
			currentMatch := (currentMatchStr * 1) + 1
			if(lastFieldTwo != currentMatch)
			{
				lastFieldTwo := currentMatch
				currentMatchStr := "" + currentMatch
				data:={"number":currentMatchStr} ; key-val data to be posted
				UpdateFieldTwo(data, "CP2-1")
			}
			
		}
		else if(ChoicePos == "2") {

			;FIELD 1
			currentMatch := (currentMatchStr * 1) + 1
			if(lastFieldOne != currentMatch)
			{
				lastFieldOne := currentMatch
				currentMatchStr := "" + currentMatch
				data:={"number":currentMatchStr} ; key-val data to be posted
				UpdateFieldOne(data, "CP2-2")
			}
		}
	}
	else if(NumFields == 3)
	{
		;WriteLog("Three fields...")
		;MsgBox % "We've got three fields!"
		if(ChoicePos == "1") {
			;WriteLog("From field 1")
			;we're on field 1 - we should send data to field 2 and field 3

			;FIELD 2
			currentMatchStr := "" + currentMatch
			if(lastFieldTwo != currentMatch)
			{
				lastFieldTwo := currentMatch
				currentMatchStr := "" + currentMatch
				data:={"number":currentMatchStr} ; key-val data to be posted
				UpdateFieldTwo(data, "CP3-1")
			}
			
			;FIELD 3
			currentMatch := (currentMatchStr * 1) + 1
			if(lastFieldThree != currentMatch)
			{
				lastFieldThree := currentMatch
				currentMatchStr := "" + currentMatch
				data:={"number":currentMatchStr} ; key-val data to be posted
				UpdateFieldThree(data, "CP3-1")
			}
		}
		else if(ChoicePos == "2") {
			;we're on field 2 - we should send data to field 3 and field 1
			;WriteLog("From field 2")
			;FIELD 3
			currentMatchStr := "" + currentMatch
			if(lastFieldThree != currentMatch)
			{
				lastFieldThree := currentMatch
				currentMatchStr := "" + currentMatch
				data:={"number":currentMatchStr} ; key-val data to be posted
				UpdateFieldThree(data, "CP3-2")
			}
			
			;FIELD 1
			currentMatch := (currentMatchStr * 1) + 1
			if(lastFieldOne != currentMatch)
			{
				lastFieldOne := currentMatch
				currentMatchStr := "" + currentMatch
				data:={"number":currentMatchStr} ; key-val data to be posted
				UpdateFieldOne(data, "CP3-2")
			}
		}
		else {
			;we're on field 3 - we should send data to field 1 and field 2
			;WriteLog("From field 3")
			;FIELD 1
			currentMatchStr := "" + currentMatch
			if(lastFieldOne != currentMatch)
			{
				lastFieldOne := currentMatch
				data:={"number":currentMatchStr} ; key-val data to be posted
				UpdateFieldOne(data, "CP3-3")
			}
			
			;FIELD 2
			currentMatch := (currentMatchStr * 1) + 1
			if(lastFieldTwo != currentMatch)
			{
				lastFieldTwo := currentMatch
				currentMatchStr := "" + currentMatch
				data:={"number":currentMatchStr} ; key-val data to be posted
				UpdateFieldTwo(data, "CP3-3")
			}
		}
	}

return

RemoveToolTip:
	SetTimer, RemoveToolTip, Off
	ToolTip
return

SendDataToBoard(data, endpoint)
{
	createFormData(rData,rHeader,data) ; formats the data, stores in rData, header info in rHeader
	hObject:=comObjCreate("MSXML2.XMLHTTP.6.0")
	hObject.timeout :=2000 ; 2 second timeout
	hObject.open("POST",endpoint)
	hObject.setRequestHeader("Content-Type",rHeader) ; set content header
	hObject.send(rData) ; send request with data
}

UpdateFieldOne(strinput, fromStr)
{
	endpoint:=fieldOneAddr ; url pointing to the API endpoint
	data:={"number":strinput} ; key-val data to be posted
	try
	{
		SendDataToBoard(data, endpoint)
		WriteLog("Updated F1 from " fromStr " to " currentMatchStr)
	}
	catch e
	{
		;return e.message
		;MsgBox % e.message
		WriteLog("Error sending to F1 from " fromStr " " + e.message)
		lastFieldOne := "" + "err"
	}
}

UpdateFieldTwo(strinput, fromStr)
{
	endpoint:=fieldTwoAddr ; url pointing to the API endpoint
	data:={"number":strinput} ; key-val data to be posted
	try
	{
		SendDataToBoard(data, endpoint)
		WriteLog("Updated F2 from " fromStr " to " currentMatchStr)
	}
	catch e
	{
		;return e.message
		;MsgBox % e.message
		WriteLog("Error sending to F2 from " fromStr " " + e.message)
		lastFieldTwo := "" + "err"
	}
}

UpdateFieldThree(strinput, fromStr)
{
	endpoint:=fieldThreeAddr ; url pointing to the API endpoint
	data:={"number":strinput} ; key-val data to be posted
	try
	{
		SendDataToBoard(data, endpoint)
		WriteLog("Updated F3 from " fromStr " to " currentMatchStr)
	}
	catch e
	{
		;return e.message
		;MsgBox % e.message
		WriteLog("Error sending to F3 from " fromStr " " + e.message)
		lastFieldThree := "" + "err"
	}
}