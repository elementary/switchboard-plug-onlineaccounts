provider_name = 'nextcloud'

# Install the provider
install_data(
    provider_name + '.provider',
    install_dir: providers_dir
)

# Install the services
install_data(
    provider_name + '-calendar.service',
    provider_name + '-contacts.service',
    install_dir: services_dir,
)
