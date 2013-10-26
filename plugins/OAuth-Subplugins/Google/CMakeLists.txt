find_package (PkgConfig)

pkg_check_modules(OAUTH_G_PLUGIN ${CORE_LIBRARY_NAME} libaccounts-glib libgsignon-glib rest-0.7 json-glib-1.0 libsoup-2.4)

if (OAUTH_G_PLUGIN_FOUND)

set (CMAKE_INCLUDE_CURRENT_DIR ON)
set(OAUTH_G_PLUGIN_CFLAGS ${DEPS_CFLAGS} ${OAUTH_G_PLUGIN_CFLAGS})
set(OAUTH_G_PLUGIN_LIBRARIES ${DEPS_LIBRARIES} ${OAUTH_G_PLUGIN_LIBRARIES})
set(OAUTH_G_PLUGIN_LIBRARY_DIRS ${DEPS_LIBRARY_DIRS} ${OAUTH_G_PLUGIN_LIBRARY_DIRS})

link_directories (${OAUTH_G_PLUGIN_LIBRARY_DIRS} ${CMAKE_CURRENT_BINARY_DIR}/../../lib)
add_definitions (${OAUTH_G_PLUGIN_CFLAGS} "-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")
set (OAUTH_G_PLUGIN_PKG_DEPS
    ${DEPS_PACKAGES}
    libsoup-2.4
    rest-0.7
    json-glib-1.0
    gmodule-2.0)

set(G_NAME google)

vala_precompile(OAUTH_G_PLUGIN_VALA_C ${G_NAME}
    google.vala
    Plugin.vala
PACKAGES
    ${OAUTH_G_PLUGIN_PKG_DEPS}
OPTIONS
    ${GLOBAL_VALAC_OPTIONS}
)

add_library(${G_NAME} MODULE ${OAUTH_G_PLUGIN_VALA_C})
target_link_libraries (${G_NAME} ${OAUTH_G_PLUGIN_LIBRARIES})

install(TARGETS ${G_NAME} DESTINATION ${PLUGIN_DIR}/generic-oauth-plugins/)
install(FILES google.plugin DESTINATION ${PLUGIN_DIR}/generic-oauth-plugins/)
install(FILES google.svg DESTINATION ${CMAKE_INSTALL_PREFIX}/share/icons/hicolor/scalable/apps)
install(FILES accounts.google.com.conf DESTINATION ${CMAKE_INSTALL_PREFIX}/etc/signon-ui/webkit-options.d/)
install(FILES google.provider DESTINATION ${ACCOUNTS_DIR}/providers/)
install(FILES google-calendar.service DESTINATION ${ACCOUNTS_DIR}/services/)
install(FILES google-contacts.service DESTINATION ${ACCOUNTS_DIR}/services/)
install(FILES google-drive.service DESTINATION ${ACCOUNTS_DIR}/services/)
install(FILES google-picasa.service DESTINATION ${ACCOUNTS_DIR}/services/)
install(FILES google-im.service DESTINATION ${ACCOUNTS_DIR}/services/)
install(FILES google-gmail.service DESTINATION ${ACCOUNTS_DIR}/services/)

else ()

message("-- Google plugin disabled")

endif ()
