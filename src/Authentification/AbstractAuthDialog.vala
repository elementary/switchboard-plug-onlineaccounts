/*
 * Copyright (c) 2013-2019 elementary, Inc. (https://elementary.io)
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

public enum OnlineAccounts.SignonUIError {
    NONE,
    GENERAL,
    NO_SIGNONUI,
    BAD_PARAMETERS,
    CANCELED,
    NOT_AVAILABLE,
    BAD_URL,
    BAD_CAPTCHA,
    BAD_CAPTCHA_URL,
    REFRESH_FAILED,
    FORBIDDEN,
    FORGOT_PASSWORD
}

public abstract class OnlineAccounts.AbstractAuthDialog : Gtk.Dialog {
    public signal void finished ();

    public HashTable<string, Variant> parameters;
    public string request_id;
    public OnlineAccounts.SignonUIError error_code;

    protected Gtk.Grid content_area;

    protected AbstractAuthDialog (HashTable<string, Variant> parameter) {
        error_code = OnlineAccounts.SignonUIError.NONE;
        this.parameters = parameter;
        plug.hide_request.connect (() => {
            error_code = OnlineAccounts.SignonUIError.CANCELED;
            finished ();
        });
    }

    construct {
        content_area = new Gtk.Grid ();

        var frame = new Gtk.Frame (null) {
            expand = true,
            margin_start = 12,
            margin_end = 12
        };
        frame.get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        frame.add (content_area);
        frame.show_all ();

        add_button (_("Cancel"), Gtk.ResponseType.CANCEL);

        get_content_area ().add (frame);

        deletable = false;
        default_height = 600;
        default_width = 450;
        title = _("Add Account");

        var accounts_manager = AccountsManager.get_default ();
        accounts_manager.account_added.connect ((account) => {
            finished ();
        });
    }

    public override void response (int response_type) {
        error_code = OnlineAccounts.SignonUIError.CANCELED;
        finished ();
    }

    public virtual HashTable<string, Variant> get_reply () {
        var reply = new HashTable<string, Variant> (str_hash, str_equal);
        reply.insert (OnlineAccounts.Key.QUERY_ERROR_CODE, new Variant.uint32 (error_code));

        return reply;
    }

    public virtual bool set_parameters (HashTable<string, Variant> params) {
        this.parameters = params;
        if (!validate_params (params)) {
            error_code = OnlineAccounts.SignonUIError.BAD_PARAMETERS;
            warning ("Bad parameters");
            return false;
        }

        return true;
    }

    private bool validate_params (HashTable<string, Variant> params) {
        GLib.Variant value = params.lookup (OnlineAccounts.Key.REQUEST_ID);
        if ((value == null) || value.is_of_type (GLib.VariantType.STRING) == false) {
            debug ("Wrong request id : %s", value != null ? value.get_type_string () : "null request id");
            return false;
        }

        request_id = value.get_string ();
        return true;
    }
}
