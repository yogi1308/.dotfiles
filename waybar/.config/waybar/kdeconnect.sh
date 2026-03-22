#!/usr/bin/env bash

ICON_CONNECTED=""
ICON_DISCONNECTED=""

# Use mapfile with -t to strip newlines and read each line as one array element
# This prevents names like "OnePlus Nord 5" from being split into three elements
mapfile -t devices < <(kdeconnect-cli -a --name-only 2>/dev/null)

# Clean up any empty strings from the array
active_devices=()
for dev in "${devices[@]}"; do
    [[ -n "$dev" ]] && active_devices+=("$dev")
done

count=${#active_devices[@]}

if [[ $count -eq 0 ]]; then
    echo "{\"text\": \"$ICON_DISCONNECTED\", \"tooltip\": \"No devices connected\", \"class\": \"disconnected\"}"
else
    # Join the array elements with \n for the tooltip
    # This syntax joins elements using the first character of IFS (set to \n)
    tooltip=$(IFS=$'\n'; echo "${active_devices[*]}")

    # Output JSON for Waybar
    echo "{\"text\": \"$ICON_CONNECTED $count\", \"tooltip\": \"$tooltip\", \"class\": \"connected\"}"
fi