
link_directories (${DEPS_LIBRARY_DIRS} ${CMAKE_CURRENT_BINARY_DIR}/../../lib)
add_definitions (${DEPS_CFLAGS} "-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")


set(Y_NAME yahoo)

vala_precompile(OAUTH_Y_PLUGIN_VALA_C ${Y_NAME}
    yahoo.vala
PACKAGES
    ${DEPS_PACKAGES}
OPTIONS
    ${GLOBAL_VALAC_OPTIONS}
)

add_library(${Y_NAME} MODULE ${OAUTH_Y_PLUGIN_VALA_C})
target_link_libraries (${Y_NAME} ${DEPS_LIBRARIES})
add_dependencies(${Y_NAME} ${PLUGNAME})

install(TARGETS ${Y_NAME} DESTINATION ${PLUGIN_DIR}/generic-oauth-plugins/)
install(FILES 32/online-account-yahoo.svg DESTINATION ${CMAKE_INSTALL_PREFIX}/share/icons/hicolor/32x32/apps)
install(FILES 48/online-account-yahoo.svg DESTINATION ${CMAKE_INSTALL_PREFIX}/share/icons/hicolor/48x48/apps)
install(FILES yahoo.provider DESTINATION ${ACCOUNTS_DIR}/providers/)
install(FILES yahoo-calendar.service DESTINATION ${ACCOUNTS_DIR}/services/)
