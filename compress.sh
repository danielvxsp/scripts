#!/bin/bash

if ! command -v ffmpeg &> /dev/null; then
    echo "ffmpeg is not installed. Please install it first."
    exit 1
fi

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <show_name> <start_episode> <end_episode> <acceleration_type>"
    echo "<acceleration_type> can be 'cpu', 'nvidia', or 'amd'"
    exit 1
fi

show_name=$1
start_episode=$2
end_episode=$3
acceleration_type=$4

echo "Adjustable Video Compression Script for $show_name"
echo "Leave an option blank to keep the current value."

read -p "Enter desired CRF value (leave blank to keep current): " crf_value
read -p "Enter desired frame rate (leave blank to keep current): " frame_rate
read -p "Enter desired audio bitrate (leave blank to keep current): " audio_bitrate

case "$acceleration_type" in
    cpu)
        codec="libx264"
        preset="veryfast" # Adjust for balance of speed/quality
        ;;
    nvidia)
        codec="h264_nvenc"
        preset="fast"
        ;;
    amd)
        codec="h264_amf"
        preset="medium"
        ;;
    *)
        echo "Invalid acceleration type! Use 'cpu', 'nvidia', or 'amd'."
        exit 1
        ;;
esac

for i in $(seq "$start_episode" "$end_episode"); do
    episode_str="${show_name} Episode $i.mp4"
    
    if [ ! -f "$episode_str" ]; then
        echo "File $episode_str does not exist, skipping."
        continue
    fi

    output_file="${episode_str%.mp4}_compressed.mp4"

    command="ffmpeg -y -i \"$episode_str\" -c:v $codec -vf \"scale=1280:720\" -preset $preset"

    # Enable multi-threading for CPU
    if [ "$acceleration_type" = "cpu" ]; then
        command+=" -threads 4"
    fi

    # Add optional parameters if provided
    if [ -n "$crf_value" ]; then
        command+=" -crf $crf_value"
    fi
    if [ -n "$frame_rate" ]; then
        command+=",fps=$frame_rate"
    fi
    if [ -n "$audio_bitrate" ]; then
        command+=" -b:a $audio_bitrate"
    fi

    command+=" \"$output_file\""
    eval $command

    echo "Compressed $episode_str to $output_file"
    
    rm "$episode_str"
    echo "Deleted original file $episode_str"
done

echo "All specified episodes have been processed."
