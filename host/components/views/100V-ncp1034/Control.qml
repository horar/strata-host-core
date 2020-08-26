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

    property var sgUserSettings

    PlatformInterface {
        id: platformInterface
    }

    Component.onCompleted: {
        //Help.registerTarget(navTabs, "Using these two tabs, you may select between basic and advanced controls.", 0, "controlHelp")
    }

    BasicControl{
        anchors.fill: parent
    }

//    SGIcon {
//        id: helpIcon
//        anchors {
//            right: controlContainer.right
//            top: controlContainer.top
//            margins: 20
//        }
//        source: "control-views/question-circle-solid.svg"
//        iconColor: helpMouse.containsMouse ? "lightgrey" : "grey"
//        height: 40
//        width: 40

//        MouseArea {
//            id: helpMouse
//            anchors {
//                fill: helpIcon
//            }
//            onClicked: {
//                // Make sure view is set to Basic before starting tour
//                controlContainer.currentIndex = 0
//                basicButton.clicked()
//                Help.startHelpTour("controlHelp")
//            }
//            hoverEnabled: true
//        }
//    }

}
