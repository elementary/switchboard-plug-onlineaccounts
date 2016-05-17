// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2013-2015 Pantheon Developers (https://launchpad.net/switchboard-plug-onlineaccounts)
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
 * Authored by: Corentin Noël <corentin@elementary.io>
 */

public class OnlineAccounts.GraphicalDialog : OnlineAccounts.Dialog {
    public signal void refresh_captcha_needed ();
    Gtk.Entry username_entry;
    Gtk.Entry password_entry;
    Gtk.Entry new_password_entry;
    Gtk.Entry confirm_password_entry;
    Gtk.Entry captcha_entry;
    Gtk.Button cancel_button;
    Gtk.Button save_button;
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

        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.CENTER;
        column_spacing = 12;
        row_spacing = 6;

        var username_label = new Gtk.Label (_("Username:"));
        username_label.halign = Gtk.Align.END;
        username_entry = new Gtk.Entry ();
        username_entry.placeholder_text = _("john_doe");
        username_entry.width_request = 256;

        var password_label = new Gtk.Label (_("Password:"));
        password_label.halign = Gtk.Align.END;
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

        forgot_button = new Gtk.LinkButton.with_label ("http://elementary.io", _("Forgot password"));

        captcha_entry = new Gtk.Entry ();
        captcha_entry.secondary_icon_name = "view-refresh";
        captcha_entry.secondary_icon_activatable = true;
        captcha_entry.secondary_icon_tooltip_text = _("Refresh Captcha");
        captcha_entry.tooltip_text = _("Enter above text here");

        message_label = new Gtk.Label ("");
        message_label.no_show_all = true;

        cancel_button = new Gtk.Button.with_label (_("Cancel"));
        save_button = new Gtk.Button.with_label (_("Log In"));
        save_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

        set_parameters (params);

        if (query_username == true) {
            attach (username_label, 1, 1, 1, 1);
            attach (username_entry, 2, 1, 1, 1);
        }

        if (query_password == true) {
            attach (password_label, 1, 2, 1, 1);
            attach (password_entry, 2, 2, 1, 1);
            attach (remember_button, 2, 5, 1, 1);
        }
        
        if (forgot_password_url != null) {
            attach (forgot_button, 1, 6, 2, 1);
        }

        if (query_confirm == true) {
            attach (new_password_label, 1, 3, 1, 1);
            attach (new_password_entry, 2, 3, 1, 1);
            attach (confirm_password_label, 1, 4, 1, 1);
            attach (confirm_password_entry, 2, 4, 1, 1);
        }

        if (query_captcha == true) {
            attach (captcha_image, 1, 7, 2, 1);
            attach (captcha_entry, 1, 8, 2, 1);
        }

        attach (message_label, 1, 9, 2, 1);
        Gtk.ButtonBox save_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
        save_box.margin_top = 12;
        save_box.spacing = 6;
        save_box.set_layout (Gtk.ButtonBoxStyle.END);
        save_box.add (cancel_button);
        save_box.add (save_button);
        save_button.clicked.connect (() => finished ());
        cancel_button.clicked.connect (() => {
            error_code = GSignond.SignonuiError.CANCELED;
            finished ();
            this.destroy ();
        });
        attach (save_box, 1, 10, 2, 1);
        show_all ();
    }

    public override bool set_parameters (HashTable<string, Variant> params) {
        if (base.set_parameters (params) == false) {
            return false;
        }

        if (validate_params (params) == false) {
            return false;
        }

        weak Variant temp_string = params.get (OnlineAccounts.Key.USERNAME);
        username_entry.sensitive = query_username;
        if (temp_string != null)
            username_entry.text = temp_string.get_string () ?? "";

        if (forgot_password_url != null) {
            forgot_button.label = _("Forgot password…");
            forgot_button.uri = forgot_password_url;
            forgot_button.activate_link.connect (() =>{
                warning ("forgot password");
                error_code = GSignond.SignonuiError.FORGOT_PASSWORD;
                finished ();
                return false;
            });
        }

        temp_string = params.get (OnlineAccounts.Key.MESSAGE);
        if (temp_string != null) {
            message_label.label = temp_string.get_string ();
            message_label.show ();
        } else {
            message_label.hide ();
        }

        temp_string = params.get (OnlineAccounts.Key.CAPTCHA_URL);
        if (temp_string != null) {
            query_captcha = refresh_captcha (temp_string.get_string ());
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
        reset_ok ();

        return true;
    }

    private bool validate_params (HashTable<string, Variant> params) {
        /* determine query type and its validate its value */
        if (OnlineAccounts.Key.QUERY_USERNAME in params) {
            query_username = params.get (OnlineAccounts.Key.QUERY_USERNAME).get_boolean ();
        }

        if (OnlineAccounts.Key.QUERY_PASSWORD in params) {
            query_password = params.get (OnlineAccounts.Key.QUERY_PASSWORD).get_boolean ();
        }

        if (OnlineAccounts.Key.CONFIRM in params) {
            query_confirm = params.get (OnlineAccounts.Key.CONFIRM).get_boolean ();
        }

        if (query_username == false && query_password == false && query_confirm == false) {
            warning ("No Valid Query found");
            return false;
        }

        if (OnlineAccounts.Key.PASSWORD in params) {
            old_password = params.get (OnlineAccounts.Key.PASSWORD).get_string ();
        }

        if (query_confirm == true && old_password == null) {
            warning ("Wrong params for confirm query");
            return false;
        }

        if (OnlineAccounts.Key.FORGOT_PASSWORD_URL in params) {
            forgot_password_url = params.get (OnlineAccounts.Key.FORGOT_PASSWORD_URL).get_string ();
        }

        params.get_keys ().foreach ((key) => {
            warning (key);
        });

        return true;
    }

    public override bool refresh_captcha (string uri) {
        if (uri == null) {
            warning ("invalid captcha value : %s", uri);
            error_code = GSignond.SignonuiError.BAD_CAPTCHA_URL;
            return false;
        }

        string filename = null;
        try {
            filename = GLib.Filename.from_uri (uri);
        } catch (Error e) {
            critical (e.message);
        }

        if (filename == null) {
            warning ("invalid captcha value : %s", uri);
            error_code = GSignond.SignonuiError.BAD_CAPTCHA_URL;
            return false;
        }

        debug ("setting captcha : %s", filename);
        captcha_image.set_from_file (filename);
        var used_filename = captcha_image.file;
        debug ("Used file : %s", used_filename);
        var is_valid = GLib.strcmp (filename, used_filename) == 0;
        if (is_valid == false) {
            error_code = GSignond.SignonuiError.BAD_CAPTCHA;
            return false;
        }

        query_captcha = true;
        return true;
    }

    public override HashTable<string, Variant> get_reply () {
        var table = base.get_reply ();
        table.insert (OnlineAccounts.Key.USERNAME, new Variant.string (username_entry.text));
        table.insert (OnlineAccounts.Key.PASSWORD, new Variant.string (password_entry.text));
        return table;
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
