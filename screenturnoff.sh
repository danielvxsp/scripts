#!/bin/bash
dpms_status=$(xset q | grep "DPMS is" | awk '{print $3}')

if [ "$dpms_status" = "Enabled" ]; then
    xset s off
    xset -dpms
    echo "Automatic screen turn-off disabled."
else
    xset s on
    xset +dpms
    echo "Automatic screen turn-off enabled."
fi
