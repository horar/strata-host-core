import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import "control-views"
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/help_layout_manager.js" as Help
import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

Item {
    id: controlNavigation
    anchors {
        fill: parent
    }

    property real ratioCalc: controlNavigation.width / 1200

    property real sensorItWasOn: 0
    property string popupMessage: ""
    property string unknownPopupHeading: "Unknown Sensor State"
    property string unknownPopupMessage: "A previous Strata session configured this sensor without power cycling the sensor to reset it to default register values. The user interface and sensor registers will be out of sync. Please unplug then plug in the USB cable to perform a power on reset of this sensor."

    PlatformInterface {
        id: platformInterface
    }

    Popup {
        id: warningPopup
        width: controlNavigation.width/3
        height: controlNavigation.height/5
        anchors.centerIn: controlNavigation
        modal: true
        focus: true
        closePolicy:Popup.NoAutoClose

        background: Rectangle {
            id: warningPopupContainer1
            width: warningPopup.width
            height: warningPopup.height
            color: "#dcdcdc"
            border.color: "grey"
            border.width: 2
            radius: 10
        }

        Rectangle {
            id: warningBox
            color: "red"
            anchors.centerIn: parent

            anchors.horizontalCenter: parent.horizontalCenter
            width: (parent.width) - 10
            height: parent.height/3
            Text {
                id: warningText
                anchors.centerIn: parent
                text: popupMessage
                font.pixelSize: (parent.width + parent.height)/ 32
                color: "white"
                font.bold: true
            }

            Text {
                id: warningIcon3
                anchors {
                    right: warningText.left
                    verticalCenter: warningText.verticalCenter
                    rightMargin: 10
                }
                text: "\ue80e"
                font.family: Fonts.sgicons
                font.pixelSize: (parent.width + parent.height)/ 15
                color: "white"
            }

            Text {
                id: warningIcon4
                anchors {
                    left: warningText.right
                    verticalCenter: warningText.verticalCenter
                    leftMargin: 10
                }
                text: "\ue80e"
                font.family: Fonts.sgicons
                font.pixelSize: (parent.width + parent.height)/ 15
                color: "white"
            }
        }
    }

    property var sensor_status_value: platformInterface.sensor_status_value.value
    onSensor_status_valueChanged: {
        if(sensor_status_value === "close_popup")
            warningPopup.close()
        else if(sensor_status_value === "unknown_state")
            unknownPopup.open()
        else if(sensor_status_value === "config_failed")
            invalidWarningTouchPopup.open()
    }

    property var sensor_type_notification: platformInterface.sensor_value.value
    onSensor_type_notificationChanged: {
        if(sensor_type_notification === "touch") {
            controlContainer.currentIndex = 0
            navTabs.currentIndex = 0
            platformInterface.set_sensor_type.update("touch")

        }
        else if (sensor_type_notification === "proximity"){
            controlContainer.currentIndex = 1
            navTabs.currentIndex = 1
            platformInterface.set_sensor_type.update("proximity")


        }
        else if(sensor_type_notification === "light" ) {
            controlContainer.currentIndex = 2
            navTabs.currentIndex = 2
            platformInterface.set_sensor_type.update("light")

        }
        else if(sensor_type_notification === "temp") {
            controlContainer.currentIndex = 3
            navTabs.currentIndex = 3
            platformInterface.set_sensor_type.update("temp")
        }
        else if(sensor_type_notification === "touch_register") {
            controlContainer.currentIndex = 4
            navTabs.currentIndex = 4
            platformInterface.set_sensor_type.update("touch_register")


        }
        //        else if(sensor_type_notification === "unknown_state") {
        //            unknownPopup.open()
        //            unknownPopupHeading = "Unknown Sensor State"
        //            unknownPopupMessage = "A previous Strata session configured this sensor without power cycling the sensor to reset it to default register values. The user interface and sensor registers will be out of sync. Please unplug then plug in the USB cable to perform a power on reset of this sensor."
        //        }


        else {
            console.log("undefined tab or invalid")
        }
    }

    property var sensor_defaults_value: platformInterface.sensor_defaults_value.value
    onSensor_defaults_valueChanged: {
        if(sensor_defaults_value === "1") {
            warningPopup.close()
        }
    }


    Popup{
        id: invalidWarningTouchPopup
        width: controlNavigation.width/2
        height: controlNavigation.height/3.5
        anchors.centerIn: parent
        modal: true
        focus: true
        closePolicy: Popup.NoAutoClose
        background: Rectangle{
            id: warningPopupContainer
            width: invalidWarningTouchPopup.width
            height: invalidWarningTouchPopup.height
            color: "#dcdcdc"
            border.color: "grey"
            border.width: 2
            radius: 10
        }

        Rectangle {
            id: invalidwarningBox
            color: "red"
            anchors {
                top: parent.top
                topMargin: 15
                horizontalCenter: parent.horizontalCenter
            }
            width: (parent.width)/1.6
            height: parent.height/5
            Text {
                id: invalidwarningText
                anchors.centerIn: parent
                text: "<b>Sensor Configuration Failed</b>"
                font.pixelSize: (parent.width + parent.height)/32
                color: "white"
            }

            Text {
                id: warningIcon1
                anchors {
                    right: invalidwarningText.left
                    verticalCenter: invalidwarningText.verticalCenter
                    rightMargin: 10
                }
                text: "\ue80e"
                font.family: Fonts.sgicons
                font.pixelSize: (parent.width + parent.height)/ 15
                color: "white"
            }
            Text {
                id: warningIcon2
                anchors {
                    left: invalidwarningText.right
                    verticalCenter: invalidwarningText.verticalCenter
                    leftMargin: 10
                }
                text: "\ue80e"
                font.family: Fonts.sgicons
                font.pixelSize: (parent.width + parent.height)/ 15
                color: "white"
            }
        }
        Rectangle {
            id: warningPopupBox
            color: "transparent"
            anchors {
                top: invalidwarningBox.bottom
                topMargin: 5
                horizontalCenter: parent.horizontalCenter
            }
            width: warningPopupContainer.width - 50
            height: warningPopupContainer.height - 50

            Rectangle {
                id: messageContainerForPopup
                anchors {
                    top: parent.top
                    topMargin: 10
                    horizontalCenter: parent.horizontalCenter
                }
                color: "transparent"
                width: parent.width
                height:  parent.height - selectionContainerForPopup2.height - invalidwarningBox.height - 50
                Text {
                    id: warningTextForPopup
                    anchors.fill:parent
                    text:  "Sensor configuration has failed. Please perform a hardware reset."
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    fontSizeMode: Text.Fit
                    width: parent.width
                    font.family: "Helvetica Neue"
                    font.pixelSize: ratioCalc * 15
                }
            }



            Rectangle {
                id: selectionContainerForPopup2
                width: parent.width/2
                height: parent.height/4
                anchors{
                    top: messageContainerForPopup.bottom
                    topMargin: 50
                    centerIn: parent
                }
                color: "transparent"
                SGButton {
                    width: parent.width/2
                    height:parent.height
                    anchors.centerIn: parent
                    text: "Hardware Reset"
                    color: checked ? "white" : pressed ? "#cfcfcf": hovered ? "#eee" : "white"
                    roundedLeft: true
                    roundedRight: true

                    onClicked: {
                        invalidWarningTouchPopup.close()
                        warningPopup.open()
                        popupMessage = "Performing Hardware Reset"
                        platformInterface.touch_reset.update()
                    }
                }
            }
        }
    }

    Popup{
        id: unknownPopup
        width: controlNavigation.width/2
        height: controlNavigation.height/3.5
        anchors.centerIn: parent
        modal: true
        focus: true
        closePolicy: Popup.NoAutoClose
        background: Rectangle{
            id: warningPopupContainer2
            width: unknownPopup.width
            height: unknownPopup.height
            color: "#dcdcdc"
            border.color: "grey"
            border.width: 2
            radius: 10
        }


        Rectangle {
            id: unknownwarningBox
            color: "red"
            anchors {
                top: parent.top
                topMargin: 15
                horizontalCenter: parent.horizontalCenter
            }
            width: (parent.width)/1.6
            height: parent.height/5
            Text {
                id: unknownwarningText
                anchors.centerIn: parent
                text: unknownPopupHeading
                font.pixelSize: (parent.width + parent.height)/32
                color: "white"
                font.bold: true
            }

            Text {
                id: unknownWarningIcon1
                anchors {
                    right: unknownwarningText.left
                    verticalCenter: unknownwarningText.verticalCenter
                    rightMargin: 10
                }
                text: "\ue80e"
                font.family: Fonts.sgicons
                font.pixelSize: (parent.width + parent.height)/ 15
                color: "white"
            }
            Text {
                id: unknownWarningIcon2
                anchors {
                    left: unknownwarningText.right
                    verticalCenter: unknownwarningText.verticalCenter
                    leftMargin: 10
                }
                text: "\ue80e"
                font.family: Fonts.sgicons
                font.pixelSize: (parent.width + parent.height)/ 15
                color: "white"
            }
        }
        Rectangle {
            id: warningPopupBox2
            color: "transparent"
            anchors {
                top: unknownwarningBox.bottom
                topMargin: 5
                horizontalCenter: parent.horizontalCenter
            }
            width: warningPopupContainer2.width - 50
            height: warningPopupContainer2.height/1.5

            Rectangle {
                id: messageContainerForPopup2
                anchors {
                    top: parent.top
                    topMargin: 10
                    centerIn:  parent.Center
                }
                color: "transparent"
                width: parent.width
                height:  parent.height - unknownwarningBox.height - 10
                Text {
                    id: warningTextForPopup2
                    anchors.fill:parent
                    text: unknownPopupMessage
                    verticalAlignment:  Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    fontSizeMode: Text.Fit
                    width: parent.width
                    font.family: "Helvetica Neue"
                    font.pixelSize: ratioCalc * 15
                }
            }
        }
    }

    //property var reset_notification: platformInterface.reset_touch_mode.status


    Component.onCompleted: {
        platformInterface.set_sensor_type.update("get")
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
                warningPopup.open()
                popupMessage = "Performing Sensor Configuration"
                platformInterface.set_sensor_type.update("touch")

            }
        }

        TabButton {
            id: proximityButton
            text: qsTr("Proximity")
            onClicked: {
                controlContainer.currentIndex = 1
                warningPopup.open()
                popupMessage = "Performing Sensor Configuration"
                platformInterface.set_sensor_type.update("proximity")

            }
        }

        TabButton {
            id: lightButton
            text: qsTr("Light")
            onClicked: {
                controlContainer.currentIndex = 2
                platformInterface.set_sensor_type.update("light")
                warningPopup.open()
                popupMessage = "Performing Sensor Configuration"
            }
        }

        TabButton {
            id: temperatureButton
            text: qsTr("Temperature")
            onClicked: {
                controlContainer.currentIndex = 3
                platformInterface.set_sensor_type.update("temp")
                warningPopup.open()
                popupMessage = "Performing Sensor Configuration"

            }
        }
        TabButton {
            id: lcButton
            text: qsTr("LC717A10AR")
            onClicked: {
                controlContainer.currentIndex = 4
                warningPopup.open()
                popupMessage = "Performing Sensor Configuration"
                platformInterface.set_sensor_type.update("touch_register")
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

        AdvanceView {
            id: advanceview
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
