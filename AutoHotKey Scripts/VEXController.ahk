#NoEnv
#SingleInstance force
#Include Const_TreeView.ahk
#Include Const_Process.ahk
#Include Const_Memory.ahk
#Include RemoteTreeViewClass.ahk

SetBatchLines -1
ListLines Off
SendMode Input
SetWorkingDir %A_ScriptDir%

CoordMode, Mouse, Screen

global numMatches = 0
global sleepDelay = 10
global FoundX = 0
global FoundY = 0
global DebugActive = "false"
;global DebugActive = "true"

global AutoQueueMatches = "true" ;if true, uncomment line below
SetTimer, CheckQueue, 1000
global RefScoreSetVar = "false" ;if true, uncomment line below
;SetTimer, RefScoreSet, 5000 ;Disabled, untested in latest TM versions
global matchStartTime = A_TickCount
global matchTimeDelay = 110000 ;IQ=65000, EDR=110000 Field Control Button 5 Text: "Red" = 110000, "Team 1" = 65000
global QueuedMatch = 1
global MyTV
global hItem
global TVId
global Qual1
global oAcc
global matchQueueDifference
global failedToQueueCount = 0
global theScreenScaling = 0
global theScreenScalingTest = 100 ;this test value increases by 25 every 'failed' test
global lastSavedMatchText = ""
;MsgBox %A_ScreenWidth% ;DEBUG
global fieldControlNameIs = "Field Control"
global inVexIQMode = "false"

;Menu, TRAY, Icon, favicon.ico ;icon is set via AHK2EXE
Menu, TRAY, nostandard
WinId := WinExist("VEX Tournament Manager")
Sleep, 30
ControlGet TVId, Hwnd, , SysTreeView321, VEX Tournament Manager
MyTV := new RemoteTreeView(TVId)
hItem = 0  ; Causes the loop's first iteration to start the search at the top of the tree.
WinActivate VEX Tournament Manager
Sleep, 30
hItem := MyTV.GetNext(hItem, "Full") ;field test
hItem := MyTV.GetNext(hItem, "Full") ;practice
hItem := MyTV.GetNext(hItem, "Full") ;qualification
MyTV.SetSelection(hItem) ;select qualification
Send {RIGHT} ;expand qualification (if expanded, select qual 1)
hItem := MyTV.GetNext(hItem, "Full") ;qual 1
Qual1 := hItem
oAcc := Acc_Get("Object", "4", 0, "ahk_id " TVId) ;using the Acc library we can access a SysTreeView's child x/y coordinates
Qual1Loc := Acc_Location(oAcc, 5)
Qual2Loc := Acc_Location(oAcc, 6)
oAccLoc := Acc_Location(oAcc)
thisX := oAccLoc.x
thisY := oAccLoc.y
;MsgBox %thisX% %thisY% ;DEBUG
matchQueueDifference := (Qual2Loc.y - Qual1Loc.y) / 2 ;this is 16 / 2 = 8 on a 1920x1200 screen

