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

//    Component.onCompleted: {
//        Help.registerTarget(navTabs, "Using these two tabs, you may select between basic and advanced controls.", 0, "controlHelp")
//    }

//    TabBar {
//        id: navTabs
//        anchors {
//            top: parent.top
//            left: parent.left
//            right: parent.right
//        }

//        TabButton {
//            id: basicButton
//            text:"<b>ACF PSU</b>"
//            onClicked: {
//                controlContainer.currentIndex = 0
//            }


//        }

//        TabButton {
//            id: advancedButton
//            text: qsTr("Advanced")
//            onClicked: {
//                controlContainer.currentIndex = 1
//            }
//        }
//    }

    StackLayout {
        id: controlContainer
        anchors {
            top: controlNavigation.top
            bottom: controlNavigation.bottom
            right: controlNavigation.right
            left: controlNavigation.left
        }

        BasicControl {
            id: mainmenu
        }


    }
//HELP ICON TO BE IMPLEMENTED
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

//    DebugMenu {
//        // See description in control-views/DebugMenu.qml
//        anchors {
//            right: controlContainer.right
//            bottom: controlContainer.bottom
//        }
//    }
}
