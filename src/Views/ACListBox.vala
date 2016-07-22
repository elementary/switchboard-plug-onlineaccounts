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

public class OnlineAccounts.ACListBox : Gtk.ListBox {
    Ag.Account account;
    Signon.Identity identity;
    unowned Signon.SecurityContextList acl = null;
    Ag.Service service;

    public ACListBox (Ag.Account account, Ag.Service service, Signon.Identity identity) {
        this.account = account;
        this.service = service;
        this.identity = identity;
        account.manager.list_applications_by_service (service).foreach ((app) => {
            var row = new AppRow (account, app, service, identity);
            add (row);
            row.show_all ();
        });

        update_acl.begin ();
    }

    private async void update_acl () {
        identity.query_info ((self, info, error) => {
            if (error != null) {
                critical (error.message);
                return;
            }

            acl = info.get_access_control_list ();
            get_children ().foreach ((child) => {
                var approw = child as AppRow;
                approw.check_acl (acl);
            });
        });
    }

    public void allow_service () {
        get_children ().foreach ((child) => {
            var approw = child as AppRow;
            approw.allow_app ();
        });
    }

    public void deny_service () {
        get_children ().foreach ((child) => {
            var approw = child as AppRow;
            approw.deny_app ();
        });
    }

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
                    allow_app ();
                } else {
                    deny_app ();
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

        public void check_acl (List<Signon.SecurityContext> acl) {
            var path = get_app_path ();
            for (unowned List<Signon.SecurityContext> nth = acl.first (); nth != null; nth = nth.next) {
                if (nth.data.sys_ctx == path) {
                    app_switch.active = true;
                    return;
                }
            }

            app_switch.active = false;
        }

        public void allow_app () {
            account.select_service (service);
            identity.query_info ((self, info, error) => {
                if (error != null) {
                    critical (error.message);
                    account.select_service (null);
                    return;
                }

                info.access_control_list_append (new Signon.SecurityContext.from_values (get_app_path (), "*"));
                identity.store_credentials_with_info (info, (self, id, error) => {
                    if (error != null) {
                        critical (error.message);
                    }

                    app_switch.active = true;
                    account.store_async.begin (null);
                    account.select_service (null);
                });
            });
        }

        public void deny_app () {
            account.select_service (service);
            identity.query_info ((self, info, error) => {
                if (error != null) {
                    critical (error.message);
                    account.select_service (null);
                    return;
                }

                var path = get_app_path ();
                var acl = new List<Signon.SecurityContext> ();
                info.get_access_control_list ().foreach ((nth) => {
                    if (nth.sys_ctx != path) {
                        acl.append (nth);
                    }
                });

                info.set_access_control_list ((Signon.SecurityContextList) acl);
                identity.store_credentials_with_info (info, (self, id, error) => {
                    if (error != null) {
                        critical (error.message);
                    }

                    app_switch.active = false;
                    account.store_async.begin (null);
                    account.select_service (null);
                });
            });
        }
    }
}
