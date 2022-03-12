/* BreakTimer.vala
 *
 * Copyright 2021-2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    public class BreakTimer : Timer {
        public signal void completed ();

        public override void start () {
            already_started = true;
            running = true;
            Timeout.add_seconds (1, update_time);
        }

        protected override bool update_time () {
            if (!running)
                return false;

            if (seconds == 0) {
                completed ();
                return false;
            }

            seconds--;

            return true;
        }
    }
}
