find_package (PkgConfig)
# Add all your dependencies to the list below
pkg_check_modules (DEPS REQUIRED ${DEPS_PKG})

add_definitions (${DEPS_CFLAGS})
link_libraries (${DEPS_LIBRARIES})
link_directories (${DEPS_LIBRARY_DIRS})

set(CONFIG_FILE ${CMAKE_CURRENT_BINARY_DIR}/config.vala)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/config.vala.cmake ${CONFIG_FILE})
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/${PLUGNAME}.pc.cmake ${CMAKE_CURRENT_BINARY_DIR}/${PLUGNAME}.pc)

# Add all your vala files and requires packages to the List below to include them in the build
vala_precompile (VALA_C ${PLUGNAME}
    ${CONFIG_FILE}
    OnlineAccounts.vala
    Account.vala
    AccountsManager.vala
    PluginManager.vala
    Threads.vala
    Views/SourceSelector.vala
    Views/AccountView.vala
    Views/AccountPopOver.vala
    MethodPlugin.vala
    ProviderPlugin.vala
    Authentification/Server.vala
    Authentification/DialogService.vala
    Authentification/RequestQueue.vala
    Authentification/RequestInfo.vala
    Authentification/Key.vala
    Authentification/Dialog.vala
    Authentification/WebDialog.vala
    Authentification/GraphicalDialog.vala
CUSTOM_VAPIS
    ../vapi/glib-addons.vapi
PACKAGES
    ${DEPS_PACKAGES}
OPTIONS
    ${GLOBAL_VALAC_OPTIONS}
GENERATE_VAPI
    ${PLUGNAME}
GENERATE_HEADER
    ${PLUGNAME}
)

if (BUILD_SHARED_LIBS)
    # Install lib stuffs
    install (FILES ${CMAKE_BINARY_DIR}/src/${PLUGNAME}.pc DESTINATION ${CMAKE_INSTALL_FULL_LIBDIR}/pkgconfig/)
    install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${PLUGNAME}.vapi DESTINATION share/vala/vapi/)
    install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/${PLUGNAME}.deps DESTINATION share/vala/vapi/)
    install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${PLUGNAME}.h DESTINATION include/${PLUGNAME}/)
endif ()

add_library (${PLUGNAME} MODULE ${VALA_C})
target_link_libraries(${PLUGNAME} ${DEPS_LIBRARIES})

# Installation
install (TARGETS ${PLUGNAME} DESTINATION ${PKGDATADIR})