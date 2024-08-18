// alarm.rs
//
// Copyright 2024 Diego Iván M.E <diegoivan.mae@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

use gtk::{
    prelude::*,
    glib::{self, subclass::prelude::*},
};

use std::collections::HashMap;
use adw::gio;
use crate::services;

#[derive(Debug)]
struct Sound {
    pub name: String,
    pub gfile: gio::File,
}

#[derive(Debug)]
struct TonePlayer {
    media_file: Option<gtk::MediaFile>,

}

mod imp {
    use super::*;
    use std::cell::{Cell, RefCell};
    #[derive(Debug, Default, glib::Properties)]
    #[properties(wrapper_type = super::Alarm)]
    pub struct Alarm {
        #[property(get, set = Self::set_timer)]
        pub(super) timer: RefCell<Option<services::FlowtimeTimer>>,
        pub(super) table: RefCell<HashMap<String, Sound>>,
        pub(super) media_file: RefCell<gtk::MediaFile>,
    }

    impl Alarm {
        pub fn set_timer(&self, timer: &services::FlowtimeTimer) {
            timer.connect_break_done(glib::clone!(@weak self as alarm => move |_| {
                println!("Break is over!");
                // TODO: Play alarm tone in settings
                alarm.play_tone("Beep");
            }));
            self.timer.replace(Some(timer.clone()));
        }

        pub(crate) fn play_tone(&self, name: &str) {
            let sound_table = self.table.borrow();
            let sound = match sound_table.get(name) {
                Some(sound) => sound,
                None => {
                    eprintln!("The name {name} is not registered in the tone table");
                    return;
                },
            };

            let media_file = self.media_file.borrow();
            if media_file.is_playing() {
                media_file.set_playing(false);
                media_file.clear();
            }

            media_file.set_file(Some(&sound.gfile));
            media_file.play();
        }
    }

    #[glib::object_subclass]
    impl ObjectSubclass for Alarm {
        const NAME: &'static str = "FlowtimeAlarm";
        type Type = super::Alarm;
        type ParentType = glib::Object;
    }

    #[glib::derived_properties]
    impl ObjectImpl for Alarm {
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
}

glib::wrapper! {
    pub struct Alarm(ObjectSubclass<imp::Alarm>);
}

impl Alarm {
    pub(crate) fn new(timer: &services::FlowtimeTimer) -> Self {
        let object: Alarm = glib::Object::builder()
            .property("timer", timer.clone())
            .build();

        object.add_sound_for_uri(
            "Baum",
            &format!("resource://io/github/diegoivanme/flowtime/baum.ogg")
        );

        object.add_sound_for_uri(
            "Bleep",
            &format!("resource://io/github/diegoivanme/flowtime/bleep.ogg")
        );

        object.add_sound_for_uri(
            "Tone",
            &format!("resource://io/github/diegoivanme/flowtime/tone.ogg")
        );

        object.add_sound_for_uri(
            "Beep",
            &format!("resource://io/github/diegoivanme/flowtime/beep.ogg")
        );

        object
    }

    pub(crate) fn add_sound_for_uri(&self, name: &str, uri: &str) {
        let mut table = self.imp().table.borrow_mut();
        let sound = Sound {
            name: String::from(name),
            gfile: gio::File::for_uri(uri),
        };
        table.insert(String::from(name), sound);
    }
}
