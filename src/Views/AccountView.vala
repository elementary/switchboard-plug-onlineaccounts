// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2013 Pantheon Developers (http://launchpad.net/online-accounts-plug)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 * Authored by: Corentin Noël <tintou@mailoo.org>
 */

public class OnlineAccounts.AccountView : Gtk.Grid {
    
    Gtk.Grid main_grid;
    OnlineAccounts.Plugin plugin;
    
    public AccountView (OnlineAccounts.Plugin plugin) {
        this.plugin = plugin;
        main_grid = new Gtk.Grid ();
        main_grid.margin = 12;
        main_grid.column_spacing = 6;
        main_grid.row_spacing = 6;
        
        var label_str = "%s - %s".printf (plugin.account.get_display_name (), plugin.account.manager.get_provider (plugin.account.provider).get_display_name ());
        var user_label = new Gtk.Label (label_str);
        Granite.Widgets.Utils.apply_text_style_to_label (Granite.TextStyle.H2, user_label);
        user_label.hexpand = true;
        
        var apps_label = new Gtk.Label ("");
        apps_label.set_markup (_("<b>Applications that use this service:</b>"));
        apps_label.xalign = 0;
        apps_label.margin_top = 12;
        
        var scrolled_window = new Gtk.ScrolledWindow (null, null);
        scrolled_window.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scrolled_window.expand = true;
        
        var apps_grid = new Gtk.Grid ();
        apps_grid.margin_bottom = 12;
        apps_grid.margin_left = 12;
        apps_grid.margin_right = 12;
        apps_grid.column_spacing = 12;
        apps_grid.row_spacing = 6;
        
        int i = 0;
        foreach (var service in plugin.account.list_services ()) {
            foreach (var app in plugin.account.manager.list_applications_by_service (service)) {
                string i18n_domain = app.get_desktop_app_info ().get_string ("X-GNOME-Gettext-Domain");
                if (i18n_domain == null)
                    i18n_domain = app.get_desktop_app_info ().get_string ("X-Ubuntu-Gettext-Domain");
                if (i18n_domain == null)
                    i18n_domain = app.get_i18n_domain ();
                
                var service_image = new Gtk.Image.from_gicon (app.get_desktop_app_info ().get_icon (), Gtk.IconSize.DIALOG);
                service_image.margin_left = 12;
                
                var service_label = new Gtk.Label ("");
                service_label.set_markup ("<big>" + GLib.dgettext (i18n_domain, app.get_desktop_app_info ().get_string ("Name") + "</big>"));
                service_label.xalign = 0;
                
                var service_description_label = new Gtk.Label (GLib.dgettext (app.get_i18n_domain (), app.get_service_usage (service)));
                service_description_label.xalign = 0;
                
                var service_labels_grid = new Gtk.Grid ();
                service_labels_grid.hexpand = true;
                service_labels_grid.margin = 6;
                service_labels_grid.row_spacing = 6;
                service_labels_grid.attach (service_label, 0, 0, 1, 1);
                service_labels_grid.attach (service_description_label, 0, 1, 1, 1);
                
                var service_switch = new Gtk.Switch ();
                service_switch.valign = Gtk.Align.CENTER;
                plugin.account.select_service (service);
                service_switch.active = plugin.account.get_enabled ();
                service_switch.notify["active"].connect (() => {on_service_switch_activated (service_switch.active, service);});
                
                apps_grid.attach (service_image, 0, i, 1, 1);
                apps_grid.attach (service_labels_grid, 1, i, 1, 1);
                apps_grid.attach (service_switch, 2, i, 1, 1);
                i++;
            }
        }
        if (i == 0) {
            apps_label.set_markup (_("<b>There is no application using this account.</b>"));
        }
        plugin.account.select_service (null);
        
        scrolled_window.add_with_viewport (apps_grid);
        
        main_grid.attach (user_label, 0, 0, 1, 1);
        main_grid.attach (apps_label, 0, 1, 1, 1);
        this.attach (main_grid, 0, 0, 1, 1);
        this.attach (scrolled_window, 0, 1, 1, 1);
    }
    
    private void on_service_switch_activated (bool enabled, Ag.Service service) {
        plugin.account.select_service (service);
        plugin.account.set_enabled (enabled);
        try {
            plugin.account.store_async.begin (null);
        } catch (Error e) {
            critical (e.message);
        }
        plugin.account.select_service (null);
    }
    
}
