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

public class OnlineAccounts.CaldavDialog : Hdy.Window {
    private GLib.Cancellable? cancellable;
    private Granite.ValidatedEntry url_entry;
    private Granite.ValidatedEntry username_entry;
    private Gtk.Button login_button;
    private Gtk.Button save_configuration_button;
    private Gtk.Button save_configuration_close_button;
    private Gtk.Entry display_name_entry;
    private Gtk.Entry password_entry;
    private Gtk.ListBox calendars_list;
    private Gtk.Stack save_configuration_page_stack;
    private Hdy.Deck deck;
    private ListStore calendars_store;

    private E.SourceRegistry? registry = null;
    private E.Source? source = null;

    construct {
        var url_label = new Granite.HeaderLabel (_("Server URL"));
        url_entry = new Granite.ValidatedEntry () {
            hexpand = true
        };

        var url_message_revealer = new ValidationMessage (_("Invalid URL"));
        url_message_revealer.label_widget.get_style_context ().add_class (Gtk.STYLE_CLASS_ERROR);

        var username_label = new Granite.HeaderLabel (_("User Name"));
        username_entry = new Granite.ValidatedEntry ();

        var password_label = new Granite.HeaderLabel (_("Password"));
        password_entry = new Gtk.Entry () {
            activates_default = true,
            input_purpose = Gtk.InputPurpose.PASSWORD,
            visibility = false
        };

        var login_cancel_button = new Gtk.Button.with_label (_("Cancel"));

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
        action_area.add (login_cancel_button);
        action_area.add (login_button);

        var login_page = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL,
            margin = 12
        };
        login_page.add (url_label);
        login_page.add (url_entry);
        login_page.add (url_message_revealer);
        login_page.add (username_label);
        login_page.add (username_entry);
        login_page.add (password_label);
        login_page.add (password_entry);
        login_page.add (action_area);

        var display_name_label = new Granite.HeaderLabel (_("Account Display Name"));

        display_name_entry = new Gtk.Entry () {
            hexpand = true
        };

        var display_name_hint_label = new Gtk.Label (_("Pick a name like “Work” or “Personal” for the account.")) {
            hexpand = true,
            xalign = 0
        };
        display_name_hint_label.set_line_wrap (true);
        display_name_hint_label.get_style_context ().add_class (Granite.STYLE_CLASS_SMALL_LABEL);

        calendars_store = new ListStore (typeof (E.Source));

        calendars_list = new Gtk.ListBox () {
            expand = true
        };
        calendars_list.set_header_func (header_func);
        calendars_list.set_sort_func (sort_func);
        calendars_list.bind_model (calendars_store, create_item);

        var calendars_scroll_window = new Gtk.ScrolledWindow (null, null) {
            hscrollbar_policy = Gtk.PolicyType.NEVER
        };
        calendars_scroll_window.add (calendars_list);

        var calendar_list_frame = new Gtk.Frame (null) {
            margin_top = 18
        };
        calendar_list_frame.add (calendars_scroll_window);

        var calendar_page_back_button = new Gtk.Button.with_label (_("Back"));

        save_configuration_button = new Gtk.Button.with_label (_("Save")) {
            can_default = true
        };
        save_configuration_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

