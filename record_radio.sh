#!/bin/bash

# Set the stream URL
STREAM_URL="tunein-station.m3u8"

# Start recording the stream with ffmpeg
ffmpeg -i $(mpv --no-video --term-status-msg='${stream-url}' $STREAM_URL | grep -o 'http[^ ]*') -c copy temp_recording.mp3 &

# Get the process ID of ffmpeg
FFMPEG_PID=$!

while true; do
    # Get current song title
    TITLE=$(mpv --no-video --term-status-msg='${metadata}' $STREAM_URL | grep -oP '(?<=icy-title: ).*')
    
    if [ -n "$TITLE" ]; then
        # Format filename
        SAFE_TITLE=$(echo "$TITLE" | sed 's/[^a-zA-Z0-9 _-]/_/g')
        
        # Save current segment
        ffmpeg -i temp_recording.mp3 -c copy "$SAFE_TITLE.mp3"
        
        # Clear recording
        > temp_recording.mp3
    fi

    sleep 10  # Adjust based on average song length
done
