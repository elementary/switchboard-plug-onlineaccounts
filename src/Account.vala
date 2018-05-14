// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2013-2015 Pantheon Developers (https://launchpad.net/switchboard-plug-onlineaccounts)
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
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
 *
 * Authored by: Corentin Noël <corentin@elementary.io>
 */

public class OnlineAccounts.Account : GLib.Object {
    public Ag.Account ag_account;

    public signal void removed ();
    public signal void complete ();

    public Account (Ag.Account account) {
        ag_account = account;
    }

    public async void delete_account () throws GLib.Error {
        var account_service = new Ag.AccountService (ag_account, null);
        var auth_data = account_service.get_auth_data ();
        var identity = new Signon.Identity.from_db (auth_data.get_credentials_id ());
        yield identity.remove (null);
        ag_account.delete ();
        yield ag_account.store_async (null);
    }

    public async void authenticate () {
        var account_service = new Ag.AccountService (ag_account, null);
        var auth_data = account_service.get_auth_data ();
        var method = auth_data.get_method ();
        var mechanism = auth_data.get_mechanism ();

        var info = new Signon.IdentityInfo ();
        info.set_caption (ag_account.get_provider_name ());
        info.set_identity_type (Signon.IdentityType.APP);
        info.set_secret ("", true);
        info.set_method (method, {mechanism, null});
        info.add_access_control ("%s/bin/io.elementary.switchboard".printf (Build.CMAKE_INSTALL_PREFIX), "*");
        var integration_variant = ag_account.get_variant ("integration/executable", null);
        if (integration_variant != null) {
            info.add_access_control (integration_variant.dup_string (), "*");
        }

        var session_data = auth_data.get_login_parameters (null);

        var allowed_realms_val = session_data.lookup_value ("AllowedRealms", null);
        if (allowed_realms_val != null) {
            info.set_realms (allowed_realms_val.get_strv ());
        }

        var identity = new Signon.Identity ();
        try {
            yield identity.store_info (info, null);

            var session = identity.create_session (method);
            var session_result = yield session.process (session_data, mechanism, null);
            var access_token = session_result.lookup_value ("AccessToken", null);

            ag_account.set_enabled (true);
            ag_account.set_variant ("CredentialsId", new GLib.Variant.uint32 (identity.get_id ()));
            yield ag_account.store_async (null);

            if (integration_variant != null) {
                var command = "%s --method=UserName --account-id=%u".printf (integration_variant.get_string (), ag_account.id);

                try {
                    var appinfo = GLib.AppInfo.create_from_commandline (command, "Single Sign On Integration", GLib.AppInfoCreateFlags.NONE);
                    appinfo.launch (null, null);
                } catch (Error e) {
                    critical (e.message);
                }
            }

            AccountsManager.get_default ().add_account (this);
        } catch (Error e) {
            critical (e.message);
        }
    }
}
