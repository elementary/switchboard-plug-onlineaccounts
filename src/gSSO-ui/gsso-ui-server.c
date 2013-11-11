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
#if HAVE_CONFIG_H
#include "config.h"
#endif
#include <errno.h>
#include <string.h>
#include <glib/gstdio.h>

#include "gsso-ui-server.h"
#include "gsso-ui-dbus-glue.h"
#include "gsso-ui-dialog-service.h"
#include "gsso-ui-request-queue.h"
#include "gsso-ui-log.h"

#define GSSO_UI_BUS_NAME "com.google.code.AccountsSSO.gSingleSignOn.UI"

struct _GSSOUIServer
{
    GObject parent;

    guint bus_owner_id;
    SSODbusUI *ui;
    GDBusServer *bus_server;
    gchar *socket_file_path;
    GHashTable *dialog_services;
    GSSOUIRequestQueue *request_queue;
    guint32 timeout;
#ifdef ENABLE_TIMEOUT
    gulong request_queue_notify_handler_id;
    guint daemon_timer_id;
#endif
};

G_DEFINE_TYPE(GSSOUIServer, gsso_ui_server, G_TYPE_OBJECT)

static void _on_connection_closed (GSSOUIServer *, gboolean, GError *, GDBusConnection *);

static void
_disconnect_connection_close_handler (gpointer key, gpointer value, gpointer data)
{
    g_signal_handlers_disconnect_by_func (key, _on_connection_closed, data);
}

static void 
_dispose (GObject *obj)
{
    GSSOUIServer *self = GSSO_UI_SERVER(obj);
DBG("{");
    g_return_if_fail (self);

    if (self->bus_server) {
        g_dbus_server_stop (self->bus_server);
        g_clear_object (&self->bus_server);
    }

    if (self->socket_file_path) {
        g_unlink (self->socket_file_path);
        g_free (self->socket_file_path);
        self->socket_file_path = NULL;
    }
#ifdef ENABLE_TIMEOUT
    if (self->daemon_timer_id) {
        g_source_remove (self->daemon_timer_id);
        self->daemon_timer_id = 0;
    }
    if (self->request_queue_notify_handler_id) {
        g_signal_handler_disconnect (self->request_queue,
                    self->request_queue_notify_handler_id);
        self->request_queue_notify_handler_id = 0;
    }
#endif
    if (self->dialog_services) {
        g_hash_table_foreach (self->dialog_services, 
            _disconnect_connection_close_handler, self);
        g_hash_table_unref (self->dialog_services);
        self->dialog_services = NULL;
    }

    g_clear_object (&self->request_queue);

    G_OBJECT_CLASS(gsso_ui_server_parent_class)->dispose (obj);
DBG("}");
}

static void
gsso_ui_server_class_init (GSSOUIServerClass *klass)
{
    G_OBJECT_CLASS (klass)->dispose = _dispose;
}

#ifdef ENABLE_TIMEOUT
static gboolean
_close_server (gpointer data)
{
    GSSOUIServer *self = GSSO_UI_SERVER (data);

    if (!self) return FALSE;
 
    g_source_remove (self->daemon_timer_id);
    self->daemon_timer_id = 0;

    DBG ("closing serve as its timed out");
    g_object_unref (self);

    return FALSE;
}

static void
_on_request_queue_notify (GSSOUIServer *self, GParamSpec *pspec, GSSOUIRequestQueue *queue)
{
    gboolean is_idle = gsso_ui_request_queue_is_idle (queue);
    
    if (self->daemon_timer_id) {
        g_source_remove (self->daemon_timer_id);
        self->daemon_timer_id = 0;
    }

    if (is_idle && self->timeout) {
        DBG ("setting dameon timeout to %d seconds", self->timeout);
        self->daemon_timer_id = g_timeout_add_seconds (
                self->timeout, _close_server, self);
    }
}
#endif

static void
gsso_ui_server_init (GSSOUIServer *self)
{
    self->timeout = 0;
    self->bus_owner_id = 0;
    self->bus_server = NULL;
    self->socket_file_path = NULL;
    self->dialog_services = g_hash_table_new_full (
        g_direct_hash, g_direct_equal, NULL, g_object_unref);
    self->request_queue = gsso_ui_request_queue_new ();
#ifdef ENABLE_TIMEOUT
    self->request_queue_notify_handler_id = g_signal_connect_swapped (
            self->request_queue, "notify::is-idle", 
            G_CALLBACK(_on_request_queue_notify), self);
    _on_request_queue_notify (self, NULL, self->request_queue);
#endif
}

static void
_on_connection_closed (GSSOUIServer     *self,
                       gboolean         remote_peer_vanished,
                       GError          *error,
                       GDBusConnection *connection)
{
    GSSOUIDialogService *service = NULL;
    DBG ("Client Dis-Connected ....");

    g_signal_handlers_disconnect_by_func (connection, _on_connection_closed, self);

    service = g_hash_table_lookup (self->dialog_services, connection);
    if (service) {
        gsso_ui_request_queue_close_all_by_servcie (
                    self->request_queue, service);
    }
    else {
        WARN ("No Dialog service found for conneciton '%p'", connection);
    }

    g_hash_table_remove (self->dialog_services, connection);

    DBG("}");
}

