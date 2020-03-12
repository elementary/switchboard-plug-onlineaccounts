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

public class OnlineAccounts.PasswordDialog : OnlineAccounts.AbstractAuthDialog {
    public signal void refresh_captcha_needed ();
    private Gtk.Entry username_entry;
    private Gtk.Entry password_entry;
    private Gtk.Entry new_password_entry;
    private Gtk.Entry confirm_password_entry;
    private Gtk.Entry captcha_entry;
    private Gtk.Button save_button;
    private Gtk.LinkButton forgot_button;
    private Gtk.LinkButton signup_button;
    private Gtk.Image captcha_image;
    private Gtk.Label message_label;
    private Gtk.Label provider_label;

    private bool query_url = false;
    private bool query_username = false;
    private bool query_password = false;
    private bool query_confirm = false;
    private bool query_captcha = false;

    private bool is_username_valid = false;
    private bool is_password_valid = false;
    private bool is_new_password_valid = false;
    private bool is_captcha_valid = false;

    private string display_name;
    private string old_password;
    private string forgot_password_url;
    private string signup_url;

    public PasswordDialog (GLib.HashTable<string, GLib.Variant> params) {
        base (params);

        provider_label = new Gtk.Label ("");
        provider_label.get_style_context ().add_class ("h1");
        provider_label.margin_bottom = 24;

        var url_entry = new Gtk.Entry ();
        url_entry.placeholder_text = _("URL");
        url_entry.input_purpose = Gtk.InputPurpose.URL;

        username_entry = new Gtk.Entry ();
        username_entry.placeholder_text = _("Email");
        username_entry.width_request = 256;

        password_entry = new Gtk.Entry ();
        password_entry.placeholder_text = _("Password");
        password_entry.visibility = false;
        password_entry.input_purpose = Gtk.InputPurpose.PASSWORD;

        new_password_entry = new Gtk.Entry ();
        new_password_entry.placeholder_text = _("New Password");
        new_password_entry.visibility = false;
        new_password_entry.input_purpose = Gtk.InputPurpose.PASSWORD;

        confirm_password_entry = new Gtk.Entry ();
        confirm_password_entry.placeholder_text = _("Confirm Password");
        confirm_password_entry.visibility = false;
        confirm_password_entry.input_purpose = Gtk.InputPurpose.PASSWORD;

        var entry_grid = new Gtk.Grid ();
        entry_grid.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);
        entry_grid.orientation = Gtk.Orientation.VERTICAL;

        forgot_button = new Gtk.LinkButton.with_label ("", _("Forgot password…"));

        captcha_entry = new Gtk.Entry ();
        captcha_entry.secondary_icon_name = "view-refresh";
        captcha_entry.secondary_icon_activatable = true;
        captcha_entry.secondary_icon_tooltip_text = _("Refresh Captcha");
        captcha_entry.tooltip_text = _("Enter above text here");

        message_label = new Gtk.Label ("");
        message_label.no_show_all = true;

        save_button = new Gtk.Button.with_label (_("Log In"));
        save_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
        save_button.hexpand = true;

        signup_button = new Gtk.LinkButton.with_label ("", _("Don't have an account? Sign Up"));

        set_parameters (params);

        var grid = new Gtk.Grid ();
        grid.column_spacing = 12;
        grid.halign = Gtk.Align.CENTER;
        grid.valign = Gtk.Align.CENTER;
        grid.vexpand = true;
        grid.margin = 12;
        grid.orientation = Gtk.Orientation.VERTICAL;
        grid.row_spacing = 6;
        grid.get_style_context ().add_class ("login");
        grid.add (provider_label);

        content_area.add (grid);

        if (query_url) {
            grid.add (url_entry);
        }

        grid.add (entry_grid);

        if (query_username) {
            entry_grid.add (username_entry);
        }

        if (query_password) {
            entry_grid.add (password_entry);
        }

        grid.add (save_button);

