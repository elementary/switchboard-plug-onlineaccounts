/*-
 * Copyright (c) 2016 elementary LLC. (https://elementary.io)
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

public class OnlineAccounts.Plugins.LastFMAccount : OnlineAccounts.Account {
    string method = "lastfm";
    public Ag.AuthData auth_data;
    public Signon.IdentityInfo info;
    private Signon.Identity identity;
    bool is_new = false;

    public LastFMAccount (Ag.Account account, bool is_new = false) {
        this.account = account;
        this.is_new = is_new;
        var account_service = new Ag.AccountService (account, null);
        auth_data = account_service.get_auth_data ();
        session_data = auth_data.get_login_parameters (null);
        if (is_new) {
            setup_authentification ();
        }
    }

    public override void setup_authentification () {
        info = new Signon.IdentityInfo ();
        info.set_caption (account.get_provider_name ());
        info.set_identity_type (Signon.IdentityType.APP);
        info.set_secret ("", true);
        info.set_method (method, {"lastfm", null});
        info.access_control_list_append (new Signon.SecurityContext.from_values ("*", "*"));
        var allowed_realms = session_data.lookup_value ("AllowedRealms", null).dup_strv ();
        info.set_realms (allowed_realms);
        identity = new Signon.Identity ();
        identity.store_credentials_with_info (info, store_credentials_callback);
    }

    public async void authenticate (Signon.Identity self, uint32 id) {
        GLib.Variant? v_id = new GLib.Variant.uint32 (id);
        account.set_variant (gsignon_id, v_id);

        try {
            var session = identity.create_session (method);
            session_result = yield session.process_async (session_data, method, null);
            var access_token = session_result.lookup_value ("Secret", null).dup_string ();
            info.set_secret (access_token, true);
            var username = session_result.lookup_value ("UserName", null).dup_string ();
            account.set_display_name (username);

            identity.query_info (query_info_callback);
        } catch (Error e) {
            critical (e.message);
        }

        yield;
    }

    // Callbacks
    public void store_credentials_callback (Signon.Identity self, uint32 id, GLib.Error error) {
        if (error != null) {
            critical (error.message);
            return;
        }

        authenticate.begin (self, id);
    }

    public void query_info_callback (Signon.Identity self, Signon.IdentityInfo info, GLib.Error error) {
        if (error != null) {
            critical (error.message);
            return;
        }

        account.set_enabled (true);
        account.store_async.begin (null);
        if (is_new == true) {
            AccountsManager.get_default ().add_account (this);
            is_new = false;
        }
    }
}
