find_package (PkgConfig)


pkg_check_modules(TWITTERPLUGIN libaccounts-glib account-plugin libsignon-glib)

if (TWITTERPLUGIN_FOUND)

set (CMAKE_INCLUDE_CURRENT_DIR ON)
set(TWITTERPLUGIN_CFLAGS ${DEPS_CFLAGS} ${TWITTERPLUGIN_CFLAGS})
set(TWITTERPLUGIN_LIBRARIES ${DEPS_LIBRARIES} ${TWITTERPLUGIN_LIBRARIES})
set(TWITTERPLUGIN_LIBRARY_DIRS ${DEPS_LIBRARY_DIRS} ${TWITTERPLUGIN_LIBRARY_DIRS})

link_directories (${TWITTERPLUGIN_LIBRARY_DIRS} ${CMAKE_CURRENT_BINARY_DIR}/../../lib)
add_definitions (${TWITTERPLUGIN_CFLAGS} "-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")
set (TWITTER_PLUGIN_PKG_DEPS
    ${DEPS_PACKAGES}
    AccountPlugin
    signon)

set(TARGET_NAME twitter)
vala_precompile(TWITTERPLUGIN_VALA_C ${TARGET_NAME}
    config.vala
    twitter.vala
PACKAGES
    ${TWITTER_PLUGIN_PKG_DEPS}
OPTIONS
    ${VALAC_OPTIONS}
)

add_library(${TARGET_NAME} MODULE ${TWITTERPLUGIN_VALA_C})
target_link_libraries (${TARGET_NAME} ${TWITTERPLUGIN_LIBRARIES})

install(TARGETS ${TARGET_NAME} DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/libaccount-plugin-1.0/providers/)
install(FILES twitter.svg DESTINATION ${CMAKE_INSTALL_PREFIX}/share/icons/hicolor/scalable/apps)
install(FILES api.twitter.com.conf DESTINATION ${CMAKE_INSTALL_PREFIX}/etc/signon-ui/webkit-options.d/)
install(FILES twitter.provider DESTINATION ${CMAKE_INSTALL_PREFIX}/share/accounts/providers/)
install(FILES twitter-microblog.service DESTINATION ${CMAKE_INSTALL_PREFIX}/share/accounts/services/)

else ()

message("-- twitter plugin disabled")

endif ()
