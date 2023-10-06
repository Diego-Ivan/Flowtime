/* PreferencesWindow.vala
 *
 * Copyright 2021-2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    [GtkTemplate (ui = "/io/github/diegoivanme/flowtime/preferenceswindow.ui")]
    public class PreferencesWindow : Adw.PreferencesWindow {
        [GtkChild]
        private unowned Adw.PreferencesGroup sounds_group;
        [GtkChild]
        private unowned Gtk.Switch autostart_switch;
        [GtkChild]
        private unowned Adw.SpinRow months_spinrow;
        [GtkChild]
        private unowned Adw.SpinRow divisor_spinrow;

        private Services.Settings settings = new Services.Settings ();

        public Sound[] sounds = {
            { "Baum", "resource:///io/github/diegoivanme/flowtime/baum.ogg" },
            { "Beep", "resource:///io/github/diegoivanme/flowtime/beep.ogg" },
            { "Bleep", "resource:///io/github/diegoivanme/flowtime/bleep.ogg" },
            { "Tone", "resource:///io/github/diegoivanme/flowtime/tone.ogg" }
        };

        public PreferencesWindow (Gtk.Window parent) {
            transient_for = parent;
            show ();
        }

        construct {
            Gtk.CheckButton? button_group = null;
            months_spinrow.value = 0;

            settings.bind_property ("autostart",
                autostart_switch, "active",
                SYNC_CREATE | BIDIRECTIONAL
            );

            settings.bind_property ("months-saved",
                months_spinrow, "value",
                SYNC_CREATE | BIDIRECTIONAL
            );

            settings.bind_property ("break-divisor",
                                    divisor_spinrow, "value",
                                    SYNC_CREATE | BIDIRECTIONAL);

            for (int i = 0; i < sounds.length; i++) {
                var row = new SoundRow (sounds[i]);
                if (button_group == null) {
                    button_group = row.check_button;
                }

                row.check_button.group = button_group;

                if (settings.tone == sounds[i].title.down () + ".ogg") {
                    row.check_button.active = true;
                }

                sounds_group.add (row);
            }
        }
    }
}
