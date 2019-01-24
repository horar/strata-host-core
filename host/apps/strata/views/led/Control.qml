import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.3
import "qrc:/views/led/sgwidgets"
import "qrc:/views/led/views"

Item {
    id: controlView
    objectName: "control"
    anchors { fill: parent }

    PlatformInterface {
        id: platformInterface
    }

    property bool basicControlIsVisible: true
    property bool advancedControlIsVisible: false

//    TabBar {
//        id: navTabs

//        anchors {
//            top: controlView.top
//            left: controlView.left
//            right: controlView.right
//        }

//        TabButton {
//            id: basicButton
//            text: qsTr("Basic")
//            onClicked: {
//                //from advanced
//                if (advancedControlIsVisible){
//                    //console.log("going to basic from advanced")
//                    basicControl.transitionToBasicView();
//                    basicControlIsVisible = true;
//                    advancedControlIsVisible = false;
//                }
//                //from system control
//                else if (systemControl.visible){
//                    systemControl.visible = false;
//                    basicControl.visible = true;
//                    if (!basicControlIsVisible){
//                        basicControl.switchToBasicView();
//                    }
//                    basicControlIsVisible = true;
//                }
//            }
//        }

//        TabButton {
//            id: advancedButton
//            text: qsTr("Advanced")
//            onClicked: {
//                if (basicControlIsVisible){
//                    //console.log("going to advanced from basic")
//                    basicControl.transitionToAdvancedView();
//                    basicControlIsVisible = false;
//                    advancedControlIsVisible = true;
//                }
//                //from system control
//                else if (systemControl.visible){
//                    systemControl.visible = false;
//                    basicControl.visible = true
//                    if (!advancedControlIsVisible){
//                        basicControl.switchToAdvancedView()
//                    }
//                    advancedControlIsVisible = true
//                }
//            }
//        }

//        TabButton {
//            id: systemButton
//            text: qsTr("System")
//            onClicked: {
//                basicControl.visible = false
//                //advancedControl.visible = false
//                basicControlIsVisible = false;
//                advancedControlIsVisible = false;
//                systemControl.visible = true;
//            }
//        }
 //   }

    Item {
        id: controlContainer
        anchors {
            top: controlView.top
            bottom: controlView.bottom
            right: controlView.right
            left: controlView.left
        }

        BasicControl {
            id: basicControl
            visible: true
            property real initialAspectRatio
        }

//        SystemControl{
//            id: systemControl
//            visible: false
//            property real initialAspectRatio
//        }
    }

    Component.onCompleted: {
        basicControl.initialAspectRatio = controlContainer.width / controlContainer.height

        console.log("Requesting platform Refresh")
        platformInterface.refresh.send() //ask the platform for all the current values

    }
}
