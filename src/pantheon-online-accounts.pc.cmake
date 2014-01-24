prefix=@PREFIX@
exec_prefix=@DOLLAR@{prefix}
libdir=@DOLLAR@{prefix}/lib
includedir=@DOLLAR@{prefix}/include/
 
Name: Online Accounts (for the Pantheon Desktop)
Description: Online Accounts headers  
Version: 0.1  
Libs: -lonline-accounts-pantheon
Cflags: -I@DOLLAR@{includedir}/online-accounts-pantheon
Requires: glib-2.0 gio-2.0 gee-0.8 libpeas-1.0 gtk+-3.0 granite libaccounts-glib libgsignon-glib

