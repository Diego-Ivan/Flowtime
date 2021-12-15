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

        /* Signals */
        public signal void updated ();

        /* Abstract methods */
        public abstract bool update_time ();
        public abstract string format_time ();
        public abstract void reset_time ();

        /* Virtual methods */
        public virtual void resume () {
            running = true;

            Timeout.add_seconds (1, update_time);
        }

        public virtual void stop () {
            running = false;
        }
    }
}
