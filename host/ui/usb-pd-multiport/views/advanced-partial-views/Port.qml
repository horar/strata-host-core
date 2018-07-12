import QtQuick 2.9
import "qrc:/sgwidgets"

Item {
    id: root

    property bool debugLayout: true

    width: parent.width
    height: 400

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
