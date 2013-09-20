find_package (PkgConfig)


pkg_check_modules(FLICKRPLUGIN libaccounts-glib account-plugin libsignon-glib)

if (FLICKRPLUGIN_FOUND)

set (CMAKE_INCLUDE_CURRENT_DIR ON)
set(FLICKRPLUGIN_CFLAGS ${DEPS_CFLAGS} ${FLICKRPLUGIN_CFLAGS})
set(FLICKRPLUGIN_LIBRARIES ${DEPS_LIBRARIES} ${FLICKRPLUGIN_LIBRARIES})
set(FLICKRPLUGIN_LIBRARY_DIRS ${DEPS_LIBRARY_DIRS} ${FLICKRPLUGIN_LIBRARY_DIRS})

link_directories (${FLICKRPLUGIN_LIBRARY_DIRS} ${CMAKE_CURRENT_BINARY_DIR}/../../lib)
add_definitions (${FLICKRPLUGIN_CFLAGS} "-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")
set (FLICKR_PLUGIN_PKG_DEPS
    ${DEPS_PACKAGES}
    AccountPlugin
    signon)

set(TARGET_NAME flickr)
vala_precompile(FLICKRPLUGIN_VALA_C ${TARGET_NAME}
    config.vala
    flickr.vala
PACKAGES
    ${FLICKR_PLUGIN_PKG_DEPS}
OPTIONS
    ${VALAC_OPTIONS}
)

add_library(${TARGET_NAME} MODULE ${FLICKRPLUGIN_VALA_C})
target_link_libraries (${TARGET_NAME} ${FLICKRPLUGIN_LIBRARIES})

install(TARGETS ${TARGET_NAME} DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/libaccount-plugin-1.0/providers/)
install(FILES flickr.svg DESTINATION ${CMAKE_INSTALL_PREFIX}/share/icons/hicolor/scalable/apps)
install(FILES secure.flickr.com.conf DESTINATION ${CMAKE_INSTALL_PREFIX}/etc/signon-ui/webkit-options.d/)
install(FILES flickr.provider DESTINATION ${CMAKE_INSTALL_PREFIX}/share/accounts/providers/)
install(FILES flickr-sharing.service DESTINATION ${CMAKE_INSTALL_PREFIX}/share/accounts/services/)
install(FILES flickr-microblog.service DESTINATION ${CMAKE_INSTALL_PREFIX}/share/accounts/services/)

else ()

message("-- flickr plugin disabled")

endif ()
