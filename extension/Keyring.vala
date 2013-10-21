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
    
    Secret.Schema schema = null;
    SQLHeavy.Database database;
    public override bool open_db () {
        schema = new Secret.Schema ("com.ubuntu.OnlineAccounts.Secrets", Secret.SchemaFlags.NONE,
                                 "signon-type", Secret.SchemaAttributeType.INTEGER,
                                 "signon-id", Secret.SchemaAttributeType.INTEGER,
                                 "signon-method", Secret.SchemaAttributeType.INTEGER);
        var database_dir = GLib.File.new_for_path (GLib.Environment.get_user_config_dir () + "/signond/");
        try {
            database_dir.make_directory_with_parents (null);
        } catch (GLib.Error err) {
            if (!(err is IOError.EXISTS))
                error ("Could not create data directory: %s", err.message);
        }

        string database_path = Path.build_filename (database_dir.get_path (), "signon.db");
        var database_file = File.new_for_path (database_path);

        try {
            const SQLHeavy.FileMode flags = SQLHeavy.FileMode.READ
                                            | SQLHeavy.FileMode.WRITE
                                            | SQLHeavy.FileMode.CREATE;
            database = new SQLHeavy.Database (database_file.get_path (), flags);
        } catch (SQLHeavy.Error err) {
            error ("Could not read/create database file: %s", err.message);
        }

        // Disable synchronized commits for performance reasons
        database.synchronous = SQLHeavy.SynchronousMode.OFF;

        load_table (Database.Tables.ACL);
        load_table (Database.Tables.CREDIDENTIALS);
        load_table (Database.Tables.METHODS);
        load_table (Database.Tables.TOKENS);
        return true;
    }

    private void load_table (string table) {
        try {
            database.execute (table);
        } catch (SQLHeavy.Error err) {
            warning ("Error while executing %s: %s", table, err.message);
        }
    }
    
    public override bool close_db () {
        return true;
    }
    
    public override bool clear_db () {
        return true;
    }
    
    public override bool is_open_db () {
        return ((schema != null) && (database != null));
    }
    
    public override Signond.Credentials load_credentials (uint32 id) {
        assert (database != null);
        var credidential = new Signond.Credentials ();
        int identity_id = 0;
        int type = 0;
        string method = "";
        string username = "";
        string password = "";

        // Get ID
        try {
            SQLHeavy.Query query = new SQLHeavy.Query (database, "SELECT * FROM `ACL` WHERE rowid=:rowid");
            query.set_int (":rowid", (int)id);

            for (var results = query.execute (); !results.finished; results.next()) {
                warning ("rowid: %d", results.fetch_int (1));
                identity_id = results.fetch_int (2);
                warning ("identity_id: %d", identity_id);
                warning ("token_id: %d", results.fetch_int (5));
                
            }
        }
        catch (SQLHeavy.Error err) {
            warning ("Could not load credidentials from db: %s\n", err.message);
        }

        // Get Method
        try {
            SQLHeavy.Query query = new SQLHeavy.Query (database, "SELECT * FROM `METHODS` WHERE id=:id");
            query.set_int (":id", identity_id);

            for (var results = query.execute (); !results.finished; results.next()) {
                method = results.fetch_string (1);
                warning ("method: %s", method);
                
            }
        }
        catch (SQLHeavy.Error err) {
            warning ("Could not load credidentials from db: %s\n", err.message);
        }

        // Get Username and Type
        try {
            SQLHeavy.Query query = new SQLHeavy.Query (database, "SELECT * FROM `CREDIDENTIALS` WHERE id=:id");
            query.set_int (":id", identity_id);

            for (var results = query.execute (); !results.finished; results.next()) {
                username = results.fetch_string (2);
                warning ("username: %s", username);
                type = results.fetch_int (4);
                warning ("type: %d", type);
            }
        }
        catch (SQLHeavy.Error err) {
            warning ("Could not load credidentials from db: %s\n", err.message);
        }

        password = Secret.password_lookup_sync (schema, null, 
                                        "signon-type", type, "signon-id", identity_id,
                                        "signon-method", method);
        credidential.set_data (id, username, password);

        return credidential;
    
    }
    
    public override bool update_credentials (Signond.Credentials creds) {
        return base.update_credentials (creds);
    }
    
    public override bool remove_credentials (uint32 id) {
        int identity_id = 0;
        int type = 0;
        string method = "";
        string username = "";

        // Get ID
        try {
            SQLHeavy.Query query = new SQLHeavy.Query (database, "SELECT * FROM `ACL` WHERE rowid=:rowid");
            query.set_int (":rowid", (int)id);

            for (var results = query.execute (); !results.finished; results.next()) {
                warning ("rowid: %d", results.fetch_int (1));
                identity_id = results.fetch_int (2);
                warning ("identity_id: %d", identity_id);
                warning ("token_id: %d", results.fetch_int (5));
                
            }
        }
        catch (SQLHeavy.Error err) {
            warning ("Could not load credidentials from db: %s\n", err.message);
        }

        // Get Method
        try {
            SQLHeavy.Query query = new SQLHeavy.Query (database, "SELECT * FROM `METHODS` WHERE id=:id");
            query.set_int (":id", identity_id);

            for (var results = query.execute (); !results.finished; results.next()) {
                method = results.fetch_string (1);
                warning ("method: %s", method);
                
            }
        }
        catch (SQLHeavy.Error err) {
            warning ("Could not load credidentials from db: %s\n", err.message);
        }

        // Get Username and Type
        try {
            SQLHeavy.Query query = new SQLHeavy.Query (database, "SELECT * FROM `CREDIDENTIALS` WHERE id=:id");
            query.set_int (":id", identity_id);

            for (var results = query.execute (); !results.finished; results.next()) {
                username = results.fetch_string (2);
                warning ("username: %s", username);
                type = results.fetch_int (4);
                warning ("type: %d", type);
            }
        }
        catch (SQLHeavy.Error err) {
            warning ("Could not load credidentials from db: %s\n", err.message);
        }
        return Secret.password_clear_sync (schema, null,
                                        "signon-type", type, "signon-id", identity_id,
                                        "signon-method", method);
    }
    
    public override bool check_credentials (Signond.Credentials creds) {
        return base.check_credentials (creds);
    }
    
    public override GLib.HashTable<string, GLib.Variant> load_data (uint32 id, uint32 method) {
        return base.load_data (id, method);
    }
    
    public override bool update_data (uint32 id, uint32 method, GLib.HashTable<string, GLib.Variant> data) {
        return base.update_data (id, method, data);
    }
    
    public override bool remove_data (uint32 id, uint32 method) {
        return base.remove_data (id, method);
    }
    
    public override GLib.Error get_last_error () {
        return base.get_last_error ();
    }
    
    public bool store_password (int type, int id, int method, string password) {
        return Secret.password_store_sync (schema, Secret.COLLECTION_DEFAULT, "Online Account",
                                        password, null, "signon-type", type, "signon-id", id,
                                        "signon-method", method);
    }
}

