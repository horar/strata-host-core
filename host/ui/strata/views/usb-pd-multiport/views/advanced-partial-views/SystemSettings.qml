import QtQuick 2.9
import QtQuick.Layouts 1.3
import "qrc:/views/usb-pd-multiport/sgwidgets"

Item {
    id: root
    height: 375
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

            Text {
                id: powerManagement
                text: "<b>Power Management</b>"
                font {
                    pixelSize: 16
                }
            }

            SGSlider {
                id: maximumBoardPower
                label: "Maximum System Power:"
                anchors {
                    top: powerManagement.bottom
                    topMargin: 15
                    left: margins1.left
                    leftMargin: 55
                    right: maximumBoardPowerInput.left
                    rightMargin: 10
                }
                from: 30
                to: platformInterface.ac_power_supply_connection.power
                startLabel: "30W"
                endLabel: platformInterface.ac_power_supply_connection.power+"W"
                labelTopAligned: true
                value: platformInterface.maximum_board_power.watts

                Component.onCompleted:{
                    value = maximumBoardPower.to;   //set the slider to max value initially
                }

                onMoved: {
                    //we'll need to address how to handle this when there are devices attached, as that would trigger
                    //renegotiation with all devices
                    platformInterface.set_maximum_board_power.update(value);
                }
            }

            SGSubmitInfoBox {
                id: maximumBoardPowerInput
                showButton: false
                infoBoxWidth: 30
                anchors {
                    verticalCenter: maximumBoardPower.verticalCenter
                    verticalCenterOffset: -7
                    right: maximumBoardPowerUnits.left
                    rightMargin: 5
                }
                onApplied: {
                    platformInterface.set_maximum_board_power.update(maximumBoardPowerInput.intValue);

                value: platformInterface.maximum_board_power.watts
                }
            }

            Text{
                id: maximumBoardPowerUnits
                text: "W"
                anchors {
                    right: parent.right
                    verticalCenter: maximumBoardPowerInput.verticalCenter
                }
            }

            Text{
                id: powerNegotiationTitleText
                text: "Power Negotiation:"
                anchors {
                    top: maximumBoardPower.bottom
                    topMargin: 10
                    left: margins1.left
                    leftMargin: 92
                }
            }

            Text{
                id: powerNegotiationText
                text: "First come, first served"
                color:"dimgray"
                anchors {
                    top: maximumBoardPower.bottom
                    topMargin: 10
                    left: powerNegotiationTitleText.right
                    leftMargin: 10
                }
            }

            Text{
                id: assuredPortText
                text: "Assure Port 1 power:"
                anchors {
                    top: powerNegotiationText.bottom
                    topMargin:15
                    left: margins1.left
                    leftMargin: 82
                }
            }

            SGSwitch {
                id: assuredPortSwitch
                anchors {
                    left: assuredPortText.right
                    leftMargin: 10
                    verticalCenter: assuredPortText.verticalCenter
                }
                checkedLabel: "On"
                uncheckedLabel: "Off"
                switchHeight: 20
                switchWidth: 46

                checked: platformInterface.assured_power_port.enabled
                onToggled: platformInterface.set_assured_power_port.update(checked, 1)  //we're only allowing port 1 to be assured

                Component.onCompleted: {
                    assuredPortSwitch.checked =  false
                }
            }

            SGComboBox {
                id: assuredMaxPowerOutput
                label: "Maximum Assured Power:"
                model: ["15","27", "36", "45","60","100"]
                comboBoxHeight: 25
                comboBoxWidth: 60
                anchors {

                    top: assuredPortText.top
                    topMargin: 30
                    left: margins1.left
                    leftMargin: 53
                }

                //when changing the value
                onActivated: {
                    console.log("setting max power to ",parseInt(assuredMaxPowerOutput.comboBox.currentText));
                    platformInterface.set_usb_pd_maximum_power.update(1,parseInt(assuredMaxPowerOutput.comboBox.currentText))
                }

                //notification of a change from elsewhere
                property var currentMaximumPower: platformInterface.usb_pd_maximum_power.commanded_max_power
                onCurrentMaximumPowerChanged: {
                    if (platformInterface.usb_pd_maximum_power.port === 1){
                        assuredMaxPowerOutput.currentIndex = assuredMaxPowerOutput.comboBox.find( parseInt (platformInterface.usb_pd_maximum_power.commanded_max_power))
                    }

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
                    top: assuredMaxPowerOutput.bottom
                    topMargin: 10
                    left: margins1.left
                    leftMargin: 132
                }



                segmentedButtons: GridLayout {
                    columnSpacing: 2

                    property var sleepMode: platformInterface.sleep_mode.mode

                    onSleepModeChanged:{
                        if (platformInterface.sleep_mode.mode === "off"){
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
                        text: qsTr("Off")
                        checked: true  // Sets default checked button when exclusive

                        onClicked: {
                            platformInterface.set_sleep_mode.update("off");
                        }
                    }

                    SGSegmentedButton{
                        id:automaticSleepModeButton
                        text: qsTr("Automatic")
                        onClicked: {
                            platformInterface.set_sleep_mode.update("automatic");
                        }
                    }
                }
            }


            Text {
                id: faultHeader
                text: "<b>Faults</b>"
                font {
                    pixelSize: 16
                }
                anchors.top: sleepMode.bottom
                anchors.topMargin: 10
            }

            SGSegmentedButtonStrip {
                id: faultProtection
                anchors {
                    top: faultHeader.bottom
                    topMargin: 10
                    left: margins1.left
                    leftMargin: 109
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
                    leftMargin: 65
                    top: faultProtection.bottom
                    topMargin: 10
                    right: inputFaultInput.left
                    rightMargin: 10
                }
                from: 0
                to: 20
                startLabel: "0V"
                endLabel: "20V"
                labelTopAligned: true
                value: platformInterface.input_under_voltage_notification.minimum_voltage
                onMoved: {
                    platformInterface.set_minimum_input_voltage.update(value);
                }
            }

            SGSubmitInfoBox {
                id: inputFaultInput
                showButton: false
                infoBoxWidth: 30
                anchors {
                    verticalCenter: inputFault.verticalCenter
                    verticalCenterOffset: -7
                    right: inputFaultUnits.left
                    rightMargin: 5
                }
                value: platformInterface.input_under_voltage_notification.minimum_voltage
                onApplied:{
                    var currentValue = parseFloat(value)
                    platformInterface.set_minimum_input_voltage.update(currentValue);   // slider will be updated via notification
                }
            }

            Text{
                id: inputFaultUnits
                text: "V"
                anchors {
                    right: parent.right
                    verticalCenter: inputFaultInput.verticalCenter
                }
            }

            SGSlider {
                id: tempFault
                label: "Fault when temperature above:"
                anchors {
                    left: parent.left
                    leftMargin:20
                    top: inputFault.bottom
                    topMargin: 10
                    right: tempFaultInput.left
                    rightMargin: 10
                }
                from: -64
                to: 191
                startLabel: "-64°C"
                endLabel: "191°C"
                labelTopAligned: true
                value: platformInterface.set_maximum_temperature_notification.maximum_temperature
                onMoved: {
                    platformInterface.set_maximum_temperature.update(value);
                }
            }

            SGSubmitInfoBox {
                id: tempFaultInput
                showButton: false
                infoBoxWidth: 30
                anchors {
                    verticalCenter: tempFault.verticalCenter
                    verticalCenterOffset: -7
                    right: tempFaultUnits.left
                    rightMargin: 5
                }
                value: platformInterface.set_maximum_temperature_notification.maximum_temperature
                onApplied:{
                    console.log("temp fault value onApplied");
                    var currentValue = parseFloat(value)
                    platformInterface.set_maximum_temperature.update(currentValue); // slider will be updated via notification
                }
            }

            Text{
                id: tempFaultUnits
                text: "°C"
                anchors {
                    right: parent.right
                    verticalCenter: tempFaultInput.verticalCenter
                }
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
                text: "<b>Input Foldback</b>"
                font {
                    pixelSize: 16
                }
            }

            Text{
                id: inputFoldbackStatus
                text: "Active:"
                anchors {
                    top: inputFoldback.bottom
                    topMargin:15
                    left: margins2.left
                    leftMargin: 122
                }
            }

            SGSwitch {
                id: inputFoldbackSwitch
                anchors {
                    left: inputFoldbackStatus.right
                    leftMargin: 10
                    verticalCenter: inputFoldbackStatus.verticalCenter
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
                    leftMargin: 91
                    top: inputFoldbackStatus.bottom
                    topMargin: 15
                    right: foldbackLimitInput.left
                    rightMargin: 10
                }
                from: 0
                to: 20
                startLabel: "0V"
                endLabel: "20V"
                labelTopAligned: true
                //copy the current values for other stuff, and add the new slider value for the limit.
                onMoved: platformInterface.set_input_voltage_foldback.update(platformInterface.foldback_input_voltage_limiting_event.input_voltage_foldback_enabled,
                                 value,
                                platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage_power)
            }

            SGSubmitInfoBox {
                id: foldbackLimitInput
                showButton: false
                infoBoxWidth: 30
                anchors {
                    verticalCenter: foldbackLimit.verticalCenter
                    verticalCenterOffset: -7
                    right: foldbackLimitUnits.left
                    rightMargin: 5
                }
                value: platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage
                onApplied: platformInterface.set_input_voltage_foldback.update(platformInterface.foldback_input_voltage_limiting_event.input_voltage_foldback_enabled,
                                                                              parseFloat(value),
                                                                              platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage_power)
            }

            Text{
                id: foldbackLimitUnits
                text: "V"
                anchors {
                    right: parent.right
                    verticalCenter: foldbackLimitInput.verticalCenter
                }
            }

            SGComboBox {
                id: limitOutput
                label: "Limit output power to:"
                model: ["15","27", "36", "45","60","100"]
                comboBoxHeight: 25
                comboBoxWidth: 70
                anchors {
                    left: parent.left
                    leftMargin:30
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



            Text {
                id: tempFoldback
                text: "<b>Temperature Foldback</b>"
                font {
                    pixelSize: 16
                }
                anchors {
                    top: limitOutput.bottom
                    topMargin: 15
                }
            }

            Text{
                id: temperatureFoldbackStatus
                text: "Active:"
                anchors {
                    top: tempFoldback.bottom
                    topMargin:15
                    left: margins2.left
                    leftMargin: 120
                }
            }

            SGSwitch {
                id: tempFoldbackSwitch
                anchors {
                    left: temperatureFoldbackStatus.right
                    leftMargin: 10
                    verticalCenter: temperatureFoldbackStatus.verticalCenter
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
                    leftMargin: 87
                    top: temperatureFoldbackStatus.bottom
                    topMargin: 10
                    right: foldbackTempInput.left
                    rightMargin: 10
                }
                from: 25
                to: 200
                startLabel: "25°C"
                endLabel: "200°C"
                labelTopAligned: true
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
                showButton: false
                infoBoxWidth: 30
                anchors {
                    verticalCenter: foldbackTemp.verticalCenter
                    verticalCenterOffset: -7
                    right: foldbackTempUnits.left
                    rightMargin: 5
                }
                value: platformInterface.foldback_temperature_limiting_event.foldback_maximum_temperature
                onApplied: platformInterface.set_temperature_foldback.update(platformInterface.foldback_temperature_limiting_event.temperature_foldback_enabled,
                                                                             parseFloat(value),
                                                                             platformInterface.foldback_temperature_limiting_event.foldback_maximum_temperature_power)
            }

            Text{
                id: foldbackTempUnits
                text: "°C"
                anchors {
                    right: parent.right
                    verticalCenter: foldbackTempInput.verticalCenter
                }
            }

            SGComboBox {
                id: limitOutput2
                label: "Reduce output power to:"
                model: ["10","15", "25", "50","75","90"]
                comboBoxHeight: 25
                comboBoxWidth: 60
                anchors {
                    left: parent.left
                    leftMargin: 10
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

            Text{
                id:percentLabel
                text:"percent"
                anchors{
                    left:limitOutput2.right
                    leftMargin: 5
                    verticalCenter: limitOutput2.verticalCenter
                }
            }
        }
    }
}
