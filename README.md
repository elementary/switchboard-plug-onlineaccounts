# Switchboard Online Accounts Plug
[![l10n](https://l10n.elementary.io/widgets/switchboard/switchboard-plug-onlineaccounts/svg-badge.svg)](https://l10n.elementary.io/projects/switchboard/switchboard-plug-onlineaccounts)

## Building and Installation

It's recommended to create a clean build environment

    mkdir build
    cd build/
    
Run `cmake` to configure the build environment and then `make` to build

    cmake -DCMAKE_INSTALL_PREFIX=/usr ..
    make
    
To install, use `make install`, then execute with `switchboard`

    sudo make install
    switchboard
