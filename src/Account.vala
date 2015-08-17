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

public class OnlineAccounts.Account : GLib.Object {
    public Ag.Account account;
    public Ag.Provider provider;
    public string username;
    public string password;
    public bool need_authentification;
    public GLib.Variant session_data;
    public GLib.Variant session_result;

    public const string gsignon_id = "CredentialsId";

    public signal void removed ();
    public signal void complete ();

    public async void delete_account () {
        account.select_service (null);
        var v_id = account.get_variant (gsignon_id, null);
        var identity = new Signon.Identity.from_db (v_id.get_uint32 ());
        identity.remove ((Signon.IdentityRemovedCb) null);
        account.delete ();
        try {
            yield account.store_async (null);
        } catch (Error e) {
            critical (e.message);
        }
    }

    public virtual void setup_authentification () {
        
    }
}
