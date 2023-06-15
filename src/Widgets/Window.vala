/* Window.vala
 *
 * Copyright 2021-2023 Diego Iván
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    [GtkTemplate (ui = "/io/github/diegoivanme/flowtime/window.ui")]
    public class Window : Adw.ApplicationWindow {
        [GtkChild]
        private unowned Services.Timer timer;

        [GtkChild]
        private unowned SmallView small_view;
        [GtkChild]
        private unowned Adw.Squeezer squeezer;

        public bool small_view_enabled {
            get {
                return squeezer.visible_child == small_view;
            }
        }

        private Adw.TimedAnimation height_animation;
        private Adw.TimedAnimation width_animation;

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

        public Services.Statistics stats {
            owned get {
                return new Services.Statistics ();
            }
        }

        private const ActionEntry[] WIN_ENTRIES = {
            { "enable-small-view", enable_small_view },
            { "disable-small-view", disable_small_view }
        };

        public Window (Gtk.Application app) {
            Object (application: app);
        }

        static construct {
            typeof(StatPage).ensure ();
            typeof(SmallView).ensure ();
            typeof(TimerPage).ensure ();
        }

        construct {
            var action_group = new SimpleActionGroup ();
            action_group.add_action_entries (WIN_ENTRIES, this);
            insert_action_group ("win", action_group);

            /*
             * Setup animations for resizing in PiP mode
             */
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

        [GtkCallback]
        private bool on_close_request () {
            if (!timer.is_used) {
                timer.save_to_statistics ();
                hide_on_close = false;
            }
            return false;
        }

        public async bool query_quit () {
            if (!timer.running) {
                timer.save_to_statistics ();
                return true;
            }

            var warning = new Adw.MessageDialog (this, _("There is a Session Active"), _("Do you want to quit?")) {
                close_response = "cancel",
            };

            warning.add_response ("cancel", _("Cancel"));
            warning.add_response ("hide", _("Hide Window"));
            warning.add_response ("quit", _("Quit Session"));

            warning.set_response_appearance ("quit", DESTRUCTIVE);

            string response = yield warning.choose (null);

            if (response == "quit") {
                timer.save_to_statistics ();
                return true;
            }

            if (response == "hide") {
                close_request ();
            }

            return false;
        }

        public void query_save_for_shutdown () {
            timer.save_to_statistics ();
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
            new StatsWindow (this);
        }
    }
}


