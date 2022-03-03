/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import Qt.labs.settings 1.1

Settings {
    category: "Login";
    property bool rememberMe: false;
    property string token: '';
    property string first_name: '';
    property string last_name: '';
    property string user: '';

    function clear () {
        token = ""
        first_name = ""
        last_name = ""
        user = ""
    }
}
