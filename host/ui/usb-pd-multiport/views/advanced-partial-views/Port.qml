import QtQuick 2.9
import "qrc:/sgwidgets"

Item {
    id: root

    property bool debugLayout: true
    property int portNumber: 1
    property alias portConnected: portInfo.portConnected

    width: parent.width
    height: 288

    PortInfo {
        id: portInfo
        anchors {
            left: parent.left
        }
        SGLayoutDivider {
            position: "right"
        }
    }

    PortSettings {
        id: portSettings
        anchors {
            left: portInfo.right
        }
    }
}
