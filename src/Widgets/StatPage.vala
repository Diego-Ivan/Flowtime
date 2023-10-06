/* StatPage.vala
 *
 * Copyright 2022-2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

[GtkTemplate (ui = "/io/github/diegoivanme/flowtime/statpage.ui")]
public class Flowtime.StatPage : Adw.Bin {
    public Services.TimePeriod selected_period { get; private set; default = TODAY; }

    static construct {
        typeof (StatInfo).ensure ();
        typeof (TimePeriodRow).ensure ();
    }

    [GtkCallback]
    private void on_details_button_clicked () {
        new StatsWindow ((Gtk.Window) root);
    }

    [GtkCallback]
    private void on_row_activated (Gtk.ListBoxRow row) {
        var period_row = (TimePeriodRow) row;
        selected_period = period_row.time_period;
        notify_property ("selected-period");
    }
}

public class Flowtime.TimePeriodRow : Adw.ActionRow {
    private Services.TimePeriod _time_period;
    public Services.TimePeriod time_period {
        get {
            return _time_period;
        }
        set {
            _time_period = value;
            title = value.to_string ();
        }
    }

    construct {
        activatable = true;
        add_suffix (new Gtk.Image.from_icon_name ("go-next-symbolic"));
    }
}
