/* window.vala
 *
 * Copyright 2021 Diego Iván
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    [GtkTemplate (ui = "/io/github/diegoivanme/flowtime/window.ui")]
    public class Window : Adw.ApplicationWindow {
        // TODO: Reconsider the stack implementation. Maybe it's better to
        // Just use a single label and a single button :p
        [GtkChild] unowned Gtk.Stack stages;
        [GtkChild] unowned Adw.HeaderBar headerbar;

        // Work Stage
        // This button will start breaks automatically
        // TODO: better naming, this names are confusing af
        [GtkChild] unowned Gtk.Button start_break_button;
        [GtkChild] unowned Gtk.Button pause_work_button;
        [GtkChild] unowned Gtk.Label work_time_label;

        // Break Stage
        [GtkChild] unowned Gtk.Button pause_break_button;
        [GtkChild] unowned Gtk.Button finish_break_button;
        [GtkChild] unowned Gtk.Label break_time_label;

        private WorkTimer work_timer { get; set; }
        private BreakTimer break_timer { get; set; }

        public Window (Gtk.Application app) {
            Object (application: app);

            // TODO: Move callbacks to [GtkCallback]
            start_break_button.clicked.connect (() => {
                stages.set_visible_child_full ("break_stage", CROSSFADE);
                headerbar.set_title_widget (new QuoteLabel ());
            });

            finish_break_button.clicked.connect (() => {
                stages.set_visible_child_full ("work_stage", CROSSFADE);
                headerbar.set_title_widget (null);
            });

            pause_work_button.clicked.connect (() => {
                if (work_timer.running)
                    work_timer.stop ();
                else
                    work_timer.start ();
            });

            pause_break_button.clicked.connect (() => {
                if (break_timer.running) {
                    break_timer.stop ();
                }
                else {
                    if (break_timer.already_started) {
                        break_timer.start_back ();
                    }
                    else {
                        break_timer.start (5, 0);
                    }
                }
            });

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
    }
}
