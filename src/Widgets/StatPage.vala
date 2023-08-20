/* StatPage.vala
 *
 * Copyright 2022-2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    [GtkTemplate (ui = "/io/github/diegoivanme/flowtime/statpage.ui")]
    public class StatPage : Adw.Bin {
        static construct {
            typeof (StatInfo).ensure ();
        }
    }
}
