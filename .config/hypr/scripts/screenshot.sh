#   _________                                         .__            __   
#  /   _____/ ___________   ____   ____   ____   _____|  |__   _____/  |_ 
#  \_____  \_/ ___\_  __ \_/ __ \_/ __ \ /    \ /  ___/  |  \ /  _ \   __\
#  /        \  \___|  | \/\  ___/\  ___/|   |  \\___ \|   Y  (  <_> )  |  
# /_______  /\___  >__|    \___  >\___  >___|  /____  >___|  /\____/|__|  
#         \/     \/            \/     \/     \/     \/     \/             

# Based on https://github.com/hyprwm/contrib/blob/main/grimblast/screenshot.sh

prompt='Screenshot'
mesg="DIR: ~/Screenshots"

# Screenshot Filename
source ~/.config/hypr/settings/screenshot-filename.sh

# Screenshot Folder
source ~/.config/hypr/settings/screenshot-folder.sh

# Screenshot Editor
export GRIMBLAST_EDITOR="$(cat ~/.config/hypr/settings/screenshot-editor.sh)"

# Example for keybindings
# bind = SUPER, p, exec, grimblast save active
# bind = SUPER SHIFT, p, exec, grimblast save area
# bind = SUPER ALT, p, exec, grimblast save output
# bind = SUPER CTRL, p, exec, grimblast save screen

# Quick instant mode: full screen
take_instant_full() {
    grim "$NAME" && notify-send -t 1000 "Screenshot saved to $screenshot_folder/$NAME"
    [[ -f "$HOME/$NAME" && -d "$screenshot_folder" && -w "$screenshot_folder" ]] && mv "$HOME/$NAME" "$screenshot_folder/"
}

# Quick instant mode: area selection
take_instant_area() {
    local pid_picker region

    # freeze screen for region selection
    hyprpicker -r -z &
    pid_picker=$!
    trap 'kill "$pid_picker" 2>/dev/null' EXIT
    sleep 0.1

    # user selects region; kill picker on cancel
    region=$(slurp -b "#00000080" -c "#888888ff" -w 1) || exit 0
    [[ -z "$region" ]] && exit 0

    # unfreeze screen
    kill "$pid_picker" 2>/dev/null
    trap - EXIT

    # capture and notify
    grim -g "$region" "$NAME" && notify-send -t 1000 "Screenshot saved to $screenshot_folder/$NAME"
    [[ -f "$HOME/$NAME" && -d "$screenshot_folder" && -w "$screenshot_folder" ]] && mv "$HOME/$NAME" "$screenshot_folder/"
}

# Handle instant flags
if [[ "$1" == "--instant" ]]; then
    take_instant_full
    exit 0
elif [[ "$1" == "--instant-area" ]]; then
    take_instant_area
    exit 0
fi

# Options
option_1="Immediate"
option_2="Delayed"

option_capture_1="Capture Everything"
option_capture_2="Capture Active Display"
option_capture_3="Capture Selection"

option_time_1="5s"
option_time_2="10s"
option_time_3="20s"
option_time_4="30s"
option_time_5="60s"
#option_time_4="Custom (in seconds)" # Roadmap or someone contribute :)

list_col='1'
list_row='2'

copy='Copy'
save='Save'
copy_save='Copy & Save'
edit='Edit'

# Wofi CMD
wofi_cmd() {
    wofi --dmenu --prompt "Take screenshot" --height 150 --width 300
}

# Pass variables to wofi dmenu
run_wofi() {
    echo -e "$option_1\n$option_2" | wofi_cmd
}

# Timer CMD
timer_cmd() {
    wofi --dmenu \
         --prompt "Choose timer" \
         --lines 5 \
         --width 300
}

# Ask for confirmation
timer_exit() {
    echo -e "$option_time_1\n$option_time_2\n$option_time_3\n$option_time_4\n$option_time_5" | timer_cmd
}

