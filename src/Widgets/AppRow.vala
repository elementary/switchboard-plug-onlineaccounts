/*
* Copyright (c) 2013-2018 elementary, Inc. (https://elementary.io)
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

public class AppRow : Gtk.ListBoxRow {
    public Ag.Account account { get; construct; }
    public Ag.Application app { get; construct; }
    public Ag.Service service { get; construct; }
    public Signon.Identity identity { get; construct; }

    private Gtk.CheckButton app_switch;

    public AppRow (Ag.Account account, Ag.Application app, Ag.Service service, Signon.Identity identity) {
        Object (
            account: account,
            app: app,
            identity: identity,
            service: service
        );
    }

    construct {
        var app_info = app.get_desktop_app_info ();

        var app_image = new Gtk.Image ();
        app_image.icon_size = Gtk.IconSize.DND;
        app_image.gicon = app_info.get_icon ();

        var app_name = new Gtk.Label (app_info.get_display_name ());

        app_switch = new Gtk.CheckButton ();

        var grid = new Gtk.Grid ();
        grid.column_spacing = 6;
        grid.add (app_switch);
        grid.add (app_image);
        grid.add (app_name);

        activatable = false;
        selectable = false;
        margin = 6;
        add (grid);

        app_switch.activate.connect (() => {
            if (app_switch.active) {
                allow_app.begin ();
            } else {
                deny_app.begin ();
            }
        });
    }

    private string get_app_path () {
        var app_info = app.get_desktop_app_info ();
        unowned string exec = app_info.get_executable ();
        if (exec.contains ("/") == false) {
            return Environment.find_program_in_path (exec);
        }

        return exec;
    }

    public void check_acl (GLib.List<Signon.SecurityContext> acl) {
        var path = get_app_path ();
        for (unowned List<Signon.SecurityContext> nth = acl.first (); nth != null; nth = nth.next) {
            if (nth.data.get_system_context () == path) {
                app_switch.active = true;
                return;
            }
        }

        app_switch.active = false;
    }

    public async void allow_app () {
        try {
            account.select_service (service);
            Signon.IdentityInfo info = yield identity.query_info (null);
            info.add_access_control (get_app_path (), "*");
            yield identity.store_info (info, null);
            app_switch.active = true;
            account.select_service (null);
            yield account.store_async (null);
        } catch (Error e) {
            critical (e.message);
            account.select_service (null);
        }
    }

    public async void deny_app () {
        try {
            account.select_service (service);
            Signon.IdentityInfo info = yield identity.query_info (null);
            var list = info.get_access_control_list ();
            var path = get_app_path ();
            list.foreach ((nth) => {
                if (nth.get_system_context () == path) {
                    list.remove (nth);
                }
            });

            info.set_access_control_list (list);
            yield identity.store_info (info, null);
            app_switch.active = false;
            account.select_service (null);
            yield account.store_async (null);
        } catch (Error e) {
            critical (e.message);
            account.select_service (null);
        }
    }
}
