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
#ifndef _GSSO_UI_DIALOG_SERVICE_H_
#define _GSSO_UI_DIALOG_SERVICE_H_

#include <glib.h>
#include <glib-object.h>
#include <gio/gio.h>

G_BEGIN_DECLS

#define GSSO_TYPE_UI_DIALOG_SERVICE (gsso_ui_dialog_service_get_type ())
#define GSSO_UI_DIALOG_SERVICE(o) (G_TYPE_CHECK_INSTANCE_CAST ((o),GSSO_TYPE_UI_DIALOG_SERVICE, GSSOUIDialogService))
#define GSSO_IS_UI_DIALOG_SERVICE(o) (G_TYPE_CHECK_INSTANCE_TYPE((o), GSSO_TYPE_UI_DIALOG_SERVICE))

typedef struct _GSSOUIDialogService GSSOUIDialogService;
typedef struct _GSSOUIDialogServiceClass GSSOUIDialogServiceClass;
typedef struct _GSSOUIDialogServicePrivate GSSOUIDialogServicePrivate;

struct _GSSOUIDialogService
{
    GObject parent;

    GSSOUIDialogServicePrivate *priv;
};

struct _GSSOUIDialogServiceClass
{
    GObjectClass parent_class;
};

GType gsso_ui_dialog_service_get_type();

GSSOUIDialogService* gsso_ui_dialog_service_new ();
void gsso_ui_dialog_service_notify_reply (GSSOUIDialogService *self,
                                     GDBusMethodInvocation *invocation,
                                     GHashTable *reply);
void gsso_ui_dialog_service_emit_refresh (GSSOUIDialogService *self,
                                     const gchar *request_id);

G_END_DECLS

#endif /* _GSSO_UI_DIALOG_SERVICE_H_ */
