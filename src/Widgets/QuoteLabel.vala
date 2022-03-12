/* QuoteLabel.vala
 *
 * Copyright 2021 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    public class QuoteLabel : Adw.Bin {
        public string[] break_quotes = {
            _("Good Job!"),
            _("Time to take a rest"),
            _("In the meantime, drink some water"),
            _("It's coffee time"),
            _("You deserve a break"),
            _("Keep a healthy mind"),
            _("Just breathe"),
            _("Relax, refresh and recharge"),
            _("Celebrate your small wins"),
            _("Impossible is just an opinion"),
            _("Way to go!"),
            _("Begin anywhere"),
            _("The possibilities are never ending")
        };

        construct {
            var random_number = Random.int_range (0, break_quotes.length);
            var quote = break_quotes[random_number];

            var label = new Gtk.Label (quote);
            label.add_css_class ("dim-label");
            set_child (label);
        }

        public void randomize () {
            var random_number = Random.int_range (0, break_quotes.length);
            var quote = break_quotes[random_number];

            var label = new Gtk.Label (quote);
            label.add_css_class ("dim-label");
            set_child (label);
        }
    }
}
