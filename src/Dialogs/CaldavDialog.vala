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

public class OnlineAccounts.CaldavDialog : PagedDialog {
    private GLib.Cancellable? cancellable;
    private Granite.ValidatedEntry url_entry;
    private Granite.ValidatedEntry username_entry;
    private Gtk.Button login_button;
    private Gtk.Button save_configuration_button;
    private Gtk.Entry display_name_entry;
    private Gtk.Entry password_entry;
    private Gtk.ListBox calendars_list;
    private Adw.NavigationPage calendars_page;
    private ListStore calendars_store;
    private ValidationMessage url_message_revealer;

    private E.SourceRegistry? registry = null;
    private E.Source? source = null;

    private uint source_children_configuration_timeout_id = 0;
    private uint source_children_configuration_count = 0;

    construct {
        url_entry = new Granite.ValidatedEntry () {
            hexpand = true,
            input_purpose = URL
        };
        url_entry.update_property (Gtk.AccessibleProperty.REQUIRED, true, -1);

        var url_label = new Granite.HeaderLabel (_("Server URL")) {
            mnemonic_widget = url_entry
        };

        url_message_revealer = new ValidationMessage (_("Invalid URL"));
        url_message_revealer.label_widget.add_css_class (Granite.STYLE_CLASS_ERROR);

        username_entry = new Granite.ValidatedEntry ();
        username_entry.update_property (Gtk.AccessibleProperty.REQUIRED, true, -1);

        var username_label = new Granite.HeaderLabel (_("User Name")) {
            mnemonic_widget = username_entry
        };

        password_entry = new Gtk.Entry () {
            activates_default = true,
            input_purpose = PASSWORD,
            visibility = false
        };

        var password_label = new Granite.HeaderLabel (_("Password")) {
            mnemonic_widget = password_entry
        };

        var login_cancel_button = new Gtk.Button.with_label (_("Cancel"));

        login_button = new Gtk.Button.with_label (_("Log In")) {
            sensitive = false
        };
        login_button.add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);

