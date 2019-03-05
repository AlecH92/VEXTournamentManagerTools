## Tournament Manager Tools
* This repository contains AutoHotKey scripts used for automating tasks in Tournament Manager
* The Arduino and CAD folders contain programs and models for physical components used
* The OBS folder contains setup and usage info, to be used with DisplayControl
* The VEXController script can be utilized with a generic USB joystick (Xbox/PS4 controller etc)

### Below is information on the AutoHotKey scripts

## VEXController
  This program is the main controller to be used with the physical box and wireless start button. It takes care of switching `Tournament Manager` between screens and queueing upcoming matches.  
  On startup, `Tournament Manager` and `Field Control` must already be opened. It checks for the `Match List` and expands `Qualifications`.  
  Match 1 is queued automatically to determine Windows screen scaling size.  
  By default, automatic queueing is enabled and automatic ref-score saving is disabled.  
  The Tray icon has access to set the Current Match, change the Sleep Delay (for slower PCs), toggle Auto Queue Matches and toggle Auto Save Ref scores  

  Physical Box/Joystick Buttons:
  ```
  Saved Match Results (Joystick Button 1)
  Start Match (Joystick Button 2)
  Intro (Joystick Button 3)
  Queue Next Match (Joystick Button 4)
  Autonomous Winner None (Joystick Button 5) (These are available via Ref Scoring, mostly unused now)
  Autonomous Winner Red  (Joystick Button 6)
  Autonomous Winner Blue (Joystick Button 7)
  ```

  Auto queueing a match displays `Saved Match Results` if the `Saved Match (in Field Control)` has changed since the last match was queued.  
  This prevents automatically displaying the same Saved Match twice.  
  If saved scores are displayed, it switches back to `Intro` after 10 seconds. If saved scores are not displayed, it switches to Intro instead.  

## DisplayControl
  This program controls what scene is active in OBS based on input from Tournament Manager  

  Loops once per second checking for the `Field Control` window options: "Intro" or "In-Match"
  ```
  If it's in Intro, the Combined view (F7 shortcut) is shown
  If it's in Intro and In Finals (F3 shortcut) is toggled on, the Combined Finals view (F8 shortcut) is shown
  If it's In-Match, the "Field" dropdown is checked. The first option uses F9 and any other option uses F10
  If it's neither of these, it switches to a normal Audience Display (F6 shortcut)
  ```

  Program Shortcut List:
  ```
  F3  - Enable/Disable "Combined Finals" Display
  ```

  OBS Shortcut List:
  ```
  F5  - Field 3
  F6  - Audience Display (No Overlay)
  F7  - Combined, Standard
  F8  - Combined, Finals
  F9  - Field 1
  F10 - Field 2
  ```

### OBSAutoMatchRecord (Untested / Needs Work)
  This program automatically records matches from start to finish via OBS

  When the program opens, it asks for a name of the Tournament to use in saving the videos (referenced below as %TournamentTitle%)  
  Loops 4 times a second looking for "Field Control" to have "In-Match" selected  
  When "In-Match" is triggered, the current "Match On Field" listed is saved (referenced below as %MatchName%) and recording begins (F4 shortcut (Toggle))  
  While "In-Match", the program loops every second watching for a change  
  When "Field Control" switches out of "In-Match", recording is stopped (F4 shortcut (Toggle)) and the program waits 2.5 seconds and then moves C:\Users\alecharley\Videos\*.mp4 to D:\YouTubeUpload\%TournamentTitle% - %MatchName%.mp4  

  Program Shortcut List:
  ```
  None
  ```

  OBS Shortcut List:
  ```
  F4  - Toggle Recording
  ```

### refScoreToSK2 (Untested / Needs Work)
  This program automatically saves TM Mobile (referee) inputted scores and displays/sends them to Skills Field 2  

  Loops once per second  
  The program searches for the specific gray color of the unsaved score and gets the coordinates of it  
  Once the coordinates are found, it selects that match and clicks "Save Scores"  
  Then the same coordinates are right clicked to send the scores to Skills Field 2 (used on OBS as a Non-Overlay Audience Display)  

  Program Shortcut List:
  ```
  F3  - Toggle Pause Script
  ```

  OBS Shortcut List:
  ```
  None
  ```