ControlGetText, EDRorIQ, Button6, %fieldControlNameIs%
if(EDRorIQ == "Red") {
	matchTimeDelay = 110000 ;Autonomous Winner below None = Red for EDR
}
else if(EDRorIQ == "Team 1") {
	matchTimeDelay = 65000 ;Autonomous Winner below None = Team 1 for IQ
}
else {
	InputBox, fieldControlNameIs, % "Is your Field Control named differently? Please input it (Field Sets > first entry)"
}
ControlGetText, EDRorIQ, Button6, %fieldControlNameIs%
if(EDRorIQ == "Red") {
	matchTimeDelay = 110000 ;Autonomous Winner below None = Red for EDR
}
else if(EDRorIQ == "Team 1") {
	matchTimeDelay = 65000 ;Autonomous Winner below None = Team 1 for IQ
	inVexIQMode := "true"
}
else {
	ToolTip matchTimeDelay is unknown`, EDR by default
	InputBox, theScreenScaling, % "matchTimeDelay unknown? 110000 is default"
	matchTimeDelay = 110000 ;2017 IQ has no auton winner buttons - they are invisible. still is found as "Team 1"
}

checkScreenScaling()

if(DebugActive == "true") {
	MsgBox The screen scaling was determined to be ( %theScreenScaling% )( %theScreenScalingTest% )
}

if(theScreenScaling == 0)
{
	InputBox, theScreenScaling, % "Screen scaling? 100% is default"
}
if(theScreenScaling == 0)
{
	theScreenScaling = 100 ;if it's still 0, set to 100
}

if(DebugActive == "true") {
	MsgBox The screen scaling was determined to be ( %theScreenScaling% )( %theScreenScalingTest% )
}

SetMenu()

Loop {
	3Joy3:: ;we use JoyX, 2JoyX and 3JoyX in case the connected joystick registers as the 2nd or 3rd device
	2Joy3:: ;intro
	Joy3::
		ControlGetText, MatchMode, Static4, %fieldControlNameIs%
		if(MatchMode != "")
		{
			return ;MatchMode wasn't blank - we're in Auton, between Auton and Driver, or in Driver. Bail.
		}
		WinActivate, %fieldControlNameIs%
		Sleep, sleepDelay
		WinActivate, %fieldControlNameIs%
		Sleep, sleepDelay
		ControlClick, Button22, %fieldControlNameIs%,,,,NA
		ControlClick, Button22, %fieldControlNameIs%,,,,NA
		ControlClick, Button22, %fieldControlNameIs%,,,,NA
		Sleep, sleepDelay
	return
	3Joy5::
	2Joy5:: ;auton none
	Joy5::
		WinActivate, %fieldControlNameIs%
		Sleep, sleepDelay
		WinActivate, %fieldControlNameIs%
		Sleep, sleepDelay
		ControlClick, Button4, %fieldControlNameIs%,,,,NA
		ControlClick, Button4, %fieldControlNameIs%,,,,NA
		ControlClick, Button4, %fieldControlNameIs%,,,,NA
		Sleep, sleepDelay
	return
	3Joy6::
	2Joy6:: ;auton red
	Joy6::
		WinActivate, %fieldControlNameIs%
		Sleep, sleepDelay
		WinActivate, %fieldControlNameIs%
		Sleep, sleepDelay
		ControlClick, Button5, %fieldControlNameIs%,,,,NA
		ControlClick, Button5, %fieldControlNameIs%,,,,NA
		ControlClick, Button5, %fieldControlNameIs%,,,,NA
		Sleep, sleepDelay
	return
	3Joy7::
	2Joy7:: ;auton blue
	Joy7::
		WinActivate, %fieldControlNameIs%
		Sleep, sleepDelay
		WinActivate, %fieldControlNameIs%
		Sleep, sleepDelay
		ControlClick, Button6, %fieldControlNameIs%,,,,NA
		ControlClick, Button6, %fieldControlNameIs%,,,,NA
		ControlClick, Button6, %fieldControlNameIs%,,,,NA
		Sleep, sleepDelay
	return
	3Joy1::
	2Joy1:: ;saved results
	Joy1::
		ControlGetText, MatchMode, Static4, %fieldControlNameIs%
		if(MatchMode != "")
		{
			return
		}
		WinActivate, %fieldControlNameIs%
		Sleep, sleepDelay
		WinActivate, %fieldControlNameIs%
		Sleep, sleepDelay
		ControlClick, Button24, %fieldControlNameIs%,,,,NA
		ControlClick, Button24, %fieldControlNameIs%,,,,NA
		ControlClick, Button24, %fieldControlNameIs%,,,,NA
		Sleep, sleepDelay
	return
	3Joy2::
	2Joy2:: ;start match
	Joy2::
		ControlGetText, MatchMode, Static4, %fieldControlNameIs%
		if(MatchMode == "AUTONOMOUS" || MatchMode == "DRIVER CONTROL") {
			return ;bail, we're still in a match mode
		}
		WinActivate, %fieldControlNameIs%
		Sleep, sleepDelay
		WinActivate, %fieldControlNameIs%
		Sleep, sleepDelay*3
		ControlClick, Button12, %fieldControlNameIs%,,,,NA
		Sleep, sleepDelay
		if(inVexIQMode == "true") {
			matchStartTime = %A_TickCount%
			SetTimer, BackToIntro, Off ;in case we start matches back to back quickly, disable switching to intro after we've started a match
			QueuedMatch = 0
		}
		if(MatchMode == "PAUSED" || MatchMode == "DRIVER CONTROL") ;check the text under Match Timer for Paused or Driver Control
		{
			matchStartTime = %A_TickCount%
			SetTimer, BackToIntro, Off ;in case we start matches back to back quickly, disable switching to intro after we've started a match
			QueuedMatch = 0
		}
	return
	3Joy4::
	2Joy4:: ;queue match
	Joy4::
		QueueMatch()
	return
}

SetCurrentMatch:
	Menu, TRAY, delete, Current Match: %numMatches%
	InputBox, numMatches, Currently: %numMatches%
	hItem := Qual1
	Loop, %numMatches% {
		hItem := MyTV.GetNext(hItem, "Full")
		MyTV.SetSelection(hItem)
	}
	SetMenu()
return

SetMatchTimeDelay:
	Menu, TRAY, delete, Match Length: %matchTimeDelay%
	InputBox, matchTimeDelay, Set Match Length, Set the driver mode length plus five seconds to auto queue after (EDR 110000 IQ 65000)
	SetMenu()
return

SetSleepDelay:
	Menu, TRAY, delete, Sleep Delay: %sleepDelay%
	InputBox, sleepDelay, Currently: %sleepDelay%
	SetMenu()
return

SetDebugActive:
	if(DebugActive == "true") {
		DebugActive := "false"
	}
	else {
		DebugActive := "true"
	}
	SetMenu()
return

BackToIntro:
	ControlGetText, MatchMode, Static4, %fieldControlNameIs%
	if(MatchMode != "")
	{
		return
	}
	SetTimer, BackToIntro, Off
	ControlClick, Button22, %fieldControlNameIs%,,,,NA ;intro
	ControlClick, Button22, %fieldControlNameIs%,,,,NA
	ControlClick, Button22, %fieldControlNameIs%,,,,NA
return

RefScoreSet:
	if(RefScoreSetVar == "true") {
		WinActivate, VEX Tournament Manager
		ControlGetPos,cx,cy,w,h,,ahk_id%TVId%
		Sleep, sleepDelay
		ImageSearch, Px, Py, cx, cy, cx+w, cy+h, *100, refs.bmp ;search for refs
		if (ErrorLevel = 2) { ;failed
			return
		}
		else if (ErrorLevel = 1) { ;not found
			return
		}
		else { ;worked
			click %Px%, %Py%
			Sleep, sleepDelay
			ControlClick, Save Scores, VEX Tournament Manager,,,,NA
			return
		} ;end search for refs
	}
return


SwapAutoQueue:
	if(AutoQueueMatches == "true") {
		AutoQueueMatches := "false"
	}
	else {
		AutoQueueMatches := "true"
	}
	SetMenu()
return

RefScoreSetSwap:
	if(RefScoreSetVar == "true") {
		SetTimer, RefScoreSet, Off
		RefScoreSetVar := "false"
	}
	else {
		SetTimer, RefScoreSet, 3000
		RefScoreSetVar := "true"
	}
	SetMenu()
return

SetMenu() {
	Menu, TRAY, deleteall
	Menu, TRAY, add, Current Match: %numMatches%, SetCurrentMatch
	Menu, TRAY, add, Sleep Delay: %sleepDelay%, SetSleepDelay
	Menu, TRAY, add, Auto Queue Matches: %AutoQueueMatches%, SwapAutoQueue
	Menu, TRAY, add, Auto Save Ref Scores: %RefScoreSetVar%, RefScoreSetSwap
	Menu, TRAY, add, Debugging Active: %DebugActive%, SetDebugActive
	Menu, TRAY, add, Match Length: %matchTimeDelay%, SetMatchTimeDelay
	Menu, TRAY, add, Last Saved Match: %lastSavedMatchText%
	Menu, TRAY, add
	Menu, TRAY, add, Exit, Exit
return
}

CheckQueue:
	theDifference := A_TickCount - matchStartTime
	if(DebugActive == "true") {
		;ToolTip %A_TickCount% %matchStartTime% %theDifference% %QueuedMatch% ;DEBUG
	}
	if(AutoQueueMatches == "true") {
		if(QueuedMatch == 0) {
			if(A_TickCount - matchStartTime > matchTimeDelay) {
				QueueMatch()
			}
		}
	}
return

QueueMatch() {
	ControlGetText, MatchMode, Static4, %fieldControlNameIs% ;IQ=4, EDR=4, changed in a previous ver?
	if(MatchMode != "")
	{
		nmpone := numMatches + 1
		MsgBox Tried to queue Qual %nmpone% during %MatchMode%
		return
	}
	if(failedToQueueCount > 2)
	{
		nmpone := numMatches + 1
		MsgBox Failed to queue match Qual %nmpone% three times
		failedToQueueCount := 0
		return
	}
	QueuedMatch = 1
	WinActivate VEX Tournament Manager
	ControlClick, SysTreeView321, VEX Tournament Manager,,,,NA
	Sleep, sleepDelay*2
	MyTV.SetSelection(hItem)
	oRect := Acc_Location(oAcc, 5+numMatches) ;Qual 1 is 5, 5+0 = Qual 1, 5+1 = Qual 2 etc
	accName := oAcc.AccName(5+numMatches) ;we get the name "Qual #" to compare down below
	if(DebugActive == "true") {
		MsgBox QueueMatch:Acc Found %accName%
	}
	IfNotInString, accName, Qual
	{
		;check that we are actually queueing a Qual match
		if(DebugActive == "true") {
			MsgBox QueueMatch:NotInString We got a non-Qual, resetting
		}
		hItem = 0
		return
	}
	theY := oRect.y + matchQueueDifference
	theX := oRect.x
	theX := theX * (theScreenScaling / 100)
	theY := theY * (theScreenScaling / 100)
	if(DebugActive == "true") {
		MsgBox %theX% %theY%
	}
	MouseMove, %theX%,%theY%
	Sleep, sleepDelay*3
	SendEvent {Click right}
	Sleep, sleepDelay*6
	SendEvent {Down}
	Sleep, sleepDelay*6
	SendEvent {Enter}
	Sleep, sleepDelay*6
	WinActivate, %fieldControlNameIs%
	Sleep, sleepDelay*6
	WinActivate, %fieldControlNameIs%
	Sleep, sleepDelay*6
	ControlGetText, StaticOneText, Static1, %fieldControlNameIs%
	if(StaticOneText == "Q"+ (numMatches+1)) {
		Menu, TRAY, delete, Current Match: %numMatches%
		numMatches ++
	}
	else
	{
		failedToQueueCount++
		QueueMatch()
		return
	}
	ControlGetText, SavedMatchText, Static2, %fieldControlNameIs%
	Sleep, sleepDelay*6
	if(lastSavedMatchText == SavedMatchText) ;just go to intro if we don't have a new 'saved match results'
	{
		ControlClick, Button21, %fieldControlNameIs%,,,,NA ;intro
		ControlClick, Button21, %fieldControlNameIs%,,,,NA
		ControlClick, Button21, %fieldControlNameIs%,,,,NA
		SetTimer, BackToIntro, Off
	}
	else
	{
		SetTimer, BackToIntro, 10000 ;back to intro after X seconds (from displaying scores)
		ControlClick, Button23, %fieldControlNameIs%,,,,NA ;saved results
		ControlClick, Button23, %fieldControlNameIs%,,,,NA ;saved results
		ControlClick, Button23, %fieldControlNameIs%,,,,NA ;saved results
		lastSavedMatchText := SavedMatchText
	}
	failedToQueueCount := 0
	SetMenu()
	hItem := MyTV.GetNext(hItem, "Full")
	if not hItem { ; No more items in tree.
		if(DebugActive == "true") {
			MsgBox QueueMatch Found no more items in the SysTreeView
		}
		hItem = 0
		return
	}
return
}

RemoveToolTip:
	SetTimer, RemoveToolTip, Off
	ToolTip
return

Exit:
	ExitApp
return

checkScreenScaling() {
	if(theScreenScalingTest > 300) ;we're past any 'real' screen scale, just exit
	{
		theScreenScaling := 0 ; set back to zero so we'll prompt later
		MsgBox % "Setting screen scaling failed"
		return
	}
	WinActivate VEX Tournament Manager
	ControlClick, SysTreeView321, VEX Tournament Manager,,,,NA
	Sleep, sleepDelay*2
	MyTV.SetSelection(hItem)
	oRect := Acc_Location(oAcc, 5) ;Qual 1 is 5, 5+0 = Qual 1, 5+1 = Qual 2 etc
	accName := oAcc.AccName(5) ;we get the name "Qual #" to compare down below
	IfNotInString, accName, Qual
	{
		;check that we are actually queueing a Qual match
		MsgBox QueueMatch:NotInString We got a non-Qual
	}
	theY := oRect.y + matchQueueDifference
	theX := oRect.x
	theX := theX * (theScreenScalingTest / 100) ;test with 100 to start
	theY := theY * (theScreenScalingTest / 100)
	MouseMove, %theX%,%theY%
	Sleep, sleepDelay*3
	SendEvent {Click right}
	Sleep, sleepDelay*6
	SendEvent {Down}
	Sleep, sleepDelay*6
	SendEvent {Enter}
	Sleep, sleepDelay*6
	ControlGetText, StaticOneText, Static1, %fieldControlNameIs%
	if(StaticOneText == "Q1") {
		theScreenScaling := theScreenScalingTest ;when we succeed, set our normalized screen scaling to the test value
		if(DebugActive == "true") {
			MsgBox Setting screen scaling to  %theScreenScaling%
		}
		return
	}
	else
	{
		theScreenScalingTest := theScreenScalingTest + 25 ; increase by 25 each 'failed' attempt, re-attempt
		if(DebugActive == "true") {
			MsgBox Setting screen scaling test to  %theScreenScalingTest%
		}
		Sleep, 500 ;pause 
		checkScreenScaling()
	}
	return
}