/* TestWindow.vala
 *
 * Copyright 2022 = <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Flowtime.TestWindow : Gtk.Window {
    public Services.Timer timer { get; set; default = new Services.Timer (); }
    construct {
        var main_box = new Gtk.Box (VERTICAL, 6);
        var label = new Gtk.Label ("00:00");
        var play_button = new Gtk.Button.with_label ("Play");
        var pause_button = new Gtk.Button.with_label ("Pause");
        var change_button = new Gtk.Button.with_label ("Change mode");

        main_box.append (label);
        main_box.append (play_button);
        main_box.append (pause_button);
        main_box.append (change_button);

        timer.updated.connect (() => {
            label.label = format_time ();
        });

        timer.done.connect (() => {
            message ("A Timer is Done!");
        });

        play_button.clicked.connect (() => {
            timer.start ();
        });

        pause_button.clicked.connect (() => {
            if (timer.running) {
                timer.stop ();
                return;
            }

            timer.resume ();
        });

        change_button.clicked.connect (() => {
            timer.next_mode ();
        });

        child = main_box;
    }

    private string format_time () {
        uint minutes = timer.seconds / 60;
        uint s = timer.seconds % 60;
        string seconds_format, minutes_format;

        if (s < 10) {
            seconds_format = "0%u".printf (s);
        }
        else {
            seconds_format = "%u".printf (s);
        }

        if (minutes < 10) {
            minutes_format = "0%u".printf (minutes);
        }
        else {
            minutes_format = "%u".printf (minutes);
        }

        var format = "%s:%s".printf (minutes_format, seconds_format);
        return format;
    }
}
