/* Session.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public struct Flowtime.Models.State {
    public int worktime;
    public int breaktime;

    public State (int @default = 0) {
        worktime = @default;
        breaktime = @default;
    }
}
