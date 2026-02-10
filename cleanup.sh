#!/bin/bash

# Ensure the script is run with root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)."
   exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "Could not detect OS. Exiting."
    exit 1
fi

echo "--- Starting Cleanup for $NAME ---"

case "$OS" in
    debian|ubuntu|kali|pop)
        echo "Running Debian-based cleanup..."
        apt update && apt autoremove --purge -y
        apt clean
        # Purge residual config files
        REMAINING_CONFIGS=$(dpkg -l | grep '^rc' | awk '{print $2}')
        if [ -n "$REMAINING_CONFIGS" ]; then
            echo "$REMAINING_CONFIGS" | xargs dpkg --purge
        fi
        ;;

    fedora|rhel|centos)
        echo "Running Fedora/DNF-based cleanup..."
        dnf autoremove -y
        dnf clean all
        ;;

    arch|manjaro|endeavouros)
        echo "Running Arch-based cleanup..."
        # Remove orphaned packages (if any exist)
        ORPHANS=$(pacman -Qdtq)
        if [ -n "$ORPHANS" ]; then
            pacman -Rns $ORPHANS --noconfirm
        else
            echo "No orphaned packages to remove."
        fi
        # Clear pacman cache (keep only the last 2 versions)
        if command -v paccache &> /dev/null; then
            paccache -r
        else
            pacman -Sc --noconfirm
        fi
        ;;

    *)
        echo "Unsupported OS: $OS. Skipping package manager cleanup."
        ;;
esac

# Common tasks for all distributions
echo "--- Running generic housekeeping ---"

# 1. Vacuum Systemd Journal logs to 100MB
echo "Limiting journal logs to 100M..."
journalctl --vacuum-size=100M

# 2. Clear thumbnail cache for all users
echo "Clearing thumbnail caches..."
rm -rf /home/*/.cache/thumbnails/*
rm -rf /root/.cache/thumbnails/*

echo "--- $NAME System Cleaned Successfully! ---"
