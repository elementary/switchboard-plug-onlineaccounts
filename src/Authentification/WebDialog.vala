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

public class OnlineAccounts.WebDialog : OnlineAccounts.Dialog {
    private WebKit.WebView webview;
    private string oauth_open_url;
    private string oauth_final_url;
    private string oauth_response;
    private Gtk.Label info_label;
    private Gtk.Spinner spinner;

    public WebDialog (GLib.HashTable<string, GLib.Variant> params) {
        base (params);

        info_label = new Gtk.Label (_("Loading…"));

        spinner = new Gtk.Spinner ();
        spinner.start ();

        var container_grid = new Gtk.Grid ();
        container_grid.column_spacing = 6;
        container_grid.valign = Gtk.Align.CENTER;
        container_grid.add (info_label);
        container_grid.add (spinner);

        var infobar = new Gtk.InfoBar.with_buttons (_("Cancel"), 0);
        infobar.get_content_area ().add (container_grid);

        WebKit.WebContext.get_default ().set_preferred_languages (GLib.Intl.get_language_names ());

        webview = new WebKit.WebView ();
        webview.expand = true;

        attach (webview, 0, 0);
        attach (infobar, 0, 1);
        show_all ();

        set_parameters (params);

        infobar.response.connect (() => {
            error_code = OnlineAccounts.SignonUIError.CANCELED;
            finished ();
            this.destroy ();
        });
    }

    public override bool set_parameters (HashTable<string, Variant> params) {
        if (base.set_parameters (params) == false) {
            return false;
        }

        webview.load_changed.connect (on_webview_load);
        webview.load_failed.connect (on_load_uri_failed);

        if (validate_params (params) == false) {
            return false;
        }

        webview.load_uri (oauth_open_url);
        return true;
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
                info_label.label = _("Please enter your credentials…");
                spinner.stop ();
                spinner.hide ();
                return;
            }

            if (load_event == WebKit.LoadEvent.STARTED) {
                info_label.label = _("Loading…");
                spinner.start ();
                spinner.show ();
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

    public override bool refresh_captcha (string uri) {
        return true;
    }

}
