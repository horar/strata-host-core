import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Button {
    padding: 0
    implicitHeight: 20
    Layout.fillWidth: true

    MouseArea {
        id: mouse
        anchors {
            fill: parent
        }
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onPressed: mouse.accepted = false
    }
}
