/* PreferencesWindow.vala
 *
 * Copyright 2021 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    [GtkTemplate (ui = "/io/github/diegoivanme/flowtime/preferenceswindow.ui")]
    public class PreferencesWindow : Adw.PreferencesWindow {
        public Window parent_window { get; set; }
        [GtkChild] unowned Gtk.SpinButton time_spin_button;
        [GtkChild] unowned Adw.PreferencesGroup sounds_group;

        public Sound[] sounds = {
            { "Baum", "resource:///io/github/diegoivanme/flowtime/baum.ogg" },
            { "Beep", "resource:///io/github/diegoivanme/flowtime/beep.ogg" },
            { "Bleep", "resource:///io/github/diegoivanme/flowtime/bleep.ogg" },
            { "Tone", "resource:///io/github/diegoivanme/flowtime/tone.ogg" }
        };

        public PreferencesWindow (Window parent) {
            Object (
                parent_window: parent
            );
            set_transient_for (parent_window);
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

            var first_row = new SoundRow (sounds[0]);
            sounds_group.add (first_row);

            if (player.uri == sounds[0].path) {
                first_row.check_button.active = true;
            }

            for (int i = 1; i < sounds.length; i++) {
                var row = new SoundRow (sounds[i]);
                row.check_button.group = first_row.check_button;

                if (player.uri == sounds[i].path) {
                    row.check_button.active = true;
                }

                sounds_group.add (row);
            }
        }
    }
}
