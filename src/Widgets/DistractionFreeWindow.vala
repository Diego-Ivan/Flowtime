/* DistractionFreeWindow.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    [GtkTemplate (ui = "/io/github/diegoivanme/flowtime/distractionfreewindow.ui")]
    public class DistractionFreeWindow : Adw.ApplicationWindow {
        public DistractionFreeWindow (Gtk.Application app) {
            Object (
                application: app
            );
        }
    }
}
