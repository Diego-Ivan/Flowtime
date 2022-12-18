/* State.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

[Compact (opaque = true)]
public class Flowtime.Models.State {
    public int worktime { get; set; default = 0; }
    public int breaktime { get; set; default = 0; }
}
