// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2016 elementary LLC. (https://elementary.io)
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
 * Authored by: Corentin Noël <corentin@elementary.io>
 */

public class OnlineAccounts.Plugins.MailMethod : OnlineAccounts.MethodPlugin {
    
    public MailMethod () {
        Object (plugin_name: "mail");
    }
    
    public override OnlineAccounts.Account? add_account (Ag.Account account) {
        var plu = new MailAccount (account, true);
        return plu;
    }
    
    public override OnlineAccounts.Account? get_account (Ag.Account account) {
        var plu = new MailAccount (account, false);
        AccountsManager.get_default ().add_account (plu);
        return plu;
    }
}

public OnlineAccounts.MethodPlugin get_method_plugin (Module module) {
    debug ("OnlineAccouts: Activating Mail plugin");
    var plugin = new OnlineAccounts.Plugins.MailMethod ();
    return plugin;
}
