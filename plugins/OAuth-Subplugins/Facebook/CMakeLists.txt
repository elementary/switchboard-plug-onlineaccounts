find_package (PkgConfig)

pkg_check_modules(OAUTH_F_PLUGIN ${CORE_LIBRARY_NAME} libaccounts-glib libgsignon-glib rest-0.7 json-glib-1.0 libsoup-2.4)

if (OAUTH_F_PLUGIN_FOUND)

set (CMAKE_INCLUDE_CURRENT_DIR ON)
set(OAUTH_F_PLUGIN_CFLAGS ${DEPS_CFLAGS} ${OAUTH_F_PLUGIN_CFLAGS})
set(OAUTH_F_PLUGIN_LIBRARIES ${DEPS_LIBRARIES} ${OAUTH_F_PLUGIN_LIBRARIES})
set(OAUTH_F_PLUGIN_LIBRARY_DIRS ${DEPS_LIBRARY_DIRS} ${OAUTH_F_PLUGIN_LIBRARY_DIRS})

link_directories (${OAUTH_F_PLUGIN_LIBRARY_DIRS} ${CMAKE_CURRENT_BINARY_DIR}/../../lib)
add_definitions (${OAUTH_F_PLUGIN_CFLAGS} "-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")
set (OAUTH_F_PLUGIN_PKG_DEPS
    ${DEPS_PACKAGES}
    libsoup-2.4
    rest-0.7
    json-glib-1.0
    gmodule-2.0)

set(F_NAME facebook)

vala_precompile(OAUTH_F_PLUGIN_VALA_C ${F_NAME}
    facebook.vala
    Plugin.vala
PACKAGES
    ${OAUTH_F_PLUGIN_PKG_DEPS}
OPTIONS
    ${GLOBAL_VALAC_OPTIONS}
)

add_library(${F_NAME} MODULE ${OAUTH_F_PLUGIN_VALA_C})
target_link_libraries (${F_NAME} ${OAUTH_F_PLUGIN_LIBRARIES})

install(TARGETS ${F_NAME} DESTINATION ${PLUGIN_DIR}/generic-oauth-plugins/)
install(FILES facebook.plugin DESTINATION ${PLUGIN_DIR}/generic-oauth-plugins/)
install(FILES facebook.svg DESTINATION ${CMAKE_INSTALL_PREFIX}/share/icons/hicolor/scalable/apps)
install(FILES www.facebook.com.conf DESTINATION ${CMAKE_INSTALL_PREFIX}/etc/signon-ui/webkit-options.d/)
install(FILES facebook.provider DESTINATION ${ACCOUNTS_DIR}/providers/)
install(FILES facebook-sharing.service DESTINATION ${ACCOUNTS_DIR}/services/)
install(FILES facebook-microblog.service DESTINATION ${ACCOUNTS_DIR}/services/)
install(FILES facebook-im.service DESTINATION ${ACCOUNTS_DIR}/services/)

else ()

message("-- Facebook plugin disabled")

endif ()
