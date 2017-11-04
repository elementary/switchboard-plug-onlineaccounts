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
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
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
        provider_image.use_fallback = true;

        var user_label = new Gtk.Label (Markup.escape_text (plugin.account.get_display_name ()));
        user_label.get_style_context ().add_class ("h2");
        user_label.hexpand = true;
        user_label.xalign = 0;

        var provider_label = new Gtk.Label (provider.get_display_name ());
        provider_label.xalign = 0;

        var scrolled_window = new Gtk.ScrolledWindow (null, null);
        scrolled_window.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scrolled_window.expand = true;

        var apps_grid = new Gtk.Grid ();
        apps_grid.margin = 6;
        apps_grid.margin_top = 12;
        apps_grid.column_spacing = 12;
        apps_grid.row_spacing = 6;

        int i = 0;
        plugin.account.list_services ().foreach ((service) => {
            if (plugin.account.manager.list_applications_by_service (service).length () == 0)
                return;

            unowned string i18n_domain = service.get_i18n_domain ();

            var service_label = new Gtk.Label (Markup.escape_text (GLib.dgettext (i18n_domain, service.get_display_name ())));
            service_label.get_style_context ().add_class ("h4");
            service_label.hexpand = true;
            service_label.xalign = 0;

            var service_switch = new Gtk.Switch ();
            service_switch.margin_end = 6;
            service_switch.valign = Gtk.Align.CENTER;
            service_switch.tooltip_text = GLib.dgettext (i18n_domain, service.get_description ());
            plugin.account.select_service (service);
            service_switch.active = plugin.account.get_enabled ();

            var acl_list = new ACListBox (plugin.account, service, identity);

            var frame = new Gtk.Frame (null);
            frame.margin_bottom = 12;
            frame.add (acl_list);

            var acl_revealer = new Gtk.Revealer ();
            acl_revealer.reveal_child = service_switch.active;
            acl_revealer.add (frame);

            service_switch.bind_property ("active", acl_revealer, "reveal-child", BindingFlags.DEFAULT);
            service_switch.notify["active"].connect (() => {on_service_switch_activated (service_switch.active, service, acl_list);});

            apps_grid.attach (service_label, 0, i, 1, 1);
            apps_grid.attach (service_switch, 1, i, 1, 1);
            i++;
            apps_grid.attach (acl_revealer, 0, i, 2, 1);
            i++;
        });

        if (i == 1) {
            var provider_name = plugin.account.manager.get_provider (plugin.account.get_provider_name ()).get_display_name ();
            var no_service_label = _("There are no apps currently installed that link to your %s account").printf (provider_name);
            var alert = new Granite.Widgets.AlertView (_("No Apps"), no_service_label, "applications-internet-symbolic");
            this.add (alert);
        } else {
            scrolled_window.add_with_viewport (apps_grid);

            attach (provider_image, 0, 0, 1, 2);
            attach (user_label, 1, 0, 1, 1);
            attach (provider_label, 1, 1, 1, 1);
            attach (scrolled_window, 0, 2, 2, 1);
        }
    }

    private void on_service_switch_activated (bool enabled, Ag.Service service, ACListBox listbox) {
        plugin.account.select_service (service);
        plugin.account.set_enabled (enabled);
        if (enabled) {
            listbox.allow_service ();
        } else {
            listbox.deny_service ();
        }
    }
}
