/* Application.vala
 *
 * Copyright 2021-2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    public GLib.Settings settings;
    public Gst.Player player;
    public class Application : Adw.Application {
        public Window main_window;
        public string sound_uri_prefix;

        private const ActionEntry[] APP_ENTRIES = {
            { "quit", action_close },
            { "about", about_flowtime },
            { "preferences", flowtime_preferences }
        };

        public Application () {
            Object (
                application_id: "io.github.diegoivanme.flowtime",
                flags: GLib.ApplicationFlags.FLAGS_NONE
            );
            settings = new GLib.Settings (Config.APP_ID);
            resource_base_path = "/io/github/diegoivanme/flowtime";
            sound_uri_prefix = "resource://" + resource_base_path + "/";

            add_action_entries (APP_ENTRIES, this);
            set_accels_for_action ("app.quit", { "<Ctrl>Q" });
            set_accels_for_action ("app.preferences", { "<Ctrl>comma" });

            Intl.setlocale (LocaleCategory.ALL, "");
            Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.GNOMELOCALEDIR);
            Intl.textdomain (Config.GETTEXT_PACKAGE);
        }

        protected override void activate () {
            if (main_window == null) {
                main_window = new Window (this);
            }
            main_window.present ();
            settings.delay ();

            player = new Gst.Player (null, null);
            var sound = settings.get_string ("tone");
            player.uri = sound_uri_prefix + sound;
        }

        protected override void shutdown () {
            base.shutdown ();

            var tone = player.uri.replace (sound_uri_prefix, "");
            settings.set_string ("tone", tone);

            settings.apply ();
            quit ();
        }

        private void flowtime_preferences () {
            new PreferencesWindow (active_window);
        }

        private void action_close () {
            main_window.close_request ();
            quit ();
        }

        private void about_flowtime () {
            const string COPYRIGHT = "Copyright \xc2\xa9 2021 Diego Iván";
            const string? AUTHORS[] = {
                "Diego Iván<diegoivan.mae@gmail.com>",
                null
            };

            const string? ARTISTS[] = {
                "Mike Koenig https://soundbible.com/1251-Beep.html",
                "SoundBible https://soundbible.com/1815-A-Tone.html",
                null
            };
            string program_name = "Flowtime";

            Gtk.show_about_dialog (
                main_window, // transient for
                "program_name", program_name,
                "logo-icon-name", Config.APP_ID,
                "version", Config.VERSION,
                "copyright", COPYRIGHT,
                "authors", AUTHORS,
                "artists", ARTISTS,
                "license-type", Gtk.License.GPL_3_0,
                "wrap-license", true,
                // Translators: Write your Name<email> here :p
                "translator-credits", _("translator-credits"),
                null
            );
        }
    }
}
