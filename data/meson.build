desktop_config = configuration_data()
desktop_config.set ('LIBEXECDIR', libexecdir)

configure_file(
    input: meson.project_name() + '-daemon.desktop.in',
    output: '@BASENAME@',
    configuration: desktop_config,
    install_dir: join_paths(get_option('sysconfdir'), 'xdg', 'autostart')
)

i18n.merge_file(
    input: 'onlineaccounts.appdata.xml.in',
    output: 'io.elementary.switchboard.onlineaccounts.appdata.xml',
    po_dir: join_paths(meson.source_root(), 'po', 'extra'),
    type: 'xml',
    install: true,
    install_dir: join_paths(datadir, 'metainfo'),
)
