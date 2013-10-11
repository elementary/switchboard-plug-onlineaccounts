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

namespace OnlineAccounts {
    
    public class Extension : Signond.Extension {
        public override string get_extension_name () {
            return "pantheon";
        }
        public override int32 get_extension_version () {
            return 0;
        }
        public override Signond.StorageManager get_storage_manager (Signond.Config config) {
            return base.get_storage_manager (config);
        }
        public override Signond.SecretStorage get_secret_storage (Signond.Config config) {
            return base.get_secret_storage (config);
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