/*
 * Copyright 2023 elementary, Inc. (https://elementary.io)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 *
 */

public class OnlineAccounts.SettingsSyncDialog : Hdy.Window {
    private Hdy.Deck deck;
    private SettingsSyncLoginPage login_page;
    private SettingsSyncSavePage save_page;
    private Gtk.Spinner spinner;

    construct {
        login_page = new SettingsSyncLoginPage ();
        save_page = new SettingsSyncSavePage ();

        var header_label = new Granite.HeaderLabel (_("Synchronize your settings across devices"));

        var explanation_label = new Gtk.Label (_("Settings Sync syncs your settings to a private Git repository hosted on GitHub."));
        explanation_label.set_line_wrap (true);

        spinner = new Gtk.Spinner () {
            margin = 12
        };

        var authenticate_cancel_button = new Gtk.Button.with_label (_("Cancel"));

        var authenticate_button = new Gtk.Button.with_label (_("Authenticate")) {
            can_default = true
        };
        authenticate_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

        var action_area = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
            layout_style = Gtk.ButtonBoxStyle.END,
            margin_top = 24,
            spacing = 6,
            valign = Gtk.Align.END,
            vexpand = true
        };
        action_area.add (authenticate_cancel_button);
        action_area.add (authenticate_button);

        var authenticate_page = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL,
            margin = 12
        };
        authenticate_page.add (header_label);
        authenticate_page.add (explanation_label);
        authenticate_page.add (spinner);
        authenticate_page.add (action_area);

        deck = new Hdy.Deck () {
            can_swipe_back = true,
            expand = true
        };
        deck.add (authenticate_page);
        deck.add (login_page);
        deck.add (save_page);

        var window_handle = new Hdy.WindowHandle ();
        window_handle.add (deck);

        default_height = 400;
        default_width = 300;
        window_position = Gtk.WindowPosition.CENTER_ON_PARENT;
        modal = true;
        type_hint = Gdk.WindowTypeHint.DIALOG;
        add (window_handle);

        authenticate_button.has_default = true;

        authenticate_cancel_button.clicked.connect (() => {
            destroy ();
        });

        authenticate_button.clicked.connect (() => {
            authenticate_button.sensitive = false;
            spinner.start ();

            authenticate.begin ((obj, res) => {
                try {
                    authenticate.end (res);
                } catch (Error e) {
                    save_page.show_error (e);
                    deck.visible_child = save_page;
                }
            });
        });

        login_page.cancel.connect (destroy);

        save_page.close.connect (destroy);
    }

    private async void authenticate () throws Error {
        var github = GitHub.Manager.get_default ();
        var device_response = yield github.request_device_and_user_verification_codes ();

        spinner.stop ();
        login_page.update (device_response.user_code, device_response.verification_uri);
        deck.visible_child = login_page;

        var token_response = yield github.poll_user_authorized_device (device_response.device_code, device_response.expires_in, device_response.interval);

        // TODO: save token
        save_page.show_success ();
        deck.visible_child = save_page;
    }
}
