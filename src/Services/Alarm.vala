/* Alarm.vala
 *
 * Copyright 2022-2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Flowtime.Services.Alarm : Object {
    private TonePlayer player = new TonePlayer ();
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

    public Alarm (Timer timer) {
        Object (timer: timer);
    }

    private void on_timer_done () {
        var notification = new GLib.Notification (_("Break is over!"));
        notification.set_body (_("Let's get back to work"));
        notification.set_priority (NORMAL);

        application.send_notification ("Flowtime-Break-Done", notification);

        var settings = new Settings ();
        player.play_tone (settings.tone);
    }
}
