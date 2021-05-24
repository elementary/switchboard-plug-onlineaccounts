# Switchboard Online Accounts Plug
[![Translation status](https://l10n.elementary.io/widgets/switchboard/-/switchboard-plug-onlineaccounts/svg-badge.svg)](https://l10n.elementary.io/engage/switchboard/?utm_source=widget)

![screenshot](data/screenshot.png?raw=true)

## Building and Installation

You'll need the following dependencies:

* libedataserver-1.2
* libedataserverui-1.2
* libglib2.0-dev
* libgranite-dev
* libgtk-3-dev
* libswitchboard-2.0-dev
* libwebkit2gtk-4.0-dev
* meson
* valac

Run `meson` to configure the build environment and then `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`, then execute with `io.elementary.switchboard`

    ninja install
    io.elementary.switchboard
