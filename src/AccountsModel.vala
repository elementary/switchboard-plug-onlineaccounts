/*
* Copyright 2021 elementary, Inc. (https://elementary.io)
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

    private E.SourceRegistryWatcher collection_extension_watcher;
    private E.SourceRegistryWatcher mail_account_extension_watcher;

    construct {
        accounts_liststore = new ListStore (typeof (E.Source));

        init_registry.begin ();
    }

    private async void init_registry () {
        try {
            var registry = yield new E.SourceRegistry (null);

            collection_extension_watcher = new E.SourceRegistryWatcher (registry, E.SOURCE_EXTENSION_COLLECTION);
            collection_extension_watcher.appeared.connect (add_esource);
            collection_extension_watcher.disappeared.connect (remove_esource);
            collection_extension_watcher.reclaim ();

            mail_account_extension_watcher = new E.SourceRegistryWatcher (registry, E.SOURCE_EXTENSION_MAIL_ACCOUNT);
            mail_account_extension_watcher.appeared.connect (add_esource);
            mail_account_extension_watcher.disappeared.connect (remove_esource);
            mail_account_extension_watcher.reclaim ();
        } catch (Error e) {
            critical (e.message);
        }
    }

    private void add_esource (E.Source e_source) {
        uint position;
        if (accounts_liststore.find (e_source, out position)) {
            return;
        }

        // Ignore children of collection accounts
        if (e_source.parent != null) {
            return;
        }

        // Ignore "Search" and "On This Computer"
        if (e_source.has_extension (E.SOURCE_EXTENSION_MAIL_ACCOUNT)) {
            unowned var mail_source = (E.SourceMailAccount) e_source.get_extension (E.SOURCE_EXTENSION_MAIL_ACCOUNT);
            if (mail_source.backend_name == "vfolder" || mail_source.backend_name == "maildir") {
                return;
            }
        }

        accounts_liststore.append (e_source);
    }

    private void remove_esource (E.Source e_source) {
        uint position;
        if (accounts_liststore.find (e_source, out position)) {
            accounts_liststore.remove (position);
        }
    }
}
