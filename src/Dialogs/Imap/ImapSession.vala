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

public class OnlineAccounts.SimpleSasl : Camel.Sasl {
    public SimpleSasl (string service_name, string mechanism, Camel.Service service) {
        Object (service_name: service_name, mechanism: mechanism, service: service);
    }
}

public class OnlineAccounts.ImapSession : Camel.Session {
    private static ImapSession _session;
    public static unowned ImapSession get_default () {
        if (_session == null) {
            _session = new ImapSession ();
        }
        return _session;
    }

    private ImapSession () {
        Object (
            user_data_dir: Path.build_filename (E.get_user_data_dir (), "mail"),
            user_cache_dir: Path.build_filename (E.get_user_cache_dir (), "mail")
        );
    }

    construct {
        Camel.init (E.get_user_data_dir (), false);
        set_online (true);
    }
}