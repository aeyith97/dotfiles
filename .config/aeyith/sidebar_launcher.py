#!/usr/bin/env python3

import gi
gi.require_version('Gtk', '4.0')
from gi.repository import Gtk, Gio, Gdk

import os
import subprocess
import json

WALLPAPER_PATH = os.path.expanduser("~/.config/aeyith/current_landscape.txt")

def run_pywal(wallpaper_path):
    if not os.path.exists(wallpaper_path):
        print(f"[WARN] Wallpaper file does not exist: {wallpaper_path}")
        return
    subprocess.run(["wal", "-n", "-q", "-i", wallpaper_path])

def get_pywal_colors():
    try:
        with open(os.path.expanduser("~/.cache/wal/colors.json")) as f:
            data = json.load(f)
            return {
                "background": data["special"]["background"],
                "foreground": data["special"]["foreground"],
                "accent": data["colors"]["color4"],
                "hover": data["colors"]["color5"],
            }
    except Exception as e:
        print(f"[WARN] Failed to load pywal colors: {e}")
        return {
            "background": "#1e1e1e",
            "foreground": "#ffffff",
            "accent": "#5e81ac",
            "hover": "#81a1c1",
        }

class SidebarApp(Gtk.Application):
    def __init__(self):
        super().__init__(application_id="com.aeyith.Sidebar")
        self.window = None

    def do_activate(self):
        if not self.window:
            self.window = Gtk.ApplicationWindow(application=self)
            self.window.set_title("Sidebar Launcher")
            self.window.set_default_size(240, 400)
            self.window.set_resizable(False)
            self.window.set_name("sidebar")  # For CSS styling

            box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
            box.set_margin_top(20)
            box.set_margin_bottom(20)
            box.set_margin_start(20)
            box.set_margin_end(20)

            # Launch Theme Manager Button
            theme_button = Gtk.Button(label="🎨 Theme Manager")
            theme_button.set_name("sidebar-button")
            theme_button.connect("clicked", self.open_theme_manager)
            box.append(theme_button)

            # You can add more buttons below
            # ...

            self.window.set_child(box)

            # Run pywal & apply styling
            self.update_style_from_wallpaper()

        self.window.present()

    def open_theme_manager(self, _button):
        subprocess.Popen(["python", os.path.expanduser("~/.config/aeyith/theme_manager.py")])

    def update_style_from_wallpaper(self):
        try:
            with open(WALLPAPER_PATH) as f:
                wallpaper = f.read().strip()
        except:
            wallpaper = "/home/aeyith/dotfiles/wallpaper/landscape-1.png"

        run_pywal(wallpaper)
        colors = get_pywal_colors()

        css = f"""
        window#sidebar {{
            background-color: {colors['background']};
            border-radius: 20px;
            padding: 16px;
        }}
        button#sidebar-button {{
            background-color: {colors['accent']};
            color: {colors['foreground']};
            font-size: 16px;
            padding: 10px;
            border-radius: 10px;
        }}
        button#sidebar-button:hover {{
            background-color: {colors['hover']};
        }}
        """

        provider = Gtk.CssProvider()
        provider.load_from_data(css.encode())
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

if __name__ == "__main__":
    app = SidebarApp()
    app.run()
