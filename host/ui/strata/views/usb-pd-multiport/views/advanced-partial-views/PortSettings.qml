import QtQuick 2.9
import QtQuick.Layouts 1.3
import "qrc:/views/usb-pd-multiport/sgwidgets"

Item {
    id: root

    Item {
        id: controlMargins
        anchors {
            fill: parent
            margins: 15
        }

        SGComboBox {
            id: maxPowerOutput
            label: "Max Power Output:"
            model: ["15","27", "36", "45","60","100"]
            anchors {
                left: parent.left
                leftMargin: 23
                top: parent.top
            }

            //when changing the value
            onActivated: {
                console.log("setting max power to ",maxPowerOutput.comboBox.currentText);
                platformInterface.set_usb_pd_maximum_power.update(port,maxPowerOutput.comboBox.currentText)
            }

            //notification of a change from elsewhere
            property var currentMaximumPower: platformInterface.usb_pd_maximum_power.current_max_power
            onCurrentMaximumPowerChanged: {
                if (platformInterface.usb_pd_maximum_power.port === port){
                    maxPowerOutput.currentIndex = maxPowerOutput.comboBox.find( parseInt (platformInterface.usb_pd_maximum_power.current_max_power))
                }

            }


        }


        SGSlider {
            id: currentLimit
            label: "Current limit:"
            value: platformInterface.request_over_current_protection_notification.current_limit
            anchors {
                left: parent.left
                leftMargin: 61
                top: maxPowerOutput.bottom
                topMargin: 10
                right: currentLimitInput.left
                rightMargin: 10
            }

            onValueChanged: platformInterface.set_over_current_protection.update(port, value)

        }

        SGSubmitInfoBox {
            id: currentLimitInput
            buttonVisible: false
            anchors {
                verticalCenter: currentLimit.verticalCenter
                right: parent.right
            }
            input: currentLimit.value.toFixed(0)
            onApplied: currentLimit.value = value
        }

        SGDivider {
            id: div1
            anchors {
                top: currentLimit.bottom
                topMargin: 15
            }
        }

        Text {
            id: cableCompensation
            text: "<b>Cable Compensation:</b>"
            font {
                pixelSize: 16
            }
            anchors {
                top: div1.bottom
                topMargin: 15
            }
        }

        SGSlider {
            id: increment
            label: "For every increment of:"
            value:platformInterface.get_cable_loss_compensation.output_current
            from:0
            to:3
            anchors {
                left: parent.left
                top: cableCompensation.bottom
                topMargin: 10
                right: incrementInput.left
                rightMargin: 10
            }
            onMoved:{
                platformInterface.set_cable_loss_compensation.update(portNumber,
                                                                     increment.value,
                                                                     platformInterface.get_cable_loss_compensation.bias_voltage)
            }

        }

        SGSubmitInfoBox {
            id: incrementInput
            buttonVisible: false
            anchors {
                verticalCenter: increment.verticalCenter
                right: parent.right
            }
            input: increment.value.toFixed(0)
            onApplied: increment.value = value
        }

        SGSlider {
            id: bias
            label: "Bias output by:"
            value:platformInterface.get_cable_loss_compensation.bias_voltage
            from:0
            to:2
            anchors {
                left: parent.left
                leftMargin: 50
                top: increment.bottom
                topMargin: 10
                right: biasInput.left
                rightMargin: 10
            }
            onMoved: {
                platformInterface.set_cable_loss_compensation.update(portNumber,
                                                                     platformInterface.get_cable_loss_compensation.output_current,
                                                                     bias.value)
            }

        }

        SGSubmitInfoBox {
            id: biasInput
            buttonVisible: false
            anchors {
                verticalCenter: bias.verticalCenter
                right: parent.right
            }
            input: bias.value.toFixed(0)
            onApplied: bias.value = value
        }


        SGDivider {
            id: div2
            height: 1
            anchors {
                top: bias.bottom
                topMargin: 15
            }
        }

        Text {
            id: advertisedVoltages
            text: "<b>Advertised Voltages:</b>"
            font {
                pixelSize: 16
            }
            anchors {
                top: div2.bottom
                topMargin: 15
            }
        }

        SGSegmentedButtonStrip {
            id: faultProtection
            anchors {
                left: advertisedVoltages.right
                leftMargin: 10
                verticalCenter: advertisedVoltages.verticalCenter
            }
            textColor: "#666"
            activeTextColor: "white"
            radius: 4
            buttonHeight: 25
            hoverEnabled: false

            property var sourceCapabilities: platformInterface.usb_pd_advertised_voltages_notification.settings

            onSourceCapabilitiesChanged:{
                if (platformInterface.usb_pd_advertised_voltages_notification.port === port){
                    //disable all the possibilities
                    setting7.enabled = false;
                    setting6.enabled = false;
                    setting5.enabled = false;
                    setting4.enabled = false;
                    setting3.enabled = false;
                    setting2.enabled = false;
                    setting1.enabled = false;

                    var numberOfSettings = platformInterface.usb_pd_advertised_voltages_notification.number_of_settings;
                    if (numberOfSettings >= 7){
                        setting7.enabled = true;
                        setting7.text = platformInterface.usb_pd_advertised_voltages_notification.settings[7].voltage;
                        setting7.text += "V, ";
                        setting7.text += platformInterface.usb_pd_advertised_voltages_notification.settings[7].maximum_current;
                        setting7.text += "A";
                    }
                    if (numberOfSettings >= 6){
                        setting6.enabled = true;
                        setting6.text = platformInterface.usb_pd_advertised_voltages_notification.settings[6].voltage;
                        setting6.text += "V, ";
                        setting6.text += platformInterface.usb_pd_advertised_voltages_notification.settings[6].maximum_current;
                        setting6.text += "A";
                    }
                    if (numberOfSettings >= 5){
                        setting5.enabled = true;
                        setting5.text = platformInterface.usb_pd_advertised_voltages_notification.settings[5].voltage;
                        setting5.text += "V, ";
                        setting5.text += platformInterface.usb_pd_advertised_voltages_notification.settings[5].maximum_current;
                        setting5.text += "A";
                    }
                    if (numberOfSettings >= 4){
                        setting4.enabled = true;
                        setting4.text = platformInterface.usb_pd_advertised_voltages_notification.settings[4].voltage;
                        setting4.text += "V, ";
                        setting4.text += platformInterface.usb_pd_advertised_voltages_notification.settings[4].maximum_current;
                        setting4.text += "A";
                    }
                    if (numberOfSettings >= 3){
                        setting3.enabled = true;
                        setting3.text = platformInterface.usb_pd_advertised_voltages_notification.settings[3].voltage;
                        setting3.text += "V, ";
                        setting3.text += platformInterface.usb_pd_advertised_voltages_notification.settings[3].maximum_current;
                        setting3.text += "A";
                    }
                    if (numberOfSettings >= 2){
                        setting2.enabled = true;
                        setting7.text = platformInterface.usb_pd_advertised_voltages_notification.settings[2].voltage;
                        setting7.text += "V, ";
                        setting7.text += platformInterface.usb_pd_advertised_voltages_notification.settings[2].maximum_current;
                        setting7.text += "A";
                    }
                    if (numberOfSettings >= 2){
                        setting1.enabled = true;
                        setting1.text = platformInterface.usb_pd_advertised_voltages_notification[1].voltage;
                        setting1.text += "V, ";
                        setting1.text += platformInterface.usb_pd_advertised_voltages_notification[1].maximum_current;
                        setting1.text += "A";
                    }

                }
            }

            segmentedButtons: GridLayout {
                columnSpacing: 2

                SGSegmentedButton{
                    id: setting1
                    //text: qsTr("5V, 3A")
                    checkable: false
                }

                SGSegmentedButton{
                    id: setting2
                    //text: qsTr("7V, 3A")
                    checkable: false
                }

                SGSegmentedButton{
                    id:setting3
                    //text: qsTr("8V, 3A")
                    checkable: false
                }

                SGSegmentedButton{
                    id:setting4
                    //text: qsTr("9V, 3A")
                    //enabled: false
                    checkable: false
                }

                SGSegmentedButton{
                    id:setting5
                    //text: qsTr("12V, 3A")
                    //enabled: false
                    checkable: false
                }

                SGSegmentedButton{
                    id:setting6
                    //text: qsTr("15V, 3A")
                    //enabled: false
                    checkable: false
                }

                SGSegmentedButton{
                    id:setting7
                    //text: qsTr("20V, 3A")
                    //enabled: false
                    checkable: false
                }
            }
        }
    }
}
