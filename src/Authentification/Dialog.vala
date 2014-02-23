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
 
public abstract class OnlineAccounts.Dialog : Gtk.Grid {
    public signal void finished ();
    
    public HashTable<string, Variant> parameters;
    public string request_id;
    public Signond.SignonUIError error_code;

    public Dialog (HashTable<string, Variant> parameter) {
        error_code = Signond.SignonUIError.NONE;
        this.parameters = parameter;
        plug.hide_request.connect (() => {
            error_code = Signond.SignonUIError.CANCELED;
            finished ();
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
            error_code = Signond.SignonUIError.BAD_PARAMETERS;
            warning ("Bad parameters");
            return false;
        }

        return true;
    }

    public abstract bool refresh_captcha (string uri);

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