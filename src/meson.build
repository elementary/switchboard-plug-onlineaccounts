plug_files = files(
    'Dialogs/CaldavDialog.vala',
    'Dialogs/ICloudDialog.vala',
    'MainView.vala',
    'Plug.vala',
    'Widgets/ValidationMessage.vala'
)

switchboard_plugsdir = switchboard_dep.get_pkgconfig_variable('plugsdir', define_variable: ['libdir', libdir])

shared_module(
    meson.project_name(),
    gresource,
    plug_files,
    dependencies: [
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
