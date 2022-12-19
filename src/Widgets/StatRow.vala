/* StatRow.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    [GtkTemplate (ui = "/io/github/diegoivanme/flowtime/statrow.ui")]
    public class StatRow : Adw.Bin {
        [GtkChild]
        private unowned Gtk.Label date_label;
        [GtkChild]
        private unowned Gtk.Label time_label;

        public StatRow (Models.StatObject object) {
            date_label.label = object.date;
            time_label.label = object.time;
        }
    }
}
