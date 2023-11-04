/* Settings.vala
 *
 * Copyright 2022-2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

[SingleInstance]
public class Flowtime.Services.Settings : Object {
    private GLib.Settings settings = new GLib.Settings (Config.APP_ID);

    private int _months_saved;
    public int months_saved {
        get {
            return _months_saved;
        }
        set {
            if (value > 6 || value < 0) {
                critical ("Value for months saved is out of range");
                return;
            }
            _months_saved = value;
        }
    }

    private double _break_percentage;
    public double break_percentage {
        get {
            return _break_percentage;
        }
        set {
            if (value < 10 || value > 100) {
                critical ("Break percentage is out of bounds");
                return;
            }
            _break_percentage = value;
        }
    }

    public string tone { get; set; }
    public bool autostart { get; set; }
    public bool distraction_free { get; set; }
    public bool activate_screensaver { get; set; }

    private Settings? instance = null;
    public Settings () {
        if (instance == null) {
            instance = this;
        }
    }

    construct {
        port_divisor ();

        settings.bind ("tone", this, "tone", DEFAULT);
        settings.bind ("autostart", this, "autostart", DEFAULT);
        settings.bind ("distraction-free", this, "distraction-free", DEFAULT);
        settings.bind ("months-saved", this, "months-saved", DEFAULT);
        settings.bind ("break-percentage", this, "break-percentage", DEFAULT);
        settings.bind ("activate-screensaver", this, "activate-screensaver", DEFAULT);

        settings.delay ();
    }

    public void save () {
        settings.apply ();
    }

    private void port_divisor () {
        int divisor = settings.get_int ("break-divisor");
        if (divisor < 0) {
            return;
        }

        settings.set_double ("break-percentage", 100.0 / divisor);
        settings.set_int ("break-divisor", -1);
    }
}
