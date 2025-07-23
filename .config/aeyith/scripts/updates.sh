#!/bin/bash

# Check for repo updates
repo_updates=$(checkupdates 2>/dev/null | wc -l)

# Check for AUR updates
aur_updates=$(yay -Qua 2>/dev/null | wc -l)

total_updates=$((repo_updates + aur_updates))

echo "{\"Total Updates\": \"$total_updates\", \"tooltip\": \"󰚰 $repo_updates repo • 󱍢 $aur_updates AUR\"}"