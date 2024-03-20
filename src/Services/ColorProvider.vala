/* ColorProvider.vala
 *
 * Copyright 2022-2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

[SingleInstance]
public class Flowtime.Services.ColorProvider : Object {
    private Adw.StyleManager style_manager = Adw.StyleManager.get_default ();
    private Gtk.CssProvider break_provider = new Gtk.CssProvider ();
    public Gtk.CssProvider? current_provider { get; private set; }

    private Services.TimerMode _mode;
    public Services.TimerMode mode {
        get {
            return _mode;
        }
        set {
            _mode = value;

            if (mode == WORK) {
                disable_break_colors ();
            }
            else {
                enable_break_colors ();
            }
        }
    }

    public Gdk.RGBA work_accent {
        get {
            var color = Gdk.RGBA ();
            string hex = "#1c71d8";
            color.parse (hex);

            return color;
        }
    }

    public Gdk.RGBA break_accent {
        get {
            var color = Gdk.RGBA ();
            string hex = "#8ff0a4";
            color.parse (hex);

            return color;
        }
    }

    private static ColorProvider? instance = null;
    public ColorProvider () {
        if (instance == null) {
            instance = this;
        }
    }

    construct {
        style_manager.notify["dark"].connect (on_style_changed);

        on_style_changed ();
    }

    private void enable_break_colors () {
        current_provider = break_provider;
        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (),
            current_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );
    }

    private void disable_break_colors () {
        if (current_provider == null) {
            return;
        }

        Gtk.StyleContext.remove_provider_for_display (Gdk.Display.get_default (), current_provider);
        current_provider = null;
    }

    private void on_style_changed () {
        if (Adw.StyleManager.get_default ().dark)
            load_break_dark ();
        else
            load_break_light ();
    }

    private void load_break_dark () {
        break_provider.load_from_string (
            "@define-color accent_color @green_1;@define-color accent_bg_color @green_5;"
        );
    }

    private void load_break_light () {
        break_provider.load_from_string (
            "@define-color accent_color @green_5;@define-color accent_bg_color @green_4;"
        );
    }
}
