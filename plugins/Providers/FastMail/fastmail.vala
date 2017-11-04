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
public class OnlineAccounts.Plugins.OAuth.FastMail.ProviderPlugin : OnlineAccounts.ProviderPlugin {
    
    public ProviderPlugin () {
        Object (plugin_name: "password",
                provider_name: "fastmail");
    }
    
    public override void get_user_name (OnlineAccounts.Account plugin) {
        var name = plugin.session_result.lookup_value ("UserName", null).dup_string ();
        if (!("@" in name)) {
            plugin.account.set_display_name (name + "@fastmail.fm");
        }
    }
    
    public override void get_user_image (OnlineAccounts.Account plugin) {
        
    }
}

public OnlineAccounts.ProviderPlugin get_provider_plugin (Module module) {
    debug ("OnlineAccouts: Activating FastMail plugin");
    var plugin = new OnlineAccounts.Plugins.OAuth.FastMail.ProviderPlugin ();
    return plugin;
}
