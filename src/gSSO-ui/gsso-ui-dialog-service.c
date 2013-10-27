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
#include "gsso-ui-dialog-service.h"
#include "gsso-ui-dialog-dbus-glue.h"
#include "gsso-ui-server.h"
#include "gsso-ui-utils.h"
#include "gsso-ui-log.h"

#define GSSO_UI_DIALOG_BUS_NAME "com.google.code.AccountsSSO.gSingleSignOn.UI.Dialog"

G_DEFINE_TYPE(GSSOUIDialogService, gsso_ui_dialog_service, G_TYPE_OBJECT)

struct _GSSOUIDialogServicePrivate
{
    GSSOUIServer    *ui_server;
    GDBusConnection *connection;
    SSODbusUIDialog *dbus_dialog;
};

enum {
    PROP_0,
    PROP_DBUS_CONNECTION,
    PROP_UI_SERVER,
    N_PROPERTIES
};
static GParamSpec *properties[N_PROPERTIES];

static void 
_dispose (GObject *obj)
{
    GSSOUIDialogService *self = GSSO_UI_DIALOG_SERVICE(obj);

    g_return_if_fail (self);
    DBG("{");
    if (self->priv->dbus_dialog) {
        g_dbus_interface_skeleton_unexport (
            G_DBUS_INTERFACE_SKELETON(self->priv->dbus_dialog));
        g_clear_object (&self->priv->dbus_dialog);
    }

    if (self->priv->connection) {
        g_clear_object (&self->priv->connection);
    }

    G_OBJECT_CLASS(gsso_ui_dialog_service_parent_class)->dispose (obj);
    DBG("}");
}

static void
_set_property (GObject *object,
               guint property_id,
               const GValue *value, GParamSpec *pspec)
{
    GSSOUIDialogService *self = GSSO_UI_DIALOG_SERVICE(object);

    switch (property_id) {
        case PROP_DBUS_CONNECTION: {
            GError *error = NULL;
            self->priv->connection = g_value_dup_object (value);
            if (!g_dbus_interface_skeleton_export (
                    G_DBUS_INTERFACE_SKELETON (self->priv->dbus_dialog),
                    self->priv->connection, "/Dialog", &error)) {
                g_warning ("Failed to export interface : %s", error->message);
                g_error_free (error);
            }
            break;
        }
        case PROP_UI_SERVER: {
            self->priv->ui_server = g_value_get_object (value);
            break;
        }
        default:
            G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
    }
}

static void
_get_property (GObject *object,
               guint property_id,
               GValue *value,
               GParamSpec *pspec)
{
    GSSOUIDialogService *self = GSSO_UI_DIALOG_SERVICE(object);

    switch (property_id) {
        case PROP_DBUS_CONNECTION:{
            g_value_set_object (value, self->priv->connection);
            break;
        }
        case PROP_UI_SERVER: {
            g_value_set_object (value, self->priv->ui_server);
            break;
        }
        default:
            G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
    }
}

static void
gsso_ui_dialog_service_class_init (GSSOUIDialogServiceClass *klass)
{
    GObjectClass *g_klass = G_OBJECT_CLASS (klass);
    
    g_type_class_add_private (klass, sizeof(GSSOUIDialogServicePrivate));

    g_klass->set_property = _set_property;
    g_klass->get_property = _get_property;
    g_klass->dispose = _dispose;

    properties[PROP_DBUS_CONNECTION] = g_param_spec_object ("connection",
            "dbus connection used",
            "DBus connection",
            G_TYPE_DBUS_CONNECTION,
            G_PARAM_READWRITE |
            G_PARAM_CONSTRUCT_ONLY |
            G_PARAM_STATIC_STRINGS);

    properties[PROP_UI_SERVER] = g_param_spec_object ("ui-server",
            "ui server ",
            "UI Server",
            GSSO_TYPE_UI_SERVER,
            G_PARAM_READWRITE |
            G_PARAM_CONSTRUCT_ONLY |
            G_PARAM_STATIC_STRINGS);
    g_object_class_install_properties (g_klass, N_PROPERTIES, properties);
}


static gboolean
_on_query_dialog (GSSOUIDialogService    *self,
                  GDBusMethodInvocation *invocation,
                  GVariant              *params,
                  gpointer               userdata)
{
    g_debug ("method 'QueryDialog' called");

    GHashTable *hash_map = g_variant_map_to_hash_table (params);
    gsso_ui_server_push_dialog (self->priv->ui_server, self, invocation, hash_map);
    g_hash_table_unref (hash_map);

    return TRUE;
}

static gboolean
_on_refresh_dialog (GSSOUIDialogService    *self,
                   GDBusMethodInvocation *invocation,
                   GVariant              *params,
                   gpointer               user_data)
{
    g_debug ("method 'RefreshDialog' called");

    GHashTable *hash_map = g_variant_map_to_hash_table (params);
    gsso_ui_server_refresh_dialog (self->priv->ui_server, self, hash_map);
    g_hash_table_unref (hash_map);

    sso_dbus_uidialog_complete_refresh_dialog (self->priv->dbus_dialog, invocation);

    return TRUE;
}

static gboolean
_on_cancel_ui_request (GSSOUIDialogService *self,
                      GDBusMethodInvocation *invocation,
                      char                  *request_id,
                      gpointer               userdata)
{
    g_debug ("method 'CancelUiRequest' called");

    gsso_ui_server_cancel_dialog (self->priv->ui_server, self, request_id);

    sso_dbus_uidialog_complete_cancel_ui_request (self->priv->dbus_dialog, invocation);

    return TRUE;
}

static void
gsso_ui_dialog_service_init (GSSOUIDialogService *self)
{
    GSSOUIDialogServicePrivate *priv =
        G_TYPE_INSTANCE_GET_PRIVATE(self, GSSO_TYPE_UI_DIALOG_SERVICE, GSSOUIDialogServicePrivate);

    self->priv = priv;

    priv->dbus_dialog = sso_dbus_uidialog_skeleton_new();

    g_signal_connect_swapped (priv->dbus_dialog, "handle-query-dialog",
            G_CALLBACK (_on_query_dialog), self);
    g_signal_connect_swapped (priv->dbus_dialog, "handle-refresh-dialog",
            G_CALLBACK (_on_refresh_dialog), self);
    g_signal_connect_swapped (priv->dbus_dialog, "handle-cancel-ui-request",
            G_CALLBACK (_on_cancel_ui_request), self);
}

GSSOUIDialogService *
gsso_ui_dialog_service_new (GDBusConnection *connection, GSSOUIServer *server)
{
    return g_object_new (GSSO_TYPE_UI_DIALOG_SERVICE,
                "connection", connection,
                "ui-server", server, NULL);
}

void
gsso_ui_dialog_service_notify_reply (GSSOUIDialogService *self,
                                     GDBusMethodInvocation *invocation,
                                     GHashTable *reply)
{
    sso_dbus_uidialog_complete_query_dialog (self->priv->dbus_dialog, 
            invocation, g_variant_map_from_hash_table (reply));
}

void
gsso_ui_dialog_service_notify_error (GSSOUIDialogService *self,
                                     GDBusMethodInvocation *invocation,
                                     GError *error)
{
    g_dbus_method_invocation_take_error (invocation, error);
}

void
gsso_ui_dialog_service_emit_refresh (GSSOUIDialogService *self, const gchar *request_id)
{
    sso_dbus_uidialog_emit_refresh (self->priv->dbus_dialog, request_id);
}
