#!/bin/bash

# Open terminal and run yay
kitty --class update-installer -e bash -c "yay -Syu; echo; echo Press enter to close...; read"
