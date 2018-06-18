import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
//import tech.spyglass. 1.0
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/views/motor-vortex/sgwidgets"

Rectangle {
    id: controlPage
    objectName: "control"
    anchors { fill: parent }
    // used to check whether the motor slider has been already updated from platform notification
    property bool isMotorSliderUpdated: false;
    color: "white"

    // Platform Implementation signals
    Connections {
        target: coreInterface
        onNotification: {
            /*
                Motor vortex has a known issue by sending non-ascii charactors in json object
                The following code is a hack.
                See the bad JSON example below. The non asci charactor can show up in the key of the object or the value.
                That's the reason there is a validation for object's key and value.
                {
                    "notification":{
                        "value":"pi_stats",
                        "payf���load":{
                            "speed_target":1500,
                            "current_speed":15f�20,
                            "error":-20,
                            "sum":-4.00e-4,
                            "duty_now":0.19,
                            "mode":"manual"
                      }
                }
            */

            try {
                /*
                    Attempt to parse JSON
                    Note: Motor platform sometimes has noise in json and can corrupt values
                */
                var notification = JSON.parse(payload)

                //check if the object has valid payload key
                if(notification.hasOwnProperty("payload")){
                    var notificationPayload = notification.payload;

                    //check if current_speed exists in the payload object. skip if corrupted.
                    if(notificationPayload.hasOwnProperty("current_speed")){
                        var current_speed = notification.payload.current_speed;

                        //check if speed is a valid integer
                        if(Number.isInteger(current_speed)){
                            tachMeterGauge.value = current_speed

                            // just making sure the the slider is being set only once when the
                            // platform send its current speed
                            // Then the user will start controlling it. Hence there is no need to keep updating the slider
                            // based on the platfrom notification's value
                            if(!isMotorSliderUpdated){
                                //set value only once and must be float from 1500 to 5500
                                motorSpeedControl.value =current_speed
                                isMotorSliderUpdated = !isMotorSliderUpdated
                            }

                        }else{
                            console.log("Motor Platfrom Notification Error. Junk data found on current_speed ", current_speed)
                        }
                    }else {
                        console.log("Motor Platfrom Notification Error. Can't find current_speed in payload object")
                    }

                    //check if mode exists in the payload object. skip if corrupted.
                    if(notificationPayload.hasOwnProperty("mode")){
                        //mode either set to be a manual or automation
                        var systemMode = notification.payload.mode;
                        if(systemMode ==="manual"){
                            manualButton.checked = true;
                            automaticButton.checked = false;
                        }else if(systemMode ==="automation") {
                            manualButton.checked = false;
                            automaticButton.checked = true;
                        }else{
                            console.log("Motor Platfrom Notification Error. Junk data found on mode")
                        }
                    }else{
                        console.log("Motor Platfrom Notification Error. can't find mode in payload object")
                    }

                }else{
                    console.log("Motor Platfrom Notification Error. payload is corrupted")
                }
            }
            catch(e)
            {
                if ( e instanceof SyntaxError){
                    console.log("Motor Platfrom Notification Error. Notification JSON is invalid, ignoring")
                }
            }

        }
    }
    // Control Section
    Rectangle {
        id: controlSection1
        width: parent.width-100
        height: parent.height / 2
        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            id: leftControl
            anchors {
                left: parent.left
                top: parent.top
            }
            width: parent.width / 2
            height: parent.height

            SGCircularGauge {
                id: tachMeterGauge
                anchors {
                    fill: parent
                }
                minimumValue: motorSpeedControl.minimumValue
                maximumValue: motorSpeedControl.maximumValue
                value: 1500
                tickmarkStepSize: 500

                Behavior on value { NumberAnimation { duration: 300 } }
            }
        }

        Rectangle {
            id: rightControl
            anchors {
                left: leftControl.right
                verticalCenter: leftControl.verticalCenter
            }
            width: parent.width / 2
            height: motorSpeedControl.height + operationModeControl.height + 40

            SGSlider {
                id: motorSpeedControl
                width: parent.width * 0.75
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                label: "<b>Motor Speed:</b>"
                labelLeft: false
                value: 1500
                minimumValue: 1500
                maximumValue: 5500
                startLabel: minimumValue
                endLabel: maximumValue

                function setMotorSpeedCommand(value) {
                    var truncated_value = Math.floor(value)
                    var setSpeedCmd ={
                        "cmd":"speed_input",
                        "payload": {
                            "speed_target":truncated_value
                        }
                    }
                    // send set speed command to platform
                    console.log ("set speed_target", truncated_value)
                    coreInterface.sendCommand(JSON.stringify(setSpeedCmd))
                }

                onValueChanged: {
                    setMotorSpeedCommand(value)
                }
            }

            SGRadioButton {
                id: operationModeControl
                model: radioModel
                anchors {
                    top: motorSpeedControl.bottom
                    topMargin: 40
                    left: motorSpeedControl.left
                }
                orientation: Qt.Horizontal
                label: "<b>Operation Mode:</b>"
                labelLeft: false

                onButtonSelected: {
                    var systemModeCmd
                    if (selected === "Manual Control"){
                        console.log("MANUAL CONTROL")
                         systemModeCmd ={
                            "cmd":"set_system_mode",
                            "payload": {
                                "system_mode":"manual"
                            }
                        }
                    } else if (selected === "Automatic Test Pattern"){
                        console.log("AUTOMATIC")
                        systemModeCmd ={
                            "cmd":"set_system_mode",
                            "payload": {
                                "system_mode":"automation"
                            }
                        }
                    }
                    // send command to platform
                    coreInterface.sendCommand(JSON.stringify(systemModeCmd))
                }

                ListModel {
                    id: radioModel

                    ListElement {
                        name: "Manual Control"
                        checked: true               // One element pre-checked when exclusive
                    }

                    ListElement {
                        name: "Automatic Test Pattern"
                    }
                }
            }


        }
    } // end Control Section Rectangle
}

