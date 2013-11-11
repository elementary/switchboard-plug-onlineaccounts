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
#include "gsso-ui-gtk-dialog.h"
#include "gsso-ui-types.h"
#include "gsso-ui-log.h"
#include "gsso-ui-utils.h"
#include <string.h>

struct _GSSOUIGtkDialog
{
    GSSOUIDialog parent;

    GtkWidget *main_window;
    GtkEntry *txt_username;
    GtkEntry *txt_password;
    GtkEntry *txt_old_password;
    GtkEntry *txt_new_password;
    GtkEntry *txt_confirm_password;
    GtkEntry *txt_captcha;
    GtkToggleButton *chk_remember_password;
    GtkWidget *btn_ok;

    GHashTable *params;
    gboolean query_username;
    gboolean query_password;
    gboolean query_confirm;
    gboolean query_captcha;

    gboolean is_username_valid;
    gboolean is_password_valid;
    gboolean is_new_password_valid;
    gboolean is_confirm_password_valid;
    gboolean is_captcha_valid;

    const gchar *old_password;
    const gchar *forgot_password_url;
    gulong response_handler_id;
};

G_DEFINE_TYPE (GSSOUIGtkDialog, gsso_ui_gtk_dialog, GSSO_TYPE_UI_DIALOG)

enum {
    PROP_0,
    PROP_PARAMETERS,
    M_PROPERTIES
};

enum {
    REFRES_CAPTCHA_SIGNAL,
    LAST_SIGNAL
};
static guint signals[LAST_SIGNAL] = { 0 };

static void
_dispose (GObject *object)
{
    G_OBJECT_CLASS (gsso_ui_gtk_dialog_parent_class)->dispose (object);
}

static GHashTable *
_get_reply (GSSOUIDialog *dialog)
{
    GHashTable *reply = NULL;
    const gchar *username = NULL;
    const gchar *password = NULL;
    gboolean remeber_password = FALSE;
    GtkEntry *entry = NULL;
    GSSOUIGtkDialog *self = NULL;
    
    g_return_val_if_fail (dialog && GSSO_IS_UI_DIALOG (dialog), NULL);

    self = GSSO_UI_GTK_DIALOG (dialog);

    reply = g_hash_table_new_full (g_str_hash, g_str_equal, 
                    NULL, (GDestroyNotify)g_variant_unref);

    g_hash_table_insert (reply, GSSO_UI_KEY_QUERY_ERROR_CODE,
            g_variant_new_uint32 (dialog->error_code));

    username = gtk_entry_get_text (self->txt_username);
    g_hash_table_insert (reply, GSSO_UI_KEY_USERNAME,
                g_variant_new_string (username));
    
    entry = self->query_confirm ? self->txt_confirm_password : self->txt_password;
        
    password = gtk_entry_get_text (entry);
    g_hash_table_insert (reply, GSSO_UI_KEY_PASSWORD,
		 g_variant_new_string (password));

    remeber_password = gtk_toggle_button_get_active (self->chk_remember_password);
    g_hash_table_insert (reply, GSSO_UI_KEY_REMEMBER_PASSWORD, 
    g_variant_new_boolean (remeber_password));

    if (self->query_captcha) {
        g_hash_table_insert (reply, GSSO_UI_KEY_CAPTCHA_RESPONSE,
                g_variant_new_string (gtk_entry_get_text (self->txt_captcha)));
    }

    return reply;
}

static void
_on_captcha_refresh_clicked (GSSOUIGtkDialog *dialog, 
                     GtkEntryIconPosition icon_pos,
                     GdkEvent *event,
                     GtkEntry *entry)
{
    g_signal_handlers_disconnect_by_func (entry, _on_captcha_refresh_clicked, dialog);

    /*TODO: disable dialog other than cancel
      and show animation till we get get refresh 
      request from client.
      */
    g_signal_emit (dialog, signals[REFRES_CAPTCHA_SIGNAL], 0, NULL);
}

