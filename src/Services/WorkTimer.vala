/* Timer.vala
 *
 * Copyright 2021 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    public class WorkTimer : GLib.Object {
        public bool running { get; private set; }
        public bool keep_running { get; set; }
        public uint seconds;
        public uint minutes;

        /* Signals */
        public signal void updated (string time);

        public void start () {
            running = true;
            keep_running = true;
            Timeout.add_seconds (1, update_time);
        }

        private bool update_time () {
            string format, seconds_format, minutes_format;
            seconds++;

            if (seconds == 60) {
                minutes++;
                seconds = 0;
            }

            if (seconds < 10) {
                seconds_format = "0%u".printf (seconds);
            }
            else {
                seconds_format = "%u".printf (seconds);
            }

            if (minutes < 10) {
                minutes_format = "0%u".printf (minutes);
            }
            else {
                minutes_format = "%u".printf (minutes);
            }

            format = "%s:%s".printf (minutes_format, seconds_format);
            message (format);
            updated (format);

            return keep_running;
        }

        public void stop () {
            keep_running = false;
        }
    }
}
