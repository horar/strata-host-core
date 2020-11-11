import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    anchors.fill: parent
    Rectangle {
        id: container
        width: parent.width/2
        height: parent.height/2
        anchors.centerIn: parent
        color: "dark gray"
    }

}
