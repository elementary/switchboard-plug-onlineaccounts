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
#ifndef _GSSO_UI_REQUEST_QUEUE_H_
#define _GSSO_UI_REQUEST_QUEUE_H_

#include <glib-object.h>
#include <gtk/gtk.h>
#include <gio/gio.h>
#include "gsso-ui-dialog-service.h"

#define GSSO_TYPE_UI_REQUEST_QUEUE (gsso_ui_request_queue_get_type())
#define GSSO_UI_REQUEST_QUEUE(o)   (G_TYPE_CHECK_INSTANCE_CAST ((o), GSSO_TYPE_UI_REQUEST_QUEUE, GSSOUIRequestQueue))
#define GSSO_UI_REQUEST_QUEUE_CLASS(kls) (G_TYPE_CHECK_CLASS_CAST ((kls), GSSO_TYPE_UI_REQUEST_QUEUE, GSSOUIRequestQueueClass))
#define GSSO_IS_UI_REQUEST_QUEUE(o) (G_TYPE_CHECK_INSTANCE_TYPE ((o), GSSO_TYPE_UI_REQUEST_QUEUE))
#define GSSO_IS_UI_REQUEST_QUEUE_CLASS(o) (G_TYPE_CHECK_CLASS_TYPE ((o), GSSO_TYPE_UI_REQUEST_QUEUE))
#define GSSO_UI_REQUEST_QUEUE_GET_CLASS(o) (G_TYPE_INSTANCE_GET_CLASS ((o), GSSO_TYPE_UI_REQUEST_QUEUE, GSSOUIRequestQueueClass))

typedef struct _GSSOUIRequestQueue GSSOUIRequestQueue;
typedef struct _GSSOUIRequestQueueClass GSSOUIRequestQueueClass;

struct _GSSOUIRequestQueueClass
{
    GObjectClass parent_class;
};

GType gsso_ui_request_queue_get_type();

GSSOUIRequestQueue * gsso_ui_request_queue_new ();

gboolean gsso_ui_request_queue_is_idle (GSSOUIRequestQueue *self);

void gsso_ui_request_queue_push_dialog (GSSOUIRequestQueue *self,
                                        GSSOUIDialogService *service,
                                        GDBusMethodInvocation *invocation,
                                        GHashTable *params);

gboolean gsso_ui_request_queue_refresh_dialog (GSSOUIRequestQueue *self,
                                               GSSOUIDialogService *service,
                                               GHashTable *params);

gboolean gsso_ui_request_queue_cancel_dialog (GSSOUIRequestQueue *self,
                                              GSSOUIDialogService *service,
                                              const gchar *id);

void gsso_ui_request_queue_close_all_by_servcie (GSSOUIRequestQueue *self,
                                            GSSOUIDialogService *service);

#endif /* _GSSO_UI_REQUEST_QUEUE_H_ */
