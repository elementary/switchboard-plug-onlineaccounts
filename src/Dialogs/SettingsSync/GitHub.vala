/*
 * Copyright 2023 elementary, Inc. (https://elementary.io)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 *
 */

namespace GitHub {
    public class DeviceAndUserVerificationCodesResponse : Object {
        public string device_code { get; set; }
        public int expires_in { get; set; }
        public int interval { get; set; }
        public string user_code { get; set; }
        public string verification_uri { get; set;}
    }

    public class UserAuthorizedDeviceResponse : Object {
        public string access_token { get; set; }
        public string token_type { get; set; }
        public string scope { get; set;}
    }

    public errordomain Error {
        ERROR
    }
}

public class GitHub.Manager {
    public async DeviceAndUserVerificationCodesResponse requestDeviceAndUserVerificationCodes () throws GitHub.Error {
        Timeout.add (Random.int_range (3000, 10000), () => {
            requestDeviceAndUserVerificationCodes.callback ();
            return false;
        }, Priority.DEFAULT);

        yield;

        var response = new DeviceAndUserVerificationCodesResponse () {
            device_code = "asf7ahsf78ahsf7azgsf7ags7f6agsf67asgf7as",
            user_code = "B00A-6EB8",
            verification_uri = "https://github.com/login/device",
            expires_in = 899,
            interval = 5
        };

        return response;
    }

    public async UserAuthorizedDeviceResponse requestUserAuthorizedDevice(string device_code) throws GitHub.Error {
        var response = new UserAuthorizedDeviceResponse () {
            access_token = "asjfiajiufahjs89fahsf79ahf783h78aqfh783a",
            token_type = "bearer",
            scope = "gist"
        };

        return response;
    }

    public async UserAuthorizedDeviceResponse pollUserAuthorizedDevice(string device_code, int expires_in, int interval) throws GitHub.Error {
        var seconds_left = expires_in - interval;

        UserAuthorizedDeviceResponse? response = null;
        Timeout.add_seconds_full (Priority.DEFAULT, interval, ()=> {
            if (seconds_left <= 0 || response != null) {
                pollUserAuthorizedDevice.callback ();
                return false;
            }

            if (seconds_left < 894) {
                requestUserAuthorizedDevice.begin (device_code, (obj, res) => {
                    try {
                        response = requestUserAuthorizedDevice.end (res);
                    } catch (Error e) {
                        warning ("Could not request user authorized device: %s", e.message);
                    }
                });
            }

            seconds_left -= interval;

            return true;
        });

        yield;

        if (response == null) {
            throw new GitHub.Error.ERROR ("Could not get response");
        }

        return response;
    }

    private static GLib.Once<Manager> instance;
    public static unowned Manager get_default () {
        return instance.once (() => {
            return new Manager ();
        });
    }

    private Manager () {}
}
