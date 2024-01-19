global IntroButton
global InMatchButton
global SavedMatchResultsButton
global StartMatchButton
global QueueNextMatchButton
global AutonWinnerRedButton
global AutonWinnerBlueButton
global AutonWinnerNoneButton
global AutonWinnerTieButton
global PlaySoundsCheckbox
global StartMatchActualButtonIndex = -1

UpdateButtonDefinitions() {
Loop
{
    if (A_Index > 35)
        break  ; Terminate the loop
	ButtonName := "Button"A_Index
    ControlGetText, btntext, %ButtonName%, %fieldControlNameIs%
	;MsgBox Button %A_Index% text is %btntext%
	if (btntext == "Start Match")
	{
		StartMatchButton := "Button"A_Index
		StartMatchActualButtonIndex := A_Index
	}
	if (btntext == "Intro")
	{
		IntroButton := "Button"A_Index
	}
	if (btntext == "In-Match")
	{
		InMatchButton := "Button"A_Index
	}
	if (btntext == "Saved Match Results")
	{
		SavedMatchResultsButton := "Button"A_Index
	}
	if (btntext == "Queue Next Match")
	{
		QueueNextMatchButton := "Button"A_Index
	}
	if (btntext == "Red")
	{
		AutonWinnerRedButton := "Button"A_Index
	}
	if (btntext == "Blue")
	{
		AutonWinnerBlueButton := "Button"A_Index
	}
	if (btntext == "None" && (StartMatchActualButtonIndex == -1 || A_Index < StartMatchActualButtonIndex)) ;we need to ignore the Audience Display / None entry
	{
		AutonWinnerNoneButton := "Button"A_Index
	}
	if (btntext == "Tie")
	{
		AutonWinnerTieButton := "Button"A_Index
	}
	if (btntext == "Play Sounds")
	{
		PlaySoundsCheckbox := "Button"A_Index
	}
}
return
}

ObsSaveTimestamp() {
	obsAcc := Acc_Get("Name", "4.14.4.4", 0, "", "obs64")
	;MsgBox %obsAcc%
	;This fetches the current "LIVE: 00:00:00" text from OBS. we should save this with the current Q# match number to a text file so we can create Chapters in the video description later.
	ControlGetText, StaticOneText, Static1, %fieldControlNameIs%
	TextToSave := obsAcc A_Tab "Match " StaticOneText "`n"
	FileAppend, %TextToSave%, obs_auto_chapters.txt
return
}