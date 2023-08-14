/* StatList.vala
 *
 * Copyright 2022-2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    [GtkTemplate (ui = "/io/github/diegoivanme/flowtime/statlist.ui")]
    public class StatList : Adw.PreferencesGroup {
        private ListStore list_store = new ListStore (typeof(Models.StatObject));
        public ListModel list_model {
            get {
                return list_store;
            }
        }

        static construct {
            typeof(Models.StatObject).ensure ();
            typeof(StatRow).ensure ();
        }

        public void append (Models.StatObject object) {
            list_store.append (object);
        }
    }
}
