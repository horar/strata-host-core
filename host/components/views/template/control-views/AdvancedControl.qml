import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09

import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: container
    Layout.fillHeight: true
    Layout.fillWidth: true

    Component.onCompleted: {
        Help.registerTarget(name, "Place holder for Advanced control view help messages", 0, "AdvanceControlHelp")
    }

    Text {
        id: name
        width: contentWidth
        height: contentHeight
        text: "Advanced view Control Tab or Other Supporting Tabs: \nShould be used for more detailed UI implementations such as register map tables or advanced functionality. \nTake the idea of walking the user into evaluating the board by ensuring the board is instantly functional \nwhen powered on and then dive into these advanced features."
        font {
            pixelSize: 20
        }
        anchors {
            centerIn: parent
        }
    }
}
