#!/bin/bash
# To revisit
# Get keybindings location based on variation
# -----------------------------------------------------
config_file=$(<~/.config/hypr/confDir/keybinding.conf)
config_file=${config_file//source = ~//home/$USER}

# -----------------------------------------------------
# Path to keybindings config file
# -----------------------------------------------------
echo "Config file: $config_file"
ls -l "$config_file"
head "$config_file"

keybinds=$(awk -F'[=#]' '
    $1 ~ /^bind/ {
        gsub(/\$mainMod/, "SUPER", $0)
        gsub(/^bind[[:space:]]*=+[[:space:]]*/, "", $0)
        split($1, kbarr, ",")
        print kbarr[1] " + " kbarr[2] "\t" $2
    }
' "$config_file")

echo "$keybinds"

sleep 0.2
wofi --dmenu --prompt "Keybinds" <<<"$keybinds"