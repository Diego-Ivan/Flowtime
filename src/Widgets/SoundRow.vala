/* SoundRow.vala
 *
 * Copyright 2021-2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    public class SoundRow : Adw.ActionRow {
        public string tone_key { get; set; }
        public Gtk.CheckButton check_button { get; private set; }

        private Services.Settings settings = new Services.Settings ();
        private Services.TonePlayer player = new Services.TonePlayer ();

        public SoundRow (string tone_key) {
            Object (tone_key: tone_key);
            title = player.get_tone_name (tone_key);
        }

        construct {
            check_button = new Gtk.CheckButton ();
            add_prefix (check_button);
            activatable_widget = check_button;

            activated.connect (play_sound);
        }

        private void play_sound () {
            settings.tone = tone_key;
            player.play_tone (tone_key);
        }
    }
}
