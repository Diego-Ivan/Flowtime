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
        private unowned Gtk.HeaderBar header_bar;

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
                empty ();
            }

            foreach (Models.Day day in statistics.all_days) {
                var work_object = new Models.StatObject (day.date, day.worktime);
                work_list.append (work_object);

                var break_object = new Models.StatObject (day.date, day.breaktime);
                break_list.append (break_object);
            }

            if (statistics.all_days.size > 1) {
                work_list.description = _("%s is your most productive day of the week").printf (statistics.productive_day);
            }
        }

        private void empty () {
            // Empty Header
            header_bar.title_widget = null;
            header_bar.add_css_class ("flat");
            title = "";

            // Status Page
            var status = new Adw.StatusPage () {
                title = _("Start working to see you progress"),
                icon_name = "timer-sand-symbolic"
            };
            status.add_css_class ("compact");
            child = status;
        }
    }
}
