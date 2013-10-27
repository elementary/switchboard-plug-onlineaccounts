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
#include "config.h"
#endif
#include "gsso-ui-utils.h"


GHashTable * g_variant_map_to_hash_table (GVariant *params)
{
    GVariantIter *iter;
    gchar *key = NULL;
    GVariant *value = NULL;
    GHashTable *map = g_hash_table_new_full (
            g_str_hash, g_str_equal, (GDestroyNotify)g_free, (GDestroyNotify)g_variant_unref);

    g_variant_get (params, "a{sv}", &iter);
    while (g_variant_iter_loop (iter, "{&sv}", &key, &value)) {
        g_hash_table_insert (map, g_strdup(key), g_variant_ref_sink (value));
    }

    return map;
}

GVariant * g_variant_map_from_hash_table (GHashTable *params)
{
    GVariantBuilder builder;
    GHashTableIter iter;
    gchar *key = NULL;
    GVariant *value = NULL;

    g_variant_builder_init (&builder, (GVariantType*)"a{sv}");

    g_hash_table_iter_init (&iter, params);
    while (g_hash_table_iter_next (&iter, (gpointer*)&key, (gpointer*)&value)) {
        g_variant_builder_add (&builder, "{sv}", key, g_variant_ref_sink(value));
    }

    return g_variant_builder_end (&builder);
}

const gchar*
g_hash_map_get_string (GHashTable *map, const gchar *key)
{
    GVariant *value = g_hash_table_lookup (map, key);
    if (value && g_variant_is_of_type (value, G_VARIANT_TYPE_STRING))
        return g_variant_get_string (value, NULL);
    return NULL;
}

gboolean
g_hash_map_get_bool (GHashTable *map, const gchar *key)
{
    GVariant *value = g_hash_table_lookup (map, key);
    
    return value && g_variant_is_of_type (value, G_VARIANT_TYPE_BOOLEAN) 
        && g_variant_get_boolean (value);
}

const gchar * get_ui_files_dir ()
{
    return "/usr/lib/plugs/pantheon/online-accounts";
}
