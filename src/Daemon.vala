/*
 * Copyright 2021 elementary, Inc
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

[DBus (name = "io.elementary.switchboard.OnlineAccounts")]
public class OnlineAccounts.Daemon : Object {
    private static MainLoop loop;

    public string lookup_password (string uid) throws Error {
        string? password;
        E.secret_store_lookup_sync (uid, out password);
        if (password == null) {
            throw new IOError.NOT_FOUND (_("Password not found"));
        }

        return Base64.encode (password.data);
    }

    private static void on_bus_aquired (DBusConnection connection, string name) {
        try {
            connection.register_object<Daemon> ("/io/elementary/switchboard/online_accounts", new Daemon ());
            debug ("Daemon Interface Registred");
        } catch (Error e) {
            critical (e.message);
        }
    }

    private static int main () {
        loop = new MainLoop ();
        try {
            Bus.get_sync (BusType.SESSION);
        } catch (Error e) {
            printerr ("No session bus: %s\n", e.message);
            return 2;
        }

        var id = Bus.own_name (
            BusType.SESSION,
            "io.elementary.switchboard.online-accounts",
            BusNameOwnerFlags.NONE,
            on_bus_aquired,
            () => debug ("'io.elementary.switchboard.online-accounts' aquired"),
            () => loop.quit ()
        );
        loop.run ();
        Bus.unown_name (id);
        return 0;
    }
}
