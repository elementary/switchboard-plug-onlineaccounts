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
#include "gsso-ui-request-queue.h"
#include "gsso-ui-dialog-service.h"
#include "gsso-ui-gtk-dialog.h"
#include "gsso-ui-web-dialog.h"
#include "gsso-ui-types.h"
#include "gsso-ui-log.h"

typedef struct {
    GSSOUIDialogService *service;
    GDBusMethodInvocation *invocation;
    GHashTable *params;
} RequestInfo;

typedef struct _GSSOUIRequestQueue {
    GObject parent;
    GQueue *queue;
    RequestInfo *active_request;
    GSSOUIDialog *active_dialog;
    gboolean is_idle;
} GSSOUIRequestQueue;

enum {
    PROP_0,
    PROP_IS_IDLE,
    PROP_MAX
};
static GParamSpec *properties[PROP_MAX];

G_DEFINE_TYPE (GSSOUIRequestQueue, gsso_ui_request_queue, G_TYPE_OBJECT)

static void _process_next (GSSOUIRequestQueue *self);
static void _set_is_idle (GSSOUIRequestQueue *self, gboolean idle);

static RequestInfo *
request_info_new (GSSOUIDialogService *service, GDBusMethodInvocation *invocation, GHashTable *params)
{
    RequestInfo *info = NULL;

    info = g_slice_new0(RequestInfo);
    info->service = g_object_ref (service);
    info->invocation = g_object_ref (invocation);
    info->params = g_hash_table_ref (params);

    return info;
}

static void
request_info_free (RequestInfo *info)
{
    if (info) {
        g_object_unref (info->service);
        g_object_unref (info->invocation);
        g_hash_table_unref (info->params);

        g_slice_free (RequestInfo, info);
    }
}

static void
_dispose (GObject *obj)
{
    GSSOUIRequestQueue *self = GSSO_UI_REQUEST_QUEUE(obj);

    if (self->active_dialog)
        g_clear_object (&self->active_dialog);

    G_OBJECT_CLASS (gsso_ui_request_queue_parent_class)->dispose(obj);
}

static void
_finalize (GObject *obj)
{
    GSSOUIRequestQueue *self = GSSO_UI_REQUEST_QUEUE(obj);

    if (self->queue) {
        g_queue_free_full (self->queue, (GDestroyNotify)request_info_free);
        self->queue = NULL;
    }

    G_OBJECT_CLASS (gsso_ui_request_queue_parent_class)->finalize(obj);
}

static void
_get_property (GObject      *object,
               guint         property_id,
               GValue *value,
               GParamSpec   *pspec)
{
    GSSOUIRequestQueue *self = GSSO_UI_REQUEST_QUEUE (object);

    switch (property_id) {
        case PROP_IS_IDLE:
            g_value_set_boolean (value, self->is_idle);
            break;
        default:
            G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
    }
}

static void
gsso_ui_request_queue_class_init (GSSOUIRequestQueueClass *klass)
{
    GObjectClass *g_klass = G_OBJECT_CLASS (klass);

    g_klass->get_property = _get_property;
    g_klass->dispose = _dispose;
    g_klass->finalize = _finalize;

    properties[PROP_IS_IDLE] = g_param_spec_boolean (
                "is-idle", 
                "Is idle",
                "Is Rquest in idle state",
                TRUE, G_PARAM_READABLE);
    g_object_class_install_properties (g_klass, PROP_MAX, properties);
}

static void 
gsso_ui_request_queue_init (GSSOUIRequestQueue *self)
{
    self->queue = g_queue_new ();
    self->active_dialog = NULL;
    self->is_idle = TRUE;
}

static void
_set_is_idle (GSSOUIRequestQueue *self, gboolean idle)
{
    if (self->is_idle != idle) {
        DBG ("emitting notify::is_idle with %d", idle);
        self->is_idle = idle;
        g_object_notify_by_pspec (G_OBJECT(self), properties[PROP_IS_IDLE]);
    }
}

static gboolean
_process_next_request_idle_cb (gpointer data)
{
    _process_next (GSSO_UI_REQUEST_QUEUE (data));

    return FALSE;
}

static void
_on_dialog_refresh_captcha (GSSOUIDialog *dialog, RequestInfo *info)
{
    gsso_ui_dialog_service_emit_refresh (info->service, 
          gsso_ui_dialog_get_request_id (dialog));
}

static void
_on_dialog_close (GSSOUIDialog *dialog, GSSOUIRequestQueue *self)
{
DBG("{");
    RequestInfo *info = (RequestInfo*) g_queue_pop_head (self->queue);
    DBG ("QUEUE SIZE : %d", g_queue_get_length (self->queue));
    GHashTable *reply = gsso_ui_dialog_get_reply (dialog);

    gsso_ui_dialog_service_notify_reply (info->service, info->invocation, reply);

    g_object_unref (dialog);
    request_info_free (info);

    self->active_dialog = NULL;

    g_idle_add (_process_next_request_idle_cb, self);
DBG("}");
}

