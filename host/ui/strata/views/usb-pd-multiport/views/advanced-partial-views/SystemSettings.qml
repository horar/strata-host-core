import QtQuick 2.9
import QtQuick.Layouts 1.3
import "qrc:/views/usb-pd-multiport/sgwidgets"

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
        width: parent.width/2

        Item {
            id: margins1
            anchors {
                fill: parent
                margins: 15
            }

            SGSlider {
                id: maximumBoardPower
                label: "Maximum Power:"
                anchors {
                    left: margins1.left
                    leftMargin: 72
                    right: maximumBoardPowerInput.left
                    rightMargin: 10
                }
                from: 30
                to: 200
                startLabel: "30W"
                endLabel: "200W"
                value: platformInterface.maximum_board_power.watts
                onMoved: {
                    //we'll need to address how to handle this when there are devices attached, as that would trigger
                    //renegotiation with all devices
                    platformInterface.set_maximum_board_power.update(value);
                }
            }

            SGSubmitInfoBox {
                id: maximumBoardPowerInput
                buttonVisible: false
                anchors {
                    verticalCenter: maximumBoardPower.verticalCenter
                    right: parent.right
                }
                //input: inputFault.value.toFixed(0)
                //onApplied: platformInterface.set_minimum_input_voltage.update(input);   // slider will be updated via notification
            }

            SGSegmentedButtonStrip {
                id: powerNegotiation
                label: "Power Negotiation:"
                activeColor: "#666"
                inactiveColor: "#dddddd"
                textColor: "#666"
                activeTextColor: "white"
                radius: 4
                buttonHeight: 25
                anchors {
                    top: maximumBoardPower.bottom
                    topMargin: 10
                    left: margins1.left
                    leftMargin: 75
                }

                segmentedButtons: GridLayout {
                    columnSpacing: 2

                    property var negotiationTypeChanged: platformInterface.power_negotiation.negotiation_type

                    onNegotiationTypeChangedChanged:{
                        if (platformInterface.power_negotiation.negotiation_type === "dynamic"){
                            dynamicNegotiationButton.checked = true;
                            fcfsNegotiationButton.checked = false;
                            priorityNegotiationButton.checked = false;
                        }
                        else if (platformInterface.power_negotiation.negotiation_type === "first_come_first_served"){
                            dynamicNegotiationButton.checked = false;
                            fcfsNegotiationButton.checked = true;
                            priorityNegotiationButton.checked = false;
                        }
                        else if (platformInterface.power_negotiation.negotiation_type === "priority"){
                            dynamicNegotiationButton.checked = false;
                            fcfsNegotiationButton.checked = false;
                            priorityNegotiationButton.checked = true;
                        }


                    }

                    SGSegmentedButton{
                        id:dynamicNegotiationButton
                        text: qsTr("Dynamic")
                        checked: true  // Sets default checked button when exclusive
                        onClicked: {
                            platformInterface.set_power_negotiation.update("dynamic");
                        }
                    }

                    SGSegmentedButton{
                        id:fcfsNegotiationButton
                        text: qsTr("FCFS")
                        onClicked: {
                            platformInterface.set_power_negotiation.update("first_come_first_served");
                        }
                    }

                    SGSegmentedButton{
                        id:priorityNegotiationButton
                        text: qsTr("Priority")
                        onClicked: {
                            platformInterface.set_power_negotiation.update("priority");
                        }
                    }
                }
            }

            SGDivider {
                id: leftDiv1
                anchors {
                    top: powerNegotiation.bottom
                    topMargin: 10
                }
            }

            SGSegmentedButtonStrip {
                id: sleepMode
                label: "Sleep Mode:"
                activeTextColor: "white"
                textColor: "#666"
                radius: 4
                buttonHeight: 25
                anchors {
                    top: leftDiv1.bottom
                    topMargin: 10
                    left: margins1.left
                    leftMargin: 20
                }



                segmentedButtons: GridLayout {
                    columnSpacing: 2

                    property var sleepMode: platformInterface.sleep_mode.mode

                    onSleepModeChanged:{
                        if (platformInterface.sleep_mode.mode === "manual"){
                            manualSleepModeButton.checked = true;
                            automaticSleepModeButton.checked = false;
                        }
                        else if (platformInterface.sleep_mode.mode === "automatic"){
                            manualSleepModeButton.checked = false;
                            automaticSleepModeButton.checked = true;
                        }
                    }

                    SGSegmentedButton{
                        id:manualSleepModeButton
                        text: qsTr("Manual")
                        checked: true  // Sets default checked button when exclusive

                        onClicked: {
                            platformInterface.set_sleep_mode.update("manual");
                        }
                    }

                    SGSegmentedButton{
                        id:automaticSleepModeButton
                        text: qsTr("Automatic")
                        onCheckedChanged: {
                            if (checked) {
                                manualSleep.enabled = false
                            } else {
                                manualSleep.enabled = true
                            }

                        }

                        onClicked: {
                            platformInterface.set_sleep_mode.update("automatic");
                        }
                    }
                }
            }

            SGSegmentedButtonStrip {
                id: manualSleep
                label: "Manual Sleep:"
                textColor: "#666"
                activeTextColor: "white"
                radius: 4
                buttonHeight: 25
                anchors {
                    top: sleepMode.top
                    left: sleepMode.right
                    leftMargin: 50
                }

                segmentedButtons: GridLayout {
                    columnSpacing: 2

                    property var manualSleepMode: platformInterface.manual_sleep_mode.mode

                    onManualSleepModeChanged:{
                        if (platformInterface.manual_sleep_mode.mode ==="on"){
                            manualSleepOnButton.checked = true;
                            manualSleepOffButton.checked = false;
                        }
                        else if (platformInterface.manual_sleep_mode.mode ==="off"){
                            manualSleepOnButton.checked = false;
                            manualSleepOffButton.checked = true;
                        }
                    }

                    SGSegmentedButton{
                        id:manualSleepOnButton
                        text: qsTr("ON")
                        checked: true  // Sets default checked button when exclusive

                        onClicked: {
                            platformInterface.set_manual_sleep_mode.update("on");
                        }
                    }

                    SGSegmentedButton{
                        id:manualSleepOffButton
                        text: qsTr("OFF")

                        onClicked: {
                            platformInterface.set_manual_sleep_mode.update("off");
                        }
                    }
                }
            }

            SGDivider {
                id: leftDiv2
                anchors {
                    top: sleepMode.bottom
                    topMargin: 10
                }
            }

            SGSegmentedButtonStrip {
                id: faultProtection
                anchors {
                    top: leftDiv2.bottom
                    topMargin: 10
                    left: margins1.left
                    leftMargin: 89
                }
                label: "Fault Protection:"
                textColor: "#666"
                activeTextColor: "white"
                radius: 4
                buttonHeight: 25

                segmentedButtons: GridLayout {
                    columnSpacing: 2

                    SGSegmentedButton{
                        text: qsTr("Shutdown")
                        checked: platformInterface.usb_pd_protection_action.action === "shutdown"

                        onClicked: {
                            platformInterface.set_protection_action.update("shutdown");
                        }
                    }

                    SGSegmentedButton{
                        text: qsTr("Retry")
                        checked: platformInterface.usb_pd_protection_action.action === "retry"

                        onClicked: {
                            platformInterface.set_protection_action.update("retry");
                        }
                    }

                    SGSegmentedButton{
                        text: qsTr("None")
                        checked: platformInterface.usb_pd_protection_action.action === "nothing"

                        onClicked: {
                            platformInterface.set_protection_action.update("nothing");
                        }
                    }
                }
            }

            SGSlider {
                id: inputFault
                label: "Fault when input below:"
                anchors {
                    left: margins1.left
                    leftMargin: 45
                    top: faultProtection.bottom
                    topMargin: 10
                    right: inputFaultInput.left
                    rightMargin: 10
                }
                from: 0
                to: 20
                startLabel: "0V"
                endLabel: "20V"
                value: platformInterface.input_under_voltage_notification.minimum_voltage
                onMoved: {
                    platformInterface.set_minimum_input_voltage.update(value);
                }
            }

            SGSubmitInfoBox {
                id: inputFaultInput
                buttonVisible: false
                anchors {
                    verticalCenter: inputFault.verticalCenter
                    right: parent.right
                }
                input: inputFault.value.toFixed(0)
                onApplied: platformInterface.set_minimum_input_voltage.update(input);   // slider will be updated via notification
            }

            SGSlider {
                id: tempFault
                label: "Fault when temperature above:"
                anchors {
                    left: parent.left
                    top: inputFault.bottom
                    topMargin: 10
                    right: tempFaultInput.left
                    rightMargin: 10
                }
                from: -64
                to: 191
                startLabel: "-64°C"
                endLabel: "191°C"
                value: platformInterface.set_maximum_temperature_notification.maximum_temperature
                onMoved: {
                    platformInterface.set_maximum_temperature.update(value);
                }
            }

            SGSubmitInfoBox {
                id: tempFaultInput
                buttonVisible: false
                anchors {
                    verticalCenter: tempFault.verticalCenter
                    right: parent.right
                }
                input: tempFault.value.toFixed(0)
                onApplied: platformInterface.set_maximum_temperature.update(input); // slider will be updated via notification
            }
        }

        SGLayoutDivider {
            position: "right"
        }
    }

    Item {
        id: rightColumn
        anchors {
            left: leftColumn.right
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }


        Item {
            id: margins2
            anchors {
                fill: parent
                margins: 15
            }

            Text {
                id: inputFoldback
                text: "<b>Input Foldback:</b>"
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
                switchHeight: 20
                switchWidth: 46
                checked: platformInterface.foldback_input_voltage_limiting_event.input_voltage_foldback_enabled
                onToggled: platformInterface.set_input_voltage_foldback.update(checked, platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage,
                                platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage_power)
            }

            SGSlider {
                id: foldbackLimit
                label: "Limit below:"
                value: platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage
                anchors {
                    left: parent.left
                    leftMargin: 61
                    top: inputFoldback.bottom
                    topMargin: 10
                    right: foldbackLimitInput.left
                    rightMargin: 10
                }
                from: 0
                to: 20
                startLabel: "0V"
                endLabel: "20V"
                //copy the current values for other stuff, and add the new slider value for the limit.
                onMoved: platformInterface.set_input_voltage_foldback.update(platformInterface.foldback_input_voltage_limiting_event.input_voltage_foldback_enabled,
                                 value,
                                platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage_power)
            }

            SGSubmitInfoBox {
                id: foldbackLimitInput
                buttonVisible: false
                anchors {
                    verticalCenter: foldbackLimit.verticalCenter
                    right: parent.right
                }
                input: foldbackLimit.value.toFixed(0)
                onApplied: platformInterface.set_input_voltage_foldback.update(platformInterface.foldback_input_voltage_limiting_event.input_voltage_foldback_enabled,
                                                                               input,
                                                                              platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage_power)
            }

            SGComboBox {
                id: limitOutput
                label: "Limit output power to:"
                model: ["15","27", "36", "45","60","100"]
                anchors {
                    left: parent.left
                    top: foldbackLimit.bottom
                    topMargin: 10
                }
                //when changing the value
                onActivated: {
                    console.log("setting input power foldback to ",limitOutput.comboBox.currentText);
                    platformInterface.set_input_voltage_foldback.update(platformInterface.foldback_input_voltage_limiting_event.input_voltage_foldback_enabled,
                                                                        platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage,
                                                                                 limitOutput.comboBox.currentText)
                }

                property var currentFoldbackOuput: platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage_power
                onCurrentFoldbackOuputChanged: {
                    //console.log("got a new min power setting",platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage_power);
                    limitOutput.currentIndex = limitOutput.comboBox.find( parseInt (platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage_power))
                }


            }

            SGDivider {
                id: div1
                anchors {
                    top: limitOutput.bottom
                    topMargin: 15
                }
            }

            Text {
                id: tempFoldback
                text: "<b>Temperature Foldback:</b>"
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
                switchHeight: 20
                switchWidth: 46
                checked: platformInterface.foldback_temperature_limiting_event.temperature_foldback_enabled
                onToggled:{
                    console.log("sending temp foldback update command from tempFoldbackSwitch");
                    platformInterface.set_temperature_foldback.update(tempFoldbackSwitch.checked,
                                                                                    platformInterface.foldback_temperature_limiting_event.foldback_maximum_temperature,
                                                                                    platformInterface.foldback_temperature_limiting_event.foldback_maximum_temperature_power);
                }
            }

            SGSlider {
                id: foldbackTemp
                label: "Limit above:"
                anchors {
                    left: parent.left
                    leftMargin: 60
                    top: tempFoldback.bottom
                    topMargin: 10
                    right: foldbackTempInput.left
                    rightMargin: 10
                }
                from: 25
                to: 200
                startLabel: "25°C"
                endLabel: "200°C"
                value: platformInterface.foldback_temperature_limiting_event.foldback_maximum_temperature
                onMoved:{
                    console.log("sending temp foldback update command from foldbackTempSlider");
                    platformInterface.set_temperature_foldback.update(platformInterface.foldback_temperature_limiting_event.temperature_foldback_enabled,
                                                                                  foldbackTemp.value,
                                                                                  platformInterface.foldback_temperature_limiting_event.foldback_maximum_temperature_power)
                }

            }

            SGSubmitInfoBox {
                id: foldbackTempInput
                buttonVisible: false
                anchors {
                    verticalCenter: foldbackTemp.verticalCenter
                    right: parent.right
                }
                input: foldbackTemp.value.toFixed(0)
                onApplied: platformInterface.set_temperature_foldback.update(platformInterface.foldback_temperature_limiting_event.temperature_foldback_enabled,
                                                                             input,
                                                                             platformInterface.foldback_temperature_limiting_event.foldback_maximum_temperature_power)
            }

            SGComboBox {
                id: limitOutput2
                label: "Limit output power to:"
                model: ["15","27", "36", "45","60","100"]
                anchors {
                    left: parent.left
                    top: foldbackTemp.bottom
                    topMargin: 10
                }
                //when the value is changed by the user
                onActivated: {
                    console.log("sending temp foldback update command from limitOutputComboBox");
                    platformInterface.set_temperature_foldback.update(platformInterface.foldback_temperature_limiting_event.temperature_foldback_enabled,
                                                                                 platformInterface.foldback_temperature_limiting_event.foldback_maximum_temperature,
                                                                                 limitOutput2.currentText)
                }

                property var currentFoldbackOuput: platformInterface.foldback_temperature_limiting_event.foldback_maximum_temperature_power

                onCurrentFoldbackOuputChanged: {
                    limitOutput2.currentIndex = limitOutput2.comboBox.find( parseInt (platformInterface.foldback_temperature_limiting_event.foldback_maximum_temperature_power))
                }
            }
        }
    }
}
