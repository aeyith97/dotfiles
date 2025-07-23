#!/usr/bin/env python3

import os
import subprocess
import gi
from gi.repository import Gtk, GdkPixbuf

gi.require_version("Gtk", "4.0")

# Paths
THEME_DIR = "/home/aeyith/dotfiles/wallpaper"
HYPRPAPER_CONF = "/home/aeyith/.config/hypr/hyprpaper.conf"
HYPRLOCK_CONF = "/home/aeyith/.config/hypr/hyprlock.conf"
ROFI_GEN_SCRIPT = "/home/aeyith/.config/aeyith/settings/generate-rofi-wallpaper.sh"
LANDSCAPE_SH = "/home/aeyith/.config/aeyith/settings/wallpaper-landscape.sh"
POTRAIT_SH = "/home/aeyith/.config/aeyith/settings/wallpaper-potrait.sh"
CUR_LANDSCAPE = "/home/aeyith/.config/aeyith/current-landscape.txt"
CUR_POTRAIT = "/home/aeyith/.config/aeyith/current-potrait.txt"


class ThemeButton(Gtk.Button):
    def __init__(self, theme_id):
        super().__init__()
        self.theme_id = theme_id

        image_path = os.path.join(THEME_DIR, f"theme-{theme_id}.png")
        if os.path.exists(image_path):
            pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(image_path, 320, 180, True)
            image = Gtk.Image.new_from_pixbuf(pixbuf)
            self.set_child(image)
        else:
            self.set_label(f"Theme {theme_id}")

        self.connect("clicked", self.on_click)

    def on_click(self, button):
        landscape = os.path.join(THEME_DIR, f"landscape-{self.theme_id}.png")
        potrait = os.path.join(THEME_DIR, f"potrait-{self.theme_id}.png")

        # Update hyprpaper.conf
        with open(HYPRPAPER_CONF, "w") as f:
            f.write(f"""preload = {landscape}
preload = {potrait}
wallpaper = HDMI-A-1,{landscape}
wallpaper = HDMI-A-2,{potrait}
""")

        # Update .sh reference files
        os.makedirs(os.path.dirname(LANDSCAPE_SH), exist_ok=True)
        with open(LANDSCAPE_SH, "w") as f:
            f.write(f'#!/bin/bash\necho "{landscape}"\n')
        with open(POTRAIT_SH, "w") as f:
            f.write(f'#!/bin/bash\necho "{potrait}"\n')

        # Update .txt reference files for hyprlock
        with open(CUR_LANDSCAPE, "w") as f:
            f.write(f"{landscape}\n")
        with open(CUR_POTRAIT, "w") as f:
            f.write(f"{potrait}\n")

        # Update hyprlock.conf
        with open(HYPRLOCK_CONF, "w") as f:
            f.write(f"""general {{
    ignore_empty_input = true
}}


background {{
    monitor = HDMI-A-1
    path = {landscape}
    blur_size = 5
    blur_passes = 2
    noise = 0.011
    contrast = 1.0
    brightness = 1.0
    vibrancy = 0.3
}}

background {{
    monitor = HDMI-A-2
    path = {potrait}
    blur_size = 5
    blur_passes = 2
    noise = 0.011
    contrast = 1.0
    brightness = 1.0
    vibrancy = 0.3
}}

input-field {{
    monitor =
    size = 200, 50
    outline_thickness = 3
    dots_size = 0.33
    dots_spacing = 0.15
    dots_center = true
    dots_rounding = -1
    outer_color = $on_primary
    inner_color = $on_surface
    font_color = $surface
    fade_on_empty = true
    fade_timeout = 1000
    placeholder_text = <i>Input Password...</i>
    hide_input = false
    rounding = 40
    check_color = $primary
    fail_color = $error
    fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i>
    fail_transition = 300
    capslock_color = -1
    numlock_color = -1
    bothlock_color = -1
    invert_numlock = false
    swap_font_color = false
    position = 0, -20
    halign = center
    valign = center
    shadow_passes = 10
    shadow_size = 20
    shadow_color = $shadow
    shadow_boost = 1.6
}}

label {{
    monitor =
    text = cmd[update:1000] echo "$TIME"
    color = $on_surface
    font_size = 55
    font_family = Fira Semibold
    position = -100, 70
    halign = right
    valign = bottom
    shadow_passes = 5
    shadow_size = 10
}}

label {{
    monitor =
    text = $USER
    color = $on_surface
    font_size = 20
    font_family = Fira Semibold
    position = -100, 160
    halign = right
    valign = bottom
    shadow_passes = 5
    shadow_size = 10
}}

image {{
    monitor =
    path = $aeyith_cache_folder/square_wallpaper.png
    size = 280
    rounding = 40
    border_size = 4
    border_color = $primary
    rotate = 0
    reload_time = -1
    position = 0, 200
    halign = center
    valign = center
    shadow_passes = 10
    shadow_size = 20
    shadow_color = $shadow
    shadow_boost = 1.6
}}
""")

        # Restart hyprpaper
        subprocess.run(["killall", "hyprpaper"])
        subprocess.Popen(["hyprpaper"])

        # Regenerate Rofi wallpaper config
        subprocess.run([ROFI_GEN_SCRIPT])


class ThemeApp(Gtk.Application):
    def __init__(self):
        super().__init__(application_id="com.aeyith.ThemeManager")
        self.connect("activate", self.on_activate)

    def on_activate(self, app):
        window = Gtk.ApplicationWindow(application=app)
        window.set_title("Wallpaper Theme Manager")
        window.set_default_size(1000, 700)

        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        main_box.set_margin_top(10)
        main_box.set_margin_bottom(10)
        main_box.set_margin_start(10)
        main_box.set_margin_end(10)

        flowbox = Gtk.FlowBox()
        flowbox.set_valign(Gtk.Align.START)
        flowbox.set_max_children_per_line(3)
        flowbox.set_selection_mode(Gtk.SelectionMode.NONE)

        theme_files = sorted(os.listdir(THEME_DIR))
        for fname in theme_files:
            if fname.startswith("theme-") and fname.endswith(".png"):
                theme_id = fname.split("-")[-1].replace(".png", "")
                flowbox.append(ThemeButton(theme_id))

        if not flowbox.get_first_child():
            main_box.append(Gtk.Label(label="No theme images found in wallpaper directory."))

        scroll = Gtk.ScrolledWindow()
        scroll.set_child(flowbox)
        main_box.append(scroll)

        window.set_child(main_box)
        window.present()


if __name__ == "__main__":
    app = ThemeApp()
    app.run()
