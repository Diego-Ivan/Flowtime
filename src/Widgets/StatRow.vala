/* StatRow.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    [GtkTemplate (ui = "/io/github/diegoivanme/flowtime/statrow.ui")]
    public class StatRow : Gtk.ListBoxRow {
        [GtkChild]
        private unowned Gtk.Label date_label;
        [GtkChild]
        private unowned Gtk.Label time_label;

        public DateTime date {
            set {
                date_label.label = value.format ("%x");
            }
        }

        public uint time {
            set {
                time_label.label = format_time (value);
            }
        }

        public string formatted_date {
            get {
                return date_label.label;
            }
        }

        public string formatted_time {
            get {
                return time_label.label;
            }
        }

        private string format_time (uint seconds) {
            string unit;
            // If seconds is less than a minute, it will display seconds
            if (seconds < 60) {
                unit = _("seconds");
                return "%u seconds".printf (seconds);
            }

            // If seconds is less than an hour, it will display minutes
            if (seconds < 3600) {
                uint minutes = seconds / 60;
                uint s = seconds % 60;
                string seconds_format, minutes_format;

                unit = _("minutes");

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

                var format = "%s:%s %s".printf (minutes_format, seconds_format, unit);
                return format;
            }

            // If seconds is less than a day, it will display hours
            if (seconds < 86400) {
                uint minutes = seconds / 60;
                uint hours = minutes / 60;
                uint m = seconds % 60;
                string minutes_format;

                if (hours == 1 && m == 0) {
                    unit = _("hour");
                }
                else {
                    unit = _("hours");
                }

                if (m < 10) {
                    minutes_format = "0%u".printf (m);
                }
                else {
                    minutes_format = "%u".printf (m);
                }

                return "%u:%s %s".printf (hours, minutes_format, unit);
            }

            // If it's not any of the options before, it will display days :)
            uint days = seconds / 86400;

            if (days == 1) {
                unit = _("day");
            }
            else {
                unit = _("days");
            }

            return "%u %s".printf (days, unit);
        }
    }
}
