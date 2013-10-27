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
#ifndef _GSSO_UI_WEB_DIALOG_H_
#define _GSSO_UI_WEB_DIALOG_H_

#include "gsso-ui-dialog.h"

#define GSSO_TYPE_UI_WEB_DIALOG (gsso_ui_web_dialog_get_type())
#define GSSO_UI_WEB_DIALOG(o)   (G_TYPE_CHECK_INSTANCE_CAST ((o), GSSO_TYPE_UI_WEB_DIALOG, GSSOUIWebDialog))
#define GSSO_UI_WEB_DIALOG_CLASS(kls) (G_TYPE_CHECK_CLASS_CAST ((kls), GSSO_TYPE_UI_WEB_DIALOG, GSSOUIWebDialogClass))
#define GSSO_IS_UI_WEB_DIALOG(o) (G_TYPE_CHECK_INSTANCE_TYPE ((o), GSSO_TYPE_UI_WEB_DIALOG))
#define GSSO_IS_UI_WEB_DIALOG_CLASS(o) (G_TYPE_CHECK_CLASS_TYPE ((o), GSSO_TYPE_UI_WEB_DIALOG))
#define GSSO_UI_WEB_DIALOG_GET_CLASS(o) (G_TYPE_INSTANCE_GET_CLASS ((o), GSSO_TYPE_UI_WEB_DIALOG, GSSOUIWebDialogClass))

typedef struct _GSSOUIWebDialog GSSOUIWebDialog;
typedef struct _GSSOUIWebDialogClass GSSOUIWebDialogClass;

struct _GSSOUIWebDialogClass
{
    GSSOUIDialogClass parent_class;
};

GType gsso_ui_web_dialog_get_type();

GSSOUIDialog * gsso_ui_web_dialog_new (GHashTable *params);

#endif /* _GSSO_UI_WEB_DIALOG_H_ */
