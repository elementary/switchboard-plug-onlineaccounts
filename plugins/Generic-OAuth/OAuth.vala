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

namespace OnlineAccounts.Plugins.OAuth {
    
    private const string plugin_name = "generic-oauth";
        
    public class Plugin : Peas.ExtensionBase, Peas.Activatable {
        public GLib.Object object { owned get; construct; }

        public Plugin () {
            GLib.Object ();
        }
        
        internal void translation () {
            var desc = _("Includes Contacts, Gmail, Google Docs, Google+, YouTube and Picasa");
        }
        
        public void activate () {
            debug ("Activating OAuth plugin");
            plugins_manager.use_plugin.connect (use_plugin);
            plugins_manager.register_plugin (plugin_name);
        }

        public void deactivate () {
            debug ("Deactivating OAuth plugin");
            plugins_manager.use_plugin.disconnect (use_plugin);
        }

        public void update_state () {
            // do nothing
        }
        
        public void use_plugin (Ag.Account account, bool is_new = false) {
            var manager = new Ag.Manager ();
            var provider = manager.get_provider (account.provider);
            if (provider.get_plugin_name () == plugin_name) {
                var plu = new OAuth2 (account, is_new);
                if (is_new == false)
                    accounts_manager.add_account (plu);
            }
        }
        
    }
}

[ModuleInit]
public void peas_register_types (GLib.TypeModule module) {
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type (typeof (Peas.Activatable),
                                     typeof (OnlineAccounts.Plugins.OAuth.Plugin));
}
