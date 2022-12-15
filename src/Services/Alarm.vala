/* Alarm.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

[SingleInstance]
public class Flowtime.Services.Alarm : Object {
    private Alarm? instance = null;
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
    public string sound_name { get; set; }

    public Alarm (Timer timer) {
        Object (timer: timer);
        if (instance == null) {
            instance = this;
        }
    }

    construct {
        sound_name = settings.get_string ("tone");
        message (sound_prefix + sound_name);
        player.uri = sound_prefix + settings.get_string ("tone");
    }

    private void on_timer_done () {
        var notification = new GLib.Notification (_("Break is over!"));
        notification.set_body (_("Let's get back to work"));
        notification.set_priority (NORMAL);

        application.send_notification ("Flowtime-Break-Done", notification);
        player.play ();
    }
}
