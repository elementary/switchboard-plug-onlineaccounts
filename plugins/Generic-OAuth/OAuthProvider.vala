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

public class OnlineAccounts.Plugins.OAuth2 : Plugin {

    public OAuth2 (Ag.Account account, bool is_new = false) {
        base (account, is_new);
        if (is_new) {
            authenticate.begin ();
        }
    }
    
    public override async void authenticate () {
        
        var manager = new Ag.Manager ();
        var provider = manager.get_provider (account.provider);
        var identity = new Signon.Identity ("switchboard");
        var session = identity.create_session ("oauth");
        var oauth_params_builder = new GLib.VariantBuilder (GLib.VariantType.VARDICT);
        var method = account.get_variant ("auth/method", null).get_string ();
        var mechanism = account.get_variant ("auth/mechanism", null).get_string ();
        
        string[] method_a;
        if (mechanism == "PLAINTEXT" || mechanism == "HMAC-SHA1" || mechanism == "RSA-SHA1")
            method_a = {"oauth1", null};
        else if (mechanism == "web_server" || mechanism == "user_agent")
            method_a = {"oauth2", null};
        else
            return;
        
        var host = account.get_variant ("auth/%s/%s/Host".printf(method, mechanism), null);
        if (host != null) {
            oauth_params_builder.add ("{sv}", "AuthHost", host);
            oauth_params_builder.add ("{sv}", "TokenHost", host);
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
        if (scope.is_of_type (GLib.VariantType.STRING))
            oauth_params_builder.add ("{sv}", "Scope", scope, null);
        else if(scope.is_of_type (GLib.VariantType.STRING_ARRAY))
            oauth_params_builder.add ("{sv}", "Scope", new GLib.Variant.string (string_from_string_array (scope.get_strv ())));
        
        var schemes = account.get_variant ("auth/%s/%s/AllowedSchemes".printf(method, mechanism), null);
        if (schemes.is_of_type (GLib.VariantType.STRING))
            oauth_params_builder.add ("{sv}", "AllowedSchemes", scope);
        else if(schemes.is_of_type (GLib.VariantType.STRING_ARRAY))
            oauth_params_builder.add ("{sv}", "AllowedSchemes", new GLib.Variant.string (string_from_string_array (schemes.get_strv (), ",")));
        
        oauth_params_builder.add ("{sv}", "ForceClientAuthViaRequestBody", new GLib.Variant.boolean (true));
        
        var display = account.get_variant ("auth/%s/%s/Display".printf(method, mechanism), null);
        if (display != null)
            oauth_params_builder.add ("{sv}", "Display", display);
        
        var rqend = account.get_variant ("auth/%s/%s/RequestEndpoint".printf(method, mechanism), null);
        if (rqend != null)
        oauth_params_builder.add ("{sv}", "RequestEndpoint", rqend);
        
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
        
        var oauth_params = oauth_params_builder.end ();
        try {
            GLib.Variant val = yield session.process_async (oauth_params, method_a[0], null);
            var token_type = val.lookup_value ("TokenType", null).dup_string ();
            var duration = val.lookup_value ("Duration", null).get_int64 ();
            var timestamp = val.lookup_value ("Timestamp", null).get_int64 ();
            var access_token = val.lookup_value ("AccessToken", null).dup_string ();
            VariantIter iter = oauth_params.iterator ();
            GLib.Variant? vari = null;
            string? key = null;

            while (iter.next ("{sv}", &key, &vari)) {
                account.set_variant (key, vari);
            }
            account.set_enabled (true);
            var info = new Signon.IdentityInfo ();
            info.set_method ("oauth", {"oauth2", null});
            info.set_secret (access_token, true);
            identity.store_credentials_with_info (info, (self, id, error) => {IdentityStoreCredentialsCallback1 (self, id, error, this);});
        } catch (Error e) {
            critical (e.message);
        }
        yield;
    }
    
    public void query_info_from_callback (Signon.Identity id) {
        id.query_info ((s, i, err) => {IdentityInfoCallback (s, i, err, this);});
    }
    
    public void store_credentials_from_callback (Signon.Identity id, Signon.IdentityInfo info) {
        account.set_display_name (info.get_username ());
        id.store_credentials_with_info (info, (sel, ide, err) => {IdentityStoreCredentialsCallback2 (sel, ide, err, this);});
    }
    
    /*private string query_mail_address (string token_type, string token) {
        var session = new Soup.SessionSync ();
        var msg = new Soup.Message ("GET", "https://www.googleapis.com/oauth2/v1/userinfo?access_token=" + token);
        msg.request_headers.append ("Authorization", token_type + " " + token);
        session.send_message (msg);
        try {
            var parser = new Json.Parser ();
            parser.load_from_data ((string) msg.response_body.flatten ().data, -1);

            var root_object = parser.get_root ().get_object ();
            string mail = root_object.get_string_member ("email");
            return mail;
        } catch (Error e) {
            critical (e.message);
        }
        return "";
    }*/
    
    public static void IdentityStoreCredentialsCallback1 (Signon.Identity self, uint32 id, GLib.Error error, OAuth2 pr) {
        if (error != null) {
            critical (error.message);
            return;
        }
        pr.query_info_from_callback (self);
    }
    
    public static void IdentityStoreCredentialsCallback2 (Signon.Identity self, uint32 id, GLib.Error error, OAuth2 pr) {
        if (error != null) {
            critical (error.message);
            return;
        }
        
        GLib.Variant? v_id = new GLib.Variant.uint32 (id);
        pr.account.set_variant (gsignon_id, v_id);
        pr.account.store_async.begin (null);
        if (pr.is_new == true) {
            accounts_manager.add_account (pr);
            pr.is_new = false;
        }
    }
    
    public static void IdentityInfoCallback (Signon.Identity self, Signon.IdentityInfo info, GLib.Error error, OAuth2 pr) {
        if (error != null) {
            critical (error.message);
            return;
        }
        pr.store_credentials_from_callback (self, info);
    }
}
