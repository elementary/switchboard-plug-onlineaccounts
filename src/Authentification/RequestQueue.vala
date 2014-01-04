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
 
public class OnlineAccounts.RequestQueue : Object {
    
    private static RequestQueue request_queue;
    public static RequestQueue get_default () {
        if (request_queue == null)
            request_queue = new RequestQueue ();
        return request_queue;
    }
    
    Gee.LinkedList<string> widgets_to_show;
    Gee.LinkedList<Dialog> dialogs;
    
    private bool is_idle = true;
    
    private RequestQueue () {
        widgets_to_show = new Gee.LinkedList<string> ();
        dialogs = new Gee.LinkedList<Dialog> ();
    }
    
    public Dialog push_dialog (HashTable<string, Variant> parameter, GLib.MainLoop main_loop) {
        var request_info = new RequestInfo (parameter, main_loop);
        return process_next (request_info);
    }
    
    public async void show_next_process () {
        if (is_idle == true && widgets_to_show.is_empty == false) {
            var name = widgets_to_show.peek_head ();
            is_idle = false;
            plug.switch_to_widget (name);
        }
    }

    public Dialog process_next (OnlineAccounts.RequestInfo info) {
        Dialog dialog;
        if (info.parameters.contains (OnlineAccounts.Key.OPEN_URL)) {
            dialog = new WebDialog (info.parameters);
            plug.add_widget_to_stack (dialog, dialog.request_id);
        } else {
            dialog = new GraphicalDialog (info.parameters);
            plug.add_widget_to_stack (dialog, dialog.request_id);
        }
        dialogs.add (dialog);

        if (is_idle == true) {
            is_idle = false;
            plug.switch_to_widget (dialog.request_id);
        }

        dialog.finished.connect (() => {
            is_idle = true;
            dialogs.remove (dialog);
            info.main_loop.quit ();
            plug.switch_to_main ();
            show_next_process.begin ();
        });

        return dialog;
    }
    
    public Dialog? get_dialog_from_request_id (string request_id) {
        foreach (var dialog in dialogs) {
            if (GLib.strcmp (dialog.request_id, request_id) == 0)
                return dialog;
        }
        return null;
    }
}