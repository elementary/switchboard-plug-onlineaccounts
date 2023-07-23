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

public class OnlineAccounts.SettingsSyncSavePage : Gtk.Grid {
    public signal void close ();

    private Gtk.Button close_button;

    private Gtk.Stack stack;
    private Granite.Widgets.AlertView error_alert_view;

    construct {
        error_alert_view = new Granite.Widgets.AlertView (
            _("Settings Sync could not be set up."),
            "",
            "process-error"
        );
        error_alert_view.get_style_context ().remove_class (Gtk.STYLE_CLASS_VIEW);
        error_alert_view.show_all ();

        var success_alert_view = new Granite.Widgets.AlertView (
            _("Success"),
            _("Settings Sync has been set up."),
            "process-completed"
        );
        success_alert_view.get_style_context ().remove_class (Gtk.STYLE_CLASS_VIEW);
        success_alert_view.show_all ();

        stack = new Gtk.Stack () {
            expand = true,
            homogeneous = false,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };
        stack.add_named (error_alert_view, "error");
        stack.add_named (success_alert_view, "success");

        close_button = new Gtk.Button.with_label (_("Close")) {
            can_default = true
        };
        close_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

        var action_area = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
            layout_style = Gtk.ButtonBoxStyle.END,
            margin_top = 24,
            spacing = 6,
            valign = Gtk.Align.END,
            vexpand = true
        };
        action_area.add (close_button);

        margin = 12;
        orientation = Gtk.Orientation.VERTICAL;
        row_spacing = 6;
        add (stack);
        add (action_area);

        close_button.clicked.connect (() => {
            close ();
        });
    }

    public void show_success () {
        stack.set_visible_child_name ("success");
    }

    public void show_error (Error error) {
        error_alert_view.description = error.message;
        stack.set_visible_child_name ("error");
    }
}
