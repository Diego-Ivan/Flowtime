/* window.vala
 *
 * Copyright 2021 Diego Iván
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    [GtkTemplate (ui = "/io/github/diegoivanme/flowtime/window.ui")]
    public class Window : Adw.ApplicationWindow {
        [GtkChild] unowned Gtk.Stack stages;
        [GtkChild] unowned Adw.HeaderBar headerbar;
        [GtkChild] unowned Gtk.Label work_time_label;
        [GtkChild] unowned Gtk.Label break_time_label;

        public WorkTimer work_timer { get; set; }
        public BreakTimer break_timer { get; set; }

        public Window (Gtk.Application app) {
            Object (application: app);

            work_timer.updated.connect ((time) => {
                work_time_label.label = time;
            });

            break_timer.updated.connect ((time) => {
                break_time_label.label = time;
            });
        }

        construct {
            work_timer = new WorkTimer ();
            break_timer = new BreakTimer ();
        }

        [GtkCallback]
        private void pause_work_cb () {
            if (work_timer.running)
                work_timer.stop ();
            else
                work_timer.start ();
        }

        [GtkCallback]
        private void pause_break_cb () {
            if (break_timer.running) {
                break_timer.stop ();
            }

            else if (break_timer.already_started) {
                break_timer.start_back ();
            }

            else {
                break_timer.start (5, 0);
            }
        }

        [GtkCallback]
        private void finish_break_cb () {
            stages.set_visible_child_full ("work_stage", CROSSFADE);
            headerbar.set_title_widget (null);
        }

        [GtkCallback]
        private void finish_work_cb () {
            stages.set_visible_child_full ("break_stage", CROSSFADE);
            headerbar.set_title_widget (new QuoteLabel ());
        }
    }
}
