
set (ONLINE_ACCOUNTS_SERVICE com.google.code.AccountsSSO.gSingleSignOnUI.service)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/${ONLINE_ACCOUNTS_SERVICE}.cmake ${CMAKE_CURRENT_BINARY_DIR}/${ONLINE_ACCOUNTS_SERVICE})
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${ONLINE_ACCOUNTS_SERVICE} DESTINATION ${CMAKE_INSTALL_PREFIX}/share/dbus-1/services/)

install (FILES "${CMAKE_CURRENT_SOURCE_DIR}/pantheon-plug-onlineaccounts.desktop" DESTINATION "/usr/share/applications")