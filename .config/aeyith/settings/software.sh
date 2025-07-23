#!/bin/bash

# Try to launch pamac or bauh if available
if command -v pamac-manager &>/dev/null; then
    pamac-manager &
elif command -v bauh &>/dev/null; then
    bauh &
else
    notify-send "No GUI software manager found" "Install pamac or bauh to use this feature"
fi
