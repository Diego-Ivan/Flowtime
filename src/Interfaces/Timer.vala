/* Timer.vala
 *
 * Copyright 2021-2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    public abstract class Timer : GLib.Object {
        /* Properties */
        public bool running { get; internal set; }
        public bool already_started { get; internal set; }
        private uint _seconds;
        public uint seconds {
            get {
                return _seconds;
            }
            set {
                _seconds = value;
                updated ();
            }
        }

        construct {
            seconds = 0;
        }

        /* Signals */
        public signal void updated ();

        /* Abstract methods */
        protected abstract bool update_time ();
        public abstract void start ();

        /* Virtual methods */
        public virtual void resume () {
            running = true;

            Timeout.add_seconds (1, update_time);
        }

        public virtual void stop () {
            running = false;
        }

        /* Methods */
        public virtual string format_time () {
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

        public void reset_time () {
            stop ();
            seconds = 0;
            already_started = false;
            updated ();
        }
    }
}
