/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtWebChannel 1.0
import QtWebEngine 1.8

Item {

    property alias text: content.text

    WebEngineView {
        id: webView
        anchors.fill: parent

        url: "qrc:/tech/strata/sgwidgets.1.0/SGMarkdownViewer/index.html"
        webChannel: WebChannel {
            registeredObjects: [content]
        }

        onContextMenuRequested: function(request) {
            request.accepted = true
        }
    }

    QtObject {
        id: content

        property string text
        WebChannel.id: "content"
    }
}
