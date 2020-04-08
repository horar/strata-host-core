import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.12
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
    leftPadding: 10
    rightPadding: leftPadding

    background: Rectangle {
        id: backRect
        implicitHeight: 40
        color: root.hovered ? "#666" : Qt.darker("#666")
        opacity: enabled ? 1 : 0.3
    }

    contentItem: RowLayout {
        spacing: 10

        SGIcon {
            id: buttonIcon
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
        }
    }
}

