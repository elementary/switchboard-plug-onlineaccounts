/*
 * Copyright 2013-2019 elementary, Inc. (https://elementary.io)
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

public class OnlineAccounts.iCloudDialog : OnlineAccounts.Dialog {
    public iCloudDialog (GLib.HashTable<string, GLib.Variant> params) {
        base (params);

        var info_label = new Gtk.Label (_("Loading…"));

        var spinner = new Gtk.Spinner ();
        spinner.start ();

        var back_button = new Gtk.Button.with_label (_("Back"));
        back_button.halign = Gtk.Align.START;
        back_button.margin = 6;
        back_button.get_style_context ().add_class (Granite.STYLE_CLASS_BACK_BUTTON);

        var container_grid = new Gtk.Grid ();
        container_grid.column_spacing = 6;
        container_grid.valign = Gtk.Align.CENTER;
        container_grid.add (info_label);
        container_grid.add (spinner);

        var header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        header_box.hexpand = true;
        header_box.add (back_button);
        header_box.set_center_widget (container_grid);


        attach (header_box, 0, 0);
        attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 0, 1);
        show_all ();

        back_button.clicked.connect (() => {
            error_code = OnlineAccounts.SignonUIError.CANCELED;
            finished ();
        });
    }

    public override bool refresh_captcha (string uri) {
        return true;
    }
}
