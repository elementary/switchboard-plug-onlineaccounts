find_package (PkgConfig)

set (CMAKE_INCLUDE_CURRENT_DIR ON)
#
# SQLHeavy: Use version 0.2 if it is available; otherwise, fall back to 0.1
#
pkg_check_modules(SQLHEAVY2 QUIET sqlheavy-0.2)
if (SQLHEAVY2_FOUND)
    message("-- Will use sqlheavy-0.2")
    set(DEPS_PACKAGES ${DEPS_PACKAGES} sqlheavy-0.2)
    set(SQLHEAVY_CFLAGS ${SQLHEAVY2_CFLAGS})
    set(SQLHEAVY_LIBRARY_DIRS ${SQLHEAVY2_LIBRARY_DIRS})
    set(SQLHEAVY_LIBRARIES ${SQLHEAVY2_LIBRARIES})
else ()
    message("-- Will use sqlheavy-0.1")
    pkg_check_modules(SQLHEAVY REQUIRED sqlheavy-0.1)
    set(DEPS_PACKAGES ${DEPS_PACKAGES} sqlheavy-0.1)
endif ()

set(DEPS_CFLAGS ${DEPS_CFLAGS} ${SQLHEAVY_CFLAGS})
set(DEPS_LIBRARIES ${DEPS_LIBRARIES} ${SQLHEAVY_LIBRARIES})
set(DEPS_LIBRARY_DIRS ${DEPS_LIBRARY_DIRS} ${SQLHEAVY_LIBRARY_DIRS})

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
