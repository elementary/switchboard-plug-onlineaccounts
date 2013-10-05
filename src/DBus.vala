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
// TODO: deprecate the signon-ui package and integrate everything directly into the plug.

const string DBUS_PATH = "/org/pantheon/onlineaccounts";

[DBus (name = "com.google.code.AccountsSSO.gSingleSignOn.UI")]
public class OnlineAccounts.DBusUI : Object {

    public string getBusAddress () {
        string address = GLib.BusType.get_address_sync (GLib.BusType.SESSION);
        string[] parts = address.split (",", 2);
        return parts[0];
    }

}

[DBus (name = "com.google.code.AccountsSSO.gSingleSignOn.UI.Dialog")]
public class OnlineAccounts.DBusDialog : Object {

    public GLib.Variant queryDialog (GLib.Variant prms) {
        VariantBuilder builder = new VariantBuilder (new VariantType ("a{sv}") );
        builder.add ("{sv}", "str1", new Variant.string ("str"));
        return builder.end ();
    }

    public void refreshDialog (GLib.Variant prms) {
        
    }

    public void cancelUiRequest (string request_id) {
        
    }
    
    public signal string refresh ();

}

public class OnlineAccounts.DBus : Object {

    public DBus () {
        Bus.own_name (BusType.SESSION, "com.google.code.AccountsSSO.gSingleSignOn.UI.Dialog", BusNameOwnerFlags.NONE,
                  on_ui_bus_aquired,
                  () => {},
                  () => critical ("Could not aquire name"));
        
        Bus.own_name (BusType.SESSION, "com.google.code.AccountsSSO.gSingleSignOn.UI", BusNameOwnerFlags.NONE,
                  on_bus_aquired,
                  () => {},
                  () => critical ("Could not aquire name"));
    }

    void on_bus_aquired (DBusConnection conn) {
        try {
            conn.register_object ("/", new DBusUI ());
        } catch (IOError e) {
            critical (e.message);
        }
    }

    void on_ui_bus_aquired (DBusConnection conn) {
        try {
            conn.register_object (DBUS_PATH, new DBusDialog ());
        } catch (IOError e) {
            critical (e.message);
        }
    }
    
}

