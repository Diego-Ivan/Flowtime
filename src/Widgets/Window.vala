/* Window.vala
 *
 * Copyright 2021-2022 Diego Iván
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    [GtkTemplate (ui = "/io/github/diegoivanme/flowtime/window.ui")]
    public class Window : Adw.ApplicationWindow {
        [GtkChild] unowned Gtk.Stack stages;
        // [GtkChild] unowned QuoteLabel quote_label;
        [GtkChild] unowned TimerPage work_page;
        [GtkChild] unowned TimerPage break_page;

        [GtkChild] unowned Statistics statistics;

        public Statistics stats {
            get {
                return statistics;
            }
        }

        private Gtk.CssProvider provider = new Gtk.CssProvider ();

        private const GLib.ActionEntry[] WIN_ENTRIES = {
            { "preferences", open_settings }
        };

        public Window (Gtk.Application app) {
            Object (application: app);

            stats.retrieve_statistics.begin (() => {
                /*
                 * Internally, FlowtimeStatistics does not use the worktime setters,
                 * Therefore, we have to give it a little "refresh" when the
                 * async method is done :)
                 */
                stats.worktime_today = stats.worktime_today;
                stats.breaktime_today = stats.breaktime_today;
            });
        }

        static construct {
            typeof(WorkTimer).ensure ();
            typeof(BreakTimer).ensure ();
            typeof(StatPage).ensure ();
        }

        construct {
            var action_group = new GLib.SimpleActionGroup ();
            action_group.add_action_entries (WIN_ENTRIES, this);
            insert_action_group ("win", action_group);

            Gtk.StyleContext.add_provider_for_display (
                Gdk.Display.get_default (),
                provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );

            break_page.change_request.connect (on_stop_break_request);
            work_page.change_request.connect (on_stop_work_request);

            close_request.connect (() => {
                if (work_page.timer.running)
                    stats.worktime_today += work_page.seconds;

                if (break_page.timer.running)
                    stats.breaktime_today += break_page.seconds;

                stats.save ();
                return false;
            });
        }

        private void open_settings () {
            new PreferencesWindow (this);
        }

        private void on_stop_break_request () {
            stats.breaktime_today += break_page.seconds;
            stats.save ();
            break_page.timer.reset_time ();

            stages.set_visible_child_full ("work_stage", CROSSFADE);

            provider.load_from_data (
                (uint8[])"@define-color accent_color @blue_3; @define-color accent_bg_color @blue_3;"
            );

            if (settings.get_boolean ("autostart"))
                work_page.play_timer ();
        }

        private void on_stop_work_request () {
            break_page.timer.seconds = work_page.timer.seconds / 5;
            stats.worktime_today += work_page.seconds;

            work_page.timer.reset_time ();

            stages.set_visible_child_full ("break_stage", CROSSFADE);

            provider.load_from_data (
                (uint8[])"@define-color accent_color @green_4; @define-color accent_bg_color @green_4;"
            );

            if (settings.get_boolean ("autostart"))
                break_page.play_timer ();

            stats.save ();
        }

        [GtkCallback]
        private void on_details_button_clicked () {
            new StatsWindow (this, stats);
        }

        [GtkCallback]
        private void on_break_completed () {
            var notification = new GLib.Notification (_("Break is over!"));

            notification.set_body (_("Let's get back to work"));
            notification.set_priority (NORMAL);
            app.send_notification ("Break-Timer-Done", notification);
            player.play ();
            stats.breaktime_today += break_page.seconds;

            stats.save ();
            work_page.timer.reset_time ();
        }
    }
}
