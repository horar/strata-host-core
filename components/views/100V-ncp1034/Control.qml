import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "control-views"
import "qrc:/js/help_layout_manager.js" as Help

import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Item {
    id: controlNavigation
    anchors {
        fill: parent
    }

    PlatformInterface {
        id: platformInterface
    }

    BasicControl{ }

    SGIcon {
        id: helpIcon
        anchors {
            right: controlNavigation.right
            top: controlNavigation.top
            margins: 20
        }
        source: "qrc:/sgimages/question-circle.svg"
        iconColor: helpMouse.containsMouse ? "lightgrey" : "grey"
        height: 30
        width: 30

        MouseArea {
            id: helpMouse
            anchors {
                fill: helpIcon
            }
            onClicked: {
                Help.startHelpTour("100VcontrolHelp")
            }
            hoverEnabled: true
        }
    }
}
