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
 * Authored by: Corentin Noël <tintou@mailoo.org>
 */

public abstract class OnlineAccounts.Plugin : GLib.Object {

    public Ag.Account account;
    public Ag.Provider provider;
    public GLib.Error error;
    public string username;
    public string password;
    public GLib.HashTable<string, string> cookies;
    public bool ignore_cookies;
    public bool need_authentication;
    public bool cancelled;
    public static string signon_id = "CredentialsId";
    
    public Plugin (Ag.Account account) {
        this.account = account;
        cookies = new GLib.HashTable<string, string> (null, null);
    }

    public abstract Gtk.Widget get_widget ();
    public abstract void delete_account ();

}
