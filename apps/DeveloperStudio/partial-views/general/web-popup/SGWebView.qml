/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebEngine 1.6
import QtGraphicalEffects 1.0

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

WebEngineView {
    id: webview
    url: ""

    settings.webGLEnabled: true
    settings.pluginsEnabled: true
    settings.defaultTextEncoding: "UTF-8"

    onContextMenuRequested: function(request) {
        request.accepted = true
    }
}

