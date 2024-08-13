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


mod imp {
    use super::*;

    #[derive(Debug, Default, gtk::CompositeTemplate)]
    #[template(resource = "/io/github/diegoivanme/flowtime/window.ui")]
    pub struct FlowtimeWindow {
    }

    #[glib::object_subclass]
    impl ObjectSubclass for FlowtimeWindow {
        const NAME: &'static str = "FlowtimeWindow";
        type Type = super::FlowtimeWindow;
        type ParentType = adw::ApplicationWindow;

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
        glib::Object::builder()
            .property("application", application)
            .build()
    }
}

