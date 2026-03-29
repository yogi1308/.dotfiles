#!/bin/bash
state=$(rmpc status | grep -oP '"state":"\K[^"]+')
if [ "$state" = "Play" ]; then
    kitty rmpc pause
else
    kitty rmpc play
fi