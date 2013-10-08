# This a sample CMakeLists.txt for compiling plug for Switchboard
# http://elementaryos.org/docs/developer-guide/cmake 

cmake_minimum_required (VERSION 2.6)
cmake_policy (VERSION 2.6)

# Set the Properties of your Plug

# Set the Name of the plug, should be an executable command, lowercase, no spaces 
set (PLUGNAME "online-accounts-pantheon")
# Set the Category of the Plug, one of:
# personal, hardware, network, system
set (PLUGCATEGORY "network")
# Set the Title to use for the Plug in the Overview and in the Titlebar
set (PLUGTITLE "Online Accounts")
# The symbolic name of the Icon to use for the plug
set (PLUGICON "preferences-desktop-online-accounts")

project (${PLUGNAME})

#########################################################
# Only alter stuff below if you know what you are doing #
#########################################################

set (DATADIR "${CMAKE_INSTALL_PREFIX}/lib/plugs")
set (PLUGIN_DIR "${CMAKE_INSTALL_PREFIX}/share/${PLUGNAME}")
set (ACCOUNTS_DIR "${CMAKE_INSTALL_PREFIX}/share/accounts")
set (PKGDATADIR "${DATADIR}/pantheon/online-accounts")
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
configure_file (plug.plug ${CMAKE_BINARY_DIR}/${PLUGNAME}.plug)
install (FILES ${CMAKE_BINARY_DIR}/${PLUGNAME}.plug DESTINATION ${PKGDATADIR})
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
    gee-1.0
    gtk+-3.0
    posix
    granite
    pantheon
    accounts
    gSignon
    gSignond
    libpeas-1.0
    json-glib-1.0
    libsecret-1
)

set(DEPS_PKG
    glib-2.0
    gio-2.0
    gee-1.0
    gtk+-3.0
    granite
    pantheon
    libaccounts-glib
    libgsignon-glib
    gsignond
    libpeas-1.0
    json-glib-1.0
    libsecret-1
)

add_subdirectory (po)
add_subdirectory (data)

find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.16.0" MINIMUM)

include (ValaPrecompile)

set(GLOBAL_VALAC_OPTIONS
    --vapidir=${CMAKE_SOURCE_DIR}/vapi
    --vapidir=${CMAKE_BINARY_DIR}/src
    --target-glib=2.32
    --thread
)

add_subdirectory(src)
add_subdirectory(extension)
add_subdirectory(plugins)
