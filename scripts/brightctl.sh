#!/bin/bash
# usage: display-control.sh brightness [time] [display]
# brightness must be between 0-100
# time period to change brightness in seconds (optional, default: 0)
# display is optional (default: all monitors, 1 and 2)

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <brightness> [time] [display]"
    exit 1
fi

# Check if ddcutil is installed
if ! command -v ddcutil >/dev/null 2>&1; then
    echo "Error: ddcutil is not installed or not found in PATH"
    exit 1
fi

# Assign brightness from first argument
brightness="$1"

# Validate brightness is a number between 0 and 100
if ! [[ "$brightness" =~ ^[0-9]+$ ]] || [ "$brightness" -lt 0 ] || [ "$brightness" -gt 100 ]; then
    echo "Error: Brightness must be a number between 0 and 100"
    exit 1
fi

# Get monitor(s) from third argument or use default (1 and 2)
if [ -n "$3" ]; then
    # Validate display is a number
    if ! [[ "$3" =~ ^[0-9]+$ ]]; then
        echo "Error: Display must be a positive number"
        exit 1
    fi
    display_ids=("$3")
else
    display_ids=(1 2)
fi

# Get time from second argument or use default (0 for instant change)
if [ -n "$2" ]; then
    time="$2"
    # Validate time is a non-negative number
    if ! [[ "$time" =~ ^[0-9]+$ ]]; then
        echo "Error: Time must be a non-negative number"
        exit 1
    fi

    # Define delay (in seconds)
    delay=30

    # Handle case where time is 0 or very small
    if [ "$time" -eq 0 ]; then
        # Treat as instant change
        steps=0
    elif [ "$time" -lt "$delay" ]; then
        # If time is less than delay, set brightness in one step
        steps=1
        delay="$time"  # Adjust delay to match time
    else
        # Calculate steps for gradual change
        steps=$(echo "$time / $delay" | bc)
        # Ensure steps is at least 1
        [ "$steps" -lt 1 ] && steps=1
    fi

    # Store initial brightness for each display
    declare -A initial_brightness

    # Get initial brightness for each display
    for display in "${display_ids[@]}"; do
        # Get current brightness using ddcutil
        current=$(ddcutil -t getvcp 10 --display "$display" | cut -d' ' -f4)
        if [ $? -ne 0 ] || [ -z "$current" ] || ! [[ "$current" =~ ^[0-9]+$ ]]; then
            echo "Error: Failed to get brightness for display $display"
            exit 1
        fi
        initial_brightness["$display"]="$current"
        echo "Display $display: Initial brightness = $current"
        sleep 5
    done

    # Gradually change brightness for all displays
    if [ "$steps" -eq 0 ]; then
        # Instant change
        for display in "${display_ids[@]}"; do
            echo "Setting brightness to $brightness on display $display"
            ddcutil setvcp 10 "$brightness" --display "$display"
            if [ $? -ne 0 ]; then
                echo "Error: Failed to set brightness on display $display"
                exit 1
            fi
            sleep 5
        done
    else
        # Gradual change
        for ((step=1; step<=steps; step++)); do
            for display in "${display_ids[@]}"; do
                # Calculate interpolated brightness
                initial=${initial_brightness["$display"]}
                # Linear interpolation: current = initial + (target - initial) * step / steps
                delta=$((brightness - initial))
                increment=$(( (delta * step + (steps / 2)) / steps ))  # Round to nearest integer
                current=$((initial + increment))
                # Ensure we don't overshoot due to integer division
                if [ "$step" -eq "$steps" ]; then
                    current="$brightness"  # Set to target on final step
                fi

                # Ensure current is within 0-100
                if [ "$current" -lt 0 ]; then
                    current=0
                elif [ "$current" -gt 100 ]; then
                    current=100
                fi

                echo "Setting brightness to $current on display $display (step $step/$steps)"
                ddcutil setvcp 10 "$current" --display "$display"
                if [ $? -ne 0 ]; then
                    echo "Error: Failed to set brightness on display $display"
                    exit 1
                fi
                sleep 5
            done
            # Sleep only if not the final step
            if [ "$step" -lt "$steps" ]; then
                sleep "$delay"
            fi
        done
    fi
else
    # Instant brightness change for displays
    for display in "${display_ids[@]}"; do
        echo "Setting brightness to $brightness on display $display"
        ddcutil setvcp 10 "$brightness" --display "$display"

        # Check if the command was successful
        if [ $? -ne 0 ]; then
            echo "Error: Failed to set brightness on display $display"
            exit 1
        fi
        sleep 5
    done
fi