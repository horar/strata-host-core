import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
//import tech.spyglass. 1.0
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/views/motor-vortex/sgwidgets"
import "qrc:/views/motor-vortex/Control.js" as MotorControl
Rectangle {
    id: controlNavigation
    anchors {
        fill: parent
    }

    PlatformInterface {
        id: platformInterface
    }

// TODO - Faller: Remove this old PlatInt code before merge back to dev,
//                leaving for reference while updating to new PI
//    Component.onCompleted: {
//        MotorControl.setCoreInterface(coreInterface);
//    }
//    Connections {
//        target: coreInterface
//        onNotification: {
//            try {
//                /*
//                        Attempt to parse JSON
//                */
//                var notification = JSON.parse(payload)
//                if(notification.hasOwnProperty("payload")){
//                    /*
//                          check and parse the command for the notification
//                          based on the notification value
//                    */
//                    if(notification.value === "pi_stats") {
//                        advanceView.parseCurrentSpeed(notification);
//                        faeView.parseCurrentSpeed(notification);
//                    }
//                    else if(notification.value === "input_voltage_notification")
//                    {
//                        advanceView.parseVin(notification);
//                        faeView.parseVin(notification);
//                    }
//                    else if( notification.value === "system_error")
//                    {

//                        advanceView.parseSystemError(notification);
//                        faeView.parseSystemError(notification);
//                    }

//                    else
//                    {
//                        console.log("Error expected pi_stats,input_voltage_notification or system_error but received", notification.value)
//                    }

//                }
//                else {
//                    console.log("Notification Error. payload is corrupted");
//                }
//            }
//            catch(e)
//            {
//                if (e instanceof SyntaxError){
//                    console.log("Notification JSON is invalid,ignoring")
//                }
//            }
//        }
//    }

    TabBar {
        id: navTabs
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        TabButton {
            id: basicButton
            text: qsTr("Basic")
            onClicked: controlContainer.currentIndex = 0
        }

        TabButton {
            id: advancedButton
            text: qsTr("Advanced")
            onClicked: controlContainer.currentIndex = 1
        }

        TabButton {
            id: faeButton
            text: qsTr("FAE Only")
            onClicked: controlContainer.currentIndex = 2
            background: Rectangle {
                color: faeButton.down ? "#eeeeee" : faeButton.checked ? "white" : "tomato"
            }
        }
    }

    SwipeView {
        id: controlContainer

        currentIndex: 0
        interactive: false
        anchors {
            top: navTabs.bottom
            bottom: parent.bottom
            right: parent.right
            left: parent.left
        }

        Item {
            id: basicControl
            BasicControl {id: basicView }
        }

        Item {
            id: advancedControl
            AdvancedControl {id: advanceView }
        }

        Item {
            id: faeControl
            FAEControl {id : faeView }
        }
    }

    Image {
        id: flipButton
        source:"./images/icons/infoIcon.svg"
        anchors { bottom: parent.bottom; right: parent.right }
        height: 40; width:40
    }

    MouseArea {
        width: flipButton.width; height: flipButton.height
        anchors { fill: flipButton }
        visible: true
        z: 20
        onClicked: {
            NavigationControl.updateState(NavigationControl.events.TOGGLE_CONTROL_CONTENT)
        }
    }
}
