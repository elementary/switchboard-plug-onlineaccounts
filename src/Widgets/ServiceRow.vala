/*
 * Copyright 2013-2018 elementary, Inc. (https://elementary.io)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
 */

public class OnlineAccounts.ServiceRow : Gtk.ListBoxRow {
    public Ag.Provider provider { get; construct; }
    public string description { get; construct; default = ""; }
    public string title_text { get; construct set; default = ""; }

    public ServiceRow (Ag.Provider provider) {
        Object (provider: provider);
    }

    construct {
        var image = new Gtk.Image.from_icon_name (provider.get_icon_name (), Gtk.IconSize.DND);
        image.pixel_size = 32;
        image.use_fallback = true;

        var title_label = new Gtk.Label (title_text);
        title_label.ellipsize = Pango.EllipsizeMode.END;
        title_label.halign = Gtk.Align.START;

        var description_label = new Gtk.Label ("<span font_size='small'>%s</span>".printf (description));
        description_label.ellipsize = Pango.EllipsizeMode.END;
        description_label.halign = Gtk.Align.START;
        description_label.use_markup = true;

        var grid = new Gtk.Grid ();
        grid.margin = 6;
        grid.column_spacing = 6;
        grid.attach (image, 0, 0, 1, 2);
        grid.attach (title_label, 1, 0);
        grid.attach (description_label, 1, 1);

        add (grid);

        title_label.bind_property ("label", this, "title-text");
    }
}
