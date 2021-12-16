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
        [GtkChild] unowned Gtk.Button pause_work_button;
        [GtkChild] unowned Gtk.Button pause_break_button;
        [GtkChild] unowned Gtk.Button stop_working_button;
        [GtkChild] unowned Gtk.Button stop_break_button;

        public WorkTimer work_timer { get; set; }
        public BreakTimer break_timer { get; set; }

        public const GLib.ActionEntry[] WIN_ENTRIES = {
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
            });
        }

        construct {
            var action_group = new GLib.SimpleActionGroup ();
            action_group.add_action_entries (WIN_ENTRIES, this);
            insert_action_group ("win", action_group);

            work_timer = new WorkTimer ();
            break_timer = new BreakTimer ();

            player.uri = "resource:///io/github/diegoivanme/flowtime/sounds/tone.ogg";
        }

        private void open_settings () {
            new PreferencesWindow (this);
        }

        [GtkCallback]
        private void pause_work_cb () {
            stop_working_button.sensitive = work_timer.breakable;
            if (work_timer.running) {
                work_timer.stop ();
                pause_work_button.icon_name = "media-playback-start-symbolic";
                return;
            }

            if (work_timer.already_started) {
                work_timer.resume ();
                pause_work_button.icon_name = "media-playback-pause-symbolic";
            }
            else {
                work_timer.start ();
                pause_work_button.icon_name = "media-playback-pause-symbolic";
            }
        }

        [GtkCallback]
        private void pause_break_cb () {
            if (break_timer.running) {
                break_timer.stop ();

                pause_break_button.icon_name = "media-playback-start-symbolic";
                stop_break_button.sensitive = true;
                return;
            }

            if (break_timer.already_started) {
                break_timer.resume ();
                pause_break_button.icon_name = "media-playback-pause-symbolic";
            }

            else {
                break_timer.start ();
                work_timer.reset_time ();
                pause_break_button.icon_name = "media-playback-pause-symbolic";
            }
            stop_break_button.sensitive = false;
        }

        [GtkCallback]
        private void finish_break_cb () {
            stages.set_visible_child_full ("work_stage", CROSSFADE);
            headerbar.set_title_widget (null);
            break_timer.reset_time ();
        }

        [GtkCallback]
        private void finish_work_cb () {
            stages.set_visible_child_full ("break_stage", CROSSFADE);
            headerbar.set_title_widget (new QuoteLabel ());

            break_timer.minutes = work_timer.minutes / 5;
            break_timer.seconds = work_timer.seconds / 5;
            break_time_label.label = break_timer.format_time ();
        }
    }
}
