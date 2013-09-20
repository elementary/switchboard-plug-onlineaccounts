// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2013 Pantheon Developers (http://launchpad.net/online-accounts-plug)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 * Authored by: Corentin Noël <tintou@mailoo.org>
 */

public class OnlineAccounts.OAuthPlugin : OnlineAccounts.Plugin {
    
    public string mechanism;
    public GLib.HashTable<string, GLib.Value?> oauth_params;
    public GLib.HashTable<string, GLib.Value?> account_oauth_params;
    public Ag.AuthData auth_data;
    public Signon.Identity identity;
    public Signon.AuthSession auth_session;
    public bool identity_stored;
    public bool deleting_identity;
    public bool authenticating;
    public bool storing_account;
    
    public enum OAuthMechanism {
        USER_AGENT = 0,
        WEB_SERVER = 1,
        HMAC_SHA1 = 2,
        PLAINTEXT = 3,
        RSA_SHA1 = 4
    }
    
    public OAuthPlugin (Ag.Account account) {
        base (account);
        oauth_params = new GLib.HashTable<string, GLib.Value?> (str_hash, null);
        account_oauth_params = new GLib.HashTable<string, GLib.Value?> (str_hash, null);
    }
    
    public void set_mechanism (OAuthMechanism mechanism) {
        string[] oauth_mechanisms = {
            "user_agent",
            "web_server",
            "HMAC-SHA1",
            "PLAINTEXT",
            "RSA-SHA1",
        };
        this.mechanism = oauth_mechanisms[mechanism];
    }

    public override Gtk.Widget get_widget () {
        var acl_all = new GLib.List<Signon.SecurityContext> ();
        acl_all.append (new Signon.SecurityContext.from_values ("*", ""));

        var info = new Signon.IdentityInfo ();
        info.set_caption (provider.get_display_name ());
        info.set_identity_type (Signon.IdentityType.APP);
        if (username != null)
            info.set_username (username);
        info.set_secret (password, true);
        info.set_access_control_list (acl_all);

        identity = new Signon.Identity ("online-accounts-pantheon");
        identity.store_credentials_with_info (info, (Signon.IdentityStoreCredentialsCb)identity_store_cb);
        return new Gtk.Grid ();
    }
    
    public static GLib.Variant? value_to_variant (GLib.Value val) {
        GLib.VariantType type;

        if (val.type () == typeof(string)) type = GLib.VariantType.STRING;
        else if (val.type () == typeof(bool)) type = GLib.VariantType.BOOLEAN;
        else if (val.type () == typeof(uchar)) type = GLib.VariantType.BYTE;
        else if (val.type () == typeof(int)) type = GLib.VariantType.INT32;
        else if (val.type () == typeof(uint)) type = GLib.VariantType.UINT32;
        else if (val.type () == typeof(int64)) type = GLib.VariantType.INT64;
        else if (val.type () == typeof(uint64)) type = GLib.VariantType.UINT64;
        else if (val.type () == typeof(double)) type = GLib.VariantType.DOUBLE;
        else if (val.type () == typeof(string[])) type = GLib.VariantType.STRING_ARRAY;
        else {
            warning ("Unsupported type %s", val.type_name ());
            return null;
        }

        return GLib.DBus.gvalue_to_gvariant (val, type);
    }

    public GLib.Variant prepare_session_data () {

        var builder = new GLib.VariantBuilder (GLib.VariantType.VARDICT);

        if (cookies != null && !ignore_cookies) {
            builder.add ("{sv}", "Cookies", cookies_to_variant (cookies));
        }

        /* Add all the provider-specific OAuth parameters. */
        if (oauth_params != null)
        {
            var iter = HashTableIter<string, GLib.Value?> (oauth_params);
            unowned Value? val;
            string key;

            while (iter.next (out key, out val)) {
                var variant = value_to_variant (val);
                builder.add ("{sv}", key, variant);
            }
        }

        /* Merge the session parameters built so far with the provider's default
         * parameters */
        var session_data = builder.end ();
        if (auth_data != null) {
            session_data = auth_data.get_login_parameters (session_data);
        }
        return session_data;
    }
    
    public GLib.Variant cookies_to_variant (GLib.HashTable<string, string> cookies){
        
        var builder = new GLib.VariantBuilder (new GLib.VariantType ("a{ss}"));
        var iter = HashTableIter<string, string> (cookies);
        unowned string val;
        string key;

        while (iter.next (out key, out val)) {
            builder.add ("{ss}", key, val);
        }
        return builder.end ();
    }

    private void identity_store_cb (Signon.Identity self, uint32 id, GLib.Error error) {
        if (error != null) {
            critical ("Couldn't store identity: %s", error.message);
            return;
        }

        identity_stored = true;

        /* store the identity ID into the account settings */
        var v_id = new GLib.Variant.uint32 (id);
        account.set_variant (signon_id, v_id);

        start_authentication_process ();
    }
    
    public void start_authentication_process () {
        var session_data = prepare_session_data ();

        try {
            auth_session = identity.create_session ("oauth2");
            authenticating = true;
            auth_session.process_async.begin (session_data, mechanism, null);
        } catch (Error e) {
            critical ("Couldn't create AuthSession: %s", error.message);
        }
    }
    
    public override void delete_account () {
        
    }
}
