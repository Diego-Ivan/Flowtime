/* TimerPage.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    [GtkTemplate (ui = "/io/github/diegoivanme/flowtime/timerpage.ui")]
    public class TimerPage : Gtk.Box {
        [GtkChild]
        private unowned Gtk.Button pause_button;
        [GtkChild]
        private unowned Gtk.Label time_label;
        [GtkChild]
        private unowned Gtk.Label stage_label;

        public Timer _timer;
        public Timer timer {
            get {
                return _timer;
            }
            set {
                _timer = value;
                timer.updated.connect (() => {
                    time_label.label = timer.format_time ();
                });

                timer.notify["running"].connect (() => {
                    message ("Timer is running? == %s", timer.running.to_string ());
                    if (timer.running == true)
                        pause_button.icon_name = "media-playback-pause-symbolic";
                    else
                        pause_button.icon_name = "media-playback-start-symbolic";
                });
            }
        }

        public uint seconds {
            get {
                return timer.seconds;
            }
        }

        public string stage_name {
            get {
                return stage_label.label;
            }
            set {
                stage_label.label = value;
            }
        }

        public signal void change_request ();

        construct {
            change_request.connect (() => {
                pause_button.icon_name = "media-playback-start-symbolic";
            });
        }

        public void play_timer () {
            timer.start ();
        }

        [GtkCallback]
        private void on_pause_button_clicked () {
            if (timer.running) {
                timer.stop ();
            }
            else {
                play_timer ();
            }
        }

        [GtkCallback]
        private void on_next_button_clicked () {
            change_request ();
        }
    }
}
