/* Day.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Flowtime.Models.Day : GLib.Object {
    public Xml.Node* node { get; private set; }
    private Xml.Node* worktime_node;
    private Xml.Node* breaktime_node;

    private DateTime _date;
    public DateTime date {
        get {
            return _date;
        }
        set {
            _date = value;
            node->set_prop ("date", value.format_iso8601 ());
        }
    }

    private int _worktime = 0;
    internal int worktime {
        get {
            return _worktime;
        }
        set {
            _worktime = value;
            worktime_node->set_content (value.to_string ());
        }
    }

    private int _breaktime = 0;
    internal int breaktime {
        get {
            return _breaktime;
        }
        set {
            _breaktime = value;
            breaktime_node->set_content (value.to_string ());
        }
    }

    public string day_of_week {
        owned get {
            return date.format ("%A");
        }
    }

    public Day () {
        node = new Xml.Node (null, "day");
        date = new DateTime.now_local ();

        worktime_node = node->new_text_child (null, "worktime", "");
        breaktime_node = node->new_text_child (null, "breaktime", "");
    }

    public Day.from_xml (Xml.Node* n) {
        node = n;
        date = new DateTime.from_iso8601 (n->get_prop ("date"), null);

        for (Xml.Node* i = node->children; i != null; i = i->next) {
            if (i->type == ELEMENT_NODE) {
                switch (i->name) {
                    case "worktime":
                        worktime_node = XmlUtils.get_content_node (i, "worktime");
                        _worktime = int.parse(worktime_node->get_content ());
                        break;

                    case "breaktime":
                        breaktime_node = XmlUtils.get_content_node (i, "breaktime");
                        _breaktime = int.parse (breaktime_node->get_content ());
                        break;
                }
            }
        }
    }

    public void unlink () {
        node->unlink ();
    }
}
