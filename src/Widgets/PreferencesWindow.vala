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
        private unowned Adw.SpinRow percentage_spinrow;
        [GtkChild]
        private unowned Adw.SwitchRow screensaver_row;

        private Services.Settings settings = new Services.Settings ();

        public Services.Screensaver? screensaver { get; construct; default = null; }

        public PreferencesWindow (Gtk.Window parent, Services.Screensaver? screensaver) {
            Object (
                screensaver: screensaver,
                transient_for: parent
            );
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

            settings.bind_property ("activate-screensaver",
                                    screensaver_row, "active",
                                    SYNC_CREATE | BIDIRECTIONAL);

            settings.bind_property ("break-percentage",
                                    percentage_spinrow, "value",
                                    SYNC_CREATE | BIDIRECTIONAL);

            var tone_player = new Services.TonePlayer ();
            foreach (unowned string key in tone_player.get_tone_keys ()) {
                var row = new SoundRow (key);
                if (button_group == null) {
                    button_group = row.check_button;
                }

                row.check_button.group = button_group;

                if (row.tone_key == settings.tone) {
                    row.check_button.active = true;
                }

                sounds_group.add (row);
            }

            message (@"$(screensaver.supported)");
            screensaver_row.visible = screensaver == null ? false : screensaver.supported;
        }
    }
}
