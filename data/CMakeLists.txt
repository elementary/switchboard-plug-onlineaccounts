
# Files
file (GLOB service_types "${CMAKE_CURRENT_SOURCE_DIR}/service_types/*")
# Info-plug
install (FILES ${service_types} DESTINATION "${CMAKE_INSTALL_PREFIX}/share/accounts/service_types/")