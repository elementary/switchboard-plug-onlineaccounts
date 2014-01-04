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

public class OnlineAccounts.GraphicalDialog : OnlineAccounts.Dialog {
    Gtk.Entry username_entry;
    Gtk.Entry password_entry;
    Gtk.Entry new_password_entry;
    Gtk.Entry confirm_password_entry;
    Gtk.Entry captcha_entry;
    Gtk.Button save_button;
    Gtk.Button cancel_button;
    Gtk.CheckButton remember_button;
    Gtk.LinkButton forgot_button;
    Gtk.Image captcha_image;

    public GraphicalDialog (GLib.HashTable<string, GLib.Variant> params) {
        base (params);

        var username_label = new Gtk.Label (_(""));
        username_entry = new Gtk.Entry ();
        attach (username_label, 0, 0, 1, 1);
        attach (username_entry, 1, 0, 1, 1);
        password_entry = new Gtk.Entry ();
        password_entry.visibility = false;
        password_entry.input_purpose = Gtk.InputPurpose.PASSWORD;
        new_password_entry = new Gtk.Entry ();
        new_password_entry.visibility = false;
        new_password_entry.input_purpose = Gtk.InputPurpose.PASSWORD;
        confirm_password_entry = new Gtk.Entry ();
        confirm_password_entry.visibility = false;
        confirm_password_entry.input_purpose = Gtk.InputPurpose.PASSWORD;
        captcha_entry = new Gtk.Entry ();
        save_button = new Gtk.Button.with_label (_("Save"));
        cancel_button = new Gtk.Button.with_label (_("Cancel"));
        remember_button = new Gtk.CheckButton.with_label (_("Remember password"));
        forgot_button = new Gtk.LinkButton.with_label ("http://www.valadoc.org", "Valadoc");
    }

    public override bool refresh_captcha (string uri) {
        return true;
    }

}