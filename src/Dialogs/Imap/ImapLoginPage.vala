/*
* Copyright 2021 elementary, Inc. (https://elementary.io)
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

public class OnlineAccounts.ImapLoginPage : Gtk.Grid {
    public signal void cancel ();

    public string display_name { get; set; }
    public string email { get; set; }
    public string password { get; set; }
    public string real_name { get; set; }

    private Granite.ValidatedEntry display_name_entry;
    private Granite.ValidatedEntry email_entry;
    private Granite.ValidatedEntry password_entry;
    private Granite.ValidatedEntry real_name_entry;

    public Gtk.Button next_button { get; set; }

    construct {
        Regex? email_regex = null;
        try {
            email_regex = new Regex ("""^[^\s]+@[^\s]+\.[^\s]+$""");
        } catch (Error e) {
            critical (e.message);
        }

        var real_name_label = new Granite.HeaderLabel (_("Real Name"));

        real_name_entry = new Granite.ValidatedEntry () {
            is_valid = true,
            text = Environment.get_real_name ()
        };
        real_name = real_name_entry.text;

        var email_label = new Granite.HeaderLabel (_("Email"));

        email_entry = new Granite.ValidatedEntry.from_regex (email_regex) {
            hexpand = true
        };

        var password_label = new Granite.HeaderLabel (_("Password"));

        password_entry = new Granite.ValidatedEntry () {
            input_purpose = Gtk.InputPurpose.PASSWORD,
            visibility = false
        };

        var display_name_label = new Granite.HeaderLabel (_("Account Display Name"));

        display_name_entry = new Granite.ValidatedEntry () {
            hexpand = true
        };

        var display_name_hint_label = new Gtk.Label (_("Pick a name like “Work” or “Personal” for the account.")) {
            hexpand = true,
            wrap = true,
            xalign = 0
        };
        display_name_hint_label.get_style_context ().add_class (Granite.STYLE_CLASS_SMALL_LABEL);

        var cancel_button = new Gtk.Button.with_label (_("Cancel"));

        next_button = new Gtk.Button.with_label (_("Next")) {
            can_default = true,
            sensitive = false
        };
        next_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

        var action_area = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
            layout_style = Gtk.ButtonBoxStyle.END,
            margin_top = 24,
            spacing = 6,
            valign = Gtk.Align.END,
            vexpand = true
        };
        action_area.add (cancel_button);
        action_area.add (next_button);

        margin = 12;
        orientation = Gtk.Orientation.VERTICAL;
        row_spacing = 6;
        add (real_name_label);
        add (real_name_entry);
        add (email_label);
        add (email_entry);
        add (password_label);
        add (password_entry);
        add (display_name_label);
        add (display_name_entry);
        add (display_name_hint_label);
        add (action_area);

        bind_property ("email", email_entry, "text", GLib.BindingFlags.DEFAULT);
        email_entry.changed.connect (() => {
            display_name_entry.text = email_entry.text;
            email = email_entry.text;
            set_button_sensitivity ();
        });

        bind_property ("real_name", real_name_entry, "text", GLib.BindingFlags.DEFAULT);
        real_name_entry.changed.connect (() => {
            real_name_entry.is_valid = real_name_entry.text.length > 0;
            real_name = real_name_entry.text;
            set_button_sensitivity ();
        });

        bind_property ("display_name", display_name_entry, "text", GLib.BindingFlags.DEFAULT);
        display_name_entry.changed.connect (() => {
            display_name_entry.is_valid = display_name_entry.text.length > 0;
            display_name = display_name_entry.text;
            set_button_sensitivity ();
        });

        bind_property ("password", password_entry, "text", GLib.BindingFlags.DEFAULT);
        password_entry.changed.connect (() => {
            password_entry.is_valid = password_entry.text.length > 0;
            password = password_entry.text;
            set_button_sensitivity ();
        });

        cancel_button.clicked.connect (() => {
            cancel ();
        });
    }

    private void set_button_sensitivity () {
        next_button.sensitive = email_entry.is_valid && real_name_entry.is_valid && display_name_entry.is_valid && password_entry.is_valid;
    }
}