static void
_process_next (GSSOUIRequestQueue *self)
{
    GSSOUIDialog* dialog  = NULL;
    gboolean is_web_dialog = FALSE;

    g_return_if_fail (self->active_dialog == NULL);

    RequestInfo *info = (RequestInfo*)g_queue_peek_head (self->queue);

    if (!info) {
        _set_is_idle (self, TRUE);
        return ;
    }

    is_web_dialog = g_hash_table_contains (info->params, GSSO_UI_KEY_OPEN_URL);

    dialog = is_web_dialog ? gsso_ui_web_dialog_new (info->params) 
                           : gsso_ui_gtk_dialog_new (info->params);

    if (!gsso_ui_dialog_show (dialog)) {

        _on_dialog_close (dialog, self);

        return;
    }

    g_object_set_data (G_OBJECT (dialog), "service", (gpointer)info->service);

    g_signal_connect(dialog, "close", G_CALLBACK (_on_dialog_close), self);

    if (!is_web_dialog) 
        g_signal_connect(dialog, "refresh-captcha",
            G_CALLBACK (_on_dialog_refresh_captcha), self);

    self->active_dialog = dialog;
    _set_is_idle (self, FALSE);
}

void
gsso_ui_request_queue_push_dialog (
    GSSOUIRequestQueue *self,
    GSSOUIDialogService *service,
    GDBusMethodInvocation *invocation,
    GHashTable *params)
{
    g_queue_push_tail (self->queue, request_info_new (service, invocation, params));

    if (self->is_idle) {
        _process_next (self);
    }
}

static gint
_compare_request_by_id (gconstpointer a, gconstpointer b)
{
    GVariant *var_req_id = NULL;
    RequestInfo *info = (RequestInfo *)a;
    const gchar *id = (const gchar *)b;

    if (!id || !info || !(var_req_id = g_hash_table_lookup(info->params, GSSO_UI_KEY_REQUEST_ID)))
        return FALSE;

    return g_strcmp0(id, g_variant_get_string (var_req_id, NULL));
}

gboolean
gsso_ui_request_queue_cancel_dialog (GSSOUIRequestQueue *self, GSSOUIDialogService *service, const gchar *id)
{
    if (self->active_dialog &&
        g_strcmp0 (id, gsso_ui_dialog_get_request_id (self->active_dialog)) == 0) {
        gsso_ui_dialog_close(self->active_dialog);

        return TRUE;
    }
    else {

        /* check in the wait queue */
        GList *element = g_queue_find_custom (self->queue, id, _compare_request_by_id);

        if (element) {
            RequestInfo *info = (RequestInfo *)element->data;

            request_info_free (info);

            g_queue_delete_link (self->queue, element);
        }

        return TRUE;
    }

    return FALSE;
}

gboolean
gsso_ui_request_queue_refresh_dialog (
    GSSOUIRequestQueue *self,
    GSSOUIDialogService *service,
    GHashTable *params)
{
    GVariant *value= NULL;
    const gchar *captcha_uri = NULL;

    if (!self->active_dialog) {
        /* no active dialog */
        return FALSE;
    }

    value = g_hash_table_lookup (params, GSSO_UI_KEY_REQUEST_ID);
    if (!value || !g_variant_is_of_type (value, G_VARIANT_TYPE_STRING)
        || (g_strcmp0 (g_variant_get_string (value, NULL),
                       gsso_ui_dialog_get_request_id (self->active_dialog)) != 0)) {
        
        /* No valid request id  */
        return FALSE;
    }

    value = g_hash_table_lookup (params, GSSO_UI_KEY_CAPTCHA_URL);
    if (! g_variant_is_of_type (value, G_VARIANT_TYPE_STRING)
        || !(captcha_uri = g_variant_get_string (value, NULL))) {
        /* Invalid captcah url */
        return FALSE;
    }

    gsso_ui_dialog_refresh_captcha (self->active_dialog, captcha_uri); 

    return TRUE;
}

static gint
_compare_request_by_service (gconstpointer a, gconstpointer b)
{
    RequestInfo *info = (RequestInfo *)a;

    return info && info->service == b ? 0 : 1;
}

void
gsso_ui_request_queue_close_all_by_servcie (GSSOUIRequestQueue *self,
                                            GSSOUIDialogService *service)
{
    GList *element = NULL;
 DBG("{");
    g_return_if_fail (self && GSSO_IS_UI_REQUEST_QUEUE (self));
    g_return_if_fail (service);

    if (self->active_dialog && 
        g_object_get_data (G_OBJECT(self->active_dialog), "service") == service) {
        g_object_unref (self->active_dialog);
        self->active_dialog = NULL;

        g_idle_add (_process_next_request_idle_cb, self);
    }

    while (self->queue && (element = g_queue_find_custom (
            self->queue, service, _compare_request_by_service))) {
        DBG("Found an element ...");
        g_queue_delete_link (self->queue, element);
    }
 DBG("}");
}

gboolean
gsso_ui_request_queue_is_idle (GSSOUIRequestQueue *self)
{
    g_return_val_if_fail (self && GSSO_IS_UI_REQUEST_QUEUE(self), FALSE);

    return self->is_idle;
}

GSSOUIRequestQueue *
gsso_ui_request_queue_new ()
{
    return g_object_new (GSSO_TYPE_UI_REQUEST_QUEUE, NULL);
}

