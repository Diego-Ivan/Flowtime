/* State.vala
 *
 * Copyright 2022-2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Flowtime.Models.State : Object, InformationHolder {
    public int worktime { get; set; default = 0; }
    public int breaktime { get; set; default = 0; }
}
