
link_directories (${DEPS_LIBRARY_DIRS} ${CMAKE_CURRENT_BINARY_DIR}/../../lib)
add_definitions (${DEPS_CFLAGS} "-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")


set(FM_NAME fastmail)

vala_precompile(OAUTH_FM_PLUGIN_VALA_C ${FM_NAME}
    fastmail.vala
PACKAGES
    ${DEPS_PACKAGES}
OPTIONS
    ${GLOBAL_VALAC_OPTIONS}
)

add_library(${FM_NAME} MODULE ${OAUTH_FM_PLUGIN_VALA_C})
target_link_libraries (${FM_NAME} ${DEPS_LIBRARIES})
add_dependencies(${FM_NAME} ${PLUGNAME})

install(TARGETS ${FM_NAME} DESTINATION ${PLUGIN_DIR}/password-plugins/)
install(FILES 32/online-account-fastmail.svg DESTINATION ${CMAKE_INSTALL_PREFIX}/share/icons/hicolor/32x32/apps)
install(FILES 48/online-account-fastmail.svg DESTINATION ${CMAKE_INSTALL_PREFIX}/share/icons/hicolor/48x48/apps)
install(FILES fastmail.provider DESTINATION ${ACCOUNTS_DIR}/providers/)
install(FILES fastmail-mail.service DESTINATION ${ACCOUNTS_DIR}/services/)
