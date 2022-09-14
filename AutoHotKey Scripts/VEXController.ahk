#NoEnv
#SingleInstance force
#Include Const_TreeView.ahk
#Include Const_Process.ahk
#Include Const_Memory.ahk
#Include RemoteTreeViewClass.ahk
#Include Acc.ahk
#Include VEX_Shared.ahk

SetBatchLines -1
ListLines Off
SendMode Input
SetWorkingDir %A_ScriptDir%

CoordMode, Mouse, Screen

global numMatches = 1 ;start at 1 since we use the 'queue next match' button
global sleepDelay = 10
global FoundX = 0
global FoundY = 0
global DebugActive = "false"
;global DebugActive = "true"

global inFinals = "false"
global AutoQueueMatches = "true" ;if true, uncomment line below
SetTimer, CheckQueue, 1000
global AutoShowScores = "true" ;auto show scores determines if we should automatically display the last score/or intro on a timer. this is to allow a ref to start matches without us recording the start time.
global notifiedScores = "false"
global savedTimeStamp = "false" ;this is used for YouTube Chapters
global RefScoreSetVar = "false" ;if true, uncomment line below
global AutoObsChapters = "true" ;automatically grab obs live timestamps?
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
global fieldControlNameIs = "Match Field Set #1"
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

;we try to get button7 by default - if the field control name is different, we'll catch it here.
ControlGetText, EDRorIQ, Button7, %fieldControlNameIs%
;MsgBox %EDRorIQ% ;DEBUG
if (InStr(EDRorIQ, "Red") or InStr(EDRorIQ, "Blue")) {
	matchTimeDelay = 110000 ;Autonomous Winner below None = Red for EDR
}
else if InStr(EDRorIQ, "Team") {
	matchTimeDelay = 65000 ;Autonomous Winner below None = Team 1 for IQ
	inVexIQMode := "true"
}
else {
	InputBox, fieldControlNameIs, % "Is your Field Control named differently? Please input it (Field Sets > first entry)"
}

UpdateButtonDefinitions()

