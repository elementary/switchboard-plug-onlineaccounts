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

    public signal void refresh_captcha_needed ();

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
    Gtk.Label message_label;

    bool query_username = false;
    bool query_password = false;
    bool query_confirm = false;
    bool query_captcha = false;

    bool is_username_valid = false;
    bool is_password_valid = false;
    bool is_new_password_valid = false;
    bool is_captcha_valid = false;

    string old_password;
    string forgot_password_url;

    public GraphicalDialog (GLib.HashTable<string, GLib.Variant> params) {
        base (params);
        
        column_spacing = 12;
        row_spacing = 6;
        
        var fake_grid_left = new Gtk.Grid ();
        fake_grid_left.hexpand = true;
        var fake_grid_right = new Gtk.Grid ();
        fake_grid_right.hexpand = true;
        attach (fake_grid_left, 0, 0, 1, 1);
        attach (fake_grid_right, 3, 0, 1, 1);
        
        var username_label = new Gtk.Label (_("Username:"));
        username_entry = new Gtk.Entry ();
        username_entry.placeholder_text = _("john_doe");

        var password_label = new Gtk.Label (_("Password:"));
        password_entry = new Gtk.Entry ();
        password_entry.visibility = false;
        password_entry.input_purpose = Gtk.InputPurpose.PASSWORD;
        var new_password_label = new Gtk.Label (_("New Password:"));
        new_password_entry = new Gtk.Entry ();
        new_password_entry.visibility = false;
        new_password_entry.input_purpose = Gtk.InputPurpose.PASSWORD;
        var confirm_password_label = new Gtk.Label (_("Confirm Password:"));
        confirm_password_entry = new Gtk.Entry ();
        confirm_password_entry.visibility = false;
        confirm_password_entry.input_purpose = Gtk.InputPurpose.PASSWORD;

        remember_button = new Gtk.CheckButton.with_label (_("Remember password"));

        forgot_button = new Gtk.LinkButton.with_label ("http://elementaryos.org", _("Forgot password"));

        captcha_entry = new Gtk.Entry ();
        captcha_entry.secondary_icon_name = "view-refresh";
        captcha_entry.secondary_icon_activatable = true;
        captcha_entry.secondary_icon_tooltip_text = _("Refresh Captcha");
        captcha_entry.tooltip_text = _("Enter above text here");

        message_label = new Gtk.Label ("");
        message_label.no_show_all = true;

        save_button = new Gtk.Button.with_label (_("Save"));
        cancel_button = new Gtk.Button.with_label (_("Cancel"));

        set_parameters (params);

        if (query_username == true) {
            attach (username_label, 1, 0, 1, 1);
            attach (username_entry, 2, 0, 1, 1);
        }

        if (query_password == true) {
            attach (password_label, 1, 1, 1, 1);
            attach (password_entry, 2, 1, 1, 1);
            attach (remember_button, 1, 4, 2, 1);
        }
        
        if (forgot_password_url != null) {
            attach (forgot_button, 1, 5, 2, 1);
        }

        if (query_confirm == true) {
            attach (new_password_label, 1, 2, 1, 1);
            attach (new_password_entry, 2, 2, 1, 1);
            attach (confirm_password_label, 1, 3, 1, 1);
            attach (confirm_password_entry, 2, 3, 1, 1);
        }

        if (query_captcha == true) {
            attach (captcha_image, 1, 6, 2, 1);
            attach (captcha_entry, 1, 7, 2, 1);
        }
        attach (message_label, 1, 8, 2, 1);
    }

    public override bool set_parameters (HashTable<string, Variant> params) {
        if (base.set_parameters (params) == false) {
            return false;
        }

        if (validate_params (params) == false) {
            return false;
        }

        var temp_string = params.get (OnlineAccounts.Key.USERNAME).get_string ();
        username_entry.sensitive = query_username;
        username_entry.text = temp_string ?? "";
        if (forgot_password_url != null) {
            temp_string = params.get (OnlineAccounts.Key.FORGOT_PASSWORD).get_string ();
            forgot_button.label = temp_string ?? _("Forgot password");
            forgot_button.uri = forgot_password_url;
            forgot_button.activate_link.connect (() =>{
                error_code = Signond.SignonUIError.FORGOT_PASSWORD;
                finished ();
                return false;
            });
        }

        temp_string = params.get (OnlineAccounts.Key.MESSAGE).get_string ();
        if (temp_string != null) {
            message_label.label = temp_string;
            message_label.show ();
        } else {
            message_label.hide ();
        }

        temp_string = params.get (OnlineAccounts.Key.CAPTCHA_URL).get_string ();
        if (temp_string != null) {
            query_captcha = refresh_captcha (temp_string);
        }

        if (query_username  == true) {
            username_entry.changed.connect (() => {
                is_username_valid = (username_entry.text.char_count () > 0);
                reset_ok ();
            });

            password_entry.changed.connect (() => {
                is_password_valid = (password_entry.text.char_count () > 0);
                if (query_confirm == true && is_password_valid && old_password != null)
                    is_password_valid = GLib.strcmp (old_password, password_entry.text) == 0;

                reset_ok ();
            });
        }

        if (query_confirm  == true) {
            new_password_entry.changed.connect (() => {
                string new_password = new_password_entry.text;
                string confirm = confirm_password_entry.text;
                is_new_password_valid = (new_password.char_count () > 0) && 
                                        (confirm.char_count () > 0) && 
                                        (GLib.strcmp (new_password, confirm) == 0);
                reset_ok ();
            });

            confirm_password_entry.changed.connect (() => {
                string new_password = new_password_entry.text;
                string confirm = confirm_password_entry.text;
                is_new_password_valid = (new_password.char_count () > 0) && 
                                        (confirm.char_count () > 0) && 
                                        (GLib.strcmp (new_password, confirm) == 0);
                reset_ok ();
            });
        }

        if (query_captcha  == true) {
            captcha_entry.changed.connect (() => {
                is_captcha_valid = (captcha_entry.text.char_count () > 0);
                reset_ok ();
            });
            captcha_entry.icon_release.connect ((pos, event) => {
                if (pos == Gtk.EntryIconPosition.SECONDARY) {
                    refresh_captcha_needed ();
                }
            });
        }

        return true;
    }
    
    private bool validate_params (HashTable<string, Variant> params) {
        /* determine query type and its validate its value */
        query_username = params.get (OnlineAccounts.Key.QUERY_USERNAME).get_boolean ();
        query_password = params.get (OnlineAccounts.Key.QUERY_PASSWORD).get_boolean ();
        query_confirm = params.get (OnlineAccounts.Key.CONFIRM).get_boolean ();

        if (query_username == false && query_password == false && query_confirm == false) {
            warning ("No Valid Query found");
            return false;
        }

        if (query_username == true && params.get (OnlineAccounts.Key.PASSWORD) == null) {
            warning ("No username found, for query type non QueryUsername");
            /* TODO: Is it a real issue */ 
            //return false;
        }

        old_password = params.get (OnlineAccounts.Key.PASSWORD).get_string ();

        if (query_confirm == true && old_password == null) {
            warning ("Wrong params for confirm query");
            return false;
        }

        forgot_password_url = params.get (OnlineAccounts.Key.FORGOT_PASSWORD_URL).get_string ();
        return true;
    }

    public override bool refresh_captcha (string uri) {
        if (uri == null) {
            warning ("invalid captcha value : %s", uri);
            error_code = Signond.SignonUIError.BAD_CAPTCHA_URL;
            return false;
        }

        var filename = GLib.Filename.from_uri (uri);
        if (filename == null) {
            warning ("invalid captcha value : %s", uri);
            error_code = Signond.SignonUIError.BAD_CAPTCHA_URL;
            return false;
        }

        debug ("setting captcha : %s", filename);
     
        captcha_image.set_from_file (filename);

        var used_filename = captcha_image.file;

        debug ("Used file : %s", used_filename);
        var is_valid = GLib.strcmp (filename, used_filename) == 0;

        if (is_valid == false) {
            error_code = Signond.SignonUIError.BAD_CAPTCHA;
            return false;
        }

        query_captcha = true;

        return true;
    }
    
    private void reset_ok () {
        bool state = false;

        if (query_username)
            state = is_username_valid == true && is_password_valid == true;
        else if (query_password)
            state = is_password_valid;
        else if (query_confirm)
            state = is_password_valid == true && is_new_password_valid == true;

        if (query_captcha)
            state = state && is_captcha_valid == true;

        if (save_button.sensitive != state)
            save_button.sensitive = state;
    }

}