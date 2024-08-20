// statistics.rs
//
// Copyright 2024 Diego Iván M.E <diegoivan.mae@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

use gtk::{
    prelude::*,
    glib::{self, subclass::prelude::*},
};
use std::path::PathBuf;
use crate::models;

mod imp {
    use super::*;
    use std::cell::{Cell, RefCell};

    #[derive(Debug, Default, glib::Properties)]
    #[properties(wrapper_type = super::Statistics)]
    pub struct Statistics {
        pub(super) all_days: RefCell<Vec<models::Day>>,
        #[property(get)]
        pub(crate) productive_day: RefCell<String>
    }

    #[glib::object_subclass]
    impl ObjectSubclass for Statistics {
        const NAME: &'static str = "FlowtimeStatistics";
        type Type = super::Statistics;
        type ParentType = glib::Object;
    }

    #[glib::derived_properties]
    impl ObjectImpl for Statistics {
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
    pub struct Statistics(ObjectSubclass<imp::Statistics>);
}

#[derive(Debug, Clone, Copy)]
enum StatisticsElement {
    Day,
    Worktime,
    Breaktime,
    Statistics,
    None,
}

impl StatisticsElement {
    pub(super) fn from_name(name: &str) -> Option<Self> {
        match name {
            "day" => Some(Self::Day),
            "worktime" => Some(Self::Worktime),
            "breaktime" => Some(Self::Breaktime),
            "statistics" => Some(Self::Statistics),
            _ => None,
        }
    }
}

impl Statistics {
    pub fn new() -> Self {
        glib::Object::builder()
            .build()
    }

    pub fn load_days(&self) {
        use xml::reader::XmlEvent;

        let mut xml_file = glib::user_data_dir();
        xml_file.push("statistics.xml");

        let file = std::fs::File::open(xml_file).unwrap();
        let file = std::io::BufReader::new(file);

        let reader = xml::EventReader::new(file);

        let mut worktime = 0u32;
        let mut breaktime = 0u32;
        let mut date: Option<glib::DateTime> = None;

        let mut element_stack = Vec::new();

        for event in reader {
            println!("{event:?}");
            match event {
                Ok(XmlEvent::StartDocument {..}) => println!("Started to parse document"),
                Ok(XmlEvent::StartElement { name, attributes, ..}) => {
                    match StatisticsElement::from_name(&name.local_name) {
                        Some(StatisticsElement::Day) => {
                            element_stack.push(StatisticsElement::Day);
                            println!("Starting to parse a day");
                            let day_date = attributes
                                .into_iter()
                                .find(|a| a.name.local_name == "date");
                            match day_date {
                                Some(day_date) => {
                                    date = glib::DateTime::from_iso8601(&day_date.value, None).ok()
                                },
                                None => {
                                    println!("Could not find attribute date");
                                    continue;
                                }
                            }
                        }
                        Some(node) => element_stack.push(node),
                        None => {
                            eprintln!("Unrecognized element {name}");
                            continue;
                        }
                    }
                },
                Ok(XmlEvent::Characters(content)) => {
                    let current_element = element_stack.last().unwrap_or(&StatisticsElement::None);
                    match current_element {
                        StatisticsElement::Worktime => match content.parse() {
                            Ok(count) => worktime = count,
                            Err(e) => {
                                eprintln!("Failed to parse count: {e}");
                                continue;
                            }
                        },
                        StatisticsElement::Breaktime => match content.parse() {
                            Ok(count) => breaktime = count,
                            Err(e) => {
                                eprintln!("Failed to parse count: {e}");
                                continue;
                            }
                        },
                        _ => {
                            eprintln!("Received content in {current_element:?}, but it is not supported");
                        }
                    }
                },
                Ok(XmlEvent::EndElement { .. }) => {
                    let current_element = element_stack.pop().unwrap_or(StatisticsElement::None);
                    match current_element {
                        StatisticsElement::Day => {
                            println!("A day has been parsed");
                            match date.as_ref() {
                                Some(date) => {
                                    let day = models::Day::new(date, worktime, breaktime);
                                    self.imp().all_days.borrow_mut().push(day);
                                },
                                None => {
                                    eprintln!("Expected date element to be Some at this point");
                                    continue;
                                }
                            };

                            worktime = 0;
                            breaktime = 0;
                            date = None;
                        },
                        _ => {},
                    }
                },
                Ok(XmlEvent::EndDocument) => {
                    println!("End document");
                    assert! (element_stack.is_empty());
                }
                Err(e) => eprintln!("Failed to parse element: {e}"),
                _ => {},
            }
        }

        println!("{list:?}", list = self.imp().all_days.borrow());
    }
}
