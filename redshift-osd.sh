#!/bin/bash

# https://github.com/Ao1Pointblank/redshift-osd
# Usage Guide:
# 
# This script allows you to adjust brightness, and temperature settings using redshift 
# and it also displays an on-screen display (OSD) notification for Cinnamon.
# 
# Usage:
# ./redshift-osd.sh <mode> <direction>
# 
# Parameters:
# - <mode>: Specifies the setting to adjust. Available modes:
#   - brightness: Adjusts the screen brightness.
#   - temperature: Adjusts the screen color temperature.
# 
# - <direction>: Specifies the adjustment direction. Available directions:
#   - up: Increases the setting value.
#   - down: Decreases the setting value.
#   - reset: Resets the setting to its default value.
# 
# Examples:
# - Increase Brightness: ./gummy-osd.sh brightness up
# - Decrease Temperature: ./gummy-osd.sh temperature down
# - Reset Temperature to Default: ./gummy-osd.sh temperature reset
# 
# Requires:
# bc (bash calculator) and redshift (with manual location mode configured) installed and in $PATH
# this script probably only works on Cinnamon with X11

BRIGHTNESS_FILE="/tmp/.${UID}_${DISPLAY}.redshift-osd-bright"
TEMPERATURE_FILE="/tmp/.${UID}_${DISPLAY}.redshift-osd-temp"

if [ ! -f "$BRIGHTNESS_FILE" ]; then
    echo "100" > "$BRIGHTNESS_FILE"
fi

if [ ! -f "$TEMPERATURE_FILE" ]; then
    echo "6500" > "$TEMPERATURE_FILE"
fi

# Function to update and display OSD
update_osd() {
    local icon=$1
    local level=$2

    gdbus call --session \
        --dest org.Cinnamon \
        --object-path /org/Cinnamon \
        --method org.Cinnamon.ShowOSD \
        '{"icon": <"'$icon'">, "level": <'$level'>}' > /dev/null 2>&1
}

# Check the mode and adjust accordingly
case "$1" in
    "brightness")
        VALUE_FILE="$BRIGHTNESS_FILE"
        ICON="display-brightness-symbolic"
        STEP=10
        DEFAULT=100
        ;;
    "temperature")
        VALUE_FILE="$TEMPERATURE_FILE"
        ICON="temperature-symbolic"
        STEP=500
        DEFAULT=6500
        ;;
    *)
        echo "Unknown mode: $1"
        exit 1
        ;;
esac

# Read the current value
VALUE=$(cat "$VALUE_FILE")

# Adjust the value based on the direction
case "$2" in
    "up") VALUE=$((VALUE + STEP)) ;;
    "down") VALUE=$((VALUE - STEP)) ;;
    "reset") VALUE=$DEFAULT ;;
    *) echo "Unknown direction: $2"; exit 1 ;;
esac

# Ensure VALUE is within valid ranges
if [ "$1" == "brightness" ]; then
    if [ "$VALUE" -gt 100 ]; then
        VALUE=100
        echo "max value: no change"
    elif [ "$VALUE" -lt 10 ]; then
        VALUE=10
        echo "min value: no change"
    else
        echo "new value: $VALUE"
        # Scale VALUE from 10-100 to 0-100 for OSD
        PERCENTAGE=$(( (VALUE - 10) * 100 / 90 )) ##
    fi
elif [ "$1" == "temperature" ]; then
    if [ "$VALUE" -gt 6500 ]; then
        VALUE=6500
        echo "max value: no change"
    elif [ "$VALUE" -lt 1000 ]; then
        VALUE=1000
        echo "min value: no change"
    else
        echo "new value: $VALUE"
        # Scale VALUE from 1000-6500 to 0-100 for OSD
        PERCENTAGE=$(( ( (VALUE - 1000) * 100 ) / 5500 ))
    fi
fi

# Write the updated value back to the file
echo "$VALUE" > "$VALUE_FILE"

# Update the OSD display
update_osd "$ICON" "$PERCENTAGE"

#reset gamma ramps but restore previous opposing settings
case "$1" in
    "brightness")
        redshift -b "$(echo "scale=2; "$VALUE" / 100" | bc)" -O "$(cat $TEMPERATURE_FILE)" -P > /dev/null
       ;;
    "temperature")
        redshift -b "$(echo "scale=2; $(cat $BRIGHTNESS_FILE) / 100" | bc)" -O "$VALUE" -P > /dev/null
        ;;
esac
