#!/bin/sh

export XAUTHORITY=~/.Xauthority
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"

BATTERY_STATE=$1
BATTERY_LEVEL=$(acpi -b | grep "Battery 0" | grep -P -o '[0-9]+(?=%)')

case "$BATTERY_STATE" in
    "charging")    
        TITLE="Power Connected"
        ICON="battery-charging"
        
        # 1. Force SwayNC to close the specific ID 9991 if it exists
        swaync-client -cp 9991 2>/dev/null
        
        # 2. Send the new notification
        notify-send "$TITLE" "Battery: ${BATTERY_LEVEL}%" -u normal -i "$ICON" -t 3000 -r 9991
        ;;
    "discharging") 
        TITLE="Unplugged"
        ICON=""
        notify-send "$TITLE" "${BATTERY_LEVEL}%" -u normal -i "$ICON" -t 3000 -r 9991
        ;;
esac