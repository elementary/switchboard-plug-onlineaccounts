// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2013-2016 elementary LLC. (https://elementary.io)
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
 *
 * Authored by: Corentin Noël <corentin@elementary.io>
 */

public class OnlineAccounts.MailDialog : OnlineAccounts.Dialog {
    Gtk.Button save_button;

    Gtk.Entry imap_username_entry;
    Gtk.Entry imap_password_entry;
    Gtk.Entry imap_server_entry;
    Gtk.SpinButton imap_port_spin;
    Gtk.ComboBoxText imap_encryption_combobox;

    Gtk.Entry smtp_username_entry;
    Gtk.Entry smtp_password_entry;
    Gtk.CheckButton no_credentials;
    Gtk.Entry smtp_server_entry;
    Gtk.SpinButton smtp_port_spin;
    Gtk.ComboBoxText smtp_encryption_combobox;
    Gtk.CheckButton use_imap_credentials;

    bool imap_modified_by_user = false;
    bool imap_port_modified_by_user = false;
    bool smtp_modified_by_user = false;
    bool smtp_port_modified_by_user = false;

    public MailDialog (GLib.HashTable<string, GLib.Variant> params) {
        base (params);

        var info_label = new Gtk.Label (_("Please enter your credentials…"));

        var back_button = new Gtk.Button.with_label (_("Back"));
        back_button.halign = Gtk.Align.START;
        back_button.margin = 6;
        back_button.get_style_context ().add_class (Granite.STYLE_CLASS_BACK_BUTTON);

        var header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        header_box.hexpand = true;
        header_box.add (back_button);
        header_box.set_center_widget (info_label);

        var main_grid = new Gtk.Grid ();
        main_grid.margin = 12;
        main_grid.halign = Gtk.Align.CENTER;
        main_grid.valign = Gtk.Align.CENTER;
        main_grid.column_spacing = 12;
        main_grid.row_spacing = 6;
        main_grid.orientation = Gtk.Orientation.VERTICAL;
        main_grid.get_style_context ().add_class ("login");

        var provider_label = new Gtk.Label (_("Mail Account"));
        provider_label.get_style_context ().add_class ("h1");
        provider_label.margin_bottom = 24;

        var imap_label = new Gtk.Label ("IMAP");
        imap_label.get_style_context ().add_class ("h4");
        imap_label.halign = Gtk.Align.START;

        imap_username_entry = new Gtk.Entry ();
        imap_username_entry.placeholder_text = _("Email");
        imap_username_entry.hexpand = true;

        imap_password_entry = new Gtk.Entry ();
        imap_password_entry.placeholder_text = _("Password");
        imap_password_entry.visibility = false;
        imap_password_entry.input_purpose = Gtk.InputPurpose.PASSWORD;

        var imap_credentials = new Gtk.Grid ();
        imap_credentials.orientation = Gtk.Orientation.VERTICAL;
        imap_credentials.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);
        imap_credentials.add (imap_username_entry);
        imap_credentials.add (imap_password_entry);

        imap_server_entry = new Gtk.Entry ();
        imap_server_entry.placeholder_text = _("Server");

        imap_port_spin = new Gtk.SpinButton.with_range (1, uint16.MAX, 10);
        imap_port_spin.value = 993;

