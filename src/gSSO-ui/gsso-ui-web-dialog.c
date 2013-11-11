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
#ifdef HAVE_CONFIG_H
#   include "config.h"
#endif
#include "gsso-ui-web-dialog.h"
#include "gsso-ui-types.h"
#include "gsso-ui-log.h"
#include "gsso-ui-utils.h"
#include <gtk/gtk.h>

#ifdef HAVE_WEBKIT2GTK
#include <webkit2/webkit2.h>
#else
#include <webkit/webkit.h>
#endif

struct _GSSOUIWebDialog
{
    GSSOUIDialog parent;
    GtkWidget *webview;
    const gchar *oauth_open_url;
    const gchar *oauth_final_url;
    gchar *oauth_response;
    gulong webkit_redirect_handler_id;
};

G_DEFINE_TYPE (GSSOUIWebDialog, gsso_ui_web_dialog, GSSO_TYPE_UI_DIALOG)

static void
_dispose (GObject *object)
{
    GSSOUIWebDialog *self = GSSO_UI_WEB_DIALOG (object);
DBG("{");
    if (self->webkit_redirect_handler_id) {
        g_signal_handler_disconnect (self->webview, self->webkit_redirect_handler_id);
        self->webkit_redirect_handler_id = 0;
    }

    G_OBJECT_CLASS (gsso_ui_web_dialog_parent_class)->dispose (object);
DBG("}");
}

static void
_finalize (GObject *object)
{
    GSSOUIWebDialog *self = GSSO_UI_WEB_DIALOG (object);

    if (self->oauth_response) {
        g_free (self->oauth_response);
        self->oauth_response = NULL;
    }

    G_OBJECT_CLASS(gsso_ui_web_dialog_parent_class)->finalize (object);
}

GHashTable *
_get_reply (GSSOUIDialog *dialog)
{
    GHashTable *reply = NULL;
    g_return_val_if_fail (dialog && GSSO_IS_UI_DIALOG (dialog), NULL);

    reply = g_hash_table_new_full (g_str_hash, g_str_equal, NULL, (GDestroyNotify)g_variant_unref);

    g_hash_table_insert (reply, GSSO_UI_KEY_QUERY_ERROR_CODE,
            g_variant_new_uint32 (dialog->error_code));
    g_hash_table_insert (reply, GSSO_UI_KEY_URL_RESPONSE, 
                g_variant_new_string (GSSO_UI_WEB_DIALOG(dialog)->oauth_response));

    return reply;
}

#ifdef ENABLE_TESTS
static gboolean
_handle_test_reply (GSSOUIDialog *dialog, const gchar *test_reply)
{
    char **iter;
    char **pairs = NULL;
    GSSOUIWebDialog *self = GSSO_UI_WEB_DIALOG(dialog);

    if (!self || !test_reply) return FALSE;

    pairs = g_strsplit (test_reply, ",", 0);
    for (iter = pairs; *iter; iter++) {
        char **pair = g_strsplit (*iter, ":", 2);
        if (g_strv_length (pair) == 2) {
            if (g_strcmp0 (pair[0], GSSO_UI_KEY_URL_RESPONSE) == 0) {
                self->oauth_response = g_strdup (pair[1]);
            }
        }
        g_strfreev (pair);
    }
    g_strfreev (pairs);

    return TRUE;
}
#endif

static void
gsso_ui_web_dialog_class_init (GSSOUIWebDialogClass *klass)
{
    GObjectClass *g_klass = G_OBJECT_CLASS (klass);

    g_klass->dispose = _dispose;
    g_klass->finalize = _finalize;

    GSSO_UI_DIALOG_CLASS(klass)->get_reply = _get_reply;
#ifdef ENABLE_TESTS
    GSSO_UI_DIALOG_CLASS(klass)->handle_test_reply = _handle_test_reply;
#endif
}

static void
gsso_ui_web_dialog_init (GSSOUIWebDialog *self)
{
    self->oauth_open_url = NULL;
    self->oauth_final_url = NULL;
    self->oauth_response = NULL;
    self->webkit_redirect_handler_id = 0;
}

static gboolean
_close_window(gpointer self)
{
    gsso_ui_dialog_notify_close (GSSO_UI_DIALOG(self));
    
    return FALSE;
}

