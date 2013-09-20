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

public class OnlineAccounts.GooglePlugin.WebView : Gtk.Dialog {

    WebKit.WebView web_view;

    public WebView (OAuthPlugin plugin) {
        this.title = _("Connect your Google Account");
        set_default_size (480, 420);
        
        this.web_view = new WebKit.WebView ();
        var scrolled_window = new Gtk.ScrolledWindow (null, null);
        scrolled_window.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        scrolled_window.add (this.web_view);
        scrolled_window.expand = true;
        
        var content_area = this.get_content_area ();
        content_area.add (scrolled_window);
        
        string url = "%s://%s/%s".printf (Config.schemes[0], Config.auth_host, Config.auth_path);
        url = url + "?response_type=" + Config.response_type;
        url = url + "&redirect_uri=" + Config.redirect_uri;
        url = url + "&client_id=" + Config.client_id;
        url = url + "&scope=";
        bool first = true;
        foreach (var scope in Config.scopes) {
            if (first) {
                url = url + scope;
                first = false;
            } else
                url = url + "," + scope;
        }
        this.web_view.load_committed.connect ((source, frame) => {
            if (frame.get_uri ().has_prefix (Config.redirect_uri)) {

                string code = frame.get_uri ().replace (Config.redirect_uri, "");
                code = code.replace ("/?code=", "");
                code = code.replace ("?code=", "");
                get_token (code, null);
            }
        });
        
        this.web_view.open (url);
        
        this.show_all ();
    }
    
    private void get_token (string code, string? refresh_token) {
        var proxy = new Rest.Proxy ("https://accounts.google.com/o/oauth2/token", false);
        var call = proxy.new_call ();

        call.set_method ("POST");
        call.add_header ("Content-Type", "application/x-www-form-urlencoded");
        call.add_param ("client_id", Config.client_id);
        call.add_param ("client_secret", Config.client_secret);

        if (refresh_token != null) {
            call.add_param ("grant_type", "refresh_token");
            call.add_param ("refresh_token", refresh_token);
        } else {
            call.add_param ("grant_type", "authorization_code");
            call.add_param ("redirect_uri", Config.redirect_uri);
            call.add_param ("code", code);
        }

        try {
            call.sync ();
        } catch (Error error) {
            critical (error.message);
        }

        var status_code = call.get_status_code ();
        if (status_code != 200) {
          critical (_("Expected status 200 when requesting access token, instead got status %d (%s)"), status_code, call.get_status_message ());
          return;
        }

        var payload = call.get_payload ();
        var payload_length = call.get_payload_length ();
        int64 ret_access_token_expires_in;
        string ret_access_token = "";
        string ret_refresh_token = "";
        /* some older OAuth2 implementations does not return json - handle that too */
        if (payload.has_prefix ("access_token=")) {

            debug ("Response is not JSON - possibly old OAuth2 implementation");

            GLib.HashTable<string,string> hash = Soup.Form.decode (payload);
            ret_access_token = hash.lookup ("access_token");
            if (ret_access_token == null) {
                warning ("Did not find access_token in non-JSON data");
            }
            /* refresh_token is optional */
            ret_refresh_token = hash.lookup ("refresh_token");
            /* expires_in is optional */
            var expires_in_str = hash.lookup ("expires_in");
            /* sometimes "expires_in" appears as "expires" */
            if (expires_in_str == null)
                expires_in_str = hash.lookup ("expires");
            if (expires_in_str != null)
                ret_access_token_expires_in = (int64) expires_in_str;
        } else {

            var parser = new Json.Parser ();
            try {
                parser.load_from_data (payload, (ssize_t)payload_length);
            } catch (Error e) {
                critical (e.message);
            }
            var object = parser.get_root ().get_object ();
            ret_access_token = object.get_string_member ("access_token");
            if (ret_access_token == null) {
              warning ("Did not find access_token in JSON data");
            }
            /* refresh_token is optional... */
            if (object.has_member ("refresh_token"))
                ret_refresh_token = object.get_string_member ("refresh_token");
            if (object.has_member ("expires_in"))
                ret_access_token_expires_in = object.get_int_member ("expires_in");
        }
        
        warning (ret_access_token);
    }
    
    private void token_callback (Soup.Message msg) {
        /*warning ((string)msg.response_body.data);
        if (msg.status_code != Soup.KnownStatusCode.OK && msg.status_code != Soup.KnownStatusCode.BAD_REQUEST) {
            critical ("Token endpoint returned an error: %u %s", msg.status_code, msg.reason_phrase);
            //return;
        }
        
        var parser = new Json.Parser ();
        bool res = parser.load_from_data ((string)msg.response_body.data);
        if (res == false) {
            //_issue_not_authorized_error(self, "Json parser returned an error");
            critical ("Json parser returned an error");
            return;
        }
        
        if (parser.get_root ().get_node_type () != Json.NodeType.OBJECT) {
            //_issue_not_authorized_error(self, "Json top-level structure is not an object");
            critical ("Json top-level structure is not an object");
            return;        
        }
        
        var params = _get_json_params(json_node_get_object(json_parser_get_root(parser)));
        g_object_unref(parser);

        // if using a refresh token failed, go back to full authentication process
        // using supplied credentials info
        const gchar* error = g_hash_table_lookup(params, "error");
        if (error != NULL && g_strcmp0(error, "invalid_grant") == 0 &&
                gsignond_dictionary_get(self->oauth2_request, "_Oauth2UseRefresh") != NULL) {
            gsignond_dictionary_remove(self->oauth2_request, "_Oauth2UseRefresh");
            g_hash_table_unref(params);
            GSignondSessionData* session_data = self->oauth2_request;
            self->oauth2_request = NULL;
            GSignondDictionary* token_cache = self->token_cache;
            self->token_cache = NULL;
            _request_new_token(self, session_data, token_cache);
            g_hash_table_unref(session_data);
            g_hash_table_unref(token_cache);
            return;
        }
        
        if (error != NULL) {
            _do_reset_oauth2(self);
            _process_auth_error(self, params);
            g_hash_table_unref(params);
            return;
        }
        
        // "client_credentials" grant type doesn't allow refresh tokens
        // RFC 6749 4.4.3
        if (g_strcmp0(gsignond_dictionary_get_string(self->oauth2_request, "GrantType"),
            "client_credentials") == 0)
            g_hash_table_remove(params, "refresh_token");
        
        _process_access_token(self, params);
        
        g_hash_table_unref(params);*/
        this.hide ();
    }
}
