/* Screensaver.vala
 *
 * Copyright 2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Flowtime.Services.Screensaver : Object {
    private const string BUS_NAME = "org.freedesktop.ScreenSaver";
    private const string OBJECT_PATH = "/org/freedesktop/ScreenSaver";
    private const string METHOD_NAME = "SetActive";

    private const string GNOME_BUS_NAME = "org.gnome.ScreenSaver";
    private const string GNOME_OBJECT_PATH = "/org/gnome/ScreenSaver";

    private DBusConnection? connection = null;

    /*
     * In case using BUS_NAME fails, we'll try communicating to org.gnome.ScreenSaver.
     *
     * The reason we are using it as fallback is because org.freedesktop.ScreenSaver.SetActive
     * is not implemented in GNOME, thus throwing an error every time it is called. This fallback is
     * unfortunately desktop-specific, a better one must be found.
     */
    private bool use_gnome = false;
    private bool supported = true;

    private Timer _timer;
    public Timer timer {
        get {
            return _timer;
        }
        construct {
            _timer = value;
            timer.notify["mode"].connect(timer_mode_changed);
        }
    }

    ~Screensaver () {
        try {
            connection.close_sync (null);
        } catch (Error e) {
            warning (e.message);
        }
    }

    public async Screensaver (Timer timer) throws IOError {
        Object (timer: timer);
        connection = yield Bus.get (SESSION, null);
    }

    private void timer_mode_changed () {
        var settings = new Settings ();
        bool screensaver = settings.activate_screensaver && settings.autostart;
        if (timer.mode == BREAK && screensaver) {
            try_activate_screensaver.begin ();
        }
    }

    private async void try_activate_screensaver () {
        try {
            yield activate_screensaver ();
        } catch (Error e) {
            critical (e.message);
            supported = false;
        }
    }

    public async void activate_screensaver () throws Error
    requires (connection != null)
    requires (supported) {
        bool succeeded = false;
        Variant parameters = new Variant.tuple ({ new Variant.boolean (true) });

        if (!use_gnome) {
            try {
                Variant result = yield connection.call (BUS_NAME, OBJECT_PATH,
                                                        BUS_NAME, METHOD_NAME,
                                                        parameters, VariantType.BOOLEAN,
                                                        NONE, -1, null);
                succeeded = result.get_boolean ();
            } catch (Error e) {
                warning (e.message);
            }
        }

        if (succeeded) {
            return;
        }

        use_gnome = true;
        warning (@"Calling $BUS_NAME.$METHOD_NAME failed. Trying $GNOME_BUS_NAME");

        yield connection.call (GNOME_BUS_NAME, GNOME_OBJECT_PATH,
                               GNOME_BUS_NAME, METHOD_NAME,
                               parameters, null,
                               NONE, -1, null);
    }
}
