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

public class OnlineAccounts.Widget.WebDialog : GLib.Object {

    GLib.HashTable<string, GLib.Variant> params;
    Gtk.Widget webview;
    const string oauth_open_url;
    const string oauth_final_url;
    string oauth_response;
    ulong webkit_redirect_handler_id;
    GSSOUIQueryError error_code;
    
    public WebDialog (GLib.HashTable<string, GLib.Variant> params) {
        this.params = params;
    }
    
    public async void delete_account () {
        account.select_service (null);
        var v_id = account.get_variant (gsignon_id, null);
        var identity = new Signon.Identity.from_db (v_id.get_uint32 (), "");
        identity.remove ((Signon.IdentityRemovedCb) null);
        account.delete ();
        yield account.store_async (null);
    }
    public virtual void setup_authentification () {
    
    }

}
