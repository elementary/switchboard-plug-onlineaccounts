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

public class OnlineAccounts.AccountsManager : Object {
    
    public Gee.ArrayList<OnlineAccounts.Account> accounts_available;
    private OnlineAccounts.Account to_delete; // Store it here and wait until the user is sure to remove it.
    
    public signal void account_added (OnlineAccounts.Account account);
    public signal void account_removed (OnlineAccounts.Account account);
    
    private static OnlineAccounts.AccountsManager? accounts_manager = null;
    
    public static AccountsManager get_default () {
        if (accounts_manager == null) {
            accounts_manager = new AccountsManager ();
        }
        return accounts_manager;
    }

    private AccountsManager () {
        accounts_available = new Gee.ArrayList<OnlineAccounts.Account> ();
    }
    ~AccountsManager () {
        remove_cached_account ();
    }
    
    public void add_account (OnlineAccounts.Account account) {
        accounts_available.add (account);
        account_added (account);
    }
    
    public void remove_cached_account () {
        if (to_delete != null) {
            to_delete.delete_account.begin ();
        }
        to_delete = null;
    }
    
    public void restore_cached_account () {
        if (to_delete != null) {
            add_account (to_delete);
        }
        to_delete = null;
    }
    
    public void remove_account (OnlineAccounts.Account account) {
        accounts_available.remove (account);
        if (to_delete != null) {
            to_delete.delete_account.begin ();
        }
        to_delete = account;
        account_removed (account);
    }
}
