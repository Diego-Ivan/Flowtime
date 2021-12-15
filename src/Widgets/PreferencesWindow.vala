/* PreferencesWindow.vala
 *
 * Copyright 2021 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    [GtkTemplate (ui = "/io/github/diegoivanme/flowtime/preferenceswindow.ui")]
    public class PreferencesWindow : Adw.PreferencesWindow {
        [GtkChild] unowned Gtk.SpinButton time_spin_button;

        public PreferencesWindow (Adw.ApplicationWindow parent) {
            set_transient_for (parent);
            show ();
        }

        construct {
            time_spin_button.value = settings.get_int ("time-until-break");
            time_spin_button.notify["value"].connect (() => {
                settings.set_int (
                    "time-until-break",
                    (int) time_spin_button.value
                );
            });
        }
    }
}
