/* Window.vala
 *
 * Copyright 2021-2023 Diego Iván
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

[GtkTemplate (ui = "/io/github/diegoivanme/flowtime/window.ui")]
public class Flowtime.Window : Adw.ApplicationWindow {
    [GtkChild]
    private unowned Services.Timer timer;
    [GtkChild]
    private unowned Adw.ViewStack view_stack;
    [GtkChild]
    private unowned Adw.ViewSwitcher view_switcher;
    [GtkChild]
    private unowned Adw.ViewSwitcherBar switcher_bar;
    [GtkChild]
    private unowned StatInfo overview_info;
    [GtkChild]
    private unowned Adw.NavigationView navigation_view;

    private Adw.Animation hide_animation;
    private Adw.Animation show_animation;
    private Adw.AnimationTarget content_target;
    private Adw.AnimationTarget switchers_target;

    private Services.Screensaver? screensaver = null;

    private bool _distraction_free = false;
    public bool distraction_free {
        get {
            return _distraction_free;
        }
        set {
            bool animations_playing =
                hide_animation.state == PLAYING || show_animation.state == PLAYING;

            if (value == distraction_free || animations_playing) {
                return;
            }

            _distraction_free = value;
            distraction_free_transition ();
        }
    }

    public Window (Gtk.Application app) {
        Object (application: app);
    }

    static construct {
        typeof(StatPage).ensure ();
        typeof(TimerPage).ensure ();
    }

    construct {
        install_property_action ("win.distraction-free", "distraction-free");

        content_target = new Adw.CallbackAnimationTarget (change_content_opacity);
        switchers_target = new Adw.CallbackAnimationTarget (change_switchers_opacity);

        hide_animation = new Adw.TimedAnimation (view_stack, 1, 0, 200, switchers_target) {
            easing = EASE_IN_OUT_CUBIC
        };

        show_animation = new Adw.TimedAnimation (view_stack, 0, 1, 200, content_target) {
            easing = EASE_IN_OUT_CUBIC
        };

        hide_animation.done.connect (() => {
            switcher_bar.visible = view_switcher.visible = !distraction_free;
            view_stack.visible_child_name = "timer";
            show_animation.play ();
        });
        distraction_free = false;

        init_screensaver.begin ();
    }

    private async void init_screensaver () {
        try {
            screensaver = yield new Services.Screensaver (timer);
        } catch (Error e) {
            critical (e.message);
        }
    }

    private void distraction_free_transition () {
        if (view_stack.visible_child_name == "statistics" || switcher_bar.reveal) {
            hide_animation.target = show_animation.target = content_target;
        } else {
            hide_animation.target = show_animation.target = switchers_target;
        }

        hide_animation.play ();
    }

    private void change_switchers_opacity (double @value) {
        switcher_bar.opacity = view_switcher.opacity = value;
    }

    private void change_content_opacity (double @value) {
        switcher_bar.opacity = view_switcher.opacity = view_stack.opacity = value;
    }

    [GtkCallback]
    private bool on_close_request () {
        if (!timer.is_used) {
            timer.save_to_statistics ();
            hide_on_close = false;
        }
        return false;
    }

    [GtkCallback]
    private void change_to_overview (Object source, ParamSpec pspec) {
        var stat_page = (StatPage) source;
        overview_info.time_period = stat_page.selected_period;
        navigation_view.activate_action_variant ("navigation.push", "overview");
    }

    public async bool query_quit () {
        if (!timer.running) {
            timer.save_to_statistics ();
            return true;
        }

        var warning = new Adw.MessageDialog (this, _("There is a Session Active"), _("Do you want to quit?")) {
            close_response = "cancel",
        };

        warning.add_response ("cancel", _("Cancel"));
        warning.add_response ("hide", _("Hide Window"));
        warning.add_response ("quit", _("Quit Session"));

        warning.set_response_appearance ("quit", DESTRUCTIVE);

        string response = yield warning.choose (null);

        if (response == "quit") {
            timer.save_to_statistics ();
            return true;
        }

        if (response == "hide") {
            close_request ();
        }

        return false;
    }

    public void query_save_for_shutdown () {
        timer.save_to_statistics ();
    }
}
