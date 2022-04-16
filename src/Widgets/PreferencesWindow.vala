/* PreferencesWindow.vala
 *
 * Copyright 2021-2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    [GtkTemplate (ui = "/io/github/diegoivanme/flowtime/preferenceswindow.ui")]
    public class PreferencesWindow : Adw.PreferencesWindow {
        public Window parent_window { get; set; }
        [GtkChild] unowned Adw.PreferencesGroup sounds_group;
        [GtkChild] unowned Gtk.Switch autostart_switch;
        [GtkChild] unowned Gtk.SpinButton months_spinbutton;

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
            var first_row = new SoundRow (sounds[0]);
            sounds_group.add (first_row);
            months_spinbutton.value = 0;

            settings.bind ("autostart",
                autostart_switch, "active",
                DEFAULT
            );

            settings.bind ("months-saved",
                months_spinbutton, "value",
                DEFAULT
            );

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
