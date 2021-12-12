/* QuoteLabel.vala
 *
 * Copyright 2021 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime {
    public class QuoteLabel : Adw.Bin {
        public string[] BREAK_QUOTES = {
            _("Good Job!"),
            _("Time to take a rest"),
            _("In the meantime, drink some water"),
            _("It's coffee time"),
            _("You deserve a break"),
            _("Keep a healthy mind"),
            _("Just breathe"),
            _("Relax, refresh and recharge")
        };

        construct {
            var random_number = Random.int_range (0, BREAK_QUOTES.length);
            var quote = BREAK_QUOTES[random_number];

            var label = new Gtk.Label (quote);
            label.add_css_class ("dim-label");
            set_child (label);
        }
    }
}
