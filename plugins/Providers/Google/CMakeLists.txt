
link_directories (${DEPS_LIBRARY_DIRS} ${CMAKE_CURRENT_BINARY_DIR}/../../lib)
add_definitions (${DEPS_CFLAGS} "-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")


set(G_NAME google)

vala_precompile(OAUTH_G_PLUGIN_VALA_C ${G_NAME}
    google.vala
PACKAGES
    ${DEPS_PACKAGES}
OPTIONS
    ${GLOBAL_VALAC_OPTIONS}
)

add_library(${G_NAME} MODULE ${OAUTH_G_PLUGIN_VALA_C})
target_link_libraries (${G_NAME} ${DEPS_LIBRARIES})

install(TARGETS ${G_NAME} DESTINATION ${PLUGIN_DIR}/generic-oauth-plugins/)
install(FILES google.svg DESTINATION ${CMAKE_INSTALL_PREFIX}/share/icons/hicolor/scalable/apps)
install(FILES google.provider DESTINATION ${ACCOUNTS_DIR}/providers/)
install(FILES google-calendar.service DESTINATION ${ACCOUNTS_DIR}/services/)
install(FILES google-contacts.service DESTINATION ${ACCOUNTS_DIR}/services/)
install(FILES google-drive.service DESTINATION ${ACCOUNTS_DIR}/services/)
install(FILES google-picasa.service DESTINATION ${ACCOUNTS_DIR}/services/)
install(FILES google-im.service DESTINATION ${ACCOUNTS_DIR}/services/)
install(FILES google-gmail.service DESTINATION ${ACCOUNTS_DIR}/services/)