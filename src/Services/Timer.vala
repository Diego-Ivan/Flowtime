/* Timer.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Flowtime.Services.Timer : Object {
    public bool running { get; protected set; }
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
    public Mode mode { get; private set; }

    public signal void updated ();

    private const int INTERVAL_MILLISECONDS = 1000;
    private DateTime? last_datetime = null;

    construct {
        seconds = 0;
    }

    public void start () {
        last_datetime = new DateTime.now_utc ();
        Timeout.add (INTERVAL_MILLISECONDS, timeout);
    }

    public void stop () {
        running = false;
    }

    public void next_mode () {
        reset ();
        if (mode == WORK) {
            mode = BREAK;
            return;
        }
        mode = WORK;
    }

    public void reset () {
        stop ();
        last_datetime = null;
        seconds = 0;
    }

    protected bool timeout () {
        if (!running) {
            return false;
        }

        var current_time = new DateTime.now_utc ();
        // Obtaining the difference between the last and current times, casting it to seconds
        int time_seconds = (int) (last_datetime.difference (current_time) * TimeSpan.SECOND);

        switch (mode) {
            case WORK:
                seconds += time_seconds;
                break;

            case BREAK:
                if (time_seconds >= seconds) {
                    seconds = 0;
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

public enum Flowtime.Mode {
    WORK,
    BREAK
}
