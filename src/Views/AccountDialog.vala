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

public class OnlineAccounts.AccountDialog : Granite.Widgets.LightWindow {
    
    public AccountDialog () {
        
        title = _("Add an Account");

        // Dialog properties
        window_position = Gtk.WindowPosition.CENTER_ON_PARENT;
        type_hint = Gdk.WindowTypeHint.DIALOG;
        transient_for = app.window;
        
        var general_grid = new Gtk.Grid ();
        general_grid.margin_left = 12;
        general_grid.margin_right = 12;
        general_grid.margin_top = 12;
        general_grid.margin_bottom = 12;
        general_grid.set_row_spacing (6);
        general_grid.set_column_spacing (12);
        
        // Buttons
        
        var buttonbox = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
        buttonbox.set_layout (Gtk.ButtonBoxStyle.END);
        

        var cancel_button = new Gtk.Button.from_stock (Gtk.Stock.CANCEL);
        var create_button = new Gtk.Button.from_stock (Gtk.Stock.ADD);

        create_button.clicked.connect (save);
        cancel_button.clicked.connect (() => {this.destroy();});

        buttonbox.pack_end (cancel_button);
        buttonbox.pack_end (create_button);
        
        general_grid.attach (buttonbox,  0, 1, 2, 1);
        
        this.add (general_grid);
        
        show_all ();
    }
    
    private void remove_backend_widgets () {
        if (backend_widgets == null)
            return;
        foreach (var widget in backend_widgets) {
            widget.widget.hide ();
        }
        backend_widgets.clear ();
    }
    
    private void add_backend_widgets () {
        foreach (var widget in backend_widgets) {
            main_grid.attach (widget.widget, widget.column, 4 + widget.row, 1, 1);
            if (widget.needed == true && widget.widget is Gtk.Entry) {
                var entry = widget.widget as Gtk.Entry;
                entry.changed.connect (() => {entry_changed (widget);});
                widgets_checked.set (widget.ref_name, ((Gtk.Entry)widget.widget).text != "");
            }
            widget.widget.show ();
        }
        check_can_validate ();
    }
    
    private void entry_changed (PlacementWidget widget) {
        widgets_checked.unset (widget.ref_name);
        widgets_checked.set (widget.ref_name, ((Gtk.Entry)widget.widget).text != "");
        check_can_validate ();
    }
    
    private void check_can_validate () {
        bool result = true;
        foreach (var valid in widgets_checked.values) {
            if (valid == false) {
                result = false;
                break;
            }
        }
        if (result == true && name_entry.text != "") {
            create_button.sensitive = true;
        } else {
            create_button.sensitive = false;
        }
    }

    //--- Public Methods ---//
    
    
    public void save () {
        
        if (event_type == EventType.ADD) {
            current_backend.add_new_calendar (name_entry.text, Util.get_hexa_color (color_button.rgba), set_as_default, backend_widgets);
            this.destroy();
        } else {
            current_backend.modify_calendar (name_entry.text, Util.get_hexa_color (color_button.rgba), set_as_default, backend_widgets, source);
            this.destroy();
        }
    }
}
