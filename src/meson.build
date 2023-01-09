plug_files = files(
    'AccountsModel.vala',
    'Dialogs/CaldavDialog.vala',
    'Dialogs/Imap/CamelSession.vala',
    'Dialogs/Imap/ImapDialog.vala',
    'Dialogs/Imap/ImapSavePage.vala',
    'Dialogs/Imap/ImapLoginPage.vala',
    'MainView.vala',
    'Plug.vala',
    'Widgets/AccountMenuItem.vala',
    'Widgets/ValidationMessage.vala'
)

switchboard_plugsdir = switchboard_dep.get_pkgconfig_variable('plugsdir', define_variable: ['libdir', libdir])

if glib_dep.version().version_compare('>=2.66')
    args += '--define=HAS_GLIB_2_66'
endif

shared_module(
    meson.project_name(),
    gresource,
    plug_files,
    config_file,
    dependencies: [
        camel_dep,
        glib_dep,
        gobject_dep,
        granite_dep,
        gtk_dep,
        handy_dep,
        edataserver_dep,
        edataserverui_dep,
        switchboard_dep,
        ecal_vapi
    ],
    install: true,
    install_dir : join_paths(switchboard_plugsdir, 'network')
)
