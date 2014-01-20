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

// This is compatible with Ubuntu Online Accounts.
public class OnlineAccounts.Keyring : Signond.SecretStorage {
    public enum SignonSecretType {
        NOTYPE = 0,
        PASSWORD,
        USERNAME,
        DATA
    }
    
    Secret.Schema schema = null;
    Error error = null;
    public override bool open_db () {
        if (schema == null)
        schema = new Secret.Schema ("com.ubuntu.OnlineAccounts.Secrets", Secret.SchemaFlags.DONT_MATCH_NAME,
                                 "signon-type", Secret.SchemaAttributeType.INTEGER,
                                 "signon-id", Secret.SchemaAttributeType.INTEGER,
                                 "signon-method", Secret.SchemaAttributeType.INTEGER);
        return true;
    }
    
    public override bool close_db () {
        return true;
    }
    
    public override bool clear_db () {
        return true;
    }
    
    public override bool is_open_db () {
        return (schema != null);
    }
    
    public override Signond.Credentials load_credentials (uint32 id) {
        var credidential = new Signond.Credentials ();
        string username;
        load_secret (SignonSecretType.USERNAME, id, 0, out username);
        string password;
        load_secret (SignonSecretType.PASSWORD, id, 0, out password);
        credidential.set_data (id, username, password);
        return credidential;
    
    }
    
    public override bool update_credentials (Signond.Credentials creds) {
        if (creds.get_password () != null || creds.get_password () != "")
            store_secret (SignonSecretType.PASSWORD, creds.get_id (), 0, creds.get_password ());
        if (creds.get_username () != null || creds.get_username () != "")
            store_secret (SignonSecretType.USERNAME, creds.get_id (), 0, creds.get_username ());
        return true;
    }
    
    public override bool remove_credentials (uint32 id) {
        try {
            return Secret.password_clear_sync (schema, null, "signon-id", id);
        } catch (Error e) {
            critical (e.message);
            error = e;
            return false;
        }
    }
    
    public override bool check_credentials (Signond.Credentials creds) {
        return base.check_credentials (creds);
    }
    
    public override GLib.HashTable<string, GLib.Variant> load_data (uint32 id, uint32 method) {
        var result = new GLib.HashTable<string, GLib.Variant>(null, null);
        string data_serialized;
        load_secret (SignonSecretType.DATA, id, method, out data_serialized);
        if (data_serialized == null)
            return result;
        foreach (var entry in data_serialized.split ("\n")) {
            if (entry != null) {
                var entries = entry.split ("<!separator>", 2);
                try {
                    result.set (entries[0], GLib.Variant.parse (null, entries[1]));
                } catch (Error e) {
                    critical (e.message);
                    error = e;
                }
            }
        }
        return result;
    }
    
    public override bool update_data (uint32 id, uint32 method, GLib.HashTable<string, GLib.Variant> data) {
        string data_serialized = "";
        foreach (var key in data.get_keys ()) {
            data_serialized = data_serialized + key + "<!separator>" + data.lookup (key).print (true) + "\n";
        }
        return store_secret (SignonSecretType.DATA, id, method, data_serialized);
    }
    
    public override bool remove_data (uint32 id, uint32 method) {
        try {
            return Secret.password_clear_sync (schema, null, "signon-id", id, "signon-method", method);
        } catch (Error e) {
            critical (e.message);
            error = e;
            return false;
        }
    }
    
    public override GLib.Error get_last_error () {
        return error;
    }
    
    public bool store_password (int type, int id, int method, string password) {
        try {
            return Secret.password_store_sync (schema, Secret.COLLECTION_DEFAULT, "Online Account",
                                        password, null, "signon-type", type, "signon-id", id,
                                        "signon-method", method);
        } catch (Error e) {
            critical (e.message);
            error = e;
            return false;
        }
    }
    
    public bool store_secret (SignonSecretType type, uint32 id, uint32 method, string secret) {
        if (secret == null || secret == "")
            return false;
        var display_name = "Web Account: id %u-%u".printf (id, type);
        string? signonMethod = (type == SignonSecretType.DATA) ? "signon-method" : null;
        try {
            Secret.password_store_sync(schema, Secret.COLLECTION_DEFAULT, display_name,
                                        secret, null, "signon-type", type, "signon-id", id,
                                        signonMethod, method);
        } catch (Error e) {
            critical (e.message);
            error = e;
            return false;
        }
        
        return true;
    }

    public bool load_secret (SignonSecretType type, uint32 id, uint32 method, out string secret) {
        string? signonMethod = (type == SignonSecretType.DATA) ? "signon-method" : null;
        
        try {
            string data = Secret.password_lookup_sync(schema, null, "signon-type", type,
                                                  "signon-id", id, signonMethod, method);
            secret = data;
        } catch (Error e) {
            warning (e.message);
            error = e;
            return false;
        }
        return true;
    }
}
