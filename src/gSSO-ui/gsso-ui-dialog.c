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
#ifdef HAVE_CONFIG
#   include "config.h"
#endif
#include "gsso-ui-dialog.h"
#include "gsso-ui-log.h"
#include "gsso-ui-utils.h"
#include <glib/gi18n-lib.h>

G_DEFINE_TYPE (GSSOUIDialog, gsso_ui_dialog, G_TYPE_OBJECT)

enum {
    PROP_0,
    PROP_PARAMETERS,
    PROP_UI_FILE,
    N_PROPERTIES
};

static GParamSpec *properties[N_PROPERTIES];

enum {
    CLOSE_SIGNAL,
    LAST_SIGNAL
};
static guint signals[LAST_SIGNAL] = { 0 };

static void
_dispose (GObject *object)
{
    GSSOUIDialog *self = GSSO_UI_DIALOG(object);
DBG("{");
    if (self->destroy_handler_id) {
        g_signal_handler_disconnect (self->main_window, self->destroy_handler_id);
        self->destroy_handler_id = 0ul;
    }

    if (self->main_window) {
        gtk_widget_destroy (self->main_window);
        self->main_window = NULL;
    }

    if (self->builder) {
        g_clear_object (&self->builder);
    }
 
    if (self->params) {
        g_hash_table_unref (self->params);
        self->params = NULL;
    }

DBG("}");
    G_OBJECT_CLASS (gsso_ui_dialog_parent_class)->dispose (object);
}

static void
_finalize (GObject *object)
{
    GSSOUIDialog *self = GSSO_UI_DIALOG(object);

    if (self->ui_file) {
        g_free (self->ui_file);
        self->ui_file = NULL;
    }

    G_OBJECT_CLASS (gsso_ui_dialog_parent_class)->finalize (object);
}

static void
_set_property (GObject      *object,
               guint         property_id,
               const GValue *value,
               GParamSpec   *pspec)
{
    GSSOUIDialog *self = GSSO_UI_DIALOG (object);

    switch (property_id) {
        case PROP_PARAMETERS:
            gsso_ui_dialog_set_parameters (self, (GHashTable*)g_value_get_boxed (value));
            break;
        case PROP_UI_FILE:
            gsso_ui_dialog_load_from_file (self, g_value_get_string (value));
            break;
        default:
            G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
    }
}

static void
gsso_ui_dialog_class_init (GSSOUIDialogClass *klass)
{
    GObjectClass *g_klass = G_OBJECT_CLASS (klass);

    g_klass->set_property = _set_property;
    g_klass->dispose = _dispose;
    g_klass->finalize = _finalize;

    properties[PROP_PARAMETERS] = g_param_spec_boxed ("parameters", "Parameters",
                "The hashtable a{sv} that contains the parameters for this dialog",
                G_TYPE_HASH_TABLE, G_PARAM_WRITABLE);
    properties[PROP_UI_FILE] = g_param_spec_string ("ui-file", "Builder UI file",
                "The Gtk builder ui file for this dialog",
                NULL, G_PARAM_CONSTRUCT_ONLY| G_PARAM_WRITABLE);
    g_object_class_install_properties (g_klass, N_PROPERTIES, properties);

    signals[CLOSE_SIGNAL] =
        g_signal_new ("close",
                G_TYPE_FROM_CLASS (klass),
                G_SIGNAL_RUN_FIRST,
                0, NULL, NULL,
                g_cclosure_marshal_VOID__VOID,
                G_TYPE_NONE, 0);
}

static void
gsso_ui_dialog_init (GSSOUIDialog *self)
{
    self->params = NULL;
    self->main_window = NULL;
    self->error_code = GSSO_UI_QUERY_ERROR_NONE;
    self->destroy_handler_id = 0;
    self->builder = gtk_builder_new ();
    gtk_builder_set_translation_domain  (self->builder, "pantheon-online-accounts");
}

static gboolean
_validate_params (GSSOUIDialog *dialog, GHashTable *params)
{
    GVariant *value = NULL;

    /* validate request id 
       FIXME: it should be the other way, UI should give back request id,
              for all requests it received.
    */
    if (!(value = g_hash_table_lookup (params, GSSO_UI_KEY_REQUEST_ID))
        || !g_variant_is_of_type (value, G_VARIANT_TYPE_STRING)) {
        DBG ("Wrong request id : %s", value ? g_variant_get_type_string (value) : ""); 
        return FALSE;
    }

    dialog->id = g_variant_get_string (value, NULL);

    return TRUE;
}

gboolean 
gsso_ui_dialog_set_parameters (GSSOUIDialog *dialog, GHashTable *params)
{
    GVariant *value = NULL;
    const gchar *title = NULL;
    const gchar *caption = NULL;
    gchar *dialog_title = NULL;

    g_return_val_if_fail (dialog && GSSO_IS_UI_DIALOG (dialog), FALSE);
    g_return_val_if_fail (params, FALSE);

    if (dialog->params) 
        g_hash_table_unref (dialog->params);

    dialog->params = g_hash_table_ref (params);

    if (! _validate_params (dialog, params)) {
        dialog->error_code = GSSO_UI_QUERY_ERROR_BAD_PARAMETERS;
        g_warning ("Bad parameters");
    }

    caption = g_hash_map_get_string (params, GSSO_UI_KEY_CAPTION);
    title = g_hash_map_get_string (params, GSSO_UI_KEY_TITLE);
    if (!title) title = _("Enter your credentials");

    dialog_title = caption ? g_strdup_printf("%s-%s", caption, title)
                           : g_strdup_printf("%s", title);
    g_object_set (G_OBJECT (dialog->main_window), "title", dialog_title, NULL);
    g_free (dialog_title);

    g_object_notify_by_pspec (G_OBJECT(dialog), properties[PROP_PARAMETERS]);

    return TRUE;
}

