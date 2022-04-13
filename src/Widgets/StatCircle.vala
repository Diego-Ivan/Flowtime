/* StatCircle.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    [GtkTemplate (ui = "/io/github/diegoivanme/flowtime/statcircle.ui")]
    public class StatCircle : Adw.Bin {
        [GtkChild]
        private unowned Gtk.Label time_label;
        [GtkChild]
        private unowned Gtk.Label caption_label;

        private uint _displayed_value;
        public uint displayed_value {
            get {
                return _displayed_value;
            }
            set {
                _displayed_value = value;
                time_label.label = format_time (value);
            }
        }

        public string caption {
            get {
                return caption_label.label;
            }
            set {
                caption_label.label = value;
            }
        }

        private string format_time (uint seconds) {
            uint minutes = seconds / 60;
            uint s = seconds % 60;
            string seconds_format, minutes_format;

            if (s < 10) {
                seconds_format = "0%u".printf (s);
            }
            else {
                seconds_format = "%u".printf (s);
            }

            if (minutes < 10) {
                minutes_format = "0%u".printf (minutes);
            }
            else {
                minutes_format = "%u".printf (minutes);
            }

            var format = "%s:%s".printf (minutes_format, seconds_format);
            return format;
        }
    }
}
