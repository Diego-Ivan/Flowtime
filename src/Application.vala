/* Application.vala
 *
 * Copyright 2021-2023 Diego Iván <diegoivan.mae@gmail.com>
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
    public class Application : Adw.Application {
        public string sound_uri_prefix;
        private Window main_window;

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
            var win = active_window ?? main_window;
            if (win == null) {
                win = new Window (this);
            }
            win.present ();
            // var test_win = new TestWindow ();
            // test_win.present ();
        }

        protected override void shutdown () {
            base.shutdown ();

            var settings = new Services.Settings ();
            settings.save ();
            quit ();
        }

        private void flowtime_preferences () {
            new PreferencesWindow (active_window);
        }

        private void action_close () {
            active_window.close_request ();
            quit ();
        }

        private void about_flowtime () {
            const string COPYRIGHT = "Copyright \xc2\xa9 2021-2023 Diego Iván";
            const string? DEVELOPERS[] = {
                "Diego Iván<diegoivan.mae@gmail.com>",
                null
            };
            const string? ARTISTS[] = {
                "Brage Fuglseth",
                "David Lapshin",
                "Mike Koenig https://soundbible.com/1251-Beep.html",
                "SoundBible https://soundbible.com/1815-A-Tone.html",
                null
            };

            var about = new Adw.AboutWindow () {
                application_icon = Config.APP_ID,
                application_name = "Flowtime",
                artists = ARTISTS,
                copyright = COPYRIGHT,
                developers = DEVELOPERS,
                issue_url = "https://github.com/Diego-Ivan/Flowtime/issues",
                license_type = GPL_3_0,
                transient_for = active_window,
                translator_credits = _("translator_credits"),
                version = Config.VERSION,
                website = "https://github.com/Diego-Ivan/Flowtime",
            };

            about.present ();
        }
    }
}
