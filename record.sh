#!/bin/bash

FILENAME="$HOME/desktop_recording_$(date +%Y%m%d_%H%M%S).mkv"
PID_FILE="/tmp/ffmpeg_recording.pid"

if [ -f "$PID_FILE" ]; then
    echo "Stopping recording..."
    PID=$(cat "$PID_FILE")
    kill "$PID"
    rm "$PID_FILE"
    echo "Recording stopped."
else
    echo "Starting recording..."
    ffmpeg -video_size 1280x1024 -framerate 30 -f x11grab -i :0.0 -f pulse -i default -c:a aac -b:a 192k -c:v libx264 -preset ultrafast -y "$FILENAME" & echo $! > "$PID_FILE"
    echo "Recording started: $FILENAME"
fi
