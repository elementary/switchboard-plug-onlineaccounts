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
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
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
        Gtk.Label info_label;
        AccountView account_view;
        SourceSelector source_selector;
        Granite.Widgets.ThinPaned paned;
        OnlineAccounts.Server oa_server;
        PluginsManager plugins_manager;
        Gtk.InfoBar infobar;
        Gee.HashMap<int, Ag.Provider> providers_map;
        Granite.Widgets.Welcome welcome;

        public Plug () {
            Object (category: Category.NETWORK,
                    code_name: Build.PLUGCODENAME,
                    display_name: _("Online Accounts"),
                    description: _("Synchronize your computer with all your online accounts around the web."),
                    icon: "preferences-desktop-online-accounts");
            plugins_manager = PluginsManager.get_default ();
            providers_map = new Gee.HashMap<int, Ag.Provider> (null, null);
            plug = this;
        }

        ~Plug () {
            AccountsManager.get_default ().remove_cached_account ();
        }

        public override Gtk.Widget get_widget () {
            if (stack == null) {
                infobar = new Gtk.InfoBar.with_buttons (_("Close"), 0, _("Restore"), 1);
                infobar.no_show_all = true;
                var action_box = infobar.get_action_area () as Gtk.Box;
                action_box.orientation = Gtk.Orientation.HORIZONTAL;
                var container = infobar.get_content_area () as Gtk.Container;
                info_label = new Gtk.Label ("");
                info_label.valign = Gtk.Align.CENTER;
                info_label.show ();
                container.add (info_label);
                infobar.response.connect ((id) => {
                    var accounts_manager = AccountsManager.get_default ();
                    if (id == 0) {
                        accounts_manager.remove_cached_account ();
                        infobar.hide ();
                    } else {
                        accounts_manager.restore_cached_account ();
                        infobar.hide ();
                    }
                });

                stack = new Gtk.Stack ();
                main_grid = new Gtk.Grid ();
                paned = new Granite.Widgets.ThinPaned ();
                source_selector = new SourceSelector ();
                source_selector.account_selected.connect (account_selected);
                grid = new Gtk.Grid ();
                grid.expand = true;

                paned.pack1 (source_selector, false, false);
                paned.pack2 (grid, true, false);
                paned.set_position (200);

                main_grid.attach (infobar, 0, 0, 1, 1);
                main_grid.attach (paned, 0, 1, 1, 1);
                main_grid.show_all ();
                stack.add_named (main_grid, "main");
                create_welcome ();
                stack.show_all ();
                oa_server = new OnlineAccounts.Server ();
                account_selected ();
                var accounts_manager = AccountsManager.get_default ();
                accounts_manager.account_removed.connect ((account) => {
                    info_label.label = _("Account '%s' Removed.").printf (account.account.get_display_name ());
                    infobar.show ();
                    if (accounts_manager.accounts_available.size <= 0)
                        switch_to_welcome ();
                });
                accounts_manager.account_added.connect ((account) => {
                    switch_to_main ();
                });
            }

            return stack;
        }
        
        private void create_welcome () {
            welcome = new Granite.Widgets.Welcome (_("Connect Your Online Accounts"), _("Sign in to connect with apps like Mail, Contacts, and Calendar."));
            welcome.expand = true;
            main_grid.attach (welcome, 0, 1, 1, 1);
        
            var manager = new Ag.Manager ();
            
            foreach (var provider in manager.list_providers ()) {
                if (provider == null)
                    continue;
                if (provider.get_plugin_name () == null)
                    continue;
                foreach (var method_plugin in PluginsManager.get_default ().get_method_plugins ()) {
                    if (provider.get_plugin_name ().collate (method_plugin.plugin_name) != 0)
                        continue;
                    var description = GLib.dgettext (provider.get_i18n_domain (), provider.get_description ());
                    var id = welcome.append (provider.get_icon_name (), provider.get_display_name (), description ?? "");
                    providers_map.set (id, provider);
                }
            }
            
            welcome.show_all ();
            welcome.no_show_all = true; 
            welcome.hide ();
            
            welcome.activated.connect ((id) => {
                var prov = providers_map.get (id);
                
                var account = manager.create_account (prov.get_name ());
                var provider = manager.get_provider (account.provider);
                var plugin_name = provider.get_plugin_name ();
                foreach (var providerplugin in PluginsManager.get_default ().get_method_plugins ()) {
                    if (providerplugin.plugin_name == plugin_name) {
                        providerplugin.add_account (account);
                        break;
                    }
                }
            });
        }

        public override void shown () {
            
        }

        public override void hidden () {
            hide_request ();
        }

        public override void search_callback (string location) {
            
        }

        // 'search' returns results like ("Keyboard → Behavior → Duration", "keyboard<sep>behavior")
        public override async Gee.TreeMap<string, string> search (string search) {
            return new Gee.TreeMap<string, string> (null, null);
        }

        private void account_selected () {
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
            account_view = new AccountView (source_selector.get_selected_account ());
            grid.attach (account_view, 0, 0, 1, 1);
            account_view.show_all ();
        }

        public void add_widget_to_stack (Gtk.Widget widget, string name) {
            stack.add_named (widget, name);
        }

        public void switch_to_widget (string name) {
            stack.set_visible_child_full (name, Gtk.StackTransitionType.SLIDE_LEFT);
        }

        public void switch_to_main () {
            if (AccountsManager.get_default ().accounts_available.size <= 0) {
                switch_to_welcome ();
                return;
            }
            welcome.hide ();
            paned.show ();
            stack.set_visible_child_full ("main", Gtk.StackTransitionType.SLIDE_RIGHT);
        }

        public void switch_to_welcome () {
            welcome.show ();
            paned.hide ();
            stack.set_visible_child_full ("main", Gtk.StackTransitionType.SLIDE_RIGHT);
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