#!/bin/env sh
TMP_FILE="$XDG_RUNTIME_DIR/hyprland-show-desktop"
CURRENT_WORKSPACE=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .activeWorkspace | .name')
CMDS=""
TMP_ADDRESS=""


if [ -s "$TMP_FILE-$CURRENT_WORKSPACE" ]; then
  while IFS= read -r address; do
    [[ -n "$address" ]] && CMDS+="dispatch movetoworkspacesilent name:$CURRENT_WORKSPACE,address:$address;"
  done < "$TMP_FILE-$CURRENT_WORKSPACE"
  hyprctl --batch "$CMDS"
  rm "$TMP_FILE-$CURRENT_WORKSPACE"
else
  HIDDEN_WINDOWS=$(hyprctl clients -j | jq -r --arg CW "$CURRENT_WORKSPACE" '.[] | select(.workspace.name == $CW) | .address')
  while IFS= read -r address; do
    [[ -n "$address" ]] && {
      TMP_ADDRESS+="$address"$'\n'
      CMDS+="dispatch movetoworkspacesilent special:desktop,address:$address;"
    }
  done <<< "$HIDDEN_WINDOWS"
  hyprctl --batch "$CMDS"
  printf '%s' "$TMP_ADDRESS" > "$TMP_FILE-$CURRENT_WORKSPACE"
fi
