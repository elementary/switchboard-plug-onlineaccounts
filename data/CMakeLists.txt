
# Files
file (GLOB service_types "${CMAKE_CURRENT_SOURCE_DIR}/service_types/*")
# Info-plug
install (FILES ${service_types} DESTINATION "${CMAKE_INSTALL_PREFIX}/share/accounts/service_types/")

# configure_file(${CMAKE_CURRENT_SOURCE_DIR}/com.google.code.AccountsSSO.gSingleSignOnUI.service.cmake ${CMAKE_CURRENT_BINARY_DIR}/com.google.code.AccountsSSO.gSingleSignOnUI.service)
# install (FILES ${CMAKE_CURRENT_BINARY_DIR}/com.google.code.AccountsSSO.gSingleSignOnUI.service DESTINATION "${CMAKE_INSTALL_PREFIX}/share/dbus-1/services/")