static gboolean
_refresh_captcha (GSSOUIDialog *dialog, const gchar *uri)
{
    GtkImage *img = NULL;
    GtkWidget *captcha_box = NULL;
    gchar *filename = NULL, *used_filename = NULL;
    gboolean is_valid = FALSE;

    g_return_val_if_fail (dialog && GSSO_IS_UI_DIALOG (dialog), FALSE);

    if (!uri || !(filename = g_filename_from_uri (uri, NULL, NULL))) {
        g_warning ("invalid captcha value : %s", uri);
        dialog->error_code = GSSO_UI_QUERY_ERROR_BAD_CAPTCHA_URL;
        return FALSE;
    }
    DBG("setting captcha : %s", filename);
 
    img = GTK_IMAGE(gtk_builder_get_object (dialog->builder, "img_captcha"));
    gtk_image_set_from_file (img, filename);

    g_object_get (G_OBJECT (img), "file", &used_filename, NULL);

    DBG("Used file : %s", used_filename);
    is_valid = g_strcmp0 (filename, used_filename) == 0;

    g_free (filename);
    g_free (used_filename);

    if (!is_valid) {
        dialog->error_code = GSSO_UI_QUERY_ERROR_BAD_CAPTCHA;
        return FALSE;
    }

    captcha_box = GTK_WIDGET (gtk_builder_get_object (dialog->builder, "vbox_captcha"));
    gtk_widget_set_visible (captcha_box, TRUE);

    g_signal_connect_swapped (GSSO_UI_GTK_DIALOG(dialog)->txt_captcha, "icon-press",
            G_CALLBACK(_on_captcha_refresh_clicked), dialog);

    GSSO_UI_GTK_DIALOG(dialog)->query_captcha = TRUE;
 
    return TRUE;
}

#ifdef ENABLE_TESTS
static gboolean
_handle_test_reply (GSSOUIDialog *dialog, const gchar *test_reply)
{
    char **iter;
    char **pairs = g_strsplit (test_reply, ",", 0);
    GSSOUIGtkDialog *self = GSSO_UI_GTK_DIALOG(dialog);

    if (!self || !test_reply) return FALSE;

    for (iter = pairs; *iter; iter++) {
        char **pair = g_strsplit (*iter, ":", 2);
        if (g_strv_length (pair) == 2) {
            if (g_strcmp0 (pair[0], GSSO_UI_KEY_CAPTCHA_RESPONSE) == 0) {
                gtk_entry_set_text (self->txt_captcha, pair[1]);
            } else if (g_strcmp0 (pair[0], GSSO_UI_KEY_PASSWORD) == 0) {
                gtk_entry_set_text (self->txt_password, pair[1]);
            } else if (g_strcmp0 (pair[0], GSSO_UI_KEY_CONFIRM_SECRET) == 0) {
                gtk_entry_set_text (self->txt_new_password, pair[1]); 
                gtk_entry_set_text (self->txt_confirm_password, pair[1]); 
            } else if (g_strcmp0 (pair[0], GSSO_UI_KEY_QUERY_ERROR_CODE) == 0) {
                dialog->error_code = atoi(pair[1]);
            } else if (g_strcmp0 (pair[0], GSSO_UI_KEY_REMEMBER_PASSWORD) == 0) {
                gtk_toggle_button_set_active (GTK_TOGGLE_BUTTON (self->chk_remember_password),
                    !g_ascii_strcasecmp (pair[1], "true"));
            } else if (g_strcmp0 (pair[0], GSSO_UI_KEY_USERNAME) == 0) {
                    gtk_entry_set_text (self->txt_username, pair[1]);
            }
        }
        g_strfreev (pair);
    }
    g_strfreev (pairs);

    return TRUE;
}
#endif

static void
gsso_ui_gtk_dialog_class_init (GSSOUIGtkDialogClass *klass)
{
    GObjectClass *g_klass = G_OBJECT_CLASS (klass);
    GSSOUIDialogClass *dialog_klass = GSSO_UI_DIALOG_CLASS (klass);

    g_klass->dispose = _dispose;
    dialog_klass->get_reply = _get_reply;
    dialog_klass->refresh_captcha = _refresh_captcha;
#ifdef ENABLE_TESTS
    dialog_klass->handle_test_reply = _handle_test_reply;
#endif

    signals[REFRES_CAPTCHA_SIGNAL] =
        g_signal_new ("refresh-captcha",
                G_TYPE_FROM_CLASS(klass),
                G_SIGNAL_RUN_FIRST,
                0, NULL, NULL,
                g_cclosure_marshal_VOID__VOID,
                G_TYPE_NONE, 0);
}

static void
gsso_ui_gtk_dialog_init (GSSOUIGtkDialog *self)
{
    self->old_password = self->forgot_password_url = NULL;
    self->query_username = self->query_password = FALSE;
    self->query_confirm = self->query_captcha = FALSE;
    self->is_username_valid = self->is_password_valid = FALSE;
    self->is_new_password_valid = self->is_confirm_password_valid = FALSE;
    self->is_captcha_valid = FALSE;
    self->forgot_password_url = self->old_password = NULL;
    self->response_handler_id = 0;
}

