provider_name = 'nextcloud'
provider_exe = 'io.elementary.online-accounts.'+provider_name

executable(
    provider_exe,
    'Integration.vala',
    dependencies : [
        glib_dep,
        gio_dep,
        gobject_dep,
        libaccounts_dep,
        libsignon_glib,
        json_glib_dep,
        rest_dep,
    ],
    install: true,
    install_dir: libexecdir,
)

# Install the provider
provider_data = configuration_data()
provider_data.set ('LIBEXECDIR', libexecdir)
provider_data.set ('INTEGRATION_EXEC', provider_exe)
configure_file(
    input: provider_name+'.provider.in',
    output: '@BASENAME@',
    configuration: provider_data,
    install: true,
    install_dir: providers_dir
)

# Install the services
install_data(
    'nextcloud-calendar.service',
    'nextcloud-contacts.service',
    install_dir: services_dir,
)

# Install the icons
icon_sizes = ['32', '48']

foreach i : icon_sizes
    install_data(
        join_paths(i,'online-account-nextcloud.svg'),
        install_dir: join_paths(hicolor_dir, i + 'x' + i, 'apps'),
    )
    install_data(
        join_paths(i,'online-account-nextcloud.svg'),
        install_dir: join_paths(hicolor_dir, i + 'x' + i + '@2', 'apps'),
    )
endforeach
