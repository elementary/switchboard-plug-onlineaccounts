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
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
 *
 * Authored by: Corentin Noël <tintou@mailoo.org>
 */

public class OnlineAccounts.Plugins.OAuth.Microsoft.ProviderPlugin : OnlineAccounts.ProviderPlugin {
    public ProviderPlugin () {
        Object (plugin_name: "generic-oauth",
                provider_name: "microsoft");
    }

    public override void get_user_name (OnlineAccounts.Account plugin) {
        var token = plugin.session_result.lookup_value ("AccessToken", null).dup_string ();
        var client_id = plugin.session_data.lookup_value ("ClientId", null).dup_string ();
        var auth_endpoint = plugin.session_data.lookup_value ("RedirectUri", null).dup_string ();
        var proxy = new Rest.OAuth2Proxy.with_token (client_id, token, auth_endpoint, "https://apis.live.net/v5.0/me", false);
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
            weak Json.Object mails_member = root_object.get_object_member ("emails");
            unowned string mail = mails_member.get_string_member ("account");
            plugin.account.set_display_name (mail);
            // Add the login_hint to the query so that the account name is automatically filled
            var account_service = new Ag.AccountService (plugin.account, null);
            var auth_data = account_service.get_auth_data ();
            var key = "auth/%s/%s/AuthQuery".printf (auth_data.get_method (), auth_data.get_mechanism ());
            var auth_query = account_service.get_variant (key, null);
            if (auth_query != null) {
                var variant = new Variant.string ("login_hint=%s&amp;%s".printf (mail, auth_query.get_string ()));
                account_service.set_variant (key, variant);
            } else {
                var variant = new Variant.string ("login_hint=%s".printf (mail));
                account_service.set_variant (key, variant);
            }
        } catch (Error e) {
            critical (e.message);
        }
    }

    public override void get_user_image (OnlineAccounts.Account plugin) {
        
    }
}

public OnlineAccounts.ProviderPlugin get_provider_plugin (Module module) {
    debug ("OnlineAccouts: Activating Microsoft plugin");
    var plugin = new OnlineAccounts.Plugins.OAuth.Microsoft.ProviderPlugin ();
    return plugin;
}
