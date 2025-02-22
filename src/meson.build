plug_files = files(
    'AccountsModel.vala',
    'Dialogs/CaldavDialog.vala',
    'Dialogs' / 'WebDavDialog.vala',
    'Dialogs/Imap/CamelSession.vala',
    'Dialogs/Imap/ImapDialog.vala',
    'Dialogs/Imap/ImapSavePage.vala',
    'Dialogs/Imap/ImapLoginPage.vala',
    'MainView.vala',
    'Plug.vala',
    'Widgets/AccountMenuItem.vala',
    'Widgets' / 'FinalizePage.vala',
    'Widgets/ValidationMessage.vala'
)

switchboard_plugsdir = switchboard_dep.get_pkgconfig_variable('plugsdir', define_variable: ['libdir', libdir])

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
        adw_dep,
        edataserver_dep,
        switchboard_dep,
        ecal_vapi
    ],
    install: true,
    install_dir : join_paths(switchboard_plugsdir, 'network')
)
