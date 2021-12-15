/* BreakTimer.vala
 *
 * Copyright 2021 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    public class BreakTimer : Timer, GLib.Object {
        public uint minutes { get; set; }
        public uint seconds { get; set; }
        public bool running { get; set; }
        public bool keep_running { get; set; }
        public bool already_started { get; private set; }

        /* Signals */
        public signal void completed ();

        public void start () {
            if (seconds > 60) {
                minutes += seconds / 60;
                seconds = seconds % 60;
            }

            running = true;
            keep_running = true;
            already_started = true;
            Timeout.add_seconds (1, update_time);
        }

        public void reset_time () {
            stop ();
            seconds = 0;
            minutes = 0;
            updated ();
        }

        private bool update_time () {
            if (!running) {
                return false;
            }

            if (seconds == 0 && minutes == 0) {
                keep_running = false;
                completed ();
                return false;
            }

            if (seconds == 0 && minutes > 0) {
                seconds = 60; // set to 60 so it decreases to 59 later
                minutes--;
            }
            seconds--;

            return keep_running;
        }

        public string format_time () {
            string minute_format, second_format;

            if (minutes < 10) {
                minute_format = "0%u".printf (minutes);
            }
            else {
                minute_format = "%u".printf (minutes);
            }

            if (seconds < 10) {
                second_format = "0%u".printf (seconds);
            }
            else {
                second_format = "%u".printf (seconds);
            }

            var format = "%s:%s".printf (minute_format, second_format);
            return format;
        }
    }
}
