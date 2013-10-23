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

namespace OnlineAccounts.Plugins.Facebook {
    
    private const string plugin_name = "facebook";
        
    public class Plugin : Peas.ExtensionBase, Peas.Activatable {
        public GLib.Object object { owned get; construct; }

        public Plugin () {
            GLib.Object ();
        }
        
        internal void translation () {
            var desc = _("Includes Contacts, Gmail, Google Docs, Google+, YouTube and Picasa");
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
        
        public void use_plugin (string plugin, Ag.Account? account = null) {
            if (plugin == plugin_name) {
                var provider = new Provider (account);
                accounts_manager.add_account (provider);
            }
        }
        
    }
}

[ModuleInit]
public void peas_register_types (GLib.TypeModule module) {
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type (typeof (Peas.Activatable),
                                     typeof (OnlineAccounts.Plugins.Facebook.Plugin));
}
