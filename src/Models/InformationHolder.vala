/* InformationHolder.vala
 *
 * Copyright 2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public interface Flowtime.Models.InformationHolder : Object {
    public abstract int worktime { get; set; }
    public abstract int breaktime { get; set; }
}
