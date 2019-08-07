provider_rdnn = 'io.elementary.online-accounts.icloud'

install_data(
    'com.icloud.provider',
    install_dir: providers_dir
)

install_data(
    'com.icloud.calendar.service',
    'com.icloud.contacts.service',
    'com.icloud.mail.service',
    'com.icloud.tasks.service',
    install_dir: services_dir,
)

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
