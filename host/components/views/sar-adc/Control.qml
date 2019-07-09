import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import "control-views"
import "qrc:/js/help_layout_manager.js" as Help

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



    StackLayout {
        id: controlContainer
        anchors {
           fill: parent
        }

        BasicControl {
            id: basic
        }


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
//        sourceSize.height: 40

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
