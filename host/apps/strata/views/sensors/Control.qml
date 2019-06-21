import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import Fonts 1.0
import "control-views"
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/help_layout_manager.js" as Help
//import Strata.Logger 1.0 as LoggerModule

Item {
    id: controlNavigation
    anchors {
        fill: parent
    }


    PlatformInterface{
        id: platformInterface
    }

    property var sensor_type_notification: platformInterface.get_sensor_type.type
    onSensor_type_notificationChanged: {
        if(sensor_type_notification === "touch") {
           controlContainer.currentIndex = 0
            navTabs.currentIndex = 0
        }
        else if (sensor_type_notification === "proximity"){
            controlContainer.currentIndex = 1
            navTabs.currentIndex = 1
        }
        else if( sensor_type_notification === "light" ) {
            controlContainer.currentIndex = 2
            navTabs.currentIndex = 2
        }
        else if( sensor_type_notification === "temp") {
            controlContainer.currentIndex = 3
            navTabs.currentIndex = 3
        }
        else if( sensor_type_notification === "lc717a10ar_register") {
            controlContainer.currentIndex = 4
            navTabs.currentIndex = 4
        }
        else {
            console.log("undefined tab")
        }

    }

    //property var reset_notification: platformInterface.reset_touch_mode.status


    Component.onCompleted: {
        platformInterface.set_sensor_type.update("touch")
        platformInterface.start_periodic.update("board_startup", 1 ,0)
      //  Help.registerTarget(navTabs, "Using these two tabs, you may select between basic and advanced controls.", 0, "controlHelp")
    }

    TabBar {
        id: navTabs
        anchors {
            top: controlNavigation.top
            left: controlNavigation.left
            right: controlNavigation.right
        }

        TabButton {
            id: touchButton
            text: qsTr("Touch")
            onClicked: {
                controlContainer.currentIndex = 0
                platformInterface.set_sensor_type.update("touch")
            }
        }

        TabButton {
            id: proximityButton
            text: qsTr("Proximity")
            onClicked: {
                controlContainer.currentIndex = 1
                platformInterface.set_sensor_type.update("proximity")

            }
        }

        TabButton {
            id: lightButton
            text: qsTr("Light")
            onClicked: {
                controlContainer.currentIndex = 2
                platformInterface.set_sensor_type.update("light")
            }
        }

        TabButton {
            id: temperatureButton
            text: qsTr("Temperature")
            onClicked: {     
                controlContainer.currentIndex = 3
                platformInterface.set_sensor_type.update("temp")
                platformInterface.get_nct72_status.update()
                platformInterface.get_conv_rate.update()
                platformInterface.get_cons_alert.update()

            }
        }
        TabButton {
            id: lcButton
            text: qsTr("LC717A10R")
            onClicked: {                
                controlContainer.currentIndex = 4
                platformInterface.set_sensor_type.update("lc717a10ar_register")
            }
        }
    }

    StackLayout {
        id: controlContainer
        anchors {
            top: navTabs.bottom
            bottom: controlNavigation.bottom
            right: controlNavigation.right
            left: controlNavigation.left
        }

        TouchSensorControl {
            id: touch
        }

        ProximitySensorControl {
            id: proximity
        }

        LightSensorControl {
            id: light
        }

        TemperatureSentorControl {
            id: temperature
        }
    }

//    Text {
//        id: helpIcon
//        anchors {
//            right: controlContainer.right
//            top: controlContainer.top
//            margins: 20
//        }
//        text: "\ue808"
//        color: helpMouse.containsMouse ? "lightgrey" : "grey"
//        font {
//            family: Fonts.sgicons
//            pixelSize: 40
//        }

//        MouseArea {
//            id: helpMouse
//            anchors {
//                fill: helpIcon
//            }
//            onClicked: {
//                // Make sure view is set to Basic before starting tour
//                controlContainer.currentIndex = 0
//                touchButton.clicked()
//                Help.startHelpTour("controlHelp")
//            }
//            hoverEnabled: true
//        }
//    }
}
