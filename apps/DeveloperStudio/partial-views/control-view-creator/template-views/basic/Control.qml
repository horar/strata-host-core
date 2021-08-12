import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "qrc:/js/help_layout_manager.js" as Help

import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Item {
    id: controlRoot
    anchors {
        fill: parent
    }

    property string class_id // automatically populated for use when the control view is created with a connected board

    Rectangle {
        // background color
        color: "salmon"
        anchors {
            fill: parent
        }
    }

    PlatformInterface {
        id: platformInterface
    }

    SGText {
        anchors.centerIn: parent
        text: "Control View Goes Here"
    }
}
