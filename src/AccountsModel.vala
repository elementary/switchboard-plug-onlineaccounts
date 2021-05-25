/*
* Copyright 2020 elementary, Inc. (https://elementary.io)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
*/

public class OnlineAccounts.AccountsModel : Object {
    public ListStore accounts_liststore { get; private set; }

    construct {
        accounts_liststore = new ListStore (typeof (E.Source));

        init_registry.begin ();
    }

    private async void init_registry () {
        try {
            var registry = yield new E.SourceRegistry (null);

            registry.source_added.connect ((account) => {
                accounts_liststore.append (account);
            });

            registry.source_removed.connect ((account) => {
                uint position;
                if (accounts_liststore.find (account, out position)) {
                    accounts_liststore.remove (position);
                } else {
                    critical ("Can't remove: %s", account.dup_display_name ());
                }
            });

            registry.list_sources (null).foreach ((account) => {
                accounts_liststore.append (account);
            });
        } catch (Error e) {
            critical (e.message);
        }
    }
}
