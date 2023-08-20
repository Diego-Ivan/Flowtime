/* StatCircle.vala
 *
 * Copyright 2022-2023 Diego Iván <diegoivan.mae@gmail.com>
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

        public Services.TimePeriod time_period { get; set; default = TODAY; }
        private Services.TimerMode _timer_mode;
        public Services.TimerMode timer_mode {
            get {
                return _timer_mode;
            }
            set {
                _timer_mode = value;
                update_values ();
            }
        }

        private int _displayed_value;
        public int displayed_value {
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

        construct {
            unit = _("seconds");
            displayed_value = 0;

            var statistics = new Services.Statistics ();
            statistics.updated.connect (update_values);
        }

        private void update_values () {
            async_update_values.begin ();
        }

        private async void async_update_values () {
            var statistics = new Services.Statistics ();
            displayed_value = statistics.get_time_from_mode_and_period (timer_mode, time_period);
        }

        private string format_time (int seconds) {
            const int MINUTE = 60;
            const int HOUR = 3600;
            const int DAY = 86400;

            if (seconds < MINUTE) {
                unit = _("seconds");
                return seconds.to_string ();
            }

            if (seconds < HOUR) {
                uint minutes = seconds / MINUTE;
                uint s = seconds % MINUTE;
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

                var format = "%s:%s".printf (minutes_format, seconds_format);
                return format;
            }

            if (seconds < DAY) {
                uint hours = seconds / HOUR;
                uint m = (seconds % HOUR) / MINUTE;

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

                return "%u:%s".printf (hours, minutes_format);
            }

            uint days = seconds / DAY;
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
