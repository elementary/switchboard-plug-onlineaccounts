# Switchboard Online Accounts Plug
[![Translation status](https://l10n.elementary.io/widgets/switchboard/-/switchboard-plug-onlineaccounts/svg-badge.svg)](https://l10n.elementary.io/engage/switchboard/?utm_source=widget)

![screenshot](data/screenshot.png?raw=true)

## Building and Installation

You'll need the following dependencies:

* libaccounts-glib-dev
* libgee-0.8-dev
* libglib2.0-dev
* libgranite-dev
* libsignon-glib-dev
* libgtk-3-dev
* libjson-glib-dev
* librest-dev
* libswitchboard-2.0-dev
* libwebkit2gtk-4.0-dev
* meson
* valac

Run `meson` to configure the build environment and then `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`, then execute with `switchboard`

    sudo ninja install
    switchboard

## Regenerate the translation template

Run the commands in the following order:

    ninja po/services-pot
    ninja po/providers-pot
    ninja online-accounts-plug-pot
    ninja online-accounts-plug-update-po
