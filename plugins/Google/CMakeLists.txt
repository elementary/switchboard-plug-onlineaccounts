find_package (PkgConfig)


pkg_check_modules(GOOGLEPLUGIN ${CORE_LIBRARY_NAME} libaccounts-glib libgsignon-glib webkitgtk-3.0 rest-0.7 json-glib-1.0 libsoup-2.4)

if (GOOGLEPLUGIN_FOUND)

set (CMAKE_INCLUDE_CURRENT_DIR ON)
set(GOOGLEPLUGIN_CFLAGS ${DEPS_CFLAGS} ${GOOGLEPLUGIN_CFLAGS})
set(GOOGLEPLUGIN_LIBRARIES ${DEPS_LIBRARIES} ${GOOGLEPLUGIN_LIBRARIES})
set(GOOGLEPLUGIN_LIBRARY_DIRS ${DEPS_LIBRARY_DIRS} ${GOOGLEPLUGIN_LIBRARY_DIRS})

link_directories (${GOOGLEPLUGIN_LIBRARY_DIRS} ${CMAKE_CURRENT_BINARY_DIR}/../../lib)
add_definitions (${GOOGLEPLUGIN_CFLAGS} "-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")
set (GOOGLE_PLUGIN_PKG_DEPS
    ${DEPS_PACKAGES}
    libsoup-2.4
    webkit-3.0
    rest-0.7
    json-glib-1.0)

set(TARGET_NAME google)
vala_precompile(GOOGLEPLUGIN_VALA_C ${TARGET_NAME}
    config.vala
    google.vala
    GoogleProvider.vala
PACKAGES
    ${GOOGLE_PLUGIN_PKG_DEPS}
OPTIONS
    ${GLOBAL_VALAC_OPTIONS}
)

add_library(${TARGET_NAME} MODULE ${GOOGLEPLUGIN_VALA_C})
target_link_libraries (${TARGET_NAME} ${GOOGLEPLUGIN_LIBRARIES})

install(TARGETS ${TARGET_NAME} DESTINATION ${PLUGIN_DIR})
install(FILES google.plugin DESTINATION ${PLUGIN_DIR})
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
