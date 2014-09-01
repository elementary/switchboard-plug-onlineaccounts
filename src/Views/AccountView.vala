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
    OnlineAccounts.Account plugin;

    public AccountView (OnlineAccounts.Account plugin) {
        this.plugin = plugin;
        main_grid = new Gtk.Grid ();
        main_grid.margin = 12;
        main_grid.column_spacing = 6;
        main_grid.row_spacing = 6;

        string label_str = plugin.account.manager.get_provider (plugin.account.get_provider_name ()).get_display_name ();
        var name = plugin.account.get_display_name ();
        if (name != "" && name != null) {
            label_str = "%s - %s".printf (plugin.account.get_display_name (), label_str);
        }

        var user_label = new Gtk.Label (Markup.escape_text (label_str));
        Granite.Widgets.Utils.apply_text_style_to_label (Granite.TextStyle.H2, user_label);
        user_label.hexpand = true;

        var apps_label = new Gtk.Label ("");
        apps_label.set_markup ("<b>%s</b>".printf (Markup.escape_text (_("Content to synchronise:"))));
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

        int i = 1;
        var services = plugin.account.list_services ();
        foreach (var service in services) {
            string i18n_domain = service.get_i18n_domain ();
            string tooltip = GLib.dgettext (i18n_domain, service.get_description ());

            var service_image = new Gtk.Image.from_icon_name (service.get_icon_name (), Gtk.IconSize.DIALOG);
            service_image.margin_left = 12;

            var service_label = new Gtk.Label ("");
            service_label.set_markup ("<big>%s</big>".printf (Markup.escape_text (GLib.dgettext (i18n_domain, service.get_display_name ()))));

            service_label.xalign = 0;

            var service_switch = new Gtk.Switch ();
            service_switch.valign = Gtk.Align.CENTER;
            service_switch.tooltip_text = tooltip;
            plugin.account.select_service (service);
            service_switch.active = plugin.account.get_enabled ();
            service_switch.notify["active"].connect (() => {on_service_switch_activated (service_switch.active, service);});

            apps_grid.attach (service_image, 1, i, 1, 1);
            apps_grid.attach (service_label, 2, i, 1, 1);
            apps_grid.attach (service_switch, 3, i, 1, 1);
            i++;
        }

        if (i == 1) {
            apps_label.set_markup ("<b>%s</b>".printf (Markup.escape_text (_("There is no service linked this account."))));
        } else {
            var fake_grid_l = new Gtk.Grid ();
            fake_grid_l.hexpand = true;
            var fake_grid_r = new Gtk.Grid ();
            fake_grid_r.hexpand = true;
            apps_grid.attach (fake_grid_l, 0, 0, 1, 1);
            apps_grid.attach (fake_grid_r, 4, 0, 1, 1);
        }

        apps_grid.attach (apps_label, 1, 0, 2, 1);
        plugin.account.select_service (null);

        scrolled_window.add_with_viewport (apps_grid);
        main_grid.attach (user_label, 0, 0, 1, 1);
        this.attach (main_grid, 0, 0, 1, 1);
        this.attach (scrolled_window, 0, 1, 1, 1);
    }

    private void on_service_switch_activated (bool enabled, Ag.Service service) {
        plugin.account.select_service (service);
        plugin.account.set_enabled (enabled);
        plugin.account.store_async.begin (null);
        plugin.account.select_service (null);
    }
    
}