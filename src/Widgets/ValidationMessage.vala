/*
* Copyright 2018-2020 elementary, Inc. (https://elementary.io)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

private class ValidationMessage : Gtk.Box {
    public Gtk.Label label_widget { get; construct; }
    public string label { get; construct set; }

    public ValidationMessage (string label) {
        Object (label: label);
    }

    construct {
        label_widget = new Gtk.Label (label) {
            halign = Gtk.Align.END,
            justify = Gtk.Justification.RIGHT,
            max_width_chars = 55,
            wrap = true,
            xalign = 1
        };
        label_widget.add_css_class (Granite.STYLE_CLASS_SMALL_LABEL);

        var revealer = new Gtk.Revealer () {
            child = label_widget,
            transition_type = CROSSFADE
        };

        append (revealer);

        bind_property ("label", label_widget, "label");
    }
}
