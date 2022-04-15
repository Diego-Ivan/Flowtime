/* StatList.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    public class StatList : Adw.Bin {
        private Gtk.ListBox listbox = new Gtk.ListBox ();
        private Gtk.FileChooserNative filechooser;

        public void append (StatRow row) {
            listbox.append (row);
        }

        construct {
            listbox.add_css_class ("boxed-list");
            listbox.selection_mode = NONE;
            child = listbox;

            filechooser = new Gtk.FileChooserNative (null,
                get_native () as Gtk.Window, SAVE,
                null, null
            );
            filechooser.response.connect (on_filechooser_response);
        }

        public void ask_save_file () {
            filechooser.show ();
        }

        private void on_filechooser_response (int res) {
            if (res == Gtk.ResponseType.ACCEPT) {
                save_as_csv.begin ();
            }
        }

        public async string save_as_csv () {
            string body = _("date,time\n");

            int i = 0;
            StatRow row = listbox.get_row_at_index (0) as StatRow;
            while (row != null) {
                body += "\"%s\",\"%s\"\n".printf (row.formatted_date, row.formatted_time);
                i++;
                row = listbox.get_row_at_index (i) as StatRow;
                message ("One iteration");
            }

            string path = filechooser.get_file ().get_path ();
            try {
                FileUtils.set_contents (path, body);
            }
            catch (Error e) {
                critical (e.message);
            }

            return body;
        }
    }
}
