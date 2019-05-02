import QtQuick 2.9
import QtQuick.Controls 2.3
import "qrc:/include/Modules/"      // On Semi QML Modules
import "content-widgets"
import Fonts 1.0

Item {
    height: listViewContainer.height + 20
    width: parent.width
    property alias model: pdfListView.model

    Rectangle {
        id: listViewContainer
        border {
            width: 1
            color: "#ccc"
        }
        width: parent.width - 20
        height: pdfListView.height + 20
        anchors {
            centerIn: parent
        }
        color: "transparent"
        clip: true

        ListView {
            id: pdfListView
            anchors {
                centerIn: listViewContainer
            }
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AlwaysOn
            }
            height: Math.min(600, contentItem.childrenRect.height)
            width: listViewContainer.width - 20

            section {
                property: "dirname"
                delegate: Item {
                    id: sectionContainer
                    width: pdfListView.width - 20
                    height: delegateText.height + 10

                    Item {
                        id: sectionBackground
                        anchors {
                            topMargin: 5
                            fill: parent
                            bottomMargin: 1
                        }

                        Rectangle {
                            id: underline
                            color: "#33b13b"
                            height: 1
                            width: sectionBackground.width
                            anchors {
                                bottom: sectionBackground.bottom
                            }
                        }
                    }

                    Text {
                        id: delegateText
                        text: "<b>" + section + "</b>"
                        color: "white"
                        anchors {
                            verticalCenter: sectionContainer.verticalCenter
                            right: sectionContainer.right
                        }
                        width: sectionContainer.width - 5
                        wrapMode: Text.Wrap
                    }
                }
            }

            ButtonGroup {
                id: buttonGroup
                exclusive: true
            }

            delegate: SGSelectorButton {
                title: model.filename
                uri: model.uri
                width: pdfListView.width - 20
                leftMargin: 20
            }
        }
    }
}

