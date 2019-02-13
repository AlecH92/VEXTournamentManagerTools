InputBox, TournamentTitle, Name of Tournament, Input the name of the tournament`, ex: "South San Diego VEX Tournament 2016"
Loop {
	ControlGet, currentlyInMatch, Checked , , Button22, Field Control
	ControlGetText, MatchTime, Static3, Field Control ;gets current match time for use in while loop
	;ToolTip %currentlyInMatch% ;DEBUG

	if(currentlyInMatch) { ;if In-Match is selected
		ControlGetText, MatchName, Static1, Field Control
		ControlSend,,{F4}, ahk_class Qt5QWindowIcon ;start recording OBS
		while(currentlyInMatch || MatchTime != "0:00") { ;wait until we're not In Match
			Sleep, 1000
			ControlGet, currentlyInMatch, Checked , , Button22, Field Control
			ControlGetText, MatchTime, Static3, Field Control
		}
		ControlSend,,{F4}, ahk_class Qt5QWindowIcon ;stop recording OBS after we're out of In Match
		Sleep, 2500 ;give the video file time to save/close
		FileMove, C:\Users\alecharley\Videos\*.mp4, D:\YouTubeUpload\%TournamentTitle% - %MatchName%.mp4
	}
	Sleep, 250 ;delay while waiting for a match to start
}
