/* PauseButton.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    public class PauseButton : Gtk.Button {
        public Timer timer { get; set; }

        construct {
            icon_name = "media-playback-start-symbolic";
            halign = CENTER;

            add_css_class ("suggested-action");
            add_css_class ("circular");
            add_css_class ("large-button");

            clicked.connect (on_pause_request);
        }

        private void on_pause_request () {
            if (timer.running) {
                timer.stop ();
                icon_name = "media-playback-start-symbolic";
            }
            else {
                timer.start ();
                icon_name = "media-playback-pause-symbolic";
            }
        }
    }
}
