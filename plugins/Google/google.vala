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

namespace OnlineAccounts.GooglePlugin {
    
    private const string plugin_name = "google";
    
    public class OAuthPlugin : OnlineAccounts.OAuthPlugin {
        private enum ParametersUser
        {
            ACCOUNT_PLUGIN,
            CLIENT_APPLICATIONS
        }

        public OAuthPlugin (Ag.Account account) {
            base (account);
            
            set_mechanism (OnlineAccounts.OAuthPlugin.OAuthMechanism.WEB_SERVER);
            
            ignore_cookies = true;
            
            /*oauth_params.insert ("AuthHost", "accounts.google.com");
            oauth_params.insert ("AuthPath", "o/oauth2/auth");
            oauth_params.insert ("TokenPath", "o/oauth2/token");
            oauth_params.insert ("RedirectUri",
                                 "http://elementaryos.org/");
            oauth_params.insert ("ClientId", Config.GOOGLE_CLIENT_ID);
            oauth_params.insert ("ClientSecret", Config.GOOGLE_CLIENT_SECRET);
            
            account_oauth_params.insert ("AuthHost", "accounts.google.com");
            account_oauth_params.insert ("AuthPath", "o/oauth2/auth");
            account_oauth_params.insert ("TokenPath", "o/oauth2/token");
            account_oauth_params.insert ("RedirectUri",
                                 "http://elementaryos.org/");
            account_oauth_params.insert ("ClientId", Config.GOOGLE_CLIENT_ID);
            account_oauth_params.insert ("ClientSecret", Config.GOOGLE_CLIENT_SECRET);*/

            /* Note the evil trick here: Google uses a couple of non-standard OAuth
             * parameters: "access_type" and "approval_prompt"; the signon OAuth
             * plugin doesn't (yet?) give us a way to provide extra parameters, so
             * we fool it by appending them to the value of the "ResponseType".
             *
             * We need to specify "access_type=offline" if we want Google to return
             * us a refresh token.
             */
            /* The "approval_prompt=force" string forces Google to ask for
             * authentication. */
            /*oauth_params.insert ("ResponseType",
                                 "code&access_type=offline&approval_prompt=force");
            account_oauth_params.insert ("ResponseType",
                                 "code&access_type=offline");*/
        }
        
        internal void translation () {
            var desc = _("Includes Contacts, Gmail, Google Docs, Google+, YouTube and Picasa");
        }
    }
        
    public class GooglePlugin : Peas.ExtensionBase, Peas.Activatable {
        public GLib.Object object { owned get; construct; }

        public GooglePlugin () {
          GLib.Object ();
        }
        
        public void activate () {
            debug ("Activating Google plugin");
            plugins_manager.use_plugin.connect (use_plugin);
            plugins_manager.new_account_for_provider.connect (new_account_for_provider);
            plugins_manager.register_plugin (plugin_name);
        }

        public void deactivate () {
            debug ("Deactivating Google plugin");
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
            if (provider.get_name () == plugin_name) {
                var identity = new Signon.Identity ();
                
                /*var manager = new Ag.Manager ();
                var account = manager.create_account (plugin_name);
                var OAuth = new OAuthPlugin (account);
                var webview = new WebView (OAuth);
                webview.present ();*/
            }
        }
    }
}

[ModuleInit]
public void peas_register_types (GLib.TypeModule module) {
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type (typeof (Peas.Activatable),
                                     typeof (OnlineAccounts.GooglePlugin.GooglePlugin));
}
