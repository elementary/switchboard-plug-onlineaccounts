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

    private string[] method_a;
    Ag.Manager manager;
    public Ag.AuthData auth_data;
    public Signon.IdentityInfo info;
    public GLib.MainLoop main_loop;
    bool is_new = false;

    public OAuth2 (Ag.Account account, bool is_new = false) {
        this.account = account;
        this.is_new = is_new;
        var account_service = new Ag.AccountService (account, null);
        auth_data = account_service.get_auth_data ();
        if (is_new) {
            setup_authentification ();
        }
    }
    
    public override void setup_authentification () {
        main_loop = new GLib.MainLoop ();
        manager = new Ag.Manager ();
        info = new Signon.IdentityInfo ();
        info.set_caption (account.provider);
        info.set_identity_type (Signon.IdentityType.APP);
        info.set_secret ("", true);
        info.set_method ("oauth", {"oauth1", "oauth2", null});
        info.access_control_list_append (new Signon.SecurityContext.from_values ("*", "*"));
        var identity = new Signon.Identity ("switchboard");
        identity.store_credentials_with_info (info, (sel, ide, err) => {IdentityStoreCredentialsCallback (sel, ide, err, this);});
        
        main_loop.run ();
    }
    
    public async void authenticate (Signon.Identity identity, uint32 id) {
        
        GLib.Variant? v_id = new GLib.Variant.uint32 (id);
        account.set_variant (gsignon_id, v_id);
        var oauth_params_builder = new GLib.VariantBuilder (GLib.VariantType.VARDICT);
        var method = account.get_variant ("auth/method", null).get_string ();
        var mechanism = account.get_variant ("auth/mechanism", null).get_string ();
        string[3] host_names = {null, null, null};
        int hosts_count = 0;
        
        if (mechanism == "PLAINTEXT" || mechanism == "HMAC-SHA1" || mechanism == "RSA-SHA1") {
            oauth_params_builder.add ("{sv}", "SignatureMethod", account.get_variant ("auth/mechanism", null));
            method_a = {"oauth1", null};
        } else if (mechanism == "web_server" || mechanism == "user_agent") {
            method_a = {"oauth2", null};
        } else {
            method_a = {"", null};
        }
        
        var host = account.get_variant ("auth/%s/%s/Host".printf(method, mechanism), null);
        if (host != null) {
            oauth_params_builder.add ("{sv}", "AuthHost", host);
            oauth_params_builder.add ("{sv}", "TokenHost", host);
            host_names[hosts_count] = host.get_string ();
            hosts_count++;
        }
        
        var auth_host = account.get_variant ("auth/%s/%s/AuthHost".printf(method, mechanism), null);
        if (auth_host != null) {
            oauth_params_builder.add ("{sv}", "AuthHost", auth_host);
            host_names[hosts_count] = auth_host.get_string ();
            hosts_count++;
        }
        
        var token_host = account.get_variant ("auth/%s/%s/TokenHost".printf(method, mechanism), null);
        if (token_host != null) {
            oauth_params_builder.add ("{sv}", "TokenHost", token_host);
            host_names[hosts_count] = token_host.get_string ();
            hosts_count++;
        }
        
        var path = account.get_variant ("auth/%s/%s/AuthPath".printf(method, mechanism), null);
        if (path != null) {
            oauth_params_builder.add ("{sv}", "AuthPath", path);
        }
        
        var token_path = account.get_variant ("auth/%s/%s/TokenPath".printf(method, mechanism), null);
        if (token_path != null) {
            oauth_params_builder.add ("{sv}", "TokenPath", token_path);
        } else if (path != null){
            oauth_params_builder.add ("{sv}", "TokenPath", path);
        }
        
        var redirect = account.get_variant ("auth/%s/%s/RedirectUri".printf(method, mechanism), null);
        if (redirect != null)
            oauth_params_builder.add ("{sv}", "RedirectUri", redirect);
        
        var client_id = account.get_variant ("auth/%s/%s/ClientId".printf(method, mechanism), null);
        if (client_id != null)
            oauth_params_builder.add ("{sv}", "ClientId", client_id);
        
        var client_secret = account.get_variant ("auth/%s/%s/ClientSecret".printf(method, mechanism), null);
        if (client_secret != null)
            oauth_params_builder.add ("{sv}", "ClientSecret", client_secret);
        
        var response_type = account.get_variant ("auth/%s/%s/ResponseType".printf(method, mechanism), null);
        if (response_type != null)
            oauth_params_builder.add ("{sv}", "ResponseType", response_type);
        else
            oauth_params_builder.add ("{sv}", "ResponseType", new GLib.Variant.string ("code"));
        
        oauth_params_builder.add ("{sv}", "UiPolicy", new GLib.Variant.int32 (Signon.SessionDataUiPolicy.DEFAULT));
        
        var scope = account.get_variant ("auth/%s/%s/Scope".printf(method, mechanism), null);
        if (scope.is_of_type (GLib.VariantType.STRING) && scope != null)
            oauth_params_builder.add ("{sv}", "Scope", scope, null);
        else if(scope.is_of_type (GLib.VariantType.STRING_ARRAY) && scope != null)
            oauth_params_builder.add ("{sv}", "Scope", new GLib.Variant.string (string_from_string_array (scope.get_strv ())));
        
        var schemes = account.get_variant ("auth/%s/%s/AllowedSchemes".printf(method, mechanism), null);
        if (schemes.is_of_type (GLib.VariantType.STRING) && schemes != null)
            oauth_params_builder.add ("{sv}", "AllowedSchemes", scope);
        else if(schemes.is_of_type (GLib.VariantType.STRING_ARRAY) && schemes != null)
            oauth_params_builder.add ("{sv}", "AllowedSchemes", new GLib.Variant.string (string_from_string_array (schemes.get_strv (), ",")));
        
        oauth_params_builder.add ("{sv}", "ForceClientAuthViaRequestBody", new GLib.Variant.boolean (true));
        oauth_params_builder.add ("{sv}", "QueryUserName", new GLib.Variant.boolean (true));
        
        var display = account.get_variant ("auth/%s/%s/Display".printf(method, mechanism), null);
        if (display != null)
            oauth_params_builder.add ("{sv}", "Display", display);
        
        var rqend = account.get_variant ("auth/%s/%s/RequestEndpoint".printf(method, mechanism), null);
        if (rqend != null)
        oauth_params_builder.add ("{sv}", "RequestEndpoint", rqend);
        
        var callback = account.get_variant ("auth/%s/%s/Callback".printf(method, mechanism), null);
        if (callback != null)
        oauth_params_builder.add ("{sv}", "Callback", callback);
        
        var tkend = account.get_variant ("auth/%s/%s/TokenEndpoint".printf(method, mechanism), null);
        if (tkend != null)
            oauth_params_builder.add ("{sv}", "TokenEndpoint", tkend);
        
        var authend = account.get_variant ("auth/%s/%s/AuthorizationEndpoint".printf(method, mechanism), null);
        if (authend != null)
            oauth_params_builder.add ("{sv}", "AuthorizationEndpoint", authend);
        
        var cb = account.get_variant ("auth/%s/%s/Callback".printf(method, mechanism), null);
        if (cb != null)
            oauth_params_builder.add ("{sv}", "Callback", cb);
        
        var consumer_key = account.get_variant ("auth/%s/%s/ConsumerKey".printf(method, mechanism), null);
        if (consumer_key != null)
            oauth_params_builder.add ("{sv}", "ConsumerKey", consumer_key);
        
        var consumer_secret = account.get_variant ("auth/%s/%s/ConsumerSecret".printf(method, mechanism), null);
        if (consumer_secret != null)
            oauth_params_builder.add ("{sv}", "ConsumerSecret", consumer_secret);
        
        var source = account.get_variant ("auth/%s/%s/Source".printf(method, mechanism), null);
        if (source != null)
            oauth_params_builder.add ("{sv}", "Source", source);
        
        var mode = account.get_variant ("auth/%s/%s/Mode".printf(method, mechanism), null);
        if (mode != null)
            oauth_params_builder.add ("{sv}", "Mode", mode);
        
        oauth_params_builder.add ("{sv}", "AllowedRealms", new Variant.strv (host_names));
        oauth_params_builder.add ("{sv}", "Realms", new Variant.strv (host_names));
        
        session_data = oauth_params_builder.end ();
        session_data = auth_data.get_login_parameters (session_data);
            try {
                var session = identity.create_session ("oauth");
                var sequence = Signond.copy_array_to_sequence (host_names);
                session_result = yield session.process_async (session_data, method_a[0], null);
                var access_token = session_result.lookup_value ("AccessToken", null).dup_string ();
                info.set_secret (access_token, true);
            
                foreach (var provider_plugin in OnlineAccounts.PluginsManager.get_default ().get_provider_plugins ()) {
                    if (provider_plugin.plugin_name != "generic-oauth")
                        continue;
                    if (provider_plugin.provider_name != account.provider)
                        continue;
                    provider_plugin.get_user_name (this);
                }
                identity.query_info ((s, i, err) => {IdentityInfoCallback (s, i, err, this);});
            } catch (Error e) {
                critical (e.message);
                main_loop.quit ();
            }
        yield;
    }
    
    // Callbacks
    public static void IdentityStoreCredentialsCallback (Signon.Identity self, uint32 id, GLib.Error error, OAuth2 pr) {
        if (error != null) {
            critical (error.message);
            pr.main_loop.quit ();
            return;
        }
        pr.authenticate.begin (self, id);
    }
    public static void IdentityInfoCallback (Signon.Identity self, Signon.IdentityInfo info, GLib.Error error, OAuth2 pr) {
        if (error != null) {
            critical (error.message);
            pr.main_loop.quit ();
            return;
        }
        pr.account.set_enabled (true);
        pr.account.store_async.begin (null);
        if (pr.is_new == true) {
            AccountsManager.get_default ().add_account (pr);
            pr.is_new = false;
        }
        pr.main_loop.quit ();
    }
}