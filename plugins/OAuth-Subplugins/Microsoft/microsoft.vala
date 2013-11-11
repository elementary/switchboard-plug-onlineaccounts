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
[ModuleInit]
void plugin_init (GLib.TypeModule type_module)
{
    if (OnlineAccounts.plugins_manager.plugins_available.contains (OnlineAccounts.Plugins.OAuth.subplugin_name))
        return;
    debug ("Activating Microsoft plugin");
    OnlineAccounts.plugins_manager.subplugins_name_available.add (OnlineAccounts.Plugins.OAuth.subplugin_name);
    OnlineAccounts.plugins_manager.get_subplugins.connect (register_subplugin);
}

private void register_subplugin () {
    var subplugin = new OnlineAccounts.Plugins.OAuth.Microsoft.SubPlugin ();
    OnlineAccounts.plugins_manager.register_subplugin (subplugin);
}

namespace OnlineAccounts.Plugins.OAuth {
    private const string plugin_name = "generic-oauth";
    private const string subplugin_name = "microsoft";
}
