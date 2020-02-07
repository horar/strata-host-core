import QtQuick 2.12
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as SGWidgets09

Item {
    id: root
    height: 275
    width: parent.width
    anchors {
        left: parent.left
    }

    Item {
        id: leftColumn
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width/3

        Item {
            id: margins1
            anchors {
                fill: parent
                margins: 15
            }



            Text {
                id: faultText
                text: "<b>Faults</b>"
                font {
                    pixelSize: 16
                }
                anchors {
                    top: margins1.top
                    topMargin: 30
                }
            }

            SGWidgets09.SGSegmentedButtonStrip {
                id: faultProtection
                anchors {
                    top: faultText.bottom
                    topMargin: 10
                    left: margins1.left
                    leftMargin: 85
                    right: margins1.right
                    rightMargin: 10
                }
                label: "Fault Protection:"
                textColor: "#222"
                activeTextColor: "white"
                radius: 4
                buttonHeight: 25
                buttonImplicitWidth:0
                hoverEnabled: false

                segmentedButtons: GridLayout {
                    columnSpacing: 2


                    SGWidgets09.SGSegmentedButton{
                        text: qsTr("Retry")
                        checked: platformInterface.usb_pd_protection_action.action === "retry"

                        onClicked: {
                            platformInterface.set_protection_action.update("retry");
                        }
                    }

                    SGWidgets09.SGSegmentedButton{
                        text: qsTr("None")
                        checked: platformInterface.usb_pd_protection_action.action === "nothing"

                        onClicked: {
                            platformInterface.set_protection_action.update("nothing");
                        }
                    }
                }
            }


            Text{
                id:inputFaultLabel
                anchors.right: inputFault.left
                anchors.rightMargin: 5
                anchors.verticalCenter: inputFault.verticalCenter
                anchors.verticalCenterOffset: -8
                horizontalAlignment: Text.AlignRight
                text: "Fault when input below:"
            }

            SGSlider {
                id: inputFault
                anchors {
                    left: margins1.left
                    leftMargin: 190
                    top: faultProtection.bottom
                    topMargin: 15
                    right: margins1.right
                    rightMargin: 0
                }
                from: 5
                to: 20
                fromText.fontSizeMultiplier:.75
                toText.fontSizeMultiplier: .75
                fromText.text: "5V"
                toText.text: "20V"
                handleSize:20
                fillColor:"dimgrey"
                value: platformInterface.input_under_voltage_notification.minimum_voltage
                onMoved: {
                    platformInterface.set_minimum_input_voltage.update(value);
                }
            }

            Text{
                id:tempFaultLabel
                anchors.right: tempFault.left
                anchors.rightMargin: 5
                anchors.verticalCenter: tempFault.verticalCenter
                anchors.verticalCenterOffset: -8
                horizontalAlignment: Text.AlignRight
                text:"Fault when temperature above:"
            }

            SGSlider {
                id: tempFault
                anchors {
                    left: margins1.left
                    leftMargin: 190
                    top: inputFault.bottom
                    topMargin: 10
                    right: margins1.right
                    rightMargin: 0
                }
                from: 20
                to: 100
                fillColor:"dimgrey"
                handleSize:20
                fromText.fontSizeMultiplier:.75
                toText.fontSizeMultiplier: .75
                fromText.text: "20 °C"
                toText.text: "100 °C"
                value: platformInterface.set_maximum_temperature_notification.maximum_temperature
                onMoved: {
                    platformInterface.set_maximum_temperature.update(value);
                }
            }

            Text{
                id:hysteresisLabel
                anchors.right: hysteresisSlider.left
                anchors.rightMargin: 5
                anchors.verticalCenter: hysteresisSlider.verticalCenter
                anchors.verticalCenterOffset: -8
                horizontalAlignment: Text.AlignRight
                text:"Reset when temperature drops:"
            }

            SGSlider {
                id: hysteresisSlider
                anchors {
                    left: margins1.left
                    leftMargin: 190
                    top: tempFault.bottom
                    topMargin: 10
                    right: margins1.right
                    rightMargin: 0
                }
                from: 5
                to: 50
                stepSize:5
                fillColor:"dimgrey"
                handleSize:20
                fromText.fontSizeMultiplier:.75
                toText.fontSizeMultiplier: .75
                fromText.text: "5 °C"
                toText.text: "50 °C"
                value: platformInterface.temperature_hysteresis.value
                onMoved: {
                    platformInterface.set_temperature_hysteresis.update(value);
                }
            }

        }

        SGWidgets09.SGLayoutDivider {
            position: "right"
        }
    }

    Item {
        id: middleColumn
        anchors {
            left: leftColumn.right
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width/3


        Item {
            id: margins2
            anchors {
                fill: parent
                margins: 15
            }

            Text {
                id: inputFoldback
                text: "<b>Input Foldback</b>"
                font {
                    pixelSize: 16
                }
            }

            SGSwitch {
                id: inputFoldbackSwitch
                anchors {
                    right: parent.right
                    verticalCenter: inputFoldback.verticalCenter
                }
                checkedLabel: "On"
                uncheckedLabel: "Off"
                height: 20
                width: 46
                grooveFillColor:"green"
                checked: platformInterface.foldback_input_voltage_limiting_event.input_voltage_foldback_enabled
                onToggled: platformInterface.set_input_voltage_foldback.update(checked, platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage,
                                platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage_power)
            }

            Text{
                id:foldbackLimitLabel
                anchors.right: foldbackLimit.left
                anchors.rightMargin: 5
                anchors.verticalCenter: foldbackLimit.verticalCenter
                anchors.verticalCenterOffset: -8
                horizontalAlignment: Text.AlignRight
                text:"Limit below:"
            }

            SGSlider {
                id: foldbackLimit
                value: platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage
                anchors {
                    left: parent.left
                    leftMargin: 135
                    top: inputFoldback.bottom
                    topMargin: 13
                    right: margins2.right
                    rightMargin: 0
                }
                from: 5
                to: 20
                fromText.fontSizeMultiplier:.75
                toText.fontSizeMultiplier: .75
                fromText.text: "5V"
                toText.text: "20V"
                handleSize:20
                fillColor:"dimgrey"
                //copy the current values for other stuff, and add the new slider value for the limit.
                onMoved: platformInterface.set_input_voltage_foldback.update(platformInterface.foldback_input_voltage_limiting_event.input_voltage_foldback_enabled,
                                 value,
                                platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage_power)
            }


            Text{
                id:limitOutputLabel
                anchors.right: limitOutput.left
                anchors.rightMargin: 5
                anchors.verticalCenter: limitOutput.verticalCenter
                horizontalAlignment: Text.AlignRight
                text:"Limit output power to:"
            }

            SGComboBox {
                id: limitOutput
                model: ["7.5","15.0","22.5", "30.0", "37.5","45.0","52.5","60.0"]
                anchors {
                    left: parent.left
                    leftMargin: 135
                    top: foldbackLimit.bottom
                    topMargin: 10
                }
                width: 70
                //when changing the value
                onActivated: {
                    console.log("setting input power foldback to ",limitOutput.comboBox.currentText);
                    platformInterface.set_input_voltage_foldback.update(platformInterface.foldback_input_voltage_limiting_event.input_voltage_foldback_enabled,
                                                                        platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage,
                                                                                 limitOutput.comboBox.currentText)
                }

                property var currentFoldbackOuput: platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage_power
                onCurrentFoldbackOuputChanged: {
                    console.log("got a new min power setting",platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage_power);
                    limitOutput.currentIndex = limitOutput.find( (platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage_power).toFixed(1))
                }
            }
            Text{
                id: foldbackTempUnits
                text: "W"
                anchors {
                    left: limitOutput.right
                    leftMargin: 5
                    verticalCenter: limitOutput.verticalCenter
                    verticalCenterOffset: 0
                }
            }

            SGWidgets09.SGDivider {
                id: div1
                anchors {
                    top: limitOutput.bottom
                    topMargin: 15
                }
            }

            Text {
                id: tempFoldback
                text: "<b>Temperature Foldback</b>"
                font {
                    pixelSize: 16
                }
                anchors {
                    top: div1.bottom
                    topMargin: 15
                }
            }

            SGSwitch {
                id: tempFoldbackSwitch
                anchors {
                    right: parent.right
                    verticalCenter: tempFoldback.verticalCenter
                }
                checkedLabel: "On"
                uncheckedLabel: "Off"
                height: 20
                width: 46
                grooveFillColor:"green"
                checked: platformInterface.foldback_temperature_limiting_event.temperature_foldback_enabled
                onToggled:{
                    console.log("sending temp foldback update command from tempFoldbackSwitch");
                    platformInterface.set_temperature_foldback.update(tempFoldbackSwitch.checked,
                                                                                    platformInterface.foldback_temperature_limiting_event.foldback_maximum_temperature,
                                                                                    platformInterface.foldback_temperature_limiting_event.foldback_maximum_temperature_power);
                }
            }

            Text{
                id:foldbackTempLabel
                anchors.right: foldbackTemp.left
                anchors.rightMargin: 5
                anchors.verticalCenter: foldbackTemp.verticalCenter
                anchors.verticalCenterOffset: -8
                text:"Limit above:"
            }

            SGSlider {
                id: foldbackTemp
                anchors {
                    left: parent.left
                    leftMargin: 135
                    top: tempFoldback.bottom
                    topMargin: 15
                    right: parent.right
                    rightMargin: 0
                }
                from: 20
                to: 100
                fromText.fontSizeMultiplier:.75
                toText.fontSizeMultiplier: .75
                fromText.text: "20°C"
                toText.text: "100°C"
                fillColor:"dimgrey"
                handleSize: 20
                value: platformInterface.foldback_temperature_limiting_event.foldback_maximum_temperature
                //value: platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage
               onValueChanged: {
                    console.log("foldback max temp is now:",value)
               }
                onMoved:{
                    console.log("sending temp foldback update command from foldbackTempSlider");
                    platformInterface.set_temperature_foldback.update(platformInterface.foldback_temperature_limiting_event.temperature_foldback_enabled,
                                                                                  foldbackTemp.value,
                                                                                  platformInterface.foldback_temperature_limiting_event.foldback_maximum_temperature_power)
                }

            }


            Text{
                id:limitOutput2Label
                anchors.right: limitOutput2.left
                anchors.rightMargin: 5
                anchors.verticalCenter: limitOutput2.verticalCenter
                text:"Limit output power to:"
            }

            SGComboBox {
                id: limitOutput2
                model: ["7.5","15.0","22.5", "30.0", "37.5","45.0","52.5","60.0"]
                anchors {
                    left: parent.left
                    leftMargin: 135
                    top: foldbackTemp.bottom
                    topMargin: 10
                }
                width: 70
                //when the value is changed by the user
                onActivated: {
                    console.log("sending temp foldback update command from limitOutputComboBox");
                    platformInterface.set_temperature_foldback.update(platformInterface.foldback_temperature_limiting_event.temperature_foldback_enabled,
                                                                                 platformInterface.foldback_temperature_limiting_event.foldback_maximum_temperature,
                                                                                 limitOutput2.currentText)
                }

                property var currentFoldbackOuput: platformInterface.foldback_temperature_limiting_event.foldback_maximum_temperature_power

                onCurrentFoldbackOuputChanged: {
                    limitOutput2.currentIndex = limitOutput2.find( (platformInterface.foldback_temperature_limiting_event.foldback_maximum_temperature_power).toFixed(1))
                }
            }

            Text{
                id: foldbackTempUnits2
                text: "W"
                anchors {
                    left: limitOutput2.right
                    leftMargin: 5
                    verticalCenter: limitOutput2.verticalCenter
                }
            }
        }
}

    Item{
        id: rightColumn
        anchors {
            right: root.right
            top: root.top
            bottom: root.bottom
        }
        width: root.width/3

        SGStatusLogBox {
            id: currentFaults
            height: rightColumn.height/2
            width: rightColumn.width
            title: "Active Faults:"
            model: faultListModel

            property var underVoltageEvent: platformInterface.input_under_voltage_notification
            property var overTempEvent: platformInterface.over_temperature_notification
            property string stateMessage:""

            onUnderVoltageEventChanged: {
                if (underVoltageEvent.state === "below"){   //add input voltage message to list
                    stateMessage = "Input is below ";
                    stateMessage += platformInterface.input_under_voltage_notification.minimum_voltage;
                    stateMessage += " V";
                    //if there's already an input voltage fault in the list, remove it (there can only be one at a time)
                    for(var i = 0; i < faultListModel.count; ++i){
                        var theItem = faultListModel.get(i);
                        if (theItem.type === "voltage"){
                            faultListModel.remove(i);
                        }
                    }
                    //console.log("over voltage event:",stateMessage)
                    faultListModel.append({"type":"voltage", "portName":"0", "message":stateMessage});

                }
                else{                                       //remove input voltage message from list
                    for(var j = 0; j < faultListModel.count; ++j){
                        var theListItem = faultListModel.get(j);
                        if (theListItem.type === "voltage"){
                            faultListModel.remove(j);
                        }
                    }
                }
            }

            onOverTempEventChanged: {
                if (overTempEvent.state === "above"){   //add temp  message to list
                    stateMessage = platformInterface.over_temperature_notification.port
                    stateMessage += " temperature is above ";
                    stateMessage += platformInterface.over_temperature_notification.maximum_temperature;
                    stateMessage += " °C";
                    //console.log("over temp event:",stateMessage)
                    faultListModel.append({"type":"temperature", "portName":platformInterface.over_temperature_notification.port, "message":stateMessage});
                }
                else{                                       //remove temp message for the correct port from list
                    for(var i = 0; i < faultListModel.count; ++i){
                        var theItem = faultListModel.get(i);
                        if (theItem.type === "temperature" && theItem.portName === platformInterface.over_temperature_notification.port){
                            faultListModel.remove(i);
                        }
                    }
                }
            }

            ListModel{
                id:faultListModel
            }
        }



        SGStatusLogBox {
            id: faultHistory
            height: rightColumn.height/2
            anchors {
                top: currentFaults.bottom
            }
            width: rightColumn.width
            title: "Fault History:"

            property var underVoltageEvent: platformInterface.input_under_voltage_notification
            property var overTempEvent: platformInterface.over_temperature_notification
            property string stateMessage:""

            onUnderVoltageEventChanged: {
                if (underVoltageEvent.state === "below"){   //add input voltage message to list
                    stateMessage = "Input is below ";
                    stateMessage += platformInterface.input_under_voltage_notification.minimum_voltage;
                    stateMessage += " V";
                    //console.log("adding message to fault history",stateMessage);
                    faultHistory.append(stateMessage);

                }
                else{
//                    stateMessage = "Input voltage fault ended at ";
//                    stateMessage += platformInterface.input_under_voltage_notification.minimum_voltage;
//                    stateMessage += " V";
//                    faultHistory.input = stateMessage;
                }
            }

            onOverTempEventChanged: {
                if (overTempEvent.state === "above"){   //add temp  message to list
                    stateMessage = platformInterface.over_temperature_notification.port
                    stateMessage += " temperature is above ";
                    stateMessage += platformInterface.over_temperature_notification.maximum_temperature;
                    stateMessage += " °C";
                    faultHistory.append(stateMessage);
                }
                else{
//                    stateMessage = platformInterface.over_temperature_notification.port
//                    stateMessage += " temperature went below ";
//                    stateMessage += platformInterface.over_temperature_notification.maximum_temperature;
//                    stateMessage += " °C";
//                    faultHistory.input = stateMessage;
                }


            }
        }
    }
}
