project(
    'online-accounts',
    'vala', 'c',
    version: '6.1.0'
)

gettext_name = meson.project_name() + '-plug'
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
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name() + '-plug')
config_file = configure_file(
    input: 'src/Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')], language: 'vala')

ecal_vapi = meson.get_compiler('vala').find_library('libecal-2.0-fixes', dirs: meson.current_source_dir() / 'vapi')
camel_dep = dependency('camel-1.2', version: '>= 3.28')
edataserver_dep = dependency('libedataserver-1.2')
edataserverui_dep = dependency('libedataserverui-1.2')
glib_dep = dependency('glib-2.0')
gobject_dep = dependency('gobject-2.0')
granite_dep = dependency('granite', version: '>=6.0.0')
gtk_dep = dependency('gtk+-3.0')
handy_dep = dependency('libhandy-1', version: '>=1.0.0')
switchboard_dep = dependency('switchboard-2.0')

if edataserverui_dep.version().version_compare('>=3.39.2')
    add_project_arguments('--define=HAS_EDS_3_40', language: 'vala')
endif

gresource = gnome.compile_resources(
    'gresource',
    'data' / 'gresource.xml',
    source_dir: 'data'
)

subdir('data')
subdir('src')
subdir('po')
