/*
 * This file is part of signonui-gtk
 *
 * Copyright (C) 2013 Intel Corporation.
 *
 * Author: Amarnath Valluri <amarnath.valluri@intel.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA
 */
#ifndef _GSSO_UI_SERVER_H_
#define _GSSO_UI_SERVER_H_

#include <glib.h>
#include <glib-object.h>
#include <gio/gio.h>
#include "gsso-ui-dialog-service.h"

G_BEGIN_DECLS

#define GSSO_TYPE_UI_SERVER (gsso_ui_server_get_type ())
#define GSSO_UI_SERVER(o) (G_TYPE_CHECK_INSTANCE_CAST ((o),GSSO_TYPE_UI_SERVER, GSSOUIServer))
#define GSSO_IS_UI_SERVER(o) (G_TYPE_CHECK_INSTANCE_TYPE((o), GSSO_TYPE_UI_SERVER))

typedef struct _GSSOUIServer GSSOUIServer;
typedef struct _GSSOUIServerClass GSSOUIServerClass;

struct _GSSOUIServerClass
{
    GObjectClass parent_class;
};

GType gsso_ui_server_get_type();

GSSOUIServer* gsso_ui_server_new ();

gboolean gsso_ui_server_start ();

void gsso_ui_server_stop();

void gsso_ui_server_push_dialog (GSSOUIServer *self,
                                 GSSOUIDialogService *serive,
                                 GDBusMethodInvocation *invocation,
                                 GHashTable *params);

gboolean gsso_ui_server_refresh_dialog (GSSOUIServer *self,
                                    GSSOUIDialogService *service,
                                    GHashTable *params);

gboolean gsso_ui_server_cancel_dialog (GSSOUIServer *self,
                                   GSSOUIDialogService *service,
                                   const gchar *id);

G_END_DECLS

#endif /* _GSSO_UI_SERVER_H_ */