        if (forgot_password_url != null) {
            grid.add (forgot_button);
        }

        if (signup_url != null) {
            grid.add (signup_button);
        }

        if (query_confirm) {
            entry_grid.add (new_password_entry);
            entry_grid.add (confirm_password_entry);
        }

        if (query_captcha) {
            grid.add (captcha_image);
            grid.add (captcha_entry);
        }

        grid.add (message_label);

        password_entry.activate.connect (() => {
            if (save_button.sensitive) {
                save_button.activate ();
            }
        });
        save_button.clicked.connect (() => finished ());

        show_all ();
    }

    public override bool set_parameters (HashTable<string, Variant> params) {
        if (base.set_parameters (params) == false) {
            return false;
        }

        if (validate_params (params) == false) {
            return false;
        }

        provider_label.label = display_name;

        weak Variant temp_string = params.get (OnlineAccounts.Key.USERNAME);
        username_entry.sensitive = query_username;
        if (temp_string != null)
            username_entry.text = temp_string.get_string () ?? "";

        if (forgot_password_url != null) {
            forgot_button.uri = forgot_password_url;
            forgot_button.activate_link.connect (() =>{
                warning ("forgot password");
                error_code = OnlineAccounts.SignonUIError.FORGOT_PASSWORD;
                finished ();
                return false;
            });
        }

        if (signup_url != null) {
            signup_button.uri = signup_url;
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

        if (query_username) {
            username_entry.changed.connect (() => {
                is_username_valid = (username_entry.text.char_count () > 0);
                reset_ok ();
            });

            password_entry.changed.connect (() => {
                is_password_valid = (password_entry.text.char_count () > 0);
                if (query_confirm && is_password_valid && old_password != null)
                    is_password_valid = GLib.strcmp (old_password, password_entry.text) == 0;

                reset_ok ();
            });
        }

        if (query_confirm) {
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

        if (query_captcha) {
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

        if (OnlineAccounts.Key.QUERY_URL in params) {
            query_url = params.get (OnlineAccounts.Key.QUERY_URL).get_boolean ();
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

        if (query_confirm && old_password == null) {
            warning ("Wrong params for confirm query");
            return false;
        }

        if (OnlineAccounts.Key.DISPLAY_NAME in params) {
            display_name = params.get (OnlineAccounts.Key.DISPLAY_NAME).get_string ();
        } else {
            display_name = _("Other Account");
        }

        if (OnlineAccounts.Key.FORGOT_PASSWORD_URL in params) {
            forgot_password_url = params.get (OnlineAccounts.Key.FORGOT_PASSWORD_URL).get_string ();
        }

        if (OnlineAccounts.Key.SIGNUP_URL in params) {
            signup_url = params.get (OnlineAccounts.Key.SIGNUP_URL).get_string ();
        }

        params.get_keys ().foreach ((key) => {
            warning (key);
        });

        return true;
    }

    public bool refresh_captcha (string uri) {
        if (uri == null) {
            warning ("invalid captcha value : %s", uri);
            error_code = OnlineAccounts.SignonUIError.BAD_CAPTCHA_URL;
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
            error_code = OnlineAccounts.SignonUIError.BAD_CAPTCHA_URL;
            return false;
        }

        debug ("setting captcha : %s", filename);
        captcha_image.set_from_file (filename);
        var used_filename = captcha_image.file;
        debug ("Used file : %s", used_filename);
        var is_valid = GLib.strcmp (filename, used_filename) == 0;
        if (is_valid == false) {
            error_code = OnlineAccounts.SignonUIError.BAD_CAPTCHA;
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
            state = is_username_valid && is_password_valid;
        else if (query_password)
            state = is_password_valid;
        else if (query_confirm)
            state = is_password_valid && is_new_password_valid;

        if (query_captcha)
            state = state && is_captcha_valid;

        if (save_button.sensitive != state)
            save_button.sensitive = state;
    }

}
