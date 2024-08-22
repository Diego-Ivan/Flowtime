/* window.rs
 *
 * Copyright 2024 Diego Iván M.E <diegoivan.mae@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

//use crate::widgets;
use adw::prelude::*;
use adw::subclass::prelude::*;
use gtk::{gio, glib};
use crate::services;


mod imp {
    use super::*;

    use once_cell::sync::OnceCell;

    #[derive(Debug, gtk::CompositeTemplate)]
    #[template(resource = "/io/github/diegoivanme/flowtime/window.ui")]
    pub struct FlowtimeWindow {
        pub(super) timer: services::FlowtimeTimer,

        #[template_child]
        pub(super) timer_page: TemplateChild<crate::widgets::TimerPage>,

        pub(super) alarm: services::Alarm,
        pub(super) statistics: services::Statistics,
    }

    #[glib::object_subclass]
    impl ObjectSubclass for FlowtimeWindow {
        const NAME: &'static str = "FlowtimeWindow";
        type Type = super::FlowtimeWindow;
        type ParentType = adw::ApplicationWindow;

        fn new() -> Self {
            let statistics = services::Statistics::new();
            let timer = services::FlowtimeTimer::new(&statistics);
            Self {
                alarm: services::Alarm::new(&timer),
                timer_page: TemplateChild::default(),
                timer,
                statistics
            }
        }

        fn class_init(klass: &mut Self::Class) {
            klass.bind_template();
        }

        fn instance_init(obj: &glib::subclass::InitializingObject<Self>) {
            obj.init_template();
        }
    }

    impl ObjectImpl for FlowtimeWindow {}
    impl WidgetImpl for FlowtimeWindow {}
    impl WindowImpl for FlowtimeWindow {}
    impl ApplicationWindowImpl for FlowtimeWindow {}
    impl AdwApplicationWindowImpl for FlowtimeWindow {}
}

glib::wrapper! {
    pub struct FlowtimeWindow(ObjectSubclass<imp::FlowtimeWindow>)
        @extends gtk::Widget, gtk::Window, gtk::ApplicationWindow, adw::ApplicationWindow,        @implements gio::ActionGroup, gio::ActionMap;
}

impl FlowtimeWindow {
    pub fn new<P: glib::IsA<gtk::Application>>(application: &P) -> Self {
        let win: FlowtimeWindow = glib::Object::builder()
            .property("application", application)
            .build();
        let imp = win.imp();
        imp.timer_page.set_timer(&imp.timer);
        win
    }
}


