
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/config.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config.h)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/${PLUGNAME}.pc.cmake ${CMAKE_CURRENT_BINARY_DIR}/${PLUGNAME}.pc)

# Add all your vala files and requires packages to the List below to include them in the build
vala_precompile (POA_VALA_C "libpoa"
    AccountsManager.vala
    Account.vala
    PluginManager.vala
    MethodPlugin.vala
    ProviderPlugin.vala
PACKAGES
    ${DEPS_PACKAGES}
    config
    glib-addons
OPTIONS
    ${GLOBAL_VALAC_OPTIONS}
    --vapidir ${CMAKE_CURRENT_SOURCE_DIR}
GENERATE_VAPI
    ${PLUGNAME}
GENERATE_HEADER
    ${PLUGNAME}
)

vala_precompile (VALA_C ${PLUGNAME}
    OnlineAccounts.vala
    Views/SourceSelector.vala
    Views/AccountView.vala
    Authentification/Server.vala
    Authentification/DialogService.vala
    Authentification/RequestQueue.vala
    Authentification/RequestInfo.vala
    Authentification/Key.vala
    Authentification/Dialog.vala
    Authentification/WebDialog.vala
    Authentification/GraphicalDialog.vala
PACKAGES
    ${DEPS_PACKAGES}
    config
    glib-addons
    ${PLUGNAME}
OPTIONS
    ${GLOBAL_VALAC_OPTIONS}
    --vapidir ${CMAKE_CURRENT_SOURCE_DIR}
)

set (PLUGSONAME ${PLUGNAME}-plug)

add_library (${PLUGSONAME} MODULE ${POA_VALA_C} ${VALA_C})
target_link_libraries(${PLUGSONAME} ${DEPS_LIBRARIES})
target_link_libraries(${PLUGSONAME} ${PLUGNAME})


add_library (${PLUGNAME} SHARED ${POA_VALA_C})
set_target_properties (${PLUGNAME} PROPERTIES
  VERSION 0.1
  SOVERSION 0
)

# Installation
install (TARGETS ${PLUGSONAME} DESTINATION ${PKGDATADIR})
install (TARGETS ${PLUGNAME} DESTINATION ${CMAKE_INSTALL_FULL_LIBDIR})

# Install lib stuffs
install (FILES ${CMAKE_BINARY_DIR}/src/${PLUGNAME}.pc DESTINATION ${CMAKE_INSTALL_FULL_LIBDIR}/pkgconfig/)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${PLUGNAME}.vapi DESTINATION share/vala/vapi/)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/${PLUGNAME}.deps DESTINATION share/vala/vapi/)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${PLUGNAME}.h DESTINATION include/${PLUGNAME}/)

