/* Alarm.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Flowtime.Services.Alarm : Object {
    private Gst.Player player { get; set; default = new Gst.Player (null, null); }
    private unowned GLib.Application application = GLib.Application.get_default ();

    private Timer _timer;
    public Timer timer {
        get {
            return _timer;
        }
        set {
            _timer = value;
            timer.done.connect (on_timer_done);
        }
    }

    private string sound_prefix {
        owned get {
            return "resource://" + application.resource_base_path + "/";
        }
    }

    private string _sound_uri;
    public string sound_uri {
        get {
            return _sound_uri;
        }
        set {
            _sound_uri = value;

        }
    }

    public Alarm (Timer timer) {
        Object (timer: timer);
    }

    construct {
        var settings = new Settings ();
        settings.notify["tone"].connect (on_tone_changed);

        bind_property ("sound_uri", player, "uri", SYNC_CREATE);
    }

    private void on_timer_done () {
        message ("Timer Done");
        var notification = new GLib.Notification (_("Break is over!"));
        notification.set_body (_("Let's get back to work"));
        notification.set_priority (NORMAL);

        application.send_notification ("Flowtime-Break-Done", notification);
        player.play ();
    }

    private void on_tone_changed (Object object, ParamSpec pspec) {
        message ("Settings changed");
        var settings = (Settings) object;
        sound_uri = sound_prefix + settings.tone;
    }
}
