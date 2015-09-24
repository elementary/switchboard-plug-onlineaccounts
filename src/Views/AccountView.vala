// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2013-2015 Pantheon Developers (https://launchpad.net/switchboard-plug-onlineaccounts)
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
 * Authored by: Corentin Noël <corentin@elementary.io>
 */

public class OnlineAccounts.AccountView : Gtk.Grid {
    Gtk.Grid main_grid;
    OnlineAccounts.Account plugin;
    Signon.Identity identity;

    public AccountView (OnlineAccounts.Account plugin) {
        orientation = Gtk.Orientation.VERTICAL;
        this.plugin = plugin;
        main_grid = new Gtk.Grid ();
        main_grid.orientation = Gtk.Orientation.VERTICAL;
        main_grid.margin = 12;
        main_grid.column_spacing = 6;
        main_grid.row_spacing = 6;

        plugin.account.select_service (null);
        var v_id = plugin.account.get_variant (OnlineAccounts.Account.gsignon_id, null);
        identity = new Signon.Identity.from_db (v_id.get_uint32 ());

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
        ((Gtk.Misc) apps_label).xalign = 0;
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
        plugin.account.list_services ().foreach ((service) => {
            if (plugin.account.manager.list_applications_by_service (service).length () == 0)
                return;

            unowned string i18n_domain = service.get_i18n_domain ();

            var service_image = new Gtk.Image.from_icon_name (service.get_icon_name (), Gtk.IconSize.DIALOG);

            var service_label = new Gtk.Label ("");
            service_label.set_markup ("<big>%s</big>".printf (Markup.escape_text (GLib.dgettext (i18n_domain, service.get_display_name ()))));
            ((Gtk.Misc) service_label).xalign = 0;

            var service_switch = new Gtk.Switch ();
            service_switch.valign = Gtk.Align.CENTER;
            service_switch.tooltip_text = GLib.dgettext (i18n_domain, service.get_description ());
            plugin.account.select_service (service);
            service_switch.active = plugin.account.get_enabled ();

            var app_button = new Gtk.ToggleButton ();
            app_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            app_button.image = new Gtk.Image.from_icon_name ("application-menu-symbolic", Gtk.IconSize.MENU);
            app_button.sensitive = plugin.account.get_enabled ();

            var popover = new ACLPopover (plugin.account, service, identity);
            popover.relative_to = app_button;
            popover.hide.connect (() => {
                app_button.active = false;
            });

            app_button.toggled.connect (() => {
                if (app_button.active) {
                    popover.show_all ();
                }
            });

            var app_button_grid = new Gtk.Grid ();
            app_button_grid.valign = Gtk.Align.CENTER;
            app_button_grid.add (app_button);
            service_switch.notify["active"].connect (() => {on_service_switch_activated (service_switch.active, service, app_button, popover);});

            apps_grid.attach (service_image, 1, i, 1, 1);
            apps_grid.attach (service_label, 2, i, 1, 1);
            apps_grid.attach (service_switch, 3, i, 1, 1);
            apps_grid.attach (app_button_grid, 4, i, 1, 1);
            i++;
        });

        if (i == 1) {
            var provider_name = plugin.account.manager.get_provider (plugin.account.get_provider_name ()).get_display_name ();
            var no_service_label = _("There are no apps currently installed that link to your %s account").printf (provider_name);
            var alert = new Granite.Widgets.AlertView (_("No Apps"), no_service_label, "applications-internet-symbolic");
            this.add (alert);
        } else {
            var fake_grid_l = new Gtk.Grid ();
            fake_grid_l.hexpand = true;
            var fake_grid_r = new Gtk.Grid ();
            fake_grid_r.hexpand = true;
            apps_grid.attach (fake_grid_l, 0, 0, 1, 1);
            apps_grid.attach (fake_grid_r, 5, 0, 1, 1);

            scrolled_window.add_with_viewport (apps_grid);
            main_grid.add (user_label);
            this.add (main_grid);
            this.add (scrolled_window);
            apps_grid.attach (apps_label, 1, 0, 2, 1);
        }
    }

    private void on_service_switch_activated (bool enabled, Ag.Service service, Gtk.Button button, ACLPopover popover) {
        button.sensitive = enabled;
        plugin.account.select_service (service);
        plugin.account.set_enabled (enabled);
        if (enabled) {
            popover.allow_service ();
        } else {
            popover.deny_service ();
        }
    }
}
