/* StatList.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    public class StatList : Adw.Bin {
        private Gtk.FileChooserNative filechooser;
        private Gtk.ListView listview;
        private ListStore liststore;

        public void append (StatObject object) {
            liststore.append (object);
        }

        construct {
            filechooser = new Gtk.FileChooserNative (null,
                get_native () as Gtk.Window, SAVE,
                null, null
            );
            filechooser.response.connect (on_filechooser_response);

            liststore = new ListStore (typeof(StatObject));
            var selection_model = new Gtk.NoSelection (liststore);

            var factory = new Gtk.SignalListItemFactory ();
            factory.bind.connect ((item) => {
                item.child = new StatRow (item.item as StatObject);
            });
            listview = new Gtk.ListView (selection_model, factory);
            listview.remove_css_class ("view");
            listview.add_css_class ("background");

            child = listview;
        }

        public void ask_save_file () {
            filechooser.show ();
        }

        private void on_filechooser_response (int res) {
            if (res == Gtk.ResponseType.ACCEPT) {
                save_as_csv.begin ();
            }
        }

        public async void save_as_csv () {
            string format = "date,time";

            for (uint i = 0; i < liststore.get_n_items (); i++) {
                StatObject o = (StatObject) liststore.get_item (i);
                format += "\n\"%s\",\"%s\"".printf (o.formatted_date, o.formatted_time);
            }

            try {
                string path = filechooser.get_file ().get_path ();
                FileUtils.set_contents (path, format);
            }
            catch (Error e) {
                critical (e.message);
            }
        }
    }
}
