# redshift-osd

 This script allows you to adjust brightness and temperature settings using redshift, 
 and it also displays an on-screen display (OSD) notification.

![Workspace 1_033](https://github.com/user-attachments/assets/2953feaf-00a3-4d01-b7fd-0d77d83ad08d)

# Requires:
  - bc (bash calculator)  
  - redshift (with manual location mode configured)   
  - make sure both are in $PATH  
  - this script most likely only works on Cinnamon in X11 mode
  
 # Usage:
 ``./redshift-osd.sh <mode> <direction>``
 
 Parameters:
 - ``<mode>``: Specifies the setting to adjust. Available modes:
   - brightness: Adjusts the screen brightness.  
   - temperature: Adjusts the screen color temperature.
 
 - ``<direction>``: Specifies the adjustment direction. Available directions:
   - up: Increases the setting value.
   - down: Decreases the setting value.
   - reset: Resets the setting to its default value.
 
 Examples:
 - Increase Brightness: ``./redshift-osd.sh brightness up``
 - Decrease Temperature: ``./redshift-osd.sh temperature down``
 - Reset Temperature to Default: ``./gummy-osd.sh temperature reset``

 Suggestions: 
 - add to ``autorandr`` postswitch script:  
create a file ``~/.config/autorandr/postswitch`` and ``chmod +x`` it, then add this to it:
```bash
#!/bin/bash
BRIGHTNESS_FILE="/tmp/.${UID}_${DISPLAY}.redshift-osd-bright"
TEMPERATURE_FILE="/tmp/.${UID}_${DISPLAY}.redshift-osd-temp"
sleep 2
redshift -b "$(echo "scale=2; "$(cat $BRIGHTNESS_FILE)" / 100" | bc)" -O "$(cat $TEMPERATURE_FILE)" -P
```
this will allow your cached brightness/temperature settings to carry over to a new autorandr profile when switching monitors.
