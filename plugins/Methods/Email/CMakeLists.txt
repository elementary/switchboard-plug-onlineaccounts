
link_directories (${DEPS_LIBRARY_DIRS} ${CMAKE_CURRENT_BINARY_DIR}/../../lib)
add_definitions (${DEPS_CFLAGS} "-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")

set(TARGET_NAME email)

vala_precompile(EMAILPLUGIN_VALA_C ${TARGET_NAME}
    Email.vala
    EmailProvider.vala
PACKAGES
    ${DEPS_PACKAGES}
    config
OPTIONS
    ${GLOBAL_VALAC_OPTIONS}
    --vapidir ${CMAKE_SOURCE_DIR}/src
)

add_library(${TARGET_NAME} MODULE ${EMAILPLUGIN_VALA_C})
target_link_libraries (${TARGET_NAME} ${DEPS_LIBRARIES})
add_dependencies(${TARGET_NAME} ${PLUGNAME})

install(TARGETS ${TARGET_NAME} DESTINATION ${PLUGIN_DIR})
install(FILES mail.provider DESTINATION ${ACCOUNTS_DIR}/providers/)
install(FILES mail.service DESTINATION ${ACCOUNTS_DIR}/services/)