static void
_on_dialog_close (GSSOUIDialog *dialog, gpointer userdata)
{
    g_return_if_fail (dialog && GSSO_IS_UI_DIALOG (dialog));

    dialog->error_code = GSSO_UI_QUERY_ERROR_CANCELED;

    gsso_ui_dialog_notify_close (dialog);
}

gboolean
gsso_ui_dialog_load_from_file (GSSOUIDialog *dialog, const gchar *file)
{
    GError *error = NULL;

    g_return_val_if_fail (dialog && GSSO_UI_DIALOG(dialog), FALSE);
    g_return_val_if_fail (file, FALSE);

    if (dialog->ui_file) g_free (dialog->ui_file);
    dialog->ui_file = g_strdup (file);

    gtk_builder_add_from_file (dialog->builder, file, &error);
    if (error) {
        g_critical ("Failed to parse UI file : %s", error->message);
        g_error_free (error);
        dialog->error_code = GSSO_UI_QUERY_ERROR_FORBIDDEN;
    }

    dialog->main_window = GTK_WIDGET (gtk_builder_get_object (dialog->builder, "window"));

    dialog->destroy_handler_id = g_signal_connect_swapped (dialog->main_window, "destroy", 
            G_CALLBACK(_on_dialog_close), (gpointer)dialog);

    return TRUE;
}

const gchar *
gsso_ui_dialog_get_request_id (GSSOUIDialog *dialog)
{
    g_return_val_if_fail (dialog && GSSO_IS_UI_DIALOG (dialog), NULL);

    return dialog->id;
}

gboolean 
gsso_ui_dialog_show (GSSOUIDialog *dialog)
{
    g_return_val_if_fail (dialog && GSSO_IS_UI_DIALOG (dialog), FALSE);
    g_return_val_if_fail (dialog->main_window, FALSE);
    g_return_val_if_fail (dialog->error_code 
            == GSSO_UI_QUERY_ERROR_NONE, FALSE);

    gtk_widget_show_all (dialog->main_window);
#ifdef ENABLE_TESTS
    GVariant *value = g_hash_table_lookup(dialog->params, GSSO_UI_KEY_TEST_REPLY_VALUES);
    if (value && g_variant_is_of_type (value, G_VARIANT_TYPE_STRING)
        && GSSO_UI_DIALOG_GET_CLASS(dialog)->handle_test_reply(
            dialog, g_variant_get_string (value, NULL))) {
        DBG("Returning test reply");
        return FALSE;
    }
#endif

    return TRUE;
}

void
gsso_ui_dialog_notify_close (GSSOUIDialog *dialog)
{
DBG("{");
    g_return_if_fail (dialog && GSSO_IS_UI_DIALOG(dialog));

    gtk_widget_hide (dialog->main_window);

    g_signal_emit (dialog, signals[CLOSE_SIGNAL], 0, NULL);
DBG("}");
}

gboolean
gsso_ui_dialog_close (GSSOUIDialog *dialog)
{
    g_return_val_if_fail (dialog && GSSO_IS_UI_DIALOG(dialog), FALSE);

    _on_dialog_close (dialog, NULL);

    return TRUE;
}

GHashTable *
gsso_ui_dialog_get_reply (GSSOUIDialog *dialog)
{
    g_return_val_if_fail (dialog && GSSO_IS_UI_DIALOG(dialog), NULL);
    g_return_val_if_fail (GSSO_UI_DIALOG_GET_CLASS(dialog)->get_reply, NULL);
DBG("{");
    if (dialog->error_code != GSSO_UI_QUERY_ERROR_NONE) {

        GHashTable *reply = g_hash_table_new_full (g_str_hash, g_str_equal, 
                                NULL, (GDestroyNotify)g_variant_unref);

        g_hash_table_insert (reply, GSSO_UI_KEY_QUERY_ERROR_CODE,
            g_variant_new_uint32 (dialog->error_code));
DBG("}");
        return reply;
    }

    return GSSO_UI_DIALOG_GET_CLASS (dialog)->get_reply (dialog);
}

gboolean
gsso_ui_dialog_refresh_captcha (GSSOUIDialog *dialog, const gchar *uri)
{
    g_return_val_if_fail (dialog && GSSO_IS_UI_DIALOG(dialog), FALSE);
    g_return_val_if_fail (uri, FALSE);
    g_return_val_if_fail (GSSO_UI_DIALOG_GET_CLASS(dialog)->refresh_captcha, FALSE);

    return GSSO_UI_DIALOG_GET_CLASS (dialog)->refresh_captcha (dialog, uri);
}

