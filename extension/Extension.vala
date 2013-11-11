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

namespace OnlineAccounts {
    
    public class Extension : Signond.Extension {
        
        OnlineAccounts.Keyring keyring;
        OnlineAccounts.StorageManager storage_manager;
        
        public override string get_extension_name () {
            return "pantheon";
        }
        
        public override int32 get_extension_version () {
            return 0;
        }
        
        public override Signond.StorageManager get_storage_manager (Signond.Config config) {
            if (storage_manager == null) {
                storage_manager = (OnlineAccounts.StorageManager)GLib.Object.new (typeof(OnlineAccounts.StorageManager), "config", config, null);
            }
            return storage_manager;
        
        }
        
        public override Signond.SecretStorage get_secret_storage (Signond.Config config) {
            if (keyring == null) {
                keyring = new OnlineAccounts.Keyring ();
                keyring.open_db ();
            }
            return keyring;
        }
        
        public override Signond.AccessControlManager get_access_control_manager (Signond.Config config) {
            return base.get_access_control_manager (config);
        }
        
    }
}

static Signond.Extension test_extension = null;
Signond.Extension pantheon_extension_init () {
    if (test_extension == null) {
        test_extension = new OnlineAccounts.Extension ();
    }
    return test_extension;
}
