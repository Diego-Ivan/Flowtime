/* Screensaver.vala
 *
 * Copyright 2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public errordomain ScreensaverError {
    UNSUPPORTED
}

public class Flowtime.Services.Screensaver : Object {
    private enum ScreensaverInterface {
        FREEDESKTOP,
        GNOME,
        NONE
    }

    private const string BUS_NAME = "org.freedesktop.ScreenSaver";
    private const string OBJECT_PATH = "/org/freedesktop/ScreenSaver";
    private const string SET_METHOD_NAME = "SetActive";
    private const string GET_METHOD_NAME = "GetActive";

    private const string GNOME_BUS_NAME = "org.gnome.ScreenSaver";
    private const string GNOME_OBJECT_PATH = "/org/gnome/ScreenSaver";

    private DBusConnection? connection = null;

    /*
     * In case using BUS_NAME fails, we'll try communicating to org.gnome.ScreenSaver.
     *
     * The reason we are using it as fallback is because org.freedesktop.ScreenSaver.SetActive
     * is not implemented in GNOME, thus throwing an error every time it is called.
     */
    private ScreensaverInterface @interface = NONE;

    [CCode (notify = false)]
    public bool supported {
        get {
            return @interface != NONE;
        }
    }

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

    public async Screensaver (Timer timer) throws IOError, ScreensaverError {
        Object (timer: timer);

        connection = yield Bus.get (SESSION, null);
        bool supports_screensaver = yield system_supports_screensaver ();

        if (!supports_screensaver) {
            throw new ScreensaverError.UNSUPPORTED ("Screensaver is not supported on this system");
        }
    }

    private async bool system_supports_screensaver () {
        try {
            yield connection.call (BUS_NAME, OBJECT_PATH,
                                   BUS_NAME, GET_METHOD_NAME,
                                   null, VariantType.BOOLEAN,
                                   NONE, -1, null);
            @interface = FREEDESKTOP;
            return true;
        } catch (Error e) {
            warning (@"$BUS_NAME.$SET_METHOD_NAME unsupported: $(e.message). Trying fallback...");
        }

        try {
            yield connection.call (GNOME_BUS_NAME, GNOME_OBJECT_PATH,
                                   GNOME_BUS_NAME, GET_METHOD_NAME,
                                   null, VariantType.TUPLE,
                                   NONE, -1, null);
            @interface = GNOME;
            return true;
        } catch (Error e) {
            warning (@"Screensaver is not supported in this system: $(e.message)");
        }

        return false;
    }

    private void timer_mode_changed () {
        var settings = new Settings ();
        bool screensaver = settings.activate_screensaver && settings.autostart;

        if (timer.mode == BREAK && screensaver && supported) {
            activate_screensaver.begin ();
        }
    }

    public async void activate_screensaver () {
        Variant parameters = new Variant.tuple ({ new Variant.boolean (true) });

        switch (@interface) {
            case FREEDESKTOP:
                yield activate_freedesktop (parameters);
                break;
            case GNOME:
                yield activate_gnome (parameters);
                break;
            case NONE:
                break;
        }
    }

    private async void activate_freedesktop (Variant parameters) {
        try {
            yield connection.call (BUS_NAME, OBJECT_PATH,
                                   BUS_NAME, SET_METHOD_NAME,
                                   parameters, VariantType.BOOLEAN,
                                   NONE, -1, null);
        } catch (Error e) {
            warning (e.message);
        }
    }

    private async void activate_gnome (Variant parameters) {
        try {
            yield connection.call (GNOME_BUS_NAME, GNOME_OBJECT_PATH,
                                   GNOME_BUS_NAME, SET_METHOD_NAME,
                                   parameters, null,
                                   NONE, -1, null);
        } catch (Error e) {
            warning (e.message);
        }
    }
}
