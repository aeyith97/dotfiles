#!/bin/bash

case $1 in
    d)
        cliphist list | rofi -dmenu -replace -config ~/.config/rofi/cliphist.rasi | cliphist delete
        ;;
    
    w)
        if [ "$(echo -e "Clear\nCancel" | rofi -dmenu -config ~/.config/rofi/short.rasi)" == "Clear" ]; then
            cliphist clear
        fi
        ;;
    
    *)
        cliphist list | rofi -dmenu -replace -config ~/.config/rofi/cliphist.rasi | cliphist decode | wl-copy
        ;;
esac
