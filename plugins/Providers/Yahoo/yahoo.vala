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
public class OnlineAccounts.Plugins.OAuth.Yahoo.ProviderPlugin : OnlineAccounts.ProviderPlugin {
    
    public ProviderPlugin () {
        Object (plugin_name: "generic-oauth",
                provider_name: "yahoo");
    }
    
    public override void get_user_name (OnlineAccounts.Account plugin) {
        var token_secret = plugin.session_result.lookup_value ("TokenSecret", null).dup_string ();
        var consumer_key = plugin.session_data.lookup_value ("ConsumerKey", null).dup_string ();
        var consumer_secret = plugin.session_data.lookup_value ("ConsumerSecret", null).dup_string ();
        var token = plugin.session_result.lookup_value ("AccessToken", null).dup_string ();

        try {
            var proxy = new Rest.OAuthProxy.with_token (consumer_key, consumer_secret, token, token_secret, "http://social.yahooapis.com/v1/me/guid", false);
            var call = proxy.new_call ();
            call.set_method ("GET");
            call.add_param ("format", "xml");
            call.run ();
            string content = get_string_from_call (call);
            if (content == null)
                return;
            string guid = content.split ("<value>", 2)[1].split ("</value>", 2)[0];
            if (guid == null || guid == "")
                return;
            proxy.url_format = "http://social.yahooapis.com/v1/user/%s/profile/usercard".printf (guid);
            try {
                var call2 = proxy.new_call ();
                call2.set_method ("GET");
                call2.add_param ("format", "xml");
                call2.run ();
                content = get_string_from_call (call2);
                if (content == null)
                    return;
                string name = content.split ("<nickname>", 2)[1].split ("</nickname>", 2)[0];

                plugin.account.set_display_name (name);
            } catch (Error e) {
                critical (e.message);
            }
        } catch (Error e) {
            critical (e.message);
        }
    }
    
    public override void get_user_image (OnlineAccounts.Account plugin) {
        
    }
    
    private string get_string_from_call (Rest.ProxyCall call) {
        string payload = call.get_payload ();
        int64 len = call.get_payload_length ();

        // We interpret the result as data:
        unowned uint8[] arr = (uint8[]) payload;
        arr.length = (int) len;
        return (string) arr;
    }
}

public OnlineAccounts.ProviderPlugin get_provider_plugin (Module module) {
    debug ("OnlineAccouts: Activating Yahoo plugin");
    var plugin = new OnlineAccounts.Plugins.OAuth.Yahoo.ProviderPlugin ();
    return plugin;
}