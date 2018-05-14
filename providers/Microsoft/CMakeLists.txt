add_definitions (${DEPS_CFLAGS} "-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")

set (INTEGRATION_EXEC io.elementary.online_accounts_microsoft)
vala_precompile(MICROSOFT_INTEGRATION_C ${INTEGRATION_EXEC}
    Integration.vala
PACKAGES
    ${DEPS_PACKAGES}
OPTIONS
    ${GLOBAL_VALAC_OPTIONS}
)

add_executable(${INTEGRATION_EXEC} ${MICROSOFT_INTEGRATION_C})
target_link_libraries (${INTEGRATION_EXEC} ${DEPS_LIBRARIES})

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/microsoft.provider.in ${CMAKE_CURRENT_BINARY_DIR}/microsoft.provider)

install(TARGETS ${INTEGRATION_EXEC} DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBEXECDIR}/)
install(FILES 32/online-account-microsoft.svg DESTINATION ${CMAKE_INSTALL_PREFIX}/share/icons/hicolor/32x32/apps)
install(FILES 48/online-account-microsoft.svg DESTINATION ${CMAKE_INSTALL_PREFIX}/share/icons/hicolor/48x48/apps)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/microsoft.provider DESTINATION ${ACCOUNTS_DIR}/providers/)
install(FILES microsoft-contacts.service DESTINATION ${ACCOUNTS_DIR}/services/)
install(FILES microsoft-calendar.service DESTINATION ${ACCOUNTS_DIR}/services/)
install(FILES microsoft-mails.service DESTINATION ${ACCOUNTS_DIR}/services/)
