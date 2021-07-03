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
    private static AccountsModel accountsmodel;

    static construct {
        accountsmodel = new AccountsModel ();
    }

    construct {
        var welcome = new Granite.Widgets.AlertView (
            _("Connect Your Online Accounts"),
            _("Connect online accounts by clicking the icon in the toolbar below."),
            "preferences-desktop-online-accounts"
        );
        welcome.show_all ();

        var listbox = new Gtk.ListBox ();
        listbox.bind_model (accountsmodel.accounts_liststore, create_account_row);
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

        var imap_menuitem = new AccountMenuItem (
            "onlineaccounts-mail",
            _("IMAP"),
            _("Mail")
        );

        var add_acount_grid = new Gtk.Grid () {
            margin_top = 3,
            margin_bottom = 3,
            orientation = Gtk.Orientation.VERTICAL
        };
        add_acount_grid.add (caldav_menuitem);
        add_acount_grid.add (imap_menuitem);
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

        imap_menuitem.clicked.connect (() => {
            var imap_dialog = new ImapDialog () {
                transient_for = (Gtk.Window) get_toplevel ()
            };
            imap_dialog.show_all ();
        });
    }

    private Gtk.Widget create_account_row (GLib.Object object) {
        var e_source = (E.Source) object;

        var icon_name = "onlineaccounts";
        if (e_source.has_extension (E.SOURCE_EXTENSION_TASK_LIST)) {
            icon_name = "onlineaccounts-tasks";
        } else if (e_source.has_extension (E.SOURCE_EXTENSION_CALENDAR)) {
            icon_name = "x-office-calendar";
        } else if (e_source.has_extension (E.SOURCE_EXTENSION_MAIL_ACCOUNT)) {
            icon_name = "onlineaccounts-mail";
        } else if (e_source.has_extension (E.SOURCE_EXTENSION_COLLECTION)) {
            unowned var collection_source = (E.SourceCollection) e_source.get_extension (E.SOURCE_EXTENSION_COLLECTION);
            icon_name = "onlineaccounts-%s".printf (collection_source.backend_name);
        }

        var label = new Gtk.Label (e_source.display_name) {
            halign = Gtk.Align.START,
            hexpand = true
        };
        label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

        var image = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.DND) {
            use_fallback = true
        };

        var remove_button = new Gtk.Button.from_icon_name ("edit-delete-symbolic", Gtk.IconSize.MENU) {
            tooltip_text = _("Remove this account")
        };
        remove_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        var grid = new Gtk.Grid () {
            column_spacing = 6,
            margin = 6
        };
        grid.attach (image, 0, 0);
        grid.attach (label, 1, 0);
        grid.attach (remove_button, 2, 0);
        grid.show_all ();

        remove_button.clicked.connect (() => {
            var message_dialog = new Granite.MessageDialog (
                _("Remove “%s” from this device").printf (e_source.display_name),
                _("This account will be removed, and no longer appear in apps on this device."),
                new ThemedIcon.with_default_fallbacks (icon_name),
                Gtk.ButtonsType.CANCEL
            ) {
                badge_icon = new ThemedIcon ("edit-delete"),
                transient_for = (Gtk.Window) get_toplevel ()
            };

            var accept_button = (Gtk.Button) message_dialog.add_button (_("Remove Account"), Gtk.ResponseType.ACCEPT);
            accept_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);

            if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {
                e_source.remove.begin (null);
            }

            message_dialog.destroy ();
        });

        return grid;
    }
}
