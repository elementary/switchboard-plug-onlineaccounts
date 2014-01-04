// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2013 Pantheon Developers (http://launchpad.net/online-accounts-plug)
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
 * Authored by: Zeeshan Ali (Khattak) <zeeshanak@gnome.org> (from Rygel)
 *              Lucas Baudin <xapantu@gmail.com> (from Pantheon Files)
 *              Corentin Noël <tintou@mailoo.org>
 */

public class OnlineAccounts.AccountsManager : Object {
    
    public Gee.ArrayList<OnlineAccounts.Account> accounts_available;
    private OnlineAccounts.Account to_delete; // Store it here and wait until the user is sure to remove it.
    
    public signal void account_added (OnlineAccounts.Account account);
    
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
        if (to_delete != null) {
            to_delete.delete_account.begin ();
        }
    }
    
    public void add_account (OnlineAccounts.Account account) {
        account_added (account);
        accounts_available.add (account);
    }
    
    public void remove_account (OnlineAccounts.Account account) {
        accounts_available.remove (account);
        if (to_delete != null) {
            to_delete.delete_account.begin ();
        }
        to_delete = account;
        
    }
}