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
        [GtkChild]
        private unowned Gtk.HeaderBar header_bar;

        public Window parent_window { get; set; }

        private Services.Statistics _statistics;
        public Services.Statistics statistics {
            get {
                return _statistics;
            }
            construct {
                _statistics = value;

                if (statistics.total.worktime == 0) {
                    header_bar.title_widget = null;
                    header_bar.add_css_class ("flat");
                    title = "";

                    var status = new Adw.StatusPage () {
                        title = _("Start working to see you progress"),
                        icon_name = "timer-sand-symbolic"
                    };
                    status.add_css_class ("compact");
                    child = status;

                    return;
                }

                foreach (Models.Day d in statistics.all_days) {
                    add_new_day_row (d);
                }

                if (statistics.all_days.length () > 1) {
                    work_group.description = _("%s is your most productive day of the week").printf (statistics.productive_day);
                }
            }
        }

        public StatsWindow (Window? p, Services.Statistics stats) {
            Object (
                parent_window: p,
                statistics: stats,
                modal: true
            );

            transient_for = parent_window;
            show ();
        }

        private void add_new_day_row (Models.Day d) {
            var work_object = new Models.StatObject (d.date, d.worktime);
            work_list.append (work_object);

            var break_object = new Models.StatObject (d.date, d.breaktime);
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
