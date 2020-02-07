import QtQuick 2.3
import QtQuick.Controls 2.3
import "qrc:/js/help_layout_manager.js" as Help

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

Item {
    id: root
    height: root.childrenRect.height
    width: 360

    property int index: 0
    property alias description: description.text
    property real fontSizeMultiplier: 1

    signal close()
    onClose: Help.closeTour()

    SGIcon {
        id: closer
        source: "qrc:/images/icons/times.svg"
        anchors {
            top: root.top
            right: root.right
            rightMargin: 2
        }
        iconColor: closerMouse.containsMouse ? "lightgrey" : "grey"
        height: 18
        width: height

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

        SGText {
            id: helpText
            color:"grey"
            fontSizeMultiplier: 1.25 //* root.fontSizeMultiplier
            text: " "
            anchors {
                horizontalCenter: column.horizontalCenter
            }
            onVisibleChanged: {
                if (visible) {
                    text = (root.index + 1) + "/" + Help.tour_count
                }
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

        SGTextEdit {
            id: description
            text: "Placeholder Text"
            width: root.width - 20
            color: "grey"
            anchors {
                horizontalCenter: column.horizontalCenter
            }
            readOnly: true
            wrapMode: TextEdit.Wrap
            fontSizeMultiplier: root.fontSizeMultiplier
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
                onVisibleChanged: {
                    if (visible) {
                        text = (root.index + 1) === Help.tour_count ? "End Tour" : "Next"
                    }
                }
            }
        }
    }
}
