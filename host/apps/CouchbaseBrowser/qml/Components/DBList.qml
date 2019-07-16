import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.12

Item {
    id: root
    ListView {
        id: listView
        model: listModel
        delegate: listCard
        clip: true
        spacing: 5
        anchors {
            fill: parent
            leftMargin: 25
            rightMargin: 25
        }

    }
    Component {
        id: listCard
        Rectangle {
            id: cardBackground
            width: parent.width - 10
            height: 100
            color: "white"
            border.width: 2
            border.color: "transparent"
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    listView.currentIndex = index
                    cardBackground.border.color = "blue"
                }
                onExited: cardBackground.border.color = "transparent"
                onClicked: console.log(listView.currentIndex)
            }
            Image {
                id: deleteIcon
                width: 12
                height: 12
                opacity: 0.5
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        deleteIcon.opacity = 1
                        cardBackground.border.color = "blue"
                    }
                    onExited: deleteIcon.opacity = 0.5
                    onClicked: {
                        listModel.remove(listView.currentIndex)
                    }
                }
                source: "../Images/cancelIcon.png"
                fillMode: Image.PreserveAspectFit
                anchors {
                    right: parent.right
                    top: parent.top
                    margins: 5
                }
            }
            layer.enabled: true
            layer.effect: DropShadow {
                            transparentBorder: true
                            horizontalOffset: 5
                            verticalOffset: 3
                        }

            GridLayout {
                rows: 2
                columns: 2
                anchors.fill: parent
                anchors.centerIn: parent
                Image {
                    Layout.preferredHeight: 50
                    Layout.preferredWidth: 50
                    Layout.rowSpan: 2
                    Layout.alignment: Qt.AlignCenter
                    source: "../Images/DatabaseIcon.png"
                    fillMode: Image.PreserveAspectFit

                }
                Text {
                    Layout.alignment: Qt.AlignVCenter + Qt.AlignLeading
                    text: "Name:   " + name
                }
                Text {
                    Layout.alignment: Qt.AlignVCenter + Qt.AlignLeading
                    text: "Path:   " + path
                }
            }
        }
    }

    ListModel {
        id: listModel
        ListElement {
            name: "1"
            path: "Path"
        }
        ListElement {
            name: "2"
            path: "Path"
        }
        ListElement {
            name: "3"
            path: "Path"
        }
        ListElement {
            name: "4"
            path: "Path"
        }
        ListElement {
            name: "5"
            path: "Path"
        }
    }
}
