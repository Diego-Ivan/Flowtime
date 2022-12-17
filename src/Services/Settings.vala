/* Settings.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
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
    public string tone { get; set; }
    public bool autostart { get; set; }
    public bool distraction_free { get; set; }

    ~Settings () {
        save ();
    }

    private Settings? instance = null;
    public Settings () {
        if (instance == null) {
            instance = this;
        }
    }

    construct {
        settings.bind ("tone", this, "tone", DEFAULT);
        settings.bind ("autostart", this, "autostart", DEFAULT);
        settings.bind ("distraction-free", this, "distraction-free", DEFAULT);

        settings.delay ();
    }

    public void save () {
        settings.apply ();
    }
}
