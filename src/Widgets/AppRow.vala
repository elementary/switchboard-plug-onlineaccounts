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
    public Ag.Application app;
    private Ag.Service service;
    private Ag.Account account;
    private Signon.Identity identity;

    private Gtk.Image app_image;
    private Gtk.Label app_name;
    private Gtk.CheckButton app_switch;
    public AppRow (Ag.Account account, Ag.Application app, Ag.Service service, Signon.Identity identity) {
        this.account = account;
        this.app = app;
        this.service = service;
        this.identity = identity;
        var app_info = app.get_desktop_app_info ();
        app_image.gicon = app_info.get_icon ();
        app_name.label = app_info.get_display_name ();
    }

    construct {
        activatable = false;
        selectable = false;
        margin = 6;

        app_image = new Gtk.Image ();
        app_image.icon_size = Gtk.IconSize.DND;
        app_name = new Gtk.Label (null);
        app_switch = new Gtk.CheckButton ();
        app_switch.activate.connect (() => {
            if (app_switch.active) {
                allow_app.begin ();
            } else {
                deny_app.begin ();
            }
        });

        var grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.HORIZONTAL;
        grid.column_spacing = 6;
        grid.add (app_switch);
        grid.add (app_image);
        grid.add (app_name);
        add (grid);
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
