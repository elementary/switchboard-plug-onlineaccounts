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
#ifndef _GSSO_UI_TYPES_H_
#define _GSSO_UI_TYPES_H_
#ifdef HAVE_CONFIG_H
#include "config.h"
#endif
/*
 * Possible Query types:
   - Query Only passowrd (username disabled)
   - Query Usename & password (both username & password enabled)
   - Confirm ???
 */
#define GSSO_UI_KEY_QUERY_PASSWORD   "QueryPassword" // bool
#define GSSO_UI_KEY_QUERY_USERNAME   "QueryUserName" // bool
#define GSSO_UI_KEY_CONFIRM          "Confirm"       // bool
#define GSSO_UI_KEY_OPEN_URL         "OpenUrl"     // string:url
#define GSSO_UI_KEY_FINAL_URL        "FinalUrl"    // string:url
/* Unit test reply */

#define GSSO_UI_KEY_REQUEST_ID "RequestId" // string
#define GSSO_UI_KEY_FORGOT_PASSWORD "ForgotPassword"  // bool
#define GSSO_UI_KEY_FORGOT_PASSWORD_URL "ForgotPasswordUrl"  // string:url
#define GSSO_UI_KEY_TITLE    "Title"     // string
#define GSSO_UI_KEY_CAPTION  "Caption"   // stirng - ???
#define GSSO_UI_KEY_USERNAME "UserName"  // string
#define GSSO_UI_KEY_PASSWORD "Secret"    // string
#define GSSO_UI_KEY_MESSAGE  "Message"   // string ???
#define GSSO_UI_KEY_REMEMBER_PASSWORD "RememberPassword"  // boolean
#define GSSO_UI_KEY_CAPTCHA_URL      "CaptchaUrl"  // string:url
#ifdef ENABLE_TESTS
#   define GSSO_UI_KEY_TEST_REPLY_VALUES "TestReplyValues" // string
#   define GSSO_UI_KEY_CONFIRM_SECRET     "ConfirmSecret" // string
#endif

/* only occur in reply */
#define GSSO_UI_KEY_QUERY_ERROR_CODE "QueryErrorCode"   // int32
#define GSSO_UI_KEY_URL_RESPONSE "UrlResponse"          // string:url
#define GSSO_UI_KEY_CAPTCHA_RESPONSE "CaptchaResponse"  // string

typedef enum 
{
    GSSO_UI_QUERY_ERROR_NONE = 0,        /**< No errors. */
    GSSO_UI_QUERY_ERROR_GENERAL,         /**< Generic error during interaction. */
    GSSO_UI_QUERY_ERROR_NO_SIGNONUI,     /**< Cannot send request to signon-ui. */
    GSSO_UI_QUERY_ERROR_BAD_PARAMETERS,  /**< Signon-Ui cannot create dialog based on
                                          the given UiSessionData. */
    GSSO_UI_QUERY_ERROR_CANCELED,        /**< User canceled action. Plugin should not
                                          retry automatically after this. */
    GSSO_UI_QUERY_ERROR_NOT_AVAILABLE,   /**< Requested ui is not available. For
                                          example browser cannot be started. */
    GSSO_UI_QUERY_ERROR_BAD_URL,         /**< Given url was not valid. */
    GSSO_UI_QUERY_ERROR_BAD_CAPTCHA,     /**< Given captcha image was not valid. */
    GSSO_UI_QUERY_ERROR_BAD_CAPTCHA_URL, /**< Given url for capctha loading was not
                                          valid. */
    GSSO_UI_QUERY_ERROR_REFRESH_FAILED,  /**< Refresh failed. */
    GSSO_UI_QUERY_ERROR_FORBIDDEN,       /**< Showing ui forbidden by ui policy. */
    GSSO_UI_QUERY_ERROR_FORGOT_PASSWORD  /**< User pressed forgot password. */
} GSSOUIQueryError ;



#endif /* _GSSO_UI_TYPES_H_ */
