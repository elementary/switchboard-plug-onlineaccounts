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

public class OnlineAccounts.Plugins.GenericOAuth : OnlineAccounts.MethodPlugin {
    
    public GenericOAuth () {
        Object (plugin_name: "generic-oauth");
    }
    
    public override OnlineAccounts.Account? add_account (Ag.Account account) {
        var plu = new OAuth2 (account, true);
        return plu;
    }
    
    public override OnlineAccounts.Account? get_account (Ag.Account account) {
        var plu = new OAuth2 (account, false);
        AccountsManager.get_default ().add_account (plu);
        return plu;
    }
}

public OnlineAccounts.MethodPlugin get_method_plugin (Module module) {
    debug ("OnlineAccouts: Activating Generic OAuth plugin");
    var plugin = new OnlineAccounts.Plugins.GenericOAuth ();
    return plugin;
}