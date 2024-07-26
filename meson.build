project(
    'onlineaccounts',
    'vala', 'c',
    version: '8.0.0'
)

gettext_name = 'io.elementary.settings.' + meson.project_name()
gnome = import('gnome')
i18n = import('i18n')

prefix = get_option('prefix')
datadir = join_paths(prefix, get_option('datadir'))
libdir = join_paths(prefix, get_option('libdir'))
libexecdir = join_paths(prefix, get_option('libexecdir'))
hicolor_dir = join_paths(datadir, 'icons', 'hicolor')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(gettext_name),
    language:'c'
)

config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))
config_data.set_quoted('GETTEXT_PACKAGE', gettext_name)
config_file = configure_file(
    input: 'src/Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')], language: 'vala')

ecal_vapi = meson.get_compiler('vala').find_library('libecal-2.0-fixes', dirs: meson.current_source_dir() / 'vapi')
camel_dep = dependency('camel-1.2', version: '>= 3.28')
edataserver_dep = dependency('libedataserver-1.2', version: '>=3.40')
glib_dep = dependency('glib-2.0')
gobject_dep = dependency('gobject-2.0')
granite_dep = dependency('granite-7', version: '>=7.1.0')
gtk_dep = dependency('gtk4')
adw_dep = dependency('libadwaita-1', version: '>= 1.4.0')
switchboard_dep = dependency('switchboard-3')

if edataserver_dep.version().version_compare('>=3.45.1')
    add_project_arguments('--define=HAS_EDS_3_45', language: 'vala')
endif

gresource = gnome.compile_resources(
    'gresource',
    'data' / 'gresource.xml',
    source_dir: 'data'
)

subdir('data')
subdir('src')
subdir('po')

gnome.post_install(
  gtk_update_icon_cache: true
)
