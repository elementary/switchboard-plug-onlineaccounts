project('io.elementary.accounts-prototypes', 'vala', 'c')

executable(
    meson.project_name(),
    'src/Application.vala',
    'src/CaldavView.vala',
    'src/MainWindow.vala',
    'src/ValidationMessage.vala',
    dependencies: [
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('granite', version: '>=0.5'),
        dependency('gtk+-3.0'),
        dependency('libhandy-1', version: '>=0.90.0')
    ],
    install : true
)
