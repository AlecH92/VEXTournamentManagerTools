#NoEnv
#SingleInstance force
#include BinArr.ahk
#include CreateFormData.ahk
SetBatchLines -1
ListLines Off
SendMode Input
SetWorkingDir %A_ScriptDir%

CoordMode, Mouse, Relative

global fieldControlNameIs = "Match Field Set #1"

global fieldOneAddr = "http://192.168.1.181/post"
global fieldTwoAddr = "http://192.168.1.59/post"
global fieldThreeAddr = "http://192.168.1.59/post"

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
	if(SubStr(StaticOneText, 1, 1) != "Q")
	{
		;MsgBox % "Uhh this isn't a qualifier??"
		return
	}
	currentMatchStr := SubStr(StaticOneText, 2)
	;MsgBox %currentMatchStr%
	currentMatch := (currentMatchStr * 1) + 1
	endpoint:=fieldThreeAddr ; url pointing to the API endpoint

	SendMessage, 0x147, 0, 0, ComboBox1, %fieldControlNameIs%  ; 0x147 is CB_GETCURSEL (for a DropDownList or ComboBox).
	ChoicePos = %ErrorLevel%  ; It will be -1 if there is no item selected.
	ChoicePos += 1  ; Convert from 0-based to 1-based, i.e. so that the first item is known as 1, not 0.
	SendMessage, 0x0146, 0, 0, ComboBox1, %fieldControlNameIs%  ; 0x0146 is get count
	NumFields = %ErrorLevel%  ; It will be -1 if there is no item selected.
	;NumFields += 1  ; Convert from 0-based to 1-based, i.e. so that the first item is known as 1, not 0.
	;MsgBox % NumFields
	;ToolTip %ChoicePos% ;DEBUG
	if(NumFields == 2)
	{
		;MsgBox % "We've got two fields!"
		if(ChoicePos == "1") {
			;FIELD 2
			if(lastFieldTwo == currentMatch)
			{
				return
			}
			lastFieldTwo := currentMatch
			endpoint:=fieldTwoAddr ; url pointing to the API endpoint
			currentMatchStr := "" + currentMatch
			;MsgBox %currentMatchStr%
			data:={"number":currentMatchStr} ; key-val data to be posted
			try
			{ ; only way to properly protect from an error here
				createFormData(rData,rHeader,data) ; formats the data, stores in rData, header info in rHeader
				;hObject:=comObjCreate("WinHttp.WinHttpRequest.5.1") ; create WinHttp object
				hObject:=comObjCreate("MSXML2.XMLHTTP.6.0")
				hObject.open("POST",endpoint)
				hObject.setRequestHeader("Content-Type",rHeader) ; set content header
				 ; open a post event to the specified endpoint
				hObject.send(rData) ; send request with data
			}
			catch e
			{
				;return e.message
				;MsgBox % e.message
			}
			
			;FIELD 1
			currentMatch := (currentMatchStr * 1) + 1
			if(lastFieldOne == currentMatch)
			{
				return
			}
			lastFieldOne := currentMatch
			endpoint:=fieldOneAddr ; url pointing to the API endpoint
			currentMatchStr := "" + currentMatch
			;MsgBox %currentMatchStr%
			data:={"number":currentMatchStr} ; key-val data to be posted
			try
			{ ; only way to properly protect from an error here
				createFormData(rData,rHeader,data) ; formats the data, stores in rData, header info in rHeader
				;hObject:=comObjCreate("WinHttp.WinHttpRequest.5.1") ; create WinHttp object
				hObject:=comObjCreate("MSXML2.XMLHTTP.6.0")
				hObject.open("POST",endpoint)
				hObject.setRequestHeader("Content-Type",rHeader) ; set content header
				 ; open a post event to the specified endpoint
				hObject.send(rData) ; send request with data
			}
			catch e
			{
				;return e.message
				;MsgBox % e.message
			}
		}
		else if(ChoicePos == "2") {
			;FIELD 1
			if(lastFieldOne == currentMatch)
			{
				return
			}
			lastFieldOne := currentMatch
			endpoint:=fieldOneAddr ; url pointing to the API endpoint
			currentMatchStr := "" + currentMatch
			;MsgBox %currentMatchStr%
			data:={"number":currentMatchStr} ; key-val data to be posted
			try
			{ ; only way to properly protect from an error here
				createFormData(rData,rHeader,data) ; formats the data, stores in rData, header info in rHeader
				;hObject:=comObjCreate("WinHttp.WinHttpRequest.5.1") ; create WinHttp object
				hObject:=comObjCreate("MSXML2.XMLHTTP.6.0")
				hObject.open("POST",endpoint)
				hObject.setRequestHeader("Content-Type",rHeader) ; set content header
				 ; open a post event to the specified endpoint
				hObject.send(rData) ; send request with data
			}
			catch e
			{
				;return e.message
				;MsgBox % e.message
			}
			
			;FIELD 2
			currentMatch := (currentMatchStr * 1) + 1
			if(lastFieldTwo == currentMatch)
			{
				return
			}
			lastFieldTwo := currentMatch
			endpoint:=fieldTwoAddr ; url pointing to the API endpoint
			currentMatchStr := "" + currentMatch
			;MsgBox %currentMatchStr%
			data:={"number":currentMatchStr} ; key-val data to be posted
			try
			{ ; only way to properly protect from an error here
				createFormData(rData,rHeader,data) ; formats the data, stores in rData, header info in rHeader
				;hObject:=comObjCreate("WinHttp.WinHttpRequest.5.1") ; create WinHttp object
				hObject:=comObjCreate("MSXML2.XMLHTTP.6.0")
				hObject.open("POST",endpoint)
				hObject.setRequestHeader("Content-Type",rHeader) ; set content header
				 ; open a post event to the specified endpoint
				hObject.send(rData) ; send request with data
			}
			catch e
			{
				;return e.message
				;MsgBox % e.message
			}
		}
	}
	else if(NumFields == 3)
	{
		;MsgBox % "We've got three fields!"
		if(ChoicePos == "1") {
			;we're on field 1 - we should send data to field 2 and field 3

			;FIELD 2
			if(lastFieldTwo == currentMatch)
			{
				return
			}
			lastFieldTwo := currentMatch
			endpoint:=fieldTwoAddr ; url pointing to the API endpoint
			currentMatchStr := "" + currentMatch
			;MsgBox %currentMatchStr%
			data:={"number":currentMatchStr} ; key-val data to be posted
			try
			{ ; only way to properly protect from an error here
				createFormData(rData,rHeader,data) ; formats the data, stores in rData, header info in rHeader
				;hObject:=comObjCreate("WinHttp.WinHttpRequest.5.1") ; create WinHttp object
				hObject:=comObjCreate("MSXML2.XMLHTTP.6.0")
				hObject.open("POST",endpoint)
				hObject.setRequestHeader("Content-Type",rHeader) ; set content header
				 ; open a post event to the specified endpoint
				hObject.send(rData) ; send request with data
			}
			catch e
			{
				;return e.message
				;MsgBox % e.message
			}
			
			;FIELD 3
			currentMatch := (currentMatchStr * 1) + 1
			if(lastFieldThree == currentMatch)
			{
				return
			}
			lastFieldThree := currentMatch
			endpoint:=fieldThreeAddr ; url pointing to the API endpoint
			currentMatchStr := "" + currentMatch
			;MsgBox %currentMatchStr%
			data:={"number":currentMatchStr} ; key-val data to be posted
			try
			{ ; only way to properly protect from an error here
				createFormData(rData,rHeader,data) ; formats the data, stores in rData, header info in rHeader
				;hObject:=comObjCreate("WinHttp.WinHttpRequest.5.1") ; create WinHttp object
				hObject:=comObjCreate("MSXML2.XMLHTTP.6.0")
				hObject.open("POST",endpoint)
				hObject.setRequestHeader("Content-Type",rHeader) ; set content header
				 ; open a post event to the specified endpoint
				hObject.send(rData) ; send request with data
			}
			catch e
			{
				;return e.message
				;MsgBox % e.message
			}
		}
		else if(ChoicePos == "2") {
			;we're on field 2 - we should send data to field 3 and field 1

			;FIELD 3
			if(lastFieldThree == currentMatch)
			{
				return
			}
			lastFieldThree := currentMatch
			endpoint:=fieldThreeAddr ; url pointing to the API endpoint
			currentMatchStr := "" + currentMatch
			;MsgBox %currentMatchStr%
			data:={"number":currentMatchStr} ; key-val data to be posted
			try
			{ ; only way to properly protect from an error here
				createFormData(rData,rHeader,data) ; formats the data, stores in rData, header info in rHeader
				;hObject:=comObjCreate("WinHttp.WinHttpRequest.5.1") ; create WinHttp object
				hObject:=comObjCreate("MSXML2.XMLHTTP.6.0")
				hObject.open("POST",endpoint)
				hObject.setRequestHeader("Content-Type",rHeader) ; set content header
				 ; open a post event to the specified endpoint
				hObject.send(rData) ; send request with data
			}
			catch e
			{
				;return e.message
				;MsgBox % e.message
			}
			
			;FIELD 1
			currentMatch := (currentMatchStr * 1) + 1
			if(lastFieldOne == currentMatch)
			{
				return
			}
			lastFieldOne := currentMatch
			endpoint:=fieldOneAddr ; url pointing to the API endpoint
			currentMatchStr := "" + currentMatch
			;MsgBox %currentMatchStr%
			data:={"number":currentMatchStr} ; key-val data to be posted
			try
			{ ; only way to properly protect from an error here
				createFormData(rData,rHeader,data) ; formats the data, stores in rData, header info in rHeader
				;hObject:=comObjCreate("WinHttp.WinHttpRequest.5.1") ; create WinHttp object
				hObject:=comObjCreate("MSXML2.XMLHTTP.6.0")
				hObject.open("POST",endpoint)
				hObject.setRequestHeader("Content-Type",rHeader) ; set content header
				 ; open a post event to the specified endpoint
				hObject.send(rData) ; send request with data
			}
			catch e
			{
				;return e.message
				;MsgBox % e.message
			}
		}
		else {
			;we're on field 3 - we should send data to field 1 and field 2

			;FIELD 1
			if(lastFieldOne == currentMatch)
			{
				return
			}
			lastFieldOne := currentMatch
			endpoint:=fieldOneAddr ; url pointing to the API endpoint
			currentMatchStr := "" + currentMatch
			;MsgBox %currentMatchStr%
			data:={"number":currentMatchStr} ; key-val data to be posted
			try
			{ ; only way to properly protect from an error here
				createFormData(rData,rHeader,data) ; formats the data, stores in rData, header info in rHeader
				;hObject:=comObjCreate("WinHttp.WinHttpRequest.5.1") ; create WinHttp object
				hObject:=comObjCreate("MSXML2.XMLHTTP.6.0")
				hObject.open("POST",endpoint)
				hObject.setRequestHeader("Content-Type",rHeader) ; set content header
				 ; open a post event to the specified endpoint
				hObject.send(rData) ; send request with data
			}
			catch e
			{
				;return e.message
				;MsgBox % e.message
			}
			
			;FIELD 2
			currentMatch := (currentMatchStr * 1) + 1
			if(lastFieldTwo == currentMatch)
			{
				return
			}
			lastFieldTwo := currentMatch
			endpoint:=fieldTwoAddr ; url pointing to the API endpoint
			currentMatchStr := "" + currentMatch
			;MsgBox %currentMatchStr%
			data:={"number":currentMatchStr} ; key-val data to be posted
			try
			{ ; only way to properly protect from an error here
				createFormData(rData,rHeader,data) ; formats the data, stores in rData, header info in rHeader
				;hObject:=comObjCreate("WinHttp.WinHttpRequest.5.1") ; create WinHttp object
				hObject:=comObjCreate("MSXML2.XMLHTTP.6.0")
				hObject.open("POST",endpoint)
				hObject.setRequestHeader("Content-Type",rHeader) ; set content header
				 ; open a post event to the specified endpoint
				hObject.send(rData) ; send request with data
			}
			catch e
			{
				;return e.message
				;MsgBox % e.message
			}
		}
	}

return

RemoveToolTip:
	SetTimer, RemoveToolTip, Off
	ToolTip
return
