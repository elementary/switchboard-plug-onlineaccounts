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

public class OnlineAccounts.SourceSelector : Gtk.Grid {

    private Gtk.ListStore list_store;
    private Gtk.TreeView tree_view;
    private Gee.HashMap<string, Gtk.TreeIter?> iter_map;
    private Gtk.TreeIter default_iter;
    
    private Gtk.ToolButton remove_button;
    private Gtk.ToolButton add_button;

    private enum Columns {
        ICON,
        TEXT,
        PLUGIN,
        N_COLUMNS
    }
    
    public signal void account_selected (OnlineAccounts.Plugin plugin);
    
    public SourceSelector () {
        
        list_store = new Gtk.ListStore (Columns.N_COLUMNS, typeof (string), typeof (string), typeof (OnlineAccounts.Plugin));
        tree_view = new Gtk.TreeView.with_model (list_store);
        tree_view.activate_on_single_click = true;
        iter_map = new Gee.HashMap<string, Gtk.TreeIter?> ();

        var pixbuf = new Gtk.CellRendererPixbuf ();
        pixbuf.stock_size = Gtk.IconSize.DIALOG;
        var column = new Gtk.TreeViewColumn ();
        column.pack_start (pixbuf, false);
        column.add_attribute (pixbuf, "icon_name", Columns.ICON);
        tree_view.append_column (column);

        var text = new Gtk.CellRendererText ();
        text.ellipsize = Pango.EllipsizeMode.END;
        text.ellipsize_set = true;
        column = new Gtk.TreeViewColumn ();
        column.pack_start (text, true);
        column.add_attribute (text, "markup", Columns.TEXT);
        tree_view.append_column (column);
 
        tree_view.set_headers_visible (false);
        
        var backend_map = new Gee.HashMap<string, Gtk.TreeIter?>();
        
        var selection = tree_view.get_selection ();
        selection.mode = Gtk.SelectionMode.BROWSE;
        
        accounts_manager.account_added.connect (add_plugin_callback);
        
        var scroll = new Gtk.ScrolledWindow (null, null);
        scroll.set_size_request (150, 150);
        scroll.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scroll.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
        scroll.shadow_type = Gtk.ShadowType.IN;
        scroll.expand = true;
        scroll.add (tree_view);

        var toolbar = new Gtk.Toolbar();
        toolbar.set_style (Gtk.ToolbarStyle.ICONS);
        toolbar.get_style_context ().add_class ("inline-toolbar");
        toolbar.set_icon_size (Gtk.IconSize.SMALL_TOOLBAR);
        toolbar.set_show_arrow (false);
        toolbar.hexpand = true;

        scroll.get_style_context ().set_junction_sides (Gtk.JunctionSides.BOTTOM);
        toolbar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
        toolbar.get_style_context ().set_junction_sides (Gtk.JunctionSides.TOP);
        
        add_button = new Gtk.ToolButton (null, _("Add…"));
        add_button.set_tooltip_text (_("Add…"));
        add_button.set_icon_name ("list-add-symbolic");
        add_button.clicked.connect (create_source);
        
        remove_button = new Gtk.ToolButton (null, _("Remove"));
        remove_button.set_tooltip_text (_("Remove"));
        remove_button.set_icon_name ("list-remove-symbolic");
        remove_button.clicked.connect (remove_source);
        
        toolbar.insert (add_button, -1);
        toolbar.insert (remove_button, -1);
        
        attach (scroll, 0, 0, 1, 1);
        attach (toolbar, 0, 1, 1, 1);
        
        tree_view.row_activated.connect ((path, column) => {
            Gtk.TreeIter iter;
            list_store.get_iter (out iter, path);
            OnlineAccounts.Plugin plugin;
            list_store.get (iter, Columns.PLUGIN, out plugin);
            account_selected (plugin);
        });
    }
    
    private void add_plugin_callback (OnlineAccounts.Plugin plugin) {
        var provider = plugin.account.get_manager ().get_provider (plugin.account.provider);
        Gtk.TreeIter iter;
        list_store.append (out iter);
        list_store.set (iter, Columns.ICON, provider.get_icon_name (), 
                               Columns.TEXT, "<b>" + provider.get_display_name () + "</b>\n"+ plugin.account.display_name,
                               Columns.PLUGIN, plugin);
        var selection = tree_view.get_selection ();
        if (selection.count_selected_rows () <= 0) {
            list_store.get_iter_first (out iter);
            selection.unselect_all ();
            selection.select_iter (iter);
            account_selected (plugin);
        }
    }
    
    private void create_source () {
        var popover = new AccountPopOver ();
        popover.move_to_widget (add_button, true);
        popover.present ();
    }
    
    private void remove_source () {
        Gtk.TreeModel model;
        Gtk.TreeIter? iter;
        var selection = tree_view.get_selection ();
        if (selection.get_selected (out model, out iter)) {
            OnlineAccounts.Plugin plugin;
            list_store.get (iter, Columns.PLUGIN, out plugin);
            accounts_manager.remove_account (plugin);
            bool show_welcome = false;
            list_store.remove (iter);
            selection = tree_view.get_selection ();
            selection.get_selected (out model, out iter);
            if (iter == null) {
                if (!model.get_iter_first (out iter)) {
                    show_welcome = true;
                } else {
                    selection.unselect_all ();
                    selection.select_iter (iter);
                }
            }
            
            if (!show_welcome) {
                model.get (iter, Columns.PLUGIN, out plugin);
                account_selected (plugin);
            } else {
                //TODO: show_welcome !
            }
            
        }
    }
    
    private void edit_source () {
        
    }
}
