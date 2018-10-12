provider_name = 'microsoft'
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
    install_dir: get_option('libexecdir'),
)

# Install the provider
provider_data = configuration_data()
provider_data.set ('LIBEXECDIR', join_paths(get_option('prefix'), get_option('libexecdir')))
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
    'microsoft-calendar.service',
    'microsoft-contacts.service',
    'microsoft-mails.service',
    install_dir: services_dir,
)

# Install the icons
install_data(
    '32/online-account-microsoft.svg',
    install_dir: join_paths(hicolor_dir, '32x32', 'apps'),
)

install_data(
    '48/online-account-microsoft.svg',
    install_dir: join_paths(hicolor_dir, '48x48', 'apps'),
)
