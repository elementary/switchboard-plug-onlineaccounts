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

[DBus (name = "com.google.code.AccountsSSO.gSingleSignOn.UI.Dialog")]
public class OnlineAccounts.DialogService : Object {
    const string DIALOG_BUS_NAME = "com.google.code.AccountsSSO.gSingleSignOn.UI.Dialog";

    public DialogService () {
    }

    [DBus (name = "queryDialog")]
    public async HashTable<string, Variant> query_dialog(HashTable<string, Variant> parameter) {
        var main_loop = new GLib.MainLoop ();
        var dialog = RequestQueue.get_default ().push_dialog (parameter, main_loop);
        main_loop.run ();
        HashTable<string, Variant> reply;
        if (dialog is WebDialog) {
            WebDialog webdialog = dialog as WebDialog;
            reply = webdialog.get_reply ();
        } else {
            GraphicalDialog graphicaldialog = dialog as GraphicalDialog;
            graphicaldialog.refresh_captcha_needed.connect (() => {refresh (dialog.request_id);});
            reply = graphicaldialog.get_reply ();
        }

        dialog.destroy ();
        return reply;
    }
    
    [DBus (name = "refreshDialog")]
    public void refresh_dialog (HashTable<string, Variant> parameter) {
        GLib.Variant value = parameter.lookup (OnlineAccounts.Key.REQUEST_ID);
        if ((value == null) || value.is_of_type (GLib.VariantType.STRING) == false) {
            debug ("Wrong request id : %s", value != null ? value.get_type_string () : "null request id"); 
            return;
        }

        var dialog = RequestQueue.get_default ().get_dialog_from_request_id (value.get_string ());
        if (dialog == null)
            return;

        if (dialog is WebDialog) {
            WebDialog webdialog = dialog as WebDialog;
            webdialog.set_parameters (parameter);
        } else {
            GraphicalDialog graphicaldialog = dialog as GraphicalDialog;
            graphicaldialog.set_parameters (parameter);
        }
    }
    
    [DBus (name = "cancelUiRequest")]
    public void cancel_ui_request (string request_id) {
        var dialog = RequestQueue.get_default ().get_dialog_from_request_id (request_id);
        if (dialog != null) {
            dialog.error_code = GSignond.SignonuiError.CANCELED;
            dialog.finished ();
        }
    }
    
    [DBus (name = "refresh")]
    public signal void refresh (string request_id);
}
