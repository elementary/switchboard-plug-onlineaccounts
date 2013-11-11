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

namespace OnlineAccounts.Plugins {
    public class Manager : Object {
        public signal void use_plugin (Ag.Account account, bool new_account = false);
        public signal void get_subplugins ();
        
        public Gee.ArrayList<string> plugins_available;
        public Gee.ArrayList<SubPlugin> subplugins_available;
        public Gee.ArrayList<string> subplugins_name_available;
        
        static Gee.LinkedList<TypeModule> modules;
        
        public Manager () {
            plugins_available = new Gee.ArrayList<string> ();
            subplugins_available = new Gee.ArrayList<SubPlugin> ();
            subplugins_name_available = new Gee.ArrayList<string> ();
            modules = new Gee.LinkedList<TypeModule> ();
        }
        
        public void activate () {
            var file = GLib.File.new_for_path (Build.PLUGIN_DIR);
            list_children (file, Build.PLUGIN_DIR);
        }
        
        private void list_children (File file, string path) throws Error {
            FileEnumerator enumerator = file.enumerate_children (GLib.FileAttribute.STANDARD_NAME, FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null);

            FileInfo info = null;
            while ((info = enumerator.next_file (null)) != null) {
                if (info.get_file_type () == FileType.DIRECTORY) {
                    File subdir = file.resolve_relative_path (info.get_name ());
                    list_children (subdir, subdir.get_path ());
                } else {
                    var name = info.get_name ();
                    if (name.has_suffix(".so")) {
                        name = name.replace(".so", "");
                        name = name.replace("lib", "");
                        TypeModule module = new OAModule(name, path);
                        
                        modules.add (module);
                        module.load ();
                    }
                }
            }
        }
        
        public void load_accounts () {
            var manager = new Ag.Manager ();
            foreach (var accountid in manager.list_enabled ()) {
                try {
                    var account = manager.load_account (accountid);
                    use_plugin (account, false);
                } catch (Error e) {
                    critical (e.message);
                }
            }
            get_subplugins ();
        }
        
        public void register_plugin (string plugin) {
            plugins_available.add (plugin);
        }
        
        public void register_subplugin (SubPlugin plugin) {
            subplugins_available.add (plugin);
        }
    }

    class OAModule : TypeModule {
        [CCode (has_target = false)]
        private delegate Type PluginInitFunc (TypeModule module);
        
        private GLib.Module module = null;
        
        private string name = null;
        private string path = null;
        
        public OAModule (string name, string path)
        {
            this.name = name;
            this.path = path;
        }
        
        public override bool load ()
        {
            string path = Module.build_path (path, name);
            module = Module.open (path, GLib.ModuleFlags.BIND_LAZY);
            if(null == module) {
                    critical ("Module not found in path: %s", path);
            }
            
            module.make_resident ();
            void * plugin_init = null;
            if(! module.symbol("plugin_init", out plugin_init)) {
                    critical ("No 'plugin_init' symbol for module %s in %s", name, path);
            }
            
            ((PluginInitFunc) plugin_init)(this);
            
            return true;
        }
        
        public override void unload ()
        {
            module = null;
            
            message("Library unloaded");
        }
    }
}
