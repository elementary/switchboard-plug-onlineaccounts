/*-
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

public class OnlineAccounts.SourceSelector : Gtk.Grid {
    public signal void account_selected (OnlineAccounts.Account account);

    private Gtk.ListBox list_box;
    private Gtk.SearchEntry add_account_search;

    public SourceSelector () {
        var accounts_manager = AccountsManager.get_default ();
        foreach (var account in accounts_manager.accounts_available) {
            add_account_callback (account);
        }

        accounts_manager.account_added.connect (add_account_callback);
    }

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        list_box = new Gtk.ListBox ();
        list_box.selection_mode = Gtk.SelectionMode.SINGLE;
        list_box.activate_on_single_click = true;

        var scroll = new Gtk.ScrolledWindow (null, null);
        scroll.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scroll.expand = true;
        scroll.add (list_box);

        add_account_search = new Gtk.SearchEntry ();
        add_account_search.margin = 6;
        add_account_search.placeholder_text = _("Search Providers");

        var add_account_list = new Gtk.ListBox ();
        add_account_list.width_request = 300;
        add_account_list.set_filter_func (add_list_filter_function);

        var add_account_scrolled = new Gtk.ScrolledWindow (null, null);
        add_account_scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        add_account_scrolled.min_content_height = 200;
        add_account_scrolled.add (add_account_list);

        var add_account_grid = new Gtk.Grid ();
        add_account_grid.attach (add_account_search, 0, 0);
        add_account_grid.attach (add_account_scrolled, 0, 1);
        add_account_grid.show_all ();

        var add_account_popover = new Gtk.Popover (null);
        add_account_popover.add (add_account_grid);

        var add_button = new Gtk.MenuButton ();
        add_button.always_show_image = true;
        add_button.image = new Gtk.Image.from_icon_name ("list-add-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        add_button.label = _("Add Account…");
        add_button.margin = 3;
        add_button.popover = add_account_popover;
        add_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        var remove_button = new Gtk.Button.from_icon_name ("list-remove-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        remove_button.tooltip_text = _("Remove");

        var action_bar = new Gtk.ActionBar ();
        action_bar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
        action_bar.add (add_button);
        action_bar.add (remove_button);

        add (scroll);
        add (action_bar);

        var manager = new Ag.Manager ();
        foreach (unowned Ag.Provider provider in manager.list_providers ()) {
            if (provider == null || provider.get_plugin_name () == null) {
                continue;
            }

            add_account_list.add (new ProviderRow (provider));
        }
        add_account_list.show_all ();

        remove_button.clicked.connect (remove_source);

        list_box.row_selected.connect ((row) => {
            if (row != null) {
                account_selected (((AccountRow) row).account);
            }

            remove_button.sensitive = row != null;
        });

        add_account_search.search_changed.connect (() => {
            add_account_list.invalidate_filter ();
        });

        add_account_list.row_activated.connect ((row) => {
            add_account_popover.popdown ();

            var provider = ((ProviderRow) row).provider;
            var ag_account = manager.create_account (provider.get_name ());
            var selected_account = new Account (ag_account);
            selected_account.authenticate.begin ();
        });
    }

    [CCode (instance_pos = -1)]
    private bool add_list_filter_function (Gtk.ListBoxRow row) {
        var search_term = add_account_search.text.down ();

        if (search_term in ((ProviderRow) row).provider.get_display_name ().down ()) {
            return true;
        }

        return false;
    }

    private void add_account_callback (OnlineAccounts.Account account) {
        var ag_account = account.ag_account;
        var provider = ag_account.manager.get_provider (ag_account.get_provider_name ());
        if (provider == null)
            return;

        var row = new AccountRow (account, provider);
        row.show_all ();
        list_box.add (row);
        if (list_box.get_children ().length () == 1) {
            list_box.select_row (row);
        }
    }

    public OnlineAccounts.Account? get_selected_account () {
        weak Gtk.ListBoxRow selection = list_box.get_selected_row ();
        if (selection == null)
            return null;

        return ((AccountRow) selection).account;
    }

    private void remove_source () {
        weak Gtk.ListBoxRow selection = list_box.get_selected_row ();
        if (selection == null)
            return;

        var account = ((AccountRow) selection).account;
        AccountsManager.get_default ().remove_account (account);
        selection.destroy ();
        selection = list_box.get_row_at_index (0);
        if (selection != null) {
            list_box.select_row (selection);
        }
    }

    private class AccountRow : OnlineAccounts.ProviderRow {
        public OnlineAccounts.Account account { get; construct; }

        public AccountRow (OnlineAccounts.Account account, Ag.Provider provider) {
            Object (
                account: account,
                description: GLib.Markup.escape_text (provider.get_display_name ()),
                provider: provider,
                title_text: account.ag_account.display_name ?? _("New Account")
            );
        }

        construct {
            var ag_account = account.ag_account;

            ag_account.display_name_changed.connect (() => {
                title_text = Markup.escape_text (ag_account.get_display_name () ?? _("New Account"));
            });
        }
    }
}