static gboolean
_on_client_connection (GSSOUIServer *self,
                      GDBusConnection *connection,
                      GDBusServer *dbus_server)
{
    GSSOUIDialogService *obj = NULL;

    g_return_val_if_fail (self && GSSO_IS_UI_SERVER(self), FALSE);

    obj = gsso_ui_dialog_service_new (connection, self);

    if (!obj) {
        g_critical ("Failed to create dialog service on connection '%p'", connection);
        return FALSE;
    }

    g_hash_table_insert (self->dialog_services, (gpointer)connection, (gpointer)obj);

    g_signal_connect_swapped (connection, "closed", G_CALLBACK(_on_connection_closed), self);

    return TRUE;
}

static gboolean
on_get_bus_address (SSODbusUI     *ui,
                    GDBusMethodInvocation *invocation,
                    gpointer       userdata)
{
    GSSOUIServer *self = GSSO_UI_SERVER(userdata);

    g_return_val_if_fail (self, FALSE);
    
    if (self->bus_server) {
        sso_dbus_ui_complete_get_bus_address (ui, invocation,
                g_dbus_server_get_client_address (self->bus_server));
    } else {
        // FIXME: define dbus errors
        //   g_dbus_method_invocation_take_error (invocation,
        //       g_error_new ());
    }

    return TRUE;
}


static void
on_name_acquired (GDBusConnection *connection,
        const gchar     *name,
        gpointer         userdata)
{
    g_debug ("D-Bus name acquired");
}

static void
on_name_lost (GDBusConnection *connection,
        const gchar     *name,
        gpointer         userdata)
{
    g_debug ("D-Bus name lost");
}

static void
on_bus_acquired (GDBusConnection *connection,
        const gchar     *name,
        gpointer         userdata)
{
    gchar *address = NULL;
    gchar *guid = NULL;
    GError *error = NULL;
    gchar *base_path = NULL;
    GSSOUIServer *self = GSSO_UI_SERVER(userdata);

    g_return_if_fail (self);

    g_debug ("D-Bus bus acquired");

    base_path = g_strdup_printf("%s/gsignond/", g_get_user_runtime_dir());
    //self->socket_file_path = g_strdup_printf ("%s%s", base_path, tempnam (base_path, "ui-"));
    self->socket_file_path = tempnam (base_path, "ui-");
    DBG ("Socket File path : %s", self->socket_file_path);
    if (g_file_test(self->socket_file_path, G_FILE_TEST_EXISTS)) {
        g_unlink (self->socket_file_path);
    }
    else {
        if (g_mkdir_with_parents (base_path, S_IRUSR | S_IWUSR | S_IXUSR) == -1) {
            g_warning ("Could not create '%s', error: %s", base_path, strerror(errno));
        }
    }
    g_free (base_path);

    address = g_strdup_printf ("unix:path=%s", self->socket_file_path);

    guid = g_dbus_generate_guid ();
    self->bus_server = g_dbus_server_new_sync (address, G_DBUS_SERVER_FLAGS_NONE, guid, NULL, NULL, &error);
    g_free (guid);
    g_free (address);

    if (!self->bus_server) {
        g_warning ("Could not start dbus server at address '%s' : %s", address, error->message);
        g_error_free (error);

        g_free (self->socket_file_path);
        self->socket_file_path = NULL;

        return ;
    }

    g_chmod (self->socket_file_path, S_IRUSR | S_IWUSR);

    g_signal_connect_swapped (self->bus_server,
            "new-connection", G_CALLBACK (_on_client_connection), self);

    /* expose interface */

    self->ui = sso_dbus_ui_skeleton_new ();

    g_signal_connect (self->ui, "handle-get-bus-address",
            G_CALLBACK (on_get_bus_address), self);

    if (!g_dbus_interface_skeleton_export (G_DBUS_INTERFACE_SKELETON (self->ui),
                connection,
                "/",
                &error)) {
        g_warning ("Failed to export interface: %s", error->message);
        g_error_free (error);

        return ;
    }

    g_dbus_server_start (self->bus_server);

    g_debug ("UI Dialog server started at : %s", g_dbus_server_get_client_address (self->bus_server));
}

GSSOUIServer *
gsso_ui_server_new(guint32 timeout)
{
     GSSOUIServer *server = g_object_new (GSSO_TYPE_UI_SERVER, NULL);
     
     g_return_val_if_fail (server, NULL);
     
     server->bus_owner_id = g_bus_own_name (G_BUS_TYPE_SESSION,
             GSSO_UI_BUS_NAME,
             G_BUS_NAME_OWNER_FLAGS_ALLOW_REPLACEMENT | G_BUS_NAME_OWNER_FLAGS_REPLACE,
             on_bus_acquired,
             on_name_acquired,
             on_name_lost,
             server,
             NULL);
     server->timeout = timeout;

     return server;
}

void
gsso_ui_server_push_dialog (GSSOUIServer *self,
                            GSSOUIDialogService *service,
                            GDBusMethodInvocation *invocation,
                            GHashTable *params)
{
    gsso_ui_request_queue_push_dialog (
            self->request_queue, service, invocation, params);
}

gboolean
gsso_ui_server_refresh_dialog (GSSOUIServer *self,
                               GSSOUIDialogService *service,
                               GHashTable *params)
{
    return gsso_ui_request_queue_refresh_dialog (
                self->request_queue, service, params);
}

gboolean
gsso_ui_server_cancel_dialog (GSSOUIServer *self,
                              GSSOUIDialogService *service,
                              const gchar *id)
{
    return gsso_ui_request_queue_cancel_dialog (
                self->request_queue, service, id);
}
