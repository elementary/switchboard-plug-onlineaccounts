/*
 * Copyright 2025 elementary, Inc. <https://elementary.io>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class OnlineAccounts.WebDavDialog : Gtk.Window {
    private Adw.NavigationView navigation_view;

    private Granite.ValidatedEntry url_entry;
    private Granite.ValidatedEntry username_entry;
    private Gtk.Button login_button;
    private Gtk.PasswordEntry password_entry;
    private ValidationMessage url_message_revealer;

    construct {
        url_entry = new Granite.ValidatedEntry () {
            hexpand = true,
            input_purpose = URL,
            placeholder_text = "https://webdav.example.com"
        };
        url_entry.update_property (Gtk.AccessibleProperty.REQUIRED, true, -1);

        var url_label = new Granite.HeaderLabel (_("Server URL")) {
            mnemonic_widget = url_entry
        };

        url_message_revealer = new ValidationMessage (_("URL must begin with “http://” or “https://”"));
        url_message_revealer.label_widget.add_css_class (Granite.STYLE_CLASS_ERROR);

        username_entry = new Granite.ValidatedEntry ();
        username_entry.update_property (Gtk.AccessibleProperty.REQUIRED, true, -1);

        var username_label = new Granite.HeaderLabel (_("User Name")) {
            mnemonic_widget = username_entry
        };

        password_entry = new Gtk.PasswordEntry () {
            activates_default = true,
            show_peek_icon = true
        };

        var password_label = new Granite.HeaderLabel (_("Password")) {
            mnemonic_widget = password_entry
        };

        var login_cancel_button = new Gtk.Button.with_label (_("Cancel")) {
            width_request = 86
        };

        login_button = new Gtk.Button.with_label (_("Log In")) {
            width_request = 86,
            sensitive = false
        };
        login_button.add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);

        var action_area = new Gtk.Box (HORIZONTAL, 6) {
            margin_top = 24,
            halign = END,
            valign = END,
            vexpand = true,
            homogeneous = true
        };
        action_area.append (login_cancel_button);
        action_area.append (login_button);

        var login_box = new Gtk.Box (VERTICAL, 6) {
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };
        login_box.append (url_label);
        login_box.append (url_entry);
        login_box.append (url_message_revealer);
        login_box.append (username_label);
        login_box.append (username_entry);
        login_box.append (password_label);
        login_box.append (password_entry);
        login_box.append (action_area);

        var login_page = new Adw.NavigationPage (login_box, _("Log In"));

        navigation_view = new Adw.NavigationView () {
            hexpand = true,
            vexpand = true
        };

        var window_handle = new Gtk.WindowHandle () {
            child = navigation_view
        };

        child = window_handle;

        default_height = 475;
        default_width = 350;
        modal = true;

        titlebar = new Gtk.Grid () { visible = false };

        add_css_class ("dialog");

        push_page (login_page);

        login_page.shown.connect (() => {
            default_widget = login_button;
        });

        login_cancel_button.clicked.connect (close);

        url_entry.changed.connect (() => {
            if (url_entry.text != null && url_entry.text != "") {
                var is_valid_url = is_valid_url (url_entry.text);
                url_entry.is_valid = is_valid_url;
                url_message_revealer.reveal_child = !is_valid_url;
            } else {
                url_entry.is_valid = false;
                url_message_revealer.reveal_child = false;
            }

            validate_form ();
        });

        username_entry.changed.connect (() => {
            username_entry.is_valid = username_entry.text != null && username_entry.text != "";

            validate_form ();
        });

        login_button.clicked.connect (() => {
            var cancellable = new GLib.Cancellable ();

            var finalize_page = new FinalizePage (cancellable);

            push_page (finalize_page);

            connect_to_server.begin (cancellable, (obj, res) => {
                try {
                    connect_to_server.end (res);
                    finalize_page.show_success ();
                } catch (GLib.IOError.ALREADY_MOUNTED e) {
                    finalize_page.show_success ();
                } catch (Error e) {
                    finalize_page.show_error (e);
                } finally {
                    cancellable = null;
                }
            });
        });
    }

    private async void connect_to_server (GLib.Cancellable cancellable) throws Error {
        var server_uri = Uri.parse (url_entry.text, NONE);
        var host = server_uri.get_host ();

        /* Fastmail keeps special folders in the toplevel, actual files are in a subfolder
         * https://www.fastmail.help/hc/en-us/articles/1500000277882-Remote-file-access
         */
        if (host == "webdav.fastmail.com") {
            host = "myfiles.fastmail.com";
        }

        var port = 80;
        var scheme = "dav";
        if (server_uri.get_scheme () == "https") {
            scheme = "davs";
            port = 443;
        }

        var uri = GLib.Uri.build_with_user (
            NONE,
            scheme,
            username_entry.text,
            null,
            null,
            host,
            port,
            "",
            null,
            null
        );

        var file = File.new_for_uri (uri.to_string ());

        var mount_operation = new GLib.MountOperation () {
            domain = host,
            username = username_entry.text
        };

        var password = password_entry.text;
        if (password != null && password != "") {
            mount_operation.password = password ;
            mount_operation.password_save = PERMANENTLY;
            mount_operation.ask_password.connect (() => {
                mount_operation.reply (HANDLED);
            });
        }

        yield file.mount_enclosing_volume (NONE, mount_operation, cancellable);
    }

    private bool is_valid_url (string uri) {
        var scheme = Uri.parse_scheme (uri);
        if (scheme == null) {
            return false;
        }

        return scheme.has_prefix ("http");
    }

    private void validate_form () {
        login_button.sensitive = url_entry.is_valid && username_entry.is_valid;
    }

    /**
     * Pushes an {@link Adw.NavigationPage} onto the navigation stack
     */
    public void push_page (Adw.NavigationPage page) {
        navigation_view.push (page);
    }

    /**
     * Pops the visible {@link Adw.NavigationPage} from the navigation stack
     */
    public void pop_page () {
        navigation_view.pop ();
    }
}
