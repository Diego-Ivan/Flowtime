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

        [GtkCallback]
        private void on_item_bound (Gtk.ListItem item) {
            item.child = new StatRow ((Models.StatObject) item.item);
        }
    }
}
