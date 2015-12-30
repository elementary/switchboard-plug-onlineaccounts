/*
 * Copyright (C) 2012 Canonical, Inc
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
 * USA.
 *
 * Authors:
 *      Alberto Mardegan <alberto.mardegan@canonical.com>
 */

public class OnlineAccounts.Plugins.OAuth2 : OnlineAccounts.Account {

    private string mechanism;
    public Ag.AuthData auth_data;
    public Signon.IdentityInfo info;
    private Signon.Identity identity;
    bool is_new = false;

    public OAuth2 (Ag.Account account, bool is_new = false) {
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
        info.set_method ("oauth", {"oauth1", "oauth2", null});
        info.access_control_list_append (new Signon.SecurityContext.from_values ("%s/bin/switchboard".printf (Build.CMAKE_INSTALL_PREFIX), "*"));
        var allowed_realms = session_data.lookup_value ("AllowedRealms", null).dup_strv ();
        info.set_realms (allowed_realms);
        identity = new Signon.Identity ();
        identity.store_credentials_with_info (info, IdentityStoreCredentialsCallback);
    }

    public async void authenticate (Signon.Identity identity, uint32 id) {
        GLib.Variant? v_id = new GLib.Variant.uint32 (id);
        account.set_variant (gsignon_id, v_id);
        var mechanism_variant = account.get_variant ("auth/mechanism", null);
        mechanism = mechanism_variant.get_string ();

        if (mechanism == "PLAINTEXT" || mechanism == "HMAC-SHA1" || mechanism == "RSA-SHA1") {
            mechanism = "oauth1";
        } else if (mechanism == "web_server" || mechanism == "user_agent") {
            mechanism = "oauth2";
        }

        try {
            var session = identity.create_session ("oauth");
            session_result = yield session.process_async (session_data, mechanism, null);
            var access_token = session_result.lookup_value ("AccessToken", null).dup_string ();
            info.set_secret (access_token, true);
            foreach (var provider_plugin in OnlineAccounts.PluginsManager.get_default ().get_provider_plugins ()) {
                if (provider_plugin.plugin_name != "generic-oauth")
                    continue;
                if (provider_plugin.provider_name != account.get_provider_name ())
                    continue;
                provider_plugin.get_user_name (this);
            }

            identity.query_info (IdentityInfoCallback);
        } catch (Error e) {
            critical (e.message);
        }

        yield;
    }

    [CCode (instance_pos = -1)]
    public void IdentityStoreCredentialsCallback (Signon.Identity self, uint32 id, GLib.Error error) {
        if (error != null) {
            critical (error.message);
            return;
        }

        authenticate.begin (self, id);
    }

    [CCode (instance_pos = -1)]
    public void IdentityInfoCallback (Signon.Identity self, Signon.IdentityInfo info, GLib.Error error) {
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
