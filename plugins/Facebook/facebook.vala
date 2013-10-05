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
            plugins_manager.new_account_for_provider.connect (new_account_for_provider);
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
                var oauthplugin = new OAuthPlugin (account);
                plugins_manager.plugin_callback (oauthplugin);
            }
        }
        
        public void new_account_for_provider (Ag.Provider provider) {
            new_account_for_provider_async.begin (provider);
        }
        
        public async void new_account_for_provider_async (Ag.Provider provider) {

        if (provider.get_name () == plugin_name) {
                
                var identity = new Signon.Identity ("switchboard");
                var session = identity.create_session ("oauth");
                var oauth_params = new GLib.VariantBuilder (GLib.VariantType.VARDICT);
                oauth_params.add ("{sv}", "AuthHost", new GLib.Variant.string (Config.auth_host));
                oauth_params.add ("{sv}", "AuthPath", new GLib.Variant.string (Config.auth_path));
                oauth_params.add ("{sv}", "TokenHost", new GLib.Variant.string (Config.auth_host));
                oauth_params.add ("{sv}", "TokenPath", new GLib.Variant.string (Config.token_path));
                oauth_params.add ("{sv}", "RedirectUri", new GLib.Variant.string (Config.redirect_uri));
                oauth_params.add ("{sv}", "ClientId", new GLib.Variant.string (Config.client_id));
                oauth_params.add ("{sv}", "ClientSecret", new GLib.Variant.string (Config.client_secret));
                oauth_params.add ("{sv}", "ResponseType", new GLib.Variant.string (Config.response_type));
                oauth_params.add ("{sv}", "UiPolicy", new GLib.Variant.int32 (Signon.SessionDataUiPolicy.DEFAULT));
                oauth_params.add ("{sv}", "Scope", new GLib.Variant.string (string_from_string_array (Config.scopes)));
                oauth_params.add ("{sv}", "AllowedSchemes", new GLib.Variant.string (string_from_string_array (Config.schemes)));
                try {
                    session.state_changed.connect (state_changed );
                    var val = yield session.process_async (oauth_params.end (), "oauth2", null);
                } catch (Error e) {
                    warning (e.message);
                }
                /*var manager = new Ag.Manager ();
                var account = manager.create_account (plugin_name);
                var OAuth = new OAuthPlugin (account);
                var webview = new WebView (OAuth);
                webview.present ();*/
        }

        yield;
        }
        
        private void state_changed (int state, string message) {
            warning ("%i: %s", state, message);
        }
    }
}

[ModuleInit]
public void peas_register_types (GLib.TypeModule module) {
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type (typeof (Peas.Activatable),
                                     typeof (OnlineAccounts.Plugins.FacebookPlugin));
}
