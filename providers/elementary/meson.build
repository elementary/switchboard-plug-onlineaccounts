provider_rdnn = 'io.elementary.online-accounts.elementary'

icon_sizes = ['32', '48']

foreach i : icon_sizes
    install_data(
        i + '.svg',
        install_dir: join_paths(hicolor_dir, i + 'x' + i, 'apps'),
        rename: provider_rdnn + '.svg'
    )
    install_data(
        i + '.svg',
        install_dir: join_paths(hicolor_dir, i + 'x' + i + '@2', 'apps'),
        rename: provider_rdnn + '.svg'
    )
endforeach
