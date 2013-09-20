find_package (PkgConfig)


pkg_check_modules(MICROSOFTPLUGIN ${CORE_LIBRARY_NAME} libaccounts-glib libgsignon-glib)

if (MICROSOFTPLUGIN_FOUND)

set (CMAKE_INCLUDE_CURRENT_DIR ON)
set(MICROSOFTPLUGIN_CFLAGS ${DEPS_CFLAGS} ${MICROSOFTPLUGIN_CFLAGS})
set(MICROSOFTPLUGIN_LIBRARIES ${DEPS_LIBRARIES} ${MICROSOFTPLUGIN_LIBRARIES})
set(MICROSOFTPLUGIN_LIBRARY_DIRS ${DEPS_LIBRARY_DIRS} ${MICROSOFTPLUGIN_LIBRARY_DIRS})

link_directories (${MICROSOFTPLUGIN_LIBRARY_DIRS} ${CMAKE_CURRENT_BINARY_DIR}/../../lib)
add_definitions (${MICROSOFTPLUGIN_CFLAGS} "-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")
set (MICROSOFT_PLUGIN_PKG_DEPS
    ${DEPS_PACKAGES})

set(TARGET_NAME microsoft)
vala_precompile(MICROSOFTPLUGIN_VALA_C ${TARGET_NAME}
    config.vala
    Microsoft.vala
PACKAGES
    ${MICROSOFT_PLUGIN_PKG_DEPS}
OPTIONS
    ${GLOBAL_VALAC_OPTIONS}
)

add_library(${TARGET_NAME} MODULE ${MICROSOFTPLUGIN_VALA_C})
target_link_libraries (${TARGET_NAME} ${MICROSOFTPLUGIN_LIBRARIES})

install(TARGETS ${TARGET_NAME} DESTINATION ${PLUGIN_DIR})
install(FILES microsoft.plugin DESTINATION ${PLUGIN_DIR})
install(FILES microsoft.svg DESTINATION ${CMAKE_INSTALL_PREFIX}/share/icons/hicolor/scalable/apps)
install(FILES login.live.com.conf DESTINATION ${CMAKE_INSTALL_PREFIX}/etc/signon-ui/webkit-options.d/)
install(FILES microsoft.provider DESTINATION ${CMAKE_INSTALL_PREFIX}/share/accounts/providers/)

else ()

message("-- Microsoft plugin disabled")

endif ()
