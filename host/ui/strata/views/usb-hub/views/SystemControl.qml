import QtQuick 2.9
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.3
import "qrc:/views/usb-pd-multiport/sgwidgets"

Item {
    id: systemControls

    property bool debugLayout: false
    property real ratioCalc: systemControls.width / 1200

    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height

    anchors {
        fill: parent
    }

    Column{
        id:controlColumn
        anchors.top: systemControls.top
        anchors.topMargin: 50
        anchors.left: systemControls.left
        anchors.leftMargin: systemControls.width/4
        anchors.right: systemControls.right
        anchors.rightMargin: systemControls.width/4
        anchors.bottom: systemControls.bottom
        anchors.bottomMargin: 50

        spacing: 25

        Rectangle{
            id:powerGroup
            color:"lightYellow"
            height:150
            width: controlColumn.width
            radius:5

            Text {
                id: powerLabel
                text: "<b>Power</b>"
                font {
                    pixelSize: 24
                }
                anchors {
                    top: powerGroup.top
                    topMargin: 15
                    left: powerGroup.left
                    leftMargin: 10
                }
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
                    left: powerGroup.left
                    leftMargin: 60
                    top: powerLabel.bottom
                    topMargin: 10
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

            SGSlider {
                id: maximumBoardPower
                label: "Maximum Power:"
                width: 450
                anchors {
                    left: powerGroup.left
                    leftMargin: 70
                    top:powerNegotiation.bottom
                    topMargin: 20
                }
                from: 30
                to: 200
                startLabel: "30W"
                endLabel: "200W"
                    //value: platformInterface.input_under_voltage_notification.minimum_voltage
                onMoved: {
                    //platformInterface.set_minimum_input_voltage.update(value);
                }
            }

            SGSubmitInfoBox {
                id: maximumBoardPowerInput
                buttonVisible: false
                anchors {
                    verticalCenter: maximumBoardPower.verticalCenter
                    left: maximumBoardPower.right
                    leftMargin: 15
                }
                //input: inputFault.value.toFixed(0)
                //onApplied: platformInterface.set_minimum_input_voltage.update(input);   // slider will be updated via notification
            }
        }

        Rectangle{
            id:faultGroup
            color:"lightYellow"
            height:150
            width: parent.width

            Text {
                id: faultLabel
                text: "<b>Faults</b>"
                font {
                    pixelSize: 24
                }
                anchors {
                    top: faultGroup.top
                    topMargin: 15
                    left: faultGroup.left
                    leftMargin: 10
                }
            }

            SGSegmentedButtonStrip {
                id: faultProtection
                anchors {
                    top: faultLabel.bottom
                    topMargin: 10
                    left: faultGroup.left
                    leftMargin: 100
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
                id: tempFault
                label: "Fault when temperature above:"
                width:450
                anchors {
                    left: parent.left
                    leftMargin: 40
                    top: faultProtection.bottom
                    topMargin: 10

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
                    left:tempFault.right
                    leftMargin: 10
                }
                input: tempFault.value.toFixed(0)
                onApplied: platformInterface.set_maximum_temperature.update(input); // slider will be updated via notification
            }
        }

        Rectangle{
            id:foldbackGroup
            color:"lightYellow"
            height:150
            width: parent.width
            radius:5

            Text {
                id: tempFoldback
                text: "<b>Temperature Foldback</b>"
                font {
                    pixelSize: 24
                }
                anchors {
                    top: foldbackGroup.top
                    topMargin: 15
                    left: foldbackGroup.left
                    leftMargin: 10
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
                width:400
                anchors {
                    left: parent.left
                    leftMargin: 60
                    top: tempFoldback.bottom
                    topMargin: 10
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
                    left:foldbackTemp.right
                    leftMargin: 10
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
                    leftMargin: 50
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
