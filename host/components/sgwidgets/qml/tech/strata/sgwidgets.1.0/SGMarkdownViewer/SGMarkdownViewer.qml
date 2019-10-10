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
