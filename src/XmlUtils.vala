/* XmlUtils.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Flowtime.XmlUtils {
    public Xml.Node* get_content_node (Xml.Node* n, string node_name) {
        assert (n->name == node_name);

        for (Xml.Node* i = n->children; i != null; i = i->next) {
            if (i->type == TEXT_NODE) {
                return i;
            }
        }
        return n;
    }
}
