/*-
 * Copyright 2013-2018 elementary LLC. (https://elementary.io)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by: Corentin Noël <corentin@elementary.io>
 */

public class IntegrationApplication : Application {
    private IntegrationApplication () {
        Object (flags: ApplicationFlags.HANDLES_COMMAND_LINE);
    }

    private static uint account_id = 0;
    private static string? method = null;
    private const GLib.OptionEntry[] options = {
        { "account-id", 'a', 0, OptionArg.INT, ref account_id, "Specify the account id", "ID" },
        { "method", 0, 0, OptionArg.STRING, ref method, "The action to do", "NAME" },
        { null }
    };

    public override int command_line (ApplicationCommandLine command_line) {
        string[] args = command_line.get_arguments ();
        try {
            var opt_context = new OptionContext ("- Facebook Integration");
            opt_context.set_help_enabled (true);
            opt_context.set_ignore_unknown_options (true);
            opt_context.add_main_entries (options, null);

            opt_context.parse_strv (ref args);
        } catch (OptionError e) {
            command_line.print ("error: %s\n", e.message);
            command_line.print ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
            return -1;
        }

        if (method == null) {
            command_line.print ("Missing method argument.\n");
            return -1;
        }

        if (account_id == 0) {
            command_line.print ("Missing account-id argument.\n");
            return -1;
        }

        bool finished = false;
        switch (method) {
            case "UserName":
                finished = get_user_name (account_id);
                break;
            case "UserImage":
                finished = get_user_image (account_id);
                break;
            default:
                command_line.print ("Method '%s' unavailable.\n", method);
                break;
        }

        if (finished) {
            command_line.print ("Method '%s' finished on account '%u'.\n", method, account_id);
        }

        return 0;
    }

    [Compact]
    public class ApiInfos {
        public string access_token;
        public string client_id;
        public string redirect_uri;
        public Ag.AccountService account_service;
    }

    public ApiInfos? get_token (uint account_id) {
        var api_infos = new ApiInfos ();

        var ag_manager = new Ag.Manager ();
        try {
            Ag.Account account  = ag_manager.load_account (account_id);
            var account_service = new Ag.AccountService (account, null);
            Ag.AuthData auth_data = account_service.get_auth_data ();
            weak GLib.Variant session_data = auth_data.get_login_parameters (null);

            api_infos.account_service = account_service;
            api_infos.client_id = session_data.lookup_value ("ClientId", null).dup_string ();
            api_infos.redirect_uri = session_data.lookup_value ("RedirectUri", null).dup_string ();

            var identity = new Signon.Identity.from_db (auth_data.get_credentials_id ());
            var auth_session = identity.create_session ("oauth");

            GLib.Variant session_result = null;
            var main_loop = new MainLoop ();
            auth_session.process.begin (session_data, "oauth2", null, (obj, res) => {
                try {
                    session_result = auth_session.process.end (res);
                } catch (Error e) {
                    critical (e.message);
                }

                main_loop.quit ();
            });

            main_loop.run ();
            if (session_result == null) {
                return null;
            }

            api_infos.access_token = session_result.lookup_value ("AccessToken", null).dup_string ();
        } catch (Error e) {
            critical (e.message);
            return null;
        }

        return api_infos;
    }

    public bool get_user_name (uint account_id) {
        var api_infos = get_token (account_id);
        if (api_infos == null)
            return false;

        var proxy = new Rest.OAuth2Proxy.with_token (
            api_infos.client_id,
            api_infos.access_token,
            api_infos.redirect_uri,
            "https://graph.facebook.com/me",
            false
        );

        var call = proxy.new_call ();
        call.set_method ("GET");
        try {
            call.run ();
        } catch (Error e) {
            critical (e.message);
            return false;
        }

        try {
            var parser = new Json.Parser ();
            parser.load_from_data (call.get_payload (), (ssize_t)call.get_payload_length ());
            weak Json.Object root_object = parser.get_root ().get_object ();
            unowned string username = root_object.get_string_member ("name");
            var account = api_infos.account_service.account;
            account.set_display_name (username);
            account.store_blocking ();
        } catch (Error e) {
            critical (e.message);
            return false;
        }

        return true;
    }

    public bool get_user_image (uint account_id) {
        var api_infos = get_token (account_id);
        if (api_infos == null)
            return false;

        //TODO

        return true;
    }

    public static int main (string[] args) {
        IntegrationApplication app = new IntegrationApplication ();
        int status = app.run (args);
        return status;
    }
}
