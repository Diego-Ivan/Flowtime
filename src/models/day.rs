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
        pub(crate) worktime: Cell<u64>,
        #[property(get, set)]
        pub(crate) breaktime: Cell<u64>,
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
    pub(crate) fn new(date: &glib::DateTime, worktime: u64, breaktime: u64) -> Self {
        glib::Object::builder()
            .property("date", date.clone())
            .property("worktime", worktime)
            .property("breaktime", breaktime)
            .build()
    }

    pub(crate) fn write_to_xml<R>(&self, writer: &mut xml::EventWriter<R>) -> anyhow::Result<()>
        where R: std::io::Write,
    {
        use xml::writer::XmlEvent;
        use xml::name::Name as XmlName;
        use xml::attribute::Attribute;
        use std::borrow::Cow;

        let worktime = self.worktime().to_string();
        let breaktime = self.breaktime().to_string();
        let date = self.date().format_iso8601().unwrap();
        let attributes = [
            Attribute {
                name: XmlName {
                    local_name: "date",
                    namespace: None,
                    prefix: None,
                },
                value: &date,
            }
        ];

        let events = [
            XmlEvent::StartElement {
                name: XmlName {
                    local_name: "day",
                    namespace: None,
                    prefix: None,
                },
                attributes: Cow::Borrowed(&attributes),
                namespace: Cow::Owned(xml::namespace::Namespace::empty()),
            },
            XmlEvent::StartElement {
                name: XmlName {
                    local_name: "worktime",
                    namespace: None,
                    prefix: None,
                },
                attributes: Cow::Owned(Vec::new()),
                namespace: Cow::Owned(xml::namespace::Namespace::empty()),
            },
            XmlEvent::Characters(&worktime),
            XmlEvent::EndElement {
                name: Some(XmlName {
                    local_name: "worktime",
                    namespace: None,
                    prefix: None,
                })
            },
            XmlEvent::StartElement {
                name: XmlName {
                    local_name: "breaktime",
                    namespace: None,
                    prefix: None,
                },
                attributes: Cow::Owned(Vec::new()),
                namespace: Cow::Owned(xml::namespace::Namespace::empty()),
            },
            XmlEvent::Characters(&breaktime),
            XmlEvent::EndElement {
                name: Some(XmlName {
                    local_name: "breaktime",
                    namespace: None,
                    prefix: None,
                })
            },
            XmlEvent::EndElement {
                name: Some(XmlName {
                    local_name: "day",
                    namespace: None,
                    prefix: None,
                })
            },
        ];

        for event in events {
            writer.write(event)?;
        }

        Ok(())
    }
}
