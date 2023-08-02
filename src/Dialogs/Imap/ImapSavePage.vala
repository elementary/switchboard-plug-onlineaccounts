/*
* Copyright 2021 elementary, Inc. (https://elementary.io)
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

public class OnlineAccounts.ImapSavePage : Gtk.Box {
    public signal void back ();
    public signal void close ();

    private Gtk.Button close_button;

    private Gtk.Stack stack;
    private Gtk.Button back_button;
    private Granite.Placeholder error_alert_view;
    private GLib.Cancellable? cancellable = null;

    construct {
        var busy_label = new Gtk.Label (_("Setting up the e-mail account…"));

        var busy_spinner = new Gtk.Spinner ();
        busy_spinner.start ();

        var busy_box = new Gtk.Box (HORIZONTAL, 6);
        busy_box.append (busy_label);
        busy_box.append (busy_spinner);

        error_alert_view = new Granite.Placeholder (_("Could not save the e-mail account")) {
            icon = new ThemedIcon ("process-error")
        };
        error_alert_view.remove_css_class (Granite.STYLE_CLASS_VIEW);

        var success_alert_view = new Granite.Placeholder (_("Success")) {
            description = _("E-mail account saved."),
            icon = new ThemedIcon ("process-completed")
        };
        success_alert_view.remove_css_class (Granite.STYLE_CLASS_VIEW);

        stack = new Gtk.Stack () {
            hexpand = true,
            vexpand = true,
            hhomogeneous = false,
            vhomogeneous = false,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };
        stack.add_named (busy_box, "busy");
        stack.add_named (error_alert_view, "error");
        stack.add_named (success_alert_view, "success");

        back_button = new Gtk.Button.with_label (_("Back")) {
            width_request = 86
        };

        close_button = new Gtk.Button.with_label (_("Close")) {
            width_request = 86
        };
        close_button.add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);

        var action_area = new Gtk.Box (HORIZONTAL, 6) {
            margin_top = 24,
            valign = END,
            halign = END,
            homogeneous = true,
            vexpand = true
        };
        action_area.append (back_button);
        action_area.append (close_button);

        margin_top = 12;
        margin_bottom = 12;
        margin_start = 12;
        margin_end = 12;
        orientation = VERTICAL;
        spacing = 6;
        append (stack);
        append (action_area);

        back_button.clicked.connect (() => {
            if (cancellable != null) {
                cancellable.cancel ();
            }
            back ();
        });

        close_button.clicked.connect (() => {
            if (cancellable != null) {
                cancellable.cancel ();
            }
            close ();
        });
    }

    public void show_busy (GLib.Cancellable cancellable) {
        this.cancellable = cancellable;
        stack.set_visible_child_name ("busy");
        // close_button.has_default = true;
    }

    public void show_success () {
        stack.set_visible_child_name ("success");
        back_button.visible = false;
    }

    public void show_error (Error error) {
        error_alert_view.description = error.message;
        stack.set_visible_child_name ("error");
    }
}
