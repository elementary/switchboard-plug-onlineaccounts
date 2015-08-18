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
public class OnlineAccounts.Plugins.OAuth.Facebook.ProviderPlugin : OnlineAccounts.ProviderPlugin {
    
    public ProviderPlugin () {
        Object (plugin_name: "generic-oauth",
                provider_name: "facebook");
    }
    
    public override void get_user_name (OnlineAccounts.Account plugin) {
        var token = plugin.session_result.lookup_value ("AccessToken", null).dup_string ();
        var client_id = plugin.session_data.lookup_value ("ClientId", null).dup_string ();
        var auth_endpoint = plugin.session_data.lookup_value ("RedirectUri", null).dup_string ();
        var proxy = new Rest.OAuth2Proxy.with_token (client_id, token, auth_endpoint, "https://graph.facebook.com/me", false);
        var call = proxy.new_call ();
        call.set_method ("GET");
        try {
            call.run ();
        } catch (Error e) {
            critical (e.message);
        }
        try {
            var parser = new Json.Parser ();
            parser.load_from_data (call.get_payload (), (ssize_t)call.get_payload_length ());
            var root_object = parser.get_root ().get_object ();
            string username = root_object.get_string_member ("name");
            plugin.account.set_display_name (username);
        } catch (Error e) {
            critical (e.message);
        }
    }
    
    public override void get_user_image (OnlineAccounts.Account plugin) {
        
    }
}

public OnlineAccounts.ProviderPlugin get_provider_plugin (Module module) {
    debug ("OnlineAccouts: Activating Facebook plugin");
    var plugin = new OnlineAccounts.Plugins.OAuth.Facebook.ProviderPlugin ();
    return plugin;
}
