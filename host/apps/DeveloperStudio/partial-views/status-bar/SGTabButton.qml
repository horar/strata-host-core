import QtQuick 2.9
import QtQuick.Controls 2.3

import tech.strata.fonts 1.0

TabButton {
    id: root
    text: qsTr("TabButton Text")
    property alias buttonColor: backRect.color
    hoverEnabled: true

    background: Rectangle {
        id: backRect
        implicitWidth: 40
        implicitHeight: 40
        color: root.hovered ? "#666" : Qt.darker("#666")
        opacity: enabled ? 1 : 0.3
//        visible: control.down || (control.enabled && (control.checked || control.highlighted))
    }

    contentItem: Text {
        text: root.text
        font {
            family: Fonts.franklinGothicBook
        }
        opacity: enabled ? 1.0 : 0.3
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}
