#!/bin/bash

# Define a path in RAM (extremely fast, no disk wear)
TMP_IMG="/dev/shm/ocr_snapshot.png"

# 1. Capture to RAM
hyprshot -m region -o /dev/shm -f ocr_snapshot.png --silent

# 2. Check for QR (Zbar)
QR_DATA=$(zbarimg -q --raw "$TMP_IMG" 2>/dev/null)

if [ -n "$QR_DATA" ]; then
    echo "$QR_DATA" | wl-copy
    notify-send "Text Extrated" "QR Link Copied: $QR_DATA"
    # Auto-open if it looks like a URL
    [[ "$QR_DATA" =~ ^https?:// ]] && xdg-open "$QR_DATA"
    rm "$TMP_IMG"
    exit 0
fi

# 3. OCR Pass (Tesseract)
OCR_TEXT=$(tesseract "$TMP_IMG" stdout -l eng --psm 6 2>/dev/null)

if [ -n "$OCR_TEXT" ]; then
    # Clean and copy
    CLEAN_TEXT=$(echo "$OCR_TEXT" | xargs)
    echo "$CLEAN_TEXT" | wl-copy
    
    # 4. URL Detection & Auto-Open
    if [[ "$CLEAN_TEXT" =~ ^https?:// ]]; then
        notify-send "Text Extracted" "URL Detected & Opened:\n${CLEAN_TEXT:0:80}"
        xdg-open "$CLEAN_TEXT"
    else
        PREVIEW="${CLEAN_TEXT:0:80}"
        [[ ${#CLEAN_TEXT} -gt 80 ]] && PREVIEW="$PREVIEW…"
        notify-send "Text Extracted" "Copied: $PREVIEW"
    fi
else
    notify-send "Text Extractor" "No text or QR detected"
fi

# 5. Clean up RAM
rm "$TMP_IMG"
