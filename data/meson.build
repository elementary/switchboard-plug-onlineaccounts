install_data(
    'com.google.code.AccountsSSO.gSingleSignOnUI.service',
    install_dir: join_paths(datadir, 'dbus-1', 'services')
)

install_data(
    'online-account.svg',
    install_dir: join_paths(hicolor_dir, 'scalable', 'apps'),
)

i18n.merge_file(
    input: 'onlineaccounts.appdata.xml.in',
    output: 'io.elementary.switchboard.onlineaccounts.appdata.xml',
    po_dir: join_paths(meson.source_root(), 'po', 'extra'),
    type: 'xml',
    install: true,
    install_dir: join_paths(datadir, 'metainfo'),
)
