#!/bin/bash

# Path to the actual script
SCRIPT="$HOME/.local/bin/brightctl.sh"

# Get the current hour in 24-hour format
HOUR=$(date +%H)
HOUR=$((10#$HOUR))

# If between 20:00 and 08:00, run brightctl.sh 40
if [ "$HOUR" -ge 20 ] || [ "$HOUR" -lt 8 ]; then
    "$SCRIPT" 33
else
    # Between 08:00 and 20:00, check if 08:00 was missed
    CURRENT_TIME=$(date +%s)
    LAST_MORNING=$(date -d "today 08:00:00" +%s)
    if [ $((CURRENT_TIME - LAST_MORNING)) -gt 600 ]; then
        # Missed 08:00 (more than 10 minutes past), run morning action
        "$SCRIPT" 100
    fi
fi