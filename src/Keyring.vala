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

public class OnlineAccounts.Keyring : GLib.Object {
    
    Secret.Schema schema;
    
    public Keyring () {
        schema = new Secret.Schema ("com.ubuntu.OnlineAccounts.Secrets", Secret.SchemaFlags.NONE,
                                 "signon-type", Secret.SchemaAttributeType.INTEGER,
                                 "signon-id", Secret.SchemaAttributeType.INTEGER,
                                 "signon-method", Secret.SchemaAttributeType.INTEGER);
    }
    
    public bool store_password (int type, int id, int method, string password) {
        return Secret.password_store_sync (schema, Secret.COLLECTION_DEFAULT, "Online Account",
                                        password, null, "signon-type", type, "signon-id", id,
                                        "signon-method", method);
    }
    
    public string lookup_password (int type, int id, int method) {
        return Secret.password_lookup_sync (schema, null, 
                                        "signon-type", type, "signon-id", id,
                                        "signon-method", method);
    }
    
    public bool remove_password (int type, int id, int method) {
        return Secret.password_clear_sync (schema, null,
                                        "signon-type", type, "signon-id", id,
                                        "signon-method", method);
    }
}

