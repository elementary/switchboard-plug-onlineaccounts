/*
* Copyright 2020-2021 elementary, Inc. (https://elementary.io)
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

public class OnlineAccounts.ICloudDialog : Hdy.Window {
    private Granite.ValidatedEntry password_entry;
    private Granite.ValidatedEntry username_entry;
    private Gtk.Button login_button;

    construct {
        var username_label = new Granite.HeaderLabel (_("Apple ID"));

        username_entry = new Granite.ValidatedEntry () {
            hexpand = true
        };

        var password_label = new Granite.HeaderLabel (_("App-Specific Password"));

        Regex? app_password_regex = null;
        try {
            app_password_regex = new Regex ("^[a-zA-Z]{4}-{1}[a-zA-Z]{4}-{1}[a-zA-Z]{4}-{1}[a-zA-Z]{4}$");
        } catch (Error e) {
            critical (e.message);
        }

        password_entry = new Granite.ValidatedEntry.from_regex (app_password_regex) {
            input_purpose = Gtk.InputPurpose.PASSWORD
        };

        var app_password_help = new Gtk.LinkButton.with_label (
            "https://support.apple.com/en-us/HT204397",
            _("Create an app-specific password")
        );
        app_password_help.get_style_context ().add_class (Granite.STYLE_CLASS_SMALL_LABEL);

        var cancel_button = new Gtk.Button.with_label (_("Cancel"));

        login_button = new Gtk.Button.with_label (_("Log In")) {
            can_default = true,
            sensitive = false
        };
        login_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

        var action_area = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
            layout_style = Gtk.ButtonBoxStyle.END,
            margin_top = 24,
            spacing = 6,
            valign = Gtk.Align.END,
            vexpand = true
        };
        action_area.add (cancel_button);
        action_area.add (login_button);

        var grid = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL,
            row_spacing = 6,
            margin = 12
        };
        grid.add (username_label);
        grid.add (username_entry);
        grid.add (password_label);
        grid.add (password_entry);
        grid.add (app_password_help);
        grid.add (action_area);

        var window_handle = new Hdy.WindowHandle ();
        window_handle.add (grid);

        default_height = 400;
        default_width = 300;
        modal = true;
        type_hint = Gdk.WindowTypeHint.DIALOG;
        window_position = Gtk.WindowPosition.CENTER_ON_PARENT;
        add (window_handle);

        login_button.has_default = true;

        cancel_button.clicked.connect (() => {
            destroy ();
        });

        username_entry.changed.connect (() => {
            username_entry.is_valid = username_entry.text.length >= 1;
            update_login_sensitivity ();
        });

        password_entry.changed.connect (update_login_sensitivity);
    }

    private void update_login_sensitivity () {
        login_button.sensitive = username_entry.is_valid && password_entry.is_valid;
    }
}
