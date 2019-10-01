import QtQuick 2.9
import QtQuick.Controls 2.3

Button {
    id: root
    text: qsTr("Button")
    background: Rectangle {
        implicitWidth: 100
        implicitHeight: 40
        opacity: enabled ? 1 : 0.3
        color: checked ? "#33b13b":"#e0e0e0"
    }
}
