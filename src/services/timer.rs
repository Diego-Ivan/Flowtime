// timer.rs
//
// Copyright 2024 Diego Iván M.E <diegoivan.mae@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

const TIMER_INTERVAL_MS: u64 = 1000;

use gtk::{
    glib::{self, prelude::*, subclass::prelude::*},
};

use std::time::{Duration, Instant};
use crate::services;

#[derive(Default, Debug, Clone, Copy, glib::Enum)]
#[enum_type(name="FlowtimeTimerMode")]
pub enum TimerMode {
    #[default]
    Work,
    Break,
}

mod imp {
    use super::*;
    use std::cell::{Cell, RefCell};
    use once_cell::sync::OnceCell;
    use std::sync::OnceLock;
    use glib::subclass::Signal;

    #[derive(Debug, Default, glib::Properties)]
    #[properties(wrapper_type=super::FlowtimeTimer)]
    pub struct FlowtimeTimer {
        #[property(get, builder(TimerMode::default()))]
        pub(crate) timer_mode: Cell<TimerMode>,
        #[property(get, explicit_notify)]
        pub(crate) seconds: Cell<u64>,

        pub(super) last_instant: Cell<Option<Instant>>,

        #[property(get)]
        pub(crate) running: Cell<bool>,
        pub(super) timeout_id: RefCell<Option<glib::SourceId>>,

        #[property(get, set)]
        pub(crate) statistics: OnceCell<services::Statistics>,
    }

    #[glib::object_subclass]
    impl ObjectSubclass for FlowtimeTimer {
        const NAME: &'static str = "FlowtimeTimer";
        type Type = super::FlowtimeTimer;
        type ParentType = glib::Object;
    }

    #[glib::derived_properties]
    impl ObjectImpl for FlowtimeTimer {
        fn signals() -> &'static [Signal] {
            static SIGNALS: OnceLock<Vec<Signal>> = OnceLock::new();
            SIGNALS.get_or_init(|| {
                vec![Signal::builder("break-done")
                    .return_type::<()>()
                    .build()]
            })
        }

        fn properties() -> &'static [glib::ParamSpec] {
            Self::derived_properties()
        }

        fn set_property(&self, id: usize, value: &glib::Value, pspec: &glib::ParamSpec) {
            self.derived_set_property(id, value, pspec)
        }

        fn property(&self, id: usize, pspec: &glib::ParamSpec) -> glib::Value {
            self.derived_property(id, pspec)
        }
    }
}

glib::wrapper!{
    pub struct FlowtimeTimer(ObjectSubclass<imp::FlowtimeTimer>);
}

impl FlowtimeTimer {
    pub(crate) fn new(statistics: &services::Statistics) -> Self {
        glib::Object::builder()
            .property("statistics", statistics.clone())
            .build()
    }

    pub(crate) fn start(&self) {
        self.imp().running.set(true);
        self.imp().last_instant.replace(Some(Instant::now()));

        let timeout_id = glib::timeout_add_local(
            Duration::from_millis(TIMER_INTERVAL_MS),
            glib::clone!(@weak self as timer => @default-return glib::ControlFlow::Continue, move || {
                timer.timeout()
            }),
        );


        self.imp().timeout_id.replace(Some(timeout_id));
        println!("{:?}", self.imp().timeout_id);
    }

    pub(crate) fn stop(&self) {
        self.imp().running.set(false);
        if let Some(id) = self.imp().timeout_id.take() {
            id.remove();
        }
        self.imp().last_instant.replace(None);
    }

    pub(crate) fn next_stage(&self) {
        let imp = self.imp();
        if imp.running.get() {
            self.stop ();
        }

        self.statistics().add_today_time_for_mode(self.seconds(), self.timer_mode());

        match imp.timer_mode.get() {
            TimerMode::Work => {
                // TODO: Reimplement this once the settings service has been ported
                imp.seconds.set(imp.seconds.get() / 5);
                imp.timer_mode.replace(TimerMode::Break);
                self.notify_seconds();
            },
            TimerMode::Break => {
                imp.seconds.set(0);
                imp.timer_mode.replace(TimerMode::Work);
            },
        };

        self.statistics().save();

        self.notify_timer_mode();
    }

    // TODO: Adapt once the alarm service is back
    fn timeout(&self) -> glib::ControlFlow {
        println!("timeout");
        let imp = self.imp();
        if !imp.running.get() {
            return glib::ControlFlow::Break;
        }

        let now = Instant::now();
        // TODO: Remove the unwrap with a alternative
        let last_instant = imp.last_instant.get().unwrap();
        let diff_since = now.duration_since(last_instant).as_secs();
        let elapsed_seconds = imp.seconds.get();

        let new_value = match imp.timer_mode.get() {
            TimerMode::Work => elapsed_seconds + diff_since,
            TimerMode::Break => match elapsed_seconds.checked_sub(diff_since) {
                Some(value) => value,
                None => {
                    // TODO: This has to be changed once the settings are read
                    self.stop();
                    self.emit_by_name::<()>("break-done", &[]);
                    0
                }
            },
        };

        imp.seconds.set(new_value);
        self.notify_seconds();

        imp.last_instant.replace(Some(now));

        glib::ControlFlow::Continue
    }

    pub(crate) fn connect_break_done<F: Fn(&Self) + 'static> (&self, f: F) -> glib::SignalHandlerId {
        self.connect_closure("break-done", true, glib::closure_local!(|timer| f(timer)))
    }
}
