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

public class OnlineAccounts.ImapDialog : Hdy.Window {
    construct {
        var imap_username_label = new Granite.HeaderLabel ("Email Address");

        var imap_username_entry = new Granite.ValidatedEntry () {
            hexpand = true
        };

        var imap_password_label = new Granite.HeaderLabel ("Password");

        var imap_password_entry = new Gtk.Entry () {
            input_purpose = Gtk.InputPurpose.PASSWORD,
            visibility = false
        };

        var imap_server_label = new Granite.HeaderLabel ("Server URL");

        var imap_server_entry = new Gtk.Entry () {
            hexpand = true
        };

        var imap_port_spin = new Gtk.SpinButton.with_range (1, uint16.MAX, 10) {
            value = 993
        };

        var imap_settings_grid = new Gtk.Grid ();
        imap_settings_grid.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);
        imap_settings_grid.add (imap_server_entry);
        imap_settings_grid.add (imap_port_spin);

        var imap_encryption_label = new Gtk.Label (_("Encryption:"));

        var imap_encryption_combobox = new Gtk.ComboBoxText () {
            hexpand = true
        };
        imap_encryption_combobox.append ("None", _("None"));
        imap_encryption_combobox.append ("SSL/TLS", "SSL/TLS");
        imap_encryption_combobox.append ("STARTTLS", "STARTTLS");
        imap_encryption_combobox.active = 1;

        var imap_encryption_grid = new Gtk.Grid () {
            column_spacing = 6
        };
        imap_encryption_grid.add (imap_encryption_label);
        imap_encryption_grid.add (imap_encryption_combobox);

        var smtp_label = new Granite.HeaderLabel ("SMTP");

        var smtp_username_entry = new Gtk.Entry () {
            hexpand = true,
            placeholder_text = _("Email")
        };

        var smtp_password_entry = new Gtk.Entry () {
            input_purpose = Gtk.InputPurpose.PASSWORD,
            placeholder_text = _("Password"),
            visibility = false
        };

        var smtp_credentials = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL
        };
        smtp_credentials.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);
        smtp_credentials.add (smtp_username_entry);
        smtp_credentials.add (smtp_password_entry);

        var smtp_revealer = new Gtk.Revealer ();
        smtp_revealer.add (smtp_credentials);

        var smtp_server_entry = new Gtk.Entry () {
            placeholder_text = _("Server")
        };

        var smtp_port_spin = new Gtk.SpinButton.with_range (1, uint16.MAX, 10) {
            value = 587
        };

        var smtp_settings_grid = new Gtk.Grid ();
        smtp_settings_grid.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);
        smtp_settings_grid.add (smtp_server_entry);
        smtp_settings_grid.add (smtp_port_spin);

        var use_imap_credentials = new Gtk.CheckButton.with_label (_("Use IMAP Credentials")) {
            active = true
        };

        var no_credentials = new Gtk.CheckButton.with_label (_("No authentication required"));

        var smtp_encryption_label = new Gtk.Label (_("Encryption:"));

        var smtp_encryption_combobox = new Gtk.ComboBoxText () {
            hexpand = true
        };
        smtp_encryption_combobox.append ("None", _("None"));
        smtp_encryption_combobox.append ("SSL/TLS", "SSL/TLS");
        smtp_encryption_combobox.append ("STARTTLS", "STARTTLS");
        smtp_encryption_combobox.active = 2;

        var smtp_encryption_grid = new Gtk.Grid () {
            column_spacing = 6
        };
        smtp_encryption_grid.add (smtp_encryption_label);
        smtp_encryption_grid.add (smtp_encryption_combobox);

        var entry_grid = new Gtk.Grid () {
            expand = true,
            orientation = Gtk.Orientation.VERTICAL,
            row_spacing = 6
        };
        entry_grid.add (imap_username_label);
        entry_grid.add (imap_username_entry);
        entry_grid.add (imap_password_label);
        entry_grid.add (imap_password_entry);
        entry_grid.add (imap_server_label);
        entry_grid.add (imap_settings_grid);
        entry_grid.add (imap_encryption_grid);

        entry_grid.add (smtp_label);
        entry_grid.add (no_credentials);
        entry_grid.add (use_imap_credentials);
        entry_grid.add (smtp_revealer);

        entry_grid.add (smtp_settings_grid);
        entry_grid.add (smtp_encryption_grid);

        var cancel_button = new Gtk.Button.with_label (_("Cancel"));

        var save_button = new Gtk.Button.with_label (_("Log In")) {
            can_default = true,
            has_default = true,
            sensitive = false
        };
        save_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

        var action_area = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
            layout_style = Gtk.ButtonBoxStyle.END,
            spacing = 6,
            valign = Gtk.Align.END,
            vexpand = true
        };
        action_area.add (cancel_button);
        action_area.add (save_button);

        var main_grid = new Gtk.Grid () {
            margin = 12,
            orientation = Gtk.Orientation.VERTICAL,
            row_spacing = 24
        };
        main_grid.add (entry_grid);
        main_grid.add (action_area);

        var window_handle = new Hdy.WindowHandle ();
        window_handle.add (main_grid);

        default_height = 400;
        default_width = 300;
        window_position = Gtk.WindowPosition.CENTER_ON_PARENT;
        modal = true;
        add (window_handle);

        cancel_button.clicked.connect (() => {
            destroy ();
        });

        no_credentials.notify["active"].connect (() => {
            smtp_revealer.reveal_child = !no_credentials.active && !use_imap_credentials.active;
            use_imap_credentials.sensitive = ! no_credentials.active;
        });

        use_imap_credentials.bind_property ("active", smtp_revealer, "reveal-child", GLib.BindingFlags.INVERT_BOOLEAN);

        // Be smart and propagate the domain to the server name.
        imap_username_entry.changed.connect (() => {
            if ("@" in imap_username_entry.text) {
                imap_username_entry.is_valid = true;

                var domain = imap_username_entry.text.split ("@", 2)[1].strip ().replace ("@", "");
                if (domain.length > 0) {
                    imap_server_entry.text = "imap." + domain;

                    smtp_server_entry.text = "smtp." + domain;
                }
            } else {
                imap_username_entry.is_valid = false;
            }
        });

        imap_encryption_combobox.changed.connect (() => {
            switch (imap_encryption_combobox.active) {
                case 1:
                    imap_port_spin.value = 993;
                    break;
                case 2:
                    imap_port_spin.value = 143;
                    break;
                default:
                    imap_port_spin.value = 143;
                    break;
            }
        });

        smtp_encryption_combobox.changed.connect (() => {
            switch (smtp_encryption_combobox.active) {
                case 1:
                    smtp_port_spin.value = 465;
                    break;
                case 2:
                    smtp_port_spin.value = 587;
                    break;
                default:
                    smtp_port_spin.value = 25;
                    break;
            }
        });
    }
}
