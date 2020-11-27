/*
* Copyright 2020 elementary, Inc. (https://elementary.io)
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

public class CaldavView : Gtk.Grid {
    private Gtk.Button find_calendars_button;
    private ListStore calendars_store;
    private Gtk.ListBox calendars_list;
    private ValidatedEntry url_entry;
    private ValidatedEntry username_entry;
    private Gtk.Entry password_entry;
    private GLib.Cancellable? cancellable;

    construct {
        var url_label = new Granite.HeaderLabel ("Server URL");
        url_entry = new ValidatedEntry ();

        var url_message_revealer = new ValidationMessage ("Invalid URL");
        url_message_revealer.label_widget.get_style_context ().add_class (Gtk.STYLE_CLASS_ERROR);

        var username_label = new Granite.HeaderLabel ("User Name");
        username_entry = new ValidatedEntry ();

        var password_label = new Granite.HeaderLabel ("Password");
        password_entry = new Gtk.Entry () {
            visibility = false
        };

        find_calendars_button = new Gtk.Button.with_label ("Find Calendars") {
            can_default = true,
            halign = Gtk.Align.END,
            valign = Gtk.Align.END,
            vexpand = true,
            sensitive = false
        };

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
        login_page.add (find_calendars_button);

        var back_button = new Gtk.Button.with_label ("Back") {
            halign = Gtk.Align.START,
            margin = 6
        };
        back_button.get_style_context ().add_class (Granite.STYLE_CLASS_BACK_BUTTON);

        calendars_store = new ListStore (typeof(FoundCalendar));
        calendars_list = new Gtk.ListBox () {
            expand = true,
            margin_top = 6
        };
        calendars_list.bind_model (calendars_store, create_item);

        var finish_button = new Gtk.Button.with_label ("Add Calendars") {
            halign = Gtk.Align.END,
            margin = 12
        };

        var calendars_page = new Gtk.Grid ();
        calendars_page.attach (back_button, 0, 0);
        calendars_page.attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 0, 1);
        calendars_page.attach (calendars_list, 0, 2);
        calendars_page.attach (finish_button, 0, 3);

        var deck = new Hdy.Deck () {
            can_swipe_back = true,
            expand = true
        };
        deck.add (login_page);
        deck.add (calendars_page);

        add (deck);

        // mark as default
        // use offline
        // email
        // server handles invitations
        // refresh rate

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
        var placeholder = new Granite.Widgets.AlertView (
            "Fetching Calendars",
            "Retrieving the list of available calendars…",
            "view-refresh"
        );
        placeholder.show_all ();
        calendars_list.set_placeholder (placeholder);
        calendars_store.remove_all ();

        try {
            var source = new E.Source (null, null);
            source.parent = "caldav-stub";
            unowned var cal = (E.SourceCalendar)source.get_extension (E.SOURCE_EXTENSION_CALENDAR);
            //cal.color = color;
            cal.backend_name = "caldav";
            unowned var webdav = (E.SourceWebdav)source.get_extension (E.SOURCE_EXTENSION_WEBDAV_BACKEND);
            webdav.soup_uri = new Soup.URI (url_entry.text);
            //webdav.email_address = ((Gtk.Entry)widget.widget).text;
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
                        "Error Fetching Calendars",
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

        /*var registry = new SourceRegistry.sync (null);
        var list = new List<E.Source> ();
        list.append (source);
        registry.create_sources_sync (list);*/
    }

    private class CalendarRow : Gtk.ListBoxRow {
        public string color { get; construct; }
        public string label { get; construct; }

        public CalendarRow (string label, string color) {
            Object (
                color: color,
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
                placeholder_text = "Calendar Name",
                text = label
            };
            name_entry.get_style_context ().add_class (Granite.STYLE_CLASS_ACCENT);

            var color_button_blue = new Gtk.RadioButton (null);

            unowned Gtk.StyleContext color_button_blue_context = color_button_blue.get_style_context ();
            color_button_blue_context.add_class (Granite.STYLE_CLASS_COLOR_BUTTON);
            color_button_blue_context.add_class ("blue");

            var color_button_mint = new Gtk.RadioButton.from_widget (color_button_blue);

            unowned Gtk.StyleContext color_button_mint_context = color_button_mint.get_style_context ();
            color_button_mint_context.add_class (Granite.STYLE_CLASS_COLOR_BUTTON);
            color_button_mint_context.add_class ("mint");

            var color_button_green = new Gtk.RadioButton.from_widget (color_button_blue);

            unowned Gtk.StyleContext color_button_green_context = color_button_green.get_style_context ();
            color_button_green_context.add_class (Granite.STYLE_CLASS_COLOR_BUTTON);
            color_button_green_context.add_class ("green");

            var color_button_yellow = new Gtk.RadioButton.from_widget (color_button_blue);

            unowned Gtk.StyleContext color_button_yellow_context = color_button_yellow.get_style_context ();
            color_button_yellow_context.add_class (Granite.STYLE_CLASS_COLOR_BUTTON);
            color_button_yellow_context.add_class ("yellow");

            var color_button_orange = new Gtk.RadioButton.from_widget (color_button_blue);

            unowned Gtk.StyleContext color_button_orange_context = color_button_orange.get_style_context ();
            color_button_orange_context.add_class (Granite.STYLE_CLASS_COLOR_BUTTON);
            color_button_orange_context.add_class ("orange");

            var color_button_red = new Gtk.RadioButton.from_widget (color_button_blue);

            unowned Gtk.StyleContext color_button_red_context = color_button_red.get_style_context ();
            color_button_red_context.add_class (Granite.STYLE_CLASS_COLOR_BUTTON);
            color_button_red_context.add_class ("red");

            var color_button_pink = new Gtk.RadioButton.from_widget (color_button_blue);

            var color_button_pink_context = color_button_pink.get_style_context ();
            color_button_pink_context.add_class (Granite.STYLE_CLASS_COLOR_BUTTON);
            color_button_pink_context.add_class ("pink");

            var color_button_purple = new Gtk.RadioButton.from_widget (color_button_blue);

            unowned Gtk.StyleContext color_button_purple_context = color_button_purple.get_style_context ();
            color_button_purple_context.add_class (Granite.STYLE_CLASS_COLOR_BUTTON);
            color_button_purple_context.add_class ("purple");

            var color_button_brown = new Gtk.RadioButton.from_widget (color_button_blue);

            unowned Gtk.StyleContext color_button_brown_context = color_button_brown.get_style_context ();
            color_button_brown_context.add_class (Granite.STYLE_CLASS_COLOR_BUTTON);
            color_button_brown_context.add_class ("brown");

            var color_button_slate = new Gtk.RadioButton.from_widget (color_button_blue);

            unowned Gtk.StyleContext color_button_slate_context = color_button_slate.get_style_context ();
            color_button_slate_context.add_class (Granite.STYLE_CLASS_COLOR_BUTTON);
            color_button_slate_context.add_class ("slate");

            var color_grid = new Gtk.Grid () {
                column_spacing = 3,
                margin = 12
            };
            color_grid.add (color_button_blue);
            color_grid.add (color_button_mint);
            color_grid.add (color_button_green);
            color_grid.add (color_button_yellow);
            color_grid.add (color_button_orange);
            color_grid.add (color_button_red);
            color_grid.add (color_button_pink);
            color_grid.add (color_button_purple);
            color_grid.add (color_button_brown);
            color_grid.add (color_button_slate);
            color_grid.show_all ();

            var popover = new Gtk.Popover (null);
            popover.add (color_grid);

            var more_menubutton = new Gtk.MenuButton () {
                image = new Gtk.Image.from_icon_name ("view-more-symbolic", Gtk.IconSize.BUTTON),
                popover = popover,
                tooltip_text = "Options"
            };

            var grid = new Gtk.Grid () {
                column_spacing = 6,
                margin = 6,
                margin_start = 12
            };
            grid.add (checkbox);
            grid.add (name_entry);
            grid.add (more_menubutton);

            add (grid);

            color = color.slice (0, 7);
            switch (color.down ()) {
                case "#e6a92a":
                    color_button_yellow.active = true;
                    break;
                case "#81c837":
                    color_button_green.active = true;
                    break;
                case "#a56de2":
                    color_button_purple.active = true;
                    break;
                case "#de3e80":
                    color_button_pink.active = true;
                    break;
            }
            style_calendar_color (checkbox, color);
            style_calendar_color (name_entry, color);

            checkbox.bind_property ("active", name_entry, "sensitive");
            checkbox.bind_property ("active", more_menubutton, "sensitive");
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

    private class ValidatedEntry : Gtk.Entry {
        public bool is_valid { get; set; default = false; }

        construct {
            hexpand = true;
            activates_default = true;

            changed.connect_after (() => {
                if (is_valid) {
                    secondary_icon_name = "process-completed-symbolic";
                } else if (text != null && text != "") {
                    secondary_icon_name = "process-error-symbolic";
                } else {
                    secondary_icon_name = "";
                }
            });
        }
    }
}
