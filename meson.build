project(
    'online-accounts',
    'vala', 'c',
    version: '2.0.1'
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

ecal_vapi = meson.get_compiler('vala').find_library('libecal-2.0-fixes', dirs: meson.current_source_dir() / 'vapi')
edataserver_dep = dependency('libedataserver-1.2')
edataserverui_dep = dependency('libedataserverui-1.2')
glib_dep = dependency('glib-2.0')
gobject_dep = dependency('gobject-2.0')
granite_dep = dependency('granite', version: '>=6.0.0')
gtk_dep = dependency('gtk+-3.0')
handy_dep = dependency('libhandy-1', version: '>=1.0.0')
switchboard_dep = dependency('switchboard-2.0')

subdir('data')
subdir('src')
subdir('po')
