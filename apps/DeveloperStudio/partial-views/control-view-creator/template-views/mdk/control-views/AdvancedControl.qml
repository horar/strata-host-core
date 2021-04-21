import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQml 2.12

import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: advancedControl

    Component.onCompleted: {
        Help.registerTarget(title, "Place holder for Advanced control view help messages", 0, "AdvancedControlHelp")
    }

    Text {
        id: title
        text: "Advanced view"
        font {
            pixelSize: 20
        }
        anchors {
            centerIn: parent
        }
    }
}
