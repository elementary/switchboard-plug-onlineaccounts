/*
 * Copyright 2025 elementary, Inc. <https://elementary.io>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

/**
 * PagedDialog is a modal {@link Gtk.Window} subclass containing an {@link Adw.NavigationView}.
 */
public class OnlineAccounts.PagedDialog : Gtk.Window {
    private Adw.NavigationView navigation_view;

    construct {
        navigation_view = new Adw.NavigationView () {
            hexpand = true,
            vexpand = true
        };

        var window_handle = new Gtk.WindowHandle () {
            child = navigation_view
        };

        child = window_handle;

        default_height = 475;
        default_width = 350;
        modal = true;

        titlebar = new Gtk.Grid () { visible = false };

        add_css_class ("dialog");
        add_css_class ("paged");
    }

    /**
     * Pushes an {@link Adw.NavigationPage} onto the navigation stack
     */
    public void push_page (Adw.NavigationPage page) {
        navigation_view.push (page);
    }

    /**
     * Pops the visible {@link Adw.NavigationPage} from the navigation stack
     */
    public void pop_page () {
        navigation_view.pop ();
    }
}
