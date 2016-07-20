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
    OnlineAccounts.Account plugin;
    Signon.Identity identity;

    public AccountView (OnlineAccounts.Account plugin) {
        column_spacing = 6;
        row_spacing = 3;
        margin = 24;
        orientation = Gtk.Orientation.VERTICAL;
        this.plugin = plugin;

        plugin.account.select_service (null);
        var v_id = plugin.account.get_variant (OnlineAccounts.Account.gsignon_id, null);
        identity = new Signon.Identity.from_db (v_id.get_uint32 ());

        var provider = plugin.account.get_manager ().get_provider (plugin.account.get_provider_name ());

        var provider_image = new Gtk.Image.from_icon_name (provider.get_icon_name (), Gtk.IconSize.DIALOG);

        var user_label = new Gtk.Label (Markup.escape_text (plugin.account.get_display_name ()));
        user_label.get_style_context ().add_class ("h2");
        user_label.hexpand = true;
        user_label.xalign = 0;

        var provider_label = new Gtk.Label (provider.get_display_name ());
        provider_label.xalign = 0;

        var apps_label = new Gtk.Label (_("Content to synchronise:"));
        apps_label.get_style_context ().add_class ("h4");
        apps_label.margin = 6;
        apps_label.xalign = 0;

        var scrolled_window = new Gtk.ScrolledWindow (null, null);
        scrolled_window.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scrolled_window.expand = true;

        var frame = new Gtk.Frame (null);
        frame.get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        frame.margin_top = 24;
        frame.add (scrolled_window);

        var apps_grid = new Gtk.Grid ();
        apps_grid.margin_left = 6;
        apps_grid.margin_right = 6;
        apps_grid.column_spacing = 12;
        apps_grid.row_spacing = 6;

        int i = 1;
        plugin.account.list_services ().foreach ((service) => {
            if (plugin.account.manager.list_applications_by_service (service).length () == 0)
                return;

            unowned string i18n_domain = service.get_i18n_domain ();

            var service_image = new Gtk.Image.from_icon_name (service.get_icon_name (), Gtk.IconSize.DIALOG);
            service_image.margin_start = 6;

            var service_label = new Gtk.Label ("");
            service_label.hexpand = true;
            service_label.set_markup ("<big>%s</big>".printf (Markup.escape_text (GLib.dgettext (i18n_domain, service.get_display_name ()))));
            service_label.xalign = 0;

            var service_switch = new Gtk.Switch ();
            service_switch.margin_end = 6;
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

            apps_grid.attach (service_image, 0, i, 1, 1);
            apps_grid.attach (service_label, 1, i, 1, 1);
            apps_grid.attach (app_button_grid, 2, i, 1, 1);
            apps_grid.attach (service_switch, 3, i, 1, 1);
            i++;
        });

        if (i == 1) {
            var provider_name = plugin.account.manager.get_provider (plugin.account.get_provider_name ()).get_display_name ();
            var no_service_label = _("There are no apps currently installed that link to your %s account").printf (provider_name);
            var alert = new Granite.Widgets.AlertView (_("No Apps"), no_service_label, "applications-internet-symbolic");
            this.add (alert);
        } else {
            apps_grid.attach (apps_label, 0, 0, 2, 1);
            scrolled_window.add_with_viewport (apps_grid);

            attach (provider_image, 0, 0, 1, 2);
            attach (user_label, 1, 0, 1, 1);
            attach (provider_label, 1, 1, 1, 1);
            attach (frame, 0, 2, 2, 1);
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
