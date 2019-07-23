import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.12

Item {
    id: root

    signal clicked()
    signal submit()
    signal remove(string dbName)
    signal clear()
    property alias model: listModel
    property string chosenDBPath: ""
    property bool doubleClicked: false

    Button {
        id: clearAllBtn
        text: "Clear All"
        height: 25
        width: 100
        anchors{
            top: parent.top
            right: listView.right
            rightMargin: 10
        }
        onClicked: root.clear()
    }

    ListView {
        id: listView
        model: listModel
        delegate: listCard
        clip: true
        spacing: 5
        height: parent.height - 25
        width: parent.width - 50
        anchors{
            top: clearAllBtn.bottom
            topMargin: 10
            horizontalCenter: parent.horizontalCenter
        }
    }

    Component {
        id: listCard
        Rectangle {
            id: cardBackground
            width: parent.width - 10
            height: 60
            color: "white"
            border.width: 2
            border.color: mouse.containsMouse ? "blue": "transparent"
            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    chosenDBPath = path
                    root.clicked()
                }
                onDoubleClicked: {
                    chosenDBPath = path
                    root.doubleClicked = true
                }
                onReleased: {
                    if (root.doubleClicked) {
                        root.doubleClicked = false;
                        root.submit()
                    }
                }
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
                    onClicked: remove(name)
                }
                source: "../Images/cancelIcon.svg"
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
                clip: true
                Image {
                    Layout.preferredHeight: 50
                    Layout.preferredWidth: 50
                    Layout.rowSpan: 2
                    Layout.alignment: Qt.AlignCenter
                    source: "../Images/database.svg"
                    fillMode: Image.PreserveAspectFit
                }
                Text {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    text: "Name: " + name
                }
                Text {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    text: "Path: " + path
                }
            }
        }
    }

    ListModel {
        id: listModel
    }
}
