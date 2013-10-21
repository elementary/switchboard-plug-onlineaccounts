find_package (PkgConfig)


pkg_check_modules(FACEBOOKPLUGIN ${CORE_LIBRARY_NAME} libaccounts-glib libgsignon-glib libsoup-2.4)

if (FACEBOOKPLUGIN_FOUND)

set (CMAKE_INCLUDE_CURRENT_DIR ON)
set(FACEBOOKPLUGIN_CFLAGS ${DEPS_CFLAGS} ${FACEBOOKPLUGIN_CFLAGS})
set(FACEBOOKPLUGIN_LIBRARIES ${DEPS_LIBRARIES} ${FACEBOOKPLUGIN_LIBRARIES})
set(FACEBOOKPLUGIN_LIBRARY_DIRS ${DEPS_LIBRARY_DIRS} ${FACEBOOKPLUGIN_LIBRARY_DIRS})

link_directories (${FACEBOOKPLUGIN_LIBRARY_DIRS} ${CMAKE_CURRENT_BINARY_DIR}/../../lib)
add_definitions (${FACEBOOKPLUGIN_CFLAGS} "-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")
set (FACEBOOK_PLUGIN_PKG_DEPS
    ${DEPS_PACKAGES}
    libsoup-2.4)

set(TARGET_NAME facebook)
vala_precompile(FACEBOOKPLUGIN_VALA_C ${TARGET_NAME}
    config.vala
    facebook.vala
    FacebookProvider.vala
PACKAGES
    ${FACEBOOK_PLUGIN_PKG_DEPS}
OPTIONS
    ${GLOBAL_VALAC_OPTIONS}
)

add_library(${TARGET_NAME} MODULE ${FACEBOOKPLUGIN_VALA_C})
target_link_libraries (${TARGET_NAME} ${FACEBOOKPLUGIN_LIBRARIES})

install(TARGETS ${TARGET_NAME} DESTINATION ${PLUGIN_DIR})
install(FILES facebook.plugin DESTINATION ${PLUGIN_DIR})
install(FILES facebook.svg DESTINATION ${CMAKE_INSTALL_PREFIX}/share/icons/hicolor/scalable/apps)
install(FILES www.facebook.com.conf DESTINATION ${CMAKE_INSTALL_PREFIX}/etc/signon-ui/webkit-options.d/)
install(FILES facebook.provider DESTINATION ${CMAKE_INSTALL_PREFIX}/share/accounts/providers/)
install(FILES facebook-sharing.service DESTINATION ${CMAKE_INSTALL_PREFIX}/share/accounts/services/)
install(FILES facebook-microblog.service DESTINATION ${CMAKE_INSTALL_PREFIX}/share/accounts/services/)
install(FILES facebook-im.service DESTINATION ${CMAKE_INSTALL_PREFIX}/share/accounts/services/)

else ()

message("-- Facebook plugin disabled")

endif ()
