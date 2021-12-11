/* window.vala
 *
 * Copyright 2021 Diego Iván
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    [GtkTemplate (ui = "/io/github/diegoivanme/flowtime/window.ui")]
    public class Window : Adw.ApplicationWindow {
        public Window (Gtk.Application app) {
            Object (application: app);
        }
    }
}
