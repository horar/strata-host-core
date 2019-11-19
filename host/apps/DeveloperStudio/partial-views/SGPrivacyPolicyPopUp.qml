import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtWebEngine 1.7

import tech.strata.fonts 1.0

SGStrataPopup{
    id: privacyPolicy
    headerText: "Privacy Policy"
    modal: true
    glowColor: "#666"
    closePolicy: Popup.CloseOnEscape

    property real webContainerHeight

    onClosed: {
        privacyPolicy.destroy()
    }

    contentItem: Rectangle {
        id: webContainer
        color: "white"
        implicitHeight: webContainerHeight
        border {
            width: 1
            color: "grey"
        }
        onVisibleChanged: {
            if (visible) {
                webView.url = "http://www.onsemi.com/PowerSolutions/content.do?id=1109"
            }
        }

        ScrollView {
            id: webScrollView
            anchors.fill: webContainer
            anchors.margins: 1
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn

            contentHeight: webView.contentsSize.height
            contentWidth: webView.width

            WebEngineView {
                id: webView
                width: webScrollView.width
                height: Math.max(contentsSize.height, webContainer.height)
                url: "" // URL set to load upon first load of webContainer

                Rectangle {
                    id: progressBarContainer
                    width: webView.width/2
                    height: 40
                    anchors.centerIn: webView
                    border.color: "#bbb"
                    border.width: 1
                    visible: webView.loadProgress !== 100

                    property int margins: 6

                    Rectangle {
                        id: progressBar
                        color: "#bbb"
                        anchors {
                            verticalCenter: parent.verticalCenter
                        }
                        x: progressBarContainer.margins/2
                        height: parent.height - progressBarContainer.margins
                        width: (parent.width - progressBarContainer.margins) * webView.loadProgress/100
                    }

                    Text {
                        text: "Loading..."
                        anchors.bottom: progressBarContainer.top
                        anchors.left: progressBarContainer.left
                        anchors.bottomMargin: 5
                        color: "#bbb"
                    }
                }
            }
        }

        MouseArea {
            // Blocks interactivity with webView, re-creates wheel interactivity
            anchors {
                fill: webScrollView
                rightMargin: 10 // allows for clicking vertical scrollbar
            }
            hoverEnabled: false

            onClicked: mouse.accepted = true
            onDoubleClicked: mouse.accepted = true;
            onPressAndHold: mouse.accepted = true;

            onWheel: {
                if (wheel.angleDelta.y > 0) {
                    webScrollView.contentItem.contentY -= 50;
                    if (webScrollView.contentItem.contentY < 0) {
                        webScrollView.contentItem.contentY = 0;
                    }

                } else {
                    webScrollView.contentItem.contentY += 50;
                    if (webScrollView.contentItem.contentY > webScrollView.contentHeight - webScrollView.height) {
                        webScrollView.contentItem.contentY = webScrollView.contentHeight - webScrollView.height
                    }
                }
            }
        }
    }
}
