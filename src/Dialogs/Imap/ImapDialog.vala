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
    private Gtk.CheckButton smtp_no_credentials;
    private Gtk.ComboBoxText imap_encryption_combobox;
    private Gtk.ComboBoxText smtp_encryption_combobox;
    private Gtk.Entry smtp_password_entry;
    private Gtk.Entry smtp_username_entry;
    private Gtk.SpinButton imap_port_spin;
    private Gtk.SpinButton imap_refresh_interval_spin;
    private Gtk.SpinButton smtp_port_spin;
    private ImapLoginPage login_page;
    private ImapSavePage save_page;
    private uint cancel_timeout_id = 0;

    private E.SourceRegistry? registry = null;
    private E.Source? source = null;

    construct {
        login_page = new ImapLoginPage ();
        save_page = new ImapSavePage ();

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

        imap_refresh_interval_spin = new Gtk.SpinButton.with_range (1, 60, 1) {
            value = 10
        };

        var imap_port_label = new Gtk.Label (_("Port:")) {
            halign = Gtk.Align.END
        };

        var imap_encryption_label = new Gtk.Label (_("Encryption:")) {
            halign = Gtk.Align.END
        };

        var imap_refresh_interval_label = new Gtk.Label (_("Refresh Interval in Minutes:")) {
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
        imap_server_grid.attach (imap_refresh_interval_label, 0, 6);
        imap_server_grid.attach (imap_refresh_interval_spin, 1, 6);

        use_imap_credentials = new Gtk.CheckButton.with_label (_("Use IMAP Credentials")) {
            active = true
        };

        smtp_no_credentials = new Gtk.CheckButton.with_label (_("No authentication required"));

        var smtp_header = new Granite.HeaderLabel ("SMTP");

        var smtp_username_label = new Gtk.Label (_("Username:")) {
            xalign = 1
        };

        smtp_username_entry = new Gtk.Entry () {
            activates_default = true,
            hexpand = true
        };

        var smtp_password_label = new Gtk.Label (_("Password:")) {
            xalign = 1
        };

        smtp_password_entry = new Gtk.Entry () {
            activates_default = true,
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
        smtp_server_grid.attach (smtp_no_credentials, 1, 1);
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
        deck.add (save_page);

        var window_handle = new Hdy.WindowHandle ();
        window_handle.add (deck);

        default_height = 400;
        default_width = 300;
        window_position = Gtk.WindowPosition.CENTER_ON_PARENT;
        modal = true;
        type_hint = Gdk.WindowTypeHint.DIALOG;
        add (window_handle);

        login_page.next_button.has_default = true;

        login_page.cancel.connect (destroy);

        login_page.next_button.clicked.connect (() => {
            deck.visible_child = main_grid;
            save_button.has_default = true;
        });

        save_page.close.connect (destroy);

        save_page.back.connect (() => {
            deck.navigate (Hdy.NavigationDirection.BACK);
            save_button.has_default = true;
        });

        back_button.clicked.connect (() => {
            deck.navigate (Hdy.NavigationDirection.BACK);
            login_page.next_button.has_default = true;
        });

        smtp_no_credentials.notify["active"].connect (() => {
            smtp_revealer.reveal_child = !smtp_no_credentials.active && !use_imap_credentials.active;
            use_imap_credentials.sensitive = ! smtp_no_credentials.active;
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
            if (use_imap_credentials.active) {
                smtp_username_entry.text = imap_username_entry.text;
            }
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
            if (cancellable != null) {
                cancellable.cancel ();
            }
            cancellable = new GLib.Cancellable ();

            deck.visible_child = save_page;
            save_page.show_busy (cancellable);

            save_configuration.begin ((obj, res) => {
                try {
                    save_configuration.end (res);
                    save_page.show_success ();

                } catch (Error e) {
                    save_page.show_error (e);
                }
            });
        });

        key_release_event.connect ((event_key) => {
            if (event_key.keyval == Gdk.Key.Escape) {
                if (cancellable != null) {
                    cancellable.cancel ();
                }
                destroy ();
            }
        });
    }

    private void set_button_sensitivity () {
        save_button.sensitive = imap_username_entry.is_valid && imap_server_entry.is_valid && smtp_server_entry.is_valid;
    }

    public async void load_configuration (E.Source account_source, GLib.Cancellable? cancellable) throws Error {
        if (!account_source.has_extension (E.SOURCE_EXTENSION_MAIL_ACCOUNT)) {
            throw new Camel.Error.ERROR_GENERIC (_("The data provided does not seem to reflect a valid mail account."));
        }

        registry = yield new E.SourceRegistry (cancellable);
        if (cancellable.is_cancelled ()) {
            return;
        }
        this.source = account_source;
        var credentials_provider = new E.SourceCredentialsProvider (registry);

        E.NamedParameters account_credentials;
        credentials_provider.lookup_sync (account_source, null, out account_credentials);
        if (account_credentials != null) {
            login_page.password = account_credentials.get (E.SOURCE_CREDENTIAL_PASSWORD);
        }

        /* load configuration from identity_source */
        unowned var account_extension = (E.SourceMailAccount) account_source.get_extension (E.SOURCE_EXTENSION_MAIL_ACCOUNT);

        if (account_extension.identity_uid != "") {
            var identity_source = registry.ref_source (account_extension.identity_uid);

            if (identity_source != null) {

                if (identity_source.has_extension (E.SOURCE_EXTENSION_MAIL_IDENTITY)) {
                    unowned var identity_extension = (E.SourceMailIdentity) identity_source.get_extension (E.SOURCE_EXTENSION_MAIL_IDENTITY);
                    login_page.email = identity_extension.address;
                    login_page.real_name = identity_extension.name;
                }

                if (identity_source.has_extension (E.SOURCE_EXTENSION_MAIL_SUBMISSION)) {

                    /* load configuration from transport_source */

                    unowned var submission_extension = (E.SourceMailSubmission) identity_source.get_extension (E.SOURCE_EXTENSION_MAIL_SUBMISSION);

                    if (submission_extension.transport_uid != null) {
                        var transport_source = registry.ref_source (submission_extension.transport_uid);

                        if (transport_source != null) {
                            if (transport_source.has_extension (E.SOURCE_EXTENSION_SECURITY)) {
                                unowned var transport_security_extension = (E.SourceSecurity) transport_source.get_extension (E.SOURCE_EXTENSION_SECURITY);
                                smtp_encryption_combobox.set_active_id (transport_security_extension.method);
                            }

                            if (transport_source.has_extension (E.SOURCE_EXTENSION_AUTHENTICATION)) {
                                unowned var transport_auth_extension = (E.SourceAuthentication) transport_source.get_extension (E.SOURCE_EXTENSION_AUTHENTICATION);

                                smtp_username_entry.text = transport_auth_extension.user;
                                smtp_server_entry.text = transport_auth_extension.host;
                                smtp_port_spin.value = transport_auth_extension.port;
                            }

                            E.NamedParameters transport_credentials;
                            credentials_provider.lookup_sync (transport_source, null, out transport_credentials);

                            if (transport_credentials == null) {
                                smtp_no_credentials.active = true;

                            } else if (account_credentials != null && account_credentials.get (E.SOURCE_CREDENTIAL_PASSWORD) == transport_credentials.get (E.SOURCE_CREDENTIAL_PASSWORD)) {
                                use_imap_credentials.active = true;

                            } else {
                                use_imap_credentials.active = false;
                                smtp_password_entry.text = transport_credentials.get (E.SOURCE_CREDENTIAL_PASSWORD);
                            }
                        }
                    }
                }
            }
        }

        /* load configuration from account_source */

        if (account_source.has_extension (E.SOURCE_EXTENSION_SECURITY)) {
            unowned var account_security_extension = (E.SourceSecurity) account_source.get_extension (E.SOURCE_EXTENSION_SECURITY);
            imap_encryption_combobox.set_active_id (account_security_extension.method);
        }

        if (account_source.has_extension (E.SOURCE_EXTENSION_AUTHENTICATION)) {
            unowned var account_auth_extension = (E.SourceAuthentication) account_source.get_extension (E.SOURCE_EXTENSION_AUTHENTICATION);
            imap_username_entry.text = account_auth_extension.user;
            imap_server_entry.text = account_auth_extension.host;
            imap_port_spin.value = account_auth_extension.port;
        }

        if (account_source.has_extension (E.SOURCE_EXTENSION_REFRESH)) {
          unowned var refresh_extension = (E.SourceRefresh) account_source.get_extension (E.SOURCE_EXTENSION_REFRESH);
          imap_refresh_interval_spin.value = refresh_extension.interval_minutes;
        }

        if (account_source.display_name != "") {
            /* set the display name as last value to avoid having
            it overwritten by event handlers in login_page */
            login_page.display_name = account_source.display_name;
        }
    }

    private async void save_configuration () throws Error {
        if (registry == null) {
            registry = yield new E.SourceRegistry (cancellable);
        }

        if (cancellable.is_cancelled ()) {
            return;
        }

        E.Source? account_source = null;
        E.Source? identity_source = null;
        E.Source? transport_source = null;

        if (source != null) {
            account_source = source;

            if (!account_source.has_extension (E.SOURCE_EXTENSION_MAIL_ACCOUNT)) {
                unowned var account_extension = (E.SourceMailAccount) account_source.get_extension (E.SOURCE_EXTENSION_MAIL_ACCOUNT);

                if (account_extension.identity_uid != "") {
                    identity_source = registry.ref_source (account_extension.identity_uid);

                    if (identity_source != null && identity_source.has_extension (E.SOURCE_EXTENSION_MAIL_SUBMISSION)) {
                        unowned var submission_extension = (E.SourceMailSubmission) identity_source.get_extension (E.SOURCE_EXTENSION_MAIL_SUBMISSION);

                        if (submission_extension.transport_uid != "") {
                            transport_source = registry.ref_source (submission_extension.transport_uid);
                        }
                    }
                }
            }
        }

        if (account_source == null) {
            account_source = new E.Source (null, null) {
                parent = ""
            };
        }

        if (identity_source == null) {
            identity_source = new E.Source (null, null) {
                parent = account_source.uid
            };
        }

        if (transport_source == null) {
            transport_source = new E.Source (null, null) {
                parent = account_source.uid
            };
        }

        account_source.display_name = identity_source.display_name = transport_source.display_name = login_page.display_name;


        /* configure account_source */

        unowned var account_extension = (E.SourceMailAccount) account_source.get_extension (E.SOURCE_EXTENSION_MAIL_ACCOUNT);
        account_extension.identity_uid = identity_source.uid;
        account_extension.needs_initial_setup = true;
        account_extension.backend_name = "imapx";

        unowned var account_security_extension = (E.SourceSecurity) account_source.get_extension (E.SOURCE_EXTENSION_SECURITY);
        account_security_extension.set_method (imap_encryption_combobox.active_id);

        unowned var account_auth_extension = (E.SourceAuthentication) account_source.get_extension (E.SOURCE_EXTENSION_AUTHENTICATION);
        account_auth_extension.host = imap_server_entry.text;
        account_auth_extension.port = (uint) imap_port_spin.value;
        account_auth_extension.user = imap_username_entry.text;

        unowned var refresh_extension = (E.SourceRefresh) account_source.get_extension (E.SOURCE_EXTENSION_REFRESH);
        refresh_extension.enabled = true;
        refresh_extension.interval_minutes = (uint) imap_refresh_interval_spin.value;

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
        if (use_imap_credentials.active) {
            transport_auth_extension.user = imap_username_entry.text;
        } else {
            transport_auth_extension.user = smtp_username_entry.text;
        }

        /* verify connection */
        unowned var session = CamelSession.get_default ();

        debug ("Add imap service for mail account extension");
        var imap_service = session.add_service (account_source.uid, account_extension.backend_name, Camel.ProviderType.STORE);
        imap_service.set_password (login_page.password);
        account_source.camel_configure_service (imap_service);

        if (imap_service is Camel.NetworkService) {
            debug ("Test if we can reach the imap service…");
            yield ((Camel.NetworkService) imap_service).can_reach (cancellable);
        }

        var imap_auth_types = imap_service.query_auth_types_sync (cancellable);
        GLib.Error? imap_auth_error = null;
        foreach (unowned var imap_auth_type in imap_auth_types) {
            debug ("Testing %s authentication for imap service…", imap_auth_type.name);

            account_auth_extension.method = imap_auth_type.authproto;
            account_source.camel_configure_service (imap_service);

            var imap_auth_cancellable = new GLib.Cancellable ();
            set_cancel_timeout (imap_auth_cancellable);

            try {
                if (imap_service is Camel.OfflineStore) {
                    debug ("Setting the imap service online…");
                    yield ((Camel.OfflineStore) imap_service).set_online (true, GLib.Priority.DEFAULT, imap_auth_cancellable);
                } else {
                    debug ("Connecting to the imap service…");
                    yield imap_service.connect (GLib.Priority.DEFAULT, imap_auth_cancellable);
                }

                debug ("Successfully connected to the imap service using %s authentication.", imap_auth_type.name);
                imap_auth_error = null;
                break;

            } catch (GLib.Error e) {
                debug ("Error using %s authentication for imap service: %s", imap_auth_type.name, e.message);

                if (e is GLib.IOError.CANCELLED) {
                    imap_auth_error = new GLib.Error (
                        Camel.Service.error_quark (),
                        Camel.ServiceError.CANT_AUTHENTICATE,
                        _("Could not log in. Please verify your credentials.")
                    );

                } else {
                    imap_auth_error = e;
                }
            }
            unset_cancel_timeout ();
        }

        if (imap_auth_error != null) {
            throw new GLib.Error (
                Camel.Service.error_quark (),
                Camel.ServiceError.CANT_AUTHENTICATE,
                _("IMAP verification failed: %s").printf (imap_auth_error.message)
            );
        }

        if (imap_service is Camel.Store) {
            var imap_store = (Camel.Store) imap_service;

            try {
                HashTable<unowned string, unowned string> save_setup;
                imap_store.initial_setup_sync (out save_setup, cancellable);

                if (save_setup == null) {
                    warning ("Initial setup is NULL. Well known folders will probably not work correctly.");

                } else {
                    /*
                     * The key name consists of up to four parts: Source:Extension:Property[:Type]
                     * Source can be 'Collection', 'Account', 'Submission', 'Transport', 'Backend'
                     * Extension is any extension name; it's up to the key creator to make sure
                     * the extension belongs to that particular Source.
                     * Property is a property name in the Extension.
                     * Type is an optional letter describing the type of the value; if not set, then
                     * string is used. Available values are: 'b' for boolean, 'i' for integer,
                     * 's' for string, 'f' for folder full path.
                     * All the part values are case sensitive.
                     *
                     * https://gitlab.gnome.org/GNOME/evolution/-/blob/master/src/libemail-engine/e-mail-store-utils.c#L469
                    */

                    var encoded_account_uri = Camel.URL.encode (account_source.uid, ":;@/");

                    foreach (unowned var key in save_setup.get_keys ()) {
                        var keys = key.split (":");

                        if (keys.length < 3 || keys.length > 4) {
                            warning ("Incorrect store setup key. 3 or 4 parts expected, but %d given in “%s”", keys.length, key);
                            continue;

                        } else {
                            var save_setup_source_type = keys[0];
                            var save_setup_extension_name = keys[1];
                            var save_setup_property_name = keys[2];
                            var save_setup_property_type = keys[3];
                            var save_setup_property_value = save_setup.get (key);

                            switch (save_setup_source_type) {
                                case "Account":
                                    save_initial_setup_key_for_source (
                                        account_source,
                                        save_setup_extension_name,
                                        save_setup_property_name,
                                        save_setup_property_type,
                                        save_setup_property_value,
                                        encoded_account_uri
                                    );
                                    break;

                                case "Submission":
                                    save_initial_setup_key_for_source (
                                        identity_source,
                                        save_setup_extension_name,
                                        save_setup_property_name,
                                        save_setup_property_type,
                                        save_setup_property_value,
                                        encoded_account_uri
                                    );
                                    break;

                                case "Transport":
                                    save_initial_setup_key_for_source (
                                        transport_source,
                                        save_setup_extension_name,
                                        save_setup_property_name,
                                        save_setup_property_type,
                                        save_setup_property_value,
                                        encoded_account_uri
                                    );
                                    break;

                                case "Backend":
                                    save_initial_setup_key_for_source (
                                        account_source,
                                        save_setup_extension_name,
                                        save_setup_property_name,
                                        save_setup_property_type,
                                        save_setup_property_value,
                                        encoded_account_uri
                                    );
                                    break;

                                default:
                                    warning ("Initial setup key is not stored: “%s”", key);
                                    break;
                            }
                        }
                    }

                    account_extension.needs_initial_setup = false;
                }

            } catch (Error e) {
                warning ("Incomplete setup. It is possible to use this e-mail account, but well known folders most likely will not work as expected: %s", e.message);
            }
        }

        if (cancellable.is_cancelled ()) {
            return;
        }

        debug ("Add smtp service");
        var transport_service = session.add_service (transport_source.uid, transport_extension.backend_name, Camel.ProviderType.TRANSPORT);
        transport_source.camel_configure_service (transport_service);

        if (!smtp_no_credentials.active) {
            if (use_imap_credentials.active) {
                transport_service.set_password (login_page.password);
            } else {
                transport_service.set_password (smtp_password_entry.text);
            }
        }

        if (transport_service is Camel.NetworkService) {
            debug ("Test if the smtp service can be reached…");
            yield ((Camel.NetworkService) transport_service).can_reach (cancellable);
        }

        var smtp_auth_types = transport_service.query_auth_types_sync (cancellable);
        GLib.Error? smtp_auth_error = null;
        foreach (unowned var smtp_auth_type in smtp_auth_types) {
            debug ("Testing %s authentication for smtp service…", smtp_auth_type.name);

            transport_auth_extension.method = smtp_auth_type.authproto;
            transport_source.camel_configure_service (transport_service);

            var smtp_auth_cancellable = new GLib.Cancellable ();
            set_cancel_timeout (smtp_auth_cancellable);

            try {
                debug ("Connecting to the smtp service…");
                yield transport_service.connect (GLib.Priority.DEFAULT, smtp_auth_cancellable);

                debug ("Successfully connected to the smtp service using %s authentication.", smtp_auth_type.name);
                smtp_auth_error = null;
                break;

            } catch (GLib.Error e) {
                debug ("Error using %s authentication for smtp service: %s", smtp_auth_type.name, e.message);

                if (e is GLib.IOError.CANCELLED) {
                    smtp_auth_error = new GLib.Error (
                        Camel.Service.error_quark (),
                        Camel.ServiceError.CANT_AUTHENTICATE,
                        "Could not log in. Please verify your credentials."
                    );

                } else {
                    smtp_auth_error = e;
                }
            }
            unset_cancel_timeout ();
        }

        if (smtp_auth_error != null) {
            throw new GLib.Error (
                Camel.Service.error_quark (),
                Camel.ServiceError.CANT_AUTHENTICATE,
                "SMTP verification failed: %s".printf (smtp_auth_error.message)
            );
        }

        if (cancellable.is_cancelled ()) {
            return;
        }

        /* First store passwords, thus the evolution-source-registry has them ready if needed. */
        yield account_source.store_password (login_page.password, true, cancellable);

        if (use_imap_credentials.active) {
            yield transport_source.store_password (login_page.password, true, cancellable);
        } else {
            yield transport_source.store_password (smtp_password_entry.text, true, cancellable);
        }

        /* let's save the sources */
        yield registry.commit_source (account_source, cancellable);
        yield registry.commit_source (identity_source, cancellable);
        yield registry.commit_source (transport_source, cancellable);
    }


    private void set_cancel_timeout (GLib.Cancellable cancellable) {
        cancel_timeout_id = GLib.Timeout.add (4000, () => {
            cancel_timeout_id = 0;
            cancellable.cancel ();
            return GLib.Source.REMOVE;
        });
    }

    private void unset_cancel_timeout () {
        if (cancel_timeout_id != 0) {
            GLib.Source.remove (cancel_timeout_id);
        }
    }

    private void save_initial_setup_key_for_source (E.Source source, string extension_name, string property_name, string? property_type, string val, string encoded_account_uri) {
        unowned var extension = source.get_extension (extension_name);
        if (extension == null) {
            warning ("Extension '%s' not found for source '%s'", extension_name, source.display_name);
            return;
        }

        if (property_type == null) {
            property_type = "s";
        }
        switch (property_type) {
            case "s":
                extension.set (property_name, val);
                break;

            case "b":
                var bool_val = bool.parse (val);
                extension.set (property_name, bool_val);
                break;

            case "i":
                var int_val = int.parse (val);
                extension.set (property_name, int_val);
                break;

            case "f":
                string folder_val = val;
                if (folder_val[0] == '/') {
                    int start = folder_val.index_of_nth_char (1);
                    folder_val = folder_val.substring (start);
                }
                var full_folder_uri = "folder://%s/%s".printf (encoded_account_uri, Camel.URL.encode (val, ":;@?#"));
                extension.set (property_name, full_folder_uri);
                break;

            default:
                warning ("Unknown type identifier '%s' provided", property_type);
                break;
        }
    }
}
