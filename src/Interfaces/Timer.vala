/* Timer.vala
 *
 * Copyright 2021 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    public interface Timer : GLib.Object {
        /* Properties */
        public abstract bool running { get; set; }
        public abstract bool keep_running { get; set; }

        /* Signals */
        public signal void updated (string time);

        /* Abstract methods */
        public abstract bool update_time ();
        public abstract string format_time ();
        public abstract void reset_time ();

        /* Virtual methods */
        public virtual void resume () {
            running = true;
            keep_running = true;

            Timeout.add_seconds (1, update_time);
        }

        public virtual void stop () {
            running = false;
            keep_running = false;
        }
    }
}
