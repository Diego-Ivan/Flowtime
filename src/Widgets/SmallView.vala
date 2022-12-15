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
        private unowned Gtk.Stack stages;
        [GtkChild]
        private unowned TimerPage work_page;
        [GtkChild]
        private unowned TimerPage break_page;

        public string visible_child_name {
            get {
                return stages.visible_child_name;
            }
            set {
                stages.visible_child_name = value;
            }
        }

        construct {
            // work_page.change_request.connect (() => {
            //     activate_action_variant ("win.stop-work", null);
            // });
            // break_page.change_request.connect (() => {
            //     activate_action_variant ("win.stop-break", null);
            // });
        }
    }
}
