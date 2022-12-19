/* StatList.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    [GtkTemplate (ui = "/io/github/diegoivanme/flowtime/statlist.ui")]
    public class StatList : Adw.PreferencesGroup {
        [GtkChild]
        private unowned ListStore list_store;

        static construct {
            typeof(Models.StatObject).ensure ();
        }

        public void append (Models.StatObject object) {
            list_store.append (object);
        }

        public async void save_as_csv (File file) {
            string format = "date,time";

            for (uint i = 0; i < list_store.get_n_items (); i++) {
                var object = (Models.StatObject) list_store.get_item (i);
                format += "\n\"%s\",\"%s\"".printf (object.date, object.time);
            }

            try {
                FileUtils.set_contents (file.get_path (), format);
            }
            catch (Error e) {
                critical (e.message);
            }
        }

        [GtkCallback]
        private void on_item_bound (Gtk.ListItem item) {
            item.child = new StatRow ((Models.StatObject) item.item);
        }

        [GtkCallback]
        private void on_save_button_clicked () {
            var filechooser = new Gtk.FileChooserNative (null,
                (Gtk.Window) get_native (), SAVE,
                null, null
            );
            filechooser.response.connect (on_filechooser_response);
            filechooser.show ();
        }

        private void on_filechooser_response (Gtk.NativeDialog dialog, int res) {
            var file_chooser = (Gtk.FileChooserNative) dialog;

            if (res == Gtk.ResponseType.ACCEPT) {
                save_as_csv.begin (file_chooser.get_file ());
            }
        }
    }
}
