
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/com.google.code.AccountsSSO.gSingleSignOnUI.service.cmake ${CMAKE_CURRENT_BINARY_DIR}/com.google.code.AccountsSSO.gSingleSignOnUI.service)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/com.google.code.AccountsSSO.gSingleSignOnUI.service DESTINATION ${CMAKE_INSTALL_PREFIX}/share/dbus-1/services/)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/gsso-ui-gtk-dialog.ui DESTINATION ${PKGDATADIR})
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/gsso-ui-web-dialog.ui DESTINATION ${PKGDATADIR})