## OBS Setup
### Shortcuts used
* The OBS configuration expects different named Display executables
* TM - Setup Executables.bat can be used to create these required alternatives
* You will need to create shortcuts to each executable, options shown below
* These are shortcuts for automatically connecting to a remote Tournament Manager server. Shown are the Audience Display, Overlay; Pit Display 1; and TM itself
* "C:\Program Files (x86)\VEX\Tournament Manager\DisplayStandard.exe" --audience --overlay 0 --server your.ip.goes.here --pw yourpassword --fieldsetid 1
* "C:\Program Files (x86)\VEX\Tournament Manager\DisplayPit.exe" --pit --server your.up.goes.here --pw yourpassword --pitdisplayid 1
* "C:\Program Files (x86)\VEX\Tournament Manager\TM.exe" --server your.ip.goes.here --pw yourpassword --fieldsetid 1
* Be sure to reference each named executable created: DisplayStandard, DisplayPit, DisplayPit2 etc
* Some executables created by the batch file are unused and from previous game years
* On an unrelated note, this same concept can be used for remote Skills connections (set the fieldsetid to 2 to connect directly to Skills displays)
  
  
### OBS Scenes
* The "VEX Scenes.json" can be imported to OBS and already has a two or three camera field setup configured for use with the DisplayControl scripts
* Field # Camera Views can be configued for either USB cameras, or MJPG Streams
* The scenes have a few groups detailing some usage
* In Combined View, all camera/streams are accessible in case they need to be reset (usually double clicking and hitting "OK" is enough to get them going again)
* In Combined View, a separate group toggles the Field 3 view. Toggle on for three cameras, toggle off to show an Audience Display in its place
* Front of Fields View can be used with a remote Pi or other MJPG stream for an "Audience eyes view"
* DisplayControl will switch to the Field # In-Match View, which has a slightly modified TM Audience Display with Overlay
* The "Technical Difficulties" will need to have its image path altered, check out "TECHDIFF" and set it