import QtQuick 2.12
import QtWebEngine 1.8
import QtQml 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import "./"

Item {
    id: root
    Layout.fillHeight: true
    Layout.fillWidth: true

    property alias url: webView.url
    property bool isOpen: false

    ColumnLayout {
        anchors.fill: parent
        WebEngineView {
            id: webView
            Layout.fillHeight: true
            Layout.fillWidth: true
            settings.localContentCanAccessRemoteUrls: true
            settings.localContentCanAccessFileUrls: false
            settings.localStorageEnabled: false
            settings.errorPageEnabled: false
            settings.javascriptCanOpenWindows: false
            settings.javascriptEnabled: false
            settings.javascriptCanAccessClipboard: false
            settings.pluginsEnabled: false
            settings.showScrollBars: true
            settings.autoLoadIconsForPage: false
            settings.autoLoadImages: false
            settings.webGLEnabled: false
            settings.hyperlinkAuditingEnabled: false
            property bool opened: false
            onNavigationRequested: {
                if(request.navigationType === WebEngineView.BackForwardNavigation){
                    request.action = WebEngineView.IgnoreRequest;
                } else if(request.navigationType === WebEngineView.LinkClickedNavigation){
                    request.action = WebEngineView.IgnoreRequest;
                }
            }

            onContextMenuRequested: {
                request.accepted = true
            }

            MouseArea {
                anchors.fill: webView
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                onClicked: {
                    mouse.accepted = true
                }
            }
        }
    }
}
