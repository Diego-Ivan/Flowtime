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

#[derive(Default, Debug, Clone, Copy, glib::Enum)]
#[enum_type(name="FlowtimeTimerMode")]
pub enum FlowtimeTimerMode {
    #[default]
    Work,
    Break,
}

mod imp {
    use super::*;
    use std::cell::{Cell, RefCell};
    use once_cell::sync::OnceCell;

    #[derive(Debug, Default, glib::Properties)]
    #[properties(wrapper_type=super::FlowtimeTimer)]
    pub struct FlowtimeTimer {
        #[property(get, builder(FlowtimeTimerMode::default()))]
        pub(crate) timer_mode: Cell<FlowtimeTimerMode>,
        #[property(get, explicit_notify)]
        pub(crate) seconds: Cell<u64>,

        pub(super) last_instant: Cell<Option<Instant>>,

        #[property(get)]
        pub(crate) running: Cell<bool>,
        pub(super) timeout_id: RefCell<Option<glib::SourceId>>
    }

    #[glib::object_subclass]
    impl ObjectSubclass for FlowtimeTimer {
        const NAME: &'static str = "FlowtimeTimer";
        type Type = super::FlowtimeTimer;
        type ParentType = glib::Object;
    }

    #[glib::derived_properties]
    impl ObjectImpl for FlowtimeTimer {
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
    pub(crate) fn new() -> Self {
        glib::Object::builder()
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
        let new_value = match imp.timer_mode.get() {
            FlowtimeTimerMode::Work => imp.seconds.get() + diff_since,
            FlowtimeTimerMode::Break => imp.seconds.get().checked_sub(diff_since).unwrap_or(0),
        };

        imp.seconds.set (new_value);
        self.notify_seconds();

        imp.last_instant.replace(Some(now));

        glib::ControlFlow::Continue
    }
}
