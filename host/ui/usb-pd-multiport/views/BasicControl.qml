import QtQuick 2.9
import "qrc:/sgwidgets"
import "qrc:/views/images"

Item {
    id: root

    property bool debugLayout: false
    property real ratioCalc: root.width / 1200

    anchors {
        fill: parent
    }

    Image {
        id: name
        anchors {
            fill: root
        }
        source: "images/basic-background.png"
    }

    Item {
        id: inputColumn
        width: 310 * ratioCalc
        height: root.height
        anchors {
            left: root.left
            leftMargin: 80 * ratioCalc
        }


        SGLayoutDebug {
            visible: debugLayout
        }
    }

    Item {
        id: portColumn
        width: 310 * ratioCalc
        height: root.height
        anchors {
            left: inputColumn.right
            leftMargin: 20 * ratioCalc
        }

        SGLayoutDebug {
            visible: debugLayout
        }
    }

    Item {
        id: deviceColumn
        width: 280 * ratioCalc
        height: root.height
        anchors {
            left: portColumn.right
            leftMargin: 180 * ratioCalc
        }

        SGLayoutDebug {
            visible: debugLayout
        }
    }
}
