use gtk::{
    prelude::*,
    glib::{self, subclass::prelude::*},
    gio,
};

mod imp {
    use super::*;
    use std::cell::{Cell, RefCell};
    use once_cell::sync::OnceCell;
    #[derive(Debug, Default, glib::Properties)]
    #[properties(wrapper_type=super::Settings)]
    pub struct Settings {
        #[property(get, set = Self::set_months_saved)]
        pub(crate) months_saved: Cell<u32>,
        #[property(get, set = Self::set_break_percentage)]
        pub(crate) break_percentage: Cell<f32>,

        #[property(get, set)]
        pub(crate) tone: RefCell<String>,
        #[property(get, set)]
        pub(crate) autostart: Cell<bool>,
        #[property(get, set)]
        pub(crate) distraction_free: Cell<bool>,
        #[property(get, set)]
        pub(crate) activate_screensaver: Cell<bool>,

        #[property(get, set)]
        pub(super) gsettings: OnceCell<gio::Settings>,
    }

    impl Settings {
        fn set_months_saved(&self, value: u32) {
            if value <= 0 || value > 6 {
                eprintln!("This value is out of bounds!");
                return;
            }
            self.months_saved.set(value);
        }

        fn set_break_percentage(&self, value: f32) {
            if value < 10f32 || value > 100f32 {
                eprintln!("Break percentage must be in rage [10, 100]");
                return;
            }
            self.break_percentage.set(value);
        }
    }

    #[glib::object_subclass]
    impl ObjectSubclass for Settings {
        const NAME: &'static str = "FlowtimeSettings";
        type Type = super::Settings;
        type ParentType = glib::Object;
    }

    #[glib::derived_properties]
    impl ObjectImpl for Settings {
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
    pub struct Settings(ObjectSubclass<imp::Settings>);
}

impl Settings {
    pub(crate) fn new() -> Self {
        let settings = gio::Settings::new("io.github.diegoivanme.flowtime");
        let object: Settings = glib::Object::builder()
            .build();
        settings.bind("tone", &object, "tone")
            .flags(gio::SettingsBindFlags::DEFAULT)
            .build();
        settings.bind("autostart", &object, "autostart")
            .flags(gio::SettingsBindFlags::DEFAULT)
            .build();
        settings.bind("distraction-free", &object, "distraction-free")
            .flags(gio::SettingsBindFlags::DEFAULT)
            .build();
        settings.bind("months-saved", &object, "months-saved")
            .flags(gio::SettingsBindFlags::DEFAULT)
            .build();
        settings.bind("break-percentage", &object, "break-percentage")
            .flags(gio::SettingsBindFlags::DEFAULT)
            .build();

        object
    }
}
