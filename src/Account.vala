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
