/*
 * Copyright (C) 2012 Canonical, Inc
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
 * USA.
 *
 * Authors:
 *      Alberto Mardegan <alberto.mardegan@canonical.com>
 */

public class OnlineAccounts.Plugins.PasswordAccount : OnlineAccounts.Account {

    Ag.Manager manager;
    public Ag.AuthData auth_data;
    public Signon.IdentityInfo info;
    public GLib.MainLoop main_loop;
    bool is_new = false;

    public PasswordAccount (Ag.Account account, bool is_new = false) {
        this.account = account;
        this.is_new = is_new;
        var account_service = new Ag.AccountService (account, null);
        auth_data = account_service.get_auth_data ();
        if (is_new) {
            setup_authentification ();
        }
    }
    
    public override void setup_authentification () {
        main_loop = new GLib.MainLoop ();
        manager = new Ag.Manager ();
        info = new Signon.IdentityInfo ();
        info.set_caption (account.get_provider_name ());
        info.set_identity_type (Signon.IdentityType.APP);
        info.set_secret ("", true);
        info.set_method ("password", {"password", null});
        info.access_control_list_append (new Signon.SecurityContext.from_values ("%s/bin/switchboard".printf (Build.CMAKE_INSTALL_PREFIX), "*"));
        var identity = new Signon.Identity ();
        identity.store_credentials_with_info (info, (sel, ide, err) => {IdentityStoreCredentialsCallback (sel, ide, err, this);});
        
        main_loop.run ();
    }
    
    public async void authenticate (Signon.Identity identity, uint32 id) {
        
        GLib.Variant? v_id = new GLib.Variant.uint32 (id);
        account.set_variant (gsignon_id, v_id);
        var oauth_params_builder = new GLib.VariantBuilder (GLib.VariantType.VARDICT);
        
        var captcha_url = account.get_variant ("password/CaptchaUrl", null);
        if (captcha_url != null)
            oauth_params_builder.add ("{sv}", "CaptchaUrl", captcha_url);
        
        var forgot_url = account.get_variant ("password/ForgotPasswordUrl", null);
        if (forgot_url != null) {
            oauth_params_builder.add ("{sv}", "ForgotPasswordUrl", forgot_url);
            oauth_params_builder.add ("{sv}", "ForgotPassword", new GLib.Variant.boolean (true));
        }
        
        var query_user = account.get_variant ("password/QueryUserName", null);
        if (query_user != null) {
            oauth_params_builder.add ("{sv}", "QueryUserName", new GLib.Variant.boolean (bool.parse (query_user.get_string ())));
        } else {
            oauth_params_builder.add ("{sv}", "QueryUserName", new GLib.Variant.boolean (true));
        }
        
        oauth_params_builder.add ("{sv}", "UiPolicy", new GLib.Variant.int32 (Signon.SessionDataUiPolicy.DEFAULT));
        
        session_data = oauth_params_builder.end ();
        session_data = auth_data.get_login_parameters (session_data);
            try {
                var session = identity.create_session ("password");
                session_result = yield session.process_async (session_data, "password", null);
                var access_token = session_result.lookup_value ("Secret", null).dup_string ();
                info.set_secret (access_token, true);
                var username = session_result.lookup_value ("UserName", null).dup_string ();
                account.set_display_name (username);
                identity.query_info ((s, i, err) => {IdentityInfoCallback (s, i, err, this);});
            } catch (Error e) {
                critical (e.message);
                main_loop.quit ();
            }
        yield;
    }
    
    // Callbacks
    public static void IdentityStoreCredentialsCallback (Signon.Identity self, uint32 id, GLib.Error error, PasswordAccount pr) {
        if (error != null) {
            critical (error.message);
            pr.main_loop.quit ();
            return;
        }
        pr.authenticate.begin (self, id);
    }
    public static void IdentityInfoCallback (Signon.Identity self, Signon.IdentityInfo info, GLib.Error error, PasswordAccount pr) {
        if (error != null) {
            critical (error.message);
            pr.main_loop.quit ();
            return;
        }
        pr.account.set_enabled (true);
        pr.account.store_async.begin (null);
        if (pr.is_new == true) {
            AccountsManager.get_default ().add_account (pr);
            pr.is_new = false;
        }
        pr.main_loop.quit ();
    }
}
