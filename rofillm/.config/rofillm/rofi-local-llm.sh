#!/usr/bin/env bash

# Ensure user local bin is in PATH (rofi script mode strips it)
export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"


PERSONAS_FILE="$HOME/.config/rofillm/personas.conf"

THINKING_MESSAGES=(
    "⚡ Consulting the matrix..."
    "🧠 Neurons firing..."
    "🔭 Scanning the knowledge universe..."
    "☕ Brewing your answer..."
    "🎲 Calculating probabilities..."
    "🌀 Bending spacetime for your query..."
    "🤔 Thinking really hard..."
    "🔬 Running mental simulations..."
    "📡 Pinging the hive mind..."
    "🧬 Sequencing the answer DNA..."
    "🌊 Surfing the information wave..."
    "🔮 Gazing into the crystal cache..."
    "🧩 Assembling the puzzle pieces..."
    "🚀 Launching into knowledge space..."
    "⚙️ Spinning up the logic engine..."
    "🌌 Traversing the neural galaxy..."
    "📚 Raiding the library of Alexandria..."
    "🎯 Locking onto target frequency..."
    "🧲 Attracting relevant data points..."
    "💡 Charging the idea capacitor..."
    "🔑 Unlocking the answer vault..."
    "🌿 Growing a decision tree..."
    "🎻 Tuning the reasoning strings..."
    "🏄 Riding the inference wave..."
    "🦉 Consulting the wise owl..."
    "🔧 Tightening the logic bolts..."
    "🌐 Querying the noosphere..."
    "🧊 Defrosting some frozen knowledge..."
    "🎲 Rolling for intelligence..."
    "⏳ Compressing decades of reading..."
    "🕵️ Investigating the facts..."
    "🧪 Running the experiment..."
    "🔭 Zooming in on the answer..."
    "🗺️ Charting unknown territories..."
    "🎮 Loading the knowledge cartridge..."
    "🛸 Abducting the right answer..."
    "🧠 Defragmenting the thought drive..."
    "📡 Receiving transmission from the cloud..."
    "🌀 Spinning up the inference loop..."
    "🔬 Examining under the logic microscope..."
)

# Script mode: first call prints persona list, second call receives selection
if [[ -z "$@" ]]; then
    # Print personas for rofi to display
    awk -F'|' '{print $1}' "$PERSONAS_FILE"
else
    killall rofi &

    PERSONA="$@"
    SYSTEM_PROMPT=$(grep "^$PERSONA|" "$PERSONAS_FILE" | awk -F'|' '{print $2}')
    OLLAMA_MODEL="qwen2.5:1.5b"

    # Pre-warm model while user types
    curl -s http://localhost:11434/api/generate \
        -d "{\"model\": \"$OLLAMA_MODEL\", \"keep_alive\": -1, \"prompt\": \"\"}" \
        -o /dev/null &
    notify-send "ran"

    QUERY=$(rofi -dmenu -p "" \
        -theme-str "window {width: 45%;} inputbar {padding: 12px;} listview {lines: 0; border: 0px;} entry {placeholder: \"Send a message...\";}")

    [ -z "$QUERY" ] && exit 0

    # Thinking indicator
    (
        while true; do
            echo "${THINKING_MESSAGES[$RANDOM % ${#THINKING_MESSAGES[@]}]}"
            sleep 2
        done
    ) | rofi -dmenu -p "" \
        -theme-str "window {width: 35%;} listview {lines: 15; border: 0px; padding: 8px;} inputbar {enabled: false;}" \
        -no-fixed-num-lines &
    THINKING_LOOP_PID=$!

    ANSWER=$(curl -s http://localhost:11434/api/generate \
        -d "$(jq -n \
            --arg model "$OLLAMA_MODEL" \
            --arg system "$SYSTEM_PROMPT" \
            --arg prompt "$QUERY" \
            '{model: $model, system: $system, prompt: $prompt, stream: false,
              keep_alive: -1, options: {num_ctx: 2048, num_predict: 200, num_thread: 4}}'
        )" | jq -r '.response')

    kill "$THINKING_LOOP_PID" 2>/dev/null
    wait $THINKING_LOOP_PID 2>/dev/null

    HEADER="[$PERSONA] — $QUERY"
    SEPARATOR="─────────────────────"
    WRAPPED=$(echo "$ANSWER" | fold -s -w 80)

    LINE_COUNT=$(printf '%s\n%s\n%s' "$HEADER" "$SEPARATOR" "$WRAPPED" | wc -l)
    LINES=$(( LINE_COUNT < 5 ? 5 : (LINE_COUNT > 40 ? 40 : LINE_COUNT) ))

    printf '%s\n%s\n%s' "$HEADER" "$SEPARATOR" "$WRAPPED" | \
        rofi -dmenu -p "" -no-custom \
        -theme-str "window {width: 55%;} listview {lines: $LINES; scrollbar: true; border: 0px;} inputbar {enabled: false;} scrollbar {width: 4px;}"
fi