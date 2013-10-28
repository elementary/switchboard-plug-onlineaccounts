find_package (PkgConfig)

set (CMAKE_INCLUDE_CURRENT_DIR ON)

#
# Libnotify
#
pkg_check_modules(LIBNOTIFY QUIET libnotify)
if (LIBNOTIFY_FOUND)
    message("-- libnotify enabled")

    set(GLOBAL_VALAC_OPTIONS ${GLOBAL_VALAC_OPTIONS} --define=HAVE_LIBNOTIFY)

    set(DEPS_PACKAGES ${DEPS_PACKAGES} libnotify)

    set(DEPS_CFLAGS ${DEPS_CFLAGS} ${LIBNOTIFY_CFLAGS})
    set(DEPS_LIBRARIES ${DEPS_LIBRARIES} ${LIBNOTIFY_LIBRARIES})
    set(DEPS_LIBRARY_DIRS ${DEPS_LIBRARY_DIRS} ${LIBNOTIFY_LIBRARY_DIRS})
else ()
    message("-- libnotify disabled")
endif ()

link_directories (${DEPS_LIBRARY_DIRS})
add_definitions (${DEPS_CFLAGS} "-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")

set(EXTENSION_NAME extension-pantheon)
vala_precompile(EXTENSION_VALA_C ${EXTENSION_NAME}
    Extension.vala
    Keyring.vala
    Tables.vala
PACKAGES
    ${DEPS_PACKAGES}
OPTIONS
    ${GLOBAL_VALAC_OPTIONS}
)

add_library(${EXTENSION_NAME} MODULE ${EXTENSION_VALA_C})
target_link_libraries (${EXTENSION_NAME} ${DEPS_LIBRARIES})

install(TARGETS ${EXTENSION_NAME} DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/gsignond/extensions")
