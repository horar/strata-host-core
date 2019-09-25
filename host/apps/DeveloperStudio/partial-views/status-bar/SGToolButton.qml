import QtQuick 2.9
import QtQuick.Controls 2.3
import "qrc:/partial-views"

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

ToolButton {
    id: root
    text: qsTr("ToolButton Text")
    property alias buttonColor: backRect.color
    property string iconCharacter: ""
    property alias iconSource: buttonIcon.source
    hoverEnabled: true

    background: Rectangle {
        id: backRect
        implicitWidth: root.contentItem.children[0].width + 30
        implicitHeight: 40
        color: root.hovered ? "#666" : Qt.darker("#666")
        opacity: enabled ? 1 : 0.3
        //        visible: control.down || (control.enabled && (control.checked || control.highlighted))
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

            SGIcon {
                id: buttonIcon
                anchors {
                    right: buttonText.left
                    verticalCenter: buttonText.verticalCenter
                    verticalCenterOffset: -2
                    rightMargin: 10
                }
                height: 20
                width: height
                iconColor: "white"
                opacity: enabled ? 1.0 : 0.3
            }

            Text {
                id: buttonText
                text: root.text
                font {
                    family: Fonts.franklinGothicBook
                }
                opacity: enabled ? 1.0 : 0.3
                color: "white"
                anchors {
                    right: textAlignmentContainer.right
                }
            }
        }
    }
}
