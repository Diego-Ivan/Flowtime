/* Timer.vala
 *
 * Copyright 2021 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    public interface Timer : GLib.Object {
        public abstract bool running { get; set; }
        public abstract uint seconds_remaining { get; set; }
        public abstract uint minutes_remaining { get; set; }

        public signal void done ();
        public signal void update_seconds ();
        public signal void update_minutes ();
    }

    public class WorkTimer : Timer, GLib.Object {
        public bool running { get; private set; default = false; }
        public uint seconds_remaining { get; private set; }
        public uint minutes_remaining { get; private set; }
    }

    public class BreakTimer : Timer, GLib.Object {
        public bool running { get; private set; default = false; }
        public uint seconds_remaining { get; private set; }
        public uint minutes_remaining { get; private set; }
    }
}
