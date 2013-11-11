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

public class OnlineAccounts.StorageManager : Signond.StorageManager {
    string location;
    construct {
        location = null;
    }
    
    public override bool initialize_storage () {
        string try_location = GLib.Environment.get_user_config_dir ();
        string user_dir = "gsignond";
        if (config != null)
            try_location = config.get_string ("General/StoragePath");
        
        if (try_location != "/var/db" && try_location == "" && try_location == null) {
            user_dir = "gsignond.%s".printf (GLib.Environment.get_user_name ());
        } else {
            try_location = GLib.Environment.get_user_config_dir ();
        }
        
        location = GLib.Path.build_filename (try_location, user_dir);
        return GLib.DirUtils.create_with_parents (location, (int) Posix.S_IRWXU|Posix.S_IRWXG) == 0;
    }
    
    public override bool delete_storage () {
        var file = File.new_for_path (location);
        try {
            file.delete ();
            return true;
        } catch (Error e) {
            critical (e.message);
            return false;
        }
    }
    
    public override bool storage_is_initialized () {
        return Posix.access (location, Posix.F_OK) == 0;
    }
    
    public override string mount_filesystem () {
        return location;
    }
    
    public override bool unmount_filesystem () {
        return true;
    }
    
    public override bool filesystem_is_mounted () {
        return storage_is_initialized ();
    }
    
}