ControlGetText, EDRorIQ, Button7, %fieldControlNameIs%
if (InStr(EDRorIQ, "Red") or InStr(EDRorIQ, "Blue")) { ;checking for red or blue
	matchTimeDelay = 110000 ;Autonomous Winner below None = Red for EDR
}
else if InStr(EDRorIQ, "Team") { ;checking only for "Team"
	matchTimeDelay = 65000 ;Autonomous Winner below None = Team 1 for IQ
	inVexIQMode := "true"
}
else {
	ToolTip matchTimeDelay is unknown`, EDR by default
	InputBox, theScreenScaling, % "matchTimeDelay unknown? 110000 is default"
	matchTimeDelay = 110000 ;2017 IQ has no auton winner buttons - they are invisible. still is found as "Team 1"
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
		ControlClick, %IntroButton%, %fieldControlNameIs%,,,,NA
		ControlClick, %IntroButton%, %fieldControlNameIs%,,,,NA
		ControlClick, %IntroButton%, %fieldControlNameIs%,,,,NA
		Sleep, sleepDelay
	return
	3Joy5::
	2Joy5:: ;auton none
	Joy5::
		WinActivate, %fieldControlNameIs%
		Sleep, sleepDelay
		WinActivate, %fieldControlNameIs%
		Sleep, sleepDelay
		ControlClick, %AutonWinnerNoneButton%, %fieldControlNameIs%,,,,NA
		ControlClick, %AutonWinnerNoneButton%, %fieldControlNameIs%,,,,NA
		ControlClick, %AutonWinnerNoneButton%, %fieldControlNameIs%,,,,NA
		Sleep, sleepDelay
	return
	3Joy6::
	2Joy6:: ;auton red
	Joy6::
		WinActivate, %fieldControlNameIs%
		Sleep, sleepDelay
		WinActivate, %fieldControlNameIs%
		Sleep, sleepDelay
		ControlClick, %AutonWinnerRedButton%, %fieldControlNameIs%,,,,NA
		ControlClick, %AutonWinnerRedButton%, %fieldControlNameIs%,,,,NA
		ControlClick, %AutonWinnerRedButton%, %fieldControlNameIs%,,,,NA
		Sleep, sleepDelay
	return
	3Joy7::
	2Joy7:: ;auton blue
	Joy7::
		WinActivate, %fieldControlNameIs%
		Sleep, sleepDelay
		WinActivate, %fieldControlNameIs%
		Sleep, sleepDelay
		ControlClick, %AutonWinnerBlueButton%, %fieldControlNameIs%,,,,NA
		ControlClick, %AutonWinnerBlueButton%, %fieldControlNameIs%,,,,NA
		ControlClick, %AutonWinnerBlueButton%, %fieldControlNameIs%,,,,NA
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
		ControlClick, %SavedMatchResultsButton%, %fieldControlNameIs%,,,,NA
		ControlClick, %SavedMatchResultsButton%, %fieldControlNameIs%,,,,NA
		ControlClick, %SavedMatchResultsButton%, %fieldControlNameIs%,,,,NA
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
		ControlClick, %StartMatchButton%, %fieldControlNameIs%,,,,NA
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
	if ErrorLevel
	{
		return ;we had an issue finding Field Control?? Don't do anything...
	}
	if(MatchMode != "")
	{
		return
	}
	SetTimer, BackToIntro, Off
	ControlClick, %IntroButton%, %fieldControlNameIs%,,,,NA ;intro
	ControlClick, %IntroButton%, %fieldControlNameIs%,,,,NA
	ControlClick, %IntroButton%, %fieldControlNameIs%,,,,NA
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

SwapAutoScores:
	if(AutoShowScores == "true") {
		AutoShowScores := "false"
	}
	else {
		AutoShowScores := "true"
	}
	SetMenu()
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

SwapInFinals:
	if(inFinals == "true") {
		inFinals := "false"
	}
	else {
		inFinals := "true"
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

SwapObsAutoChapters:
	if(AutoObsChapters == "true") {
		AutoObsChapters := "false"
	}
	else
	{
		AutoObsChapters := "true"
	}
	SetMenu()
return

SetLastSavedMatch:
return

SetMenu() {
	Menu, TRAY, deleteall
	Menu, TRAY, add, Current Match: %numMatches%, SetCurrentMatch
	Menu, TRAY, add, Sleep Delay: %sleepDelay%, SetSleepDelay
	Menu, TRAY, add, Auto Show Scores If-Ref: %AutoShowScores%, SwapAutoScores
	Menu, TRAY, add, Auto Queue Matches: %AutoQueueMatches%, SwapAutoQueue
	Menu, TRAY, add, Auto Save Ref Scores: %RefScoreSetVar%, RefScoreSetSwap
	Menu, TRAY, add, Automatic OBS Chapters: %AutoObsChapters%, SwapObsAutoChapters
	Menu, TRAY, add, In Finals: %inFinals%, SwapInFinals
	Menu, TRAY, add, Debugging Active: %DebugActive%, SetDebugActive
	Menu, TRAY, add, Match Length: %matchTimeDelay%, SetMatchTimeDelay
	Menu, TRAY, add, Last Saved Match: %lastSavedMatchText%, SetLastSavedMatch
	Menu, TRAY, add
	Menu, TRAY, add, Exit, Exit
return
}

CheckQueue:
	ControlGetText, MatchMode, Static4, %fieldControlNameIs% ;IQ=4, EDR=4, changed in a previous ver?
	if ErrorLevel
	{
		return ;we had an issue finding Field Control?? Don't do anything...
	}
	;ToolTip MatchMode is %MatchMode%
	if(MatchMode == "" && AutoShowScores == "true" && notifiedScores == "false")
	{
		;ToolTip "Showing intro via CheckQueue..."
		notifiedScores := "true"
		savedTimeStamp := "false"
		MsgBox doing show scores or intro in 5s
		SetTimer, ShowScoresOrIntro, 5000 ;we are going to wait 5 seconds and then determine if we show scores or the intro screen
	}
	if(AutoObsChapters == true && (MatchMode == "DRIVER CONTROL" || MatchMode == "AUTONOMOUS") && savedTimeStamp == "false") {
		;we've entered the actual match - let's save the current timestamp for YouTube Chapters
		ObsSaveTimestamp()
		savedTimeStamp := "true"
		MsgBox saved obs timestamp
	}
	if(MatchMode == "DRIVER CONTROL" && AutoShowScores == "true" && notifiedScores == "true") {
		notifiedScores := "false"
	}
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

ShowScoresOrIntro() {
	ControlGetText, MatchMode, Static4, %fieldControlNameIs% ;IQ=4, EDR=4, changed in a previous ver?
	if ErrorLevel
	{
		return ;we had an issue finding Field Control?? Don't do anything...
	}
	if(MatchMode != "")
	{
		SetTimer, ShowScoresOrIntro, Off
		return
	}
	ControlGetText, SavedMatchText, Static2, %fieldControlNameIs%
	Sleep, sleepDelay*6
	if(lastSavedMatchText == SavedMatchText) ;just go to intro if we don't have a new 'saved match results'
	{
		ControlClick, %IntroButton%, %fieldControlNameIs%,,,,NA ;intro
		ControlClick, %IntroButton%, %fieldControlNameIs%,,,,NA
		ControlClick, %IntroButton%, %fieldControlNameIs%,,,,NA
		SetTimer, BackToIntro, Off
	}
	else
	{
		SetTimer, BackToIntro, 10000 ;back to intro after X seconds (from displaying scores)
		ControlClick, %SavedMatchResultsButton%, %fieldControlNameIs%,,,,NA ;saved results
		ControlClick, %SavedMatchResultsButton%, %fieldControlNameIs%,,,,NA
		ControlClick, %SavedMatchResultsButton%, %fieldControlNameIs%,,,,NA
		lastSavedMatchText := SavedMatchText
	}
	SetTimer, ShowScoresOrIntro, Off
	return
}

tryQueueAgain:
	if(AutoQueueMatches == "true") {
		if(A_TickCount - matchStartTime > matchTimeDelay) {
			QueueMatch()
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
	ControlClick, %QueueNextMatchButton%, %fieldControlNameIs%,,,,NA ;queue next match button
	Sleep, sleepDelay*2
	ControlGetText, StaticOneText, Static1, %fieldControlNameIs%
	if(inFinals == "true") {
		; we don't care if we're in finals, ignore if we don't match the StaticOne text
	}
	else if(StaticOneText == "Q"+ (numMatches+1)) {
		Menu, TRAY, delete, Current Match: %numMatches%
		numMatches ++
	}
	else
	{
		failedToQueueCount++
		;QueueMatch()
		;instead of just spamming 3x quickly, let's set a timer to try again in 2 seconds.
		SetTimer, tryQueueAgain, 2000
		return
	}
	;after we queue, cancel the try-again timer
	SetTimer, tryQueueAgain, Off
	ControlGetText, SavedMatchText, Static2, %fieldControlNameIs%
	Sleep, sleepDelay*6
	if(lastSavedMatchText == SavedMatchText) ;just go to intro if we don't have a new 'saved match results'
	{
		ControlClick, %IntroButton%, %fieldControlNameIs%,,,,NA ;intro
		ControlClick, %IntroButton%, %fieldControlNameIs%,,,,NA
		ControlClick, %IntroButton%, %fieldControlNameIs%,,,,NA
		SetTimer, BackToIntro, Off
	}
	else
	{
		SetTimer, BackToIntro, 10000 ;back to intro after X seconds (from displaying scores)
		ControlClick, %SavedMatchResultsButton%, %fieldControlNameIs%,,,,NA ;saved results
		ControlClick, %SavedMatchResultsButton%, %fieldControlNameIs%,,,,NA
		ControlClick, %SavedMatchResultsButton%, %fieldControlNameIs%,,,,NA
		lastSavedMatchText := SavedMatchText
	}
	failedToQueueCount := 0
	SetMenu()
	hItem := MyTV.GetNext(hItem, "Full")
	if not hItem { ; No more items in tree.
		if(DebugActive == "true") {
			MsgBox QueueMatch Found no more items in the SysTreeView
		}
		;we've gone through all the matches, turn on finals?
		if(inFinals == "false") {
			inFinals := "true"
			SetMenu()
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