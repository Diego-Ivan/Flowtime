/* StatPage.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    [GtkTemplate (ui = "/io/github/diegoivanme/flowtime/statpage.ui")]
    public class StatPage : Gtk.Box {
        public Services.TimerMode displayed_mode { get; set; default = WORK; }

        static construct {
            typeof (EnumListModel).ensure ();
        }

        [GtkCallback]
        private void on_value_changed (Object source, ParamSpec pspec) {
            var dropdown = (Gtk.DropDown) source;
            var selected = (EnumListItem) dropdown.selected_item;
            displayed_mode = selected.enum_value;
        }
    }

    public class EnumListModel : Object, ListModel {
        private Gee.ArrayList<EnumListItem> list = new Gee.ArrayList<EnumListItem> ();

        construct {
            list.add (new EnumListItem (WORK));
            list.add (new EnumListItem (BREAK));
        }

        public Object? get_item (uint position) {
            return list.get ((int) position);
        }

        public Type get_item_type () {
            return typeof (EnumListModel);
        }

        public uint get_n_items () {
            return list.size;
        }

        public Object? get_object (uint position) {
            return list.get ((int) position);
        }
    }

    public class EnumListItem : Object {
        public Services.TimerMode enum_value { get; set; }
        public string name {
            owned get {
                return enum_value.to_string ();
            }
        }

        public EnumListItem (Services.TimerMode enum_value) {
            Object (enum_value: enum_value);
        }
    }
}
