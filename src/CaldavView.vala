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
    construct {
        var url_label = new Granite.HeaderLabel ("Server URL");
        var url_entry = new ValidatedEntry ();

        var url_message_revealer = new ValidationMessage (".");
        url_message_revealer.label_widget.get_style_context ().add_class (Gtk.STYLE_CLASS_ERROR);

        var username_label = new Granite.HeaderLabel ("User Name");
        var username_entry = new ValidatedEntry ();

        var password_label = new Granite.HeaderLabel ("Password");
        var password_entry = new ValidatedEntry ();

        var find_calendars_button = new Gtk.Button.with_label ("Find Calendars") {
            halign = Gtk.Align.END
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

        var calendars_list = new Gtk.ListBox () {
            margin_top = 6
        };
        calendars_list.add (new CalendarRow ("Home", "purple"));
        calendars_list.add (new CalendarRow ("Work", "green"));
        calendars_list.add (new CalendarRow ("Family", "yellow"));
        calendars_list.add (new CalendarRow ("Hobby", "pink"));

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
            deck.visible_child = calendars_page;
        });

        back_button.clicked.connect (() => {
            deck.navigate (Hdy.NavigationDirection.BACK);
        });
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
            name_entry.get_style_context ().add_class (color);

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

            switch (color) {
                case "yellow":
                    color_button_yellow.active = true;
                    style_calendar_color (checkbox, "#e6a92a");
                    break;
                case "green":
                    color_button_green.active = true;
                    style_calendar_color (checkbox, "#81c837");
                    break;
                case "purple":
                    color_button_purple.active = true;
                    style_calendar_color (checkbox, "#a56de2");
                    break;
                case "pink":
                    color_button_pink.active = true;
                    style_calendar_color (checkbox, "#de3e80");
                    break;
            }

            checkbox.bind_property ("active", name_entry, "sensitive");
            checkbox.bind_property ("active", more_menubutton, "sensitive");
        }

        private void style_calendar_color (Gtk.CheckButton checkbutton, string color) {
            var css_color = "@define-color accent_color %s;".printf (color);

            var style_provider = new Gtk.CssProvider ();

            try {
                style_provider.load_from_data (css_color, css_color.length);
                checkbutton.get_style_context ().add_provider (style_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
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
        }
    }
}
