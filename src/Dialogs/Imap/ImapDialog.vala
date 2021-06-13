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
    private GLib.Cancellable? cancellable;
    private Granite.ValidatedEntry imap_server_entry;
    private Granite.ValidatedEntry imap_username_entry;
    private Granite.ValidatedEntry smtp_server_entry;
    private Gtk.Button save_button;
    private Gtk.CheckButton use_imap_credentials;
    private Gtk.ComboBoxText imap_encryption_combobox;
    private Gtk.ComboBoxText smtp_encryption_combobox;
    private Gtk.Entry smtp_password_entry;
    private Gtk.Entry smtp_username_entry;
    private Gtk.SpinButton imap_port_spin;
    private Gtk.SpinButton smtp_port_spin;
    private ImapLoginPage login_page;
    private ImapDonePage done_page;

    construct {
        login_page = new ImapLoginPage ();
        done_page = new ImapDonePage ();

        var imap_header = new Granite.HeaderLabel ("IMAP");

        var imap_username_label = new Gtk.Label (_("Username:")) {
            halign = Gtk.Align.END
        };

        imap_username_entry = new Granite.ValidatedEntry () {
            hexpand = true
        };

        var imap_password_label = new Gtk.Label (_("Password:")) {
            halign = Gtk.Align.END,
            margin_bottom = 18
        };

        var imap_url_label = new Gtk.Label (_("Server URL:")) {
            halign = Gtk.Align.END
        };

        imap_server_entry = new Granite.ValidatedEntry ();

        imap_port_spin = new Gtk.SpinButton.with_range (1, uint16.MAX, 10) {
            value = 993
        };

        var imap_port_label = new Gtk.Label (_("Port:")) {
            halign = Gtk.Align.END
        };

        var imap_encryption_label = new Gtk.Label (_("Encryption:")) {
            halign = Gtk.Align.END
        };

        imap_encryption_combobox = new Gtk.ComboBoxText () {
            hexpand = true
        };
        /* The IDs need to correspond to Camel.NetworkSecurityMethod enum: */
        imap_encryption_combobox.append ("none", _("None"));
        imap_encryption_combobox.append ("ssl-on-alternate-port", "SSL/TLS");
        imap_encryption_combobox.append ("starttls-on-standard-port", "STARTTLS");
        imap_encryption_combobox.active = 1;

        var imap_server_grid = new Gtk.Grid () {
            column_spacing = 6,
            row_spacing = 6
        };
        imap_server_grid.attach (imap_header, 0, 0, 2);
        imap_server_grid.attach (imap_username_label, 0, 1);
        imap_server_grid.attach (imap_username_entry, 1, 1);
        imap_server_grid.attach (imap_url_label, 0, 3);
        imap_server_grid.attach (imap_server_entry, 1, 3);
        imap_server_grid.attach (imap_encryption_label, 0, 4);
        imap_server_grid.attach (imap_encryption_combobox, 1, 4);
        imap_server_grid.attach (imap_port_label, 0, 5);
        imap_server_grid.attach (imap_port_spin, 1, 5);

        use_imap_credentials = new Gtk.CheckButton.with_label (_("Use IMAP Credentials")) {
            active = true
        };

        var no_credentials = new Gtk.CheckButton.with_label (_("No authentication required"));

        var smtp_header = new Granite.HeaderLabel ("SMTP");

        var smtp_username_label = new Gtk.Label (_("Username:")) {
            xalign = 1
        };

        smtp_username_entry = new Gtk.Entry () {
            hexpand = true
        };

        var smtp_password_label = new Gtk.Label (_("Password:")) {
            xalign = 1
        };

        smtp_password_entry = new Gtk.Entry () {
            input_purpose = Gtk.InputPurpose.PASSWORD,
            visibility = false
        };

        var smtp_credentials = new Gtk.Grid () {
            column_spacing = 6,
            row_spacing = 6,
            margin_bottom = 18
        };
        smtp_credentials.attach (smtp_username_label, 0, 0);
        smtp_credentials.attach (smtp_username_entry, 1, 0);
        smtp_credentials.attach (smtp_password_label, 0, 1);
        smtp_credentials.attach (smtp_password_entry, 1, 1);

        var smtp_revealer = new Gtk.Revealer ();
        smtp_revealer.add (smtp_credentials);

        var smtp_url_label = new Gtk.Label (_("Server URL:")) {
            xalign = 1
        };

        smtp_server_entry = new Granite.ValidatedEntry ();

        var smtp_port_label = new Gtk.Label (_("Port:")) {
            xalign = 1
        };

        smtp_port_spin = new Gtk.SpinButton.with_range (1, uint16.MAX, 10) {
            value = 587
        };

        var smtp_encryption_label = new Gtk.Label (_("Encryption:")) {
            xalign = 1
        };

        smtp_encryption_combobox = new Gtk.ComboBoxText () {
            hexpand = true
        };
        /* The IDs need to correspond to Camel.NetworkSecurityMethod enum: */
        smtp_encryption_combobox.append ("none", _("None"));
        smtp_encryption_combobox.append ("ssl-on-alternate-port", "SSL/TLS");
        smtp_encryption_combobox.append ("starttls-on-standard-port", "STARTTLS");
        smtp_encryption_combobox.active = 2;

        var smtp_server_grid = new Gtk.Grid () {
            column_spacing = 6,
            row_spacing = 6
        };
        smtp_server_grid.attach (smtp_header, 0, 0, 2);
        smtp_server_grid.attach (no_credentials, 1, 1);
        smtp_server_grid.attach (use_imap_credentials, 1, 2);
        smtp_server_grid.attach (smtp_revealer, 0, 3, 2);
        smtp_server_grid.attach (smtp_url_label, 0, 4);
        smtp_server_grid.attach (smtp_server_entry, 1, 4);
        smtp_server_grid.attach (smtp_encryption_label, 0, 5);
        smtp_server_grid.attach (smtp_encryption_combobox, 1, 5);
        smtp_server_grid.attach (smtp_port_label, 0, 6);
        smtp_server_grid.attach (smtp_port_spin, 1, 6);

        var smtp_sizegroup = new Gtk.SizeGroup (Gtk.SizeGroupMode.HORIZONTAL);
        smtp_sizegroup.add_widget (smtp_username_label);
        smtp_sizegroup.add_widget (smtp_password_label);
        smtp_sizegroup.add_widget (smtp_url_label);
        smtp_sizegroup.add_widget (smtp_encryption_label);
        smtp_sizegroup.add_widget (smtp_port_label);

        var back_button = new Gtk.Button.with_label (_("Back"));

        save_button = new Gtk.Button.with_label (_("Log In")) {
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
        action_area.add (back_button);
        action_area.add (save_button);


        var main_grid = new Gtk.Grid () {
            margin = 12,
            orientation = Gtk.Orientation.VERTICAL,
            row_spacing = 24
        };
        main_grid.add (imap_server_grid);
        main_grid.add (smtp_server_grid);
        main_grid.add (action_area);

        var deck = new Hdy.Deck () {
            can_swipe_back = true,
            expand = true
        };
        deck.add (login_page);
        deck.add (main_grid);
        deck.add (done_page);

        var window_handle = new Hdy.WindowHandle ();
        window_handle.add (deck);

        default_height = 400;
        default_width = 300;
        window_position = Gtk.WindowPosition.CENTER_ON_PARENT;
        modal = true;
        add (window_handle);

        login_page.cancel.connect (destroy);

        login_page.next.connect (() => {
            deck.visible_child = main_grid;
        });

        done_page.close.connect (destroy);

        done_page.back.connect (() => {
            deck.navigate (Hdy.NavigationDirection.BACK);
        });

        back_button.clicked.connect (() => {
            deck.navigate (Hdy.NavigationDirection.BACK);
        });

        no_credentials.notify["active"].connect (() => {
            smtp_revealer.reveal_child = !no_credentials.active && !use_imap_credentials.active;
            use_imap_credentials.sensitive = ! no_credentials.active;
        });

        use_imap_credentials.bind_property ("active", smtp_revealer, "reveal-child", GLib.BindingFlags.INVERT_BOOLEAN);

        login_page.notify["email"].connect (() => {
            if ("@" in login_page.email) {
                var domain = login_page.email.split ("@", 2)[1].strip ().replace ("@", "");
                if (domain.length > 0) {
                    imap_server_entry.text = "imap." + domain;
                    smtp_server_entry.text = "smtp." + domain;
                }

                imap_username_entry.text = login_page.email;
                smtp_username_entry.text = login_page.email;
            }

            set_button_sensitivity ();
        });

        imap_username_entry.changed.connect (() => {
            imap_username_entry.is_valid = imap_username_entry.text.length > 0;
            set_button_sensitivity ();
        });

        imap_server_entry.changed.connect (() => {
            imap_server_entry.is_valid = imap_server_entry.text.length > 3;
            set_button_sensitivity ();
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

        smtp_server_entry.changed.connect (() => {
            smtp_server_entry.is_valid = smtp_server_entry.text.length > 3;
            set_button_sensitivity ();
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

        save_button.clicked.connect (() => {
            save_configuration.begin ((obj, res) => {
                try {
                    save_configuration.end (res);
                    done_page.set_error (null);

                } catch (Error e) {
                    done_page.set_error (e);
                }
                deck.visible_child = done_page;
            });
        });
    }

    private void set_button_sensitivity () {
        save_button.sensitive = imap_username_entry.is_valid && imap_server_entry.is_valid && smtp_server_entry.is_valid;
    }

    private async void save_configuration () throws Error {
        if (cancellable != null) {
            cancellable.cancel ();
        }
        cancellable = new GLib.Cancellable ();

        var registry = yield new E.SourceRegistry (cancellable);
        if (cancellable.is_cancelled ()) {
            return;
        }

        var account_source = new E.Source (null, null) {
            parent = "",
            display_name = login_page.display_name
        };

        var identity_source = new E.Source (null, null) {
            parent = account_source.uid,
            display_name = login_page.display_name
        };

        var transport_source = new E.Source (null, null) {
            parent = account_source.uid,
            display_name = login_page.display_name
        };

        /* configure account_source */

        unowned var account_extension = (E.SourceMailAccount) account_source.get_extension (E.SOURCE_EXTENSION_MAIL_ACCOUNT);
        account_extension.identity_uid = identity_source.uid;
        account_extension.backend_name = "imap";

        unowned var account_security_extension = (E.SourceSecurity) account_source.get_extension (E.SOURCE_EXTENSION_SECURITY);
        account_security_extension.set_method (imap_encryption_combobox.active_id);

        unowned var account_auth_extension = (E.SourceAuthentication) account_source.get_extension (E.SOURCE_EXTENSION_AUTHENTICATION);
        account_auth_extension.host = imap_server_entry.text;
        account_auth_extension.port = (uint) imap_port_spin.value;
        account_auth_extension.user = imap_username_entry.text;
        account_auth_extension.method = "PLAIN";

        /* configure identity_source */

        unowned var submission_extension = (E.SourceMailSubmission) identity_source.get_extension (E.SOURCE_EXTENSION_MAIL_SUBMISSION);
        submission_extension.transport_uid = transport_source.uid;

        unowned var identity_extension = (E.SourceMailIdentity) identity_source.get_extension (E.SOURCE_EXTENSION_MAIL_IDENTITY);
        identity_extension.address = login_page.email;
        identity_extension.name = login_page.real_name;

        /* configure transport_source */

        unowned var transport_extension = (E.SourceMailTransport) transport_source.get_extension (E.SOURCE_EXTENSION_MAIL_TRANSPORT);
        transport_extension.backend_name = "smtp";

        unowned var transport_security_extension = (E.SourceSecurity) transport_source.get_extension (E.SOURCE_EXTENSION_SECURITY);
        transport_security_extension.set_method (smtp_encryption_combobox.active_id);

        unowned var transport_auth_extension = (E.SourceAuthentication) transport_source.get_extension (E.SOURCE_EXTENSION_AUTHENTICATION);
        transport_auth_extension.host = smtp_server_entry.text;
        transport_auth_extension.port = (uint) smtp_port_spin.value;
        transport_auth_extension.user = smtp_username_entry.text;
        transport_auth_extension.method = "PLAIN";

        /* let's save everything */

        var sources = new GLib.List<E.Source> ();
        sources.append (account_source);
        sources.append (identity_source);
        sources.append (transport_source);

        /* First store passwords, thus the evolution-source-registry has them ready if needed. */
        yield account_source.store_password (login_page.password, true, cancellable);

        if (use_imap_credentials.active) {
            yield transport_source.store_password (login_page.password, true, cancellable);
        } else {
            yield transport_source.store_password (smtp_password_entry.text, true, cancellable);
        }

        yield registry.create_sources (sources, cancellable);
    }
}
