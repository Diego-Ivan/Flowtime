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

        private Gtk.CssProvider provider = new Gtk.CssProvider ();
        // private Adw.TimedAnimation animation;

        private const GLib.ActionEntry[] WIN_ENTRIES = {
            { "preferences", open_settings }
        };

        public Window (Gtk.Application app) {
            Object (application: app);

            // var callback = new Adw.CallbackAnimationTarget (quote_label_revealer);
            // animation = new Adw.TimedAnimation (quote_label,
            //     0, 1,
            //     stages.transition_duration,
            //     callback
            // );
            // animation.easing = EASE_IN_OUT_CUBIC;
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
        }

        private void open_settings () {
            new PreferencesWindow (this);
        }

        private void on_stop_break_request () {
            // animation.reverse = true;
            // animation.play ();

            break_page.timer.reset_time ();

            stages.set_visible_child_full ("work_stage", CROSSFADE);

            provider.load_from_data (
                (uint8[])"@define-color accent_color @blue_3; @define-color accent_bg_color @blue_3;"
            );

            if (settings.get_boolean ("autostart"))
                work_page.play_timer ();
        }

        private void on_stop_work_request () {
            // quote_label.opacity = 0;
            // quote_label.randomize ();

            // animation.reverse = false;
            // animation.play ();

            break_page.timer.seconds = work_page.timer.seconds / 5;

            work_page.timer.reset_time ();

            stages.set_visible_child_full ("break_stage", CROSSFADE);

            provider.load_from_data (
                (uint8[])"@define-color accent_color @green_4; @define-color accent_bg_color @green_4;"
            );

            if (settings.get_boolean ("autostart"))
                break_page.play_timer ();
        }

        [GtkCallback]
        private void on_break_completed () {
            var notification = new GLib.Notification (_("Break is over!"));

            notification.set_body (_("Let's get back to work"));
            notification.set_priority (NORMAL);
            app.send_notification ("Break-Timer-Done", notification);
            player.play ();
            work_page.timer.reset_time ();
        }

        // private void quote_label_revealer (double v) {
        //     quote_label.opacity = v;
        // }
    }
}