static void
#if HAVE_WEBKIT2GTK
_on_webview_load (GSSOUIWebDialog  *self,
                  WebKitLoadEvent load_event,
                  WebKitWebView  *web_view)
{
    const gchar *redirect_uri = NULL;
    const gchar *params = NULL;

    if (load_event != WEBKIT_LOAD_REDIRECTED)
        return;
    redirect_uri = webkit_web_view_get_uri (web_view);
#else
_on_resource_request_starting (GSSOUIWebDialog       *self,
                               WebKitWebFrame        *web_frame,
                               WebKitWebResource     *web_resource,
                               WebKitNetworkRequest  *request,
                               WebKitNetworkResponse *response,
                               WebKitWebView         *webview)
{
    const gchar *redirect_uri = NULL;
    gchar *params = NULL;

DBG("{");
    DBG ("Webkit Resource : %s", webkit_web_resource_get_uri (web_resource));
    redirect_uri = webkit_web_resource_get_uri (web_resource);
    //if (!response) return;
    //redirect_uri = webkit_network_response_get_uri (response);
    DBG ("Webkit Response: %s", redirect_uri);
#endif

    if (!redirect_uri || !g_str_has_prefix (redirect_uri,
                                self->oauth_final_url))
        return;

    /* We got the redirect URI what we are interestead in,
       so disconnect handler 
       */
    g_signal_handler_disconnect (self->webview, self->webkit_redirect_handler_id);
    self->webkit_redirect_handler_id = 0;

    self->oauth_response = g_strdup (redirect_uri);

    DBG ("Found OAUTH Response : %s\n", self->oauth_response);

    GSSO_UI_DIALOG(self)->error_code = GSSO_UI_QUERY_ERROR_NONE;

    g_idle_add (_close_window, self);
DBG("}");
}

static gboolean
_is_valid_url (const gchar *uri)
{
    char *scheme = NULL;
    gboolean ret;

    scheme = g_uri_parse_scheme (uri);
    if (!scheme) return FALSE;
    
    ret = g_str_has_prefix(scheme, "http");
    g_free (scheme);

    return ret;
}

static gboolean
_validate_params (GSSOUIWebDialog *self, GHashTable *params)
{

    self->oauth_open_url = g_hash_map_get_string (params, GSSO_UI_KEY_OPEN_URL);
    self->oauth_final_url = g_hash_map_get_string (params, GSSO_UI_KEY_FINAL_URL);

    if (!self->oauth_open_url || !self->oauth_final_url) {
        WARN ("Missing open_url or final_url");
        return FALSE;
    }

    if (!_is_valid_url (self->oauth_open_url) ||
        !_is_valid_url (self->oauth_final_url)) {
        WARN ("Invalid open_url or final_url");
        return FALSE;
    }

    return TRUE;
}


gboolean 
gsso_ui_web_dialog_set_parameters (GSSOUIWebDialog *self, GHashTable *params)
{
    GSSOUIDialog *dialog = GSSO_UI_DIALOG (self);

    g_return_val_if_fail (self && GSSO_IS_UI_WEB_DIALOG (self), FALSE);

    if (! _validate_params (self, params)) {
        GSSO_UI_DIALOG(self)->error_code = GSSO_UI_QUERY_ERROR_BAD_PARAMETERS;
        g_warning ("Bad parameters");
        return FALSE;
    }

    DBG("Preparing Dialog for OAUTH request...");
    self->webview = GTK_WIDGET(gtk_builder_get_object (dialog->builder, "webview"));

#if HAVE_WEBKIT2GTK
    self->webkit_redirect_handler_id = g_signal_connect_swapped (self->webview, "load-changed", 
            G_CALLBACK(_on_webview_load), self);
#else
    self->webkit_redirect_handler_id = g_signal_connect_swapped (self->webview, "resource-request-starting",
            G_CALLBACK(_on_resource_request_starting), self);
#endif

    webkit_web_view_load_uri (WEBKIT_WEB_VIEW(self->webview), self->oauth_open_url);

    return TRUE;
}

GSSOUIDialog *
gsso_ui_web_dialog_new (GHashTable *params)
{
    gchar *ui_file =  g_build_filename (get_ui_files_dir(), "gsso-ui-web-dialog.ui", NULL);
    GSSOUIDialog *dialog = g_object_new (
            GSSO_TYPE_UI_WEB_DIALOG,
            "ui-file", ui_file,
            "parameters", params, NULL);

    g_free (ui_file);

    SoupSession *session = webkit_get_default_session ();
    g_object_set (G_OBJECT (session), SOUP_SESSION_ACCEPT_LANGUAGE_AUTO, TRUE, NULL);

    gsso_ui_web_dialog_set_parameters (GSSO_UI_WEB_DIALOG(dialog), params);

    return dialog;
}

