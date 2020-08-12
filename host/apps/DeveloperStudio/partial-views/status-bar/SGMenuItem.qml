import QtQuick 2.9
import QtQuick.Controls 2.3

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0
import QtQuick.Layouts 1.12

Button {
    id: root
    text: qsTr("Button Text")
    hoverEnabled: true

    property alias buttonColor: backRect.color
    property alias textColor: buttonText.color
    property alias iconSource: icon.source

    contentItem: RowLayout {
        Text {
            id: buttonText
            text: root.text
            opacity: enabled ? 1.0 : 0.3
            color: "white"
            font {
                family: Fonts.franklinGothicBook
            }
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        SGIcon {
            id: icon
            Layout.preferredHeight: 20
            Layout.preferredWidth: Layout.preferredHeight
            iconColor : "white"
            visible: source !== ""
        }
    }

    background: Rectangle {
        id: backRect
        implicitWidth: 100
        implicitHeight: 40
        opacity: enabled ? 1 : 0.3
        radius: 2
        color: !root.hovered ? "#00b842" : root.pressed ? Qt.darker("#007a1f", 1.25) : "#007a1f"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onPressed: mouse.accepted = false
        cursorShape: Qt.PointingHandCursor
    }
}
