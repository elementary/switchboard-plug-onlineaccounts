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

public abstract class OnlineAccounts.AbstractAuthView : Gtk.Grid {
    public signal void finished ();

    public HashTable<string, Variant> parameters;
    public string request_id;
    public OnlineAccounts.SignonUIError error_code;

    protected Gtk.Grid content_area;
    protected Gtk.Label title_label;
    protected Gtk.Spinner spinner;

    protected AbstractAuthView (HashTable<string, Variant> parameter) {
        error_code = OnlineAccounts.SignonUIError.NONE;
        this.parameters = parameter;
        plug.hide_request.connect (() => {
            error_code = OnlineAccounts.SignonUIError.CANCELED;
            finished ();
        });
    }

    construct {
        title_label = new Gtk.Label (_("Please enter your credentials…"));

        var back_button = new Gtk.Button.with_label (_("Back"));
        back_button.halign = Gtk.Align.START;
        back_button.margin = 6;
        back_button.get_style_context ().add_class (Granite.STYLE_CLASS_BACK_BUTTON);

        spinner = new Gtk.Spinner ();
        spinner.halign = Gtk.Align.END;
        spinner.margin = 6;

        var header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        header_box.hexpand = true;
        header_box.add (back_button);
        header_box.set_center_widget (title_label);
        header_box.pack_end (spinner);

        content_area = new Gtk.Grid ();

        attach (header_box, 0, 0);
        attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 0, 1);
        attach (content_area, 0, 2);

        back_button.clicked.connect (() => {
            error_code = OnlineAccounts.SignonUIError.CANCELED;
            finished ();
            this.destroy ();
        });
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
