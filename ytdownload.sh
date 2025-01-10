#!/bin/bash

# This makes displaying colors ALOT easier
# it gets really messy just using the codes 
RESET='\033[0m'
BOLD='\033[1m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
CYAN='\033[36m'

# menu function
display_menu() {
  echo -e "${CYAN}===================================="
  echo -e "${CYAN}       ${BOLD}YouTube Video Downloader${RESET}"
  echo -e "${CYAN}===================================="
  echo -e "${GREEN}1.${RESET} with specific formats"
  echo -e "${GREEN}2.${RESET} video only"
  echo -e "${GREEN}3.${RESET} audio only"
  echo -e "${RED}4.${RESET} Exit"
  echo -e "${CYAN}===================================="
  echo -e "Please select an option:"
}

# made seperate functions since I added the option to download only video and only audio
download_with_formats() {
  echo -e "${YELLOW}Enter the YouTube link:${RESET}"
  read -r url
  
  # 
  echo -e "${CYAN}Fetching available formats...${RESET}"
  formats=$(yt-dlp -F "$url")
  echo "$formats"
  
  echo -e "${YELLOW}Enter the video format code:${RESET}"
  read -r video_format_code
  echo -e "${YELLOW}Enter the audio format code:${RESET}"
  read -r audio_format_code

  # Checks if the format is valid 
  # it dosent allow you to reenter the format code if its invalid yet
  if [[ -z "$video_format_code" || -z "$audio_format_code" || ! "$formats" =~ "$video_format_code" || ! "$formats" =~ "$audio_format_code" ]]; then
    echo -e "${RED}Invalid format code(s). Exiting.${RESET}"
    return
  fi

  echo -e "${CYAN}Downloading the selected formats...${RESET}"
  yt-dlp -f "$video_format_code+$audio_format_code" "$url"

  echo -e "${GREEN}Download complete.${RESET}"
}

download_video_only() {
  echo -e "${YELLOW}Enter the YouTube link:${RESET}"
  read -r url

  echo -e "${CYAN}Fetching available video formats...${RESET}"
  formats=$(yt-dlp -F "$url" | grep 'video only')
  echo "$formats"

  echo -e "${YELLOW}Enter the video format code:${RESET}"
  read -r video_format_code

  if [[ -z "$video_format_code" || ! "$formats" =~ "$video_format_code" ]]; then
    echo -e "${RED}Invalid format code. Exiting.${RESET}"
    return
  fi

  echo -e "${CYAN}Downloading the video...${RESET}"
  yt-dlp -f "$video_format_code" "$url"

  echo -e "${GREEN}Download complete.${RESET}"
}

download_audio_only() {
  echo -e "${YELLOW}Enter the YouTube link:${RESET}"
  read -r url

  echo -e "${CYAN}Fetching available audio formats...${RESET}"
  formats=$(yt-dlp -F "$url" | grep 'audio only')
  echo "$formats"

  echo -e "${YELLOW}Enter the audio format code:${RESET}"
  read -r audio_format_code

  if [[ -z "$audio_format_code" || ! "$formats" =~ "$audio_format_code" ]]; then
    echo -e "${RED}Invalid format code. Exiting.${RESET}"
    return
  fi

  echo -e "${CYAN}Downloading the audio...${RESET}"
  yt-dlp -f "$audio_format_code" "$url"

  echo -e "${GREEN}Download complete.${RESET}"
}

# Main loop
while true; do
  display_menu
  read -r option

  case "$option" in
    1)
      download_with_formats
      ;;
    2)
      download_video_only
      ;;
    3)
      download_audio_only
      ;;
    4)
      echo -e "${RED}Exiting...${RESET}"
      break
      ;;
    *)
      echo -e "${RED}Invalid option. Please select a valid option [1-4].${RESET}"
      ;;
  esac
done
