#!/bin/bash

# this is so retarded 
# Fixing issue with XOpenDisplay
# Set the X11 display 
export DISPLAY=:0
export XAUTHORITY=/home/$(whoami)/.Xauthority  
# set D-bus variables
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

# Check if slstatus is running
if ! pgrep -x "slstatus" > /dev/null; then
    echo "slstatus not running. starting..."
    /usr/local/bin/slstatus &
else
    echo "slstatus is running"
fi
