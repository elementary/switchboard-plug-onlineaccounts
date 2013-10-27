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
#ifndef _SSO_UTILS_H_
#define _SSO_UTILS_H_

#include <glib.h>

GHashTable * g_variant_map_to_hash_table (GVariant *params);
GVariant * g_variant_map_from_hash_table (GHashTable *params);
const gchar * g_hash_map_get_string (GHashTable *map, const gchar *key);
gboolean g_hash_map_get_boolean (GHashTable *map, const gchar *key);

const gchar * get_ui_files_dir ();

#endif /* _SSO_UTILS_H_ */
