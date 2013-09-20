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
    
    public SourceSelector () {
        
        list_store = new Gtk.ListStore (Columns.N_COLUMNS, typeof (string), typeof (string), typeof (OnlineAccounts.Plugin));
        tree_view = new Gtk.TreeView.with_model (list_store);
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
        
        plugins_manager.plugin_callback.connect (add_plugin_callback);
        
        /*try {
            var registry = new E.SourceRegistry.sync (null);
            var sources = registry.list_sources (E.SOURCE_EXTENSION_CALENDAR);
            // Do not show sources that are on the trash
            foreach (var source in app.calmodel.calendar_trash) {
                foreach (var source2 in sources) {
                    if (source.dup_uid () == source2.dup_uid ()) {
                        sources.remove (source2);
                        break;
                    }
                }
            }
            
            
            foreach (var backend in backends_manager.backends) {
                Gtk.TreeIter? b_iter = null;
                foreach (var src in sources) {
                    Gtk.TreeIter iter;
                    if (src.parent == backend.get_uid ()) {
                        if (b_iter == null) {
                            tree_store.append (out b_iter, null);
                            tree_store.set (b_iter, Columns.TEXT, backend.get_name (), Columns.VISIBLE, false);
                            backend_map.set (backend.get_uid (), b_iter);
                        }
                        E.SourceCalendar cal = (E.SourceCalendar)src.get_extension (E.SOURCE_EXTENSION_CALENDAR);
                        tree_store.append (out iter, b_iter);
                        tree_store.set (iter, Columns.TOGGLE, cal.selected, Columns.TEXT, src.dup_display_name (), 
                                               Columns.COLOR, cal.dup_color(), Columns.SOURCE, src, 
                                               Columns.VISIBLE, true);
                        iter_map.set (src.dup_uid (), iter);
                        if (src.get_uid() == registry.default_calendar.uid) {
                            default_iter = iter;
                            selection.select_iter (iter);
                        }
                    }
                }
            }
            
            Gtk.TreeIter? other = null;
            foreach (var src in sources) {
                if (!backend_map.keys.contains (src.parent)) {
                    if (other == null) {
                        tree_store.append (out other, null);
                        tree_store.set (other, Columns.TEXT, _("Other"), Columns.VISIBLE, false);
                    }
                    Gtk.TreeIter iter;
                    E.SourceCalendar cal = (E.SourceCalendar)src.get_extension (E.SOURCE_EXTENSION_CALENDAR);
                    tree_store.append (out iter, other);
                    tree_store.set (iter, Columns.TOGGLE, cal.selected, Columns.TEXT, src.dup_display_name (), 
                                               Columns.COLOR, cal.dup_color(), Columns.SOURCE, src, 
                                               Columns.VISIBLE, true);
                    iter_map.set (src.dup_uid (), iter);
                    if (src.get_uid() == registry.default_calendar.uid) {
                        default_iter = iter;
                        selection.select_iter (iter);
                    }
                }
            }
            
            registry.source_removed.connect (source_removed);
            registry.source_added.connect (source_added);
            registry.source_disabled.connect (source_disabled);
            registry.source_enabled.connect (source_enabled);
            registry.source_changed.connect (source_changed);
        } catch (GLib.Error error) {
            critical (error.message);
        }*/
        
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
        remove_button.sensitive = false;
        
        toolbar.insert (add_button, -1);
        toolbar.insert (remove_button, -1);
        
        attach (scroll, 0, 0, 1, 1);
        attach (toolbar, 0, 1, 1, 1);
    }
    
    private void activate_buttons () {
        remove_button.sensitive = true;
    }
    
    /*private void source_removed (E.Source source) {
        if (iter_map.has_key (source.dup_uid ())) {
            var iter = iter_map.get (source.dup_uid ());
            tree_store.remove (ref iter);
            iter_map.unset (source.dup_uid (), null);
        }
    } */
    
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
            selection.select_iter (iter);
        }
    }
    
    private void create_source () {
        var popover = new AccountPopOver ();
        popover.move_to_widget (add_button, true);
        popover.present ();
    }
    
    private void remove_source () {
        /*var selection = tree_view.get_selection ();
        Gtk.TreeModel model;
        Gtk.TreeIter iter;
        selection.get_selected (out model, out iter);
        GLib.Value src;
        tree_store.get_value (iter, 3, out src);
        var source = src as E.Source;
        app.calmodel.delete_calendar (source);
        app.show_calendar_removed (source.display_name);
        this.hide ();*/
    }
    
    private void edit_source () {
        /*var selection = tree_view.get_selection ();
        Gtk.TreeModel model;
        Gtk.TreeIter iter;
        selection.get_selected (out model, out iter);
        GLib.Value src;
        tree_store.get_value (iter, 3, out src);
        var source = src as E.Source;
        var dialog = new SourceDialog (source);
        this.hide ();
        dialog.present ();*/
    }
}
