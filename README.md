# Switchboard Online Accounts Plug
[![l10n](https://l10n.elementary.io/widgets/switchboard/switchboard-plug-onlineaccounts/svg-badge.svg)](https://l10n.elementary.io/projects/switchboard/switchboard-plug-onlineaccounts)

## Building and Installation

You'll need the following dependencies:

* cmake
* gsignond
* libaccounts-glib-dev
* libgee-0.8-dev
* libglib2.0-dev
* libgranite-dev
* libgsignon-glib-dev
* libgsignond-common-dev
* libgtk-3-dev
* libjson-glib-dev
* librest-dev
* libswitchboard-2.0-dev
* libwebkit2gtk-4.0-dev
* valac

It's recommended to create a clean build environment

    mkdir build
    cd build/
    
Run `cmake` to configure the build environment and then `make` to build

    cmake -DCMAKE_INSTALL_PREFIX=/usr ..
    make
    
To install, use `make install`, then execute with `switchboard`

    sudo make install
    switchboard