static void
_on_dialog_response (GSSOUIGtkDialog *self, uint response, gpointer gtk_dialog_widget)
{
    GSSOUIDialog *dialog = GSSO_UI_DIALOG (self);
    DBG("Dialog response : %d", response);

    g_signal_handler_disconnect (gtk_dialog_widget, self->response_handler_id);
    self->response_handler_id = 0;

    if (response != GTK_RESPONSE_OK) {
        dialog->error_code = GSSO_UI_QUERY_ERROR_CANCELED;
    }

    gsso_ui_dialog_notify_close (dialog);
}
static void
_reset_ok (GSSOUIGtkDialog *self)
{
    gboolean state = FALSE;

    if (self->query_username)
        state = self->is_username_valid && self->is_password_valid;
    else if (self->query_password)
        state = self->is_password_valid;
    else if (self->query_confirm)
        state = self->is_password_valid && self->is_new_password_valid;

    if (self->query_captcha)
        state = state && self->is_captcha_valid;

    if (gtk_widget_get_sensitive (self->btn_ok) != state)
        gtk_widget_set_sensitive (self->btn_ok, state);
}

static void
_on_username_changed (GSSOUIGtkDialog *self, GParamSpec *pspec, GtkEntry *entry)
{
    const gchar *text = gtk_entry_get_text (entry);

    self->is_username_valid = text && text[0];

    _reset_ok (self);
}

static void
_on_password_changed (GSSOUIGtkDialog *self, GParamSpec *pspec, GtkEntry *entry)
{
    const gchar *text = gtk_entry_get_text (entry);

    self->is_password_valid = text && text[0];
    if (self->query_confirm && self->is_password_valid && self->old_password)
        self->is_password_valid = !g_strcmp0 (self->old_password, text);

    _reset_ok (self);
}

static void
_on_new_password_changed (GSSOUIGtkDialog *self, GParamSpec *pspec, GtkEntry *entry)
{
    const gchar *new = gtk_entry_get_text (self->txt_new_password);
    const gchar *confirm = gtk_entry_get_text (self->txt_confirm_password);

    self->is_new_password_valid = 
        new && new[0] &&
        confirm && confirm[0] &&
        !g_strcmp0 (new, confirm);

    _reset_ok(self);
}

static void
_on_captcha_changed (GSSOUIGtkDialog *self, GParamSpec *pspec, GtkEntry *entry)
{
    const gchar *text = gtk_entry_get_text (entry);

    self->is_captcha_valid = text && text[0];

    _reset_ok (self);
}

static gboolean
_close_dialog (gpointer self)
{
    gsso_ui_dialog_notify_close (GSSO_UI_DIALOG(self));

    return FALSE;
}

static gboolean
_on_forgot_password (GSSOUIGtkDialog *self, GtkLinkButton *btn)
{
    DBG ("Forgot password");
    GSSO_UI_DIALOG (self)->error_code = GSSO_UI_QUERY_ERROR_FORGOT_PASSWORD;

    g_idle_add (_close_dialog, self);

    return FALSE;
}

static gboolean
_validate_params (GSSOUIGtkDialog *self, GHashTable *params)
{
    /* determine query type and its validate its value */
    self->query_username = g_hash_map_get_bool(params, GSSO_UI_KEY_QUERY_USERNAME);
    self->query_password = g_hash_map_get_bool(params, GSSO_UI_KEY_QUERY_PASSWORD);
    self->query_confirm  = g_hash_map_get_bool(params, GSSO_UI_KEY_CONFIRM);

    if (!self->query_username && !self->query_password && !self->query_confirm) {
        WARN ("No Valid Query found");
        return FALSE;
    }

    if (!self->query_username && !g_hash_map_get_string(params, GSSO_UI_KEY_USERNAME)) {
        WARN ("No username found, for query type non QueryUsername");
        /* TODO: Is it a real issue */ 
        //return FALSE;
    }

    self->old_password = g_hash_map_get_string (params, GSSO_UI_KEY_PASSWORD);

    if (self->query_confirm && !self->old_password) {
        WARN ("Wrong params for confirm query");
        return FALSE;
    }

    self->forgot_password_url = g_hash_map_get_string (params, GSSO_UI_KEY_FORGOT_PASSWORD_URL);

    return TRUE;
}

