// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2013 Pantheon Developers (http://launchpad.net/online-accounts-plug)
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
 * Authored by: Corentin Noël <tintou@mailoo.org>
 */
namespace OnlineAccounts {

    public static Plug plug;
    public class Plug : Switchboard.Plug {
        public signal void hide_request ();

        Gtk.Stack stack;
        Gtk.Grid grid;
        Gtk.Grid main_grid;
        AccountView account_view;
        SourceSelector source_selector;
        Gtk.Paned paned;
        OnlineAccounts.Server oa_server;
        Gtk.InfoBar infobar;
        Gee.HashMap<int, Ag.Provider> providers_map;
        private Granite.Widgets.Toast toast;
        Granite.Widgets.Welcome welcome;

        public Plug () {
            var settings = new Gee.TreeMap<string, string?> (null, null);
            settings.set ("accounts/online", null);
            Object (category: Category.NETWORK,
                    code_name: "network-pantheon-online-accounts",
                    display_name: _("Online Accounts"),
                    description: _("Manage online accounts and connected applications"),
                    icon: "preferences-desktop-online-accounts",
                    supported_settings: settings);
            providers_map = new Gee.HashMap<int, Ag.Provider> (null, null);
            plug = this;
        }

        public override Gtk.Widget get_widget () {
            if (stack == null) {
                toast = new Granite.Widgets.Toast ("");
                toast.set_default_action (_("Restore"));

                var info_label = new Gtk.Label (_("Add a new account…"));
                info_label.show ();

                infobar = new Gtk.InfoBar ();
                infobar.add_button (_("Cancel"), 0);
                infobar.no_show_all = true;
                infobar.response.connect ((id) => {
                    switch_to_main ();
                    infobar.hide ();
                });

                var container = infobar.get_content_area () as Gtk.Container;
                container.add (info_label);

                stack = new Gtk.Stack ();
                stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
                main_grid = new Gtk.Grid ();
                main_grid.orientation = Gtk.Orientation.VERTICAL;
                paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);

                grid = new Gtk.Grid ();
                grid.expand = true;
                source_selector = new SourceSelector ();

                paned.pack1 (source_selector, false, false);
                paned.pack2 (grid, true, false);
                paned.set_position (200);

                create_welcome ();

                var scrolled_welcome = new Gtk.ScrolledWindow (null, null);
                scrolled_welcome.expand = true;
                scrolled_welcome.hscrollbar_policy = Gtk.PolicyType.NEVER;
                scrolled_welcome.add (welcome);
                stack.add_named (scrolled_welcome, "welcome");
                stack.add_named (paned, "main");
                stack.show_all ();

                var overlay_grid = new Gtk.Grid ();
                overlay_grid.orientation = Gtk.Orientation.VERTICAL;
                overlay_grid.add (infobar);
                overlay_grid.add (stack);

                var overlay = new Gtk.Overlay ();
                overlay.add_overlay (overlay_grid);
                overlay.add_overlay (toast);

                main_grid.add (overlay);
                main_grid.show_all ();

                toast.closed.connect (() => {
                    AccountsManager.get_default ().remove_cached_account ();
                });

                toast.default_action.connect (() => {
                    AccountsManager.get_default ().restore_cached_account ();
                });

                source_selector.account_selected.connect ((account) => {
                    switch_to_main ();
                    account_selected (account);
                });

                source_selector.new_account_request.connect (() => {
                    add_return ();
                    switch_to_welcome ();
                });

                oa_server = new OnlineAccounts.Server ();
                var accounts_manager = AccountsManager.get_default ();

                var account = source_selector.get_selected_account ();
                if (account != null) {
                    account_selected (account);
                    stack.set_visible_child_full ("main", Gtk.StackTransitionType.NONE);
                }

                accounts_manager.account_removed.connect ((account) => {
                    account_removed (account.ag_account.get_display_name ());
                });

                accounts_manager.account_added.connect ((account) => {
                    switch_to_main ();
                });
            }

            return main_grid;
        }

        private void create_welcome () {
            welcome = new Granite.Widgets.Welcome (_("Connect Your Online Accounts"), _("Sign in to connect with apps like Mail, Contacts, and Calendar."));
            welcome.expand = true;
            var manager = new Ag.Manager ();
            foreach (var provider in manager.list_providers ()) {
                if (provider == null)
                    continue;
                if (provider.get_plugin_name () == null)
                    continue;
                var description = GLib.dgettext (provider.get_i18n_domain (), provider.get_description ());
                var id = welcome.append (provider.get_icon_name (), provider.get_display_name (), description ?? "");
                providers_map.set (id, provider);
            }

            welcome.activated.connect ((id) => {
                var prov = providers_map.get (id);
                var ag_manager = new Ag.Manager ();
                var ag_account = ag_manager.create_account (prov.get_name ());
                var account = new Account (ag_account);
                account.authenticate.begin ();
            });
        }

        public override void shown () {
            
        }

        public override void hidden () {
            hide_request ();
            AccountsManager.get_default ().remove_cached_account ();
            infobar.hide ();
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
                switch_to_welcome ();
                return;
            }

            if (source_selector.get_selected_account () == null) {
                return;
            }

            account_view = new AccountView (account);
            grid.attach (account_view, 0, 0, 1, 1);
            account_view.show_all ();
        }

        public void add_widget_to_stack (Gtk.Widget widget, string name) {
            stack.add_named (widget, name);
        }

        public void switch_to_widget (string name) {
            infobar.hide ();
            stack.set_visible_child_name (name);
        }

        public void switch_to_main () {
            if (AccountsManager.get_default ().accounts_available.size <= 0) {
                switch_to_welcome ();
                return;
            }

            stack.set_visible_child_name ("main");
        }

        public void switch_to_welcome () {
            stack.set_visible_child_name ("welcome");
        }

        private void account_removed (string? account_name) {
            toast.title = _("Account '%s' Removed.").printf (account_name ?? _("New Account"));
            toast.send_notification ();
            if (AccountsManager.get_default ().accounts_available.size <= 0)
                switch_to_welcome ();
        }

        private void add_return () {
            infobar.show ();
        }
    }

    public static string string_from_string_array (string[] strv, string separator = " ") {
        string output = "";
        bool first = true;
        foreach (var str in strv) {
            if (first) {
                output = str;
                first = false;
            } else {
                output = output + separator + str;
            }
        }

        return output;
    }
}

public Switchboard.Plug get_plug (Module module) {
    debug ("Activating Online Accounts plug");
    var plug = new OnlineAccounts.Plug ();
    return plug;
}
