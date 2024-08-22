// timer_page.rs
//
// Copyright 2024 Diego Iván M.E <diegoivan.mae@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

use adw::prelude::*;
use adw::subclass::prelude::*;
use gtk::glib;
use crate::services;

mod imp {
    use super::*;
    use once_cell::sync::OnceCell;

    #[derive(Debug, Default, gtk::CompositeTemplate, glib::Properties)]
    #[properties(wrapper_type = super::TimerPage)]
    #[template(resource = "/io/github/diegoivanme/flowtime/timer_page.ui")]
    pub struct TimerPage {
        #[property(get, set = Self::set_timer)]
        pub timer: OnceCell<services::FlowtimeTimer>,

        #[template_child]
        pub time_label: TemplateChild<gtk::Label>,
        #[template_child]
        pub stage_label: TemplateChild<gtk::Label>,
        #[template_child]
        pub(super) pause_button: TemplateChild<gtk::Button>,
    }

    impl TimerPage {
        fn set_timer(&self, timer: &services::FlowtimeTimer) {
            timer.connect_seconds_notify(glib::clone!(@weak self as page => move |timer| {
                let minutes = timer.seconds() / 60;
                let seconds = timer.seconds() % 60;
                let format = format!("{minutes:0>2}:{seconds:0>2}",
                    minutes = minutes,
                    seconds = seconds
                );
                page.time_label.set_label(&format);
            }));

            timer.connect_timer_mode_notify(glib::clone!(@weak self as page => move |_| {
                page.update_stage_name();
            }));
            self.timer.set(timer.clone()).unwrap();
            self.update_stage_name();
        }

        fn update_stage_name(&self) {
            use services::timer::TimerMode;
            let timer = self.timer.get().expect("Expected TimerPage to have a timer");

            match timer.timer_mode() {
                TimerMode::Work => self.stage_label.set_label(
                    &gettextrs::gettext("Work Stage")
                ),
                TimerMode::Break => self.stage_label.set_label(
                    &gettextrs::gettext("Break Stage")
                ),
            }
        }
    }

    #[glib::object_subclass]
    impl ObjectSubclass for TimerPage {
        const NAME: &'static str = "FlowtimeTimerPage";
        type Type = super::TimerPage;
        type ParentType = adw::Bin;

        fn class_init(klass: &mut Self::Class) {
            klass.bind_template();

            klass.install_action("timer-page.pause", None, move |page, _, _| page.pause());
            klass.install_action("timer-page.next", None, move |page, _, _| page.next());
        }

        fn instance_init(obj: &glib::subclass::InitializingObject<Self>) {
            obj.init_template();
        }
    }

    impl ObjectImpl for TimerPage {
        fn properties() -> &'static [glib::ParamSpec] {
            Self::derived_properties()
        }

        fn set_property(&self, id: usize, value: &glib::Value, pspec: &glib::ParamSpec) {
            Self::derived_set_property(&self, id, value, pspec);
        }

        fn property(&self, id: usize, pspec: &glib::ParamSpec) -> glib::Value {
            Self::derived_property(&self, id, pspec)
        }

    }
    impl WidgetImpl for TimerPage {}
    impl BinImpl for TimerPage {}
}

glib::wrapper! {
    pub struct TimerPage(ObjectSubclass<imp::TimerPage>)
        @extends gtk::Widget, adw::Bin;
}

#[gtk::template_callbacks]
impl TimerPage {
    pub fn pause(&self) {
        if self.timer().running() {
            self.imp().pause_button.set_icon_name("media-playback-pause-symbolic");
            self.timer().stop ();
        } else {
            self.imp().pause_button.set_icon_name("media-playback-start-symbolic");
            self.timer().start ();
        }
    }

    pub fn next(&self) {
        self.timer().next_stage();
        println!("Current Stage {:?}", self.timer().timer_mode());
    }
}
