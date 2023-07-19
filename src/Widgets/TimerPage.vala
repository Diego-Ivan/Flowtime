/* TimerPage.vala
 *
 * Copyright 2022-2023 Diego Iván <diegoivan.mae@gmail.com>
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

        public Services.Timer _timer;
        public Services.Timer timer {
            get {
                return _timer;
            }
            set {
                _timer = value;
                timer.bind_property ("formatted-time", time_label, "label", SYNC_CREATE);

                timer.notify["running"].connect (on_running_changed);
                timer.notify["mode"].connect (update_labels);

                on_running_changed ();
                update_labels ();
            }
        }

        public uint seconds {
            get {
                return timer.seconds;
            }
        }

        private void update_labels () {
            if (timer.mode == WORK) {
                stage_label.label = _("Work Stage");
                return;
            }
            stage_label.label = _("Break Stage");
        }

        private void on_running_changed () {
            if (timer.running) {
                pause_button.icon_name = "media-playback-pause-symbolic";
                pause_button.tooltip_text = _("Pause Timer");
                return;
            }
            pause_button.icon_name = "media-playback-start-symbolic";
            pause_button.tooltip_text = _("Start Timer");
        }

        [GtkCallback]
        private void on_pause_button_clicked () {
            if (timer.running) {
                timer.stop ();
                return;
            }
            timer.start ();
        }

        [GtkCallback]
        private void on_next_button_clicked () {
            timer.next_mode ();
        }
    }
}

