// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2013-2015 Pantheon Developers (https://launchpad.net/switchboard-plug-onlineaccounts)
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
 * Authored by: Corentin Noël <corentin@elementary.io>
 */

namespace OnlineAccounts.Key {
    const string QUERY_PASSWORD = "QueryPassword";  // bool
    const string QUERY_USERNAME = "QueryUserName";  // bool
    const string CONFIRM = "Confirm";               // bool
    const string OPEN_URL = "OpenUrl";              // string:url
    const string FINAL_URL = "FinalUrl";            // string:url

    const string DISPLAY_NAME = "DisplayName";  // string
    const string REQUEST_ID = "RequestId";                  // string
    const string FORGOT_PASSWORD = "ForgotPassword";        // bool
    const string FORGOT_PASSWORD_URL = "ForgotPasswordUrl"; // string:url
    const string TITLE = "Title";                           // string
    const string CAPTION = "Caption";                       // string - ???
    const string USERNAME = "UserName";                     // string
    const string PASSWORD = "Secret";                       // string
    const string MESSAGE = "Message";                       // string ???
    const string REMEMBER_PASSWORD = "RememberPassword";    // bool
    const string CAPTCHA_URL = "CaptchaUrl";                // string:url
    const string SIGNUP_URL = "SignUpURL";  // string

    const string QUERY_ERROR_CODE = "QueryErrorCode";   // int32
    const string URL_RESPONSE = "UrlResponse";          // string:url
    const string CAPTCHA_RESPONSE = "CaptchaResponse";  // string
}
