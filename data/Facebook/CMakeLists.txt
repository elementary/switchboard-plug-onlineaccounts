
install(FILES facebook.svg DESTINATION ${CMAKE_INSTALL_PREFIX}/share/icons/hicolor/scalable/apps)
install(FILES www.facebook.com.conf DESTINATION ${CMAKE_INSTALL_PREFIX}/etc/signon-ui/webkit-options.d/)
install(FILES facebook.provider DESTINATION ${CMAKE_INSTALL_PREFIX}/share/accounts/providers/)
install(FILES facebook-sharing.service DESTINATION ${CMAKE_INSTALL_PREFIX}/share/accounts/services/)
install(FILES facebook-microblog.service DESTINATION ${CMAKE_INSTALL_PREFIX}/share/accounts/services/)
install(FILES facebook-im.service DESTINATION ${CMAKE_INSTALL_PREFIX}/share/accounts/services/)
