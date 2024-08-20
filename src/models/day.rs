use gtk::{
    prelude::*,
    glib::{self, subclass::prelude::*},
};

mod imp {
    use super::*;
    use once_cell::sync::OnceCell;
    use std::cell::Cell;
    #[derive(Debug, Default, glib::Properties)]
    #[properties(wrapper_type = super::Day)]
    pub struct Day {
        #[property(get, set)]
        pub(crate) date: OnceCell<glib::DateTime>,
        #[property(get, set)]
        pub(crate) worktime: Cell<u32>,
        #[property(get, set)]
        pub(crate) breaktime: Cell<u32>,
        #[property(get = Self::get_day_week)]
        pub(crate) day_of_week: String,
    }

    impl Day {
        fn get_day_week(&self) -> String {
            self.date.get().unwrap().format("%A").unwrap().to_string()
        }
    }

    #[glib::object_subclass]
    impl ObjectSubclass for Day {
        const NAME: &'static str = "FlowtimeDay";
        type Type = super::Day;
        type ParentType = glib::Object;
    }

    #[glib::derived_properties]
    impl ObjectImpl for Day {
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
    pub struct Day(ObjectSubclass<imp::Day>);
}

impl Day {
    pub(crate) fn new(date: &glib::DateTime, worktime: u32, breaktime: u32) -> Self {
        glib::Object::builder()
            .property("date", date.clone())
            .property("worktime", worktime)
            .property("breaktime", breaktime)
            .build()
    }
}