        var calendar_page_action_area = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
            layout_style = Gtk.ButtonBoxStyle.END,
            margin_top = 24,
            spacing = 6
        };
        calendar_page_action_area.add (calendar_page_back_button);
        calendar_page_action_area.add (save_configuration_button);

        var calendars_page = new Gtk.Grid () {
            margin = 12,
            orientation = Gtk.Orientation.VERTICAL,
            row_spacing = 6
        };
        calendars_page.add (display_name_label);
        calendars_page.add (display_name_entry);
        calendars_page.add (display_name_hint_label);
        calendars_page.add (calendar_list_frame);
        calendars_page.add (calendar_page_action_area);

        var save_configuration_busy_label = new Gtk.Label (_("Saving the configuration…"));

        var save_configuration_busy_spinner = new Gtk.Spinner ();
        save_configuration_busy_spinner.start ();

        var save_configuration_busy_grid = new Gtk.Grid () {
            column_spacing = 6
        };
        save_configuration_busy_grid.add (save_configuration_busy_label);
        save_configuration_busy_grid.add (save_configuration_busy_spinner);

        var save_configuration_success_view = new Granite.Widgets.AlertView (
            _("All done"),
            _("CalDAV account saved."),
            "process-completed"
        );
        save_configuration_success_view.get_style_context ().remove_class (Gtk.STYLE_CLASS_VIEW);
        save_configuration_success_view.show_all ();

        var save_configuration_back_button = new Gtk.Button.with_label (_("Back"));
        save_configuration_close_button = new Gtk.Button.with_label (_("Close"));
        save_configuration_close_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

        var save_configuration_page_action_area = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
            layout_style = Gtk.ButtonBoxStyle.END,
            margin_top = 24,
            spacing = 6
        };
        save_configuration_page_action_area.add (save_configuration_back_button);
        save_configuration_page_action_area.add (save_configuration_close_button);

        save_configuration_page_stack = new Gtk.Stack () {
            expand = true,
            homogeneous = false,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };
        save_configuration_page_stack.add_named (save_configuration_busy_grid, "busy");
        save_configuration_page_stack.add_named (save_configuration_success_view, "success");

        var save_configuration_page = new Gtk.Box (Gtk.Orientation.VERTICAL, 12) {
            margin = 12
        };
        save_configuration_page.add (save_configuration_page_stack);
        save_configuration_page.add (save_configuration_page_action_area);

        deck = new Hdy.Deck () {
            can_swipe_back = true,
            expand = true
        };
        deck.add (login_page);
        deck.add (calendars_page);
        deck.add (save_configuration_page);

        var window_handle = new Hdy.WindowHandle ();
        window_handle.add (deck);

        default_height = 400;
        default_width = 300;
        window_position = Gtk.WindowPosition.CENTER_ON_PARENT;
        modal = true;
        type_hint = Gdk.WindowTypeHint.DIALOG;
        add (window_handle);

        login_button.has_default = true;

        login_cancel_button.clicked.connect (() => {
            destroy ();
        });

        login_button.clicked.connect (() => {
            find_sources.begin ();
            deck.visible_child = calendars_page;
            save_configuration_button.has_default = true;
        });

        save_configuration_button.clicked.connect (() => {
            deck.visible_child = save_configuration_page;
            save_configuration_close_button.sensitive = false;
            save_configuration_page_stack.set_visible_child_name ("busy");

            save_configuration.begin ((obj, res) => {
                save_configuration_close_button.sensitive = true;

                try {
                    save_configuration.end (res);
                    save_configuration_back_button.sensitive = false;
                    save_configuration_page_stack.set_visible_child_name ("success");

                } catch (Error e) {
                    var error_view = save_configuration_page_stack.get_child_by_name ("error");
                    if (error_view != null) {
                        save_configuration_page_stack.remove (error_view);
                    }
                    error_view = new Granite.Widgets.AlertView (
                        _("Could not save configuration"),
                        e.message,
                        "dialog-error"
                    );
                    error_view.show_all ();

                    save_configuration_page_stack.add_named (error_view, "error");
                    save_configuration_page_stack.set_visible_child_name ("error");
                }
            });
        });

        save_configuration_close_button.clicked.connect (() => {
            destroy ();
        });

        calendar_page_back_button.clicked.connect (() => {
            back_button_clicked ();
            login_button.has_default = true;
        });

        save_configuration_back_button.clicked.connect (() => {
            back_button_clicked ();
            save_configuration_button.has_default = true;
        });

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
            display_name_entry.text = username_entry.text;

            validate_form ();
        });
    }

    private void back_button_clicked () {
        if (cancellable != null) {
            cancellable.cancel ();
        }
        deck.navigate (Hdy.NavigationDirection.BACK);
    }

    private int sort_func (Gtk.ListBoxRow row1, Gtk.ListBoxRow row2) {
        var source1 = ((SourceRow) row1).source;
        var source2 = ((SourceRow) row2).source;

        if (source1.has_extension (E.SOURCE_EXTENSION_CALENDAR) && !source2.has_extension (E.SOURCE_EXTENSION_CALENDAR)) {
            return -1;
        }
        return source1.display_name.collate (source2.display_name);
    }

    private void header_func (Gtk.ListBoxRow row, Gtk.ListBoxRow? before) {
        var source_row = (SourceRow) row;
        var is_calendar = source_row.source.has_extension (E.SOURCE_EXTENSION_CALENDAR);
        var is_tasklist = source_row.source.has_extension (E.SOURCE_EXTENSION_TASK_LIST);

        Granite.HeaderLabel? header_label = null;

        if (before == null) {
            if (is_calendar) {
                header_label = new Granite.HeaderLabel (_("Calendars"));
            } else if (is_tasklist) {
                header_label = new Granite.HeaderLabel (_("Task Lists"));
            }

        } else {
            var before_source_row = (SourceRow) before;
            var before_is_calendar = before_source_row.source.has_extension (E.SOURCE_EXTENSION_CALENDAR);

            if (before_is_calendar && is_tasklist) {
                header_label = new Granite.HeaderLabel (_("Task Lists"));
            }
        }
        row.set_header (header_label);
    }

    private void validate_form () {
        login_button.sensitive = url_entry.is_valid && username_entry.is_valid;
    }

    private bool is_valid_url (string uri) {
        var scheme = Uri.parse_scheme (uri);
        if (scheme == null) {
            return false;
        }

        return scheme.has_prefix ("http");
    }

    [ CCode ( instance_pos = 1.9 ) ]
    public Gtk.Widget create_item (GLib.Object item) {
        var row = new SourceRow ((E.Source) item);
        row.show_all ();

        return row;
    }

    private async void find_sources () {
        if (cancellable != null) {
            cancellable.cancel ();
        }

        cancellable = new GLib.Cancellable ();
        save_configuration_button.sensitive = false;

        var placeholder_label = new Gtk.Label (_("Finding available calendars and tasks…"));

        var spinner = new Gtk.Spinner ();
        spinner.start ();

        var placeholder = new Gtk.Grid () {
            column_spacing = 6,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };
        placeholder.add (placeholder_label);
        placeholder.add (spinner);
        placeholder.show_all ();

        calendars_list.set_placeholder (placeholder);
        calendars_store.remove_all ();

        try {
            var source = new E.Source (null, null);
            source.parent = "caldav-stub";

            unowned var col = (E.SourceCollection)source.get_extension (E.SOURCE_EXTENSION_COLLECTION);
            col.backend_name = "caldav";

            unowned var webdav = (E.SourceWebdav)source.get_extension (E.SOURCE_EXTENSION_WEBDAV_BACKEND);
            webdav.soup_uri = new Soup.URI (url_entry.text);
            webdav.calendar_auto_schedule = true;

            unowned var auth = (E.SourceAuthentication)source.get_extension (E.SOURCE_EXTENSION_AUTHENTICATION);
            auth.user = username_entry.text;

            unowned var offline = (E.SourceOffline)source.get_extension (E.SOURCE_EXTENSION_OFFLINE);
            offline.set_stay_synchronized (true);

            var credentials = new E.NamedParameters ();
            credentials.set (E.SOURCE_CREDENTIAL_USERNAME, username_entry.text);
            credentials.set (E.SOURCE_CREDENTIAL_PASSWORD, password_entry.text);

            var found_calendars = yield find_sources_supporting (E.WebDAVDiscoverSupports.EVENTS, source, credentials, cancellable);
            var found_tasklists = yield find_sources_supporting (E.WebDAVDiscoverSupports.TASKS, source, credentials, cancellable);

            Idle.add (() => {
                calendars_store.splice (0, 0, (Object[]) found_calendars);
                calendars_store.splice (found_calendars.length, 0, (Object[]) found_tasklists);
                save_configuration_button.sensitive = true;
                return Source.REMOVE;
            });

        } catch (GLib.Error e) {
            var error_placeholder = new Granite.Widgets.AlertView (
                _("Could not fetch calendars"),
                e.message,
                "dialog-error"
            );
            Idle.add (() => {
                error_placeholder.show_all ();
                calendars_list.set_placeholder (error_placeholder);
                return Source.REMOVE;
            });
        }
    }

    private async E.Source[] find_sources_supporting (E.WebDAVDiscoverSupports only_supports, E.Source source, E.NamedParameters credentials, GLib.Cancellable? cancellable) throws Error {
        E.Source[] e_sources = {};
        GLib.Error? discover_error = null;

#if HAS_EDS_3_40
        source.webdav_discover_sources.begin (
#else
        E.webdav_discover_sources.begin (
            source,
#endif
        null,
        only_supports,
        credentials,
        cancellable,
        (obj, res) => {
            string certificate_pem;
            GLib.TlsCertificateFlags certificate_errors;
            GLib.SList<E.WebDAVDiscoveredSource?> discovered_sources;
            GLib.SList<string> calendar_user_addresses;
            try {
#if HAS_EDS_3_40
                source.webdav_discover_sources.end (
#else
                E.webdav_discover_sources_finish (
                    source,
#endif
                    res,
                    out certificate_pem,
                    out certificate_errors,
                    out discovered_sources,
                    out calendar_user_addresses
                );

                foreach (unowned E.WebDAVDiscoveredSource? disc_source in discovered_sources) {
                    if (disc_source == null) {
                        continue;
                    }

                    var e_source = new E.Source (null, null) {
                        display_name = disc_source.display_name
                    };

                    unowned var webdav = (E.SourceWebdav) e_source.get_extension (E.SOURCE_EXTENSION_WEBDAV_BACKEND);
                    webdav.soup_uri = new Soup.URI (disc_source.href);
                    webdav.color = disc_source.color;

                    switch (only_supports) {
                        case E.WebDAVDiscoverSupports.EVENTS:
                            unowned var calendar = (E.SourceCalendar) e_source.get_extension (E.SOURCE_EXTENSION_CALENDAR);
                            calendar.backend_name = "caldav";
                            calendar.color = disc_source.color;
                            break;
                        case E.WebDAVDiscoverSupports.TASKS:
                            unowned var tasklist = (E.SourceTaskList) e_source.get_extension (E.SOURCE_EXTENSION_TASK_LIST);
                            tasklist.backend_name = "caldav";
                            tasklist.color = disc_source.color;
                            break;
                    }

                    e_sources += e_source;
                }
                E.webdav_discover_do_free_discovered_sources ((owned) discovered_sources);

            } catch (GLib.IOError.CANCELLED e) {
            } catch (Error e) {
                discover_error = e;
            }

            find_sources_supporting.callback ();
        });

        yield;

        if (discover_error != null) {
            throw discover_error;
        }
        return e_sources;
    }

    public async void load_configuration (E.Source collection_source, GLib.Cancellable? cancellable) throws Error {
        if (
            !collection_source.has_extension (E.SOURCE_EXTENSION_COLLECTION) ||
            "webdav" != ((E.SourceCollection) collection_source.get_extension (E.SOURCE_EXTENSION_COLLECTION)).backend_name
        ) {
            throw new Camel.Error.ERROR_GENERIC (_("The data provided does not seem to reflect a valid CalDav account."));
        }

        registry = yield new E.SourceRegistry (cancellable);
        if (cancellable.is_cancelled ()) {
            return;
        }
        this.source = collection_source;
        var credentials_provider = new E.SourceCredentialsProvider (registry);

        E.NamedParameters collection_credentials;
        credentials_provider.lookup_sync (collection_source, null, out collection_credentials);
        if (collection_credentials != null) {
            password_entry.text = collection_credentials.get (E.SOURCE_CREDENTIAL_PASSWORD);
        }

        /* load configuration from collection_source */

        unowned var collection_extension = (E.SourceCollection) collection_source.get_extension (E.SOURCE_EXTENSION_COLLECTION);
        username_entry.text = collection_extension.identity;

        if (collection_source.has_extension (E.SOURCE_EXTENSION_WEBDAV_BACKEND)) {
            unowned var webdav_extension = (E.SourceWebdav) collection_source.get_extension (E.SOURCE_EXTENSION_WEBDAV_BACKEND);
            url_entry.text = webdav_extension.soup_uri.to_string (false);

            if (webdav_extension.soup_uri.user != null && webdav_extension.soup_uri.user != "") {
                url_entry.text = url_entry.text.replace (webdav_extension.soup_uri.user + "@", "");
            }
        }

        display_name_entry.text = collection_source.display_name;
    }

    private async void save_configuration () throws Error {
        if (cancellable != null) {
            cancellable.cancel ();
        }
        cancellable = new GLib.Cancellable ();

        if (registry == null) {
            registry = yield new E.SourceRegistry (cancellable);
        }

        if (cancellable.is_cancelled ()) {
            return;
        }
        GLib.List<E.Source> new_sources = new GLib.List<E.Source> ();

        /* store the collection source first, so we can use it as parent for the other ones */
        var collection_source = new E.Source (null, null);
        collection_source.parent = "";
        collection_source.display_name = display_name_entry.text;

        unowned var collection_extension = (E.SourceCollection) collection_source.get_extension (E.SOURCE_EXTENSION_COLLECTION);
        collection_extension.backend_name = "webdav";
        collection_extension.identity = username_entry.text;

        unowned var authentication_extension = (E.SourceAuthentication) collection_source.get_extension (E.SOURCE_EXTENSION_AUTHENTICATION);
        authentication_extension.user = username_entry.text;

        unowned var webdav_extension = (E.SourceWebdav) collection_source.get_extension (E.SOURCE_EXTENSION_WEBDAV_BACKEND);
        webdav_extension.soup_uri = new Soup.URI (url_entry.text);
        webdav_extension.calendar_auto_schedule = true;

        unowned var offline_extension = (E.SourceOffline) collection_source.get_extension (E.SOURCE_EXTENSION_OFFLINE);
        offline_extension.set_stay_synchronized (true);

        new_sources.append (collection_source);

        /* next we add all child sources */
        E.Source? child_source = null;
        var position = 0;
        while ((child_source = (E.Source) calendars_store.get_item (position)) != null) {
            position++;

            child_source.parent = collection_source.dup_uid ();

            if (!child_source.has_extension (E.SOURCE_EXTENSION_AUTHENTICATION)) {
                /**
                 * Make sure the source has the Authentication extension,
                 * thus the credentials can be reused. It's fine when the extension
                 * doesn't have set values.
                */
                child_source.get_extension (E.SOURCE_EXTENSION_AUTHENTICATION);
            }

            unowned var webdav = (E.SourceWebdav) child_source.get_extension (E.SOURCE_EXTENSION_WEBDAV_BACKEND);
            webdav.calendar_auto_schedule = true;

            unowned var auth_extension = (E.SourceAuthentication) child_source.get_extension (E.SOURCE_EXTENSION_AUTHENTICATION);
            auth_extension.user = username_entry.text;

            unowned var offline = (E.SourceOffline) child_source.get_extension (E.SOURCE_EXTENSION_OFFLINE);
            offline.set_stay_synchronized (true);

            yield child_source.store_password (password_entry.text, true, cancellable);

            new_sources.append (child_source);
        }

        /* if we are editing an existing account, make sure we delete the collection source here */
        if (this.source != null) {
            yield this.source.remove (cancellable);
        }

        /* First store passwords, thus the evolution-source-registry has them ready if needed. */
        yield collection_source.store_password (password_entry.text, true, cancellable);
        yield registry.create_sources (new_sources, cancellable);
    }

    private class SourceRow : Gtk.ListBoxRow {
        public E.Source source { get; construct; }

        public SourceRow (E.Source source) {
            Object (source: source);
        }

        construct {
            var name_entry = new Gtk.Label (source.display_name);
            name_entry.get_style_context ().add_class (Granite.STYLE_CLASS_ACCENT);

            var grid = new Gtk.Grid () {
                column_spacing = 6,
                margin = 6
            };
            grid.add (name_entry);

            add (grid);

            unowned var webdav_source = (E.SourceWebdav) source.get_extension (E.SOURCE_EXTENSION_WEBDAV_BACKEND);

            style_calendar_color (name_entry, webdav_source.color);
        }

        private void style_calendar_color (Gtk.Widget widget, string color) {
            var css_color = "@define-color accent_color %s;".printf (color.slice (0, 7));

            var style_provider = new Gtk.CssProvider ();

            try {
                style_provider.load_from_data (css_color, css_color.length);
                widget.get_style_context ().add_provider (style_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            } catch (Error e) {
                warning ("Could not create CSS Provider: %s\nStylesheet:\n%s", e.message, css_color);
            }
        }
    }
}
