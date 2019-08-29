import QtQuick 2.12
import QtWebChannel 1.0
import QtWebEngine 1.8

Item {

    property alias text: content.text

    WebEngineView {
        id: webView
        anchors.fill: parent

        url: "qrc:/tech/strata/sgwidgets/SGMarkdownViewer/index.html"
        webChannel: WebChannel {
            registeredObjects: [content]
        }
    }

    QtObject {
        id: content

        property string text
        WebChannel.id: "content"
    }
}
