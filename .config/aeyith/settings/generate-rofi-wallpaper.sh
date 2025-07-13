#!/bin/bash

# Ensure output folder exists
mkdir -p ~/.cache/aeyith/hyprland-dotfiles

# Get current wallpaper from Hyprpaper config
wp=$(grep "^wallpaper *= *HDMI-A-1" ~/.config/hypr/hyprpaper.conf | cut -d',' -f2-)

# Generate Rasi snippet
echo "* {
    current-image: url(\"$wp\", width);
}" > ~/.cache/aeyith/hyprland-dotfiles/current_wallpaper.rasi