        var imap_settings_grid = new Gtk.Grid ();
        imap_settings_grid.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);
        imap_settings_grid.add (imap_server_entry);
        imap_settings_grid.add (imap_port_spin);

        var imap_encryption_label = new Gtk.Label (_("Encryption:"));

        imap_encryption_combobox = new Gtk.ComboBoxText ();
        imap_encryption_combobox.hexpand = true;
        imap_encryption_combobox.append ("None", _("None"));
        imap_encryption_combobox.append ("SSL/TLS", "SSL/TLS");
        imap_encryption_combobox.append ("STARTTLS", "STARTTLS");
        imap_encryption_combobox.active = 1;

        var imap_encryption_grid = new Gtk.Grid ();
        imap_encryption_grid.column_spacing = 6;
        imap_encryption_grid.add (imap_encryption_label);
        imap_encryption_grid.add (imap_encryption_combobox);

        var smtp_label = new Gtk.Label ("SMTP");
        smtp_label.get_style_context ().add_class ("h4");
        smtp_label.halign = Gtk.Align.START;

        smtp_username_entry = new Gtk.Entry ();
        smtp_username_entry.placeholder_text = _("Email");
        smtp_username_entry.hexpand = true;

        smtp_password_entry = new Gtk.Entry ();
        smtp_password_entry.placeholder_text = _("Password");
        smtp_password_entry.visibility = false;
        smtp_password_entry.input_purpose = Gtk.InputPurpose.PASSWORD;

        var smtp_credentials = new Gtk.Grid ();
        smtp_credentials.orientation = Gtk.Orientation.VERTICAL;
        smtp_credentials.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);
        smtp_credentials.add (smtp_username_entry);
        smtp_credentials.add (smtp_password_entry);

        smtp_server_entry = new Gtk.Entry ();
        smtp_server_entry.placeholder_text = _("Server");

        smtp_port_spin = new Gtk.SpinButton.with_range (1, uint16.MAX, 10);
        smtp_port_spin.value = 587;

        var smtp_settings_grid = new Gtk.Grid ();
        smtp_settings_grid.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);
        smtp_settings_grid.add (smtp_server_entry);
        smtp_settings_grid.add (smtp_port_spin);

        use_imap_credentials = new Gtk.CheckButton.with_label (_("Use IMAP Credentials"));
        use_imap_credentials.bind_property ("active", smtp_credentials, "sensitive", GLib.BindingFlags.INVERT_BOOLEAN);
        use_imap_credentials.active = true;

        no_credentials = new Gtk.CheckButton.with_label (_("No authentication required"));

        var smtp_encryption_label = new Gtk.Label (_("Encryption:"));

        smtp_encryption_combobox = new Gtk.ComboBoxText ();
        smtp_encryption_combobox.hexpand = true;
        smtp_encryption_combobox.append ("None", _("None"));
        smtp_encryption_combobox.append ("SSL/TLS", "SSL/TLS");
        smtp_encryption_combobox.append ("STARTTLS", "STARTTLS");
        smtp_encryption_combobox.active = 2;

        var smtp_encryption_grid = new Gtk.Grid ();
        smtp_encryption_grid.column_spacing = 6;
        smtp_encryption_grid.add (smtp_encryption_label);
        smtp_encryption_grid.add (smtp_encryption_combobox);

        save_button = new Gtk.Button.with_label (_("Log In"));
        save_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
        save_button.hexpand = true;
        save_button.margin_top = 18;
        save_button.sensitive = false;

        var entry_grid = new Gtk.Grid ();
        entry_grid.expand = true;
        entry_grid.row_spacing = 6;
        entry_grid.orientation = Gtk.Orientation.VERTICAL;
        entry_grid.add (imap_label);
        entry_grid.add (imap_credentials);
        entry_grid.add (imap_settings_grid);
        entry_grid.add (imap_encryption_grid);

        entry_grid.add (smtp_label);
        entry_grid.add (no_credentials);
        entry_grid.add (smtp_credentials);
        entry_grid.add (use_imap_credentials);
        entry_grid.add (smtp_settings_grid);
        entry_grid.add (smtp_encryption_grid);

        main_grid.add (provider_label);
        main_grid.add (entry_grid);
        main_grid.add (save_button);

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.add (main_grid);

        attach (header_box, 0, 0);
        attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 0, 1);
        attach (scrolled, 0, 2);

        set_parameters (params);

        no_credentials.notify["active"].connect (() => {
            smtp_credentials.sensitive = !no_credentials.active && !use_imap_credentials.active;
            use_imap_credentials.sensitive = ! no_credentials.active;
            reset_ok ();
        });

        use_imap_credentials.notify["active"].connect (() => reset_ok ());

        // Be smart and propagate the domain to the server name.
        imap_username_entry.notify["text"].connect (() => {
            if ("@" in imap_username_entry.text) {
                var domain = imap_username_entry.text.split ("@", 2)[1].strip ().replace ("@", "");
                if (domain.length > 0) {
                    if (!imap_modified_by_user) {
                        imap_server_entry.text = "imap."+ domain;
                    }

                    if (!smtp_modified_by_user) {
                        smtp_server_entry.text = "smtp."+ domain;
                    }
                }
            }

            reset_ok ();
        });

        imap_password_entry.notify["text"].connect (() => reset_ok ());

        imap_server_entry.notify["text"].connect (() => {
            if (imap_server_entry.has_focus) {
                imap_modified_by_user = true;
            }

            reset_ok ();
        });

        imap_port_spin.notify["text"].connect (() => {
            if (imap_port_spin.has_focus) {
                imap_port_modified_by_user = true;
            }

            reset_ok ();
        });

        imap_encryption_combobox.changed.connect (() => {
            if (!imap_port_modified_by_user) {
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
            }
        });

        smtp_username_entry.notify["text"].connect (() => reset_ok ());

        smtp_password_entry.notify["text"].connect (() => reset_ok ());

        smtp_server_entry.notify["text"].connect (() => {
            if (smtp_server_entry.has_focus) {
                smtp_modified_by_user = true;
            }

            reset_ok ();
        });

        smtp_port_spin.notify["text"].connect (() => {
            if (smtp_port_spin.has_focus) {
                smtp_port_modified_by_user = true;
            }

            reset_ok ();
        });

        smtp_encryption_combobox.changed.connect (() => {
            if (!smtp_port_modified_by_user) {
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
            }
        });

        save_button.clicked.connect (() => finished ());
        back_button.clicked.connect (() => {
            error_code = OnlineAccounts.SignonUIError.CANCELED;
            finished ();
        });

        show_all ();
    }

    public override bool refresh_captcha (string uri) {
        return true;
    }

    public override bool set_parameters (HashTable<string, Variant> params) {
        if (base.set_parameters (params) == false) {
            return false;
        }

        if (validate_params (params) == false) {
            return false;
        }

        weak Variant temp_string = params.get ("ImapUser");
        if (temp_string != null) {
            imap_username_entry.text = temp_string.get_string ();
        }

        temp_string = params.get ("ImapPassword");
        if (temp_string != null) {
            imap_password_entry.text = temp_string.get_string ();
        }

        temp_string = params.get ("SmtpUser");
        if (temp_string != null) {
            smtp_username_entry.text = temp_string.get_string ();
        }

        temp_string = params.get ("SmtpPassword");
        if (temp_string != null) {
            smtp_password_entry.text = temp_string.get_string ();
        }

        if (smtp_username_entry.text.strip () != "") {
            use_imap_credentials.active = ((smtp_username_entry.text == imap_username_entry.text) &&
            (smtp_password_entry.text == imap_password_entry.text));
        }

        temp_string = params.get ("ImapServer");
        if (temp_string != null) {
            imap_server_entry.text = temp_string.get_string ();
        }

        temp_string = params.get ("SmtpServer");
        if (temp_string != null) {
            smtp_server_entry.text = temp_string.get_string ();
        }

        temp_string = params.get ("ImapPort");
        if (temp_string != null) {
            imap_port_spin.value = temp_string.get_uint16 ();
        }

        temp_string = params.get ("SmtpPort");
        if (temp_string != null) {
            smtp_port_spin.value = temp_string.get_uint16 ();
        }

        temp_string = params.get ("ImapEncryption");
        if (temp_string != null) {
            imap_encryption_combobox.active_id = temp_string.get_string ();
        }

        temp_string = params.get ("SmtpEncryption");
        if (temp_string != null) {
            smtp_encryption_combobox.active_id = temp_string.get_string ();
        }

        reset_ok ();

        return true;
    }

    private bool validate_params (HashTable<string, Variant> params) {
        return true;
    }

    public override HashTable<string, Variant> get_reply () {
        var table = base.get_reply ();
        table.insert ("ImapUser", new Variant.string (imap_username_entry.text));
        table.insert ("ImapPassword", new Variant.string (imap_password_entry.text));
        if (!no_credentials.active) {
            if (use_imap_credentials.active) {
                table.insert ("SmtpUser", new Variant.string (imap_username_entry.text));
                table.insert ("SmtpPassword", new Variant.string (imap_password_entry.text));
            } else {
                table.insert ("SmtpUser", new Variant.string (smtp_username_entry.text));
                table.insert ("SmtpPassword", new Variant.string (smtp_password_entry.text));
            }
        }

        table.insert ("ImapServer", new Variant.string (imap_server_entry.text));
        table.insert ("ImapPort", new Variant.uint16 ((uint16)imap_port_spin.value));
        table.insert ("ImapSecurity", new Variant.string (imap_encryption_combobox.active_id));
        table.insert ("SmtpServer", new Variant.string (smtp_server_entry.text));
        table.insert ("SmtpPort", new Variant.uint16 ((uint16)smtp_port_spin.value));
        table.insert ("SmtpSecurity", new Variant.string (smtp_encryption_combobox.active_id));
        return table;
    }

    private void reset_ok () {
        bool state = imap_username_entry.text.contains ("@");
        state &= imap_password_entry.text.strip ().length > 0;
        if (!no_credentials.active && !use_imap_credentials.active) {
            state &= smtp_username_entry.text.contains ("@");
            state &= smtp_password_entry.text.strip ().length > 0;
        }

        state &= imap_server_entry.text.strip ().length > 0;
        state &= smtp_server_entry.text.strip ().length > 0;
        save_button.sensitive = state;
    }

}
