#!/bin/bash

HYPR_CONF="$HOME/.config/hypr/hyprland.conf"

# 1. Capture the components using a regex that handles the 'exec, ' comma properly.
# 2. We use a temporary delimiter '|' to separate parts.
# 3. We use sed to escape '&' characters so they don't break Rofi's Pango markup.
mapfile -t BINDINGS < <(grep -P '^bind\s*=' "$HYPR_CONF" | grep ' # ' | \
    sed -E 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' | \
    sed -E 's/^bind\s*=\s*([^,]*),\s*([^,]*),\s*(.*)\s*#\s*(.*)/<b>\1 + \2<\/b>|<i>\4<\/i>|<span color="gray">\3<\/span>/')

# column -t aligns the columns nicely for Rofi
CHOICE=$(printf '%s\n' "${BINDINGS[@]}" | column -t -s '|' | rofi -dmenu -i -markup-rows -p "Hyprland Keybinds:")

[[ -z "$CHOICE" ]] && exit 0

# Extract the raw command from the span tag and unescape the HTML entities
CMD=$(echo "$CHOICE" | sed -n 's/.*<span color="gray">\(.*\)<\/span>.*/\1/p' | \
    sed 's/\&amp;/\&/g; s/\&lt;/</g; s/\&gt;/>/g' | xargs)

resolve_hypr_vars() {
    local cmd="$1"
    while [[ "$cmd" == *\$* ]]; do
        varname=$(echo "$cmd" | grep -oP '\$\w+' | head -1)
        varkey="${varname#$}"
        # Grab value, strip quotes and whitespace
        varval=$(grep "^\s*\$$varkey\s*=" "$HYPR_CONF" | cut -d'=' -f2- | sed "s/^[[:space:]]*//;s/[[:space:]]*$//;s/^\"//;s/\"$//;s/^'//;s/'$//")
        [[ -z "$varval" ]] && break
        cmd="${cmd//$varname/$varval}"
    done
    echo "$cmd"
}

if [[ "$CMD" == exec* ]]; then
    RUN=$(echo "$CMD" | sed -E 's/^exec,?\s*//')
    RUN=$(resolve_hypr_vars "$RUN")
    # Using 'sh -c' ensures that complex commands with '&&' or '&' execute correctly
    sh -c "$RUN" &
else
    hyprctl dispatch $CMD
fi