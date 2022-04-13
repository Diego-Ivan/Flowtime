/* StatPage.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    [GtkTemplate (ui = "/io/github/diegoivanme/flowtime/statpage.ui")]
    public class StatPage : Gtk.Grid {
        static construct {
            typeof(StatCircle).ensure ();
        }
    }
}
