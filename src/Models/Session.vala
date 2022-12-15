/* Session.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Flowtime.Session : Object {
    public int worktime { get; set; default = 0; }
    public int breaktime { get; set; default = 0; }
}
