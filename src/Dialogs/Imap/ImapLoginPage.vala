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

public class OnlineAccounts.ImapLoginPage : Gtk.Box {
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

        real_name_entry = new Granite.ValidatedEntry () {
            is_valid = true,
            input_purpose = NAME,
            text = Environment.get_real_name ()
        };
        real_name_entry.update_property (Gtk.AccessibleProperty.REQUIRED, true, -1);
        real_name = real_name_entry.text;

        var real_name_label = new Granite.HeaderLabel (_("Real Name")) {
            mnemonic_widget = real_name_entry
        };

        email_entry = new Granite.ValidatedEntry.from_regex (email_regex) {
            hexpand = true,
            input_purpose = EMAIL
        };
        email_entry.update_property (Gtk.AccessibleProperty.REQUIRED, true, -1);

        var email_label = new Granite.HeaderLabel (_("Email")) {
            mnemonic_widget = email_entry
        };

        password_entry = new Granite.ValidatedEntry () {
            input_purpose = PASSWORD,
            visibility = false
        };
        password_entry.update_property (Gtk.AccessibleProperty.REQUIRED, true, -1);

        var password_label = new Granite.HeaderLabel (_("Password")) {
            mnemonic_widget = password_entry
        };

        display_name_entry = new Granite.ValidatedEntry () {
            hexpand = true
        };
        display_name_entry.update_property (Gtk.AccessibleProperty.REQUIRED, true, -1);

        var display_name_label = new Granite.HeaderLabel (_("Account Display Name")) {
            mnemonic_widget = display_name_entry,
            secondary_text = _("Pick a name like “Work” or “Personal” for the account.")
        };

        var cancel_button = new Gtk.Button.with_label (_("Cancel")) {
            width_request = 86
        };

        next_button = new Gtk.Button.with_label (_("Next")) {
            width_request = 86,
            sensitive = false
        };
        next_button.add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);

        var action_area = new Gtk.Box (HORIZONTAL, 6) {
            margin_top = 24,
            valign = END,
            halign = END,
            homogeneous = true,
            vexpand = true
        };
        action_area.append (cancel_button);
        action_area.append (next_button);

        margin_start = 12;
        margin_end = 12;
        margin_top = 12;
        margin_bottom = 12;
        orientation = VERTICAL;
        spacing = 6;
        append (real_name_label);
        append (real_name_entry);
        append (email_label);
        append (email_entry);
        append (password_label);
        append (password_entry);
        append (display_name_label);
        append (display_name_entry);
        append (action_area);

        bind_property ("email", email_entry, "text", BIDIRECTIONAL);
        email_entry.changed.connect (() => {
            display_name_entry.text = email_entry.text;
            set_button_sensitivity ();
        });

        bind_property ("real-name", real_name_entry, "text", BIDIRECTIONAL);
        real_name_entry.changed.connect (() => {
            real_name_entry.is_valid = real_name_entry.text.length > 0;
            set_button_sensitivity ();
        });

        bind_property ("display-name", display_name_entry, "text", BIDIRECTIONAL);
        display_name_entry.changed.connect (() => {
            display_name_entry.is_valid = display_name_entry.text.length > 0;
            set_button_sensitivity ();
        });

        bind_property ("password", password_entry, "text", BIDIRECTIONAL);
        password_entry.changed.connect (() => {
            password_entry.is_valid = password_entry.text.length > 0;
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
