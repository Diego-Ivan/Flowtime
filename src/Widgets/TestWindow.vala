/* TestWindow.vala
 *
 * Copyright 2022 = <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Flowtime.TestWindow : Gtk.Window {
    public Services.Timer timer { get; set; default = new Services.Timer (); }
    public Services.Statistics stats { get; set; default = new Services.Statistics (); }

    construct {
        child = new TimerPage () {
            timer = timer
        };

        close_request.connect (() => {
            timer.save_to_statistics ();
            return false;
        });
    }
}
