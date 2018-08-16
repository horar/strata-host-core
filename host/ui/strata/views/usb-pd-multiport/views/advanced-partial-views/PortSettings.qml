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
                platformInterface.set_usb_pd_maximum_power.update(portNumber,maxPowerOutput.comboBox.currentText)
            }

            //notification of a change from elsewhere
            property var currentMaximumPower: platformInterface.usb_pd_maximum_power.current_max_power
            onCurrentMaximumPowerChanged: {
                if (platformInterface.usb_pd_maximum_power.port === portNumber){
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
            id: faultProtectionButtonStrip
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

            Component.onCompleted: {

               // console.log(faultProtectionButtonStrip.children)
                for (var i=0; i< faultProtectionButtonStrip.children.length; i++) {
                    console.log("button strip has ",faultProtectionButtonStrip.children.length,"children");
                    console.log("advertized voltages child ",faultProtectionButtonStrip.children[i].id);
                }
            }

            property var sourceCapabilities: platformInterface.usb_pd_advertised_voltages_notification.settings

            onSourceCapabilitiesChanged:{

                console.log("updating advertised voltages for port ",portNumber)
                //the strip's first child is the Grid layout. The children of that layout are the buttons in
                //question. This makes accessing the buttons a little bit cumbersome since they're loaded dynamically.
                if (platformInterface.usb_pd_advertised_voltages_notification.port === portNumber){
                    //disable all the possibilities
//                    faultProtectionButtonStrip.children[0].children[6].enabled = false;
//                    faultProtectionButtonStrip.children[0].children[5].enabled = false;
//                    faultProtectionButtonStrip.children[0].children[4].enabled = false;
//                    faultProtectionButtonStrip.children[0].children[3].enabled = false;
//                    faultProtectionButtonStrip.children[0].children[2].enabled = false;
//                    faultProtectionButtonStrip.children[0].children[1].enabled = false;
//                    faultProtectionButtonStrip.children[0].children[0].enabled = false;
//                    setting6.enabled = false;
//                    setting5.enabled = false;
//                    setting4.enabled = false;
//                    setting3.enabled = false;
//                    setting2.enabled = false;
//                    setting1.enabled = false;

                    var numberOfSettings = platformInterface.usb_pd_advertised_voltages_notification.number_of_settings;
                    if (numberOfSettings >= 7){
//                        faultProtectionButtonStrip.children[0].children[6].enabled = true;
//                        faultProtectionButtonStrip.children[0].children[6].text = platformInterface.usb_pd_advertised_voltages_notification.settings[7].voltage;
//                        faultProtectionButtonStrip.children[0].children[6].text += "V, ";
//                        faultProtectionButtonStrip.children[0].children[6].text += platformInterface.usb_pd_advertised_voltages_notification.settings[7].maximum_current;
//                        faultProtectionButtonStrip.children[0].children[6].text += "A";
                    }
                    if (numberOfSettings >= 6){
//                        faultProtectionButtonStrip.children[0].children[5].enabled = true;
//                        faultProtectionButtonStrip.children[0].children[5].text = platformInterface.usb_pd_advertised_voltages_notification.settings[6].voltage;
//                        faultProtectionButtonStrip.children[0].children[5].text += "V, ";
//                        faultProtectionButtonStrip.children[0].children[5].text += platformInterface.usb_pd_advertised_voltages_notification.settings[6].maximum_current;
//                        faultProtectionButtonStrip.children[0].children[5].text += "A";
                    }
                    if (numberOfSettings >= 5){
//                        faultProtectionButtonStrip.children[0].children[4].enabled = true;
//                        faultProtectionButtonStrip.children[0].children[4].text = platformInterface.usb_pd_advertised_voltages_notification.settings[5].voltage;
//                        faultProtectionButtonStrip.children[0].children[4].text += "V, ";
//                        faultProtectionButtonStrip.children[0].children[4].text += platformInterface.usb_pd_advertised_voltages_notification.settings[5].maximum_current;
//                        faultProtectionButtonStrip.children[0].children[4].text += "A";
                    }
                    if (numberOfSettings >= 4){
//                        setting4.enabled = true;
//                        setting4.text = platformInterface.usb_pd_advertised_voltages_notification.settings[4].voltage;
//                        setting4.text += "V, ";
//                        setting4.text += platformInterface.usb_pd_advertised_voltages_notification.settings[4].maximum_current;
//                        setting4.text += "A";
                    }
                    if (numberOfSettings >= 3){
//                        setting3.enabled = true;
//                        setting3.text = platformInterface.usb_pd_advertised_voltages_notification.settings[3].voltage;
//                        setting3.text += "V, ";
//                        setting3.text += platformInterface.usb_pd_advertised_voltages_notification.settings[3].maximum_current;
//                        setting3.text += "A";
                    }
                    if (numberOfSettings >= 2){
//                        setting2.enabled = true;
//                        setting2.text = platformInterface.usb_pd_advertised_voltages_notification.settings[2].voltage;
//                        setting2.text += "V, ";
//                        setting2.text += platformInterface.usb_pd_advertised_voltages_notification.settings[2].maximum_current;
//                        setting2.text += "A";
                    }
                    if (numberOfSettings >= 2){
//                        setting1.enabled = true;
//                        setting1.text = platformInterface.usb_pd_advertised_voltages_notification[1].voltage;
//                        setting1.text += "V, ";
//                        setting1.text += platformInterface.usb_pd_advertised_voltages_notification[1].maximum_current;
//                        setting1.text += "A";
                    }

                }
            }

            segmentedButtons: GridLayout {
                id:advertisedVoltageGridLayout
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