        var action_area = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            margin_top = 24,
            halign = END,
            valign = END,
            vexpand = true,
            homogeneous = true
        };
        action_area.add_css_class ("action-area");
        action_area.append (login_cancel_button);
        action_area.append (login_button);

        var login_box = new Gtk.Box (VERTICAL, 6);
        login_box.append (url_label);
        login_box.append (url_entry);
        login_box.append (url_message_revealer);
        login_box.append (username_label);
        login_box.append (username_entry);
        login_box.append (password_label);
        login_box.append (password_entry);
        login_box.append (action_area);

        var login_page = new Adw.NavigationPage (login_box, _("Log In"));

        display_name_entry = new Gtk.Entry () {
            activates_default = true,
            hexpand = true
        };

        var display_name_label = new Granite.HeaderLabel (_("Account Display Name")) {
            mnemonic_widget = display_name_entry,
            secondary_text = _("Pick a name like “Work” or “Personal” for the account.")
        };

        calendars_store = new ListStore (typeof (E.Source));

        calendars_list = new Gtk.ListBox () {
            hexpand = true,
            vexpand = true
        };
        calendars_list.set_header_func (header_func);
        calendars_list.set_sort_func (sort_func);
        calendars_list.bind_model (calendars_store, create_item);

        var calendars_scroll_window = new Gtk.ScrolledWindow () {
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            child = calendars_list
        };

        var calendar_list_frame = new Gtk.Frame (null) {
            margin_top = 18,
            child = calendars_scroll_window
        };

        var calendar_page_back_button = new Gtk.Button.with_label (_("Back"));

        save_configuration_button = new Gtk.Button.with_label (_("Save"));
        save_configuration_button.add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);

        var calendar_page_action_area = new Gtk.Box (HORIZONTAL, 0) {
            margin_top = 24,
            halign = END,
            homogeneous = true
        };
        calendar_page_action_area.add_css_class ("action-area");
        calendar_page_action_area.append (calendar_page_back_button);
        calendar_page_action_area.append (save_configuration_button);

        var calendars_box = new Gtk.Box (VERTICAL, 6);
        calendars_box.append (display_name_label);
        calendars_box.append (display_name_entry);
        calendars_box.append (calendar_list_frame);
        calendars_box.append (calendar_page_action_area);

        calendars_page = new Adw.NavigationPage (calendars_box, _("Calendars"));

        push_page (login_page);

        default_widget = login_button;

        calendars_page.shown.connect (() => {
            default_widget = save_configuration_button;
        });

        login_page.shown.connect (() => {
            default_widget = login_button;
        });

        login_cancel_button.clicked.connect (() => {
            destroy ();
        });

        login_button.clicked.connect (() => {
            find_sources.begin ();
            push_page (calendars_page);
        });

        save_configuration_button.clicked.connect (() => {
            var finalize_page = new FinalizePage (new ThemedIcon ("x-office-calendar"), cancellable);

            push_page (finalize_page);

            save_configuration.begin ((obj, res) => {
                try {
                    save_configuration.end (res);
                    finalize_page.show_success ();
                } catch (Error e) {
                    finalize_page.show_error (e.message);
                }
            });
        });

        calendar_page_back_button.clicked.connect (() => {
            if (cancellable != null) {
                cancellable.cancel ();
            }

            pop_page ();
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

        var key_controller = new Gtk.EventControllerKey ();
        ((Gtk.Widget)this).add_controller (key_controller);

        key_controller.key_released.connect ((keyval) => {
            if (keyval != Gdk.Key.Escape) {
                return;
            }

            if (cancellable != null) {
                cancellable.cancel ();
            }

            destroy ();
        });
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

        var placeholder = new Gtk.Box (HORIZONTAL, 6) {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };
        placeholder.append (placeholder_label);
        placeholder.append (spinner);

        calendars_list.set_placeholder (placeholder);
        calendars_store.remove_all ();

        try {
            var source = new E.Source (null, null);
            source.parent = "caldav-stub";

            unowned var col = (E.SourceCollection)source.get_extension (E.SOURCE_EXTENSION_COLLECTION);
            col.backend_name = "caldav";

            unowned var webdav = (E.SourceWebdav)source.get_extension (E.SOURCE_EXTENSION_WEBDAV_BACKEND);
#if HAS_EDS_3_45
            webdav.uri = Uri.parse (url_entry.text, UriFlags.PARSE_RELAXED);
#else
            webdav.soup_uri = new Soup.URI (url_entry.text);
#endif
            webdav.calendar_auto_schedule = true;

            unowned var auth = (E.SourceAuthentication)source.get_extension (E.SOURCE_EXTENSION_AUTHENTICATION);
            auth.user = username_entry.text;

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
            var error_placeholder = new Granite.Placeholder (_("Could not fetch calendars")) {
                description = e.message,
                icon = new ThemedIcon ("dialog-error")
            };
            Idle.add (() => {
                calendars_list.set_placeholder (error_placeholder);
                return Source.REMOVE;
            });
        }
    }

    private async E.Source[] find_sources_supporting (E.WebDAVDiscoverSupports only_supports, E.Source source, E.NamedParameters credentials, GLib.Cancellable? cancellable) throws Error {
        E.Source[] e_sources = {};
        GLib.Error? discover_error = null;

        source.webdav_discover_sources.begin (
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
                source.webdav_discover_sources.end (
                    res,
                    out certificate_pem,
                    out certificate_errors,
                    out discovered_sources,
                    out calendar_user_addresses
                );

                /** Get WebDAV host: This is used to check whether we are dealing with a calendar source
                * stored on the server itself or if its a subscription from a third party server. In case
                * we are dealing with a calendar subscription we are going to ignore it, because we can't
                * possibly know its credentials. So the user has to add any subscription in the corresponding
                * app manually.
                */
                string? webdav_host = null;
                if (source.has_extension (E.SOURCE_EXTENSION_WEBDAV_BACKEND)) {
                    unowned var webdav_extension = (E.SourceWebdav) source.get_extension (E.SOURCE_EXTENSION_WEBDAV_BACKEND);
#if HAS_EDS_3_45
                    webdav_host = webdav_extension.uri.get_host ();
#else
                    webdav_host = webdav_extension.soup_uri.host;
#endif
                }

                foreach (unowned E.WebDAVDiscoveredSource? disc_source in discovered_sources) {
                    if (disc_source == null || (only_supports & disc_source.supports) == 0 || webdav_host != null && !disc_source.href.contains (webdav_host)) {
                        continue;
                    }

                    var e_source = new E.Source (null, null) {
                        display_name = disc_source.display_name
                    };

                    unowned var webdav = (E.SourceWebdav) e_source.get_extension (E.SOURCE_EXTENSION_WEBDAV_BACKEND);
#if HAS_EDS_3_45
                    webdav.uri = Uri.parse (disc_source.href, UriFlags.PARSE_RELAXED);
#else
                    webdav.soup_uri = new Soup.URI (disc_source.href);
#endif
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
            throw new Camel.Error.ERROR_GENERIC (_("The data provided does not seem to reflect a valid CalDAV account."));
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
#if HAS_EDS_3_45
            url_entry.text = webdav_extension.uri.to_string ();

            unowned var uri_user = webdav_extension.uri.get_user ();
            if (uri_user != null && uri_user != "") {
                url_entry.text = url_entry.text.replace (uri_user + "@", "");
            }
#else
            url_entry.text = webdav_extension.soup_uri.to_string (false);

            if (webdav_extension.soup_uri.user != null && webdav_extension.soup_uri.user != "") {
                url_entry.text = url_entry.text.replace (webdav_extension.soup_uri.user + "@", "");
            }
#endif
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
        collection_extension.calendar_url = url_entry.text;
        collection_extension.identity = username_entry.text;

        unowned var authentication_extension = (E.SourceAuthentication) collection_source.get_extension (E.SOURCE_EXTENSION_AUTHENTICATION);
        authentication_extension.user = username_entry.text;

        unowned var webdav_extension = (E.SourceWebdav) collection_source.get_extension (E.SOURCE_EXTENSION_WEBDAV_BACKEND);
#if HAS_EDS_3_45
        try {
            webdav_extension.uri = Uri.parse (url_entry.text, UriFlags.PARSE_RELAXED);
        } catch (Error e) {
            warning ("Unable to save webdav extension: %s", e.message);
        }
#else
        webdav_extension.soup_uri = new Soup.URI (url_entry.text);
#endif
        webdav_extension.calendar_auto_schedule = true;

        unowned var offline_extension = (E.SourceOffline) collection_source.get_extension (E.SOURCE_EXTENSION_OFFLINE);
        offline_extension.stay_synchronized = true;

        unowned var refresh_extension = (E.SourceRefresh) collection_source.get_extension (E.SOURCE_EXTENSION_REFRESH);
        refresh_extension.enabled = true;
        refresh_extension.interval_minutes = 10;

        new_sources.append (collection_source);

        /* First store passwords, thus the evolution-source-registry has them ready if needed. */
        yield collection_source.store_password (password_entry.text, true, cancellable);
        yield registry.create_sources (new_sources, cancellable);

        /* The refresh_backend call runs in the background, so we need to watch out for source_added events to configure source children */
        source_children_configuration_count = 0;
        registry.source_added.connect (configure_source_child);

        /* Discovers all child sources and EDS automatically adds them */
        yield registry.refresh_backend (collection_source.uid, cancellable);
        yield await_source_children_configuration ();

        /* We no longer need to watch for newly added source children, therefore we can safely disconnect the handler again */
        registry.source_added.disconnect (configure_source_child);

        /* if we are editing an existing account, make sure we delete the old collection source at this point */
        if (this.source != null) {
            yield this.source.remove (cancellable);
        }
    }

    private void configure_source_child (E.Source source) {
        assert_nonnull (registry);
        var collection_source = registry.find_extension (source, E.SOURCE_EXTENSION_COLLECTION);

        if (collection_source != null) {
            /* Make sure all child sources use the same configuration as their collection source */

            if (collection_source.has_extension (E.SOURCE_EXTENSION_OFFLINE)) {
                unowned var collection_offline_extension = (E.SourceOffline) collection_source.get_extension (E.SOURCE_EXTENSION_OFFLINE);
                unowned var source_offline_extension = (E.SourceOffline) source.get_extension (E.SOURCE_EXTENSION_OFFLINE);

                source_offline_extension.stay_synchronized = collection_offline_extension.stay_synchronized;
            }

            if (collection_source.has_extension (E.SOURCE_EXTENSION_REFRESH)) {
                unowned var collection_refresh_extension = (E.SourceRefresh) collection_source.get_extension (E.SOURCE_EXTENSION_REFRESH);
                unowned var source_refresh_extension = (E.SourceRefresh) source.get_extension (E.SOURCE_EXTENSION_REFRESH);

                source_refresh_extension.enabled = collection_refresh_extension.enabled;
                source_refresh_extension.interval_minutes = collection_refresh_extension.interval_minutes;
            }

            try {
                registry.commit_source_sync (source, cancellable);
                debug ("Configured child source '%s'", source.display_name);

            } catch (Error e) {
                warning ("Configure child source '%s' failed: %s", source.display_name, e.message);
            }
        }

        source_children_configuration_count += 1;
    }

    private async void await_source_children_configuration () {
        var timeout_seconds = 15;
        var await_seconds = 0;

        source_children_configuration_timeout_id = Timeout.add_seconds (1, () => {
            await_seconds += 1;

            if (
                await_seconds > timeout_seconds ||
                source_children_configuration_count >= calendars_store.get_n_items ()
            ) {
                if (source_children_configuration_timeout_id > 0) {
                    Source.remove (source_children_configuration_timeout_id);
                }

                if (await_seconds > timeout_seconds) {
                    warning ("Timeout while waiting for the source children to be configured.");
                }

                await_source_children_configuration.callback ();

                return Source.REMOVE;
            }
            return Source.CONTINUE;
        });
        yield;
    }

    private class SourceRow : Gtk.ListBoxRow {
        public E.Source source { get; construct; }

        public SourceRow (E.Source source) {
            Object (source: source);
        }

        construct {
            var name_entry = new Gtk.Label (source.display_name);
            name_entry.add_css_class (Granite.STYLE_CLASS_ACCENT);

            var box = new Gtk.Box (HORIZONTAL, 6) {
                margin_top = 6,
                margin_bottom = 6,
                margin_start = 6,
                margin_end = 6
            };
            box.append (name_entry);

            child = box;

            unowned var webdav_source = (E.SourceWebdav) source.get_extension (E.SOURCE_EXTENSION_WEBDAV_BACKEND);

            style_calendar_color (name_entry, webdav_source.color);
        }

        private void style_calendar_color (Gtk.Widget widget, string color) {
            var css_color = "@define-color accent_color %s;".printf (color.slice (0, 7));

            var style_provider = new Gtk.CssProvider ();

            style_provider.load_from_data ((uint8[]) css_color);
            widget.get_style_context ().add_provider (style_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        }
    }
}
