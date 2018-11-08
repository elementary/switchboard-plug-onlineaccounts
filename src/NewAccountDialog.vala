/*
 * Copyright 2013-2018 elementary, Inc. (https://elementary.io)
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

public class OnlineAccounts.AddAccountView : Gtk.Dialog {
    construct {
        height_request = 600;

        var primary_label = new Gtk.Label (_("Connect Your Online Accounts"));
        primary_label.wrap = true;
        primary_label.max_width_chars = 60;
        primary_label.xalign = 0;
        primary_label.get_style_context ().add_class (Granite.STYLE_CLASS_PRIMARY_LABEL);

        var secondary_label = new Gtk.Label (_("Sign in to connect with apps like Mail, Contacts, and Calendar."));
        secondary_label.wrap = true;
        secondary_label.max_width_chars = 60;
        secondary_label.xalign = 0;

        var listbox = new Gtk.ListBox ();
        listbox.activate_on_single_click = true;
        listbox.vexpand = true;

        var manager = new Ag.Manager ();
        foreach (unowned Ag.Provider provider in manager.list_providers ()) {
            if (provider == null || provider.get_plugin_name () == null) {
                continue;
            }

            listbox.add (new AccountRow (provider));
        }

        var scrolled_window = new Gtk.ScrolledWindow (null, null);
        scrolled_window.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scrolled_window.add (listbox);

        var frame = new Gtk.Frame (null);
        frame.margin_top = 24;
        frame.add (scrolled_window);

        var grid = new Gtk.Grid ();
        grid.halign = Gtk.Align.CENTER;
        grid.margin = 12;
        grid.margin_top = 0;
        grid.orientation = Gtk.Orientation.VERTICAL;
        grid.add (primary_label);
        grid.add (secondary_label);
        grid.add (frame);
        grid.show_all ();

        add_button (_("Cancel"), Gtk.ResponseType.CANCEL);
        get_action_area ().margin = 6;
        get_content_area ().add (grid);

        response.connect (() => {
            destroy ();
        });

        listbox.row_activated.connect ((row) => {
            var provider = ((AccountRow) row).provider;
            var ag_account = manager.create_account (provider.get_name ());
            var selected_account = new Account (ag_account);
            selected_account.authenticate.begin ();
            destroy ();
        });
    }

    private class AccountRow : Gtk.ListBoxRow {
        public Ag.Provider provider { get; construct; }

        public AccountRow (Ag.Provider provider) {
            Object (provider: provider);
        }

        construct {
            var image = new Gtk.Image.from_icon_name (provider.get_icon_name (), Gtk.IconSize.DND);
            image.pixel_size = 32;
            image.use_fallback = true;

            var title_label = new Gtk.Label (provider.get_display_name ());
            title_label.ellipsize = Pango.EllipsizeMode.END;
            title_label.halign = Gtk.Align.START;

            var description = GLib.dgettext (provider.get_i18n_domain (), provider.get_description ());

            var description_label = new Gtk.Label ("<span font_size='small'>%s</span>".printf (description));
            description_label.ellipsize = Pango.EllipsizeMode.END;
            description_label.halign = Gtk.Align.START;
            description_label.use_markup = true;

            var grid = new Gtk.Grid ();
            grid.margin = 6;
            grid.column_spacing = 6;
            grid.attach (image, 0, 0, 1, 2);
            grid.attach (title_label, 1, 0);
            grid.attach (description_label, 1, 1);

            add (grid);
        }
    }
}
