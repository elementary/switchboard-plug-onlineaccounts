/*-
 * Copyright 2020 elementary LLC. (https://elementary.io)
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

public class OnlineAccounts.CalDavDialog : OnlineAccounts.AbstractAuthDialog {
    private Gtk.Button save_button;

    private Gtk.Entry url_entry;
    private Gtk.Entry username_entry;
    private Gtk.Entry password_entry;
    private Gtk.ComboBoxText encryption_combobox;

    public CalDavDialog (GLib.HashTable<string, GLib.Variant> params) {
        base (params);

        var back_button = new Gtk.Button.with_label (_("Back"));
        back_button.halign = Gtk.Align.START;
        back_button.margin = 6;
        back_button.get_style_context ().add_class (Granite.STYLE_CLASS_BACK_BUTTON);

        var main_grid = new Gtk.Grid () {
          expand = true,
          margin = 12,
          halign = Gtk.Align.CENTER,
          valign = Gtk.Align.CENTER,
          row_spacing = 24,
          orientation = Gtk.Orientation.VERTICAL
        };
        main_grid.get_style_context ().add_class ("login");

        url_entry = new Gtk.Entry ();
        url_entry.placeholder_text = _("URL");
        url_entry.hexpand = true;

        username_entry = new Gtk.Entry ();
        username_entry.placeholder_text = _("User");
        username_entry.hexpand = true;

        password_entry = new Gtk.Entry ();
        password_entry.placeholder_text = _("Password");
        password_entry.visibility = false;
        password_entry.input_purpose = Gtk.InputPurpose.PASSWORD;

        var credentials = new Gtk.Grid ();
        credentials.orientation = Gtk.Orientation.VERTICAL;
        credentials.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);
        credentials.add (url_entry);
        credentials.add (username_entry);
        credentials.add (password_entry);

        var encryption_label = new Gtk.Label (_("Encryption:"));

        encryption_combobox = new Gtk.ComboBoxText ();
        encryption_combobox.hexpand = true;
        encryption_combobox.append ("None", _("None"));
        encryption_combobox.append ("SSL/TLS", "SSL/TLS");
        encryption_combobox.active = 1;

        var encryption_grid = new Gtk.Grid ();
        encryption_grid.column_spacing = 6;
        encryption_grid.add (encryption_label);
        encryption_grid.add (encryption_combobox);

        save_button = new Gtk.Button.with_label (_("Log In"));
        save_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
        save_button.hexpand = true;
        save_button.sensitive = false;

        main_grid.add (credentials);
        main_grid.add (encryption_grid);
        main_grid.add (save_button);

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.add (main_grid);

        content_area.add (scrolled);

        set_parameters (params);

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

        weak Variant temp_string = params.get ("URL");
        if (temp_string != null) {
            url_entry.text = temp_string.get_string ();
        }

        temp_string = params.get ("User");
        if (temp_string != null) {
            username_entry.text = temp_string.get_string ();
        }

        temp_string = params.get ("Password");
        if (temp_string != null) {
            password_entry.text = temp_string.get_string ();
        }

        temp_string = params.get ("Security");
        if (temp_string != null) {
            encryption_combobox.active_id = temp_string.get_string ();
        }

        reset_ok ();

        return true;
    }

    private void reset_ok () {
        bool state = true;
        save_button.sensitive = state;
    }

    private bool validate_params (HashTable<string, Variant> params) {
        return true;
    }

    public override HashTable<string, Variant> get_reply () {
        var table = base.get_reply ();
        table.insert ("URL", new Variant.string (url_entry.text));
        table.insert ("User", new Variant.string (username_entry.text));
        table.insert ("Password", new Variant.string (password_entry.text));
        table.insert ("Security", new Variant.string (encryption_combobox.active_id));
        return table;
    }
}
