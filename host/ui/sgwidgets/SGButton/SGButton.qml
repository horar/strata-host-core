import QtQuick 2.9
import QtQuick.Controls 2.3

Button {
    id: root
    text: qsTr("Button")
    property alias textColor: buttonContent.color
    property alias color: buttonBackground.color

    contentItem: Text {
        id: buttonContent
        text: root.text
        font: root.font
        opacity: enabled ? 1.0 : 0.3
        color: checked ? "#ffffff" : "#26282a"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        id: buttonBackground
        implicitWidth: 100
        implicitHeight: 40
        opacity: root.enabled ? 1 : 0.3
        color: checked ? "#353637" : pressed ? "#cfcfcf":"#e0e0e0"
    }
}
