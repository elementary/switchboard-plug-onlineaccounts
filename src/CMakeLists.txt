
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/config.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config.h)

vala_precompile (VALA_C ${PLUGNAME}
    AccountsManager.vala
    Account.vala
    OnlineAccounts.vala
    Views/SourceSelector.vala
    Views/AccountView.vala
    Views/ACListBox.vala
    Authentification/Server.vala
    Authentification/DialogService.vala
    Authentification/RequestQueue.vala
    Authentification/RequestInfo.vala
    Authentification/Key.vala
    Authentification/Dialog.vala
    Authentification/WebDialog.vala
    Authentification/PasswordDialog.vala
    Authentification/MailDialog.vala
PACKAGES
    ${DEPS_PACKAGES}
    config
OPTIONS
    ${GLOBAL_VALAC_OPTIONS}
    --vapidir=${CMAKE_CURRENT_SOURCE_DIR}
)

set (PLUGSONAME ${PLUGNAME}-plug)

add_library (${PLUGSONAME} MODULE ${VALA_C})
target_link_libraries(${PLUGSONAME} ${DEPS_LIBRARIES})

# Installation
install (TARGETS ${PLUGSONAME} DESTINATION ${PKGDATADIR})

