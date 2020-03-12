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

public class OnlineAccounts.NewAccountDialog : Gtk.Dialog {
    private Gtk.SearchEntry search_entry;
    private Gtk.Stack stack;

    construct {
        default_height = 600;
        default_width = 450;

        var primary_label = new Gtk.Label (_("Connect Your Online Accounts"));
        primary_label.wrap = true;
        primary_label.max_width_chars = 60;
        primary_label.xalign = 0;
        primary_label.get_style_context ().add_class (Granite.STYLE_CLASS_PRIMARY_LABEL);

        var secondary_label = new Gtk.Label (_("Sign in to connect with apps like Mail, Contacts, and Calendar."));
        secondary_label.wrap = true;
        secondary_label.max_width_chars = 60;
        secondary_label.xalign = 0;

        search_entry = new Gtk.SearchEntry ();
        search_entry.margin = 6;
        search_entry.placeholder_text = _("Search Providers");

        var listbox = new Gtk.ListBox ();
        listbox.activate_on_single_click = true;
        listbox.expand = true;
        listbox.set_filter_func (filter_function);

        var manager = new Ag.Manager ();
        foreach (unowned Ag.Provider provider in manager.list_providers ()) {
            if (provider == null || provider.get_plugin_name () == null) {
                continue;
            }

            listbox.add (new ProviderRow (provider));
        }

        var scrolled_window = new Gtk.ScrolledWindow (null, null);
        scrolled_window.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scrolled_window.add (listbox);

        var list_grid = new Gtk.Grid ();
        list_grid.attach (search_entry, 0, 0);
        list_grid.attach (scrolled_window, 0, 1);

        stack = new Gtk.Stack ();
        stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
        stack.add_named (list_grid, "list-grid");

        var frame = new Gtk.Frame (null);
        frame.margin_top = 24;
        frame.get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        frame.add (stack);

        var grid = new Gtk.Grid ();
        grid.margin = 12;
        grid.margin_top = 0;
        grid.orientation = Gtk.Orientation.VERTICAL;
        grid.add (primary_label);
        grid.add (secondary_label);
        grid.add (frame);
        grid.show_all ();

        var privacy_policy_link = new Gtk.LinkButton.with_label ("https://elementary.io/privacy", _("Privacy Policy"));
        privacy_policy_link.show ();

        add_button (_("Cancel"), Gtk.ResponseType.CANCEL);

        var action_area = (Gtk.ButtonBox) get_action_area ();
        action_area.margin = 6;
        action_area.add (privacy_policy_link);
        action_area.set_child_secondary (privacy_policy_link, true);

        get_content_area ().add (grid);

        response.connect (() => {
            destroy ();
        });

        search_entry.search_changed.connect (() => {
            listbox.invalidate_filter ();
        });

        listbox.row_activated.connect ((row) => {
            var provider = ((OnlineAccounts.ProviderRow) row).provider;
            var ag_account = manager.create_account (provider.get_name ());
            var selected_account = new Account (ag_account);
            selected_account.authenticate.begin ();
        });
    }

    [CCode (instance_pos = -1)]
    private bool filter_function (Gtk.ListBoxRow row) {
        var search_term = search_entry.text.down ();

        if (search_term in ((OnlineAccounts.ProviderRow) row).provider.get_display_name ().down ()) {
            return true;
        }

        return false;
    }

    public void add_widget (OnlineAccounts.AbstractAuthView widget, string name) {
        stack.add_named (widget, name);
        stack.visible_child_name = name;

        widget.finished.connect (() => {
            stack.visible_child_name = "list-grid";
            GLib.Timeout.add (stack.transition_duration, () => {
                widget.destroy ();
                return GLib.Source.REMOVE;
            });
        });
    }
}
