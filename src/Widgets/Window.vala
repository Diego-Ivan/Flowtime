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

        // Break Stage
        [GtkChild] unowned Gtk.Button pause_break_button;
        [GtkChild] unowned Gtk.Button finish_break_button;


        public Window (Gtk.Application app) {
            Object (application: app);

            start_break_button.clicked.connect (() => {
                stages.set_visible_child_full ("break_stage", CROSSFADE);
                headerbar.set_title_widget (new QuoteLabel ());
            });

            finish_break_button.clicked.connect (() => {
                stages.set_visible_child_full ("work_stage", CROSSFADE);
                headerbar.set_title_widget (null);
            });

            pause_work_button.clicked.connect (() => {
                message ("Work Timer paused!");
            });

            pause_break_button.clicked.connect (() => {
                message ("Break timer paused!");
            });
        }
    }
}
