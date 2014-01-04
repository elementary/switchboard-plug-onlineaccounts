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
        Gtk.Stack stack;
        Gtk.Grid grid;
        Gtk.Grid main_grid;
        AccountView account_view;
        SourceSelector source_selector;
        Granite.Widgets.ThinPaned paned;
        OnlineAccounts.Server oa_server;
        Gtk.Widget current_widget_ui;
        PluginsManager plugins_manager;

        public Plug () {
            Object (category: Category.NETWORK,
                    code_name: Build.PLUGCODENAME,
                    display_name: _("Online Accounts"),
                    description: _("Synchronize your computer with all your online accounts around the web."),
                    icon: "preferences-desktop-online-accounts");
            plugins_manager = PluginsManager.get_default ();
            plug = this;
        }

        ~Plug () {
            debug ("do real destruction here");
        }

        public override Gtk.Widget get_widget () {
            if (stack == null) {
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

                main_grid.attach (paned, 0, 0, 1, 1);
                stack.add_named (main_grid, "main");
                stack.show_all ();
                oa_server = new OnlineAccounts.Server ();
            }

            return stack;
        }

        public override void shown () {
            
        }

        public override void hidden () {
            
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