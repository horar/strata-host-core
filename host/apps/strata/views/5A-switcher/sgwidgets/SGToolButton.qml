import QtQuick 2.9
import QtQuick.Controls 2.3

ToolButton {
    id: root
    text: qsTr("ToolButton Text")
    property alias buttonColor: backRect.color
    property string iconCharacter: ""
    hoverEnabled: true

    background: Rectangle {
        id: backRect
        implicitWidth: root.contentItem.children[0].width + 30
        implicitHeight: 40
        color: root.hovered ? "#666" : Qt.darker("#666")
        opacity: enabled ? 1 : 0.3
    }

    contentItem: Item {
        id: contentItemContainer

        Item {
            id: textAlignmentContainer
            anchors {
                centerIn: contentItemContainer
            }
            height: buttonText.height
            width: buttonIcon.text === "" ? buttonText.width : buttonText.width + buttonIcon.width + buttonIcon.anchors.rightMargin

            Text {
                id: buttonIcon
                text: root.iconCharacter
                font {
                    family: sgicons.name
                    pixelSize: 20
                }
                color: "white"
                opacity: enabled ? 1.0 : 0.3
                anchors {
                    right: buttonText.left
                    verticalCenter: buttonText.verticalCenter
                    verticalCenterOffset: -2
                    rightMargin: 10
                }
            }

            Text {
                id: buttonText
                text: root.text
                font.family: franklinGothicBook.name
                opacity: enabled ? 1.0 : 0.3
                color: "white"
                anchors {
                    right: textAlignmentContainer.right
                }
            }
        }
    }

    FontLoader {
        id: franklinGothicBook
        source: "qrc:/fonts/FranklinGothicBook.otf"
    }

    FontLoader {
        id: sgicons
        source: "qrc:/fonts/sgicons.ttf"
    }
}
