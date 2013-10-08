find_package (PkgConfig)

set (CMAKE_INCLUDE_CURRENT_DIR ON)

link_directories (${DEPS_LIBRARY_DIRS})
add_definitions (${DEPS_CFLAGS} "-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")

set(EXTENSION_NAME pantheon-oa)
vala_precompile(EXTENSION_VALA_C ${EXTENSION_NAME}
    Extension.vala
PACKAGES
    ${DEPS_PACKAGES}
OPTIONS
    ${GLOBAL_VALAC_OPTIONS}
)

add_library(${EXTENSION_NAME} MODULE ${EXTENSION_VALA_C})
target_link_libraries (${EXTENSION_NAME} ${DEPS_LIBRARIES})

install(TARGETS ${EXTENSION_NAME} DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/gsignond/extensions")
