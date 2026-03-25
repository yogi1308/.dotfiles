#!/bin/bash
ADDRESS="0x$1"
WORKSPACE=$(hyprctl clients -j | jq -r --arg addr "$ADDRESS" '.[] | select(.address == $addr) | .workspace.id')
COUNT=$(hyprctl clients -j | jq --arg ws "$WORKSPACE" '[.[] | select(.workspace.id == ($ws | tonumber)) | select(.class | test("zen"; "i"))] | length')

if [ "$COUNT" -eq 1 ]; then
    hyprctl dispatch settiled "address:$ADDRESS"
fi