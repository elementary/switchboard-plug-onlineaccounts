/*
 * Copyright (C) 2012 Collabora Ltd.
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
 *      Xavier Claessens <xavier.claessens@collabora.co.uk>
 */

namespace OnlineAccounts.Plugins {
    
    private const string plugin_name = "microsoft";
    
    public class MicrosoftOAuthPlugin : OnlineAccounts.OAuthPlugin {
        public MicrosoftOAuthPlugin (Ag.Account account) {
            base (account);
            oauth_params.insert ("Host", "login.live.com");
            oauth_params.insert ("AuthPath", "/oauth20_authorize.srf");
            oauth_params.insert ("TokenPath", "/oauth20_token.srf");
            oauth_params.insert ("RedirectUri", "https://login.live.com/oauth20_desktop.srf");
            oauth_params.insert ("ClientId", Config.MICROSOFT_CLIENT_ID);
            oauth_params.insert ("ResponseType", "code");
            oauth_params.insert ("Display", "popup");
            string[] scopes = {
                "wl.offline_access",
                "wl.calendars",
                "wl.contacts_create"
            };
            oauth_params.insert ("Scope", scopes);
            set_mechanism (OnlineAccounts.OAuthPlugin.OAuthMechanism.WEB_SERVER);
        }
    }
    public class MicrosoftPlugin : Peas.ExtensionBase, Peas.Activatable {
        public GLib.Object object { owned get; construct; }

        public MicrosoftPlugin () {
          GLib.Object ();
        }
        
        public void activate () {
            debug ("Activating Microsoft plugin");
            plugins_manager.use_plugin.connect (use_plugin);
            plugins_manager.register_plugin (plugin_name);
        }

        public void deactivate () {
            debug ("Deactivating Microsoft plugin");
            plugins_manager.use_plugin.disconnect (use_plugin);
        }

        public void update_state () {
            // do nothing
        }
        
        public void use_plugin (string plugin, Ag.Account account) {
            if (plugin == plugin_name) {
                var microsoft_oauthplugin = new MicrosoftOAuthPlugin (account);
                plugins_manager.plugin_callback (microsoft_oauthplugin);
            }
        }
    }
}

[ModuleInit]
public void peas_register_types (GLib.TypeModule module) {
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type (typeof (Peas.Activatable),
                                     typeof (OnlineAccounts.Plugins.MicrosoftPlugin));
}
