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

public class OnlineAccounts.AccountPopOver : Granite.Widgets.PopOver {
    
    private Gtk.ListStore list_store;
    private Gtk.TreeView tree_view;
    private Gee.HashMap<string, Gtk.TreeIter?> iter_map;
    private Gtk.TreeIter default_iter;

    private enum Columns {
        ICON,
        TEXT,
        PROVIDER,
        N_COLUMNS
    }
    
    public AccountPopOver () {
        
        list_store = new Gtk.ListStore (Columns.N_COLUMNS, typeof (string), typeof (string), typeof (Ag.Provider));
        tree_view = new Gtk.TreeView.with_model (list_store);
        tree_view.activate_on_single_click = true;
        
        var main_grid = new Gtk.Grid ();

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
        tree_view.row_activated.connect (row_activated);
        
        var selection = tree_view.get_selection ();
        selection.mode = Gtk.SelectionMode.BROWSE;
        
        var manager = new Ag.Manager ();
        
        foreach (var provider in manager.list_providers ()) {
            if (provider == null)
                continue;
            if (provider.get_plugin_name () == null)
                continue;
            if (plugins_manager.plugins_available.contains (provider.get_plugin_name ())) {
                var description = GLib.dgettext (provider.get_i18n_domain (), provider.get_description ());
                Gtk.TreeIter iter;
                list_store.append (out iter);
                list_store.set (iter, Columns.ICON, provider.get_icon_name (), 
                                       Columns.TEXT, "<b>" + provider.get_display_name () + "</b>\n" + description,
                                       Columns.PROVIDER, provider);
            }
        }
        
        var scroll = new Gtk.ScrolledWindow (null, null);
        scroll.set_size_request (150, 150);
        scroll.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scroll.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
        scroll.shadow_type = Gtk.ShadowType.IN;
        scroll.expand = true;
        scroll.add (tree_view);
        
        var container = (Gtk.Container) get_content_area ();
        container.add (main_grid);
        main_grid.attach (scroll, 0, 0, 1, 1);
    }
    
    public void row_activated (Gtk.TreePath path, Gtk.TreeViewColumn column) {
        Gtk.TreeIter iter;
        list_store.get_iter (out iter, path);
        GLib.Value src;
        list_store.get_value (iter, 2, out src);
        var manager = new Ag.Manager ();
        var account = manager.create_account (((Ag.Provider)src).get_name ());
        plugins_manager.use_plugin (account, true);
        this.hide ();
    }
    
}
