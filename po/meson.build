accounts_service_its = join_paths(meson.current_source_dir(), 'its', 'accounts-service.its')
accounts_service_potfiles = join_paths(meson.current_source_dir(), 'POTFILES-SERVICES')
accounts_provider_its = join_paths(meson.current_source_dir(), 'its', 'accounts-provider.its')
accounts_provider_potfiles = join_paths(meson.current_source_dir(), 'POTFILES-PROVIDERS')

i18n.gettext(gettext_name,
    args: [
        '--directory=' + meson.source_root(),
        '--from-code=UTF-8',
        '--join-existing',
    ]
)

custom_target(
    gettext_name+'-pot-services',
    command: [
        'xgettext',
        '--its='+accounts_service_its,
        '--files-from='+accounts_service_potfiles,
        '--default-domain='+gettext_name,
        '--directory='+meson.source_root(),
        '--output='+join_paths(meson.current_source_dir(), gettext_name+'.pot'),
        '--from-code=UTF-8',
    ],
    output: 'services-pot'
)

custom_target(
    gettext_name+'-pot-providers',
    command: [
        'xgettext',
        '--its='+accounts_provider_its,
        '--files-from='+accounts_provider_potfiles,
        '--default-domain='+gettext_name,
        '--directory='+meson.source_root(),
        '--output='+join_paths(meson.current_source_dir(), gettext_name+'.pot'),
        '--from-code=UTF-8',
        '--join-existing',
    ],
    output: 'providers-pot'
)
