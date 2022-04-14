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
        [GtkChild]
        private unowned Gtk.Label unit_label;

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

        public string unit {
            get {
                return unit_label.label;
            }
            private set {
                 unit_label.label = value;
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
            // If seconds is less than a minute, it will display seconds
            if (seconds < 60) {
                unit = _("seconds");
                return seconds.to_string ();
            }

            // If seconds is less than an hour, it will display minutes
            if (seconds < 3600) {
                uint minutes = seconds / 60;
                if (minutes == 1) {
                    unit = _("minute");
                }
                else {
                    unit = _("minutes");
                }

                return minutes.to_string ();
            }

            // If seconds is less than a day, it will display hours
            if (seconds < 86400) {
                uint hours = seconds / 3600;

                if (hours == 1) {
                    unit = _("hour");
                }
                else {
                    unit = _("hours");
                }

                return hours.to_string ();
            }

            uint days = seconds / 86400;

            if (days == 1) {
                unit = _("day");
            }
            else {
                unit = _("days");
            }

            return days.to_string ();
        }
    }
}
