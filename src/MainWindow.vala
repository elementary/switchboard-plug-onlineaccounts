/*
* Copyright 2020 elementary, Inc. (https://elementary.io)
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

public class MainWindow : Gtk.ApplicationWindow {
    public MainWindow (Gtk.Application application) {
        Object (application: application);
    }

    construct {
        var caldav_view = new CaldavView ();

        var stack = new Gtk.Stack ();
        stack.add_titled (caldav_view, "CalDAV", "CalDAV");

        var stack_switcher = new Gtk.StackSwitcher () {
            halign = Gtk.Align.CENTER,
            stack = stack
        };

        var frame = new Gtk.Frame (null) {
            expand = true
        };
        frame.add (stack);
        frame.get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);

        var grid = new Gtk.Grid () {
            margin = 12,
            row_spacing = 24
        };
        grid.attach (stack_switcher, 0, 0);
        grid.attach (frame, 0, 1);

        default_height = 600;
        default_width = 450;
        add (grid);
    }
}
