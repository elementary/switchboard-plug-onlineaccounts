/*
 * Copyright 2025 elementary, Inc. <https://elementary.io>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class OnlineAccounts.FinalizePage : Adw.NavigationPage {
    public GLib.Cancellable? cancellable { get; construct; }
    public GLib.Icon icon { get; construct; }

    private Gtk.Image badge;
    private Gtk.Label description_label;
    private Gtk.Button back_button;
    private Gtk.Button close_button;

    public FinalizePage (Icon icon, GLib.Cancellable cancellable) {
        Object (
            cancellable: cancellable,
            icon: icon
        );
    }

    construct {
        var image = new Gtk.Image.from_gicon (icon) {
            icon_size = LARGE
        };

        badge = new Gtk.Image.from_icon_name ("emblem-synchronized") {
            halign = END,
            valign = END,
            icon_size = NORMAL
        };

        var overlay = new Gtk.Overlay () {
            halign = CENTER,
            child = image
        };
        overlay.add_overlay (badge);

        var title_label = new Gtk.Label ("") {
            halign = CENTER,
            justify = CENTER,
            wrap = true,
            max_width_chars = 50,
            use_markup = true
        };
        title_label.add_css_class (Granite.STYLE_CLASS_H1_LABEL);

        description_label = new Gtk.Label ("") {
            halign = CENTER,
            justify = CENTER,
            wrap = true,
            max_width_chars = 50,
            use_markup = true
        };
        description_label.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);

        var content_box = new Gtk.Box (VERTICAL, 0);
        content_box.append (overlay);
        content_box.append (title_label);
        content_box.append (description_label);

        back_button = new Gtk.Button.with_label (_("Back"));

        close_button = new Gtk.Button.with_label (_("Close"));
        close_button.add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);

        var action_area = new Gtk.Box (HORIZONTAL, 0) {
            valign = END,
            halign = END,
            homogeneous = true,
            vexpand = true
        };
        action_area.add_css_class ("action-area");
        action_area.append (back_button);
        action_area.append (close_button);

        var box = new Gtk.Box (VERTICAL, 0);
        box.append (content_box);
        box.append (action_area);

        child = box;
        title = _("Setting up the account…");
        add_css_class ("oa-finalize");

        bind_property ("title", title_label, "label", SYNC_CREATE);

        back_button.clicked.connect (() => {
            ((Adw.NavigationView) get_ancestor (typeof (Adw.NavigationView))).pop ();
        });

        hidden.connect (() => {
            if (cancellable != null) {
                cancellable.cancel ();
            }
        });

        close_button.clicked.connect (() => {
            if (cancellable != null) {
                cancellable.cancel ();
            }

            ((Gtk.Window) get_ancestor (typeof (Gtk.Window))).close ();
        });
    }

    public void show_success () {
        title = _("Ready to go");
        description_label.label = _("Account saved");
        badge.icon_name = "process-completed";

        ((Gtk.Window) get_ancestor (typeof (Gtk.Window))).default_widget = close_button;

        // Prevent navigating back
        back_button.visible = false;
        ((Adw.NavigationView) get_ancestor (typeof (Adw.NavigationView))).replace ({this});
    }

    public void show_error (Error error) {
        title = _("Could not save the account");
        description_label.label = error.message;
        badge.icon_name = "dialog-error";
    }
}
