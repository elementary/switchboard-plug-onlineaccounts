// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2013 Pantheon Developers (http://launchpad.net/online-accounts-plug)
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
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 * Authored by: Corentin Noël <tintou@mailoo.org>
 */

public class OnlineAccounts.WebDialog : OnlineAccounts.Dialog {
    WebKit.WebView webview;
    string oauth_open_url;
    string oauth_final_url;
    string oauth_response;
    Gtk.Label info_label;
    Gtk.Spinner spinner;

    public WebDialog (GLib.HashTable<string, GLib.Variant> params) {
        base (params);

        var infobar = new Gtk.InfoBar.with_buttons (_("Cancel"), 0);
        var container = infobar.get_content_area () as Gtk.Container;
        var container_grid = new Gtk.Grid ();
        container_grid.column_spacing = 12;
        info_label = new Gtk.Label (_("Loading…"));
        container_grid.valign = Gtk.Align.CENTER;
        spinner = new Gtk.Spinner ();
        spinner.start ();
        container_grid.attach (spinner, 0, 0, 1, 1);
        container_grid.attach (info_label, 1, 0, 1, 1);
        container.add (container_grid);
        infobar.response.connect (() => {
            error_code = Signond.SignonUIError.CANCELED;
            finished ();
            this.destroy ();
        });

        WebKit.WebContext.get_default ().set_preferred_languages (GLib.Intl.get_language_names ());
        webview = new WebKit.WebView ();
        webview.expand = true;
        var event_box = new Gtk.EventBox ();
        event_box.add (webview);
        event_box.get_style_context ().add_class (Granite.StyleClass.CONTENT_VIEW);
        event_box.expand = true;
        attach (infobar, 0, 0, 1, 1);
        attach (event_box, 0, 1, 1, 1);
        show_all ();
        set_parameters (params);
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
        oauth_open_url = params.get (OnlineAccounts.Key.OPEN_URL).get_string ();
        oauth_final_url = params.get (OnlineAccounts.Key.FINAL_URL).get_string ();
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
            error_code = Signond.SignonUIError.NOT_AVAILABLE;
        }

        return true;
    }

    private void on_webview_load (WebKit.LoadEvent load_event) {
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

        if (load_event != WebKit.LoadEvent.REDIRECTED)
            return;

        var redirect_uri = webview.get_uri ();

        if (redirect_uri == null || !redirect_uri.has_prefix (oauth_final_url))
            return;

        /* We got the redirect URI what we are interestead in, so disconnect handler */
        webview.load_changed.disconnect (on_webview_load);
        oauth_response = redirect_uri;
        debug ("Found OAUTH Response : %s", oauth_response);
        error_code = Signond.SignonUIError.NONE;
        finished ();
    }

    public override HashTable<string, Variant> get_reply () {
        var table = base.get_reply ();
        table.insert (OnlineAccounts.Key.URL_RESPONSE, new Variant.string (oauth_response));
        return table;
    }

    public override bool refresh_captcha (string uri) {
        return true;
    }

}
