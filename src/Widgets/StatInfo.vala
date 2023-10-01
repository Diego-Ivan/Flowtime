/* StatInfo.vala
 *
 * Copyright 2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

[GtkTemplate (ui = "/io/github/diegoivanme/flowtime/statinfo.ui")]
public class Flowtime.StatInfo : Adw.Bin {
    [GtkChild]
    private unowned Adw.PreferencesGroup overview_group;
    [GtkChild]
    private unowned Gtk.Stack content_stack;

    public unowned Models.InformationHolder info_state { get; private set; }
    private Services.Statistics statistics = new Services.Statistics ();

    private Services.TimePeriod _time_period;
    public Services.TimePeriod time_period {
        get {
            return _time_period;
        }
        set construct {
            _time_period = value;
            set_state_from_period ();
        }
    }

    static construct {
        typeof (StatGraph).ensure ();
    }

    private void format_description () {
        if (info_state.worktime == 0 && info_state.breaktime == 0) {
            content_stack.visible_child_name = "empty";
            return;
        }
        content_stack.visible_child_name = "info";

        string formatted_worktime = format_time (info_state.worktime);
        string formatted_breaktime = format_time (info_state.breaktime);

        overview_group.description = _("You've worked %s and have taken a break during %s.").printf (
            formatted_worktime, formatted_breaktime
        );
    }

    private string format_time (int seconds) {
        const int MINUTE = 60;
        const int HOUR = 3600;
        const int DAY = 86400;
        string unit = "";

        if (seconds < MINUTE) {
            unit = _("seconds");
            return @"$seconds $unit";
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
            return @"$format $unit";
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

            return "%u:%s %s".printf (hours, minutes_format, unit);
        }

        uint days = seconds / DAY;
        if (days == 1) {
            unit = _("day");
        }
        else {
            unit = _("days");
        }

        return @"$days $unit";
    }

    private void disconnect_information_holder () {
        info_state.notify["worktime"].disconnect (format_description);
        info_state.notify["breaktime"].disconnect (format_description);
    }

    private void set_state_from_period () {
        if (info_state != null) {
            disconnect_information_holder ();
        }

        switch (time_period) {
            case TODAY:
                info_state = statistics.today;
                break;
            case WEEK:
                info_state = statistics.week;
                break;
            case MONTH:
                info_state = statistics.month;
                break;
            case ALL:
                info_state = statistics.total;
                break;
        }
        overview_group.title = time_period.to_string ();

        info_state.notify["worktime"].connect (format_description);
        info_state.notify["breaktime"].connect (format_description);
        format_description ();
    }
}
