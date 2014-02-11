# This a sample CMakeLists.txt for compiling plug for Switchboard
# http://elementaryos.org/docs/developer-guide/cmake 

cmake_minimum_required (VERSION 2.6)
cmake_policy (VERSION 2.6)

# Set the Properties of your Plug

# Set the Name of the plug, should be an executable command, lowercase, no spaces 
set (PLUGNAME "pantheon-online-accounts")
# Set the Category of the Plug, one of:
# personal, hardware, network, system
set (PLUGCATEGORY "network")
# Set the Title to use for the Plug in the Overview and in the Titlebar
set (PLUGTITLE "Online Accounts")
# The symbolic name of the Icon to use for the plug
set (PLUGICON "preferences-desktop-online-accounts")

set (PLUGCODENAME "network-pantheon-online-accounts")

project (${PLUGNAME})

#########################################################
# Only alter stuff below if you know what you are doing #
#########################################################

include (GNUInstallDirs)
set (DATADIR "${CMAKE_INSTALL_FULL_LIBDIR}/switchboard")
set (PLUGIN_DIR "${CMAKE_INSTALL_FULL_LIBDIR}/${PLUGNAME}")
set (ACCOUNTS_DIR "${CMAKE_INSTALL_PREFIX}/share/accounts")
set (PKGDATADIR "${DATADIR}/network/${PLUGNAME}")
set (GETTEXT_PACKAGE "${PLUGNAME}")


option(BUILD_SHARED_LIBS "Switch between shared and static libraries" ON)

if (BUILD_SHARED_LIBS)
    message("-- Shared libraries enabled")
else ()
    message("-- Shared libraries disabled")
endif ()

set(SRC_TARGET ${CMAKE_PROJECT_NAME})

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

# Configure file
add_definitions (-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\" -w)


#
# *_PACKAGES are used with the vala compiler (not versioned.)
# *_PKG are used with PKG-Config and for linking, etc. (They can contain versions.)
#
# Both should contain *the same packages*, except for those whose VAPI file has
# a different name. In such case, *_PACKAGES would use the name of the VAPI while
# *_PKG would use the name of the package known by pkg-config.
#

set(DEPS_PACKAGES
    glib-2.0
    gio-2.0
    gio-unix-2.0
    gee-1.0
    gtk+-3.0
    posix
    granite
    switchboard-2.0
    accounts
    gSignon
    gSignond
    json-glib-1.0
    libsecret-1
    webkit2-3.0
    libsoup-2.4
    javascriptcore-3.0
    gmodule-2.0
    rest-0.7
)

set(DEPS_PKG
    glib-2.0
    gio-2.0
    gio-unix-2.0
    gee-1.0
    gtk+-3.0>=3.8
    granite
    switchboard-2.0
    libaccounts-glib
    libgsignon-glib
    gsignond
    json-glib-1.0
    libsecret-1
    webkit2gtk-3.0
    libsoup-2.4
    javascriptcoregtk-3.0
    gmodule-2.0
    rest-0.7
)

add_subdirectory (po)
add_subdirectory (data)

find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.21.2" MINIMUM)

find_package (PkgConfig)
# Add all your dependencies to the list below
pkg_check_modules (DEPS REQUIRED ${DEPS_PKG})

add_definitions (${DEPS_CFLAGS})
link_libraries (${DEPS_LIBRARIES})
link_directories (${DEPS_LIBRARY_DIRS})

include (ValaPrecompile)

set(GLOBAL_VALAC_OPTIONS
    --vapidir=${CMAKE_SOURCE_DIR}/vapi
    --vapidir=${CMAKE_BINARY_DIR}/src
    --target-glib=2.32
    --thread
)

add_subdirectory (src)
add_subdirectory (extension)
add_subdirectory (plugins)