gboolean 
gsso_ui_gtk_dialog_set_parameters (GSSOUIGtkDialog *self, GHashTable *params)
{
    GObject *label = NULL;
    const gchar *tmp_str = NULL;
    GtkBuilder *builder = NULL;
DBG("{");
    g_assert (GSSO_UI_DIALOG(self)->params);
    g_return_val_if_fail (self && GSSO_IS_UI_GTK_DIALOG (self), FALSE);

    if (! _validate_params (self, params)) {
        GSSO_UI_DIALOG(self)->error_code = GSSO_UI_QUERY_ERROR_BAD_PARAMETERS;
        WARN ("Bad parameters");
        return FALSE;
    }

    builder = GSSO_UI_DIALOG (self)->builder;

    self->txt_username = GTK_ENTRY (gtk_builder_get_object (builder, "txt_username"));
    self->txt_password = GTK_ENTRY (gtk_builder_get_object (builder, "txt_password"));
    self->txt_old_password = GTK_ENTRY (gtk_builder_get_object (builder, "txt_old_password"));
    self->txt_new_password = GTK_ENTRY (gtk_builder_get_object (builder, "txt_new_password"));
    self->txt_confirm_password = GTK_ENTRY (gtk_builder_get_object (builder, "txt_confirm_password"));
    self->txt_captcha = GTK_ENTRY (gtk_builder_get_object (builder, "txt_captcha"));
    self->chk_remember_password = GTK_TOGGLE_BUTTON (gtk_builder_get_object (builder, "chk_remember_password"));
    self->btn_ok = GTK_WIDGET (gtk_builder_get_object (builder, "btn_ok"));

    self->response_handler_id = g_signal_connect_swapped (
          GSSO_UI_DIALOG(self)->main_window, "response", G_CALLBACK(_on_dialog_response), self);

    tmp_str = g_hash_map_get_string (params, GSSO_UI_KEY_USERNAME);
    g_object_set (G_OBJECT(self->txt_username), 
         "sensitive", self->query_username || (tmp_str == NULL),
         "text", tmp_str ? tmp_str : "", NULL);

    //gtk_entry_set_text (self->txt_password, self->old_password);

    label = gtk_builder_get_object (builder, "vbox_new_password");
    g_object_set (label, "visible", self->query_confirm, NULL);
    label = gtk_builder_get_object (builder, "vbox_confirm_password");
    g_object_set (label, "visible", self->query_confirm, NULL);
 
    if (self->forgot_password_url) {
        GObject *btn_forgot_password = gtk_builder_get_object (
                    builder, "btn_forgot_password");
        tmp_str = g_hash_map_get_string (params, GSSO_UI_KEY_FORGOT_PASSWORD);
        g_object_set (btn_forgot_password, "visible", TRUE, 
            "label", tmp_str ? tmp_str : "Forgot password",
            "uri", self->forgot_password_url, NULL);
        g_signal_connect_swapped (btn_forgot_password, "activate-link",
                G_CALLBACK(_on_forgot_password), self);
    }
    tmp_str = g_hash_map_get_string (params, GSSO_UI_KEY_MESSAGE);
    if (tmp_str) {
        GObject *lbl_message = gtk_builder_get_object (builder, "lbl_message");
        g_object_set (lbl_message, "label", tmp_str, "visible", TRUE, NULL);
    }

    tmp_str = g_hash_map_get_string (params, GSSO_UI_KEY_CAPTCHA_URL);
    if (tmp_str) {
        self->query_captcha =  _refresh_captcha (GSSO_UI_DIALOG(self), tmp_str);
    }

    if (self->query_username)
        g_signal_connect_swapped (self->txt_username, "notify::text",
                G_CALLBACK(_on_username_changed), self);
    g_signal_connect_swapped (self->txt_password, "notify::text", 
            G_CALLBACK(_on_password_changed), self);
    if (self->query_confirm) {
        g_signal_connect_swapped (self->txt_new_password, "notify::text",
                G_CALLBACK(_on_new_password_changed), self);
        g_signal_connect_swapped (self->txt_confirm_password, "notify::text",
                G_CALLBACK(_on_new_password_changed), self);
    }
    if (self->query_captcha) 
        g_signal_connect_swapped (self->txt_captcha, "notify::text",
                G_CALLBACK(_on_captcha_changed), self);

DBG("}");
  
    return TRUE;
}

GSSOUIDialog *
gsso_ui_gtk_dialog_new (GHashTable *params)
{
    gchar *ui_file =  g_build_filename (get_ui_files_dir(), "gsso-ui-gtk-dialog.ui", NULL);
    GSSOUIDialog *dialog = g_object_new (
            GSSO_TYPE_UI_GTK_DIALOG, 
            "ui-file",  ui_file,
            "parameters", params, NULL);

    DBG("Gtk UI dialog path : %s", ui_file);
    g_free (ui_file);

    gsso_ui_gtk_dialog_set_parameters (GSSO_UI_GTK_DIALOG (dialog), params);

    return dialog;
}

