/* SoundRow.vala
 *
 * Copyright 2021 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    public struct Sound {
        string title;
        string path;
    }

    public class SoundRow : Adw.ActionRow {
        public Sound sound { get; construct; }
        public Gtk.CheckButton check_button { get; private set; }
        public Gtk.Button play_button { get; private set; }

        public SoundRow (Sound sound_) {
            Object (
                sound: sound_
            );
            title = sound.title;
        }

        construct {
            check_button = new Gtk.CheckButton ();
            add_prefix (check_button);
            activatable_widget = check_button;

            activated.connect (play_sound);
        }

        private void play_sound () {
            player.set_uri (sound.path);
            player.play ();
        }
    }
}
