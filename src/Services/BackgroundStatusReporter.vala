/* BackgroundStatusReporter.vala
 *
 * Copyright 2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Flowtime.Services.BackgroundStatusReporter {
    private Xdp.Portal portal = new Xdp.Portal ();

    private Timer _timer;
    public Timer timer {
        get {
            return _timer;
        }
        set {
            if (_timer != null) {
                timer.updated.disconnect (on_timer_updated);
            }
            _timer = value;
            timer.updated.connect (on_timer_updated);
        }
    }

    public BackgroundStatusReporter (Timer timer) {
        this.timer = timer;
    }

    private async void on_timer_updated () {
        string status = "";
        switch (timer.mode) {
            case BREAK:
                if (timer.seconds == 0) {
                    status = _("Break is over!");
                } else {
                    status = _("Break Stage: %s".printf (timer.formatted_time));
                }
                break;
            case WORK:
                status = _("Work Stage: %s".printf (timer.formatted_time));
                break;
        }

        try {
            bool success = yield portal.set_background_status (status, null);
            if (!success) {
                critical ("Updating background status failed");
            }
        } catch (Error e) {
            critical (e.message);
        }
    }
}
