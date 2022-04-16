/* StatsWindow.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    [GtkTemplate (ui = "/io/github/diegoivanme/flowtime/statwindow.ui")]
    public class StatsWindow : Gtk.Window {
        [GtkChild]
        private unowned StatList work_list;
        [GtkChild]
        private unowned StatList break_list;
        [GtkChild]
        private unowned Adw.PreferencesGroup work_group;

        public Window parent_window { get; set; }

        private Statistics _statistics;
        public Statistics statistics {
            get {
                return _statistics;
            }
            construct {
                _statistics = value;
                foreach (Day d in statistics.month_list) {
                    add_new_day_row (d);
                }

                work_group.description = _("%s is your most productive day of the week").printf (statistics.productive_day);
            }
        }

        public StatsWindow (Window? p, Statistics stats) {
            Object (
                parent_window: p,
                statistics: stats,
                modal: true
            );

            transient_for = parent_window;
            show ();
        }

        private void add_new_day_row (Day d) {
            var work_object = new StatObject (d.date, d.worktime);
            work_list.append (work_object);

            var break_object = new StatObject (d.date, d.breaktime);
            break_list.append (break_object);
        }

        [GtkCallback]
        private void on_work_save_button_clicked () {
            work_list.ask_save_file ();
        }

        [GtkCallback]
        private void on_break_save_button_clicked () {
            break_list.ask_save_file ();
        }
    }
}
