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

    public new void authenticate_sync (E.Source source, Camel.Service service, string? mechanism, GLib.Cancellable? cancellable = null) throws GLib.Error {
        /* This function is heavily inspired by mail_ui_session_authenticate_sync in Evolution
         * https://git.gnome.org/browse/evolution/tree/mail/e-mail-ui-session.c */

        /* Do not chain up.  Camel's default method is only an example for
         * subclasses to follow.  Instead we mimic most of its logic here. */

        Camel.ServiceAuthType authtype;
        bool try_empty_password = false;
        var result = Camel.AuthenticationResult.REJECTED;

        if (mechanism == "none") {
            mechanism = null;
        }

        if (mechanism != null) {
            /* APOP is one case where a non-SASL mechanism name is passed, so
             * don't bail if the CamelServiceAuthType struct comes back NULL. */
            authtype = Camel.Sasl.authtype (mechanism);

            /* If the SASL mechanism does not involve a user
             * password, then it gets one shot to authenticate. */
            if (authtype != null && !authtype.need_password) {
                result = service.authenticate_sync (mechanism); //@TODO make async?

                if (result != Camel.AuthenticationResult.ACCEPTED) {
                    throw new GLib.Error (
                        Camel.Service.error_quark (),
                        Camel.ServiceError.CANT_AUTHENTICATE,
                        "%s authentication failed",
                        mechanism
                    );
                }
            }

            /* Some SASL mechanisms can attempt to authenticate without a
             * user password being provided (e.g. single-sign-on credentials),
             * but can fall back to a user password.  Handle that case next. */
            var sasl = new SimpleSasl (((Camel.Provider)service.provider).protocol, mechanism, service);
            if (sasl != null) {
                try_empty_password = sasl.try_empty_password_sync ();
            }
        }

        result = Camel.AuthenticationResult.REJECTED;

        if (try_empty_password) {
            result = service.authenticate_sync (mechanism); //@TODO catch error
        }

        if (result != Camel.AuthenticationResult.ACCEPTED) {
            throw new GLib.Error (
                Camel.Service.error_quark (),
                Camel.ServiceError.CANT_AUTHENTICATE,
                "%s authentication failed",
                mechanism
            );
        }
    }

    public bool try_credentials_sync (E.CredentialsPrompter prompter, E.Source source, E.NamedParameters credentials, out bool out_authenticated, GLib.Cancellable? cancellable, Camel.Service service, string? mechanism) throws GLib.Error {
        string credential_name = null;

        if (source.has_extension (E.SOURCE_EXTENSION_AUTHENTICATION)) {
            unowned var auth_extension = (E.SourceAuthentication) source.get_extension (E.SOURCE_EXTENSION_AUTHENTICATION);

            credential_name = auth_extension.dup_credential_name ();

            if (credential_name != null && credential_name.length == 0) {
                credential_name = null;
            }
        }

        service.set_password (credentials.get (credential_name ?? E.SOURCE_CREDENTIAL_PASSWORD));

        Camel.AuthenticationResult result = service.authenticate_sync (mechanism); //@TODO catch error

        out_authenticated = (result == Camel.AuthenticationResult.ACCEPTED);

        if (out_authenticated) {
            var credentials_source = prompter.get_provider ().ref_credentials_source (source);

            if (credentials_source != null) {
                credentials_source.invoke_authenticate_sync (credentials);
            }
        }

        return result == Camel.AuthenticationResult.REJECTED;
    }
}