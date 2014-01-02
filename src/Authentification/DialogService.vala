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
    
    [DBus (name = "queryDialog")]
    public HashTable<string, Variant> query_dialog(HashTable<string, Variant> parameter) {
        warning ("");
        return parameter;
    }
    
    [DBus (name = "refreshDialog")]
    public void refresh_dialog (HashTable<string, Variant> parameter) {
        return;
    }
    
    [DBus (name = "cancelUiRequest")]
    public void cancel_ui_request (string request_id) {
        return;
    }
    
    [DBus (name = "refresh")]
    public signal void refresh(string request_id);
}