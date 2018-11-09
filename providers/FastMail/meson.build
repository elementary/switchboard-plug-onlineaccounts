# Install the provider
install_data(
    'fastmail.provider',
    install_dir: providers_dir
)

# Install the services
install_data(
    'fastmail-mail.service',
    install_dir: services_dir,
)

# Install the icons
icon_sizes = ['32', '48']

foreach i : icon_sizes
    install_data(
        join_paths(i,'online-account-fastmail.svg'),
        install_dir: join_paths(hicolor_dir, i + 'x' + i, 'apps'),
    )
    install_data(
        join_paths(i,'online-account-fastmail.svg'),
        install_dir: join_paths(hicolor_dir, i + 'x' + i + '@2', 'apps'),
    )
endforeach
