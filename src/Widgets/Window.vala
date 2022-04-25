/* Window.vala
 *
 * Copyright 2021-2022 Diego Iván
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    [GtkTemplate (ui = "/io/github/diegoivanme/flowtime/window.ui")]
    public class Window : Adw.ApplicationWindow {
        [GtkChild]
        private unowned Gtk.Stack stages;
        [GtkChild]
        private unowned TimerPage work_page;
        [GtkChild]
        private unowned TimerPage break_page;

        [GtkChild]
        private unowned Statistics statistics;
        public Statistics stats {
            get {
                return statistics;
            }
        }

        [GtkChild]
        private unowned SmallView small_view;
        [GtkChild]
        private unowned Adw.Squeezer squeezer;
        public bool small_view_enabled {
            get {
                return squeezer.visible_child == small_view;
            }
        }

        private Gtk.CssProvider provider = new Gtk.CssProvider ();
        private Adw.TimedAnimation height_animation;
        private Adw.TimedAnimation width_animation;

        private uint initial_breaktime;

        public int previous_width {
            get {
                return (int) width_animation.value_from;
            }
            set {
                width_animation.value_from = (double) value;
            }
        }

        public int previous_height {
            get {
                return (int) height_animation.value_from;
            }
            set {
                height_animation.value_from = (double) value;
            }
        }

        private const ActionEntry[] WIN_ENTRIES = {
            { "stop-break", stop_break },
            { "stop-work", stop_work },
            { "enable-small-view", enable_small_view },
            { "disable-small-view", disable_small_view }
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
            typeof(SmallView).ensure ();
        }

        construct {
            Gtk.StyleContext.add_provider_for_display (
                Gdk.Display.get_default (),
                provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );

            var action_group = new SimpleActionGroup ();
            action_group.add_action_entries (WIN_ENTRIES, this);
            insert_action_group ("win", action_group);

            break_page.change_request.connect (stop_break);
            work_page.change_request.connect (stop_work);

            close_request.connect (() => {
                if (work_page.timer.running)
                    stats.worktime_today += work_page.seconds;

                if (break_page.timer.running)
                    stats.breaktime_today += break_page.seconds;

                stats.save ();
                return false;
            });

            var width_target = new Adw.CallbackAnimationTarget (width_callback);
            var height_target = new Adw.CallbackAnimationTarget (height_callback);

            width_animation = new Adw.TimedAnimation (this,
                default_width, 361,
                400, width_target
            );
            width_animation.easing = EASE_IN_OUT_CUBIC;
            bind_property ("small-view-enabled",
                width_animation, "reverse"
            );

            height_animation = new Adw.TimedAnimation (this,
                default_height, 210,
                400, height_target
            );
            height_animation.easing = EASE_IN_OUT_CUBIC;
            bind_property ("small-view-enabled",
                height_animation, "reverse"
            );
        }

        private void stop_break () {
            stats.breaktime_today += initial_breaktime;
            stats.save ();
            break_page.timer.reset_time ();

            stages.set_visible_child_full ("work", CROSSFADE);

            if (Adw.StyleManager.get_default ().dark) {
                provider.load_from_data (
                    (uint8[])"@define-color accent_color #78aeed;"
                );
            }
            else {
                provider.load_from_data (
                    (uint8[])"@define-color accent_color @blue_4;"
                );
            }
            provider.load_from_data (
              (uint8[])"@define-color accent_bg_color @blue_3;"
            );
            if (settings.get_boolean ("autostart"))
                work_page.play_timer ();
        }

        private void stop_work () {
            initial_breaktime = work_page.seconds / 5;
            break_page.timer.seconds = initial_breaktime;
            stats.worktime_today += work_page.seconds;

            work_page.timer.reset_time ();

            stages.set_visible_child_full ("break", CROSSFADE);

            provider.load_from_data (
                (uint8[])"@define-color accent_color @green_4; @define-color accent_bg_color @green_4;"
            );
            if (settings.get_boolean ("autostart"))
                break_page.play_timer ();

            stats.save ();
        }

        private void enable_small_view () {
            previous_width = default_width;
            previous_height = default_height;

            width_animation.play ();
            height_animation.play ();
            notify_property ("small-view-enabled");
        }

        private void disable_small_view () {
            width_animation.play ();
            height_animation.play ();
            notify_property ("small-view-enabled");
        }

        private void width_callback (double v) {
            default_width = (int) v;
        }

        private void height_callback (double v) {
            default_height = (int) v;
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
            stats.breaktime_today += initial_breaktime;

            stats.save ();
            work_page.timer.reset_time ();
        }
    }
}

