// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2013-2016 elementary LLC. (https://elementary.io)
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

public class OnlineAccounts.RequestQueue : Object {
    private static RequestQueue request_queue;
    public static RequestQueue get_default () {
        if (request_queue == null)
            request_queue = new RequestQueue ();
        return request_queue;
    }

    Gee.LinkedList<string> widgets_to_show;
    Gee.LinkedList<AbstractAuthDialog> dialogs;

    private bool is_idle = true;

    private RequestQueue () {
        widgets_to_show = new Gee.LinkedList<string> ();
        dialogs = new Gee.LinkedList<AbstractAuthDialog> ();
    }

    public AbstractAuthDialog push_dialog (HashTable<string, Variant> parameter, GLib.MainLoop main_loop) {
        var request_info = new RequestInfo (parameter, main_loop);
        return process_next (request_info);
    }

    private async void show_next_process () {
        if (is_idle == true && widgets_to_show.is_empty == false) {
            var name = widgets_to_show.peek_head ();
            is_idle = false;
            plug.switch_to_widget (name);
        }
    }

    public AbstractAuthDialog process_next (OnlineAccounts.RequestInfo info) {
        AbstractAuthDialog dialog;
        if (info.parameters.contains (OnlineAccounts.Key.OPEN_URL)) {
            dialog = new OAuthView (info.parameters);
        } else if (info.parameters.contains (OnlineAccounts.Key.ASK_EMAIL_SETTINGS)) {
            dialog = new MailDialog (info.parameters);
        } else {
            dialog = new PasswordDialog (info.parameters);
        }

        dialog.run ();

        dialogs.add (dialog);
        if (is_idle == true) {
            is_idle = false;
        }

        dialog.finished.connect (() => {
            is_idle = true;
            dialogs.remove (dialog);
            info.main_loop.quit ();
            show_next_process.begin ();
        });

        return dialog;
    }

    public AbstractAuthDialog? get_dialog_from_request_id (string request_id) {
        foreach (var dialog in dialogs) {
            if (GLib.strcmp (dialog.request_id, request_id) == 0)
                return dialog;
        }

        return null;
    }
}
