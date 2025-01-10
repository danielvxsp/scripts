#!/bin/bash

# This is a shell script that aims to immitate an existing game "Progressbar95" which is avaliable on steam if youre intrested
# I wrote this script long ago but it didnt work very well so I dropped it and for some reason I decided to dig it up and 
# have another go at it, I also intend to improve it from this point too since im having fun with it
# For now its reccomended to play in a smaller terminal window since the box is really slow and holding
# left or right makes it move for every given input even if you take your finger off the key

cols=$(tput cols)
rows=$(tput lines)
prbr_width=10
progress=0
prbr_pos=$((cols / 2 - prbr_width / 2))
falling_pos=$((RANDOM % cols))
falling_row=0
sleep_time=0.1

# Hide the cursor
tput civis
stty -echo -icanon time 0 min 0 # dont really remeber what this does but its important

# Clear the terminal on exit 
cleanup() {
    tput cnorm
    tput clear
    stty sane
    echo "Game over!!! progress: $progress%" # add if the user won or lost
}
trap cleanup EXIT


# This is what draws the box  

# Its just a line for now but I would like to change the design
# maybe make it dynamic based on percentage
draw_prbr() {
    tput cup $((rows - 1)) 0
    for ((i = 0; i < cols; i++)); do
        if ((i >= prbr_pos && i < prbr_pos + prbr_width)); then
            printf "\e[42m \e[0m"
        else
            printf " "
        fi
    done
}


# these two functions draw and remove the percentage characters
erase_falling() {
    tput cup $falling_row $falling_pos
    printf " "
}
draw_falling() {
    tput cup $falling_row $falling_pos
    printf "\e[31m%%\e[0m"
}

draw_prbr

while :; do
    erase_falling

    if ((falling_row == rows - 1)); then
        # Collision check
        if ((falling_pos >= prbr_pos && falling_pos < prbr_pos + prbr_width)); then
            ((progress += 10)) # Implement diffrently colored %'s that yeild or exhaust total percentage 
                                # may be an issue for people with custom terminal colors
            sleep_time=$(awk "BEGIN {print ($sleep_time > 0.02) ? $sleep_time - 0.005 : 0.02}")
        fi
        falling_pos=$((RANDOM % cols))
        falling_row=0
    else
        ((falling_row++))
    fi

    draw_falling

    # Handle user input to move the box 
    # theres definitely room for improvement here
    key=$(dd bs=1 count=1 2>/dev/null) 
    case $key in
        $'\x1b')  
            read -n 2 -t 0.1 rest
            if [[ $rest == "[C" ]]; then
                ((prbr_pos = (prbr_pos + 1 < cols - prbr_width) ? prbr_pos + 1 : prbr_pos))  
            elif [[ $rest == "[D" ]]; then
                ((prbr_pos = (prbr_pos > 0) ? prbr_pos - 1 : prbr_pos))  
            fi
            ;;
    esac

    draw_prbr

    tput cup 0 0
    echo -n "Progress: $progress% "

    # Check for win
    if ((progress >= 100)); then
        tput cup $rows 0
        echo "You win!"
        break
    fi

    # controlls the speed of the game 
    sleep $sleep_time
done

