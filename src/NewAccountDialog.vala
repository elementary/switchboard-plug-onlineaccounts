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
    public OnlineAccounts.AbstractAuthView widget { get; construct; }

    public NewAccountDialog (OnlineAccounts.AbstractAuthView widget) {
        Object (widget: widget);
    }

    construct {
        default_height = 600;
        default_width = 450;

        var frame = new Gtk.Frame (null);
        frame.expand = true;
        frame.margin = 12;
        frame.margin_top = 0;
        frame.get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        frame.add (widget);
        frame.show_all ();

        var privacy_policy_link = new Gtk.LinkButton.with_label ("https://elementary.io/privacy", _("Privacy Policy"));
        privacy_policy_link.show ();

        add_button (_("Cancel"), Gtk.ResponseType.CANCEL);

        var action_area = (Gtk.ButtonBox) get_action_area ();
        action_area.margin = 6;
        action_area.add (privacy_policy_link);
        action_area.set_child_secondary (privacy_policy_link, true);

        get_content_area ().add (frame);

        deletable = false;

        response.connect (() => {
            destroy ();
        });

        var accounts_manager = AccountsManager.get_default ();
        accounts_manager.account_added.connect ((account) => {
            destroy ();
        });
    }

    private class AccountRow : OnlineAccounts.ProviderRow {
        public AccountRow (Ag.Provider provider) {
            Object (
                description: GLib.dgettext (provider.get_i18n_domain (), provider.get_description ()),
                provider: provider,
                title_text: provider.get_display_name ()
            );
        }
    }
}
