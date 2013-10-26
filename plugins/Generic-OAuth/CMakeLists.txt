find_package (PkgConfig)

pkg_check_modules(OAUTHPLUGIN ${CORE_LIBRARY_NAME} libaccounts-glib libgsignon-glib rest-0.7 json-glib-1.0 libsoup-2.4)

if (OAUTHPLUGIN_FOUND)

set (CMAKE_INCLUDE_CURRENT_DIR ON)
set(OAUTHPLUGIN_CFLAGS ${DEPS_CFLAGS} ${OAUTHPLUGIN_CFLAGS})
set(OAUTHPLUGIN_LIBRARIES ${DEPS_LIBRARIES} ${OAUTHPLUGIN_LIBRARIES})
set(OAUTHPLUGIN_LIBRARY_DIRS ${DEPS_LIBRARY_DIRS} ${OAUTHPLUGIN_LIBRARY_DIRS})

link_directories (${OAUTHPLUGIN_LIBRARY_DIRS} ${CMAKE_CURRENT_BINARY_DIR}/../../lib)
add_definitions (${OAUTHPLUGIN_CFLAGS} "-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")
set (OAUTH_PLUGIN_PKG_DEPS
    ${DEPS_PACKAGES}
    libsoup-2.4
    rest-0.7
    json-glib-1.0
    gmodule-2.0)

set(TARGET_NAME generic-oauth)

vala_precompile(OAUTHPLUGIN_VALA_C ${TARGET_NAME}
    OAuth.vala
    OAuthProvider.vala
PACKAGES
    ${OAUTH_PLUGIN_PKG_DEPS}
OPTIONS
    ${GLOBAL_VALAC_OPTIONS}
)

add_library(${TARGET_NAME} MODULE ${OAUTHPLUGIN_VALA_C})
target_link_libraries (${TARGET_NAME} ${OAUTHPLUGIN_LIBRARIES})

install(TARGETS ${TARGET_NAME} DESTINATION ${PLUGIN_DIR})
install(FILES generic-oauth.plugin DESTINATION ${PLUGIN_DIR})

else ()

message("-- OAuth plugin disabled")

endif ()
