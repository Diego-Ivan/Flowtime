/* StatPage.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    [GtkTemplate (ui = "/io/github/diegoivanme/flowtime/statpage.ui")]
    public class StatPage : Gtk.Box {
        [GtkChild]
        private unowned StatCircle today_circle;
        [GtkChild]
        private unowned StatCircle week_circle;
        [GtkChild]
        private unowned StatCircle month_circle;

        public uint today_time {
            get {
                return today_circle.displayed_value;
            }
            set {
                today_circle.displayed_value = value;
            }
        }

        public uint week_time {
            get {
                return week_circle.displayed_value;
            }
            set {
                week_circle.displayed_value = value;
            }
        }

        public uint month_time {
            get {
                return month_circle.displayed_value;
            }
            set {
                month_circle.displayed_value = value;
            }
        }
    }
}
