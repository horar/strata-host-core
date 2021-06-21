import QtQuick 2.12
import QtWebEngine 1.8
import QtQml 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import "./"

Item {
    id: root
    anchors.fill: parent

    property alias url: webView.url
    property bool isOpen: false

    ColumnLayout {
        anchors.fill: parent
        SGControlViewIconButton {
            Layout.preferredHeight: 25
            Layout.preferredWidth: Layout.preferredHeight
            Layout.alignment: Qt.AlignRight
            source: "qrc:/sgimages/times.svg"
            color: "red"
            onClicked: {
                webView.loadHtml("")
                isOpen = false
            }
        }

        WebEngineView {
            id: webView
            Layout.fillHeight: true
            Layout.fillWidth: true
            settings.localContentCanAccessRemoteUrls: true
            settings.localContentCanAccessFileUrls: false
            settings.localStorageEnabled: false
            settings.errorPageEnabled: true
            settings.javascriptCanOpenWindows: false
            settings.javascriptEnabled: true
            settings.javascriptCanAccessClipboard: false
            settings.pluginsEnabled: false
            settings.showScrollBars: false
            isFullScreen: true
        }
    }

    Connections {
        target: visualEditor.functions

        onGoToDocumentation: {
            isOpen = true
            if (newUrl !== url) {
                url = newUrl
            }
        }
    }
}
