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
 * Authored by: Zeeshan Ali (Khattak) <zeeshanak@gnome.org> (from Rygel)
 *              Lucas Baudin <xapantu@gmail.com> (from Pantheon Files)
 *              Corentin Noël <tintou@mailoo.org>
 */

public class OnlineAccounts.Plugins.Interface : Object {
    Manager manager;
    
    public string set_name {internal set; get; }
    public string? argument {internal set; get; }

    public Interface (Manager manager) {
        this.manager = manager;
    }
    
}


public class OnlineAccounts.Plugins.Manager : Object {
    Peas.Engine engine;
    Peas.ExtensionSet exts;
    public signal void use_plugin (string plugin, Ag.Account account);
    public signal void new_account_for_provider (Ag.Provider provider);
    public signal void plugin_callback (OnlineAccounts.Plugin plugin);
    
    public OnlineAccounts.Plugins.Interface plugin_iface { private set; get; }
    public Gee.ArrayList<string> plugins_available;

    public Manager(string d, string? e, string? argument_set) {
        plugins_available = new Gee.ArrayList<string> ();
        plugin_iface = new OnlineAccounts.Plugins.Interface (this);
        plugin_iface.argument = argument_set;
        plugin_iface.set_name = e ?? "online accounts";

        /* Let's init the engine */
        engine = Peas.Engine.get_default ();
        engine.enable_loader ("python");
        engine.enable_loader ("gjs");
        engine.add_search_path (d, null);
        
    }
    
    public void activate () {
        
        foreach (var plugin in engine.get_plugin_list ()) {
            engine.try_load_plugin (plugin);
        }

        /* Our extension set */
        Parameter param = Parameter ();
        param.value = plugin_iface;
        param.name = "object";
        exts = new Peas.ExtensionSet (engine, typeof (Peas.Activatable), "object", plugin_iface, null);

        exts.extension_added.connect( (info, ext) => {  
            ((Peas.Activatable)ext).activate ();
        });
        exts.extension_removed.connect (on_extension_removed);
        
        exts.foreach (on_extension_added);
    }
    
    void on_extension_added (Peas.ExtensionSet set, Peas.PluginInfo info, Peas.Extension extension) {
        foreach (var plugin in engine.get_plugin_list ()) {
            string module = plugin.get_module_name ();
            if (module == info.get_module_name ()) {
                ((Peas.Activatable)extension).activate();
            }
        }
    }

    void on_extension_removed (Peas.PluginInfo info, Object extension) {
        ((Peas.Activatable)extension).deactivate();
    }
    
    public void load_accounts () {
        var manager = new Ag.Manager ();
        foreach (var accountid in manager.list_enabled ()) {
            try {
                var account = manager.load_account (accountid);
                use_plugin (account.provider, account);
            } catch (Error e) {
                critical (e.message);
            }
        }
    }
    
    public void register_plugin (string plugin) {
        plugins_available.add (plugin);
    }
}

