/* StatsWindow.vala
 *
 * Copyright 2022-2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    [GtkTemplate (ui = "/io/github/diegoivanme/flowtime/statwindow.ui")]
    public class StatsWindow : Adw.Window {
        [GtkChild]
        private unowned StatList work_list;
        [GtkChild]
        private unowned StatList break_list;
        [GtkChild]
        private unowned Gtk.Button save_button;
        [GtkChild]
        private unowned Gtk.Stack content_stack;

        public StatsWindow (Gtk.Window? parent_window) {
            Object (
                transient_for: parent_window,
                modal: true
            );

            show ();
        }

        construct {
            var statistics = new Services.Statistics ();
            if (statistics.total.worktime == 0) {
                content_stack.visible_child_name = "empty";
                save_button.visible = false;
            }

            foreach (Models.Day day in statistics.all_days) {
                var work_object = new Models.StatObject (day.date, day.worktime);
                work_list.append (work_object);

                var break_object = new Models.StatObject (day.date, day.breaktime);
                break_list.append (break_object);
            }

            if (!statistics.all_days.is_empty ()) {
                work_list.description = _("%s is your most productive day of the week").printf (statistics.productive_day);
            }
        }

        public async void save_as_csv (File file)
            requires (file.query_exists ())
        {
            var statistics = new Services.Statistics ();
            string format = "date,worktime,breatkime";

            foreach (Models.Day day in statistics.all_days) {
                var work_object = new Models.StatObject (day.date, day.worktime);
                var break_object = new Models.StatObject (day.date, day.breaktime);

                format += "\"%s\",\"%s\",\"%s\"\n".printf(work_object.date, work_object.time, break_object.time);
            }

            try {
                FileUtils.set_contents (file.get_path (), format);
            }
            catch (Error e) {
                critical (e.message);
            }
        }

        [GtkCallback]
        private void on_save_button_clicked () {
            save_action.begin ();
        }

        private async void save_action () {
            var file_dialog = new Gtk.FileDialog () {
                modal = true
            };

            try {
                File file = yield file_dialog.save (this, null);
                yield save_as_csv (file);
            }
            catch (Error e) {
                critical (e.message);
            }
        }
    }
}
