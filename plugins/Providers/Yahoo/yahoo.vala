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

        var proxy = new Rest.OAuthProxy.with_token (consumer_key, consumer_secret, token, token_secret, "https://social.yahooapis.com/v1/me/guid", false);
        var call = proxy.new_call ();
        call.set_method ("GET");
        call.add_param ("format", "json");
        try {
            call.run ();
        } catch (Error e) {
            critical (e.message);
            return;
        }

        string guid = null;
        try {
            var parser = new Json.Parser ();
            parser.load_from_data (call.get_payload (), (ssize_t)call.get_payload_length ());
            weak Json.Object root_object = parser.get_root ().get_object ().get_object_member ("guid");
            guid = root_object.get_string_member ("value");
        } catch (Error e) {
            critical (e.message);
        }

        if (guid == null)
            return;

        proxy.url_format = "https://social.yahooapis.com/v1/user/%s/profile/usercard".printf (guid);
        try {
            call = proxy.new_call ();
            call.set_method ("GET");
            call.add_param ("format", "json");
            call.run ();
        } catch (Error e) {
            critical (e.message);
            return;
        }

        try {
            var parser = new Json.Parser ();
            parser.load_from_data (call.get_payload (), (ssize_t)call.get_payload_length ());
            weak Json.Object root_object = parser.get_root ().get_object ().get_object_member ("profile");
            plugin.account.set_display_name (root_object.get_string_member ("nickname"));
        } catch (Error e) {
            critical (e.message);
        }
    }

    public override void get_user_image (OnlineAccounts.Account plugin) {
        
    }
}

public OnlineAccounts.ProviderPlugin get_provider_plugin (Module module) {
    debug ("OnlineAccouts: Activating Yahoo plugin");
    var plugin = new OnlineAccounts.Plugins.OAuth.Yahoo.ProviderPlugin ();
    return plugin;
}
