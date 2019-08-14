// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright 2013-2018 elementary, Inc. (https://elementary.io)
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

public class OnlineAccounts.WebDialog : OnlineAccounts.AbstractAuthView {
    private WebKit.WebView webview;
    private string oauth_open_url;
    private string oauth_final_url;
    private string oauth_response;

    public WebDialog (GLib.HashTable<string, GLib.Variant> params) {
        base (params);

        title_label.label = _("Loading…");
        spinner.start ();

        WebKit.WebContext.get_default ().set_preferred_languages (GLib.Intl.get_language_names ());

        webview = new WebKit.WebView ();
        webview.expand = true;

        content_area.add (webview);

        show_all ();

        set_parameters (params);
    }

    public override bool set_parameters (HashTable<string, Variant> params) {
        if (base.set_parameters (params) == false) {
            return false;
        }

        webview.load_changed.connect (on_webview_load);
        webview.load_failed.connect (on_load_uri_failed);
        webview.create.connect ((action) => { return on_new_window_requested (action); });

        if (validate_params (params) == false) {
            return false;
        }

        webview.load_uri (oauth_open_url);
        return true;
    }

    public Gtk.Widget? on_new_window_requested (WebKit.NavigationAction action) {
        var uri = action.get_request ().get_uri ();
        try {
            AppInfo.launch_default_for_uri (uri, null);
        } catch (Error e) {
            warning ("Error launching browser for external link: %s", e.message);
        }

        return null;
    }

    private bool is_valid_url (string uri) {
        var scheme = Uri.parse_scheme (uri);
        if (scheme == null)
            return false;

        return scheme.has_prefix ("http");
    }

    private bool validate_params (HashTable<string, Variant> params) {
        weak Variant open_url_var = params.get (OnlineAccounts.Key.OPEN_URL);
        if (open_url_var != null) {
            oauth_open_url = open_url_var.get_string ();
        }

        weak Variant final_url_var = params.get (OnlineAccounts.Key.FINAL_URL);
        if (final_url_var != null) {
            oauth_final_url = final_url_var.get_string ();
        }

        if (oauth_open_url == null || oauth_final_url == null) {
            warning ("Missing open_url or final_url");
            return false;
        }

        if (is_valid_url (oauth_open_url) == false || is_valid_url (oauth_final_url) == false) {
            warning ("Invalid open_url or final_url");
            return false;
        }

        return true;
    }

    private bool on_load_uri_failed (WebKit.LoadEvent load_event, string failing_uri, void* _error) {
        var error = (GLib.Error)_error;
        warning ("Loading uri '%s' failed, error : %s", failing_uri, error.message);
        if (GLib.strcmp (failing_uri, oauth_open_url) == 0) {
            error_code = OnlineAccounts.SignonUIError.NOT_AVAILABLE;
        }

        return true;
    }

    private void on_webview_load (WebKit.LoadEvent load_event) {
        var redirect_uri = webview.get_uri ();
        if (redirect_uri == null || !redirect_uri.has_prefix (oauth_final_url)) {
            if (load_event == WebKit.LoadEvent.FINISHED) {
                title_label.label = _("Please enter your credentials…");
                spinner.stop ();
                return;
            }

            if (load_event == WebKit.LoadEvent.STARTED) {
                title_label.label = _("Loading…");
                spinner.start ();
                return;
            }

            return;
        }

        /* We got the redirect URI what we are interestead in, so disconnect handler */
        webview.load_changed.disconnect (on_webview_load);
        oauth_response = redirect_uri;
        debug ("Found OAUTH Response : %s", oauth_response);
        error_code = OnlineAccounts.SignonUIError.NONE;
        finished ();
    }

    public override HashTable<string, Variant> get_reply () {
        var table = base.get_reply ();
        if (error_code == OnlineAccounts.SignonUIError.NONE) {
            table.insert (OnlineAccounts.Key.URL_RESPONSE, new Variant.string (oauth_response));
        }

        return table;
    }
}
