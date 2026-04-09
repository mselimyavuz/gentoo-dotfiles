#!/bin/bash

# Directory containing your wallpapers
WALLPAPER_DIR="$HOME/Pictures/WP"

# 1. Start the first wallpaper immediately
# 'find' gets files, 'shuf -n 1' picks one randomly
swaybg -i "$(find "$WALLPAPER_DIR" -type f | shuf -n 1)" -m fill &
OLD_PID=$!

while true; do
    # 2. Wait 30 minutes (1800 seconds)
    sleep 1800

    # 3. Start the next wallpaper
    swaybg -i "$(find "$WALLPAPER_DIR" -type f | shuf -n 1)" -m fill &
    NEXT_PID=$!

    # 4. Wait a moment for the new one to render, then kill the old one
    # This prevents the screen from flashing grey or black
    sleep 1
    kill $OLD_PID
    OLD_PID=$NEXT_PID
done
