/* StatObject.vala
 *
 * Copyright 2022-2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Flowtime.Models.StatObject : Object {
    public string date { get; private set; }
    public string time { get; private set; }

    public StatObject (DateTime date_time, int time_seconds) {
        date = date_time.format ("%x");
        time = format_time (time_seconds);
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
            unit = _("minutes");
            return "%02d:%02d %s".printf (seconds / MINUTE, seconds % MINUTE, unit);
        }

        if (seconds < DAY) {
            int hours = seconds / HOUR;
            int minutes = (seconds % HOUR) / MINUTE;

            if (hours == 1 && minutes == 0) {
                unit = _("hour");
            }
            else {
                unit = _("hours");
            }

            return "%d:%02d %s".printf (seconds / HOUR, minutes, unit);
        }

        int days = seconds / DAY;
        if (days == 1) {
            unit = _("day");
        }
        else {
            unit = _("days");
        }

        return @"$days $unit";
    }
}
