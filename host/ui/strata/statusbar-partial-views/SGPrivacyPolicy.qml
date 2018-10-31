import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Fonts 1.0
import QtWebEngine 1.6

Item {
    id: root
    anchors {
        fill: profileStack
    }
    clip: true

    Item {
        id: popupContainer
        width: root.width
        height: root.height
        clip: true

        ScrollView {
            id: scrollView
            anchors {
                fill: popupContainer
            }

            contentHeight: contentContainer.height
            contentWidth: contentContainer.width
            clip: true

            Item {
                id: contentContainer
                width: Math.max(popupContainer.width, 600)
                height: mainColumn.height + mainColumn.anchors.margins*2
                clip: true

                Column {
                    id: mainColumn
                    spacing: 30
                    anchors {
                        top: contentContainer.top
                        right: contentContainer.right
                        left: contentContainer.left
                        margins: 15
                    }

                    Rectangle {
                        id: webContainer
                        color: "white"
                        width: mainColumn.width
                        height: Math.max(root.height - backButton.height - mainColumn.spacing - (mainColumn.anchors.margins * 2), 400)
                        border {
                            width: 1
                            color: "grey"
                        }

                        WebEngineView {
                            id: webView
                            anchors {
                                fill: webContainer
                                margins: 1
                            }
                            url: "http://www.onsemi.com/PowerSolutions/content.do?id=1109"
                        }
                    }

                    Button {
                        id: backButton
                        text: "Return to Profile"
                        width: 200
                        onClicked: profileStack.currentIndex = 0
                        anchors {
                            horizontalCenter: mainColumn.horizontalCenter
                        }
                    }
                }
            }
        }
    }
}
