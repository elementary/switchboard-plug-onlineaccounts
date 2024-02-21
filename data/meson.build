i18n.merge_file(
    input: 'onlineaccounts.metainfo.xml.in',
    output: 'io.elementary.settings.onlineaccounts.metainfo.xml',
    po_dir: meson.project_source_root() / 'po' / 'extra',
    type: 'xml',
    install: true,
    install_dir: datadir / 'metainfo'
)

icon_sizes = ['32', '48', '64', '128']

foreach i : icon_sizes
    install_data(
        'icons' / i + '.svg',
        install_dir: datadir/ 'icons' / 'hicolor' / i + 'x' + i / 'apps',
        rename: gettext_name + '.svg'
    )
    install_data(
        'icons' / i + '.svg',
        install_dir: datadir/ 'icons' / 'hicolor' / i + 'x' + i + '@2' / 'apps',
        rename: gettext_name + '.svg'
    )
endforeach
