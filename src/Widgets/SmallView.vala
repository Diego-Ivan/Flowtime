/* SmallView.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    [GtkTemplate (ui = "/io/github/diegoivanme/flowtime/smallview.ui")]
    public class SmallView : Adw.Bin {
        [GtkChild]
        private unowned TimerPage timer_page;

        private Services.Timer _timer;
        public Services.Timer timer {
            get {
                return _timer;
            }
            set {
                _timer = value;
                timer_page.timer = timer;
            }
        }
    }
}
