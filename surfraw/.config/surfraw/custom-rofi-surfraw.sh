#!/usr/bin/env bash

# Define your icon mapping here
declare -A icons=(
    ["acronym"]="󰬳"
    ["ads"]="󰆽"
    ["alioth"]="󰒋"
    ["amazon"]=""
    ["archpkg"]="󰣇"
    ["archwiki"]="󰣇"
    ["arxiv"]="󰙆"
    ["ask"]="󰞋"
    ["aur"]="󰣇"
    ["austlii"]="󰠰"
    ["bbcnews"]="󰃮"
    ["bing"]="󰂤"
    ["bookfinder"]="󰂿"
    ["bugmenot"]="󰅶"
    ["bugzilla"]="󰑌"
    ["cia"]="󰒳"
    ["cisco"]="󰕒"
    ["cite"]="󱉟"
    ["cliki"]="󰖬"
    ["cnn"]="󰃮"
    ["comlaw"]="󰠰"
    ["commandlinefu"]="󰆍"
    ["ctan"]="󰙮"
    ["currency"]="󰀧"
    ["cve"]="󰒃"
    ["debbugs"]="󰑌"
    ["debcodesearch"]="󰨊"
    ["debcontents"]="󰏖"
    ["deblists"]="󰇯"
    ["deblogs"]="󱃕"
    ["debpackages"]="󰏖"
    ["debpkghome"]="󰏖"
    ["debpts"]="󰏖"
    ["debsec"]="󰒃"
    ["debvcsbrowse"]="󰊤"
    ["debwiki"]="󰖬"
    ["deja"]="󰍉"
    ["discogs"]="󰎈"
    ["duckduckgo"]="󰇥"
    ["ebay"]="󰠖"
    ["etym"]="󰂽"
    ["excite"]="󰖟"
    ["f5"]="󰕒"
    ["finkpkg"]="󰏖"
    ["foldoc"]="󰂿"
    ["freebsd"]="󰣠"
    ["freedb"]="󰀱"
    ["freshmeat"]="󰏖"
    ["fsfdir"]="󱄕"
    ["gcache"]="󰊭"
    ["genbugs"]="󰑌"
    ["genportage"]="󰏖"
    ["github"]="󰊤"
    ["gmane"]="󰇯"
    ["google"]="󰊭"
    ["gutenberg"]="󰂿"
    ["imdb"]=""
    ["ixquick"]="󰍉"
    ["jamendo"]="󰎈"
    ["javasun"]="󰬷"
    ["jquery"]="󰡶"
    ["l1sp"]="󰬩"
    ["lastfm"]="󰎈"
    ["leodict"]="󱉟"
    ["lsm"]="󰏖"
    ["macports"]="󰀵"
    ["mathworld"]="󰡾"
    ["mdn"]="󰖟"
    ["mininova"]="󰮌"
    ["musicbrainz"]="󰎈"
    ["mysqldoc"]="󰆼"
    ["netbsd"]="󰣠"
    ["nlab"]="󰡾"
    ["ntrs"]="󰚾"
    ["openbsd"]="󰣠"
    ["oraclesearch"]="󰆼"
    ["pgdoc"]="󰆼"
    ["pgpkeys"]="󰌋"
    ["phpdoc"]="󰌟"
    ["pin"]="󰐃"
    ["piratebay"]="󰮌"
    ["priberam"]="󱉟"
    ["pubmed"]="󰬔"
    ["rae"]="󱉟"
    ["rfc"]="󰒓"
    ["S"]="󰍉"
    ["scholar"]="󰑴"
    ["scpan"]="󰬩"
    ["searx"]="󰍉"
    ["slashdot"]="/."
    ["slinuxdoc"]="󰌽"
    ["sourceforge"]="󰏖"
    ["springer"]="󰙆"
    ["stack"]="󰓌"
    ["stockquote"]="󰸽"
    ["thesaurus"]="󰂽"
    ["translate"]="󰗊"
    ["urban"]="󱉟"
    ["W"]="󰖬"
    ["w3css"]="󰌝"
    ["w3html"]="󰌝"
    ["w3link"]="󰖟"
    ["w3rdf"]="󰖟"
    ["wayback"]="󰔛"
    ["webster"]="󰂽"
    ["wikipedia"]="󰖬"
    ["wiktionary"]="󰖬"
    ["woffle"]="󰍉"
    ["wolfram"]="W"
    ["worldwidescience"]="󰙆"
    ["yahoo"]="Y"
    ["yandex"]="󰘆"
    ["youtube"]="󰗃"
)

#!/usr/bin/env bash

CONFIG_DIR="$HOME/.config/rofiftw"

if [[ -z "$1" ]]; then
    # Print elvi list for rofi to display
    surfraw -elvi \
        | awk -F'-' '{print $1}' \
        | sed '/:/d' \
        | awk '{$1=$1};1' \
        | while read -r engine; do
            echo "${icons[$engine]:-󰍉} $engine"
          done
else
    # Got selection from rofi — extract engine name (strip icon prefix)
    engine=$(echo "$1" | awk '{print $NF}')
    [[ -z "$engine" ]] && exit 0

    killall rofi

    # Prompt for search query via rofi dmenu
    query=$(rofi -dmenu -p "$engine: " \
    -theme-str "istview {lines: 0;}" \
    -no-fixed-num-lines)
    [[ -z "$query" ]] && exit 0

    # Execute via surfraw
    surfraw "$engine" "$query"
    notify-send -t 2000 "Surfraw" "Opened $engine: $query"
    killall rofi
fi