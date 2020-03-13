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
 */

public class OnlineAccounts.ProviderRow : Gtk.ListBoxRow {
    public signal void delete_request ();

    public Gtk.Revealer close_revealer { get; private set; }
    public Ag.Provider provider { get; construct; }
    public string description { get; construct; }
    public string title_text { get; construct set; }

    protected Gtk.Button delete_button;
    protected Gtk.Revealer revealer;

    private static Gtk.CssProvider css_provider;

    public ProviderRow (
        Ag.Provider provider,
        string? title_text = GLib.Markup.escape_text (provider.get_display_name ()),
        string? description = GLib.dgettext (provider.get_i18n_domain (), provider.get_description ())
    ) {
        Object (
            provider: provider,
            title_text: title_text,
            description: description
        );
    }

    static construct {
        css_provider = new Gtk.CssProvider ();
        css_provider.load_from_resource ("io/elementary/switchboard/onlineaccounts/AccountRow.css");
    }

    construct {
        var delete_image = new Gtk.Image.from_icon_name ("window-close-symbolic", Gtk.IconSize.BUTTON);
        delete_image.get_style_context ().add_provider (css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        delete_button = new Gtk.Button ();
        delete_button.image = delete_image;
        delete_button.margin_start = 6;
        delete_button.tooltip_text = (_("Delete"));
        delete_button.valign = Gtk.Align.CENTER;

        unowned Gtk.StyleContext delete_button_context = delete_button.get_style_context ();
        delete_button_context.add_class ("delete");
        delete_button_context.add_provider (css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        close_revealer = new Gtk.Revealer ();
        close_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;
        close_revealer.add (delete_button);

        var image = new Gtk.Image.from_icon_name (provider.get_icon_name (), Gtk.IconSize.DND);
        image.pixel_size = 32;
        image.use_fallback = true;

        var title_label = new Gtk.Label (title_text);
        title_label.ellipsize = Pango.EllipsizeMode.END;
        title_label.halign = Gtk.Align.START;

        var description_label = new Gtk.Label ("<span font_size='small'>%s</span>".printf (Markup.escape_text (description)));
        description_label.ellipsize = Pango.EllipsizeMode.END;
        description_label.halign = Gtk.Align.START;
        description_label.use_markup = true;

        var grid = new Gtk.Grid ();
        grid.column_spacing = 6;
        grid.margin = 6;
        grid.margin_start = 0;
        grid.attach (close_revealer, 0, 0, 1, 2);
        grid.attach (image, 1, 0, 1, 2);
        grid.attach (title_label, 2, 0);
        grid.attach (description_label, 2, 1);

        var revealer = new Gtk.Revealer ();
        revealer.reveal_child = true;
        revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
        revealer.add (grid);

        add (revealer);

        title_label.bind_property ("label", this, "title-text");
    }
}
