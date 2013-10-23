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

public class FlickrPlugin : Ap.OAuthPlugin {
    public FlickrPlugin (Ag.Account account) {
        Object (account: account);
    }

    construct
    {
        var oauth_params = new HashTable<string, GLib.Value?> (str_hash, null);
        oauth_params.insert ("RequestEndpoint",
                             "https://secure.flickr.com/services/oauth/request_token");
        oauth_params.insert ("TokenEndpoint",
                             "https://secure.flickr.com/services/oauth/access_token");
        oauth_params.insert ("AuthorizationEndpoint",
                             "https://secure.flickr.com/services/oauth/authorize");
        oauth_params.insert ("ConsumerKey", Config.FLICKR_CONSUMER_KEY);
        oauth_params.insert ("ConsumerSecret", Config.FLICKR_CONSUMER_SECRET);
        /* According to Flickr documentation, the callback is ignored */
        oauth_params.insert ("Callback", "https://wiki.ubuntu.com/");
        string[] schemes = {
            "https",
            "http"
        };
        oauth_params.insert ("AllowedSchemes", schemes);
        set_oauth_parameters (oauth_params);

        set_mechanism(Ap.OAuthMechanism.HMAC_SHA1);
    }
}

public GLib.Type ap_module_get_object_type ()
{
    return typeof (FlickrPlugin);
}
