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
        [GtkChild] unowned PauseButton pause_work_button;
        [GtkChild] unowned PauseButton pause_break_button;

        public WorkTimer work_timer { get; set; }
        public BreakTimer break_timer { get; set; }

        private const GLib.ActionEntry[] WIN_ENTRIES = {
            { "preferences", open_settings }
        };

        public Window (Gtk.Application app) {
            Object (application: app);

            work_timer.updated.connect (() => {
                work_time_label.label = work_timer.format_time ();
            });

            break_timer.updated.connect ((time) => {
                break_time_label.label = break_timer.format_time ();
            });

            break_timer.completed.connect (() => {
                var notification = new GLib.Notification (_("Break is over!"));

                notification.set_body (_("Let's get back to work"));
                notification.set_priority (NORMAL);
                app.send_notification ("Break-Timer-Done", notification);
                player.play ();
                work_timer.reset_time ();
            });
        }

        construct {
            var action_group = new GLib.SimpleActionGroup ();
            action_group.add_action_entries (WIN_ENTRIES, this);
            insert_action_group ("win", action_group);

            work_timer = new WorkTimer ();
            break_timer = new BreakTimer ();

            pause_work_button.timer = work_timer;
            pause_break_button.timer = break_timer;
        }

        private void open_settings () {
            new PreferencesWindow (this);
        }

        [GtkCallback]
        private void finish_break_cb () {
            stages.set_visible_child_full ("work_stage", CROSSFADE);
            headerbar.set_title_widget (null);

            pause_break_button.icon_name = "media-playback-start-symbolic";
            break_timer.reset_time ();
        }

        [GtkCallback]
        private void finish_work_cb () {
            stages.set_visible_child_full ("break_stage", CROSSFADE);
            headerbar.set_title_widget (new QuoteLabel ());

            break_timer.seconds = work_timer.seconds / 5;

            pause_work_button.icon_name = "media-playback-start-symbolic";
            work_timer.reset_time ();
        }
    }
}
