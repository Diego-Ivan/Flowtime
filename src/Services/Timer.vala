/* Timer.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Flowtime.Services.Timer : Object {
    public bool running { get; protected set; default = false; }
    public bool already_started { get; protected set; }

    private int _seconds;
    public int seconds {
        get {
            return _seconds;
        }
        set {
            _seconds = value;
            updated ();
        }
    }
    public TimerMode mode { get; private set; default = WORK; }

    public signal void updated ();
    public signal void done ();

    private const int INTERVAL_MILLISECONDS = 1000;
    private DateTime? last_datetime = null;
    private int initial_breaktime = 0;

    ~Timer () {
        stop ();
        save_to_statistics ();
    }

    construct {
        seconds = 0;

        var color_provider = new ColorProvider ();
        bind_property ("mode", color_provider, "mode", SYNC_CREATE);

        // Init Alarm Service
        new Alarm (this);
    }

    public void start () {
        last_datetime = new DateTime.now_utc ();
        running = true;
        Timeout.add (INTERVAL_MILLISECONDS, timeout);
    }

    public void stop () {
        running = false;
    }

    public void resume () {
        running = true;
        last_datetime = null;
        Timeout.add (INTERVAL_MILLISECONDS, timeout);
    }

    public void next_mode () {
        stop ();
        last_datetime = null;
        save_to_statistics ();

        /*
         * This would mean that we want to change the mode to break. We will obtain the seconds for this
         * mode and change it accordingly
         */
        if (mode == WORK) {
            initial_breaktime = seconds / 5;
            seconds = initial_breaktime;
            mode = BREAK;
        }
        else {
            // Reset timer in case the next mode is work mode
            seconds = 0;
            initial_breaktime = 0;
            mode = WORK;
        }
    }

    public void reset () {
        stop ();
        last_datetime = null;
        seconds = 0;
    }

    public string format_time () {
        uint minutes = seconds / 60;
        uint s = seconds % 60;

        var builder = new StringBuilder ();

        if (minutes < 10) {
            builder.append_printf ("0%u:", minutes);
        }
        else {
            builder.append_printf ("%u:", minutes);
        }

        if (s < 10) {
            builder.append_printf ("0%u", s);
        }
        else {
            builder.append_printf ("%u", s);
        }

        return builder.str;
    }

    public void save_to_statistics () {
        var statistics = new Statistics ();
        if (mode == WORK) {
            statistics.add_time_to_mode (mode, seconds);
        }
        else {
            statistics.add_time_to_mode (mode, initial_breaktime - seconds);
        }
    }

    protected bool timeout () {
        if (!running) {
            return false;
        }

        var current_time = new DateTime.now_utc ();
        // Obtaining the difference between the last and current times, casting it to seconds
        int time_seconds = (int) (current_time.difference (last_datetime) / TimeSpan.SECOND);
        message (time_seconds.to_string ());

        switch (mode) {
            case WORK:
                seconds += time_seconds;
                break;

            case BREAK:
                if (time_seconds >= seconds) {
                    seconds = 0;
                    done ();
                    return false;
                }
                seconds -= time_seconds;
                break;

            default:
                assert_not_reached ();
        }

        last_datetime = current_time;

        return true;
    }
}

public enum Flowtime.Services.TimerMode {
    WORK,
    BREAK
}
