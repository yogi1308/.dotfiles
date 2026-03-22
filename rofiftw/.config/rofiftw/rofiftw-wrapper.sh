#!/usr/bin/env bash

CONFIG_DIR="$HOME/.config/rofiftw"
BROWSER="xdg-open"

declare -A icons=(
    ["google"]="󰊭"
    ["youtube"]="󰗃"
    ["ddg"]="󰇥"
    ["wikipedia"]="󰖬"
    ["archwiki"]="󰣇"
    ["amazon"]=""
    ["deezer"]="󰎈"
    ["lastfm"]="󰎈"
    ["books"]="󰂿"
)
ENGINES=(google youtube ddg wikipedia archwiki amazon deezer books lastfm)

if [[ -z "$1" ]]; then
    # Print engine list for rofi to display
    for engine in "${ENGINES[@]}"; do
        echo "${icons[$engine]:-󰍉} ${engine}"
    done
else
    # Got selection from rofi — extract engine and launch suggest
    engine=$(echo "$1" | awk '{print $NF}')
    result=$(bash "$CONFIG_DIR/suggest" "$engine")
    [[ -z "$result" ]] && exit 0

    case "$engine" in
        "google")    $BROWSER "https://www.google.com/search?q=${result// /%20}" ;;
        "youtube")   $BROWSER "https://www.youtube.com/results?search_query=${result// /%20}" ;;
        "ddg")       $BROWSER "https://duckduckgo.com/?q=${result// /%20}" ;;
        "wikipedia") $BROWSER "https://en.wikipedia.org/wiki/Special:Search?search=${result// /%20}" ;;
        "archwiki")  $BROWSER "https://wiki.archlinux.org/index.php?search=${result// /%20}" ;;
        "amazon")    $BROWSER "https://www.amazon.com/s?k=${result// /%20}" ;;
        "deezer")    $BROWSER "https://www.deezer.com/search/${result// /%20}" ;;
        "books")     $BROWSER "https://www.google.com/search?tbm=bks&q=${result// /%20}" ;;
        "lastfm")    $BROWSER "https://www.last.fm/search?q=${result// /%20}" ;;
    esac
    notify-send "RofiFtw" "Opened $engine in existing browser session"
    killall rofi
fi