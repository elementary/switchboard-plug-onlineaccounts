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
#ifndef _GSSO_UI_DIALOG_H_
#define _GSSO_UI_DIALOG_H_
#ifdef HAVE_CONFIG_H
#include "config.h"
#endif
#include <glib-object.h>
#include <gtk/gtk.h>
#include "gsso-ui-types.h"

#define GSSO_TYPE_UI_DIALOG (gsso_ui_dialog_get_type())
#define GSSO_UI_DIALOG(o)   (G_TYPE_CHECK_INSTANCE_CAST ((o), GSSO_TYPE_UI_DIALOG, GSSOUIDialog))
#define GSSO_UI_DIALOG_CLASS(kls) (G_TYPE_CHECK_CLASS_CAST ((kls), GSSO_TYPE_UI_DIALOG, GSSOUIDialogClass))
#define GSSO_IS_UI_DIALOG(o) (G_TYPE_CHECK_INSTANCE_TYPE ((o), GSSO_TYPE_UI_DIALOG))
#define GSSO_IS_UI_DIALOG_CLASS(o) (G_TYPE_CHECK_CLASS_TYPE ((o), GSSO_TYPE_UI_DIALOG))
#define GSSO_UI_DIALOG_GET_CLASS(o) (G_TYPE_INSTANCE_GET_CLASS ((o), GSSO_TYPE_UI_DIALOG, GSSOUIDialogClass))

typedef struct _GSSOUIDialog GSSOUIDialog;
typedef struct _GSSOUIDialogClass GSSOUIDialogClass;

struct _GSSOUIDialog
{
    GObject parent;

    /* priv */
    GtkBuilder *builder;
    GtkWidget *main_window;
    gulong destroy_handler_id;
    GHashTable *params;
    gchar *ui_file;
    const gchar *id;

    GSSOUIQueryError error_code;
};

struct _GSSOUIDialogClass
{
    GObjectClass parent_class;

    GHashTable * (*get_reply) (GSSOUIDialog *dialog);
    gboolean (*refresh_captcha)(GSSOUIDialog *dialog, const gchar *uri);
#ifdef ENABLE_TESTS
    gboolean (*handle_test_reply) (GSSOUIDialog *dialog, const gchar *test_reply);
#endif
};

GType gsso_ui_dialog_get_type();

gboolean      gsso_ui_dialog_show (GSSOUIDialog *dialog);
GHashTable *  gsso_ui_dialog_get_reply (GSSOUIDialog *dialog);
gboolean      gsso_ui_dialog_set_parameters (GSSOUIDialog *dialog, GHashTable *params);
gboolean      gsso_ui_dialog_load_from_file (GSSOUIDialog *dialog, const gchar *file);
const gchar * gsso_ui_dialog_get_request_id (GSSOUIDialog *dialog);
void          gsso_ui_dialog_notify_close (GSSOUIDialog *dialog);
gboolean      gsso_ui_dialog_refresh_captcha (GSSOUIDialog *dialog, const gchar *uri);
gboolean      gsso_ui_dialog_close (GSSOUIDialog *dialog);

#endif /* _GSSO_UI_DIALOG_H_ */
