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

namespace OnlineAccounts.Plugins.OAuth.Microsoft {
    
    private const string plugin_name = "generic-oauth";
    private const string subplugin_name = "microsoft";
        
    public class Plugin : Peas.ExtensionBase, Peas.Activatable {
        public GLib.Object object { owned get; construct; }
        public SubPlugin subplugin;

        public Plugin () {
            GLib.Object ();
        }
        
        public void activate () {
            debug ("Activating Microsoft plugin");
            subplugin = new SubPlugin ();
            plugins_manager.register_subplugin (subplugin);
        }

        public void deactivate () {
            debug ("Deactivating Microsoft plugin");
        }

        public void update_state () {
            // do nothing
        }
        
    }
}

[ModuleInit]
public void peas_register_types (GLib.TypeModule module) {
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type (typeof (Peas.Activatable),
                                     typeof (OnlineAccounts.Plugins.OAuth.Microsoft.Plugin));
}
