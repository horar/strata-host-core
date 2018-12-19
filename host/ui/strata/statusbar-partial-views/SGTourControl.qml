import QtQuick 2.3
import QtQuick.Controls 2.3
import Fonts 1.0
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    height: root.childrenRect.height
    width: 360

    property int index: 0
    property alias description: description.text

    signal close()

    Text {
        id: closer
        text: "\ue805"
        anchors {
            top: root.top
            right: root.right
        }

        color: closerMouse.containsMouse ? "lightgrey" : "grey"

        font {
            family: Fonts.sgicons
            pixelSize: 18
        }

        MouseArea {
            id: closerMouse
            anchors {
                fill: closer
            }
            onClicked: root.close()
            hoverEnabled: true
        }
    }

    Column {
        id: column
        width: root.width

        Text {
            id: helpText
            color:"grey"
            font {
                pixelSize: 20
            }
            text: ""
            anchors {
                horizontalCenter: column.horizontalCenter
            }
            onVisibleChanged: {
                    text = (root.index + 1) + "/" +  Help.tourCount

            }
        }

        Item {
            height: 15
            width: 15
        }

        Rectangle {
            width: root.width - 40
            height: 1
            color: "darkgrey"
            anchors {
                horizontalCenter: column.horizontalCenter
            }
        }

        Item {
            height: 15
            width: 15
        }

        TextEdit {
            id: description
            text: "Placeholder Text"
            width: root.width - 20
            color: "grey"
            anchors {
                horizontalCenter: column.horizontalCenter
            }
            wrapMode: TextEdit.Wrap
        }

        Item {
            height: 15
            width: 15
        }

        Row {
            anchors {
                horizontalCenter: column.horizontalCenter
            }

            Button {
                text: "Prev"
                onClicked: {
                    Help.prev(root.index)
                }
                enabled: root.index !== 0
            }

            Item {
                height: 15
                width: 15
            }

            Button {
                text: "Next"
                onClicked: {
                    Help.next(root.index)
                }
                onVisibleChanged: text = (root.index + 1) === Help.tourCount ? "End Tour" : "Next"
            }
        }
    }
}
