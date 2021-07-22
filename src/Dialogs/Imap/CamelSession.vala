/*
* Copyright 2020-2021 elementary, Inc. (https://elementary.io)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
*/

public class OnlineAccounts.CamelSession : Camel.Session {

    private static CamelSession? session = null;

    public static unowned CamelSession get_default () {
        if (session == null) {
            session = new CamelSession ();
        }
        return session;
    }

    public CamelSession () {
        Object (
            user_data_dir: Path.build_filename (E.get_user_data_dir (), "mail"),
            user_cache_dir: Path.build_filename (E.get_user_cache_dir (), "mail")
        );
    }

    construct {
        Camel.init (E.get_user_data_dir (), false);
        set_network_monitor (E.NetworkMonitor.get_default ());
        set_online (true);
        user_alert.connect ((service, type, message) => { warning (message); });
    }
}
