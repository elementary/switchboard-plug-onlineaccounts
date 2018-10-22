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

public class OnlineAccounts.ACListBox : Gtk.ListBox {
    public Ag.Account account { get; construct; }
    public Ag.Service service { get; construct; }
    public Signon.Identity identity { get; construct; }

    public ACListBox (Ag.Account account, Ag.Service service, Signon.Identity identity) {
        Object (
            account: account,
            service: service,
            identity: identity
        );
    }

    construct {
        account.manager.list_applications_by_service (service).foreach ((app) => {
            var row = new AppRow (account, app, service, identity);
            add (row);
            row.show_all ();
        });

        update_acl.begin ();
    }

    private async void update_acl () {
        try {
            var info = yield identity.query_info (null);
            var acl = info.get_access_control_list ();
            get_children ().foreach ((child) => {
                var approw = child as AppRow;
                approw.check_acl (acl);
            });
        } catch (Error e) {
            critical (e.message);
        }
    }

    public void allow_service () {
        get_children ().foreach ((child) => {
            var approw = child as AppRow;
            approw.allow_app.begin ();
        });
    }

    public void deny_service () {
        get_children ().foreach ((child) => {
            var approw = child as AppRow;
            approw.deny_app.begin ();
        });
    }
}
