/*
 * Copyright 2023 elementary, Inc. (https://elementary.io)
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
 *
 */

public class OnlineAccounts.SettingsSyncLoginPage : Gtk.Grid {
    public signal void cancel ();

    private Gtk.Label code_label;
    private Gtk.LinkButton link_button;

    construct {
        var header_label = new Granite.HeaderLabel (_("Your Code"));

        code_label = new Gtk.Label ("") {
            selectable = true
        };
        code_label.get_style_context ().add_class ("h3");

        var spinner = new Gtk.Spinner () {
            margin = 12
        };
        spinner.start ();

        link_button = new Gtk.LinkButton.with_label ("", _("Open in browser"));

        var cancel_button = new Gtk.Button.with_label (_("Cancel"));

        var action_area = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
            layout_style = Gtk.ButtonBoxStyle.END,
            margin_top = 24,
            spacing = 6,
            valign = Gtk.Align.END,
            vexpand = true
        };
        action_area.add (cancel_button);

        margin = 12;
        orientation = Gtk.Orientation.VERTICAL;
        row_spacing = 6;
        add (header_label);
        add (code_label);
        add (spinner);
        add (link_button);
        add (action_area);

        cancel_button.clicked.connect (() => {
            cancel ();
        });
    }

    public void update (string user_code, string verification_uri) {
        code_label.label = user_code;
        link_button.uri = verification_uri;
    }
}
