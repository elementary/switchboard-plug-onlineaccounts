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

public class OnlineAccounts.MainView : Switchboard.SettingsPage {
    private static AccountsModel accountsmodel;

    public MainView () {
        Object (
            icon: new ThemedIcon ("io.elementary.settings.onlineaccounts"),
            title: _("Online Accounts")
        );
    }

    static construct {
        accountsmodel = new AccountsModel ();
    }

    construct {
        var welcome = new Granite.Placeholder (_("Connect Your Online Accounts")) {
            description = _("Connect online accounts by clicking the icon in the toolbar below.")
        };

        var listbox = new Gtk.ListBox ();
        listbox.bind_model (accountsmodel.accounts_liststore, create_account_row);
        listbox.set_placeholder (welcome);

        var scroll = new Gtk.ScrolledWindow () {
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            hexpand = true,
            vexpand = true,
            child = listbox
        };

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

        var webdav_menuitem = new AccountMenuItem (
            "folder-remote",
            _("WebDAV"),
            _("Files")
        );

        var add_acount_box = new Gtk.Box (VERTICAL, 0) {
            margin_top = 3,
            margin_bottom = 3
        };
        add_acount_box.append (caldav_menuitem);
        add_acount_box.append (imap_menuitem);
        add_acount_box.append (webdav_menuitem);

        var add_account_popover = new Gtk.Popover () {
            child = add_acount_box
        };

        var add_button_content = new Gtk.Box (HORIZONTAL, 3);
        add_button_content.append (new Gtk.Image.from_icon_name ("list-add-symbolic"));
        add_button_content.append (new Gtk.Label (_("Add Account…")));

        var add_button = new Gtk.MenuButton () {
            popover = add_account_popover,
            direction = UP,
            has_frame = false,
            child = add_button_content,
            margin_top = 3
        };
        add_button.add_css_class (Granite.STYLE_CLASS_FLAT);

        var action_bar = new Gtk.ActionBar ();
        action_bar.add_css_class (Granite.STYLE_CLASS_FLAT);
        action_bar.pack_start (add_button);

        var grid = new Gtk.Grid ();
        grid.attach (scroll, 0, 0);
        grid.attach (action_bar, 0, 1);

        var frame = new Gtk.Frame (null) {
            child = grid
        };

        child = frame;

        caldav_menuitem.clicked.connect (() => {
            add_account_popover.popdown ();
            var caldav_dialog = new CaldavDialog () {
                transient_for = (Gtk.Window) get_root ()
            };
            caldav_dialog.present ();
        });

        imap_menuitem.clicked.connect (() => {
            add_account_popover.popdown ();
            var imap_dialog = new ImapDialog () {
                transient_for = (Gtk.Window) get_root ()
            };
            imap_dialog.present ();
        });

        webdav_menuitem.clicked.connect (() => {
            add_account_popover.popdown ();
            var wevdav_dialog = new WebDavDialog () {
                transient_for = (Gtk.Window) get_root ()
            };
            wevdav_dialog.present ();
        });
    }

