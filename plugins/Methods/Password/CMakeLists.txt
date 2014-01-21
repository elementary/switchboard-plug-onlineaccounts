
link_directories (${DEPS_LIBRARY_DIRS} ${CMAKE_CURRENT_BINARY_DIR}/../../lib)
add_definitions (${DEPS_CFLAGS} "-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")

set(TARGET_NAME password)

vala_precompile(PASSWORDPLUGIN_VALA_C ${TARGET_NAME}
    Password.vala
    PasswordProvider.vala
PACKAGES
    ${DEPS_PACKAGES}
OPTIONS
    ${GLOBAL_VALAC_OPTIONS}
)

add_library(${TARGET_NAME} MODULE ${PASSWORDPLUGIN_VALA_C})
target_link_libraries (${TARGET_NAME} ${DEPS_LIBRARIES})

install(TARGETS ${TARGET_NAME} DESTINATION ${PLUGIN_DIR})