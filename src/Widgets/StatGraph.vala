/* StatGraph.vala
 *
 * Copyright 2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Flowtime.StatGraph : Gtk.Widget {
    private const int DEFAULT_SIZE = 175;
    private const Graphene.Size SIZE = { DEFAULT_SIZE, DEFAULT_SIZE };

    private Models.InformationHolder _state_info = null;
    public Models.InformationHolder state_info {
        get {
            return _state_info;
        }
        set construct {
            if (_state_info != null) {
                state_info.notify["worktime"].disconnect (queue_draw);
                state_info.notify["breaktime"].disconnect (queue_draw);
            }

            _state_info = value;
            state_info.notify["worktime"].connect (queue_draw);
            state_info.notify["breaktime"].connect (queue_draw);

            queue_draw ();
        }
    }

    public override void snapshot (Gtk.Snapshot snapshot) {
        message ("Creating Snapshot");
        var bounds = Graphene.Rect () {
            size = SIZE,
            origin = { 0, 0 }
        };

        Cairo.Context ctx = snapshot.append_cairo (bounds);

        int worktime = state_info.worktime;
        int breaktime = state_info.breaktime;

        const double FULL_CIRCLE = Math.PI * 2;
        double x = DEFAULT_SIZE * 0.5;
        double y = DEFAULT_SIZE * 0.5;
        double radius = DEFAULT_SIZE * 0.5;

        double total_time = worktime + breaktime;
        message (@"$total_time");
        double worktime_proportion = worktime / total_time;
        message (@"$(state_info.worktime / total_time)");
        double worktime_angle = worktime_proportion * FULL_CIRCLE;

        var color_provider = new Services.ColorProvider ();
        Gdk.RGBA work_color = color_provider.work_accent;
        Gdk.RGBA break_color = color_provider.break_accent;

        ctx.set_source_rgba (work_color.red, work_color.green, work_color.blue, 1);
        ctx.line_to (x, y);
        ctx.arc (x, y, radius, 0, worktime_angle);
        ctx.line_to (x, y);
        ctx.fill ();
        ctx.stroke ();

        ctx.set_source_rgba (break_color.red, break_color.green, break_color.blue, 1);
        ctx.line_to (x, y);
        ctx.arc_negative (x, y, radius, 0, worktime_angle);
        ctx.line_to (x, y);
        ctx.fill ();
        ctx.stroke ();
    }

    public override void measure (
        Gtk.Orientation orientation,
        int for_size,
        out int minimum_size,
        out int natural_size,
        out int minimum_baseline,
        out int natural_baseline
    ) {
        minimum_size = natural_size = DEFAULT_SIZE;
        minimum_baseline = natural_baseline = -1;
    }

    public override Gtk.SizeRequestMode get_request_mode () {
        return CONSTANT_SIZE;
    }
}
