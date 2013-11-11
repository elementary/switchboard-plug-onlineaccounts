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

    string dialog_bus_address;
    
    public Plugins.Manager plugins_manager;
    public AccountsManager accounts_manager;
    public UIManager ui_manager;
    
    public class Plug : Switchboard.Plug {
        
        Gtk.Grid grid;
        Gtk.Grid main_grid;
        AccountView account_view;
        SourceSelector source_selector;
        Granite.Widgets.ThinPaned paned;
        gSSOui.Server gsso_server;
        Gtk.Widget current_widget_ui;

        public Plug () {
            plugins_manager = new Plugins.Manager ();
            accounts_manager = new AccountsManager ();
            ui_manager = new UIManager ();
            category = Category.NETWORK;
            code_name = "network-pantheon-online-accounts"; // The name it is recognised with the open-plug command
            display_name = _("Online Accounts");
            description = _("Synchronize your computer with all your online accounts around the web.");
            icon = "preferences-desktop-online-accounts";
        }
        ~Plug () {
            debug ("do real destruction here");
        }
        
        public override Gtk.Widget get_widget () {
            if (main_grid == null) {
                main_grid = new Gtk.Grid ();
                paned = new Granite.Widgets.ThinPaned ();
                source_selector = new SourceSelector ();
                source_selector.account_selected.connect (account_selected);
                grid = new Gtk.Grid ();
                grid.expand = true;
                
                paned.pack1 (source_selector, false, false);
                paned.pack2 (grid, true, false);
                paned.set_position (200);
                
                main_grid.attach (paned, 0, 0, 1, 1);
                main_grid.show_all ();
                plugins_manager.activate ();
                plugins_manager.load_accounts ();
                gsso_server = new gSSOui.Server (0);
                ui_manager.widget_registered.connect (new_account_widget);
            }
            return main_grid;
        }
        
        public override void close () {
        
        }
        
        // 'search' returns results like ("Keyboard → Behavior → Duration", "keyboard<sep>behavior")
        public override async Gee.TreeMap<string, string> search (string search) {
            return new Gee.TreeMap<string, string> (null, null);
        }
        
        private void account_selected () {
            if (account_view != null) {
                account_view.hide ();
            }
            account_view = new AccountView (source_selector.get_selected_account ());
            grid.attach (account_view, 0, 0, 1, 1);
            account_view.show_all ();
        }
        
        private void new_account_widget () {
            if (current_widget_ui != null)
                return;
            paned.hide ();
            current_widget_ui = ui_manager.widgets_available.peek ();
            main_grid.attach (current_widget_ui, 0, 0, 1, 1);
            current_widget_ui.show ();
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
