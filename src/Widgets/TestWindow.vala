/* TestWindow.vala
 *
 * Copyright 2022 = <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Flowtime.TestWindow : Gtk.Window {
    public Services.Timer timer { get; set; default = new Services.Timer (); }
    construct {
        child = new TimerPage () {
            timer = timer
        };
    }
}
