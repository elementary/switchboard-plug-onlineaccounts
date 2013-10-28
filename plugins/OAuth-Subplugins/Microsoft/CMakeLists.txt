find_package (PkgConfig)

pkg_check_modules(OAUTH_M_PLUGIN ${CORE_LIBRARY_NAME} libaccounts-glib libgsignon-glib rest-0.7 json-glib-1.0 libsoup-2.4)

if (OAUTH_M_PLUGIN_FOUND)

set (CMAKE_INCLUDE_CURRENT_DIR ON)
set(OAUTH_M_PLUGIN_CFLAGS ${DEPS_CFLAGS} ${OAUTH_M_PLUGIN_CFLAGS})
set(OAUTH_M_PLUGIN_LIBRARIES ${DEPS_LIBRARIES} ${OAUTH_M_PLUGIN_LIBRARIES})
set(OAUTH_M_PLUGIN_LIBRARY_DIRS ${DEPS_LIBRARY_DIRS} ${OAUTH_M_PLUGIN_LIBRARY_DIRS})

link_directories (${OAUTH_M_PLUGIN_LIBRARY_DIRS} ${CMAKE_CURRENT_BINARY_DIR}/../../lib)
add_definitions (${OAUTH_M_PLUGIN_CFLAGS} "-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")
set (OAUTH_M_PLUGIN_PKG_DEPS
    ${DEPS_PACKAGES}
    libsoup-2.4
    rest-0.7
    json-glib-1.0
    gmodule-2.0)

set(M_NAME microsoft)

vala_precompile(OAUTH_M_PLUGIN_VALA_C ${M_NAME}
    microsoft.vala
    Plugin.vala
PACKAGES
    ${OAUTH_M_PLUGIN_PKG_DEPS}
OPTIONS
    ${GLOBAL_VALAC_OPTIONS}
)

add_library(${M_NAME} MODULE ${OAUTH_M_PLUGIN_VALA_C})
target_link_libraries (${M_NAME} ${OAUTH_M_PLUGIN_LIBRARIES})

install(TARGETS ${M_NAME} DESTINATION ${PLUGIN_DIR}/generic-oauth-plugins/)
install(FILES microsoft.plugin DESTINATION ${PLUGIN_DIR}/generic-oauth-plugins/)
install(FILES microsoft.svg DESTINATION ${CMAKE_INSTALL_PREFIX}/share/icons/hicolor/scalable/apps)
install(FILES login.live.com.conf DESTINATION ${CMAKE_INSTALL_PREFIX}/etc/signon-ui/webkit-options.d/)
install(FILES microsoft.provider DESTINATION ${ACCOUNTS_DIR}/providers/)

else ()

message("-- Microsoft plugin disabled")

endif ()
