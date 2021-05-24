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
    private Gtk.Button find_calendars_button;
    private ListStore calendars_store;
    private Gtk.ListBox calendars_list;
    private Granite.ValidatedEntry url_entry;
    private Granite.ValidatedEntry username_entry;
    private Gtk.Entry password_entry;
    private GLib.Cancellable? cancellable;

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
            visibility = false
        };

        var cancel_button = new Gtk.Button.with_label (_("Cancel"));

        find_calendars_button = new Gtk.Button.with_label (_("Find Calendars")) {
            can_default = true,
            sensitive = false
        };
        find_calendars_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

        var action_area = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
            layout_style = Gtk.ButtonBoxStyle.END,
            margin_top = 24,
            spacing = 6,
            valign = Gtk.Align.END,
            vexpand = true
        };
        action_area.add (cancel_button);
        action_area.add (find_calendars_button);

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

        calendars_store = new ListStore (typeof(FoundCalendar));

        calendars_list = new Gtk.ListBox () {
            expand = true
        };
        calendars_list.bind_model (calendars_store, create_item);
        calendars_list.set_sort_func (sort_func);

        var calendar_list_frame = new Gtk.Frame (null);
        calendar_list_frame.add (calendars_list);

        var back_button = new Gtk.Button.with_label (_("Back"));

        var finish_button = new Gtk.Button.with_label (_("Add Calendars"));
        finish_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

        var calendar_page_action_area = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
            layout_style = Gtk.ButtonBoxStyle.END,
            margin_top = 24,
            spacing = 6
        };
        calendar_page_action_area.add (back_button);
        calendar_page_action_area.add (finish_button);

        var calendars_page = new Gtk.Grid () {
            margin = 12
        };
        calendars_page.attach (calendar_list_frame, 0, 0);
        calendars_page.attach (calendar_page_action_area, 0, 1);

        var deck = new Hdy.Deck () {
            can_swipe_back = true,
            expand = true
        };
        deck.add (login_page);
        deck.add (calendars_page);

        var window_handle = new Hdy.WindowHandle ();
        window_handle.add (deck);

        default_height = 400;
        default_width = 300;
        window_position = Gtk.WindowPosition.CENTER_ON_PARENT;
        modal = true;
        add (window_handle);

        cancel_button.clicked.connect (() => {
            destroy ();
        });

        find_calendars_button.clicked.connect (() => {
            find_calendars ();
            deck.visible_child = calendars_page;
        });

        back_button.clicked.connect (() => {
            deck.navigate (Hdy.NavigationDirection.BACK);
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

            validate_form ();
        });
    }

    private int sort_func (Gtk.ListBoxRow row1, Gtk.ListBoxRow row2) {
        var cal_row1 = (CalendarRow) row1;
        var cal_row2 = (CalendarRow) row2;

        return cal_row1.label.collate (cal_row2.label);
    }

    private void validate_form () {
        find_calendars_button.sensitive = url_entry.is_valid && username_entry.is_valid;
    }

    private bool is_valid_url (string uri) {
        var scheme = Uri.parse_scheme (uri);
        if (scheme == null) {
            return false;
        }

        return scheme.has_prefix ("http");
    }

    private class FoundCalendar : GLib.Object {
        public string name;
        public string href;
        public string? color;
        public FoundCalendar (string name, string href, string? color) {
            this.name = name;
            this.href = href;
            this.color = color;
        }
    }

    [ CCode ( instance_pos = 1.9 ) ]
    public Gtk.Widget create_item (GLib.Object item)  {
        unowned FoundCalendar cal = (FoundCalendar)item;
        var row = new CalendarRow (cal.name, cal.color);
        row.show_all ();
        return row;
    }

    private void find_calendars () {
        if (cancellable != null) {
            cancellable.cancel ();
        }

        cancellable = new GLib.Cancellable ();

        var placeholder_label = new Gtk.Label (_("Retrieving the list of available calendars…"));

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

            unowned var cal = (E.SourceCalendar)source.get_extension (E.SOURCE_EXTENSION_CALENDAR);
            cal.backend_name = "caldav";

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

            E.webdav_discover_sources.begin (source, null, E.WebDAVDiscoverSupports.CALENDAR_AUTO_SCHEDULE, credentials, cancellable, (obj, res) => {
                string certificate_pem;
                GLib.TlsCertificateFlags certificate_errors;
                GLib.SList<E.WebDAVDiscoveredSource?> discovered_sources;
                GLib.SList<string> calendar_user_addresses;
                cancellable = null;
                try {
                    E.webdav_discover_sources_finish (source, res, out certificate_pem, out certificate_errors, out discovered_sources, out calendar_user_addresses);
                    FoundCalendar[] calendars = {};
                    foreach (unowned E.WebDAVDiscoveredSource? disc_source in discovered_sources) {
                        calendars += new FoundCalendar (disc_source.display_name, disc_source.href, disc_source.color);
                    }
                    E.webdav_discover_do_free_discovered_sources ((owned) discovered_sources);
                    Idle.add (() => {
                        calendars_store.splice (0, 0, (Object[]) calendars);
                        return Source.REMOVE;
                    });
                } catch (GLib.IOError.CANCELLED e) {
                } catch (Error e) {
                    var error_placeholder = new Granite.Widgets.AlertView (
                        _("Error Fetching Calendars"),
                        e.message,
                        "dialog-error"
                    );
                    Idle.add (() => {
                        error_placeholder.show_all ();
                        calendars_list.set_placeholder (error_placeholder);
                        return Source.REMOVE;
                    });
                }
            });
        } catch (GLib.Error error) {
            critical (error.message);
        }
    }

    private class CalendarRow : Gtk.ListBoxRow {
        public string color { get; construct; }
        public string label { get; construct; }

        public CalendarRow (string label, string color) {
            Object (
                color: color.slice (0, 7),
                label: label
            );
        }

        construct {
            var checkbox = new Gtk.CheckButton () {
                active = true,
                margin_end = 6
            };

            var name_entry = new Gtk.Entry () {
                hexpand = true,
                placeholder_text = _("Calendar Name"),
                text = label
            };
            name_entry.get_style_context ().add_class (Granite.STYLE_CLASS_ACCENT);

            var grid = new Gtk.Grid () {
                column_spacing = 6,
                margin = 6,
                margin_start = 12
            };
            grid.add (checkbox);
            grid.add (name_entry);

            add (grid);

            style_calendar_color (checkbox, color);
            style_calendar_color (name_entry, color);

            checkbox.bind_property ("active", name_entry, "sensitive");
        }

        private void style_calendar_color (Gtk.Widget widget, string color) {
            var css_color = "@define-color accent_color %s;".printf (color);

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
