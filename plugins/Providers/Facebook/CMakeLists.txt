
link_directories (${DEPS_LIBRARY_DIRS} ${CMAKE_CURRENT_BINARY_DIR}/../../lib)
add_definitions (${DEPS_CFLAGS} "-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")

set(F_NAME facebook)

vala_precompile(OAUTH_F_PLUGIN_VALA_C ${F_NAME}
    facebook.vala
PACKAGES
    ${DEPS_PACKAGES}
OPTIONS
    ${GLOBAL_VALAC_OPTIONS}
)

add_library(${F_NAME} MODULE ${OAUTH_F_PLUGIN_VALA_C})
target_link_libraries (${F_NAME} ${DEPS_LIBRARIES})
add_dependencies(${F_NAME} ${PLUGNAME})

install(TARGETS ${F_NAME} DESTINATION ${PLUGIN_DIR}/generic-oauth-plugins/)
install(FILES 48/online-account-facebook.svg DESTINATION ${CMAKE_INSTALL_PREFIX}/share/icons/hicolor/48x48/apps)
install(FILES 32/online-account-facebook.svg DESTINATION ${CMAKE_INSTALL_PREFIX}/share/icons/hicolor/32x32/apps)
install(FILES facebook.provider DESTINATION ${ACCOUNTS_DIR}/providers/)
install(FILES facebook-calendar.service DESTINATION ${ACCOUNTS_DIR}/services/)
install(FILES facebook-contacts.service DESTINATION ${ACCOUNTS_DIR}/services/)
install(FILES facebook-microblog.service DESTINATION ${ACCOUNTS_DIR}/services/)
