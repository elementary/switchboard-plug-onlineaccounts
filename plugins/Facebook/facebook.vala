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

namespace OnlineAccounts.Plugins {
    
    private const string plugin_name = "facebook";

    public class FacebookOAuthPlugin : OnlineAccounts.OAuthPlugin {
        public FacebookOAuthPlugin (Ag.Account account) {
            base (account);
            oauth_params.insert ("Host", "www.facebook.com");
            oauth_params.insert ("AuthPath", "/dialog/oauth");
            oauth_params.insert ("RedirectUri",
                                 "https://www.facebook.com/connect/login_success.html");
            oauth_params.insert ("ClientId", Config.FACEBOOK_CLIENT_ID);
            oauth_params.insert ("Display", "popup");
            string[] scopes = {
                "publish_stream",
                "read_stream",
                "status_update",
                "user_photos",
                "friends_photos",
                "xmpp_login"
            };
            oauth_params.insert ("Scope", scopes);
        }
    }
    
    public class FacebookPlugin : Peas.ExtensionBase, Peas.Activatable {
        public GLib.Object object { owned get; construct; }

        public FacebookPlugin () {
          GLib.Object ();
        }
        
        public void activate () {
            debug ("Activating Facebook plugin");
            plugins_manager.use_plugin.connect (use_plugin);
            plugins_manager.register_plugin (plugin_name);
        }

        public void deactivate () {
            debug ("Deactivating Facebook plugin");
            plugins_manager.use_plugin.disconnect (use_plugin);
        }

        public void update_state () {
            // do nothing
        }
        
        public void use_plugin (string plugin, Ag.Account account) {
            if (plugin == plugin_name) {
                var facebook_oauthplugin = new FacebookOAuthPlugin (account);
                plugins_manager.plugin_callback (facebook_oauthplugin);
            }
        }
    }
}

[ModuleInit]
public void peas_register_types (GLib.TypeModule module) {
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type (typeof (Peas.Activatable),
                                     typeof (OnlineAccounts.Plugins.FacebookPlugin));
}
