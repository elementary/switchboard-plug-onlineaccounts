
link_directories (${DEPS_LIBRARY_DIRS} ${CMAKE_CURRENT_BINARY_DIR}/../../lib)
add_definitions (${DEPS_CFLAGS} "-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")

set(M_NAME microsoft)

vala_precompile(OAUTH_M_PLUGIN_VALA_C ${M_NAME}
    microsoft.vala
PACKAGES
    ${DEPS_PACKAGES}
OPTIONS
    ${GLOBAL_VALAC_OPTIONS}
)

add_library(${M_NAME} MODULE ${OAUTH_M_PLUGIN_VALA_C})
target_link_libraries (${M_NAME} ${DEPS_LIBRARIES})
add_dependencies(${M_NAME} ${PLUGNAME})

install(TARGETS ${M_NAME} DESTINATION ${PLUGIN_DIR}/generic-oauth-plugins/)
install(FILES microsoft.svg DESTINATION ${CMAKE_INSTALL_PREFIX}/share/icons/hicolor/scalable/apps)
install(FILES microsoft.provider DESTINATION ${ACCOUNTS_DIR}/providers/)
install(FILES microsoft-contacts.service DESTINATION ${ACCOUNTS_DIR}/services/)
install(FILES microsoft-calendar.service DESTINATION ${ACCOUNTS_DIR}/services/)
install(FILES microsoft-mails.service DESTINATION ${ACCOUNTS_DIR}/services/)