# Confirm and execute
timer_run() {
    selected_timer="$(timer_exit)"
    if [[ "$selected_timer" == "$option_time_1" ]]; then
        countdown=5
        ${1}
    elif [[ "$selected_timer" == "$option_time_2" ]]; then
        countdown=10
        ${1}
    elif [[ "$selected_timer" == "$option_time_3" ]]; then
        countdown=20
        ${1}
    elif [[ "$selected_timer" == "$option_time_4" ]]; then
        countdown=30
        ${1}
    elif [[ "$selected_timer" == "$option_time_5" ]]; then
        countdown=60
        ${1}
    else
        exit
    fi
}
###

####
# Chose Screenshot Type
# CMD
type_screenshot_cmd() {
    wofi --dmenu --prompt "Type of screenshot" --height 300 --width 400
}

# Ask for confirmation
type_screenshot_exit() {
    echo -e "$option_capture_1\n$option_capture_2\n$option_capture_3" | type_screenshot_cmd
}

# Confirm and execute
type_screenshot_run() {
    selected_type_screenshot="$(type_screenshot_exit)"
    if [[ "$selected_type_screenshot" == "$option_capture_1" ]]; then
        option_type_screenshot=screen
        ${1}
    elif [[ "$selected_type_screenshot" == "$option_capture_2" ]]; then
        option_type_screenshot=output
        ${1}
    elif [[ "$selected_type_screenshot" == "$option_capture_3" ]]; then
        option_type_screenshot=area
        ${1}
    else
        exit
    fi
}
###

####
# Choose to save or copy photo
# CMD
copy_save_editor_cmd() {
    wofi --dmenu --prompt "How to save" --height 300 --width 400
}

# Ask for confirmation
copy_save_editor_exit() {
    echo -e "$copy\n$save\n$copy_save\n$edit" | copy_save_editor_cmd
}

# Confirm and execute
copy_save_editor_run() {
    selected_chosen="$(copy_save_editor_exit)"
    if [[ "$selected_chosen" == "$copy" ]]; then
        option_chosen=copy
        ${1}
    elif [[ "$selected_chosen" == "$save" ]]; then
        option_chosen=save
        ${1}
    elif [[ "$selected_chosen" == "$copy_save" ]]; then
        option_chosen=copysave
        ${1}
    elif [[ "$selected_chosen" == "$edit" ]]; then
        option_chosen=edit
        ${1}
    else
        exit
    fi
}
###

timer() {
    if [[ $countdown -gt 10 ]]; then
        notify-send -t 1000 "Taking screenshot in ${countdown} seconds"
        countdown_less_10=$((countdown - 10))
        sleep $countdown_less_10
        countdown=10
    fi
    while [[ $countdown -ne 0 ]]; do
        notify-send -t 1000 "Taking screenshot in ${countdown} seconds"
        countdown=$((countdown - 1))
        sleep 1
    done
}

# take shots
takescreenshot() {
    sleep 1
    grimblast --notify "$option_chosen" "$option_type_screenshot" $NAME
    if [ -f $HOME/$NAME ]; then
        if [ -d $screenshot_folder ]; then
            mv $HOME/$NAME $screenshot_folder/
        fi
    fi
}

takescreenshot_timer() {
    sleep 1
    timer
    sleep 1
    grimblast --notify "$option_chosen" "$option_type_screenshot" $NAME
    if [ -f $HOME/$NAME ]; then
        if [ -d $screenshot_folder ]; then
            mv $HOME/$NAME $screenshot_folder/
        fi
    fi
}

# Execute Command
run_cmd() {
    if [[ "$1" == '--opt1' ]]; then
        type_screenshot_run
        copy_save_editor_run "takescreenshot"
    elif [[ "$1" == '--opt2' ]]; then
        timer_run
        type_screenshot_run
        copy_save_editor_run "takescreenshot_timer"
    fi
}

# Actions
chosen="$(run_wofi)"
case "$chosen" in
    "$option_1")
        run_cmd --opt1
        ;;
    "$option_2")
        run_cmd --opt2
        ;;
    *)
        echo "Cancelled or no match"
        ;;
esac
