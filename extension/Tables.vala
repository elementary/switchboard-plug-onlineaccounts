// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2013 Pantheon Developers (http://launchpad.net/online-accounts-plug)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 * Authored by: Corentin Noël <tintou@mailoo.org>
 */

namespace OnlineAccounts.Database.Tables {

public const string ACL = """
CREATE TABLE IF NOT EXISTS ACL (`rowid` INT, `identity_id` INT,
`method_id` INT, `mechanism_id` INT, `token_id` INT)
""";

public const string CREDIDENTIALS = """
CREATE TABLE IF NOT EXISTS CREDIDENTIALS (`id` INT, `caption` TEXT, `username` TEXT,
`flag` INT, `type` INT)
""";

public const string METHODS = """
CREATE TABLE IF NOT EXISTS METHODS (`id` INT, `method` TEXT)
""";

public const string TOKENS = """
CREATE TABLE IF NOT EXISTS TOKENS (`id` INT, `token` TEXT)
""";

}
