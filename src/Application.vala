/* Application.vala
 *
 * Copyright 2021 Diego Iván <diegoivan.mae@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    public class Application : Adw.Application {
        public Window main_window;
        public Application () {
            Object (
                application_id: "io.github.diegoivanme.flowtime",
                flags: GLib.ApplicationFlags.FLAGS_NONE
            );
        }

        protected override void activate () {
            if (main_window == null) {
                main_window = new Window (this);
            }
            main_window.present ();
        }
    }
}
