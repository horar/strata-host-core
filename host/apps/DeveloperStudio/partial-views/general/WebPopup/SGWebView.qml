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

