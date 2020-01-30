plug_files = files(
    'AccountsManager.vala',
    'Account.vala',
    'Plug.vala',
    'Authentification/DialogService.vala',
    'Authentification/AbstractAuthView.vala',
    'Authentification/Key.vala',
    'Authentification/MailDialog.vala',
    'Authentification/NextcloudDialog.vala',
    'Authentification/OAuthView.vala',
    'Authentification/PasswordDialog.vala',
    'Authentification/RequestInfo.vala',
    'Authentification/RequestQueue.vala',
    'Authentification/Server.vala',
    'NewAccountDialog.vala',
    'Views/AccountView.vala',
    'Views/SourceSelector.vala',
    'Widgets/ACListBox.vala',
    'Widgets/AppRow.vala',
    'Widgets/ProviderRow.vala'
)

switchboard_dep = dependency('switchboard-2.0')
granite_dep = dependency('granite', version: '>=0.5')
gtk_dep = dependency('gtk+-3.0')
webkit_dep = dependency('webkit2gtk-4.0')

config_data = configuration_data()
config_data.set_quoted ('PREFIX', prefix)
config_h = configure_file(
    output: 'config.h',
    configuration: config_data
)

config_vapi = meson.get_compiler('vala').find_library('config', dirs: meson.current_source_dir())
config_dep = declare_dependency(dependencies: [config_vapi])

switchboard_plugsdir = switchboard_dep.get_pkgconfig_variable('plugsdir', define_variable: ['libdir', libdir])

shared_module(
    meson.project_name(),
    plug_files,
    config_h,
    dependencies: [
        glib_dep,
        gio_dep,
        gobject_dep,
        libaccounts_dep,
        libsignon_glib,
        granite_dep,
        gtk_dep,
        webkit_dep,
        switchboard_dep,
        config_dep
    ],
    install: true,
    install_dir : join_paths(switchboard_plugsdir, 'network')
)
