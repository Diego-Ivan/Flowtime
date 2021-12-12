/* BreakTimer.vala
 *
 * Copyright 2021 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    public class BreakTimer : GLib.Object {
        public uint minutes { get; set; }
        public uint seconds { get; set; }
        public bool running { get; private set; }
        public bool keep_running { get; private set; }
        public bool already_started { get; private set; }

        /* Signals */
        public signal void completed ();
        public signal void updated (string time);

        public void start (uint minutes_, uint seconds_) {
            minutes = minutes_;
            seconds = seconds_;

            if (seconds > 60) {
                minutes += seconds / 60;
                seconds = seconds % 60;
            }

            running = true;
            keep_running = true;
            already_started = true;
            Timeout.add_seconds (1, update_time);
        }

        public void start_back () {
            running = true;
            keep_running = true;

            Timeout.add_seconds (1, update_time);
        }

        public void stop () {
            keep_running = false;
            running = false;
        }

        private bool update_time () {
            string minute_format, second_format;

            if (seconds == 0 && minutes > 0) {
                seconds = 60; // set to 60 so it decreases to 59 later
                minutes--;
            }

            if (seconds == 0 && minutes == 0) {
                keep_running = false;
                completed ();
            }

            seconds--;

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
            message (format);
            updated (format);
            return keep_running;
        }
    }
}
