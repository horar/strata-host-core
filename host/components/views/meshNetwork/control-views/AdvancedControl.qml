import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09

import "qrc:/js/help_layout_manager.js" as Help

Widget09.SGResponsiveScrollView {
    id: root

    minimumHeight: 800
    minimumWidth: 1000

    Rectangle {
        id: container
        parent: root.contentItem
        anchors {
            fill: parent
        }
        color: "#ADD"

        Text {
            id: name
            text: "Advanced Control View"
            font {
                pixelSize: 60
            }
            color:"white"
            anchors {
                centerIn: parent
            }
        }


    }
}



