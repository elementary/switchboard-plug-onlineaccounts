/*
 * Copyright 2013-2018 elementary, Inc. (https://elementary.io)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
 *
 * Authored by: Corentin Noël <corentin@elementary.io>
 */

namespace OnlineAccounts {
    public static Plug plug;

    public class Plug : Switchboard.Plug {
        public signal void hide_request ();

        private Gtk.Stack stack;
        private Gtk.Grid grid;
        private Gtk.Grid main_grid;
        private AccountView account_view;
        private SourceSelector source_selector;
        private OnlineAccounts.Server oa_server;

        public Plug () {
            var settings = new Gee.TreeMap<string, string?> (null, null);
            settings.set ("accounts/online", null);
            Object (category: Category.NETWORK,
                    code_name: "io.elementary.switchboard.onlineaccounts",
                    display_name: _("Online Accounts"),
                    description: _("Manage online accounts and connected applications"),
                    icon: "preferences-desktop-online-accounts",
                    supported_settings: settings);
            plug = this;
        }

        public override Gtk.Widget get_widget () {
            if (stack == null) {
                var toast = new Granite.Widgets.Toast ("");
                toast.set_default_action (_("Restore"));

                grid = new Gtk.Grid () {
                    expand = true
                };

                source_selector = new SourceSelector ();

                var welcome = new Granite.Widgets.AlertView (
                    _("Connect Your Online Accounts"),
                    _("Connect online accounts by clicking the icon in the toolbar below."),
                    "preferences-desktop-online-accounts"
                );
                welcome.get_style_context ().remove_class (Gtk.STYLE_CLASS_VIEW);

                stack = new Gtk.Stack ();
                stack.add_named (welcome, "welcome");
                stack.add_named (grid, "main");

                var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL) {
                    position = 200
                };
                paned.pack1 (source_selector, false, false);
                paned.pack2 (stack, true, false);

                var overlay = new Gtk.Overlay ();
                overlay.add (paned);
                overlay.add_overlay (toast);

                main_grid = new Gtk.Grid ();
                main_grid.add (overlay);
                main_grid.show_all ();

                toast.closed.connect (() => {
                    AccountsManager.get_default ().remove_cached_account ();
                });

                toast.default_action.connect (() => {
                    AccountsManager.get_default ().restore_cached_account ();
                });

                source_selector.account_selected.connect ((account) => {
                    account_selected (account);
                });

                oa_server = new OnlineAccounts.Server ();
                var accounts_manager = AccountsManager.get_default ();

                var account = source_selector.get_selected_account ();
                if (account != null) {
                    account_selected (account);
                }

                accounts_manager.account_removed.connect ((account) => {
                    var account_name = account.ag_account.get_display_name () ?? _("New Account");

                    toast.title = _("Account '%s' Removed.").printf (account_name);
                    toast.send_notification ();

                    if (AccountsManager.get_default ().accounts_available.size <= 0) {
                        stack.set_visible_child_name ("welcome");
                    }
                });
            }

            return main_grid;
        }

        public override void shown () {
        }

        public override void hidden () {
            hide_request ();
            AccountsManager.get_default ().remove_cached_account ();
        }

        public override void search_callback (string location) {
        }

        // 'search' returns results like ("Keyboard → Behavior → Duration", "keyboard<sep>behavior")
        public override async Gee.TreeMap<string, string> search (string search) {
            return new Gee.TreeMap<string, string> (null, null);
        }

        private void account_selected (OnlineAccounts.Account account) {
            if (account_view != null) {
                account_view.hide ();
            }

            if (AccountsManager.get_default ().accounts_available.size <= 0) {
                return;
            }

            if (source_selector.get_selected_account () == null) {
                return;
            }

            account_view = new AccountView (account);
            grid.attach (account_view, 0, 0, 1, 1);
            account_view.show_all ();

            switch_to_main ();
        }

        public void switch_to_widget (string name) {
            stack.set_visible_child_name (name);
        }

        public void switch_to_main () {
            if (AccountsManager.get_default ().accounts_available.size <= 0) {
                stack.set_visible_child_name ("welcome");
                return;
            }

            stack.set_visible_child_name ("main");
        }
    }
}

public Switchboard.Plug get_plug (Module module) {
    debug ("Activating Online Accounts plug");
    var plug = new OnlineAccounts.Plug ();
    return plug;
}
