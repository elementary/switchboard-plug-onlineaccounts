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

public class OnlineAccounts.AccountMenuItem : Gtk.Button {
    public string icon_name { get; construct; }
    public string primary_label { get; construct; }
    public string secondary_label { get; construct; }
    public string? badge_icon_name { get; construct; }

    public AccountMenuItem (string icon_name, string primary_label, string secondary_label, string? badge_icon_name = null) {
        Object (
            icon_name: icon_name,
            primary_label: primary_label,
            secondary_label: secondary_label,
            badge_icon_name: badge_icon_name
        );
    }

    class construct {
        set_css_name (Gtk.STYLE_CLASS_MENUITEM);
    }

    construct {
        var label = new Gtk.Label (primary_label) {
            halign = Gtk.Align.START
        };
        label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

        var description = new Gtk.Label (secondary_label) {
            halign = Gtk.Align.START
        };
        description.get_style_context ().add_class (Granite.STYLE_CLASS_SMALL_LABEL);

        var grid = new Gtk.Grid () {
            column_spacing = 6
        };

        var image = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.DND);

        if (badge_icon_name == null) {
            grid.attach (image, 0, 0, 1, 2);
        } else {
            var badge = new Gtk.Image.from_icon_name (badge_icon_name, Gtk.IconSize.SMALL_TOOLBAR) {
                halign = Gtk.Align.END,
                valign = Gtk.Align.END,
                pixel_size = 16
            };

            var overlay = new Gtk.Overlay () {
                valign = Gtk.Align.START
            };
            overlay.add (image);
            overlay.add_overlay (badge);

            grid.attach (overlay, 0, 0, 1, 2);
        }

        grid.attach (label, 1, 0);
        grid.attach (description, 1, 1);

        add (grid);
    }
}
