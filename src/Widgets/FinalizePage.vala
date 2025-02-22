/*
 * Copyright 2025 elementary, Inc. <https://elementary.io>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class OnlineAccounts.FinalizePage : Adw.NavigationPage {
    public GLib.Cancellable? cancellable { get; construct; }

    private Granite.Placeholder placeholder;
    private Gtk.Button back_button;
    private Gtk.Button close_button;
    private Gtk.Stack stack;

    public FinalizePage (GLib.Cancellable cancellable) {
        Object (cancellable: cancellable);
    }

    construct {
        var busy_label = new Gtk.Label (_("Setting up the account…"));

        var busy_spinner = new Gtk.Spinner ();
        busy_spinner.start ();

        var busy_box = new Gtk.Box (HORIZONTAL, 6);
        busy_box.append (busy_label);
        busy_box.append (busy_spinner);

        placeholder = new Granite.Placeholder ("");
        placeholder.remove_css_class (Granite.STYLE_CLASS_VIEW);

        back_button = new Gtk.Button.with_label (_("Back")) {
            width_request = 86
        };

        close_button = new Gtk.Button.with_label (_("Close")) {
            width_request = 86
        };
        close_button.add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);

        stack = new Gtk.Stack () {
            hexpand = true,
            vexpand = true,
            hhomogeneous = false,
            vhomogeneous = false,
            halign = CENTER,
            valign = CENTER
        };
        stack.add_child (busy_box);
        stack.add_child (placeholder);

        var action_area = new Gtk.Box (HORIZONTAL, 6) {
            margin_top = 24,
            valign = END,
            halign = END,
            homogeneous = true,
            vexpand = true
        };
        action_area.append (back_button);
        action_area.append (close_button);

        var box = new Gtk.Box (VERTICAL, 6) {
            margin_start = 12,
            margin_end = 12,
            margin_top = 12,
            margin_bottom = 12,
        };
        box.append (stack);
        box.append (action_area);

        child = box;
        title = _("Setting up the account…");
        add_css_class ("oa-finalize");

        bind_property ("title", placeholder, "title");

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
        placeholder.description = _("Account saved");
        placeholder.icon = new ThemedIcon ("process-completed");

        stack.visible_child = placeholder;
        back_button.visible = false;

        ((Gtk.Window) get_ancestor (typeof (Gtk.Window))).default_widget = close_button;
    }

    public void show_error (Error error) {
        title = _("Could not save the account");
        placeholder.description = error.message;
        placeholder.icon = new ThemedIcon ("dialog-error");

        stack.visible_child = placeholder;
    }
}
