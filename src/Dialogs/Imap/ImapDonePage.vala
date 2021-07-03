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

public class OnlineAccounts.ImapDonePage : Gtk.Grid {
    public signal void back ();
    public signal void close ();

    private Gtk.Stack alert_view_stack;

    construct {
        var success_alert_view = new Granite.Widgets.AlertView (
            _("All done"),
            _("E-mail account added."),
            "process-completed"
        );
        success_alert_view.get_style_context ().remove_class (Gtk.STYLE_CLASS_VIEW);
        success_alert_view.show_all ();

        alert_view_stack = new Gtk.Stack () {
            expand = true,
            homogeneous = false,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };
        alert_view_stack.add_named (success_alert_view, "success");

        var back_button = new Gtk.Button.with_label (_("Back"));

        var close_button = new Gtk.Button.with_label (_("Close")) {
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
        action_area.add (back_button);
        action_area.add (close_button);

        margin = 12;
        orientation = Gtk.Orientation.VERTICAL;
        row_spacing = 6;
        add (alert_view_stack);
        add (action_area);

        back_button.clicked.connect (() => {
            back ();
        });

        close_button.clicked.connect (() => {
            close ();
        });
    }

    public void set_error (Error? error = null) {
        var error_view = alert_view_stack.get_child_by_name ("error");
        if (error_view != null) {
            alert_view_stack.remove (error_view);
        }

        if (error == null) {
            alert_view_stack.set_visible_child_name ("success");

        } else {
            error_view = new Granite.Widgets.AlertView (
                _("Could not save configuration"),
                error.message,
                "dialog-error"
            );
            error_view.show_all ();

            alert_view_stack.add_named (error_view, "error");
            alert_view_stack.set_visible_child_name ("error");
        }
    }
}
