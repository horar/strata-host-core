import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import "control-views"
import "qrc:/js/help_layout_manager.js" as Help

import tech.strata.sgwidgets 0.9
import tech.strata.fonts 1.0

Item {
    id: controlNavigation
    anchors {
        fill: parent
    }

    PlatformInterface {
        id: platformInterface
    }


//    TabBar {
//        id: navTabs
//        anchors {
//            top: parent.top
//            left: parent.left
//            right: parent.right
//        }
//    }

//    StackLayout {
//        id: controlContainer
//        anchors {
//            top: navTabs.bottom
//            bottom: controlNavigation.bottom
//            right: controlNavigation.right
//            left: controlNavigation.left
//        }

        BasicControl {
            id: basic
            anchors.fill: parent
        }
  //  }

    SGIcon {
        id: helpIcon
        anchors {
            right: basic.right
            top: parent.top
            margins: 20
        }
        source: "control-views/question-circle-solid.svg"
        iconColor: helpMouse.containsMouse ? "lightgrey" : "grey"
        height: 40
        width: 40

        MouseArea {
            id: helpMouse
            anchors {
                fill: helpIcon
            }
            onClicked: {
                // Make sure view is set to Basic before starting tour
                controlContainer.currentIndex = 0
                basicButton.clicked()
                Help.startHelpTour("controlHelp")
            }
            hoverEnabled: true
        }
    }

}
