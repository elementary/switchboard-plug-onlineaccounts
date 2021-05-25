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

public class OnlineAccounts.MainView : Gtk.Grid {
    construct {
        var welcome = new Granite.Widgets.AlertView (
            _("Connect Your Online Accounts"),
            _("Connect online accounts by clicking the icon in the toolbar below."),
            "preferences-desktop-online-accounts"
        );
        welcome.show_all ();

        var listbox = new Gtk.ListBox ();
        listbox.set_placeholder (welcome);

        var scroll = new Gtk.ScrolledWindow (null, null) {
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            expand = true
        };
        scroll.add (listbox);

        var caldav_menuitem = new AccountMenuItem (
            "x-office-calendar",
            _("CalDAV"),
            _("Calendars and Tasks")
        );

        var icloud_menuitem = new AccountMenuItem (
            "onlineaccounts-icloud",
            _("iCloud"),
            _("Calendars and Mail")
        );

        var add_acount_grid = new Gtk.Grid () {
            margin_top = 3,
            margin_bottom = 3,
            orientation = Gtk.Orientation.VERTICAL
        };
        add_acount_grid.add (caldav_menuitem);
        add_acount_grid.add (icloud_menuitem);
        add_acount_grid.show_all ();

        var add_account_popover = new Gtk.Popover (null);
        add_account_popover.add (add_acount_grid);

        var add_button = new Gtk.MenuButton () {
            always_show_image = true,
            image = new Gtk.Image.from_icon_name ("list-add-symbolic", Gtk.IconSize.SMALL_TOOLBAR),
            label = _("Add Account…"),
            popover = add_account_popover
        };
        add_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        var action_bar = new Gtk.ActionBar ();
        action_bar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        action_bar.add (add_button);

        var grid = new Gtk.Grid ();
        grid.attach (scroll, 0, 0);
        grid.attach (action_bar, 0, 1);

        var frame = new Gtk.Frame (null) {
            margin = 12
        };
        frame.add (grid);

        add (frame);
        show_all ();

        caldav_menuitem.clicked.connect (() => {
            var caldav_dialog = new CaldavDialog () {
                transient_for = (Gtk.Window) get_toplevel ()
            };
            caldav_dialog.show_all ();
        });

        icloud_menuitem.clicked.connect (() => {
            var icloud_dialog = new ICloudDialog () {
                transient_for = (Gtk.Window) get_toplevel ()
            };
            icloud_dialog.show_all ();
        });
    }

    private class AccountMenuItem : Gtk.Button {
        public string icon_name { get; construct; }
        public string primary_label { get; construct; }
        public string secondary_label { get; construct; }

        public AccountMenuItem (string icon_name, string primary_label, string secondary_label) {
            Object (
                icon_name: icon_name,
                primary_label: primary_label,
                secondary_label: secondary_label
            );
        }

        class construct {
            set_css_name (Gtk.STYLE_CLASS_MENUITEM);
        }

        construct {
            var label = new Gtk.Label (primary_label) {
                halign = Gtk.Align.START
            };
            label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

            var description = new Gtk.Label (secondary_label) {
                halign = Gtk.Align.START
            };
            description.get_style_context ().add_class (Granite.STYLE_CLASS_SMALL_LABEL);

            var image = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.DND);

            var grid = new Gtk.Grid () {
                column_spacing = 6
            };
            grid.attach (image, 0, 0, 1, 2);
            grid.attach (label, 1, 0);
            grid.attach (description, 1, 1);

            add (grid);
        }
    }
}