    private Gtk.Widget create_account_row (GLib.Object object) {
        var e_source = (E.Source) object;

        var icon_name = "io.elementary.settings.onlineaccounts";
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
        label.add_css_class (Granite.STYLE_CLASS_H3_LABEL);

        var image = new Gtk.Image.from_icon_name (icon_name) {
            use_fallback = true
        };
        image.add_css_class (Granite.STYLE_CLASS_LARGE_ICONS);

        var remove_button = new Gtk.Button.from_icon_name ("edit-delete-symbolic") {
            tooltip_text = _("Remove this account")
        };
        remove_button.add_css_class (Granite.STYLE_CLASS_FLAT);

        Gtk.Button? edit_button = null;
        if (
            e_source.has_extension (E.SOURCE_EXTENSION_MAIL_ACCOUNT) ||
            (
                e_source.has_extension (E.SOURCE_EXTENSION_COLLECTION) &&
                "webdav" == ((E.SourceCollection) e_source.get_extension (E.SOURCE_EXTENSION_COLLECTION)).backend_name
            )
        ) {
            edit_button = new Gtk.Button.from_icon_name ("edit-symbolic") {
                tooltip_text = _("Edit this account")
            };
            edit_button.add_css_class (Granite.STYLE_CLASS_FLAT);
        }

        var grid = new Gtk.Grid () {
            column_spacing = 6,
            margin_top = 6,
            margin_bottom = 6,
            margin_start = 6,
            margin_end = 6
        };

        grid.attach (image, 0, 0);
        grid.attach (label, 1, 0);
        if (edit_button != null) {
            grid.attach (edit_button, 2, 0);
            grid.attach (remove_button, 3, 0);

        } else {
            grid.attach (remove_button, 2, 0);
        }

        remove_button.clicked.connect (() => {
            var message_dialog = new Granite.MessageDialog (
                _("Remove “%s” from this device").printf (e_source.display_name),
                _("This account will be removed and no longer appear in any apps on this device."),
                new ThemedIcon.with_default_fallbacks (icon_name),
                Gtk.ButtonsType.CANCEL
            ) {
                badge_icon = new ThemedIcon ("edit-delete"),
                transient_for = (Gtk.Window) get_root ()
            };

            var accept_button = (Gtk.Button) message_dialog.add_button (_("Remove Account"), Gtk.ResponseType.ACCEPT);
            accept_button.add_css_class (Granite.STYLE_CLASS_DESTRUCTIVE_ACTION);

            message_dialog.response.connect ((res) => {
                if (res == Gtk.ResponseType.ACCEPT) {
                    e_source.remove.begin (null);
                }
                message_dialog.destroy ();
            });

            message_dialog.present ();
        });

        if (edit_button != null) {
            edit_button.clicked.connect (() => {
                if (e_source.has_extension (E.SOURCE_EXTENSION_MAIL_ACCOUNT)) {
                    var imap_dialog = new ImapDialog () {
                        transient_for = (Gtk.Window) get_root ()
                    };

                    imap_dialog.load_configuration.begin (e_source, null, (obj, res) => {
                        try {
                            imap_dialog.load_configuration.end (res);
                            imap_dialog.present ();
                        } catch (Error e) {
                            var error_dialog = new Granite.MessageDialog (
                                _("Edit account failed"),
                                _("There was an unexpected error while reading the configuration of '%s'.").printf (e_source.display_name),
                                new ThemedIcon.with_default_fallbacks (icon_name),
                                Gtk.ButtonsType.CLOSE
                            ) {
                                badge_icon = new ThemedIcon ("dialog-error"),
                                transient_for = (Gtk.Window) get_root ()
                            };
                            error_dialog.show_error_details (e.message);
                            error_dialog.response.connect (error_dialog.destroy);
                            error_dialog.present ();
                        }
                    });

                } else if (e_source.has_extension (E.SOURCE_EXTENSION_COLLECTION)) {
                    unowned var collection_extension = (E.SourceCollection) e_source.get_extension (E.SOURCE_EXTENSION_COLLECTION);

                    if ("webdav" == collection_extension.backend_name) {
                        var caldav_dialog = new CaldavDialog () {
                            transient_for = (Gtk.Window) get_root ()
                        };

                        caldav_dialog.load_configuration.begin (e_source, null, (obj, res) => {
                            try {
                                caldav_dialog.load_configuration.end (res);
                                caldav_dialog.present ();
                            } catch (Error e) {
                                var error_dialog = new Granite.MessageDialog (
                                    _("Edit account failed"),
                                    _("There was an unexpected error while reading the configuration of '%s'.").printf (e_source.display_name),
                                    new ThemedIcon.with_default_fallbacks (icon_name),
                                    Gtk.ButtonsType.CLOSE
                                ) {
                                    badge_icon = new ThemedIcon ("dialog-error"),
                                    transient_for = (Gtk.Window) get_root ()
                                };
                                error_dialog.show_error_details (e.message);
                                error_dialog.response.connect (error_dialog.destroy);
                                error_dialog.present ();
                            }
                        });
                    }
                }
            });
        }

        return grid;
    }
}
