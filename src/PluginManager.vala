// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2013-2015 Pantheon Developers (https://launchpad.net/switchboard-plug-onlineaccounts)
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
 * Authored by: Corentin Noël <corentin@elementary.io>
 */

public class OnlineAccounts.PluginsManager : GLib.Object {
    
    private static OnlineAccounts.PluginsManager? plugins_manager = null;
    
    public static PluginsManager get_default () {
        if (plugins_manager == null)
            plugins_manager = new PluginsManager ();
        return plugins_manager;
    }
    
    [CCode (has_target = false)]
    private delegate OnlineAccounts.MethodPlugin RegisterMethodPluginFunction (Module module);
    
    [CCode (has_target = false)]
    private delegate OnlineAccounts.ProviderPlugin RegisterProviderPluginFunction (Module module);
    
    private Gee.LinkedList<OnlineAccounts.MethodPlugin> method_plugins;
    private Gee.LinkedList<OnlineAccounts.ProviderPlugin> provider_plugins;
    
    public signal void method_plugin_added (OnlineAccounts.MethodPlugin plug);
    public signal void provider_plugin_added (OnlineAccounts.ProviderPlugin plug);
    
    private PluginsManager () {
        method_plugins = new Gee.LinkedList<OnlineAccounts.MethodPlugin> ();
        provider_plugins = new Gee.LinkedList<OnlineAccounts.ProviderPlugin> ();
        var base_folder = File.new_for_path (Build.PLUGIN_DIR);
        find_plugins (base_folder);
        load_accounts ();
    }

    private void load (string path) {
        if (Module.supported () == false) {
            error ("Pantheon Online Accounts is not supported by this system!");
        }

        Module module = Module.open (path, ModuleFlags.BIND_LAZY);
        if (module == null) {
            critical (Module.error ());
            return;
        }
        
        bool is_method = true;

        void* function;
        module.symbol ("get_method_plugin", out function);
        if (function == null) {
            is_method = false;
        }
        
        if (is_method) {
            
            RegisterMethodPluginFunction register_plugin = (RegisterMethodPluginFunction) function;
            OnlineAccounts.MethodPlugin method = register_plugin (module);
            if (method == null) {
                critical ("Unknown plugin type for %s !", path);
                return;
            }
            module.make_resident ();
            register_method_plugin (method);
        } else {
            
            module.symbol ("get_provider_plugin", out function);
            if (function == null) {
                critical ("neither get_method_plugin () nor get_provider_plugin () functions found in %s", path);
                return;
            }
            
            RegisterProviderPluginFunction register_plugin = (RegisterProviderPluginFunction) function;
            OnlineAccounts.ProviderPlugin provider = register_plugin (module);
            if (provider == null) {
                critical ("Unknown plugin type for %s !", path);
                return;
            }
            module.make_resident ();
            register_provider_plugin (provider);
        }
    }
    
    private void find_plugins (File base_folder) {
        FileInfo file_info = null;
        try {
            var enumerator = base_folder.enumerate_children (FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_TYPE + "," + FileAttribute.STANDARD_CONTENT_TYPE, 0);
            while ((file_info = enumerator.next_file ()) != null) {
                var file = base_folder.get_child (file_info.get_name ());

                if (file_info.get_file_type () == FileType.REGULAR && GLib.ContentType.equals (file_info.get_content_type (), "application/x-sharedlib")) {
                    load (file.get_path ());
                } else if (file_info.get_file_type () == FileType.DIRECTORY) {
                    find_plugins (file);
                }
            }
        } catch (Error err) {
            warning("Unable to scan plugins folder: %s\n", err.message);
        }
    }
    
    public void load_accounts () {
        var manager = new Ag.Manager ();
        foreach (var accountid in manager.list_enabled ()) {
            foreach (var method in method_plugins) {
                try {
                    var account = manager.load_account (accountid);
                    var provider = manager.get_provider (account.get_provider_name ());
                    if (provider == null)
                        continue;
                    if (provider.get_plugin_name ().collate (method.plugin_name) == 0)
                        method.get_account (account);
                } catch (Error e) {
                    critical (e.message);
                }
            }
        }
    }
    
    private void register_method_plugin (OnlineAccounts.MethodPlugin plug) {
        if (method_plugins.contains (plug))
            return;
        method_plugins.add (plug);
        method_plugin_added (plug);
    }
    
    public bool has_method_plugins () {
        return !method_plugins.is_empty;
    }
    
    public Gee.Collection<OnlineAccounts.MethodPlugin> get_method_plugins () {
        return method_plugins.read_only_view;
    }
    
    private void register_provider_plugin (OnlineAccounts.ProviderPlugin plug) {
        if (provider_plugins.contains (plug))
            return;
        provider_plugins.add (plug);
        provider_plugin_added (plug);
    }
    
    public bool has_provider_plugins () {
        return !provider_plugins.is_empty;
    }
    
    public Gee.Collection<OnlineAccounts.ProviderPlugin> get_provider_plugins () {
        return provider_plugins.read_only_view;
    }
}
