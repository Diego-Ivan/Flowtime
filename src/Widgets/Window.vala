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
        private unowned Adw.ToolbarView main_view;
        [GtkChild]
        private unowned Adw.ViewSwitcher view_switcher;
        [GtkChild]
        private unowned Adw.ViewSwitcherBar switcher_bar;

        private bool _distraction_free = false;
        public bool distraction_free {
            get {
                return _distraction_free;
            }
            set {
                if (value == distraction_free) {
                    return;
                }

                _distraction_free = value;

                view_switcher.visible = !value;
                switcher_bar.visible = !value;
            }
        }

        public Window (Gtk.Application app) {
            Object (application: app);
        }

        static construct {
            typeof(StatPage).ensure ();
            typeof(SmallView).ensure ();
            typeof(TimerPage).ensure ();
        }

        construct {
            install_property_action ("win.distraction-free", "distraction-free");
            distraction_free = false;
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

        [GtkCallback]
        private void on_details_button_clicked () {
            new StatsWindow (this);
        }
    }
}


